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
   - for claims with a Lean formalization, writes a **formalization coverage
     inventory** (file count, lakefile, toolchain pin, author-declared
     verification such as Palomar registration or comparator replay — recorded
     as *declarations*, never credited) plus a ready-to-run **LeanExplore
     probe query** for the post-pick Mathlib coverage check,
   - scores fragility from the harvest's declared signals plus computed
     adjustments (fixed rubric in `incoming/harvests/README.md`),
   - suggests attack lanes from the A–G taxonomy (heuristic; confirmed on pick).
3. **Output.** `docs/audits/harvest-<date>/recon.md` (verification ledger,
   ranked queue, per-claim cards), `ledger.json` (machine-readable checks),
   committed to main; a `harvest`-labeled GitHub issue carries the ranked
   table for the target pick.
4. **Target pick (human).** Reply on the issue. On pick: pin inputs
   (PDF + repo SHA under `incoming/`), write the audit note, then run gates.

### Lean-formalization recon (post-pick, manual or agent)

Clones and builds wait for the target pick — the loop above never does
either. Once a target with a Lean formalization is picked, run these two
autoformalization-tool recon steps before deep gates:

1. **Mathlib coverage probe (LeanExplore).** Take the probe query from the
   claim's recon card and semantic-search Mathlib:
   `leanexplore search "<query>" --package Mathlib` (free API key from
   leanexplore.com, or the website — no signup needed for basic search).
   If the formalized theorems, or their key lemmas, already exist in
   Mathlib, that reframes the novelty claim and can expose a
   `formal_subset_of_claim` gap. Feeds the A–D statement-faithfulness checks.
2. **Trace extraction (LeanDojo).** For the pinned repo, extract tactic
   traces, syntax trees, and proof states. Use them in the statement-
   faithfulness checks (does the formal theorem say what the paper's
   theorem says?) and in the axiom audit (what do the proofs actually
   depend on?).

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
