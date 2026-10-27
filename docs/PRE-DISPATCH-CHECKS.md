# Pre-dispatch checks — the banked failures, as gates

Standing rule: *no failure goes to waste* (SOUL.md #9). The five failure
modes banked in `AGENTS.md` on 2026-10-09 and the dispatch-time family
(D1/K13/K14) banked 2026-10-13 each killed a run after dispatch.
This spec turns each banked catch into an executable check that refuses
**before** dispatch. The checks live in `scripts/harness/pre_dispatch_checks.py`
(stdlib only, read-only: the script never dispatches, commits, or pushes).

Run it on a workflow before dispatching:

```
python3 scripts/harness/pre_dispatch_checks.py \
    --workflow .github/workflows/<name>.yml \
    [--workflows .github/workflows/*.yml] \
    [--lakefile <dir>/lakefile.lean] \
    [--project <dir>] \
    [--vendor <dir> --root-module <Lib/Root.lean> --expected-count <N>]
```

Exit 0 = every applicable check passes. Exit 1 = **PRE-DISPATCH REFUSED**,
one line per failure naming the mode. A check whose inputs were not supplied
prints SKIP — never a silent pass.

## The modes

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

## Waivers — per-dispatch, reasoned, never silent (adopted 2026-10-27, Bitter Lesson Phase 1)

A finding can be waived for one dispatch with `--waive MODE=REASON`
(repeatable), e.g. `--waive FM7="target pre-created by the runner setup
step"`. The reason is required and must be non-empty; a malformed waiver
is a usage error (exit 2). A waived finding prints as `MODE WAIVED:
<finding> (waiver: <reason>)`, does not count toward refusal, and the
OK line counts the waivers by mode. A waiver that matches no finding
prints a NOTE. Waivers apply to the single invocation only; nothing is
persisted, and the default with no `--waive` is unchanged (fail-closed).
Waiver use is data: repeated waivers of the same mode are evidence that
the mode is miscalibrated for that workflow class, and they are counted
at the monthly hygiene review, where the mode is recalibrated or the
waivers stop.

Waivers can also be recorded ahead of time in a waivers file
(`--waivers-file PATH`): JSON lines, one record per line,
`{"fm": MODE, "reason": "...", "date": "YYYY-MM-DD", "workflow": NAME}`.
A record waives its mode for a dispatch only when it names one of the
workflows being checked (by the path as given, by basename, or `"*"`),
so a waiver recorded for one workflow can never silently waive a
finding in another. When `--waive` is used together with
`--waivers-file`, each CLI waiver is appended to the file as a record,
so all waiver use stays countable. An unparseable file, or a CLI
waiver that cannot be recorded, is a usage error (exit 2): a waiver
that leaves no record must not waive.

## FM6 — dispatch-time construct semantics unverified (D1/K13/K14 family)

Three sibling lessons banked 2026-10-13 each killed or nearly killed a run
after dispatch because a shell/action construct was never verified before
it: a dropped closing quote in a `run:` block (run #9 died in 7s); `..` in
an `upload-artifact` `path:` (rejected by the action at runtime); and
`cmd; code=$?` under `set -euo pipefail` (the shell exited at the command
itself and the verdict was lost). `--workflows <files...>` turns the whole
deploy-gate adversarial pass into one executable gate:
(a) every `run:` block (block scalars via indentation, single-line scalars
too) is extracted and `bash -n` syntax-checked;
(b) `..` in any `path:`/`working-directory:` value refuses;
(c) the `; <var>=$?` exit-capture pattern inside a run block refuses —
the exempt form is `cmd || code=$?` (full-line comments are ignored by the
heuristic; `bash -n` still checks them).
Signals: `K13 REFUSED: <file>:<line> run: block fails bash -n` /
`` `..` in a path:/working-directory: value `` /
`K14 REFUSED: <file>:<line> run: block captures an exit code with ; <var>=$?`.

## FM7 — probe measures a directory before the step that creates it

Banked 2026-10-27: eth-forge run #1 (40471027485) died in 4s on its first
dispatch. The Runner probe ran `df -h "$ETH_TARGET"`; `$ETH_TARGET` is
first created by `mkdir -p` in the *next* step (sparse clone). On a fresh
runner the directory does not exist, `df` exited 1, and because the probe
block ends with that pipeline, `pipefail` turned an informational command
into the step verdict despite `set +e`. Both earlier families missed it:
the file is syntactically valid (K13) and captures no exit code (K14).
`--workflows` refuses when:
(a) a `$VAR` passed to `df` has not been created by an earlier
`mkdir -p "$VAR"` in file order and the df pipeline is not guarded with
`|| true` / `|| echo`;
(b) a step whose name contains "probe" can gate the job — it must carry
`continue-on-error: true` or its run block must end with `exit 0`.
Signals: `FM7 REFUSED: <file>:<line> df on $<VAR> before any mkdir -p
creates it` / `step '<name>' is a probe (informational) but can gate
the job`. Scope note: tracking is in file order (steps run in written
order); only `df` arguments are tracked, not every filesystem read.

## Forge gate job — the dispatch-point catch (option A, adopted 2026-10-27)

The chained `dispatch_gate.sh` call is a convention: a caller can forget
it, and dispatches placed from the web UI never pass through it. Every
forge workflow authored after 2026-10-27 therefore carries its own gate
job, so the check runs at the exact SHA being dispatched, on every
dispatch route:

```yaml
jobs:
  gate:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: Pre-dispatch checks on this workflow
        run: python3 scripts/harness/pre_dispatch_checks.py --workflows .github/workflows/<this-forge>.yml

  forge:
    needs: gate
    runs-on: [self-hosted, desktop]
    # ... the forge steps, unchanged ...
```

Rules: the gate job hard-pins `ubuntu-latest` (it must not depend on
the runner the forge itself needs); **every** other job in the file
declares `needs: gate`, not just the forge job; the hand-chained
`dispatch_gate.sh` call stays as the pre-landing check. Known limit,
accepted for a sole-owner repo whose threat model is accidents, not
malice: the gate runs the checker from the same SHA it checks, so a
commit that weakened the checker itself would pass vacuously — landing
review is the catch for checker changes. The companion detection net is
the `workflow-lint` workflow (option B): the same checker over all
workflow files on every push and pull request, ubuntu-pinned,
always-reporting, path-aware inside the job. Addition-gate lines:
(1) replaces the hand-chained convention as the primary dispatch-point
catch for new forges; the convention itself stays as pre-landing check;
(2) scope = forge workflows authored after 2026-10-27 plus the one
workflow-lint workflow; eth-forge (dispatched 2026-10-27, run #2) is
not retrofitted mid-run; (3) review at the 2026-11-01 hygiene run.
3 AM question: neither piece runs on a schedule; the gate job runs only
inside a run someone dispatched, the lint job only on push/PR, and a
red lint is an ordinary CI failure on the commit that caused it.

## Self-test

Each check was proven against a fixture carrying its known-bad pattern
(all five refused loudly) and against clean inputs (the repo's own
`ab-fluid-euler-build.yml`, which passes its inputs via `env:`; a lakefile
with mathlib required last and a bare `lean_lib`). FM6's three sub-checks
were proven against one bad fixture each (unterminated quote in a `run:`
block; `..` in an `upload-artifact` `path:`; `python3 ...; code=$?` under
`set -euo pipefail`) — all refused — and against the repo's current
workflow files, which pass exit 0. (The full-line-comment carve-out in the
K14 heuristic was earned here: `ab-fluid-euler-build.yml` names the
forbidden pattern in prose inside a comment and was the fixture that
proved the heuristic needed it.) Re-run the fixtures before trusting a
change to the script. (The FM2 check earned this rule:
it passed its first bad fixture twice — a fixture bug, then a regex bug —
and was only trusted after it refused both variants.)
FM7 was proven the same way on 2026-10-27: the checker as it stood before
FM7 passed the buggy eth-forge workflow (the gap); with FM7 it refuses that
exact file twice (df use-before-create; probe can gate), passes the fixed
file and the full 14-workflow corpus, and synthetic variants behave as
designed (continue-on-error probe passes; df-guard alone still refuses on
the probe check; `${VAR}` mkdir/df forms pass; a one-line probe run
refuses twice). The fixed probe script was also run locally under
`bash -e -o pipefail` with the target absent: exit 0, df line printed.
