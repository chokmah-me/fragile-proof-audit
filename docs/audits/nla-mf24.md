# Audit note — NLA-MF24 Maierhofer "Unbounded polynomial norm ratios for super-identical pseudospectra" — Type-A replay: PASS; Type-G verification-credit scan: no discrepancy

**Target:** harvest 2026-09-24, Card 5 (`nla-mf24`), fragility 3.
**Paper:** Georg Maierhofer, "Unbounded polynomial norm ratios for super-identical pseudospectra", September 2026.
**Pins:** `incoming/nla-mf24-maierhofer.pdf` (4 pages, SHA-256 `1ae9316d7c935f6133a54b133d36bc55dce34f3a252b44c314b3b45a54514139`); catalog ajt60gaibb/OpenProblemsInNLA at `0689db001ddc4c54f2652ed4b13b753637fef700`.
**Date:** 2026-09-24. **Scope:** Type-A exact replay of the norm-ratio chain (3)→(4)→(15)→(16) + Type-G scan of the Lean-verification credit. No Lean build attempted (the formalization's canonical verification evidence is published and reviewed below).

**Verdicts: Type-A PASS. Type-G NO DISCREPANCY** (honest scope boundary on both sides). The quantitative chain replays exactly, and the catalog's Lean formalization explicitly disclaims the sharp constants.

## The claim

For every integer m ≥ 2 and real t > 1, weighted shifts X = X_{m,t}, Y = Y_{m,t} of order N = (m+1)² have super-identical pseudospectra (X ∼_{sip} Y), and for D = m+2, p_m(z) = Σ_{j=1}^m z^{Dj}: ‖p_m(X)‖₂ ≥ t²√m, ‖p_m(Y)‖₂ ≤ t²+m−1, so the ratio ≥ √m/(1+(m−1)/t²). At t = m the ratio ≥ (4/5)√m → ∞ — finite rational matrices, no limit of matrices needed. Corollary 3: C_N ≥ √(⌊√N⌋−1) for N ≥ 9, hence lim inf C_N/N^{1/4} ≥ 1.

## Type-A: the norm-ratio chain replays exactly (PASS)

`scripts/gates/nla_mf24.py` is a from-scratch exact reimplementation (stdlib `Fraction` only; the paper's equations re-derived, never imported), sweeping m = 2..12 with t ∈ {2, 3, m}:

- **S1 — sip identity:** the η-polynomial d_N = f^T K(w²_{N−1})⋯K(w²₁)v₀ (paper eq. 8) agrees exactly between X and Y for |z|² ∈ {1, 2, 4}, all m, all t. The two Gram matrices therefore have identical characteristic polynomials — X ∼_{sip} Y.
- **S2 — numerator:** row 0 of p_m(X) has exact entries t² at columns D, 2D, …, mD and 0 elsewhere, so its 2-norm² is exactly m·t⁴ — the paper's ‖p_m(X)‖₂ ≥ t²√m.
- **S3 — denominator:** residue classes mod D give blocks of size m or m+1; each block has ≤ 1 height-0 and ≤ 1 height-2 vertex (checked); per-block exact Frobenius bound ‖bB‖_F ≤ t²+L−2 ≤ t²+m−1 — a checkable sufficient route to the paper's ‖p_m(Y)‖₂ ≤ t²+m−1; and (p_m(Y))_{0,N−1} = t² ≠ 0, so the ratio's denominator is nonzero.
- **S4 — ratio arithmetic:** the squared ratio identity is an exact rational equality; at t = m the (4/5)√m sharpening holds exactly via m² ≥ 4(m−1) ⟺ (m−2)² ≥ 0.
- **S5 — divergence:** the (4/5)√m lower bound exceeds 8/5, 16/5, 24/5, 32/5 at m = 4, 16, 36, 64; Corollary 3 instances check out for N ∈ {9, 10, 15, 25, 50, 100}.

Heights are derived symbolically from the word structure and verified against the paper's eq. (11) for every (m, t) — closing the word→height→bound loop.

**Transcription catch (gate caught its own bug):** the PDF text extraction flattens superscripts, rendering the bridge weight t^{−1} as "t−1". The gate first transcribed t−1; its own t = 2 height check failed (at t = 2 the weights t−1 and 1 coincide, exposing the inconsistency). The paper pins the weight to t^{−1} three ways: "each t^{−1} bridge lowers [the height] by one", Lemma 2 applied "with a = t^{−2}" (the bridge weight squared), and the author's own `mf24.py` (`bridges = [0] + [-1] * (m - 1)` weight exponents). After the fix, all sections pass. The flattened-superscript hazard is now recorded in the blueprint.

Cross-check: the author's frozen `references/mf24-counterexample/check_exact.py` was run independently — 5 of its 6 stages passed: generic bridge/Cayley–Hamilton identities, words/heights/block sizes for m = 2..30, 18 bivariate determinant identities, 6 direct polynomial-matrix evaluations with block decompositions, exact rational certificates at m = t = 4 (ratio > 32/19) and m = t = 9 (ratio > 243/89) via rational LDL positivity, and both negative controls (misplaced bridge, zero LDL pivot rejected). The remaining stage — direct Gram characteristic polynomials with fully symbolic z, z̄ (25×25 in sympy) — exceeded the practical time budget and was not awaited; its content (the sip determinant identity) is covered by this gate's S1.

Discrimination control: **NO FALSE POSITIVE** — changing X's "1" bridge weight 1→2 (all else fixed) breaks the sip charpoly identity at every sampled ρ; flipping one motif-edge height increment 1→0 breaks the numerator exactness (row norm² 27 ≠ 243 at m = t = 3); the unperturbed pair passes the same path. (Receipt: `results/nla_mf24_control_meta.json`.)

## Type-G: the scope boundary is honest on both sides (no discrepancy)

The catalog's Lean subtree (`matrix-functions-and-stability/MF-24/lean`, 22 `NLA/MF24` modules + Challenge/Solution at the pinned commit, toolchain `leanprover/lean4:v4.33.1`) proves `NLA.MF24.no_uniform_comparison` and `arbitrarily_large_ratios` — the qualitative unboundedness — plus a deliberately weaker quantitative bound: `(2/3)√m` at t = m with conservative denominator `t² + m`. Its README states: "At t=m the ratio is at least (2/3)√m… Sharper constants and additional dimension-padding corollaries of the manuscript are outside this formalization." `formalization.yaml` agrees: "The denominator estimate is deliberately weakened from t²+m−1 to t²+m, and the finite-family ratio from (4/5)sqrt(m) to (2/3)sqrt(m)… The source's all-dimension padding lower bound, liminf result and sharp constants are not formalized." The catalog's `RESOLVED.md` attributes Theorem 1 and eq. (15) to Maierhofer's manuscript and describes the Lean contribution accurately ("Its conservative ratio (2/3)√m suffices; the sharper manuscript corollaries remain outside the formalization").

The sorry scan is consistent: 22 sorrys, all in `Challenge.lean` (the 22 deliberate specification placeholders); 0 in `Solution.lean` and all 22 proof modules; no `axiom`/`admit`/`native_decide`. The immutable proof commit `208e30d` passed canonical Linux verification (run 35033148310, LeanCert kernel, standard axioms).

Nothing is over-claimed, so there is no verification-credit gap to expose. The sharp (4/5)√m and Corollary 3 stand on the manuscript plus the exact replay (this gate) — informal, but exactly what both sources say they are. Gates refute routes, not theorems — and here no route dies. (Receipt: `results/nla_mf24_typeg_meta.json`.)
