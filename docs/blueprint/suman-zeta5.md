# Blueprint stub — Phase 1(b): Suman ζ(5) refutation-object

**Status:** Phase 0 stub  
**Sources:** arXiv:2407.07121 (claim) · arXiv:2411.16774 (Chen et al.)  
**Attack type:** B

## Claim
ζ(5) and higher odd zetas irrational via Beukers-style integrals + Diophantine induction.

## Load-bearing lemma chain
I_n → Eq. (47)/(48) has **no** integer solutions in stated range → induction → criterion

## Formalizable slice
`IrrationalityCriterion` + n=1 witnesses. Do not claim ζ(5) rational.

## Numeric gate
Exist `a=2b`, `a=b` at n=1 under **Suman’s** k-range (derive before Lean).  
ζ(5)≈1.0369277551… ⇒ a=b ⇒ ζ(5)=1 fails by ~0.037.

## Confirm / break
Break (expected): solutions exist.  
Do **not** copy Claude’s `1 ≤ k ≤ 0` snippet.

## Abort / escalate
If faithful transcription finds no solutions → re-read both papers (transcription error likelier than Chen et al. wrong).

## Fill during Phase 1(b)
- [ ] Quoted Eq. (48) and k-range from Suman
- [ ] Quoted Prop 3.1 from Chen et al.
- [ ] Python gate witnesses
- [ ] Lean witnesses
