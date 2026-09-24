# Blueprint — Harvest 2026-09-24: nla-mf24, "Unbounded polynomial norm ratios for super-identical pseudospectra" (Maierhofer)

**Status:** Type-A gate landed (PASS) + Type-G scan landed (formal_subset_of_claim: Lean proves the weaker (2/3)√m; headline (4/5)√m and Corollary 3 outside formalized scope) + discrimination control landed (NO FALSE POSITIVE)
**Sources:** Maierhofer, "Unbounded polynomial norm ratios for super-identical pseudospectra", September 2026 (pinned PDF `incoming/nla-mf24-maierhofer.pdf`, 274,662 bytes, 4 pages, SHA-256 `1ae9316d7c935f6133a54b133d36bc55dce34f3a252b44c314b3b45a54514139`)
**Attack type:** A (asymptotics replay: exact recomputation of the norm ratio along the explicit sequence) + G (logical-gap exposure on verification credit)

## Claim

For every integer m ≥ 2 and real t > 1, weighted shifts X = X_{m,t}, Y = Y_{m,t} of order N = (m+1)² have super-identical pseudospectra (X ∼_{sip} Y) but admit a common polynomial p_m(z) = Σ_{j=1}^m z^{Dj} (D = m+2) with

> "‖p_m(X)‖₂ ≥ t²√m, ‖p_m(Y)‖₂ ≤ t² + m − 1"  (3)

hence

> "‖p_m(X)‖₂ / ‖p_m(Y)‖₂ ≥ √m / (1 + (m−1)/t²)"  (4)

Taking t = m:

> "‖p_m(X_{m,m})‖₂ / ‖p_m(Y_{m,m})‖₂ ≥ 4/5 √m → ∞"  (15)

"Each pair consists of finite rational matrices. Thus the uniform boundedness question has a negative answer, without taking a limit of matrices." Corollary 3: C_N ≥ √(⌊√N⌋ − 1) for N ≥ 9, so lim inf_{N→∞} C_N/N^{1/4} ≥ 1.

The abstract's headline: "whose norms under a common polynomial have ratio at least (4/5)√m. Thus no dimension-independent comparison constant exists."

## Load-bearing objects

1. **The words (5).** U = (t, 1, …, 1) of length m; X's word = U, 1, U, (t^{−1}, U)^{m−1}; Y's word = U, (t^{−1}, U)^{m−1}, 1, U. Each word has (m+1)m + m = N−1 entries. Nonnegative nilpotent weighted shifts. (Transcription note: the PDF text extraction flattens superscripts, rendering t^{−1} as "t−1"; the bridge weight is pinned to t^{−1} by the paper's own "each t^{−1} bridge lowers [the height] by one" and by Lemma 2's application "with a = t^{−2}" — the bridge weight squared. The gate initially transcribed t−1 and its own t = 2 height check caught the error.)

2. **sip equality (Sec. 2).** For W a weighted shift and z ∈ ℂ, the leading principal determinants of (W−zI)*(W−zI) + ηI factor through 2×2 transfer matrices: d_N = f^T K(w²_{N−1}) ⋯ K(w²₁) v₀ (8). Lemma 2 (bridge identity): with R = PK(a), S = PK(b), f^T R^n S v = f^T S R^n v — "The transposes are algebraic, not conjugate transposes." Applying it with a = t^{−2}, b = 1, n = m−1 gives det((X−zI)*(X−zI) + ηI) = det((Y−zI)*(Y−zI) + ηI) as polynomials in η (10) — hence X ∼_{sip} Y.

3. **Numerator (Sec. 3).** Prefix heights h_X(qk+s) = 1{s≥1} + 1{q≥1} (11); (W^ℓ)_{r,r+ℓ} = t^{h(r+ℓ)−h(r)} (12). "For 1 ≤ j ≤ m, the vertex jD = jk+j has X-height 2. Thus the first row of p_m(X) contains m entries equal to t², at columns D, 2D, …, mD. Its Euclidean norm is t²√m, which is at most the operator norm of p_m(X)." Also "(p_m(Y))_{0,N−1} = t² ≠ 0" (13) — the denominator polynomial matrix is nonzero.

4. **Denominator (Sec. 3).** "Every nonzero entry of p_m(Y) joins vertices in the same residue class modulo D. Permuting rows and columns by these classes gives a block diagonal matrix. Since N = mD + 1, each block has size L = m or m + 1." Entries: B_{ij} = t^{a_j − a_i} for j > i, 0 for j ≤ i (14). "Each Y-block contains at most one height 0 and at most one height 2." The first column and last row of each block B are zero; removing them gives bB with the same operator norm. With u_i = t^{−a_i}, v_j = t^{a_{j+1}}: "|bBx| ≤ u (v^T|x|), ‖bBx‖₂ ≤ ‖u‖₂‖v‖₂‖x‖₂" (Cauchy–Schwarz), and "‖u‖₂² ≤ 1 + (L−2)t^{−2}, ‖v‖₂² ≤ t⁴ + (L−2)t²", so "‖B‖₂ ≤ ‖u‖₂‖v‖₂ ≤ … = t² + L − 2 ≤ t² + m − 1."

5. **Sharp corollary (Sec. 4).** t = m gives (15) via "4(m−1) ≤ m²". "The exact constants C_N and their optimal growth rate are not determined here. In particular, a gap remains between the lower scale N^{1/4} in Corollary 3 and the upper scale N^{1/2} from [2, Theorem 1.3]."

## Break/GAP point

**Type A (load-bearing, PASS):** the quantitative chain (3)→(4)→(15)→(16) is independently replayed with exact rational arithmetic (see gate). The mathematical route — residue-class block decomposition with the height argument — is sound.

**Type G (verification credit, GAP):** the catalog's Lean formalization proves only the weaker bound (2/3)√m; the headline (4/5)√m and Corollary 3 sit outside the formalized scope. Details below.

## Numeric gate

`scripts/gates/nla_mf24.py` — verdict **PASS**

From-scratch exact implementation (stdlib `Fraction` only; the paper's equations re-derived, never imported):

1. Words (5) built for m = 2..12, t ∈ {2, 3, m}; closed-form superdiagonal entries via prefix products (12): (W^ℓ)_{r,r+ℓ} = t^{h(r+ℓ)−h(r)}.
2. sip check: for each m and z ∈ {1, 2, 1+i}, the η-polynomial d_N = f^T K(w²_{N−1})⋯K(w²₁)v₀ (8) is computed as 2×2 polynomial products over ℤ[ρ] and compared exactly between X and Y. All agree.
3. Numerator: row 0 of p_m(X) has exact entries t² at columns D, …, mD and 0 elsewhere → row 2-norm² = m·t⁴ exactly.
4. Denominator: residue classes mod D have block sizes m or m+1; each block has ≤ 1 height-0 and ≤ 1 height-2 vertex; exact Frobenius bound ‖bB‖_F ≤ t²+L−2 ≤ t²+m−1 per block (a checkable sufficient route to ‖·‖₂ ≤ t²+m−1); (p_m(Y))_{0,N−1} = t² ≠ 0.
5. Ratio arithmetic: √m/(1+(m−1)/t²) ≥ (4/5)√m at t = m verified exactly via (m−2)² ≥ 0; divergence exhibited: the (4/5)√m lower bound exceeds 1, 2, 3 at m = 4, 9, 16.
6. Corollary 3 sample: for N ∈ {9, 10, 15, 25, 50, 100}, m = ⌊√N⌋−1 ≥ 2 and the padded bound √(⌊√N⌋−1) is attained by the sequence.

## Discrimination control

Matched control: perturb a single bridge weight of X's word (1 → 2, everything else fixed) and re-run the identical check path. The perturbed pair is REJECTED (the η-polynomial identity (8) fails — charpoly mismatch at degree ≥ 1; numerator identity also breaks); the unperturbed pair PASSES. The gate discriminates — it does not rubber-stamp. (Receipt: `results/nla_mf24_control_meta.json`.)

## Type-G detail

**Lean subtree** (`matrix-functions-and-stability/MF-24/lean` at the pinned commit): 22 `NLA/MF24` proof modules + `Challenge.lean` + `Solution.lean`; toolchain pinned `leanprover/lean4:v4.33.1`; immutable proof commit `208e30d80f73ef661b1f019c7de93c70254f7e48`, which passed canonical Linux verification (GitHub Actions run 35033148310, 2026-09-15: LeanCert kernel assertions, Comparator, default-kernel replay, standard axioms `propext`/`Classical.choice`/`Quot.sound`, rejection + sandbox controls).

**Sorry/axiom scan:** 22 sorrys, all in `Challenge.lean` (the 22 deliberate specification placeholders, per `formalization.yaml`); 0 in `Solution.lean` and all 22 proof modules; no `axiom`/`admit`/`native_decide`.

**What is proved:** `NLA.MF24.no_uniform_comparison` and `arbitrarily_large_ratios` (the qualitative unboundedness), plus a weaker quantitative bound: `finite_rational_family_ratio` gives `(2/3)√m` at `t = m` with conservative denominator `t² + m` (paper: `t² + m − 1`).

**What is not:** the headline `(4/5)√m`, the `t² + m − 1` denominator, and Corollary 3 (all-dimension padding, `liminf C_N/N^{1/4} ≥ 1`). `formalization.yaml` fidelity: "The denominator estimate is deliberately weakened from t²+m−1 to t²+m, and the finite-family ratio from (4/5)sqrt(m) to (2/3)sqrt(m)… The source's all-dimension padding lower bound, liminf result and sharp constants are not formalized."

**Catalog credit:** `RESOLVED.md` attributes Theorem 1 and eq. (15) to Maierhofer's manuscript and states of the Lean work: "Its conservative ratio (2/3)√m suffices; the sharper manuscript corollaries remain outside the formalization." The tree README agrees. **NO DISCREPANCY** — honest scope boundary on both sides. (Receipt: `results/nla_mf24_typeg_meta.json`.)
