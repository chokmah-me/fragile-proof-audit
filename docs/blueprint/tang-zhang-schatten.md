# Blueprint — Track D#4: Tang-Zhang Schatten norm conjecture

**Status:** Numeric gate landed + discrimination control landed, verdict BREAK — no Lean scaffold yet
**Sources:** Tang, Zhang (conjecture, cited but not locally pinned) · refutation: Zeng, Z., Liu, H., Ratnavelu, K. (2026), "A counterexample to the Tang-Zhang Schatten norm conjecture and sharp positive results," arXiv:2608.15558 [math.CO]
**Corpus pointer:** `corpus/live-fragile-proofs-2024-2026.md` (Section 2, "The Tang-Zhang Matrix Bound Collapse")
**Local PDF pinned:** `incoming/tang-zhang-2608.15558.pdf` (sha256 `1e034f10152142de93494aaa26d003f9f15d713817cace7053fcb3ad23ae42ed`), fetched 2026-09-21 via `curl -sL https://arxiv.org/pdf/2608.15558`. **This target's corpus-doc narrative was unusable** — several of its bullets reference numbered inline images (`[63]`, `[64]`, ...) whose numeric content was never transcribed by the AI deep-research export, so the gate is built directly from the pinned PDF, not from the corpus doc.
**Attack type:** A (Scalar-Gate)

## Claim

For `A in M_n(C)`, write `|A| = (A*A)^(1/2)` and `||A||_p = (Tr|A|^p)^(1/p)`.
For `m >= 2` let `c_p(m)` be the dimension-free best constant in

```text
||sum_{k=1}^m A_k||_p <= c_p(m) |||sum_{k=1}^m A_k|||_p
```

Tang and Zhang proved `c_1(m)=1`, `c_2(m)=sqrt((1+sqrt(m))/2)`,
`c_inf(m)=sqrt(m)`, and conjectured a single formula for every finite `p>1`:
letting `x_{p,m} > 1` solve `x^p - 2x - (m-1) = 0`,

```text
C^TZ_{p,m} = sqrt(x_{p,m}(x_{p,m}+m-1)) / (x_{p,m}^p + m-1)^(1/p)
```

## Load-bearing lemma chain

The implicit assumption that the rank-one equiangular-family construction
that attains `C^TZ_{p,m}` as a *lower* bound is also the *supremum* over all
matrix families for every finite `p`, with no discontinuity as `p` crosses
the Hilbertian exponent `p=2` from below.

**Break point:** `p=3/2, m=2` — refuted with two explicit real rank-one
2x2 matrices (Theorem 1.1 of the pinned PDF):

```text
e = (1,0),  u = (39/40, sqrt(79)/40),  v = (5/8, sqrt(39)/8)
A1 = e e^T,  A2 = u v^T
```

giving `||A1+A2||_{3/2} / |||A1|+|A2|||_{3/2} > 207/200 > C^TZ_{3/2,2}`.
The paper separately proves (Theorem 1.2) that the conjectured formula
*is* the sharp rank-one bound for `2 <= p < infinity` — "the failure occurs
inside the rank-one class, but on the opposite side of the Hilbertian
exponent from the natural positive result."

## Numeric gate

`scripts/gates/tang_zhang_schatten.py`

- **Path A (exact rational)**: reproduces the paper's eqs. (7)-(9) using
  `fractions.Fraction` only, never touching an irrational number. The
  Gram matrices `L = U^T U`, `G = V^T V` (`U=(e,u)`, `V=(e,v)`) have
  rational entries because `e = (1,0)` and only `u`'s and `v`'s *first*
  coordinates (`39/40`, `5/8`) and the *squares* of their second
  coordinates (`79/1600`, `39/64`) are needed. The squared singular
  values of `A1+A2` are the eigenvalues of the rational matrix `L @ G`;
  its discriminant is confirmed to be an exact perfect square
  (`(16/5)^2`) before taking its root, giving `1027/320` and `3/320`
  exactly — matching the paper's eq. (8) independently re-derived, not
  copied. `|A1|+|A2|`'s eigenvalues reduce to `1 +/- (e.v) = 13/8, 3/8`
  directly from `e.v = 5/8`.
- **Path B (mpmath, 60 decimal digits)**: builds the actual matrices with
  `sqrt(79)`, `sqrt(39)` at high precision and recomputes singular values
  via the symmetric-2x2 eigenvalue formula on `A^T A`, entirely
  independently of Path A's Gram-matrix algebra.
- The two paths agree to `1e-40`, and both reproduce the paper's
  Remark 2.1 numeric value `R ≈ 1.0364136587048904` to all computed
  digits.
- The conjectured constant `C^TZ_{3/2,2}` is computed independently by
  solving `x^{3/2}-2x-1=0` via `mpmath.findroot` and evaluating formula
  (4) — not copied from the paper's stated `C ≈ 1.0346539518514341`,
  which it reproduces exactly.
- Verdict: **BREAK**, `R > 207/200 > C^TZ_{3/2,2}` with margins
  `~1.4e-3` and `~3.5e-4` respectively (both `>> 1e-20` safety floor).
  Runtime <0.1s (Type A, matches corpus table's "<0.01s" claim in spirit —
  this campaign's version does two independent recomputations, not one).
- Meta: `results/tang_zhang_schatten_gate_meta.json`; registered in
  `scripts/gates/check.py` (`EXPECTED_VERDICT["tang_zhang_schatten"] =
  "BREAK"`).

## Discrimination control

`scripts/controls/tang_zhang_break_control.py` — **required and landed**
(BREAK-verdict, witness-by-construction shape).

Four questions, per `docs/GATE-BEFORE-PROVE.md`:

1. **Transcription fidelity** — gate's bound (`207/200`) and matrix
   coordinates match the **pinned local PDF**, read directly by this
   campaign's PDF tool (not the corpus doc, which is corrupted for this
   target). `ok: True`.
2. **Machinery discrimination** — an independent, from-scratch
   angle-parametrized re-derivation (not Path A's Gram-matrix algebra)
   reproduces the witness's `R` exactly. 5 000 random rank-one pairs at
   the same `(p,m)=(3/2,2)`: only 1.1% exceed `C^TZ` and only 0.8% exceed
   `207/200` — the paper's witness (`R≈1.03641`) sits near the true
   extremum found by random search (`max random R≈1.03641` also, within
   `1e-5`), not a razor-thin artifact of a check that fires on everything.
3. **Algebraic self-consistency** — re-asserts Path A and Path B agreed
   to `1e-40` and that Path A's rational values match the paper's
   eqs. (8)-(9) (delegated, not duplicated).
4. **Independent corroboration** — the *same* conjectured-formula
   implementation (eq. 4), evaluated at `p=2` (a case the paper does
   *not* refute — Theorem 1.2 proves the conjecture holds there),
   reduces exactly to Tang and Zhang's own independently-proven closed
   form `c_2(m) = sqrt((1+sqrt(m))/2)` for `m in {2,3,5,8}`, to 30
   decimal digits. This validates the formula-(4) implementation against
   ground truth unrelated to the counterexample itself.

Verdict: **NO FALSE POSITIVE**.

## Formalizable slice

Not started. No formalizable slice was offered by the corpus doc for this
target (its own suggested Lean statement, `tang_zhang_false`, used the
corrupted narrative's placeholder numbers `3/2` and `207/200` — which,
per the pinned PDF, happen to be correct, a fortunate coincidence not
something this campaign should have trusted blind). Candidate shape,
built from the PDF's actual Theorem 1.1:

```lean
theorem tang_zhang_false :
    ∃ (A B : Matrix (Fin 2) (Fin 2) ℝ),
      A.rank ≤ 1 ∧ B.rank ≤ 1 ∧
      schattenNorm (3/2) (A + B) / schattenNorm (3/2) (|A| + |B|) > 207/200
```

Needs: a Lean/mathlib definition of Schatten `p`-norm for real matrices at
non-integer `p` (likely absent or partial in mathlib v4.32.2 — not
checked), matrix absolute value `|A| = (AᵀA)^(1/2)`, and either `decide`
over the exact-rational eigenvalue computation (Path A above is fully
`Fraction`-representable except the final `x^(3/4)`, `x^(3/2)` power
step, which is genuinely irrational) or a real-analysis argument
bounding those fractional powers. Substantially harder than the other
Track D targets; not attempted.

## Fill checklist

- [x] Numeric gate (`scripts/gates/tang_zhang_schatten.py`, verdict BREAK)
- [x] Registered in `scripts/gates/check.py` with pinned `EXPECTED_VERDICT`
- [x] Discrimination control (`scripts/controls/tang_zhang_break_control.py`, NO FALSE POSITIVE)
- [x] Local PDF pin under `incoming/` for arXiv:2608.15558
- [ ] Lean scaffold (`FragileProofAudit/TangZhangSchatten/`) — likely blocked on mathlib Schatten-norm coverage, not attempted
- [ ] Audit note under `docs/audits/tang-zhang-schatten.md`
