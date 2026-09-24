# Audit note — NLA-MF14 Webb "The exact seven-product closure degree is forty-seven" — Type-E replay: PASS; Type-G verification-credit scan: no discrepancy

**Target:** harvest 2026-09-24, Card 2 (`nla-mf14`), fragility 8.
**Paper:** Marcus Webb, "The exact seven-product closure degree is forty-seven", September 2026.
**Pins:** `incoming/nla-mf14-webb.pdf` (6 pages, SHA-256 `80712867ccf9cf5490ab8e672245d9c55773222f1578ae91d952c1da4e13f4b0`); seed `incoming/nla-mf14-seed.json` (SHA-256 `4bf9b5cca57fa1f04cf55d49c3308dfc7806a3e98bf3c55faba14ee8209d17c3`); catalog ajt60gaibb/OpenProblemsInNLA at `0689db001ddc4c54f2652ed4b13b753637fef700`.
**Date:** 2026-09-24. **Scope:** Type-E exact replay of the Lemma-3 Banach certificate + Type-G scan of the Lean-verification credit. No Lean build attempted (nothing to build against — the degree-47 result is not formalized).

**Verdicts: Type-E PASS. Type-G NO DISCREPANCY** (honest scope boundary on both sides). The Lemma-3 contraction certificate is exactly as claimed, and the catalog's Lean formalization explicitly disclaims the degree-47 result.

## The claim

For the seven-product family X_7, the closure degree d_7 = 47. Lower bound: a 49-parameter family with exact contact through degree 47 (Lemma 3's Banach certificate), lifted by an inverse-function/scaling argument to all of V_47. Upper bound: X_7 irreducible, dim ≤ 49; V_48 ⊆ X_7 would force X_7 = V_48, contradicted by seven squarings producing x^128. The paper claims no Lean verification, no proof-kernel check, no external human peer review — and none is needed for the gate.

## Type-E: the certificate verifies (PASS)

`scripts/gates/nla_mf14.py` is a from-scratch exact reimplementation (stdlib `Fraction` Gaussian rationals; no code shared with the author's checkers):

- **Seed integrity:** SHA-256 matches the pin; `degree_field == 47`; θ denominators exactly 10^70, B denominators exactly 10^60; all 49 parameter values present; the 48-index active list matches the paper's Appendix A exactly, in order.
- **Circuit:** paper eqs. (2)–(5) rebuilt node-by-node with forward-mode AD (values + full 48×48 Jacobian), products truncated mod x^48 — exact for the 48 contact equations F_j = [x^j]Φ − δ_{j,47}.
- **All seven Lemma-3 inequalities hold as exact rational comparisons:** ε < 10⁻⁶⁹, δ < 10⁻⁵⁷, ‖B‖₁ < 4000, H < 2·10¹², q < 10⁻²⁹, ε + q·r < r at r = 10⁻⁴⁵, and |Re b − 2| > 10⁻⁴⁵.
- **Jacobian cross-validated** against complex-step differentiation: all 1,894 nonzero entries agree; the 410 exact zeros are structural (e.g. ∂Φ[44]/∂e_5 = [x^44]q_4 = 0 as deg q_4 ≤ 16).

Two independent confirmations: the frozen upstream `verification/verify.py` reproduces both exact degree-47 checkers and the full degree-128 reconstruction (EXIT 0); the 8 fail-closed rejection tests in `verification/test_verifier.py` pass (seed/manifest mutation, unlisted sources, symlinks, optimized invocations all rejected).

Discrimination control: **NO FALSE POSITIVE** — shifting θ_0 by 10⁻⁶⁰ (one entry, all else fixed) breaks the ε < 10⁻⁶⁹ contraction bound on the identical path; the unperturbed seed passes. A 10⁻⁷⁰ single-bit flip is correctly absorbed by the margins. (Receipt: `results/nla_mf14_control_meta.json`.)

## Type-G: the scope boundary is honest on both sides (no discrepancy)

The catalog's Lean subtree (`matrix-functions-and-stability/MF-14/lean`, 87 .lean files at the pinned commit) formalizes the *earlier* degree-44 result: `NLA.MF14Degree44.degree44_coverage` and `NLA.MF14Degree44.original_equality_false` (refuting the old d_7 = 42). Its README states: "The repository's later mathematical resolution d_7 = 47 … that stronger equality is **not formalized by this degree-44 project**." The paper agrees: "no Lean verification … is claimed." The `sorry` scan is consistent: 25 sorrys, all in `Challenge.lean` (explicitly a statement-only proposal with deliberate placeholders); 0 in `Solution.lean` and all 85 proof modules; no `axiom`/`admit`/`native_decide`.

Nothing is over-claimed, so there is no verification-credit gap to expose. The exact-47 theorem stands on the exact Python certificate (this gate) plus the frozen upstream checkers — informal, but exactly what both sources say it is. Gates refute routes, not theorems — and here no route dies.
