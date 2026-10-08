# Audit note — simplex Gaussian maxima, Lean formalization (2026-09-28)

**Claim artifact:** Abhijeet Mulgund, *Stochastic Domination of Gaussian
Maxima by the Regular Simplex*, arXiv:2609.28452 (2026). Theorem 1.1:
for every n≥2, every correlation matrix G, every t∈ℝ,
F_G(t) ≥ D_n(t) (eq. 1.4); for each fixed t>0,
F_G(t) = D_n(t) ⟺ G = Δ_n (eq. 1.5), where Δ_n = (nI−J)/(n−1).
**Harvest item:** `simplex-gaussian-maxima-lean` (recon flag
`formal_subset_of_claim`).
**Campaign objects:** `results/simplex_gaussian_maxima_gate_meta.json`;
working copies at `~/workspace/simplex-audit/` (API tarball of the repo at
the certified commit, not committed).

**Repo pin:** https://github.com/abhmul/full-simplex-conjecture-lean @
`1915b3485c8d61e531374261e7844010b7538eb9` (fetched 2026-09-28 via API
tarball; SSH clone unavailable — egress proxy resets the tunnel).

**Dependency pins (all verified in place):** Lean
`leanprover/lean4:v4.31.0` (installed 2026-09-28 via elan),
mathlib `fabf563a7c95a166b8d7b6efca11c8b4dc9d911f`,
weak-simplex-conjecture-lean `a204c53cae45652d12524132dbb9a2e0ffe8cf78`,
plus 7 further packages at lake-manifest.json revisions. Dependencies were
assembled from local git object stores (the pinned revs were all present)
and the WSC repo via codeload tarball; `git rev-parse HEAD` matches the
manifest for all 10 packages.

**Agent provenance (reconstructed):** Muse (Meta) · model `Muse Spark 1.3` · run date `2026-09-28` · added before the harness-pinning policy (2026-10-08); the verdict rests on pinned artifacts, independent of the agent transcript.

## Verdict: PASS (verify/audit)

## What was run

| Check | Result |
|---|---|
| `lake build FSC FSCProbes --wfail` (Lean 4.31.0, pinned deps, prebuilt mathlib oleans via cache) | **EXIT 0**, 3839 jobs, zero warnings/errors |
| Axiom audit: `#print axioms` on all public comparison/equality/strictness/tail theorems | all ⊆ {`propext`, `Classical.choice`, `Quot.sound`} — the intended whitelist |
| Their `scripts/audit_axioms.py` on `FSC/Audit.lean` (all required endpoints) | **"Fresh axiom audit passed for 45 declarations"**, EXIT 0 |
| Placeholder scan: their exact regex (`axiom`/`sorry`/`admit`/`native_decide`/`_private.`) over 62 source files | **none found** |
| Teeth: `audit_axioms.py` on `checks/fixtures/AuditRejected.lean` (decl depending on a custom axiom) | **correctly rejected**, EXIT 1, "Nonstandard axioms" |
| Statement inspection | `cdf_simplex_le` (n≥2, all correlations, all real t), `cdf_eq_simplex_iff` (t>0, ⟺), `cdf_simplex_lt` match (1.4)/(1.5) exactly |
| Definition inspection | `cdf G t` = true Gaussian measure `multivariateGaussian 0 G` of the lower orthant (bridge theorem `cdf_eq_measure` proved); `simplex n` has 1 on diagonal, −1/((n:ℝ)−1) off-diagonal = Δ_n with real subtraction |

## On `formal_subset_of_claim`

Resolved: the Lean formalization proves **Theorem 1.1 in full** —
equations (1.4) and (1.5) are exactly the paper's main result. The "subset"
is that two paper-level consequences are not separately formalized:
Corollary 1.2 (the circumscribed-simplex geometric form) and the
signal-detection application. Both follow from Theorem 1.1 by the paper's
own short arguments; the formalization covers the mathematical core
completely, with no weakened hypotheses (all PSD ranks, duplicates,
antipodes, nonpositive thresholds for comparison; every correlation matrix
at positive thresholds for equality).

## Honest scope

- This audit rebuilt the formalization from the pinned source revision on
  this VM; it does **not** re-derive the paper's hand proof (induction via
  the derivative formula, barrier argument) — the Lean kernel checked the
  formalized proof, and the audit verified the statements say what the
  paper claims.
- The repo's own `docs/STATE.md` (2026-09-08) notes "artifact-free
  clean-checkout reproduction has not yet passed"; this audit ran in a
  tarball checkout with locally assembled dependencies, not their
  `verify_release.py --require-clean` flow (which needs a git checkout).
  The meaningful gates — full warning-free build, axiom audit, no-sorry
  scan, teeth on the auditor — all passed here.
- AI disclosure: the paper states generative AI contributed key insights,
  proof development, and the Lean formalization; the author takes
  responsibility. This audit is an independent check of the formalization
  artifact, not of the disclosure.

## Verdict lock

Untouched (25 gates: 17 BREAK / 8 PASS). This is a standalone verify/audit
PASS, recorded the same way as the other harvest targets.
