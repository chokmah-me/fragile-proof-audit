# q=1 shakedown: Stembridge's TSPP theorem (arXiv:0906.1018)

**Source:** Christoph Koutschan, "Eliminating Human Insight: An Algorithmic
Proof of Stembridge's TSPP Theorem", arXiv:0906.1018 (2009). Read 2026-09-23
(via arXiv HTML). This is the q=1 case of the q-TSPP proof — "fully written
up, smaller certificates", ordinary (non-q) Ore algebra — and the staging
shakedown for the q-case formalization (see `docs/blueprint/qtspp.md` §3b).

## 1. The theorem (Theorem 2.3)

A *plane partition* π = (π_{ij}) is a 2D array of naturals, weakly decreasing
in rows and columns, with finite sum (Def 2.1). It is *totally symmetric*
(Def 2.2) if its 3D Ferrers diagram is S₃-invariant: (i,j,k) occupied ⇒ all
permutations occupied.

**Theorem 2.3 (Stembridge).** The number of TSPPs with 3D Ferrers diagram in
[0,n]³ is

    (2.1)   ∏_{1≤i≤j≤k≤n} (i+j+k−1)/(i+j+k−2).

This is the q→1 limit of the q-TSPP product formula: setting q→1 in
(1−q^{i+j+k−1})/(1−q^{i+j+k−2}) gives (i+j+k−1)/(i+j+k−2) by l'Hôpital.

**Enumeration spot check** (matches the known TSPP counts; corpus §4.4
confirmed 2, 5, 16, 66, 352 at q=1):

| n | product value |
|---|---|
| 1 | 2/1 = 2 |
| 2 | 2/1 · 3/2 · 4/3 · 5/4 = 5  (Example 2.4 of the paper) |
| 3 | 16 |
| 4 | 66 |
| 5 | 352 |

## 2. Okada's reduction (Theorem 2.5) — the machine target

The paper follows Okada [JCTA 1989]: (2.1) holds iff the determinant
evaluation

    (2.2)   det(a(i,j))_{1≤i,j≤n} = ∏_{1≤i≤j≤k≤n} ((i+j+k−1)/(i+j+k−2))²

holds, with

    (2.3)   a(i,j) = C(i+j−2,i−1) + C(i+j−1,i) + 2δ(i,j) − δ(i,j+1).

The combinatorial TSPP definition stays informal; (2.2) is the formal
target (stated in `FragileProofAudit/QTSPP/Stembridge.lean`).

## 3. The three identities (Zeilberger's holonomic ansatz, §3)

Pull a bivariate sequence B(n,j) "out of the hat" (the guessed normalized
cofactors) and check:

    (3.1)   Σ_{j=1}^{n} B(n,j)·a(i,j) = 0        (1 ≤ i < n)   [orthogonality]
    (3.2)   B(n,n) = 1                           (n ≥ 1)       [diagonal]
    (3.3)   Σ_{j=1}^{n} B(n,j)·a(n,j) = Nice(n)/Nice(n−1)      [norm]

Then B(n,j) are the true normalized cofactors and (2.2) follows.

**Guessing (§5.1).** Kauers' Guess.m on cofactor data: 65 recurrences
(~5 MB) → noncommutative Gröbner basis of **5 polynomials (~1.6 MB)**,
leading monomials S_j⁴, S_j³S_n, S_j²S_n², S_jS_n³, S_n⁴ — a staircase of
regular shape, **10 monomials under the stairs** (= 10 initial values).
Singularity analysis (§5.2): leading coefficients vanish only at an
explicit finite set of (j,n) points; together with the staircase this pins
the full initial-value set (listed in §5.2, Figure 3).

## 4. Certificate inventory: q=1 vs q-case

| piece | q=1 (arXiv:0906.1018) | q-case (arXiv:1002.4384) |
|---|---|---|
| defining system | 5 Gröbner-basis polynomials ~1.6 MB, ordinary Ore **Q(n,j)**[S_n,S_j] | ~30 MB, Q(q,q^n,q^j)[S_n,S_j] |
| (3.2) / (1): diagonal | order-7 recurrence; **(S_n−1) right factor**; leading coeff explicitly factored, nonvanishing on ℕ; **7 initial values** | order-7; (S_n−1) right factor; p_7(q,q^n,q^n)≠0; 7 values |
| (3.3) / (3): norm | ~5 MB telescoping relation (ansatz I=7, K=5, 126 unknowns; coeffs deg ≤ 382); order-10 recurrence; RHS operator a **right divisor**; **10 initial values**; RHS = 4^{1−n}(3n−1)²(2n)_{n−1}²/((3n−2)²(n/2)_{n−1}²) | order-12; L_12 = Q·L_2; L_2 kills RHS; LC≠0; 12 values |
| (3.1) / (2): orthogonality | **TWO operators: 200 MB + 700 MB**; reformulated ΣB(n,j)a'(i,j) = B(n,i−1)−2B(n,i); RHS ideal via operator (1−2S_i), 8 under stairs; trapezoid initial values; LC factors (5+i−n), (5−i+n) | two CT recurrences; the bulk of the 7 GB |
| **total** | **~1 GB (dominated by (3.1))** | **~7 GB (dominated by (2))** |

Note the inversion: in the q-case identity (2) is the monster; at q=1 it
is (3.1) (900 MB of the ~1 GB). The diagonal piece (3.2) is small in both —
it is the shakedown target.

## 5. Smallest machine-checkable piece: identity (3.2) (§5.3)

- Diagonal recurrence of **order 7** for d_n := B'(n,n), from the ∂-finite
  description by closure property "substitution" (j ↦ n) — "a couple of
  minutes" in HolonomicFunctions.
- Reducing this recurrence by the ideal (S_n−1) gives 0, i.e. the order-7
  operator is a **left multiple of (S_n−1)** ((S_n−1) is a right factor);
  (S_n−1) annihilates the constant sequence 1.
- Leading coefficient explicitly factored:

      256(2n+3)(2n+5)(2n+7)(2n+9)(2n+11)²(2n+13)² · p_1 · p_2,

  p_1, p_2 irreducible of degrees 4 and 12 — every factor visibly > 0 for
  n ≥ 0 (the (2n+k) factors trivially; p_1, p_2 need an explicit
  no-ℕ-root check from the certificate data).
- **Finite check:** B'(1,1) = … = B'(7,7) = 1 (match by construction of the
  guess from cofactor data).
- **Closing argument:** d_n and the constant-1 sequence satisfy the same
  order-7 recurrence with everywhere-nonzero leading coefficient and agree
  on 7 initial values ⇒ d_n = 1 for all n ≥ 1, by forward induction
  (uniqueness for variable-coefficient linear recurrences — proved
  sorry-free in `FragileProofAudit/QTSPP/Stembridge.lean` as
  `recurrence_unique`).

## 6. What a Lean proof of (3.2) needs — mathlib gaps (honest)

**Done (this milestone):** the abstract closing lemma
(`recurrence_unique`, sorry-free); the statement scaffold (matrix entry,
product, determinant identity as `Prop`). Enumeration values n=1,2,3
(2, 5, 16) verified against the paper/corpus externally; not as Lean
`decide` proofs (kernel evaluation too slow in this environment).

**Still needed for (3.2), per item:**
- (a) The explicit order-7 recurrence coefficients — certificate *data*,
  small (not printed in the paper; recoverable from the HolonomicFunctions
  computation or the supplementary material — open recovery item).
- (b) The factorization L = Q·(S_n−1) as an Ore identity — univariate case
  **Q(n)**[S_n]; checkable via the single commutation rule
  S_n·p(n) = p(n+1)·S_n. Mathlib has **no Ore algebra**, but this fragment
  needs only a small verified normalizer (or a hand-rolled tactic), not a
  Gröbner engine.
- (c) Deriving the diagonal recurrence from B' (closure "substitution") —
  needs **verified ∂-finite closure properties, absent from mathlib**.
  Workaround for the shakedown: take the order-7 operator + an
  ideal-membership reduction certificate as *input data* (the paper's
  computation already produces it), and only verify the reduction.
- (d) The 7 initial values — computable from the minor definition of B at
  small n (explicit small determinants; `decide`-scale).
- (e) p_1, p_2 nonvanishing on ℕ — explicit polynomials; factor over ℤ or
  bound (decide-scale once the data is in).

**Gaps that do NOT block (3.2):** noncommutative Gröbner bases (not needed
for the univariate diagonal piece); q-hypergeometric toolkit (q=1 needs
only ordinary binomials — mathlib has them); the 200 MB/700 MB (3.1)
operators (out of kernel reach regardless — meta-level checking only).

**Shakedown value:** (3.2) exercises the full "rational-function
certificate + finite initial-value check" pattern at minimal size, and its
closing lemma is now proved. It is the template for the q-case identity
(1), and for the (3.3)→order-10 pilot next.

## 7. Certificate recovery report — milestone 2 (2026-09-23)

**Target:** the explicit order-7 recurrence coefficients for the diagonal
identity (3.2) and the polynomials p_1, p_2 (degrees 4, 12) in the leading
coefficient factorization. **Verdict: not present in any public source.**
Searched, in order:

1. **arXiv:0906.1018 source package** (`export.arxiv.org/e-print/0906.1018`,
   fetched 2026-09-23; tarball SHA-256
   `68ca7cf2a06ff933e70e448096e9fb9066c91e82d5947d0b0834c70fa3ea108b`,
   54,137 bytes): contains only `koutschan_TSPP.tex`, 4 EPS figures, and the
   document class. **No ancillary Mathematica/data files.** The TeX confirms
   the paper prints only the leading-coefficient factorization, not the
   operator.
2. **Koutschan's PhD thesis** (RISC, JKU Linz, 2009):
   `http://www.koutschan.de/publ/Koutschan09/thesisKoutschan.pdf`
   (fetched 2026-09-23; 949,327 bytes, SHA-256
   `7cebf40aa6c52ddfa42e6b4d21dbe92d08fda6e4b63711db8c91ea317351e861`).
   The TSPP chapter (Ch. 7, §7.3 "The second identity") repeats the paper
   **verbatim**: leading-coefficient factorization only; p_1, p_2 described
   but not given; no appendices with operator data.
3. **Wayback CDX of the author's supplementary pages**
   (`risc.jku.at/people/ckoutsch/*`, all 200-status captures): only the
   q-case `qtspp/` page was ever archived (the `qTSPP.nb` notebook,
   `qtspp.zip` — q-case material, already recovered). **No q=1
   supplementary page/file was found in the searched captures.**
4. **Wayback CDX of `koutschan.de/publ/Koutschan09/*`**: only
   `thesisKoutschan.pdf` and two HTML pages; no data files.

**Consequence:** milestone 2 formalizes (3.2) **parametrically**
(`FragileProofAudit/QTSPP/DiagonalIdentity.lean`): the certificate is an
explicit `DiagonalCertificate` structure (order-7 coefficients `p`,
right-factor witness `q`, with the Ore relations `L = Q·(S_n−1)` unfolded);
the closing argument — right factor ⇒ constant-1 sequence satisfies `L` ⇒
`d = 1` by `recurrence_unique` — is fully proved, sorry-free. Recovering the
numeric `p`/`q` (e.g. by re-running `DFiniteSubstitute` from the ∂-finite
description, or by author contact) reduces to discharging the structure's
fields plus: the recurrence itself (`hrec`, needs the ∂-finite description),
leading-coefficient nonvanishing (`hlead`, via the factored form), and the 7
initial values (`hinit`, small determinants).

**Status (2026-09-23):** the parametric formalization is complete and
kernel-checked — `lake build FragileProofAudit.QTSPP.DiagonalIdentity`
EXIT 0, 8,656/8,656 jobs, zero errors, no `sorry`/`admit`/`native_decide`
(log `~/workspace/qtspp-m2-build.log`). Milestone 2 closed as
"parametric proof of (3.2) modulo coefficient recovery"; the numeric
coefficient recovery stays open as milestone-3-blocker work.

## 8. Milestone 3 — coefficient recovery attempt (2026-09-23)

**Target:** explicit polynomials `p_0..p_7`, `q_0..q_6` for the
`DiagonalCertificate` (q=1 diagonal recurrence, order 7, right factor
`(S_n−1)`).

**Avenue 1 — q-case diagonal recurrence via q→1 limit: BLOCKED.**
The recovered `qTSPP.nb` notebook (Wayback 2026-05-13, 677 KB) documents the
q-case diagonal computation: `recDiag` (order 7, ByteCount 13,451,904 ≈
13 MB) found by `FindRelation` on the annihilating ideal ("requires 3 GB
of memory"), then `OrePolynomialSubstitute` j↦n, confirmed as a multiple of
the constant-1 annihilator via `OreReduce`. **But the 13 MB `recDiag`
output is NOT in the notebook** (output cells contain only timings) **and
not in any `.m` file** (`ann-qTSPP-deg.m` holds only the 5-ideal generators;
`ansatz*/denom*/solution*` are the CT certificates for (2)/(3)). Re-running
`FindRelation` needs the HolonomicFunctions Mathematica package (unavailable)
or a from-scratch Ore-relation finder (multi-week). The naive q→1 limit of
the q-case operator would give constant (not polynomial) coefficients anyway;
the (q−1)-adic leading-term extraction is unexplored.

**Avenue 2 — author contact: DRAFTED, awaiting user approval.**
Draft email to Christoph Koutschan requesting the q=1 diagonal recurrence
coefficients (and ideally the q=1 ∂-finite description / Gröbner basis).
The q=1 operator was computed in "a couple of minutes" per the paper §5.3,
so re-running it is trivial for the author — this is the highest-probability
path to the TRUE coefficients.

**Avenue 3 — full re-derivation (guessing + DFiniteSubstitute): SCOPED, not started.**
Re-guess the q=1 ∂-finite description from determinant data (B(n,j) via exact
integer-matrix cofactors), then implement substitution j↦n. Requires
multivariate Ore guessing + noncommutative Gröbner + substitution —
a multi-week infrastructure project in its own right. Fallback if Avenues 1–2 fail.

**Interim position:** the parametric Lean module (`DiagonalCertificate`)
is complete and kernel-checked; plugging in numbers is a pure data step once
Avenue 2 (or 3) delivers. No placeholder/arbitrary certificate will be
committed — the module must receive the true TSPP operator or none.
