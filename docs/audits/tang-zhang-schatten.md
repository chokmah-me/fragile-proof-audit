# Audit note — Tang–Zhang Schatten-norm constant (Track D#4)

**Claim artifact:** Tang–Zhang conjecture on the dimension-free best constant
in `‖Σ A_k‖_p ≤ c(m) ‖ |Σ |A_k| | ‖_p`.
**Refutation artifact:** Zeng, Liu, Ratnavelu, arXiv:2608.15558, Theorem 1.1.
**Campaign objects:** `docs/blueprint/tang-zhang-schatten.md`,
`scripts/gates/tang_zhang_schatten.py`,
`scripts/controls/tang_zhang_break_control.py`,
`results/tang_zhang_schatten_gate_meta.json`,
`results/tang_zhang_break_control_meta.json`,
`incoming/tang-zhang-2608.15558.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | `C^TZ_{p,m} = √(x(x+m−1)) / (x^p + m − 1)^{1/p}`, with `x > 1` solving `x^p − 2x − (m−1) = 0`, is the best constant for all finite `p > 1` |
| **Instance** | `p = 3/2`, `m = 2` |
| **False instance** | `R = 1.03641365870489… > 207/200 > C^TZ_{3/2,2} = 1.03465395185143…` |

**Verdict: BREAK.** Attack type **A** (scalar gate). The conjectured constant
is exceeded by an explicit rank-one pair.

## What was gated — two independent computation paths

The whole verdict is a numerical inequality between two constants that differ
in the third decimal place, so the question is not discrimination but whether
the arithmetic is right. It is closed twice, by different machinery:

- **Path A — exact rational.** Gram-matrix algebra over `fractions.Fraction`.
  The discriminant is confirmed a perfect square, the unit vectors confirmed
  unit, and the eigenvalues come out as exact rationals
  `λ₁ = 13/8`, `λ₂ = 3/8` (with `σ₁² = 1027/320`, `σ₂² = 3/320`), matching the
  paper's equations (8)–(9).
- **Path B — mpmath direct.** 60-digit direct matrix construction, no rational
  algebra.

The two agree to `1e-40`. The `207/200` rail comes from the paper's own
Remark 2.1 and is used as a threshold both sides must clear, with a safety
floor of `1e-20` — far below the actual margins (`~1.4e-3` above, `~3.5e-4`
below) — so "not noise" is checked rather than assumed.

## Provenance

First Track D target where the corpus doc's text was **unusable**: its formulas
are `![][imageNN]` placeholders. The gate was built by fetching and reading the
real PDF instead. That decision is what later became protocol step 0.

## Control

`scripts/controls/tang_zhang_break_control.py` — **NO FALSE POSITIVE.**

The risk here is different from a search-based gate: not "does it fire on
everything", but "is this witness typical, or did we stumble on the one point
where the formula is violated, i.e. is the formula itself mis-transcribed?"

- **Discrimination:** 5 000 random rank-one pairs at the same `(p, m)`. Only
  ~1% exceed the conjectured constant, and the witness sits near the true
  extremum rather than in the bulk — so the gate is not reporting a violation
  that any input would produce. That some inputs *do* exceed `C^TZ` also rules
  out a vacuous check.
- **Independent corroboration:** the same formula (4) is reduced to
  Tang–Zhang's own **proven** closed forms at `p = 2` — `c₂(m) = √((1+√m)/2)`
  — for several `m`, agreeing to `1e-30`. This validates the implementation of
  the conjectured-constant formula against results independently known to be
  *true*, touching the counterexample not at all.

## Lean

None. Blocked on mathlib coverage: Schatten norms and the dimension-free
constant machinery are not there. Not attempted.

## Not done, on purpose

Did not attempt to determine the *correct* best constant at `p = 3/2`, or to
map the region of `(p, m)` where the conjecture fails. Refuting the route needs
one `(p, m)` and one pair.
