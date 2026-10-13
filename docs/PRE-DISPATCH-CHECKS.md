# Pre-dispatch checks — the five banked failures, as gates

Standing rule: *no failure goes to waste* (SOUL.md #9). The five failure
modes banked in `AGENTS.md` on 2026-10-09 each killed a run after dispatch.
This spec turns each banked catch into an executable check that refuses
**before** dispatch. The checks live in `scripts/harness/pre_dispatch_checks.py`
(stdlib only, read-only: the script never dispatches, commits, or pushes).

Run it on a workflow before dispatching:

```
python3 scripts/harness/pre_dispatch_checks.py \
    --workflow .github/workflows/<name>.yml \
    [--lakefile <dir>/lakefile.lean] \
    [--project <dir>] \
    [--vendor <dir> --root-module <Lib/Root.lean> --expected-count <N>]
```

Exit 0 = every applicable check passes. Exit 1 = **PRE-DISPATCH REFUSED**,
one line per failure naming the mode. A check whose inputs were not supplied
prints SKIP — never a silent pass.

## The five modes

**FM1 — Tar vendoring path bug** (vendored tree landed somewhere the build
never looked; a directory listing was mistaken for a vendored library).
Check: the vendored tree's root module file exists, and its `.lean` file
count equals the expected count. Signal: `FM1 REFUSED: root module <path>
missing from vendor tree` / `count <got> != expected <want>`.

**FM2 — Satellite version conflict** (dependency pins disagreed; mathlib
was required before a satellite that pinned a different mathlib).
Check: in the lakefile, `require mathlib` is the LAST `require`; no package
is pinned at two different revisions across lakefile + manifest. Signal:
`FM2 REFUSED: require mathlib is not last` / `package <p> pins different
versions: <a> vs <b>`.

**FM3 — Workflow inputs substituted into shell unquoted** (an input value
reached a `run:` block as raw text; metacharacters in it became shell).
Check: every `${{ inputs.* }}` in the workflow is either inside an `env:`
mapping (values are never re-parsed by the shell) or in quoted-var-first
form `NAME="${{ inputs.x }}"`. Any other occurrence refuses. Signal:
`FM3 REFUSED: <file>:<line> inputs.* reaches a run block unquoted`.

**FM4 — Vendored subtree missing a cross-directory import** (the tree
looked complete; one module imported a sibling that was never vendored).
Check: import closure — every `import A.B.C` in the project whose top
segment is one of the project's own libraries resolves to a file in the
tree. Signal: `FM4 REFUSED: unresolved import <A.B.C> in <file>`.

**FM5 — `lean_lib` with `roots` but no `globs`** (Lake silently scheduled
only the root modules; the build "succeeded" past thousands of unbuilt
dependencies until an olean lookup failed). Check: no `lean_lib` block in
the lakefile declares `roots` without a covering `globs`. Signal:
`FM5 REFUSED: lean_lib <Name> restricts roots without globs`.

## Self-test

Each check was proven against a fixture carrying its known-bad pattern
(all five refused loudly) and against clean inputs (the repo's own
`ab-fluid-euler-build.yml`, which passes its inputs via `env:`; a lakefile
with mathlib required last and a bare `lean_lib`). Re-run the fixtures
before trusting a change to the script. (The FM2 check earned this rule:
it passed its first bad fixture twice — a fixture bug, then a regex bug —
and was only trusted after it refused both variants.)
