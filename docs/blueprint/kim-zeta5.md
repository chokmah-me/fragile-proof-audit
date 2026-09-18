# Blueprint stub — Phase 1(c): Kim ζ(5) companion

**Status:** Phase 0 stub  
**Source:** arXiv:1105.0730 · Zudilin pinpoint via OEIS A013663  
**Attack types:** F + G

## Claim
ζ(5) irrational via Dirichlet approximation + PNT.

## Load-bearing lemma chain
Approximations → ε-inequality after eq. (3.3) for n_k at fixed N → contradiction for large n_k

## Formalizable slice
ε-inequality; `Filter.Tendsto` or finite-threshold kill of the universal claim.

## Numeric gate
Sign at n_k ∈ {10, 100, 1000}, N=1.

## Confirm / break
Break (expected): fails for large n_k.  
If gate holds → re-extract formula before claiming survival.

## Abort / escalate
If Tendsto blocked by missing mathlib lemmas → ship numeric gate + English pinpoint; mark Lean `blocked`.

## Fill during Phase 1(c)
- [ ] Quoted inequality after (3.3)
- [ ] Symbol definitions
- [ ] Gate table at 10/100/1000
- [ ] Lean threshold or Tendsto lemma
