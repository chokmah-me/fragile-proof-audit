# Blueprint — Harvest 2026-09-24: nla-mf14, "The exact seven-product closure degree is forty-seven" (Webb)

**Status:** Type-E gate landed (PASS) + Type-G catalog scan landed (no discrepancy: honest scope boundary) + discrimination control landed (NO FALSE POSITIVE) — no Lean scaffold (degree-47 not formalized; degree-44 formalization out of scope for this gate)
**Sources:** Marcus Webb, "The exact seven-product closure degree is forty-seven", September 2026 (pinned PDF `incoming/nla-mf14-webb.pdf`, 90,501 bytes, 6 pages, SHA-256 `80712867ccf9cf5490ab8e672245d9c55773222f1578ae91d952c1da4e13f4b0`)
**Seed:** `incoming/nla-mf14-seed.json` (355,020 bytes, SHA-256 `4bf9b5cca57fa1f04cf55d49c3308dfc7806a3e98bf3c55faba14ee8209d17c3`), from catalog repo `ajt60gaibb/OpenProblemsInNLA` at `0689db001ddc4c54f2652ed4b13b753637fef700`, `references/webb-mf14-degree47-2026-09-17/source/seed.json`
**Attack type:** E (exact-certificate replay, Gaussian-rational Banach fixed-point certificate) + G (logical-gap exposure on verification credit — resolved as honest scope boundary, not a GAP)

## Claim

For the seven-product family X_7 (eqs. 2–5), the closure degree d_7 = 47, proved in two halves:

- **Lower bound d_7 ≥ 47:** a 49-parameter family with exact contact through degree 47, a nonsingular selected 48×48 coefficient Jacobian, a Banach fixed-point certificate (Lemma 3), then an inverse-function/scaling argument covering all of V_47.
- **Upper bound d_7 ≤ 47:** X_7 irreducible with dim X_7 ≤ 49; if V_48 ⊆ X_7, irreducibility/dimension would force X_7 = V_48 — but seven squarings produce x^128 ∉ V_48.

The paper explicitly does not claim exact representation, real coverage, or stable coefficient recovery; explicitly no Lean verification, proof-kernel check, or external human peer review is claimed.

## Load-bearing object

Lemma 3's exact Gaussian-rational certificate: center θc (49 Gaussian rationals, denominator 10^70), ordered active list I of 48 indices (paper Appendix A), preconditioner B ∈ Q(i)^48×48 (denominator 10^60), and seven exact inequalities:

| check | threshold | meaning |
|---|---|---|
| ε = ‖B·F(zc)‖₁ | < 10⁻⁶⁹ | preconditioned residual |
| δ = ‖I − B·J(zc)‖₁ | < 10⁻⁵⁷ | approximate-inverse defect |
| ‖B‖₁ | < 4000 | preconditioner norm |
| H (Hessian majorant) | < 2·10¹² | quadratic-term control |
| q = (δ + H·r)·‖B‖ | < 10⁻²⁹ | contraction factor at r = 10⁻⁴⁵ |
| ε + q·r < r | — | Banach ball invariance |
| ‖z* − zc‖ ≤ 10⁻⁴⁵ and \|Re b − 2\| | > 10⁻⁴⁵ | root inside ball; b stays off the pole |

If all hold, Banach gives z* with F(z*) = 0 inside the ball — the exact contact point.

## Break/GAP point

**Type E (load-bearing, PASS):** the certificate is independently re-verified with a from-scratch exact implementation (see gate). The mathematical route — exact Gaussian-rational Banach certificate — is sound.

**Type G (verification credit, NO DISCREPANCY):** the catalog's Lean formalization (`matrix-functions-and-stability/MF-14/lean`, 87 .lean files at the pinned commit) proves `NLA.MF14Degree44.degree44_coverage` (coverage through degree 44) and `NLA.MF14Degree44.original_equality_false` (refuting the old d_7 = 42) — and its README states explicitly that "the stronger equality [d_7 = 47] is not formalized by this degree-44 project". The paper likewise claims no Lean verification. Both sides agree on the scope boundary; there is no verification-credit gap to expose. Gates refute routes, not theorems — and here no route dies.

## Numeric gate

`scripts/gates/nla_mf14.py` — verdict **PASS**

Independent exact implementation (stdlib `Fraction` Gaussian rationals only, no shared code with the author's checkers):

1. Seed integrity: SHA-256 of `incoming/nla-mf14-seed.json` matches pin; `degree_field == 47`; theta/B denominators are exactly 10^70/10^60; all 49 parameter values present; Appendix-A active list reproduced exactly.
2. Circuit from paper eqs. (2)–(5) rebuilt node-by-node with forward-mode automatic differentiation (values + full 48×48 Jacobian), polynomial arithmetic truncated mod x^48 (exact for the 48 contact equations).
3. All seven Lemma-3 inequalities checked as exact rational comparisons.
4. Jacobian independently validated against complex-step differentiation (all 1,894 nonzero entries agree; 410 structural zeros confirmed genuine, e.g. ∂Φ[44]/∂e_5 = [x^44]q_4 = 0 since deg q_4 ≤ 16).

Cross-checks: the frozen upstream `verification/verify.py` reproduces both exact degree-47 checkers (EXIT 0); the 8 fail-closed rejection tests in `verification/test_verifier.py` all pass (seed mutation, manifest mutation, unlisted sources, symlinks, optimized invocations all rejected).

## Discrimination control

Matched control: shift θ_0's real part by 10⁻⁶⁰ (one numerator bump, everything else fixed), re-run the identical contraction-inequality path. The perturbed seed is REJECTED (ε breaks its 10⁻⁶⁹ bound — the shift exceeds the certificate's margin); the unperturbed seed PASSES the same path. A single-bit flip (10⁻⁷⁰) is correctly *absorbed* by the margins, confirming the inequalities are doing the work. The gate discriminates — it does not rubber-stamp. (Receipt: `results/nla_mf14_control_meta.json`.)
