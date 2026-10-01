/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Private campaign artifact. Gates refute routes, not theorems.
-/

import Mathlib.Data.Finset.Interval
import Mathlib.Order.Interval.Finset.Nat
import Mathlib.Data.Finset.Card
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.Order.GroupWithZero.Basic
import Mathlib.Algebra.GroupWithZero.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Tactic.Positivity

/-!
# The overlap index θ — M1 of the Litt game formalization

For words `U`, `V` of length `ℓ` over a `q`-letter alphabet, the overlap set
`Θ(U,V) = {1 ≤ k ≤ ℓ−1 : suffix of U of length k = prefix of V of length k}`
and the overlap index `θ_UV = (∑_{k ∈ Θ(U,V)} q^k) / q^ℓ`, equations (1.3)–(1.4)
of arXiv:2503.19035v1 (Janson–Nica–Segert, *The generalized Alice HH vs Bob HT
problem*). Theorem 1.1 of the paper says the asymptotic winner of Litt's game
is decided by `θ`: whoever's self-overlap is larger loses. This module is the
combinatorial core (M1 of `FragileProofAudit/LittGame/WORKPLAN.md`):
computable definitions plus basic lemmas, sorry-free.
-/

namespace FragileProofAudit.LittGame

variable (q : ℕ)

/-- The overlap set `Θ(U,V)` ((1.3) of arXiv:2503.19035v1): positions
    `1 ≤ k ≤ |U|−1` where the length-`k` suffix of `U` equals the length-`k`
    prefix of `V`. Meant for equal-length words; `|U|` plays the role of `ℓ`. -/
def overlapSet (U V : List (Fin q)) : Finset ℕ :=
  (Finset.Icc 1 (U.length - 1)).filter fun k => U.drop (U.length - k) = V.take k

/-- The overlap index `θ_UV` ((1.4) of arXiv:2503.19035v1):
    `(∑_{k ∈ Θ(U,V)} q^k) / q^ℓ`, as a nonnegative rational. -/
def theta (U V : List (Fin q)) : ℚ :=
  (∑ k ∈ overlapSet q U V, (q : ℚ) ^ k) / (q : ℚ) ^ U.length

/-- Membership characterization for the overlap set. -/
theorem mem_overlapSet_iff {U V : List (Fin q)} {k : ℕ} :
    k ∈ overlapSet q U V ↔
      1 ≤ k ∧ k ≤ U.length - 1 ∧ U.drop (U.length - k) = V.take k := by
  simp [overlapSet, Finset.mem_filter, Finset.mem_Icc, and_assoc]

/-- Every overlap position is positive. -/
theorem mem_overlapSet_pos {U V : List (Fin q)} {k : ℕ}
    (h : k ∈ overlapSet q U V) : 1 ≤ k :=
  ((mem_overlapSet_iff q).mp h).1

/-- Every overlap position is strictly below the word length. -/
theorem mem_overlapSet_lt {U V : List (Fin q)} {k : ℕ}
    (h : k ∈ overlapSet q U V) : k < U.length := by
  rw [mem_overlapSet_iff] at h
  omega

/-- Words of length at most one have no overlaps. -/
theorem overlapSet_empty_of_length_le_one {U V : List (Fin q)}
    (h : U.length ≤ 1) : overlapSet q U V = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro k hk
  have hlt := mem_overlapSet_lt q hk
  have hpos := mem_overlapSet_pos q hk
  omega

/-- The overlap index is nonnegative. -/
theorem theta_nonneg (U V : List (Fin q)) : 0 ≤ theta q U V := by
  unfold theta
  apply div_nonneg
  · exact Finset.sum_nonneg fun k _ => pow_nonneg (by positivity) _
  · exact pow_nonneg (by positivity) _

/-- Empty overlap set gives `θ = 0`. -/
theorem theta_eq_zero_of_overlapSet_eq_empty {U V : List (Fin q)}
    (h : overlapSet q U V = ∅) : theta q U V = 0 := by
  unfold theta
  rw [h, Finset.sum_empty, zero_div]

/-- Worked example: `θ_HH = 1/2`. "HH" has the length-1 self-overlap
    (suffix "H" = prefix "H"), so `θ = 2^1 / 2^2 = 1/2`. -/
theorem theta_HH_self : theta 2 [0, 0] [0, 0] = 1 / 2 := by
  native_decide

/-- Worked example: `θ_HT = 0`. "HT" has no self-overlap
    (suffix "T" ≠ prefix "H"). -/
theorem theta_HT_self : theta 2 [0, 1] [0, 1] = 0 := by
  native_decide

-- Spot checks: the definitions compute as claimed.
#eval overlapSet 2 [0, 0] [0, 0] = {1} -- expected true
#eval overlapSet 2 [0, 1] [0, 1] = ∅ -- expected true
#eval theta 2 [0, 0] [0, 0] -- expected 1/2
#eval theta 2 [0, 1] [0, 1] -- expected 0
#eval theta 2 [0, 0] [0, 1] -- expected 1/2 (cross overlap)
#eval theta 2 [0, 1] [0, 0] -- expected 0 (no cross overlap)
#eval theta 3 [0, 0] [0, 0] -- expected 1/3 (q = 3)

end FragileProofAudit.LittGame
