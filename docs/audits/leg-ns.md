# Audit note — LEG-NS Ferreira prime gaps — proof GAP (type G)

**Target:** harvest dossier II, Hit 4 (LEG-NS), claimed proof of
π(x+x^λ)−π(x) ∼ x^λ/log x for 0<λ<1 (hence Legendre's conjecture).
**Paper:** Luan Alberto Ferreira, "Real exponential sums over primes and
prime gaps", arXiv:2307.08725**v4** [math.NT], revised 7 May 2026.
Pinned at `incoming/leg-ns-2307.08725v4.pdf`
(SHA-256 `4af7b9e11350a86aeb5a8d96a59150d7ff40a1edecad9464f7d356ea507f3c64`,
427,451 bytes, 27 pages, extraction clean).
**Date:** 2026-09-23.
**Campaign objects:** `scripts/analysis/leg_ns_contour_probe.py`
(illustration probe, not a gate), `results/leg_ns_meta.json`.

**Dossier discrepancy (recorded, not repaired):** the dossier describes v2
(2025) and names "Theorem 2.18" as the load-bearing estimate. v4's
decisive step is **Proposition 2.18** (analytic continuation); the paper was
read fresh and the dossier's equation numbers were not trusted.

## Claim under test

Theorem 2.19: for 0<λ<1, π(x+x^λ)−π(x) ∼ x^λ/log x. Proposition 4.6 deduces
Legendre's conjecture "for all n sufficiently large" (λ=1/2); Propositions
4.7–4.8 and remarks claim Sierpiński's, Andrica's, Brocard's, Oppermann's.
A proof would be a landmark far beyond current knowledge (even RH gives
only ∼x^{1/2}log x intervals).

## The argument chain (reductions verified correct)

The paper adapts Newman's 10-step PNT proof to a weighted prime sum.
Propositions 2.13 → 2.14 → 2.15 correctly reduce the whole claim to a
single analytic statement:

**Proposition 2.18.** τ(s) − 1/s, with
τ(s) = Σ_p (1−λ)log(p)/(p^λ exp(sp^{1−λ})), initially defined for ℜ(s)>0,
extends analytically to ℜ(s) ≥ 0.

The reductions (Ψ ⟺ Ξ ⟺ τ via positive-real scalings and the entire factor
(e^s−1)/s) were checked and are sound. Everything rides on Prop. 2.18.

## The defect (analytic, not computational)

Prop. 2.18 is proved via the Mellin transform of an auxiliary T(s) and a
contour deformation of the inverse-Mellin integral to
C = {σ(t)+it : σ(t) = −a/(2log(2+|t|))}. Two defects:

**Defect A (decisive — the contour cannot cross the imaginary axis).**
After deformation the paper claims (p. 19, verbatim):

> "Since the integral ∫_C Υ(s,z)dz and its derivative (with respect to s)
> converge absolutely and uniformly for s in any compact subset of the
> half-plane ℜ(s) ≥ 0 … it follows from the differentiation theorem under
> the integration sign that the function … is analytic in an open
> neighborhood of the half-plane ℜ(s) ≥ 0."

This is a non sequitur. Uniform convergence on compact subsets of the
*closed* half-plane yields holomorphicity on its *interior* ({ℜ(s)>0}),
not on an open neighborhood. Holomorphicity at a boundary point
s₀ (ℜ(s₀)=0) requires uniform convergence on a *neighborhood* of s₀,
which necessarily contains points with ℜ(s)<0 — where the integral
*diverges*. Along C, Stirling gives |Γ(σ+it)| ∼ e^{−π|t|/2} while
|s^{−z}| = |s|^{−σ(t)}e^{t·arg(s)}; the product is ∼ exp(t(arg(s)−π/2)):
decay for |arg s|<π/2 (ℜ(s)>0), exact balance for |arg s|=π/2 (ℜ(s)=0),
*exponential growth* for |arg s|>π/2 (ℜ(s)<0). The paper itself concedes
the marginality (p. 19, verbatim):

> "On the critical boundary ℜ(s) = 0, the exponential decay of the Gamma
> function exactly balances the growth of the term s^{−z}."

"Exactly balances" on the boundary means *no room* to cross it — yet the
conclusion drawn is analyticity across it. The probe
`scripts/analysis/leg_ns_contour_probe.py` exhibits the three regimes
numerically (|s^{−z}Γ(z)|/|(z−1)(z−2)| along C: 5.6e−13 at t=160 for
s=0.1+i; 4.7e−06 for s=i; 3.96e+01 and growing for s=−0.1+i). The
O(log|t|) Ω-factor cannot affect the exponential tradeoff.
Newman's analytic theorem *needs* the open-neighborhood extension — its
proof shifts contours into ℜ(s)<0 — so the gap is load-bearing, not
cosmetic. No alternative representation crossing the axis is supplied.

**Defect B (concrete arithmetic error).** In the same proof (p. 17),
from "τ(s) = 3 − exp(−s)/s − (1−λ)d³/ds³M^{−1}[…]" the paper writes
"Subtracting 1/s on either side … τ(s) − 1/s = (exp(−s)−1)/s −
(1−λ)d³/ds³M^{−1}[…]". But 3 − e^{−s}/s − 1/s ≠ (e^{−s}−1)/s (at s=1:
1−1/e vs 1/e−1). The algebra is false as printed.

The author also flags, honestly, that the Newman-style double-series
commutator "I honestly don't know how to work around" (Step 8, p. 13) —
the Mellin detour was meant to bypass it, and it does not.

## Why no finite gate applies

The dossier sketched a numeric check of "the paper's explicit
weighted-sum bound," but v4's load-bearing claims are *asymptotic* (∼)
and *analytic* (continuation to ℜ(s)≥0) — there is no displayed
inequality with explicit constants whose falsity at computable depth
would refute the route. Forcing a numeric gate onto this residue would
test the wrong object. Per the dossier's own warning, this target
downgrades to a prose type-G audit. The probe above is an *illustration*
of the analytic flaw, not a gate.

## Disposition

**Proof GAP (type G) — route refuted, theorem untouched.** Proposition
2.18's proof is invalid: the contour deformation establishes (at best)
continuity up to ℜ(s)=0, not the analytic extension across it that
Newman's theorem requires, and the computation contains a false algebraic
step. Theorem 2.19, Proposition 4.6 (Legendre), and the further
conjectures are therefore unproved by this route.

**Explicitly NOT a BREAK:** no lemma *statement* was falsified — whether
τ(s)−1/s in fact extends analytically is a hard open analytic question,
not settled here. Legendre's conjecture itself is unaffected. The 24/24
verdict lock is untouched.

## Reproduction

1. Fetch arXiv:2307.08725v4; verify the SHA-256 above.
2. Read Prop. 2.18's proof (pp. 15–19); check the two quoted passages
   against the PDF.
3. `python3 scripts/analysis/leg_ns_contour_probe.py` — exhibits the
   decay/marginal/blowup trichotomy along C (needs mpmath).
4. Verify Defect B by hand: 3 − e^{−s}/s − 1/s vs (e^{−s}−1)/s at s=1.
