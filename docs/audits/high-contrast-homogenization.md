# Audit note — high-contrast homogenization in Lean 4 (Armstrong–Kuusi–Loher) (2026-10-02)

**Claim artifact:** Scott Armstrong, Tuomo Kuusi, Amélie Loher,
*Homogenization at a polynomial scale in high contrast*, arXiv:2609.27647v1
(23 September 2026), §1.4 points to the formalization. The repo claims to
formalize Theorems A–D: (A) polynomial entry into the small-contrast regime at
length polynomial in the aspect ratio; (B) algebraic convergence of the annealed
coarse-grained matrices; (C) quantitative Dirichlet homogenization under uniform
ellipticity; (D) corrector / Liouville / large-scale-regularity estimates above
one random radius.

**Campaign objects:** `results/high_contrast_homogenization_gate_meta.json`;
`scripts/gates/high_contrast_homogenization_scan.py` (the sorry/admit/axiom
source scanner, self-tested with planted fixtures).

**Source pins:**
- Repo `https://github.com/scottnarmstrong/HighContrastHomogenization/`, HEAD
  `7a13dbcd8d6609264a713373f5c69ceeac870472` ("Clarify project description",
  2026-09-24 21:04:53 UTC), public, Apache-2.0.
- Toolchain pins: `lean-toolchain` = `leanprover/lean4:v4.35.0-rc2`;
  `lake-manifest.json` pins mathlib `065356127b1d`, CoarseGraining `c7ddd76c08ad`
  (+ plausible, LeanSearchClient, importGraph, proofwidgets, aesop, Qq,
  batteries, Cli).
- Paper PDF (arXiv:2609.27647), SHA-256
  `ae50d3b56282e05a79d9206ff0b2e6dc9947dbea4263ff9c138e68620cb72ea1`
  (1,036,856 bytes, fetched 2026-10-02).

## Verdict: PASS (verify/audit — type-G formalization pass)

## What was run

| Lane | Result |
|---|---|
| Scale check | **1,579** `.lean` files, **380,773** lines — matches the claimed ~1,561 modules / ~380k lines |
| Exhaustive sorry/admit/axiom source scan (all 1,579 files) | **4** code `sorry` hits, all in `HCPolyAudit/*/Challenge.lean` — exactly the one intentional statement-level `sorry` per challenge the README declares (each filled by its `Solution.lean`, which contains no `sorry`); **0** `admit`, **0** `axiom` declarations, **0** `sorryAx`, 10 comment-only mentions |
| Import hygiene | distinct roots: `HCPoly` (own), `Homogenization` (CoarseGraining dep), `Mathlib`, `HCPolyAudit` — nothing exotic; no `unsafe`/`implemented_by`/`extern` escape hatches |
| Upstream CI `build.yml` on the exact audited SHA | run **36059134837**, **success**, 2026-09-24: full warning-free `lake build` (fails on any warning or `declaration uses 'sorry'`), plus the `HCPoly/Meta/AxiomsAudit.lean` gate — all 5 headline theorems report exactly `[propext, Classical.choice, Quot.sound]` |
| Comparator audit on the exact audited SHA | run **36059134677**, **success**, 2026-09-24: `leanprover/comparator` @ `32bd61d` checks each Mathlib-only restatement of A–D (`HCPolyAudit/*/Challenge` + `Solution`), verified by **two independent kernels** — Lean kernel replay and nanoda @ `6ae1f0c` (nanoda enabled CI-only) |
| Theorem-statement faithfulness vs the paper | A **faithful**; B **faithful**; C **faithful with declared gap**; D **faithful with declared gaps** (details below) |
| Teeth control | planted `sorry` + planted `axiom myFakeAxiom : True` in scratch copies — the scanner **fires on both** |

## Statement faithfulness (Lean `HCPoly/MainResults.lean` vs paper §1)

- **Theorem A** (`HCPoly.polynomial_entry`): faithful. Paper: ∀σ∈(0,1] ∃C(σ,d,γ),
  Θ_m ≤ 1+σ for m ≥ C·log₃(2+ΠK), length 3^m ≤ 3(2+ΠK)^C, no uniformity as γ↑1.
  Lean: same with the entry generation as ⌈C·log₃(2+ΠK)⌉ over m : ℤ (integer
  generations are the formal rendering) and the polynomial length bound exported
  as a conjunct; the γ↑1 non-uniformity is in the docstring.
- **Theorem B** (`HCPoly.algebraic_convergence`): faithful. Paper's
  0 ≤ A(□_{m₀+j}) − A ≤ 6·3^{−κj}A is Lean's
  `Abar ≤_L annealedBlock … ≤_L (1 + 6·3^{−κj}) • Abar`; Schur conditions
  s̄_* = s̄ > 0, k̄ skew; m₀ ≤ ⌈C·log₃(2+ΠK)⌉. Exact match.
- **Theorem C** (`HCPoly.uniform_homogenization`): faithful **with the declared
  gap**. The paper's L² Dirichlet estimate with forcing term `f` and tolerance
  `δ` (`e.uniform.dirichlet`) is **not** formalized — the Lean theorem gives the
  homogeneous negative-Sobolev estimate on adapted cells (Theorem D's form),
  and `δ` is absent. The README, the theorem docstring, **and the paper itself
  (§1.4: "The formal Dirichlet estimate corresponding to Theorem C treats
  f = 0")** all say exactly this. Extra corrector/Liouville/approximation
  conclusions (from the Theorem D specialization) are declared in the docstring.
- **Theorem D** (`HCPoly.polynomial_homogenization`): faithful **with declared
  gaps**, every one documented in the docstring/README/CORRESPONDENCE.md:
  Dirichlet estimate on adapted cells (triadic-cube images under s̄^{1/2}),
  not arbitrary bounded Lipschitz domains (paper §1.4 corroborates); `X ≥ 1`
  rather than `X ≥ max{1,S}`; homogenized matrix existential, not identified
  with Theorem B's limit; skew-centered fluxes; `ℝ≥0∞`-valued norms; constants
  asserted positive as a normalization; measurability carried in the membership
  classes. Tail shape `exp(−c·t^{d−2γ}) + Ψ(c_src·t)^{−1}` and the polynomial
  length `(2+ΠK)^C` match the paper's (1.21).
- `HCPoly.quenched_convergence` is an extra (the `ss.random.dirichlet`
  estimate), declared as not one of the introduction's theorems.

**Anti-paraphrase-drift mechanism (verified live):** each of A–D is restated
using only Mathlib definitions in `HCPolyAudit/*/Challenge.lean`; the
`Solution.lean` proves the restatement from the library; the comparator checks
the solution's full dependency closure matches the challenge's, permits only
the three standard axioms, and replays under two kernels. This is the
strongest statement-fidelity check seen in this campaign.

## Teeth control

The scanner is not a rubber stamp: on scratch copies with a planted
`theorem planted_weakened : (1:ℝ) = 2 := by sorry` and a planted
`axiom myFakeAxiom : True`, it reported both (plus the declared challenge
sorry). A weakened/false theorem statement smuggled into the tree would be
caught by the same pass that certified the real tree.

## Honest scope

- **No local kernel check was performed** — infeasible here, stated plainly:
  the pinned toolchain v4.35.0-rc2 is not installed on this VM, mathlib
  publishes no prebuilt oleans for the pinned rc (releases API: 0 assets), and
  the ~1,561-module dependency closure cannot build inside the VM's ~2h reboot
  windows. Kernel trust rests on upstream CI: a full warning-free `lake build`
  plus the `#print axioms` gate **on the exact audited SHA**, and the
  dual-kernel (Lean + nanoda) comparator replay of the Mathlib-only
  restatements of A–D.
- CI runs on the author's self-hosted runner; the evidence is only as
  trustworthy as that runner. The run SHAs match the audited HEAD exactly.
- Statement faithfulness is a human comparison of Lean vs paper statements
  (verbatim, above); the `HCPoly/Consistency/` modules check the definitions'
  intended meaning, and the comparator restatements give independent
  inspectability — but no machine checks "the Lean statement means the paper's
  statement."
- One comparator failure exists in history (2026-09-14, `f163e9eeed0b`),
  superseded by green runs the same day; all 16 recorded runs on/after
  2026-09-11 are otherwise green.
- This audit does not re-verify the mathematics of the paper, only that the
  formalization exists, builds, uses no extra axioms, and states what it claims.

## Verdict lock

Untouched (25 gates: 17 BREAK / 8 PASS). This is a standalone verify/audit PASS
— the last of the 9-target harvest queue, selected by the user 2026-10-02.
