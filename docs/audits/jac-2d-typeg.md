# Audit note — JAC-2D Yucai Su 2D Jacobian proof — Type-G prose/logical-gap audit: PASS

**Target:** harvest dossier II, Hit JAC-2D, Yucai Su's claimed proof of the
2-dimensional Jacobian conjecture.
**Paper:** Yucai Su, "Generalizations of local bijectivity of Keller maps and
a proof of 2-dimensional Jacobian conjecture", arXiv:1603.01867v43 [math.AG],
revised 11 May 2024 (43 versions, 2016–2024). 55 pages.
**Pin:** `incoming/jac-2d-1603.01867v43.pdf`, 705,302 bytes, SHA-256
`65634fc3a56a8d380b9ecf020e23667f5cb8d798b11ab2c7bfe1df2b83ec4224`
(matches the hash already pinned by `scripts/gates/jac_2d.py`).
**Date:** 2026-09-23. **Scope:** full prose/logical-gap pass (Type G) over the
55-page proof. Not a line-by-line formal verification; not a BREAK attempt.
Prior Type-D/E gates (Remark 2.7 degree replay, Lemma 2.8 / (2.41) bounded CAS
replay) already PASS and are not re-litigated here.

**Verdict: PASS.** No genuine inference defect was found. Several harmless
expository/computational slips were identified; none affects logical validity.
The 2D Jacobian conjecture itself is untouched (gates refute routes, not
theorems).

## Proof skeleton (as written)

Assume a Keller pair σ = (F,G) is not injective. Let
V = {(p₁,p₂) ∈ ℂ⁴ : σ(p₁) = σ(p₂), p₁ ≠ p₂} (nonempty by assumption).

1. **Theorem 1.2** (Section 2, via Lemmas 2.8–2.17 and Proposition 2.15):
   after a polynomial automorphism, |y₁|+|y₂| = o(h) on V as h → ∞,
   where h = |x₁|+|y₁|+|x₂|+|y₂|. The proof is a coefficient-comparison
   induction: assuming ¬(2.78), a divergent collision sequence forces
   y₂,ᵢ/y₁,ᵢ → ω (an m-th root of unity, (2.90)), the rescaled coefficients
   satisfy the algebraic identities of Lemma 2.14, and Lemma 2.17(v) forces
   the refined root ω′ = 1, contradicting x₁,ᵢ ≠ x₂,ᵢ via (2.101).
2. **Theorem 1.3** (Section 2): π₁ : V → ℂ², (p₁,p₂) ↦ (x₁,x₂), is proper
   (Lemma 2.20 + Proposition 2.22, using the o(h) estimate to bound fibers),
   hence finite and surjective.
3. **Section 3**: from Theorem 1.3, A_{k₁,k₂} = {(p₁,p₂) ∈ V :
   |x₁| = k₁, |x₂| = k₂} is a nonempty compact subset of V (3.1).
   Proposition 3.7 builds a **nonempty compact V₀ ⊂ V** (either V₁ from
   (3.16) or V₂ from (3.17)) carrying a continuous function ℓ_{p₁,p₂}
   ((3.25)/(3.26)) with x₁,x₂,x₂+y₂ ≠ 0 on V₀ (3.18). Nonemptiness is Lemma
   3.27; closedness (hence compactness with boundedness from (3.134) and
   Proposition 2.22) is Lemma 3.29.
4. **Proposition 3.12** (proof credited to Procesi): every point of V₀ has
   arbitrarily close points of V₀ with strictly larger ℓ-value, via a local
   holomorphic perturbation using the Keller map's local bijectivity (inverse
   function theorem) plus a two-inequality parameter-choice argument
   ((3.34)–(3.38), Lemma 3.13).
5. **Proof of Theorem 1.1**: (4) says ℓ has no maximum on the nonempty
   compact V₀; the extreme value theorem says a continuous real function on a
   nonempty compact set attains one. Contradiction. Hence σ is injective.

## What was checked and found sound

- **Final assembly (EVT contradiction).** Logically valid given its premises:
  V₀ nonempty compact + ℓ continuous + Proposition 3.12 ⟹ contradiction.
  No defect in the inference itself.
- **Proposition 2.15, Steps 1–4.** Step 1's reduction to the tilde pair
  (F̃,G̃): the key worry — whether the nonvanishing (2.47) survives the
  change of variables φ — goes through, because φ sends the distinguished
  monomials to monomials with nonzero coefficients (the computation at
  (2.53)–(2.58) preserves nonvanishing; the exact scalar is irrelevant).
  Step 2's estimate chain (2.88)–(2.90): the needed consequence
  F₁(x_{k,i},y_{k,i})/y_{1,i}^m → 0 holds since F₁ has total degree ≤ m−1 by
  (2.32)(i) while |y_{1,i}|^m ≥ h^{m²/(m+1)}; the subsequence giving
  y₂,ᵢ/y₁,ᵢ → ω with ω^m = 1 is legitimate. Lemma 2.17(v) (ω′ = 1 from
  c̃_{m−4}c̃_{m−3} ≠ 0 via Lemma 2.9) is sound; the final contradiction (2.101)
  is correctly derived (see harmless slip (c) below on citation precision).
  No FRK-UC-style quantifier upgrade: Lemma 2.8's induction is explicit
  induction on j with the quantifiers stated.
- **Theorem 1.3.** Lemma 2.20's maximal-rank claim is compatible with both
  Keller Jacobians being invertible; Proposition 2.22 converts Proposition
  2.15 into bounded fibers/preimages; properness plus density of the image
  gives surjectivity. Sound.
- **Proposition 3.12 (the engine).** The IFT perturbation step is sound:
  the local inverse gives s = s(ε₁,u,v) holomorphic in all parameters, with
  homogeneous-polynomial coefficients in (u,v); uniformity of ε₁ over the
  compact parameter set is fine; (a,b) ≠ (0,0) follows from invertibility of
  Dσ. The Case-2 two-inequality argument ((3.34)–(3.38), Lemma 3.13) was
  re-derived: the "linearly independent" subcase is immediate; the
  "dependent" subcase's reduction to one complex parameter w, the killing of
  the *complex* linear forms (which is what makes (3.38) exact — the
  potentially missing nonnegative terms vanish because c₁ = 0 ∈ ℂ, not just
  Re = 0), and Lemma 3.13's arclength ≥ π+δ argument are all correct.
  One genuine computational omission was found in (3.37) — see (d) below —
  and it is harmless (the omitted term is nonnegative, so the paper's choice
  of w still works).
- **Appendix C (Bin Xu's Proposition C.1).** Sound as written (the (C2) →
  "φ₁,φ₂ constant" inference is correct for entire functions, and the
  argument works component-wise so "V is connected" is unnecessary). It
  assumes the stronger (C4)′, so it does not apply to the actual proof; it
  is motivation only.

## Harmless slips (genuine, but not proof-breaking)

(a) **(2.58): factor-of-3 scalar error.** The computation at (2.55) gives
    c̄_{(−m̄+4)/m̄} = −J₀/m (with m̄ = 3m), but (2.58) prints −J₀/m̄. Only
    nonvanishing is ever used (to keep (2.47)), so nothing downstream is
    affected.
(b) **(2.88)(i): ≺ vs O.** "F₁(x_{k,i},y_{k,i}) ≺ᵢ h^{m−1}" is too strong as
    stated (F₁ = O(h^{m−1}) since deg F₁ ≤ m−1); but the inference that
    matters, F₁/|y_{1,i}|^m → 0, follows from |y_{1,i}|^m ≥ h^{m²/(m+1)} and
    is what (2.88)(ii)/(2.89) use. Notational, not logical.
(c) **(2.101)/Remark 2.18: imprecise citation.** The fifth equality in
    (2.101) is justified in text by "Lemma 2.17(iv)", but Lemma 2.17(iv)
    only gives the vanishing order of the left side; the needed *equality
    of leading coefficients* follows from the majorant estimate and the
    smallness of t_P (Lemma 2.14), i.e. the two sides genuinely agree to
    leading order. The asserted identity is true; the citation is sloppy.
(d) **(3.37): omitted nonnegative term.** The E₁²-coefficient A(w) of E₂
    omits κ′₁·((A₁w)_{im})²/2 ≥ 0 coming from the |1+g| expansion (with
    A₁ = −(1+κ′₂(β/α))/κ′₁, generally nonzero). Since the omitted term is
    nonnegative, A_true ≥ A_paper, and Lemma 3.13's positivity set only
    grows; the w chosen by the paper still yields E₂ > 0. Harmless.
(e) **Stale strategy description.** The Section 3 introduction (p. 22) says
    the section will "prove that the projection π₁ … is in fact not
    surjective (which contradicts Theorem 1.3 …)". The actual Proof of
    Theorem 1.1 instead derives an extreme-value-theorem contradiction from
    V₀/ℓ/Proposition 3.12; Theorem 1.3 is *used* (A_{k₁,k₂} ≠ ∅), not
    contradicted. Expository staleness, not a logical defect — the proof as
    written is complete and self-contained.
(f) Minor: Proposition 2.22's s₈ needs s₈ ≥ 1 for the stated bound (true for
    the intended choice); Lemma 3.27's "we choose (q₁,q₂) ∈ V₀ … Hence the
    'initial stage' (q₁,q₂) ∈ V₀" is circular as printed but reads as a typo
    for (q₁,q₂) ∈ V, with membership in V₀ established by the ensuing
    inequalities.

## Scope and limits

This is a prose/logical-gap audit, not a formal verification. The main
logical chain, the decisive estimates, and the perturbation engine were
re-derived by hand; the long V₀ parameter-case analysis of Proposition 3.7
(Lemmas 3.27–3.29) was read for structural soundness but its routine
inequality bookkeeping was not exhaustively re-derived. No defect of any
kind — genuine or cosmetic — was found in the decisive inferences. The
acknowledgements record that Claudio Procesi independently scrutinized every
detail and supplied the proofs of Theorem 1.3 and Proposition 3.12, which is
consistent with, but not a substitute for, this audit's findings.

## Distinguishing GAP from BREAK

No lemma statement was falsified and no computation refutes the route; per
standing doctrine this is not BREAK in any case. It is not GAP either: a
GAP requires a genuine inference defect, and none was established. The
(a)–(f) items above are repairable wording/arithmetic slips that do not
disturb any inference.

**Theorem untouched.** This audit concerns only Yucai Su's *proof route*;
the 2D Jacobian conjecture as a theorem is not adjudicated here.
