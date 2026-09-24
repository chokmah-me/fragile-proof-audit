# Gate blueprint — nla-mi32 (Heidary, Latała–Świątkowski upper comparison)

## Claim (pinned paper)

Source: `DiarHaidary/Spectral-norms-of-independent-entries-with-regular-moment-growth@762bd5e`,
`docs/source/MI32_solution.md` (6043 bytes,
SHA-256 `fc2a01f6215d4d1e0e96095ae990ad4208e8126b0091ee0103edbf2918469073`).
The catalog URL from the task brief
(`ajt60gaibb/OpenProblemsInNLA@0689db0/.../references/heidary-mi32-latala-2026-09-19/proof.pdf`)
returns **404**; the paper draft lives in the author's tree, which is also the
harvest record's paper URL.

> "Let X=(X_ij) be a real n-by-n matrix with independent mean-zero entries,
> all absolute moments finite, and ||X_ij||_{2r} <= alpha ||X_ij||_r (r>=1)."

> "c_alpha{M(X)+D(X)} <= E||X|| <= C_alpha{M(X)+D(X)}."

> "The new contribution is the upper bound. The lower bound is the
> established Theorem 4.1 of [Latala--Swiatkowski, Norms of Randomized
> Circulant Matrices](https://arxiv.org/html/2106.03139v2)."

M(X) = max row std + max column std; D(X) = max_{1<=k<=n} min_{|I|<=k}
sup_{||s||_2,||t||_2<=1} ||sum_{i,j not in I} X_ij s_i t_j||_{log(k+1)},
one shared deterministic deletion set I on both axes, subunit order log 2
at k=1 kept literally.

Load-bearing analytic engine (draft, "The substantive contraction"):

> "A vector polynomial F of degree d with nonnegative coefficients in the
> ORIGINAL monomial basis satisfies
> ||F||_{L_4(l_2)} <= (sqrt 3 alpha^2)^d ||F||_{L_2(l_2)}."

Formalized as `MI32.raw_positive_polynomial_fourth_moment`
(`MI32/RawPositiveCone.lean`): for positive original-variable polynomials of
degree <= d, independent fair signs, nonnegative magnitudes with
`moment mu (2*r) (Z e) <= alpha * moment mu r (Z e)`:

```
E_sig[(sum_a P_a^2)^2] <= 9^d * alpha^(8*d) * (E_sig[sum_a P_a^2])^2
```

i.e. the 4th-power form of the (sqrt 3 alpha^2)^d comparison. With Z = 1,
alpha = 1 this is an exact rational inequality over {+-1}^m sign patterns.

Hypothesis class non-vacuous: `MI32/RegularWitness.lean` exhibits an
independent fair-sign matrix satisfying `RegularEntries` at alpha = 1 with
`varianceScale = sqrt n`. Fair signs are regular at alpha = 1
(||X_ij||_{2r} = 1 = ||X_ij||_r).

## Gate (Type A) — `scripts/gates/nla_mi32.py`

Numeric replay of the headline comparison on the Rademacher witness family,
plus an exact replay of the load-bearing fourth-moment lemma. All rational
parts use stdlib `Fraction`; spectral-norm means use mpmath at 80 dps with
an explicit margin.

**S1 — headline on Rademacher witnesses (exact route).** For n in {2,3,4},
enumerate all 2^{n^2} sign patterns:
- F2 = sum_patterns ||X||_F^2 = n^2 * 2^{n^2} exactly (each pattern has
  Frobenius norm^2 = n^2), so E||X||_F^2 = n^2 exactly.
- Jensen (documented analytic step): (E||X||_2)^2 <= E(||X||_2^2)
  <= E(||X||_F^2) = n^2, so E||X||_2 <= n.
- n <= 2*sqrt(n) for n <= 4 (exact integer check n^2 <= 4n).
- M(X) = 2*sqrt(n) exactly for fair signs (row/col sums of squares = n);
  D(X) >= 0 (a norm).
- Hence E||X||_2 <= 1 * (M(X) + D(X)) on n = 2,3,4: the headline holds
  with C = 1 on the witness family.

**S2 — constant sharpness (high precision).** r_n = E||X||_2 / M(X) at
80 dps for n = 2,3,4 (expected ~0.6036, 0.6866, 0.7406). Check
max r_n <= C_claim - margin with C_claim = 1, margin = 0.2.

**S3 — fourth-moment lemma (exact).** Z = 1, alpha = 1. Seeded random
nonnegative-coefficient vector polynomials (m in 4..8 vars, dim 1..3,
degree 1..3, seed documented): with S2 = sum_eps sum_a P_a(eps)^2 and
S4 = sum_eps (sum_a P_a(eps)^2)^2 over all 2^m sign patterns, check
S4 * 2^m <= 9^d * S2^2 exactly (the 4th-power form of the Lean lemma).
K = 40 instances.

**S4 — discrimination control.** Two matched near-misses, both exact:
- (a) Headline with C* = 0.7: must be REJECTED, since observed max
  r_n = 0.7406... > 0.7 at n = 4.
- (b) Lemma with tightened 4th-power constant c = 2.98 (< 3 - 2/201):
  must be REJECTED on the linear form F = sum_{i=1}^{201} x_i (d = 1),
  for which S4*N/(S2^2) = 3 - 2/m exactly. The true constant 9^1
  passes. (Random polynomials do not separate 4^d, so the linear
  form is the sharp witness.)

PASS requires S1, S2, S3 all green and both S4 controls rejecting.

## Type G — formalization vs headline vs catalog

- Lean: 95 files under `MI32/`, toolchain `leanprover/lean4:v4.33.0`;
  sorry scan of Solution.lean + MI32/*.lean; `MI32.main_upper` is the
  single exported declaration (existential constant: `∃ C, 0 < C ∧
  UpperBoundAt α C`).
- Tree README at 762bd5e: "**It is not registered with Palomar.** ...
  Registration has not been requested, no human peer review of the
  mathematics has taken place, and no novelty or priority claim is made."
  `verification/status.json` (checked 2026-09-14T13:55Z): comparator
  "not_run", nanoda "not_run", registration "not_requested".
- Catalog `RESOLVED.md` + `matrix-inequalities-and-norms/MI-32/README.md`
  at 0689db0: "Lean verified — 2026-09-14", registered as
  Palomar entry PALOMAR-2026-09-14-000006 v1, "Palomar's Linux Comparator,
  NanoDa and sandboxed kernel run 34852526384 accepted the frozen
  statement", trust level "high", editorial review "neutral".
- Registry ground truth (`data.palomar-registry.org/recent.json` +
  `entries/PALOMAR-2026-09-14-000006-v1.json`, fetched 2026-09-24):
  status "registered", trust {"level": "high"}, source commit
  762bd5ec5050a96f5e6ba3926b6cda4816fcd4b0 (the exact pinned commit),
  published 2026-09-14T15:41:11Z, verification run_id 34852526384,
  comparator commit 57567492, nanoda commit 68d5ca9d, review outcome
  "neutral" (reviewer codex:gpt-5.6-sol, reviewed 14:38:57Z).
  Verdict: the catalog's registration claims are TRUE; the tree page is
  stale (frozen ~2h before registration published). Not fabrication.
- Palomar's own review warning (kept in the record): "The informal
  account materially misidentifies the exact-logarithmic LocalLogMoment
  theorem as a step in the selected proof. Describe it as an unused
  companion corollary..." — a documented formalization-vs-informal-account
  mismatch, review still "neutral".

Scope: the gate checks the quantitative headline on witnesses and the
load-bearing lemma; it does not re-verify the Lean proof (Palomar's
comparator + kernel run did that). Gates refute routes, not theorems.
