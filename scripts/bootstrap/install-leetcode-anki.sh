#!/usr/bin/env bash

set -euo pipefail

LEETCODE_ANKI_COMMIT="aeabd4dd10c5163ef84f8390c4f8a5c8812a9ceb"
LEETCODE_ANKI_SHA256="${LEETCODE_ANKI_SHA256:-c3f83153bea080c75230b825d741d8ad00aae6092100a04fbbebf37d60d96e9b}"
LEETCODE_ANKI_DECK_URL="${LEETCODE_ANKI_DECK_URL:-https://raw.githubusercontent.com/VarunVankineni/leetcode-anki-apkg/${LEETCODE_ANKI_COMMIT}/LeetcodeSuperSet600.apkg}"
LEETCODE_ANKI_EXPECTED_NOTES=574
ANKI_CONNECT_URL="${ANKI_CONNECT_URL:-http://127.0.0.1:8765}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
install_dir="${LEETCODE_ANKI_INSTALL_DIR:-$XDG_DATA_HOME/leetcode-anki}"
deck_path="$install_dir/LeetcodeSuperSet600.apkg"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
css_path="${LEETCODE_ANKI_CSS:-$repo_root/configs/anki/leetcode.css}"
import_deck=false

usage() {
	cat <<'EOF'
Usage: install-leetcode-anki.sh [--import]

Without arguments, install the pinned LeetCode Superset deck package.
With --import, also import it through a running AnkiConnect instance unless
the LeetCode Anki deck already contains notes.
EOF
}

case "${1:-}" in
'') ;;
--import) import_deck=true ;;
-h | --help)
	usage
	exit 0
	;;
*)
	usage >&2
	exit 2
	;;
esac

if [ "$#" -gt 1 ]; then
	usage >&2
	exit 2
fi

deck_is_current() {
	[ -f "$deck_path" ] &&
		printf '%s  %s\n' "$LEETCODE_ANKI_SHA256" "$deck_path" |
		sha256sum --check --status
}

mkdir -p "$install_dir"

if deck_is_current; then
	echo "LeetCode Superset deck already installed."
else
	staging_dir="$(mktemp -d)"
	trap 'rm -rf "$staging_dir"' EXIT
	staged_deck="$staging_dir/LeetcodeSuperSet600.apkg"

	curl --fail --silent --show-error --location \
		--output "$staged_deck" "$LEETCODE_ANKI_DECK_URL"
	printf '%s  %s\n' "$LEETCODE_ANKI_SHA256" "$staged_deck" |
		sha256sum --check --status
	unzip -tqq "$staged_deck"
	if ! unzip -Z1 "$staged_deck" | grep -Eq '^collection\.anki2[1b]?$'; then
		echo "The LeetCode deck archive does not contain an Anki collection." >&2
		exit 1
	fi

	mv "$staged_deck" "$deck_path"
	rm -rf "$staging_dir"
	trap - EXIT
	echo "Installed the pinned LeetCode Superset deck at $deck_path."
fi

if ! $import_deck; then
	exit 0
fi

anki_request() {
	local payload="$1"
	local response

	response="$(curl --fail --silent --show-error --max-time 120 \
		-H 'Content-Type: application/json' \
		-X POST -d "$payload" "$ANKI_CONNECT_URL")" || {
		echo "Unable to reach AnkiConnect. Start Anki and rerun with --import." >&2
		exit 1
	}
	if ! jq -e '.error == null and has("result")' >/dev/null <<<"$response"; then
		printf 'AnkiConnect failed: %s\n' \
			"$(jq -r '.error // "invalid response"' <<<"$response")" >&2
		exit 1
	fi
	jq -c '.result' <<<"$response"
}

find_payload="$(jq -cn '{
	action: "findNotes",
	version: 6,
	params: {query: "note:\"LeetCode Model\""}
}')"
existing_notes="$(anki_request "$find_payload")"
existing_count="$(jq 'length' <<<"$existing_notes")"

if [ "$existing_count" -gt 0 ]; then
	printf 'LeetCode Model already contains %s notes; skipping import.\n' \
		"$existing_count"
else
	import_payload="$(jq -cn --arg path "$deck_path" '{
		action: "importPackage",
		version: 6,
		params: {path: $path}
	}')"
	anki_request "$import_payload" >/dev/null

	imported_notes="$(anki_request "$find_payload")"
	imported_count="$(jq 'length' <<<"$imported_notes")"
	if [ "$imported_count" -ne "$LEETCODE_ANKI_EXPECTED_NOTES" ]; then
		printf 'Unexpected LeetCode note count after import: %s (expected %s).\n' \
			"$imported_count" "$LEETCODE_ANKI_EXPECTED_NOTES" >&2
		exit 1
	fi
	printf 'Imported %s notes into LeetCode Anki.\n' "$imported_count"
fi

if [ ! -r "$css_path" ]; then
	printf 'LeetCode card styling is missing: %s\n' "$css_path" >&2
	exit 1
fi
styling_payload="$(jq -cn --arg css "$(cat "$css_path")" '{
	action: "updateModelStyling",
	version: 6,
	params: {model: {name: "LeetCode Model", css: $css}}
}')"
anki_request "$styling_payload" >/dev/null

style_query="$(jq -cn '{
	action: "modelStyling",
	version: 6,
	params: {modelName: "LeetCode Model"}
}')"
installed_css="$(anki_request "$style_query" | jq -r '.css')"
if [ "$installed_css" != "$(cat "$css_path")" ]; then
	echo "LeetCode card styling did not apply cleanly." >&2
	exit 1
fi
echo "LeetCode Anki card styling updated."
