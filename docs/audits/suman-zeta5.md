# Audit note — Suman ζ(5) (Phase 1(b))

**Claim artifact:** Shekhar Suman, *A note on the Irrationality of ζ(5) and higher odd zeta values*, arXiv:2407.07121v6 (withdrawn as v7).  
**Refutation:** Chen–He–He–Huang–Li–Tang–Wu–Xu–Yang–Yu, arXiv:2411.16774.  
**Campaign objects:** `docs/blueprint/suman-zeta5.md`, `scripts/gates/suman_eq48.py`, `FragileProofAudit/SumanZeta5/BaseCase.lean`, `FragileProofAudit/IrrationalityCriterion.lean`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Eq. (48) has no integer solutions (induction base for Theorem 1) |
| **Instance** | `n = 1`, `d_1 = lcm(1) = 1`, constraints `0 ≤ k ≤ d_1` and `d_1 ∣ k b` |
| **False instance** | Solutions `(a,b,k) = (2,1,0)` (`a = 2b`) and `(1,1,1)` (`a = b`) |

Suman dismisses these because they would force `ζ(5) ∈ {1,2}`. Solvability of Eq. (48) is independent of whether ζ(5) is an integer; the induction never starts.

## What was gated

Python gate (`results/suman_gate_meta.json`):

- `d_1 = 1`
- both families found under **Eq. (48)** range `0 ≤ k ≤ d_n`
- documented that the Eq. (47)-style range `1 ≤ k ≤ d_1 − 1` is **empty** (Claude harvest trap)
- `ζ(5) ≈ 1.0369277551…`, gap from 1 ≈ 0.0369 (Suman’s “absurd” values are numerically false, but that is not needed for the algebraic kill)

## What Lean proves

- `FragileProofAudit.SumanZeta5.BaseCase.not_no_solutions` — negation of “no solutions at n=1”
- Explicit witnesses and parametric families
- `FragileProofAudit.IrrationalityCriterion.irrational_of_integer_forms_tendsto_zero` — classical Apéry/Chen kernel criterion (shared with Kim 1(c))

**Not claimed:** ζ(5) ∈ ℚ. Gates refute the route, not the theorem.

## Secondary (not primary object)

Chen et al. also note Suman’s `I_n` fails Prop. 3.1 condition (3) (`Dε ≮ 1`). Deferred; base-case kill is sufficient for Phase 1(b).
