#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "numpy>=1.26,<3",
#   "Pillow>=10,<13",
# ]
# ///

"""Find video shots that resemble a set of reference screenshots.

This intentionally uses lightweight, hand-crafted image features instead of a
neural model. It is suitable for CPU-only machines and produces a candidate
gallery for human review rather than pretending to be a perfect character
recognizer.
"""

from __future__ import annotations

import argparse
import csv
import heapq
import math
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

import numpy as np
from PIL import Image, ImageDraw, ImageFont


FRAME_WIDTH = 160
FRAME_HEIGHT = 90
LAYOUT_WIDTH = 32
LAYOUT_HEIGHT = 18
SUPPORTED_IMAGES = {".jpg", ".jpeg", ".png", ".webp"}
SUPPORTED_VIDEOS = {".mkv", ".mp4", ".webm", ".m4v", ".avi"}
REFERENCE_PRESETS = {
    # https://www.reddit.com/r/SonnyBoy/comments/raxhog/nozomi_eyes/
    "nozomi-eyes": (
        "https://i.redd.it/ec4vq6s304481.jpg",
        "https://i.redd.it/6fhew6s304481.jpg",
        "https://i.redd.it/pug7f6s304481.jpg",
        "https://i.redd.it/fktdg8s304481.jpg",
        "https://i.redd.it/kmwh07s304481.jpg",
        "https://i.redd.it/5xal17s304481.jpg",
    ),
}


@dataclass(frozen=True)
class Signature:
    layout: np.ndarray
    histogram: np.ndarray
    edges: np.ndarray
    masks: tuple[np.ndarray, np.ndarray, np.ndarray]
    difference_hash: int


@dataclass(frozen=True)
class Candidate:
    score: float
    video: Path
    seconds: float
    known_distance: int
    pale_coverage: float


def command_path(name: str) -> str:
    path = shutil.which(name)
    if path is None:
        raise RuntimeError(f"required command not found: {name}")
    return path


def resize_rgb(array: np.ndarray, width: int, height: int) -> np.ndarray:
    image = Image.fromarray(array, "RGB")
    return np.asarray(image.resize((width, height), Image.Resampling.BILINEAR))


def normalized(vector: np.ndarray) -> np.ndarray:
    vector = vector.astype(np.float32, copy=False).reshape(-1)
    norm = float(np.linalg.norm(vector))
    return vector / norm if norm else vector


def difference_hash(array: np.ndarray) -> int:
    gray = Image.fromarray(array, "RGB").convert("L").resize((9, 8), Image.Resampling.BILINEAR)
    pixels = np.asarray(gray)
    bits = pixels[:, 1:] > pixels[:, :-1]
    value = 0
    for bit in bits.reshape(-1):
        value = (value << 1) | int(bit)
    return value


def make_signature(array: np.ndarray) -> Signature:
    small = resize_rgb(array, LAYOUT_WIDTH, LAYOUT_HEIGHT)
    layout = small.astype(np.float32) / 255.0

    hsv = np.asarray(Image.fromarray(array, "RGB").convert("HSV"))
    hue = hsv[..., 0].astype(np.int32) * 16 // 256
    saturation = hsv[..., 1].astype(np.int32) * 4 // 256
    value = hsv[..., 2].astype(np.int32) * 4 // 256
    bins = hue * 16 + saturation * 4 + value
    histogram = normalized(np.bincount(bins.reshape(-1), minlength=256))

    gray = np.asarray(Image.fromarray(small, "RGB").convert("L"), dtype=np.float32) / 255.0
    gradient_x = np.diff(gray, axis=1, prepend=gray[:, :1])
    gradient_y = np.diff(gray, axis=0, prepend=gray[:1, :])
    edges = normalized(np.hypot(gradient_x, gradient_y))

    red = small[..., 0]
    green = small[..., 1]
    blue = small[..., 2]
    maximum = small.max(axis=2)
    minimum = small.min(axis=2)
    low_saturation = maximum - minimum < 45
    sclera = (maximum > 175) & low_saturation
    dark = maximum < 85
    skin = (
        (red > 145)
        & (green > 85)
        & (blue > 65)
        & (red > green)
        & (green >= blue)
        & ((red.astype(np.int16) - blue.astype(np.int16)) > 35)
    )

    return Signature(
        layout=layout.reshape(-1),
        histogram=histogram,
        edges=edges,
        masks=(sclera.reshape(-1), dark.reshape(-1), skin.reshape(-1)),
        difference_hash=difference_hash(array),
    )


def cosine(first: np.ndarray, second: np.ndarray) -> float:
    denominator = float(np.linalg.norm(first) * np.linalg.norm(second))
    return float(np.dot(first, second) / denominator) if denominator else 0.0


def dice(first: np.ndarray, second: np.ndarray) -> float:
    overlap = int(np.logical_and(first, second).sum())
    total = int(first.sum()) + int(second.sum())
    return (2.0 * overlap / total) if total else 1.0


def signature_similarity(first: Signature, second: Signature) -> float:
    layout = 1.0 - float(np.abs(first.layout - second.layout).mean())
    histogram = cosine(first.histogram, second.histogram)
    edges = cosine(first.edges, second.edges)
    masks = sum(dice(left, right) for left, right in zip(first.masks, second.masks)) / 3.0
    return 0.38 * layout + 0.27 * histogram + 0.20 * edges + 0.15 * masks


def hamming_distance(first: int, second: int) -> int:
    return (first ^ second).bit_count()


def pale_coverage(signature: Signature) -> float:
    sclera, _dark, skin = signature.masks
    return float(np.logical_or(sclera, skin).mean())


def expand_paths(paths: Sequence[Path], suffixes: set[str]) -> list[Path]:
    expanded: set[Path] = set()
    for path in paths:
        path = path.expanduser().resolve()
        if path.is_dir():
            expanded.update(item for item in path.rglob("*") if item.suffix.lower() in suffixes)
        elif path.suffix.lower() in suffixes and path.is_file():
            expanded.add(path)
        else:
            raise ValueError(f"unsupported or missing path: {path}")
    return sorted(expanded)


def load_references(paths: Sequence[Path]) -> tuple[list[Path], list[Signature]]:
    references = expand_paths(paths, SUPPORTED_IMAGES)
    if not references:
        raise ValueError("no reference images found")
    signatures = []
    for path in references:
        with Image.open(path) as image:
            array = np.asarray(image.convert("RGB").resize((FRAME_WIDTH, FRAME_HEIGHT)))
        signatures.append(make_signature(array))
    return references, signatures


def download_reference_preset(name: str, directory: Path) -> list[Path]:
    paths = []
    for index, url in enumerate(REFERENCE_PRESETS[name], 1):
        destination = directory / f"{name}-{index:02d}.jpg"
        request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(request) as response:
            destination.write_bytes(response.read())
        paths.append(destination)
    return paths


def iter_sampled_frames(video: Path, frames_per_second: float) -> Iterable[tuple[float, np.ndarray]]:
    ffmpeg = command_path("ffmpeg")
    command = [
        ffmpeg,
        "-nostdin",
        "-hide_banner",
        "-loglevel",
        "error",
        "-i",
        str(video),
        "-map",
        "0:v:0",
        "-vf",
        f"fps={frames_per_second},scale={FRAME_WIDTH}:{FRAME_HEIGHT}:flags=area",
        "-pix_fmt",
        "rgb24",
        "-f",
        "rawvideo",
        "-",
    ]
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert process.stdout is not None
    frame_size = FRAME_WIDTH * FRAME_HEIGHT * 3
    index = 0
    while True:
        data = process.stdout.read(frame_size)
        if not data:
            break
        if len(data) != frame_size:
            process.kill()
            raise RuntimeError(f"ffmpeg returned a partial frame for {video}")
        frame = np.frombuffer(data, dtype=np.uint8).reshape(FRAME_HEIGHT, FRAME_WIDTH, 3)
        yield index / frames_per_second, frame
        index += 1

    stderr = process.stderr.read().decode(errors="replace") if process.stderr else ""
    return_code = process.wait()
    if return_code:
        raise RuntimeError(f"ffmpeg failed for {video}: {stderr.strip()}")


def scan_videos(
    videos: Sequence[Path],
    references: Sequence[Signature],
    frames_per_second: float,
    pool_size: int,
) -> list[Candidate]:
    heap: list[tuple[float, int, Candidate]] = []
    serial = 0
    reference_hashes = [reference.difference_hash for reference in references]

    for video_index, video in enumerate(videos, 1):
        frame_count = 0
        for seconds, frame in iter_sampled_frames(video, frames_per_second):
            signature = make_signature(frame)
            score = max(signature_similarity(signature, reference) for reference in references)
            known_distance = min(hamming_distance(signature.difference_hash, value) for value in reference_hashes)
            candidate = Candidate(
                score=score,
                video=video,
                seconds=seconds,
                known_distance=known_distance,
                pale_coverage=pale_coverage(signature),
            )
            item = (score, serial, candidate)
            serial += 1
            if len(heap) < pool_size:
                heapq.heappush(heap, item)
            elif score > heap[0][0]:
                heapq.heapreplace(heap, item)
            frame_count += 1
        print(f"Scanned {video_index}/{len(videos)}: {video.name} ({frame_count} frames)", flush=True)

    return [item[2] for item in sorted(heap, reverse=True)]


def select_distinct_candidates(
    candidates: Sequence[Candidate],
    limit: int,
    minimum_score: float,
    minimum_gap: float,
    include_known: bool,
    known_hash_distance: int,
    minimum_pale_coverage: float,
) -> list[Candidate]:
    selected: list[Candidate] = []
    for candidate in candidates:
        if candidate.score < minimum_score:
            continue
        if candidate.pale_coverage < minimum_pale_coverage:
            continue
        if not include_known and candidate.known_distance <= known_hash_distance:
            continue
        if any(
            existing.video == candidate.video
            and abs(existing.seconds - candidate.seconds) < minimum_gap
            for existing in selected
        ):
            continue
        selected.append(candidate)
        if len(selected) == limit:
            break
    return selected


def format_timestamp(seconds: float) -> str:
    milliseconds = round(seconds * 1000)
    hours, remainder = divmod(milliseconds, 3_600_000)
    minutes, remainder = divmod(remainder, 60_000)
    whole_seconds, milliseconds = divmod(remainder, 1000)
    return f"{hours:02d}:{minutes:02d}:{whole_seconds:02d}.{milliseconds:03d}"


def extract_frame(candidate: Candidate, destination: Path) -> None:
    ffmpeg = command_path("ffmpeg")
    subprocess.run(
        [
            ffmpeg,
            "-nostdin",
            "-hide_banner",
            "-loglevel",
            "error",
            "-ss",
            f"{candidate.seconds:.3f}",
            "-i",
            str(candidate.video),
            "-frames:v",
            "1",
            "-q:v",
            "2",
            "-y",
            str(destination),
        ],
        check=True,
    )


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for path in (
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
        Path("/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf"),
    ):
        if path.is_file():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def make_contact_sheets(
    selected: Sequence[Candidate],
    frame_paths: Sequence[Path],
    output_directory: Path,
    columns: int = 4,
    rows: int = 4,
) -> None:
    thumb_width = 320
    thumb_height = 180
    label_height = 48
    page_size = columns * rows
    font = load_font(15)

    for page_index in range(math.ceil(len(selected) / page_size)):
        page = Image.new(
            "RGB",
            (columns * thumb_width, rows * (thumb_height + label_height)),
            "#15191f",
        )
        draw = ImageDraw.Draw(page)
        start = page_index * page_size
        page_candidates = selected[start : start + page_size]
        page_frames = frame_paths[start : start + page_size]
        for local_index, (candidate, frame_path) in enumerate(zip(page_candidates, page_frames)):
            column = local_index % columns
            row = local_index // columns
            x = column * thumb_width
            y = row * (thumb_height + label_height)
            with Image.open(frame_path) as frame:
                thumbnail = frame.convert("RGB")
                thumbnail.thumbnail((thumb_width, thumb_height), Image.Resampling.LANCZOS)
                page.paste(thumbnail, (x, y))
            rank = start + local_index + 1
            label = (
                f"#{rank}  score={candidate.score:.3f}  {format_timestamp(candidate.seconds)}\n"
                f"{candidate.video.stem[:44]}"
            )
            draw.text((x + 5, y + thumb_height + 4), label, fill="white", font=font)
        page.save(output_directory / f"contact-sheet-{page_index + 1:02d}.jpg", quality=92)


def write_results(
    selected: Sequence[Candidate],
    output_directory: Path,
) -> None:
    frames_directory = output_directory / "frames"
    frames_directory.mkdir(parents=True, exist_ok=True)
    frame_paths = []
    for rank, candidate in enumerate(selected, 1):
        path = frames_directory / f"{rank:03d}-{candidate.video.stem}-{candidate.seconds:.3f}.jpg"
        extract_frame(candidate, path)
        frame_paths.append(path)

    with (output_directory / "candidates.csv").open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(
            ("rank", "score", "pale_coverage", "known_hash_distance", "timestamp", "seconds", "video", "frame")
        )
        for rank, (candidate, frame_path) in enumerate(zip(selected, frame_paths), 1):
            writer.writerow(
                (
                    rank,
                    f"{candidate.score:.6f}",
                    f"{candidate.pale_coverage:.6f}",
                    candidate.known_distance,
                    format_timestamp(candidate.seconds),
                    f"{candidate.seconds:.3f}",
                    str(candidate.video),
                    str(frame_path),
                )
            )
    make_contact_sheets(selected, frame_paths, output_directory)


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Find CPU-only video-frame matches for reference screenshots.",
    )
    parser.add_argument("videos", type=Path, nargs="+", help="video files or directories to scan")
    parser.add_argument(
        "--references",
        type=Path,
        nargs="+",
        help="reference images or directories",
    )
    parser.add_argument("--preset", choices=sorted(REFERENCE_PRESETS), help="download a built-in reference set")
    parser.add_argument("--output", type=Path, required=True, help="new or empty output directory")
    parser.add_argument("--sample-fps", type=float, default=2.0, help="sample rate (default: 2)")
    parser.add_argument("--top", type=int, default=96, help="number of distinct candidate shots (default: 96)")
    parser.add_argument("--min-score", type=float, default=0.55, help="minimum similarity from 0 to 1")
    parser.add_argument(
        "--min-pale-coverage",
        type=float,
        help="minimum pale face/eye coverage; default is inferred from the references",
    )
    parser.add_argument("--min-gap", type=float, default=2.0, help="seconds between candidates from one video")
    parser.add_argument(
        "--include-known",
        action="store_true",
        help="include frames whose perceptual hash closely matches a reference",
    )
    parser.add_argument(
        "--known-hash-distance",
        type=int,
        default=5,
        help="maximum 64-bit dHash distance treated as a known frame",
    )
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    if arguments.sample_fps <= 0 or arguments.top <= 0 or arguments.min_gap < 0:
        raise ValueError("sample rate and top count must be positive; minimum gap cannot be negative")
    if not 0 <= arguments.min_score <= 1:
        raise ValueError("minimum score must be between 0 and 1")
    if arguments.min_pale_coverage is not None and not 0 <= arguments.min_pale_coverage <= 1:
        raise ValueError("minimum pale coverage must be between 0 and 1")
    if arguments.output.exists() and any(arguments.output.iterdir()):
        raise ValueError(f"output directory is not empty: {arguments.output}")

    if not arguments.references and not arguments.preset:
        raise ValueError("pass --references or --preset")

    with tempfile.TemporaryDirectory(prefix="similar-frame-references-") as temporary_directory:
        reference_inputs = list(arguments.references or [])
        if arguments.preset:
            reference_inputs.extend(download_reference_preset(arguments.preset, Path(temporary_directory)))
        reference_paths, reference_signatures = load_references(reference_inputs)
        videos = expand_paths(arguments.videos, SUPPORTED_VIDEOS)
        if not videos:
            raise ValueError("no videos found")

        print(f"Loaded {len(reference_paths)} references and found {len(videos)} videos.")
        minimum_pale_coverage = arguments.min_pale_coverage
        if minimum_pale_coverage is None:
            minimum_pale_coverage = max(
                0.0,
                min(pale_coverage(reference) for reference in reference_signatures) - 0.08,
            )
        print(f"Minimum pale close-up coverage: {minimum_pale_coverage:.3f}")
        pool_size = max(arguments.top * 20, 500)
        candidates = scan_videos(videos, reference_signatures, arguments.sample_fps, pool_size)
        selected = select_distinct_candidates(
            candidates,
            limit=arguments.top,
            minimum_score=arguments.min_score,
            minimum_gap=arguments.min_gap,
            include_known=arguments.include_known,
            known_hash_distance=arguments.known_hash_distance,
            minimum_pale_coverage=minimum_pale_coverage,
        )
    arguments.output.mkdir(parents=True, exist_ok=True)
    write_results(selected, arguments.output)
    print(f"Wrote {len(selected)} candidates to {arguments.output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError, ValueError) as error:
        print(f"Error: {error}", file=sys.stderr)
        raise SystemExit(1)
