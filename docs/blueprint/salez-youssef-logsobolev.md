# Salez-Youssef Log-Sobolev Conjecture — gated, verdict BREAK

**Target Identifier (corpus doc):** Salez-Youssef Log-Sobolev Conjecture,
2025 Refutation, arXiv:2504.08055
**Verdict: BREAK** (Track D#8)

## Provenance check (this session's standing lesson)

Chung-Graham-Spiro's corpus entry was a ghost (no body section at all) and
NCI's corpus entry claimed a "Verifiable Gate" that does not exist in the
real paper (see `docs/blueprint/nci-conjecture.md`). Before trusting this
entry's description, fetched the real paper directly: Florentin Münch, "A
counterexample to a conjecture by Salez and Youssef," arXiv:2504.08055v1
(10 Apr 2025, Leipzig University), confirmed live via WebFetch abstract
check, then downloaded (`incoming/salez-youssef-munch-2504.08055.pdf`). This
time the corpus doc's description held up closely against the real text —
unlike the last four targets, no fetch-and-correct was needed beyond
confirming the details.

## The conjecture

Salez and Youssef (arXiv:2503.02793, Conjecture 1) proved
`α_LSI ≥ K/(33 log d)` when a reversible Markov chain has **Bakry-Émery**
curvature bounded below by `K > 0` (Theorem 1.1 in Münch's paper), and asked
whether the same shape of bound holds with the more practical **Ollivier**
curvature substituted in: does `κ(x,y) ≥ K` for all neighbors `x,y` imply
`α_LSI ≥ c·K/log(d)` for some *universal* constant `c`, where `d = max{1/p(x,y)
: p(x,y)>0}` is the sparsity parameter?

## The refutation (Münch, Section 2)

An explicit family of lazy birth-death chains on `{1,...,3n}`:

```
4p(k,k+1) = 1/n^2                (1 <= k <= n)
            1 - 1/n - k/n^2      (n < k <= 3n-1)
4p(k,k-1) = 1/n + (k+1)/n^2      (2 <= k <= n)
            1                    (n < k <= 3n)
```

with `p(1,0) = p(3n,3n+1) = 0` by boundary convention. Münch shows exactly:

- Ollivier curvature `κ(k,k+1) = p(k,k+1) - p(k,k-1) - p(k+1,k+2) + p(k+1,k)
  ≥ 1/(4n²)` for every edge (equality at the interior edges).
- Sparsity `d = 4n²`.
- Via the isocapacitary characterization (his Theorem 2.1, citing
  Schlichting-Slowik 2019: `c·α_LSI ≤ inf_{π(A)≥1/2} cap(A,B)/(π(B)|log π(B)|)
  ≤ C·α_LSI`), taking `A={1}`, `B={2n,...,3n}` gives an explicit upper bound
  on `α_LSI` that decays like `1/(n³ log n)` — **one extra factor of `1/n`**
  faster than `K/log(d) ~ 1/(n² log n)`.
- Consequently `α_LSI / [K/log(d)] → 0` as `n → ∞`: no fixed constant `c`
  can survive, so Conjecture 1.2 is false.

## What the gate reproduces

`scripts/gates/salez_youssef_logsobolev.py`:

1. **Exact curvature.** Builds the chain with `fractions.Fraction`
   transition probabilities for `n ∈ {4, 10, 30, 100, 300, 1000, 3000}` and
   confirms `min_k κ(k,k+1) == 1/(4n²)` by **exact rational equality**, not
   a numeric approximation — the paper's curvature bound is tight, and the
   gate checks the tight value, not just `≥`.
2. **High-precision stationary distribution.** Detailed-balance ratios
   `π(k)/π(k+1)` are exact rationals, but their cumulative products span
   thousands of orders of magnitude (`π({2n,...,3n})` is `~10^{-3170}` at
   `n=1000` and `~10^{-10937}` at `n=3000` — far outside float64 range).
   Computed with `mpmath` at 80 decimal digits of working precision, which
   represents these magnitudes exactly (mpmath floats carry an
   arbitrary-size exponent, unlike IEEE 754 doubles).
3. **Capacity.** `cap({1},{2n,...,3n})` via the birth-death effective-
   resistance identity `1/cap = Σ_{k=1}^{2n-1} 1/(π(k)p(k,k+1))`, same
   precision.
4. **The actual asymptotic mechanism, not a snapshot.** Computes
   `R(n) := cap/(π(B)|log π(B)|)` and `K/log(d)` at each `n` and confirms
   the ratio `R(n)/[K/log(d)]` is **strictly decreasing across all seven
   tested `n`** (2.90 → 1.73 → 0.66 → 0.21 → 0.069 → 0.021 → 0.0068) and
   drops below `0.01` at `n=3000` — the actual content of "no constant `c`
   survives `n → ∞`," reproduced computationally across three orders of
   magnitude in `n`, not asserted from the paper's asymptotic notation.

This does **not** compute `α_LSI` itself (an exact log-Sobolev infimum over
all functions on a `3n`-state chain is not tractable on a laptop); it
reproduces Münch's own two-sided argument (the capacitary upper bound versus
`K/log d`) exactly, which is what the falsification actually rests on.

## Discrimination control — verdict NO FALSE POSITIVE

`scripts/controls/salez_youssef_break_control.py`:

1. **Transcription fidelity** — ten spot-checks of the gate's `p_up`/`p_down`
   formulas against the pinned PDF's Section 2 display equations (both
   branches of each, both boundary conventions, and the detailed-balance
   ratio formula `π(k)/π(k+1) = n+k+2` stated on p.6) — all match.
2. **Discrimination.** The paper itself names a case where the conjecture
   is known to hold (Section 2, second bullet): *"If the invariant measure
   is log-concave, then a lower Ollivier curvature bound `K` implies a lower
   Bakry-Émery curvature bound `K/2` [9, Theorem 3] and the conjecture
   follows from Theorem 1.1."* Built exactly such a chain — a symmetric,
   linearly-drifting birth-death walk with **constant** positive curvature
   and a discrete-Gaussian (log-concave) invariant measure — and ran the
   *same* `R(n)/[K/log d]` diagnostic on it. Result: the ratio **grows**
   with `n` (6.9 → 12.5 → 23.4 → 41.0 → 75.2 → 130.7 at `n=10..3000`) and
   stays comfortably above `1` throughout, the opposite trend from the BREAK
   instance. If the diagnostic had instead shown a vanishing ratio here too,
   it would mean the machinery "refutes" a case the source paper itself
   says satisfies the conjecture — a genuine false positive. It does not.

## Verdict

**BREAK.** Registered in `scripts/gates/check.py`; verdict lock now 15/15.

**Local PDF pinned:** `incoming/salez-youssef-munch-2504.08055.pdf`, fetched
from arXiv, live-checked via WebFetch before download.

**Formalizable slice:** none attempted. The corpus doc's own ranking table
already correctly flagged this as "Formalization Tractability: Low (Optimal
Transport)" — Ollivier curvature, capacitary/isocapacitary characterizations,
and log-Sobolev constants have no mathlib coverage. Not pursued.
