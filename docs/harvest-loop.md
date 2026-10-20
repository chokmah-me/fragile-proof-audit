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

### Effectivity screen for QRH-instantiated claims (triage, adopted 2026-10-20)

Origin: check A6 of the Frei–Sofos–Widmer audit
(`docs/audits/frei-sofos-widmer.md`), generalized at the user's word
the same day. Applies to any harvest claim whose unconditionality is
instantiated by citing a zero-free region QRH(δ) (no zeros of the
relevant Dedekind zeta functions with Re s > 1 − δ; note the
parametrization: the region Re s > 31/32 is δ = 1/32) and whose proof
consumes that region through an effective Chebotarev or
prime-splitting step with a threshold of the standard shape
x ≥ c(δ)·(log Δ)^(a/δ)·(log log Δ)^(b/δ), while the consuming
argument needs primes at norm ≤ Δ^η.

Run `scripts/harvest-loop/qrh_effectivity_screen.py --delta <δ>
--eta <η>` (defaults a = 1, b = 2, c = 1; set a and b from the
claim's own corollary when they differ). It returns the crossover:
the discriminant digit count from which the threshold first drops
below Δ^η, classified EFFECTIVE (≤ 100 digits), LARGE-ONLY
(≤ 10,000 digits), or NIL (> 10,000 digits). c = 1 is a best case
most papers do not supply (FSW's c(δ) is pure existence), so every
crossover is a lower bound on the true one. `--fsw-grid` replays the
validation: the script reproduces the FSW audit's 16-cell grid
(395,225 at (ℓ,d) = (2,3) up to 2,757,773 at (5,6)) to within 0.5
log₁₀ units, and discriminates on controls at η = 1/8
(δ = 1/2 → 56 digits, δ = 1/12 → 451, δ = 1/32 → 1,359,
δ = 1/6000 → 395,225, δ = 10⁻⁶ → 86,912,155).

What the screen is and is not: it measures the **effective content
of the instantiation**, not the claim's truth; an asymptotic bound
can be true with an astronomically large implied constant, and the
exceptional-set absorption that keeps such corollaries true is
standard. A NIL or LARGE-ONLY flag is recorded on the claim's recon
card as an effectivity qualification (it caps what "unconditional"
can mean in practice, and it decided V-B's grade in the FSW audit);
it is not a verdict and never a kill by itself. If the claim's
consumption does not go through a threshold of this shape, the
screen does not apply; say so on the card rather than forcing the
fit.

### Statement-fidelity checklist (four modes)

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
party's — answers these four modes explicitly. Pure computational-replay
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
- **M4 — Fine print** (Murray & van Oorschot, "BP: Formal Proofs, the Fine
  Print and Side Effects," IEEE SecDev 2018, DOI 10.1109/SecDev.2018.00009;
  adopted 2026-10-13, prospective only, no backfill). Inventory every
  load-bearing assumption not in the theorem statement: model/definitional
  choices, machine model, trusted base, exclusions. Dangling check: is the
  conjunction of those assumptions satisfiable by an instance of the source
  claim? Residual line per assumption: if it fails — survives / weakens
  to ___ / evaporates, and which downstream claims inherit it. Tag each
  proof-enabling change: source-faithful / convenience-only /
  risk-inducing.

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

### Companion prompts (adopted 2026-10-20)

Two Stunspot "Prompt of the Day" prompts are paired with this loop
(prospective only, no backfill; texts in the local Stunspot library,
`local-stunspot-potd`):

- **Grandmaster's Methods** (2025-08-16) runs at the recon step: reconstruct
  the author's actual working method from primary sources (the paper, the
  artifact, process evidence), weighted unvarnished-over-polished and
  high-stakes-over-promotional, with skeptic filters (survivorship,
  success-myth reconstruction, ghosted authorship) run continuously.
- **DEEPEN** (2025-10-10) runs as a pre-verdict challenge pass alongside the
  M1–M4 checklist: a reflect-and-challenge cascade over assumptions,
  theoretical basis, drawbacks, failure contexts, and alternatives, applied
  to the draft verdict before it is recorded.

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
