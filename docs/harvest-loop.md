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
   table for the target pick. Examples: [`docs/audits/harvest-2026-09-24/`](audits/harvest-2026-09-24/),
   [`docs/audits/harvest-2026-09-28/`](audits/harvest-2026-09-28/).
4. **Target pick (human).** Reply on the issue. On pick: pin inputs
   (PDF + repo SHA under `incoming/`), write the audit note, then run gates.

### Lean-formalization recon (post-pick, manual or agent)

Clones and builds wait for the target pick — the loop above never does
either. Once a target with a Lean formalization is picked, run these two
autoformalization-tool recon steps before deep gates:

1. **Mathlib coverage probe (LeanExplore).** Take the probe query from the
   claim's recon card and semantic-search Mathlib:
   `leanexplore search "<query>" --package Mathlib` (remote API is public and
   keyless — LeanExplore retired API keys; or the website).
   If the formalized theorems, or their key lemmas, already exist in
   Mathlib, that reframes the novelty claim and can expose a
   `formal_subset_of_claim` gap. Feeds the statement-fidelity checklist below.
2. **Trace extraction (LeanDojo).** For the pinned repo, extract tactic
   traces, syntax trees, and proof states. Use them in the
   statement-fidelity checklist (M1: does the formal theorem say what the
   paper's theorem says?) and in the axiom audit (what do the proofs
   actually depend on?).

### Statement-fidelity checklist (three modes)

Adopted 2026-10-08 from arXiv:2610.08144 (Bastounis–Circelli–Hansen,
"Navier-Stokes lost in translation"): Lean acceptance certifies the formal
proposition and the formal derivation supplied for it — not that the
proposition is the one the source text states, that the derivation follows
the source argument, or that the source argument is correct. A compiling
proof can coexist with a wrong NL proof, prove a different theorem by a
different method, or prove less than the NL text claims. Compilation is
therefore never the acceptance criterion for "the source proof is
correct"; no fixed finite procedure can certify faithful translation (their
SCI = ∞ result), so the checks below stay human-judgment, fail-closed.

Every audit note that evaluates a Lean formalization — ours or a third
party's — answers these three modes explicitly. Pure computational-replay
gates (types A–F) that re-derive the quantity from scratch have no
formalization under review; the note says so in one line.

- **M1 — Statement correspondence.** Does the formalized theorem state what
  the source's theorem states? Compare quantifiers, side conditions,
  derivative counts / integrability exponents, domains, norms,
  dependencies, and implicit existence conditions. Record any weakening,
  strengthening, or change — and whether downstream uses depend on the
  changed part. (Their Navier–Stokes case: m+4 → m+5 derivative loss and an
  added localized gradient term made the Lean estimate a different, weaker
  proposition.)
- **M2 — Argument correspondence.** Does the formal derivation follow the
  source's argument, or does it prove the formalized statement by a
  different route — or repair a broken one? Label it: *faithful
  formalization of the source proof* vs *independent proof of the
  formalized statement*. Both are legitimate; conflating them is not.
- **M3 — Credit honesty.** Does the claimed verification credit match what
  is actually verified? Disclose sorrys, axioms, divergences, and scope
  limits; no over-claiming. (This is the existing Type-G
  verification-credit scan, e.g. the NLA notes.)

### Receipt requirement (adopted 2026-10-09)

"Trust, but replay" without the replay artifact is just trust. Every audit
note therefore carries a **Receipt** field pointing at machine evidence —
generated as a matter of course, not as an optional extra:

- **Lean formalization audits** end with an independent forge build and an
  axiom receipt: the pinned inputs (repo revision, toolchain, dependency
  pins), where it built (a machine separate from the author's), and the
  exact `#print axioms` output for the headline theorem. "It compiled on my
  machine" is not a receipt. (Pattern and catalog: `docs/family-receipts/`.)
- **Computational-replay gates (types A–F)** already produce their receipt in
  the gate script plus its output; the discipline is that the evidence hash
  is part of the verdict record every time, not just when convenient.
- A receipt that does not exist is reported as such — a missing receipt is a
  GAP in the note, never silently omitted.

## Boundaries

- The loop never clones code, never runs builds, never downloads artifacts.
  Running anything waits for the target pick.
- The loop never touches the verdict lock.
- Every audit note pins its agent harness (model + harness + version + run
  date) in the header block, the same way it pins the Lean toolchain —
  harness choice moves results more than model choice.
- The weekly scheduled run with no new harvest does a health re-check of
  the latest harvest's identifiers and reports only on drift (repo gone
  private, new HEAD, paper v2/withdrawn).

## Local testing

`python3 scripts/harvest-loop/recon.py [YYYY-MM-DD] [--health-check]`
(stdlib only; needs network for the arXiv/GitHub APIs).
