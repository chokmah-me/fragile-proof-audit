# Harvest loop

Weekly pipeline: fresh-claim harvest in → recon analysis out → target pick.

## Stages

1. **Harvest.** Fresh claims land as `incoming/harvests/<YYYY-MM-DD>.md`
   (format: `incoming/harvests/README.md`). Produced by the weekly
   harvest scan, deep-research batches, or pasted in by hand.
2. **Recon (automatic).** The `harvest-loop` GitHub Action fires on push of a
   harvest file, weekly on Mondays (~09:17 ET), or manually. It runs
   `scripts/harvest-loop/recon.py`, which for each claim:
   - verifies the paper identifier against the arXiv API (title/author/date),
   - verifies the code repo against the GitHub API (public, HEAD pin,
     Lean-file count, lakefile, `lean-toolchain` pin),
   - scores fragility from the harvest's declared signals plus computed
     adjustments (fixed rubric in `incoming/harvests/README.md`),
   - suggests attack lanes from the A–G taxonomy (heuristic; confirmed on pick).
3. **Output.** `docs/audits/harvest-<date>/recon.md` (verification ledger,
   ranked queue, per-claim cards), `ledger.json` (machine-readable checks),
   committed to main; a `harvest`-labeled GitHub issue carries the ranked
   table for the target pick.
4. **Target pick (human).** Reply on the issue. On pick: pin inputs
   (PDF + repo SHA under `incoming/`), write the audit note, then run gates.

## Boundaries

- The loop never clones code, never runs builds, never downloads artifacts.
  Running anything waits for the target pick.
- The loop never touches the verdict lock.
- The weekly scheduled run with no new harvest does a health re-check of
  the latest harvest's identifiers and reports only on drift (repo gone
  private, new HEAD, paper v2/withdrawn).

## Local testing

`python3 scripts/harvest-loop/recon.py [YYYY-MM-DD] [--health-check]`
(stdlib only; needs network for the arXiv/GitHub APIs).
