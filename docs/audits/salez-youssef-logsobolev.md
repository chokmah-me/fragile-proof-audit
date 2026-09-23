# Audit note — Salez–Youssef log-Sobolev conjecture (Track D#8)

**Claim artifact:** Salez–Youssef, Conjecture 1 of arXiv:2503.02793 (cited as
Conjecture 1.2): a reversible Markov chain with Ollivier curvature bounded
below by `K > 0` satisfies `α_LSI ≥ c·K/log d` for a **universal** constant
`c > 0`, where `d = max{1/p(x,y) : p(x,y) > 0}`.
**Refutation artifact:** Münch, F., arXiv:2504.08055, Section 2.
**Campaign objects:** `docs/blueprint/salez-youssef-logsobolev.md`,
`scripts/gates/salez_youssef_logsobolev.py`,
`scripts/controls/salez_youssef_break_control.py`,
`results/salez_youssef_gate_meta.json`,
`results/salez_youssef_break_control_meta.json`,
`incoming/salez-youssef-munch-2504.08055.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | `α_LSI ≥ c·K/log d` for a universal `c`, on Münch's birth-death family |
| **Instance** | Birth-death chains on `{1,…,3n}`, `n = 4, 10, 30, 100, 300, 1000, 3000` |
| **False instance** | At `n = 3000`: `κ = 1/(4n²)` exactly, and `R(n)/[K/log d]` has fallen below `0.01` and is still shrinking — no fixed `c` survives `n → ∞` |

**Verdict: BREAK.** Attack type **A** (scalar gate - a best constant
claimed universal is not).

## The mechanism, and what the gate does not claim

Münch's chains have Ollivier curvature `κ ≥ 1/(4n²)` everywhere and sparsity
`d = 4n²`, so `K/log d ~ 1/(n² log n)`. But the capacitary upper bound
(Theorem 2.1: `α_LSI ≤ C·cap(A,B)/(π(B)|log π(B)|)` for any `A, B` with
`π(A) ≥ ½`), evaluated at `A = {1}`, `B = {2n,…,3n}`, decays like
`1/(n³ log n)` — **one full power of `n` faster.**

The gate does **not** compute `α_LSI`. An exact log-Sobolev infimum over all
functions is not tractable, and pretending otherwise would be the interesting
kind of lie. It reproduces the paper's own two-sided argument exactly: the
capacitary upper bound against the exact curvature/sparsity ratio. That is what
falsifies a fixed-constant claim.

Nor is it a snapshot. A single large `n` would prove nothing about a universal
constant — any one ratio can be absorbed into `c`. The gate requires the ratio
to be **strictly decreasing across seven `n` spanning three orders of
magnitude**, which is the actual asymptotic mechanism.

## What was gated

- Transition probabilities as exact `fractions.Fraction`.
- Stationary distribution and capacity in 80-digit `mpmath`. This is not
  fastidiousness: at `n = 3000` the unnormalised weights span roughly `1e-10937`,
  far outside float64. Ordinary floats silently return zero here.
- **Curvature checked with exact rational equality**, not approximation:
  `min κ == 1/(4n²)` exactly at every `n` tested. (It is met with equality, not
  merely bounded below — the edges away from the boundary all give exactly
  `1/(4n²)`.)
- `π(1) > ½` at every `n`, which is the hypothesis Theorem 2.1 needs for
  `A = {1}` — without it the capacitary bound does not apply at all.

## Provenance

One of only **two** corpus-doc sections in Track D whose description held up
against the real paper (Cohen is the other). It was still fetched and read
first, per the lesson the preceding four targets had just taught: a corpus
entry looking complete is not evidence that it is accurate. That turned out to
be the right call generally, even though this particular entry was fine.

## Control

`scripts/controls/salez_youssef_break_control.py` — **NO FALSE POSITIVE.**
Written in the same minute as the gate, it originally had two of the campaign's
four check categories; the other two were added in the 2026-09-21 re-audit.

1. **Transcription:** ten spot-checks of the chain's transition formulas
   against the pinned PDF's Section 2, including the boundary conventions
   `p(1,0) = p(3n,3n+1) = 0`.
2. **Discrimination:** the sharpest check here. The paper *itself* names a case
   that satisfies the conjecture — a log-concave invariant measure, where a
   lower Ollivier bound `K` implies a Bakry–Émery bound `K/2` and Theorem 1.1
   applies. The gate builds exactly such a chain (constant curvature,
   discrete-Gaussian invariant measure) and the **same** ratio diagnostic is
   run on it. It must not vanish — and it does not: the ratio *grows* with `n`
   and stays above 1 throughout. So the machinery discriminates rather than
   reporting a violation for any chain handed to it.
3. **Algebraic self-consistency:** the exactness of the curvature identity and
   the `π(1) > ½` hypothesis, read from the gate's own receipt.
4. **Independent corroboration:** the paper's closed-form stationary ratio
   `π(k)/π(k+1) = n+k+2` for `1 ≤ k ≤ n−1`, reproduced to better than `1e-79`
   at four values of `n`. This is derived from the transition rates alone and
   shares nothing with the capacity machinery, so it checks the chain itself
   rather than the diagnostic applied to it.

## Lean

None, and none is coming soon. mathlib has no Ollivier curvature, no
isocapacitary inequalities, and no log-Sobolev constants. The corpus doc's own
ranking table correctly flagged this target as low tractability — one of the
few things in that file that held up.

## Not done, on purpose

Did not compute `α_LSI` (see above). Did not attempt to find the correct
`n`-dependence of the best constant, or to determine whether a `log d`-free
form of the conjecture might survive.
