# Lean 4 Attack Harvest: Fragile Proofs Worth Formalizing

**Compiled: 2026-09-18 | For: Chokmah LLC (D. Y. Bilar)**
**Reference campaign: Sun Catalan (arXiv:2609.04176) → Zenodo 22830611**

---

## Methodology Note

The Sun campaign proved a specific attack pattern: formalize structural scaffolding in Lean 4, isolate a scalar gate, compute it numerically, confirm or break the proof. That pattern—call it **scalar-gate refutation**—is one of several. This harvest casts the net wider across distinct proof architectures:

| Attack type | What you formalize | What you compute | What breaks |
|---|---|---|---|
| **A. Scalar-gate** (Sun model) | Inequality chain scaffolding | Final bound at concrete parameters | Sign of a computable quantity |
| **B. Base-case kill** | Induction framework | Base case value | Existence of integer solutions the proof denies |
| **C. WZ-certificate audit** | Claimed WZ pair (F,G) | Telescoping identity F(n+1,k)−F(n,k) = G(n,k+1)−G(n,k) | Certificate fails to satisfy the recurrence |
| **D. Finite q-expansion check** | Modular identity up to Sturm bound | q-series coefficients to required precision | Coefficient mismatch below the valence bound |
| **E. CAS-transcript replay** | Paper's claimed computer algebra output | Re-run the computation independently | Output differs from what paper asserts |
| **F. Counterexample search** | Statement as a decidable predicate | Evaluate at small parameter values | Find n where claimed ∀n property fails |
| **G. Logical-gap exposure** | Proof's logical flow | Nothing; the formalization attempt itself surfaces unstated hypotheses | A `sorry` that cannot be filled |

---

## Ranked Candidates (low-hanging first)

### ══════════════════════════════════════════
### TIER 1 — High yield, ≤2 weeks each
### ══════════════════════════════════════════

---

### 1. Reed's "Formal Proof of the Irrationality of γ" (Zenodo 19612531, Apr 2026)

**Attack type: B (base-case kill) + G (logical-gap exposure)**

**The claim.** The Euler-Mascheroni constant γ ≈ 0.5772 is irrational. This has been open for 250+ years; Hilbert mentioned it before his 23 problems.

**The paper.** Jonathan Reed, Zenodo, April 2026. Includes a 7.7 kB Lean file (`Proof_Of_Euler-Mascheroni_Constant_Irrationality.lean`). Claims to leverage Sondow's series representation and derive 0 < Z < 1 for an integer Z, contradiction.

**Why it's fragile (fragility: 10/10).** The irrationality of γ is a famously hard open problem. Sondow's own criteria (arXiv:math/0209070) are *necessary and sufficient conditions*—they don't prove γ irrational, they characterize what would be needed. Any "proof" that converts Sondow's framework into a closed irrationality result in 7.7 kB of Lean is almost certainly hiding a gap. The paper is self-published on Zenodo with no peer review.

**The Lean attack.** Download the Lean file. Run `lake build`. Catalog every `sorry`, `axiom`, `Decidable.decide`, or custom axiom. The proof will either:
- Fail to build (trivial refutation)
- Build but smuggle in an unproved axiom equivalent to γ ∈ ℝ \ ℚ (circular)
- Build but have a `sorry` at the load-bearing step (the "0 < Z < 1" derivation)

**Gate.** If the Lean file compiles with zero `sorry` and no smuggled axioms, and the statement actually says `Irrational Real.eulMascheroniConst`, that would be the most important Lean proof in history. (It won't.)

**Effort: 1–2 days.** Download, build, audit. Writeup is a short note.

**Consequence: Very high pedagogically.** Demonstrates how "AI-generated formal proofs" can look complete while being vacuous—a Chokmah-relevant theme.

---

### 2. Suman's ζ(5) Irrationality (arXiv:2407.07121, withdrawn v7)

**Attack type: B (base-case kill)**

**The claim.** ζ(5) and all higher odd zeta values are irrational.

**The refutation.** Chen, He, He, Huang, Li, Tang, Wu, Xu, Yang & Yu (arXiv:2411.16774v2) show definitively: at n=1, the Diophantine equation (Suman's Eq. 48) admits integer solutions a=2b and a=b. The induction base case is false.

**The Lean attack.** Formalize the base case as a decidable proposition:
```lean
-- Suman's Eq 48 at n=1: does d₁·a − 2·d₁·b = −k·b have integer solutions
-- with d₁ | k·b and 1 ≤ k ≤ d₁ − 1?
-- d₁ = LCM(1,...,1) = 1
example : ∃ a b : ℤ, ∃ k : ℤ, 1 ≤ k ∧ k ≤ 0 ∧ a - 2*b = -k*b := by decide
```
The counterexample (a=2, b=1, k=0 or similar small values) is `decide`-level. Then formalize the refutation paper's Proposition 3.1 (standard irrationality criterion) to show Suman's method doesn't meet it.

**Effort: 2–3 days.** The base-case check is trivial; the pedagogical wrapper (formalizing the standard irrationality criterion and showing Suman's argument doesn't satisfy it) takes a couple more days.

**Consequence: Moderate.** Validates the base-case-kill methodology. Produces a reusable `IrrationalityCriterion` Lean module.

---

### 3. Kim's ζ(5) Irrationality (arXiv:1105.0730)

**Attack type: F (counterexample search) + G (logical-gap exposure)**

**The claim.** ζ(5) is irrational, via Dirichlet's approximation theorem and PNT.

**The refutation.** Wadim Zudilin (May 2011, per OEIS): the WLOG step on p.6 after eq. (3.3) "can be shown to work only for a finite set of n_k's; as the n_k are sufficiently large (and N is fixed), the inequality for ε is false."

**The Lean attack.** Formalize Kim's ε-inequality as a function of n_k and N. Show that for fixed N, there exists n_k₀ such that for all n_k > n_k₀, the inequality fails. This is an asymptotic argument formalizable with Mathlib's `Filter.Tendsto` and `Asymptotics`.

**Gate.** Compute the inequality at n_k = 10, 100, 1000 with N=1. If the inequality flips sign, that's the counterexample.

**Effort: 3–5 days.** Requires reading Kim's paper carefully and extracting the exact inequality.

---

### 4. Jana–Karmakar WZ-Pair Hypergeometric Sums (arXiv:2501.10109)

**Attack type: C (WZ-certificate audit)**

**The claim.** Theorems 1.1 and 1.2 generalize earlier hypergeometric sum identities related to Guo's supercongruence conjectures.

**Why it's fragile (fragility: 7/10).** The Pith AI review (reviewed 2025-01-17) states bluntly: "the WZ-pair proof has a **demonstrably false ratio formula**." The proof rests on a WZ pair (F,G) satisfying a telescoping identity. If the ratio formula is wrong, the certificate is invalid and the theorems are unproved.

**The Lean attack.** This is a *different* proof architecture from Sun:
1. Formalize the claimed WZ pair (F, G) as explicit rational functions of (n, k).
2. Verify the telescoping identity: F(n+1,k) − F(n,k) = G(n,k+1) − G(n,k).
3. This is a polynomial identity—checkable by `ring` or `norm_num` in Lean/Mathlib.

**Gate.** Evaluate both sides at (n,k) = (1,1), (2,3), etc. If they disagree, the WZ pair is bogus.

**Effort: 3–5 days.** WZ certificates are explicit rational functions; the verification is mechanical.

**Consequence: High methodologically.** Establishes a reusable `WZCertificate` verification module in Lean. WZ certificates are the workhorse of modern combinatorial identity proofs; having a Lean verifier for them is infrastructure.

---

### 5. Sun's 150+ Conjectured Series Identities (arXiv:2603.29973)

**Attack type: D (finite q-expansion check) + E (CAS-transcript replay)**

**The claim.** Over 150 infinite series identities involving binomial sums, harmonic numbers, and closed forms in π, ζ, L-values.

**Why it's fragile (fragility: 5/10 individually, but volume matters).** The Pith review: "the paper does not report the precision, the number of terms, or the verification procedure" and "Conjecture 5.25 is self-contradictory as printed." These are *conjectures*, not claimed proofs, but many could be verified or refuted computationally.

**The Lean attack.** Pick the 10 identities with the simplest structure (low-order hypergeometric sums). For each:
1. Compute the partial sum to 1000 terms in `mpmath` (Python) at 500-digit precision.
2. Compare with the claimed closed form.
3. For any that disagree, formalize the disagreement as a numerical bound in Lean using `norm_num` or interval arithmetic.
4. For the self-contradictory Conjecture 5.25, formalize the contradiction directly.

**Effort: 1 week for a batch of 10–20.** High throughput; each identity is independent.

**Consequence: Moderate.** Sun is a prolific conjecturer (see also arXiv:2506.01870 with 26 more); systematic verification/refutation of his output is a public good.

---

### ══════════════════════════════════════════
### TIER 2 — Substantial but higher-effort, 2–4 weeks each
### ══════════════════════════════════════════

---

### 6. Partition Diamond Congruences (arXiv:2503.00004)

**Attack type: E (CAS-transcript replay) + D (finite q-expansion check)**

**The claim.** PDN1(n) ≡ 0 (mod 5^α) and (mod 7^α) for all α, on specific arithmetic progressions.

**Why it's fragile.** Pith review: "the proof leans on unverified computer algebra; referee should demand a certificate." The load-bearing premise: "huge modular equations (3.13) and (4.8), and the base cases of the inductive lemmas, are exactly correct as produced by zero-recognition computer verification." The Sturm bound checks are finite—if the CAS got a coefficient wrong, the whole induction collapses.

**The Lean attack.**
1. Reproduce the modular equations (3.13) and (4.8) independently in SageMath or Magma.
2. Verify the Sturm-bound q-expansion checks to the required precision.
3. If any coefficient disagrees, that's a refutation. If all agree, formalize the Sturm bound argument in Lean (Mathlib has `ModularForm` basics).

**Gate.** The modular equations are polynomial relations among eta-quotients. Evaluate both sides as q-series to 200+ terms.

**Effort: 2–3 weeks.** The modular equations are large but explicit.

---

### 7. Generalized Cubic Partition Congruences mod 5 (arXiv:2508.05833)

**Attack type: E (CAS-transcript replay)**

**The claim.** Infinite families of congruences for a(n) mod 5^α via the localization method.

**Why it's fragile.** Pith review: "the load-bearing premise is the finite computer algebra verification in Theorem 6.3 that the two displayed polynomials (16) and (17) lie in the ideal generated by the two congruences defining [the space] modulo 5; if that reduction is wrong, the induction proving Theorem 4.3 fails."

**The Lean attack.** Same architecture as #6: replay the polynomial ideal membership check independently.

**Effort: 2 weeks.**

---

### 8. Rogers-Ramanujan Framework: Point-Count Modularity (arXiv:2608.05480 + 2608.15219)

**Attack type: D (finite q-expansion check) + E (CAS-transcript replay)**

**The claims.**
- 2608.05480: "the advertised point-count modularity claim rests on an unpublished identity" (Pith review)
- 2608.15219: "The b=8 proof depends on computer algebra transcript [from qMultiSum]; the paper argues the outputs are verifiable, but the verification shown is itself from the same CAS"

**Why they're fragile.** Both papers are honest about their dependencies—an unpublished identity in one, and CAS output verified only by the same CAS in the other. The q-series identities they claim are individually checkable.

**The Lean attack.**
1. For 2608.05480: formalize the q-series identity Z_{3,b} = P_{3,b} by direct computation of both sides to sufficient precision. If the unpublished identity (5) is wrong, the q-series will disagree.
2. For 2608.15219: reproduce the OreReduce identity (34) independently. This is a polynomial identity in a q-commutative algebra; SageMath's `OreAlgebra` or a Lean `MvPolynomial` formalization can check it.

**Effort: 3–4 weeks total for both.**

---

### 9. Partition Function and Elliptic Curves (arXiv:2508.09608)

**Attack type: D + G (the paper itself reports Lean formalization)**

**The claim.** p(n) as a trace over CM points on X₀(1), reducing mod nonsplit primes to a supersingular trace formula explaining Ramanujan's congruences.

**Why it's interesting.** The paper states: "The author made many mistakes unwinding these calculations by hand in August 2025" and used Lean (AxiomProver) to verify the two new algebraic identities. The Pith review flags 4 major objections. The Lean formalization is partial—the paper's own admission of hand-calculation errors makes the *unformalised* parts the attack surface.

**The Lean attack.** Identify which identities are Lean-verified and which aren't. Formalize the unverified ones. The weight-2 specialization (eq. 16) and the symmetry reduction (eq. 18) are the critical ones—if they're already Lean-checked, the remaining attack surface is the global argument connecting them.

**Effort: 2–3 weeks.**

---

### 10. Shifted Quotient of Partition Function (arXiv:2412.02257)

**Attack type: F (counterexample search)**

**The claim.** Arbitrary-order asymptotic expansion for p(n+k)/p(n) with explicit error bounds.

**Why it's fragile.** Pith review: "A separate numerical slip appears in the bound |g(1)| ≤ 6·10⁻² used in (5.19) and (5.22): Definitions 4.6–4.7 give g(1) = √6/(2π) + π/(24√6) ≈ 0.44." That's 0.44 vs. the claimed 0.06—off by a factor of 7. If the bound propagates, the error terms in the main theorem are wrong.

**The Lean attack.** Compute g(1) from its definition. If it's ≈ 0.44 and the paper claims ≤ 0.06, formalize the correct value using `norm_num` with exact rationals. Then trace whether the wrong bound infects the main theorem's error term.

**Gate.** g(1) = √6/(2π) + π/(24√6). Compute both terms. This is a 2-minute calculation.

**Effort: 3–5 days for the numerical check, 1–2 weeks to trace the downstream impact.**

---

### ══════════════════════════════════════════
### TIER 3 — Infrastructure-building (correct proofs to formalize)
### ══════════════════════════════════════════

---

### 11. Lai–Lupu–Sprang p-adic Zeta Irrationality (arXiv:2505.23088)

**Attack type: Build Lean infrastructure**

Apéry-style proof with genuine load-bearing lemmas. Formalize Lemma 5.1 (integrality) and Lemma 5.4 (floor-function inequality) to build reusable Lean modules for:
- Shifted Legendre polynomials
- p-adic valuation layers (`padicValNat`)
- Hermite-Padé approximation scaffolding

### 12. Liu–Zhang–Zhi ζ(3) Formalization (arXiv:2503.07625)

Already formalized (Beukers' method, shifted Legendre polynomials, PNT with error term). **Base to build on** for all Apéry-family attacks. Study their architecture.

### 13. Jacobian Conjecture Counterexample Verification

Already done by multiple groups (Isabelle/HOL in AFP, independent Lean 4 on Zenodo 21514514). **Methodology reference** for the "finite algebraic verification" pattern: formalize a polynomial map, check determinant and collision by `ring`/`norm_num`. Relevant architecture for any future counterexample verification.

---

### ══════════════════════════════════════════
### TIER 4 — Monitor but don't attack yet
### ══════════════════════════════════════════

---

### 14. Collatz "Proofs" (multiple, math.GM)

At least 5 claimed proofs on arXiv in 2025–2026 (Wey 2309.09991v3, Nwankpa on Preprints.org, Sato on ResearchGate, Mori via operator theory, plus the human-LLM collaboration paper 2603.11066). All are certainly wrong; none has a clean scalar gate. Not worth formalizing individually—the errors are diffuse rather than localized.

### 15. Goldbach "Proofs" (Watanabe 1811.02415, South 2206.01179v12, various)

Same situation as Collatz. The load-bearing steps are asymptotic lower bounds with hand-waved uniformity. No clean Lean gate.

### 16. Mochizuki IUT / abc

Maximum consequence, zero Lean tractability. The disputed step (Corollary 3.12) is not a formalizable quantity. Monitor Joshi's "Final Report" (arXiv:2505.10568) for developments.

### 17. Beal's Conjecture "Proof" (Preprints.org 202501.1436)

Binomial expansion argument; almost certainly trivially wrong but not worth the effort of formalizing the trivial error.

---

## Recommended Campaign Order

```
Week 1:     #1 (Reed γ, 1-2 days) → #2 (Suman ζ(5), 2-3 days)
            Quick wins, validate methodology
            
Week 2:     #4 (WZ certificate, 3-5 days) → #10 (partition quotient, 3-5 days)
            Different attack types: WZ audit + numerical slip

Week 3-4:   #5 (Sun conjectures batch, 1 week)
            High throughput, many independent checks
            
Week 4-5:   #3 (Kim ζ(5), 3-5 days) → #6 (partition diamonds, 2 weeks start)
            Asymptotic-inequality kill + CAS replay

Week 6+:    #8 or #9 (Rogers-Ramanujan or partition/elliptic curves)
            Deeper formalization
```

## Reusable Lean Infrastructure Produced

Each campaign yields modules that lower the cost of the next:

1. **Reed audit** → `AxiomAudit.lean` (tool for checking smuggled axioms in "formal proofs")
2. **Suman/Kim** → `IrrationalityCriterion.lean` (standard Apéry-style criterion)
3. **WZ certificate** → `WZVerify.lean` (mechanical WZ-pair checker)
4. **Sun conjectures** → `HypergeometricEval.lean` (high-precision series evaluation + comparison)
5. **Partition congruences** → `SturmBound.lean` (modular form q-expansion verification)
6. **Partition quotient** → `IntervalArithmetic.lean` extensions (certified real-number bounds)
