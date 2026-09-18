# Audit: AEjonanonymous / Euler-Mascheroni (γ irrationality Lean claim)

**Date:** 2026-09-18  
**Artifact:** GitHub `AEjonanonymous/Euler-Mascheroni`  
**Commit:** `cacf87dd54f01eebc2790f6e17273023097fcd96`  
**Author toolchain:** `leanprover/lean4:v4.29.0` · mathlib `v4.29.0`  
**Campaign pin (for contrast):** `v4.32.2`  
**Scanner:** `scripts/forge/axiom_audit.py` → `results/gamma_audit_meta.json`

## Verdict (route, not theorem)

The artifact does **not** prove `Irrational Real.eulMascheroniConst` (or any mathlib γ).
It proves `¬ is_rational_gamma p q hq` for a **homemade** predicate about partial
sums of `(-1)^k/(k n^k)` and a `TailTrap` sandwich. There is no bridge lemma
from “γ = p/q” to `is_rational_gamma`. Irrationality of γ remains open; this
**lemma chain** fails at statement fidelity.

## Statement fidelity

| Check | Result |
|---|---|
| Mentions `eulMascheroniConst` / mathlib γ | **No** |
| Uses `Irrational` | **No** |
| Imports Mathlib in the main proof file | **No** (standalone; comparator Challenge imports Mathlib) |
| Top theorem | `gamma_irrational : ¬ is_rational_gamma p q hq` |

`is_rational_gamma` (main file, lines 147–152) asserts that for all `n > 1` and
all `N`, the homemade partial sum is trapped around `p/q`. The file never
defines γ, never cites Sondow’s criteria as mathlib objects, and never proves
that rationality of γ would imply this predicate.

## Hole catalog

### Main claimed file
`Proof_Of_Euler-Mascheroni_Constant_Irrationality.lean`

| Pattern | Count |
|---|---|
| `sorry` / `admit` / `axiom` / `native_decide` | **0** |

So the file can look “clean.” The failure is not a visible `sorry`; it is that
the proved statement is not the advertised claim.

### Vacuous / non-load-bearing lemmas (main file)

- `term_positivity` (line 30): concludes `True` by `trivial`. Docstring claims
  positivity needed for γ ≠ 0; the statement carries no content.
- `Z : Int` in `scaled_gap_is_small` / `gamma_irrational` is an **integer by
  construction** (`p * den - num * q`). Integrality is not smuggled via `axiom`;
  it is definitional. What is missing is any proof that this `Z` is the scaled
  gap for the actual constant γ.

### Comparator tree
`comparator/Challenge.lean` contains **6× `sorry`** (lines 34, 59, 68, 118, 137, 142).
`comparator/Solution.lean` mirrors the main file. Comparator is not the
advertised kernel-checked proof; it is a holey challenge scaffold.

## Load-bearing chain vs what Lean checks

| Informal claim (README) | Lean reality |
|---|---|
| γ = p/q ⇒ ∃ integer Z with 0 < Z < 1 | Only: `is_rational_gamma` ⇒ 0 < Z < 1 at `n=2`, `N=q+2` |
| Sondow series for γ | Homemade `series_term` / `partial_sum`; not identified with γ |
| Tail trap analytic remainder | `get_trap` sets `lower = 0/1`, `upper = 1/((N+1)n^{N+1})` by fiat |
| Contradiction ⇒ γ irrational | Contradiction ⇒ `¬ is_rational_gamma` only |

**Dead lemma (named):** the missing bridge  
`γ = p/q → is_rational_gamma p q hq`  
is never stated. Without it, `gamma_irrational` does not touch γ.

## Build status

Author toolchain is v4.29.0 (campaign uses v4.32.2). Static audit does not
require a green build to establish statement non-fidelity. A same-toolchain
`lake build` is optional confirmation that the main file elaborates; it would
not repair the statement gap.

## Abort / escalate

Historic escalate criterion (clean proof of mathlib γ irrationality) **not met**.
No schedule abort. Continue to Phase 1(b).

## Reusable output

- `scripts/forge/axiom_audit.py` — tree scanner
- `FragileProofAudit.AxiomAudit` — Lean module marker (campaign lib)
- This brief — template for future Lean-claim audits
