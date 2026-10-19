# Inferred mpvacious contribution style

This is an informal guide inferred from the current mpvacious codebase and the
maintainer follow-up commits in PRs
[#173](https://github.com/Ajatt-Tools/mpvacious/pull/173),
[#175](https://github.com/Ajatt-Tools/mpvacious/pull/175),
[#176](https://github.com/Ajatt-Tools/mpvacious/pull/176),
[#178](https://github.com/Ajatt-Tools/mpvacious/pull/178), and
[#179](https://github.com/Ajatt-Tools/mpvacious/pull/179). It is not an
official Ajatt-Tools style guide.

The central design rule appears to be:

> Put behavior on the domain object or shared module that owns it, keep the
> caller thin, cover boundary cases, and avoid solving only the example that
> exposed the bug.

## Architecture

### Put behavior on the owning domain object

Prefer domain objects over passing related primitive values. For example:

- pass a `Subtitle` time window instead of separate start and end values;
- return a combined `Subtitle` instead of parallel text and timing values;
- put timing predicates such as `overlaps_in_time()` on `Subtitle`;
- put subtitle-line accumulation and deduplication in a collector module.

Before adding a function, ask:

- Which object or module owns this behavior?
- Am I passing values that should form one domain object?
- Is the transformation independent enough to be reused?

### Handle symmetric paths consistently

Check both sides of relevant pairs:

- primary and secondary subtitles;
- current subtitles and selected subtitle history;
- quick cards and regular cards;
- internal representation and OSD presentation;
- supported operating systems, when relevant.

If behavior intentionally differs, explain why.

### Reuse or extend shared helpers

Transformations independent of Anki, mpv state, or a particular UI generally
belong in `helpers.lua`. Existing examples include:

- `normalize_subtitle_text`;
- `normalize_newlines` and `split_lines`;
- `str_to_lines`, `str_wrap`, and `str_limit_width`;
- `limit_lines` and `is_cjk_heuristic`;
- integer-list slicing and list comparison.

Search for an existing helper before introducing direct one-off `gsub`, slicing,
newline-normalization, or display-width logic.

### Separate transformation from presentation

Keep UI callers thin. A typical OSD pipeline is:

```text
normalize or flatten text
-> calculate display width
-> split into lines
-> limit the number of lines
-> join using ASS \N
-> render
```

Pure text logic belongs in helpers, subtitle collection belongs under
`subtitles/`, configuration belongs under `config/`, and `main.lua` should
primarily coordinate and render.

### Use precise semantic names

Names should identify the actual unit, boundary rule, and result:

- `n_subs`, not `n_lines`, when counting subtitle cues;
- `collect_n_subs`, not `get_n_text`, when returning a collected object;
- `window`, not separate start/end primitives;
- separate `overlaps_in_time` from `overlaps_or_touches_in_time`;
- distinguish normalized, flattened, wrapped, and truncated text.

### Document invariants

Comments should explain constraints that must remain true, such as:

- why touching events differ from overlapping events;
- why only the last subtitle may be expanded safely;
- why a copy is returned instead of internal mutable state;
- why secondary subtitles must align by time rather than line count.

Avoid comments that only restate the following line of code.

## Testing

Tests live beside the implementation. A testable module exports `run_tests()`;
`tests/run.lua` should only load modules and call that function.

Prefer small named tests and table-driven cases. For every positive case, add a
similar case where the behavior must not apply. Common boundaries include:

- adjacent repetition versus repetition after a real gap;
- overlapping versus touching time ranges;
- equivalent punctuation versus genuinely different punctuation;
- empty strings and tables;
- leading, trailing, repeated, and full-width whitespace;
- LF, CRLF, CR, blank lines, and trailing newlines;
- ASCII, Cyrillic, and CJK display widths;
- exact limits, one below, and one above;
- public return types and timing invariants, not only rendered text.

Run both test commands when the interpreters are available:

```sh
lua tests/run.lua
luajit tests/run.lua
```

The repository asks contributors to use an automatic formatter but does not pin
a formatter or configuration. Match the surrounding file and avoid unrelated
formatting changes; ask the maintainer which formatter they use if necessary.

## Pull request hygiene

1. Open the PR as a draft before pushing unfinished work.
2. Keep one concern per PR; move unrelated behavior into another PR.
3. Rebase onto current `master` before requesting review.
4. Squash exploratory commits into a clean logical commit when requested.
5. Include regression tests and manual mpv verification.
6. Use project terminology and avoid references the project explicitly rejects.
7. Describe the architecture, not only the visible result.
8. If the goal is to learn from review, ask the maintainer not to push refactors
   directly before giving you an opportunity to implement them.

A suitable sentence is:

> I would like to implement requested refactors myself, so please leave review
> comments before pushing changes to the branch.

## Pre-PR checklist

- [ ] The bug or feature is stated as an observable behavior.
- [ ] The invariant is explicit.
- [ ] The owning module or domain type is identified.
- [ ] Existing helpers were reviewed before adding new ones.
- [ ] Primary/secondary and other symmetric paths were considered.
- [ ] Return types preserve related data together.
- [ ] Names describe units and boundary semantics accurately.
- [ ] Tests are colocated in the affected module.
- [ ] Positive, negative, boundary, and Unicode/newline cases are covered.
- [ ] `lua tests/run.lua` passes when Lua is available.
- [ ] `luajit tests/run.lua` passes when LuaJIT is available.
- [ ] The change was manually exercised in mpv.
- [ ] The branch is rebased and its history is clean.
- [ ] The diff contains no unrelated formatting or behavior.

## Pull request template

```markdown
## Problem

Describe the incorrect observable behavior.

## Invariant

State what must always remain true.

## Design

- Owning module or type:
- Shared helpers reused or introduced:
- Primary and secondary behavior:
- Return types and boundary semantics:

## Tests

- Expected case:
- Similar case that must remain unchanged:
- Empty and boundary cases:
- Unicode, newline, and platform cases:

## Manual verification

Describe the exact mpv workflow tested.
```

## Lessons from the five PRs

- **#173:** Start with a subtitle collector, put timing operations on
  `Subtitle`, return a combined `Subtitle`, support primary and secondary paths,
  and test non-adjacent repetition.
- **#175:** Put subtitle normalization in shared helpers and test both equivalent
  representations and distinct punctuation.
- **#176 and #178:** Separate newline normalization, line splitting,
  display-width calculation, wrapping, and line limiting; cover multiple writing
  systems and whitespace boundaries.
- **#179:** Resolve presentation semantics before implementation. Flattening only
  primary subtitles while keeping secondary cues separate created an inconsistent
  UI and led to a behavioral replacement rather than a simple refactor.

Even with this approach, zero maintainer changes cannot be guaranteed. The
maintainer frequently refactors merged code, including their own work. The goal
is to make the initial design fit the repository closely enough that remaining
changes are small, reviewable refinements.
