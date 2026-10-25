# Audit note — ReplayGate smoke test (synthetic, not a real audit)

**Claim artifact:** none. This note exists only to exercise the
ReplayGate audit-note check end to end on a live pull request.
**Harvest item:** ReplayGate M2 live smoke, 2026-10-25.
**Campaign objects:** none.
**Pinned sources:** M2 deploy bundle sha256 `b9a9e8a44e1fe1e8e14f9f1bf1f7370595f0148289610abc7a7344ae82d4bff1`
(replaygate-m2-bundle.js, built from replaygate m2/core @ 93b332f).

**Harness pin** (`scripts/harness_pin.py`,
2026-10-25T20:22:00Z): agent Muse (Meta), model `Muse Spark
1.3`; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

**Scope of this audit:** none; synthetic smoke content. The four
sections below are present so the contract linter sees a complete
note shape.

## M1 — Statement fidelity

Present for the smoke. No statement is audited.

## M2 — Argument check

Present for the smoke. No argument is checked.

## M3 — Credit honesty

Present for the smoke. No credit is claimed beyond this line:
the note is synthetic and says so in its title.

## M4 — Fine-print assumption inventory

Present for the smoke. The one assumption: a complete note
shape produces a success check.

## Verdict lock

**Verdict: PASS.** The smoke note is complete in shape; if this
check reads success with this verdict restated, the live
pipeline works end to end.
