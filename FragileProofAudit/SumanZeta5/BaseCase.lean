/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# Suman ζ(5) — Eq. (48) base-case witnesses

Suman, arXiv:2407.07121v6, Eq. (48) (induction target):

```text
d_n * a - 2 * d_n * b = -k * b
  where d_n ∣ k * b,  0 ≤ k ≤ d_n,  n ≥ 1
```

with `d_n = lcm(1,…,n)`. At `n = 1`, `d_1 = 1`, so `k ∈ {0,1}` and the
solutions `a = 2b` (`k = 0`) and `a = b` (`k = 1`) exist.

This module records those witnesses and negates the “no integer solutions”
claim. It does **not** assert that ζ(5) is rational.

Do not use the empty Eq. (47)-style range `1 ≤ k ≤ d_1 - 1 = 0`.
-/

namespace FragileProofAudit.SumanZeta5.BaseCase

/-- Suman Eq. (48) at fixed denominator `d` (here `d = d_n`). -/
def Eq48 (d a b k : ℤ) : Prop :=
  d * a - 2 * d * b = -k * b ∧ d ∣ k * b ∧ 0 ≤ k ∧ k ≤ d

/-- Canonical witness: `a = 2b` at `n = 1`, `k = 0`. -/
theorem witness_a_eq_2b : Eq48 1 2 1 0 := by
  refine ⟨by norm_num, Int.one_dvd _, by norm_num, by norm_num⟩

/-- Canonical witness: `a = b` at `n = 1`, `k = 1`. -/
theorem witness_a_eq_b : Eq48 1 1 1 1 := by
  refine ⟨by norm_num, Int.one_dvd _, by norm_num, by norm_num⟩

/-- Parametric family `a = 2b` for any nonzero `b` (`k = 0`, `d = 1`). -/
theorem family_a_eq_2b (b : ℤ) (_hb : b ≠ 0) : Eq48 1 (2 * b) b 0 := by
  refine ⟨by ring, Int.one_dvd _, by norm_num, by norm_num⟩

/-- Parametric family `a = b` for any nonzero `b` (`k = 1`, `d = 1`). -/
theorem family_a_eq_b (b : ℤ) (_hb : b ≠ 0) : Eq48 1 b b 1 := by
  refine ⟨by ring, Int.one_dvd _, by norm_num, by norm_num⟩

/-- Existence form used by the induction-base kill. -/
theorem exists_solution :
    ∃ a b k : ℤ, b ≠ 0 ∧ Eq48 1 a b k :=
  ⟨2, 1, 0, by norm_num, witness_a_eq_2b⟩

/-- Negation of Suman’s “Eq. (48) has no integer solutions” at `n = 1`. -/
theorem not_no_solutions :
    ¬ (∀ a b k : ℤ, b ≠ 0 → ¬ Eq48 1 a b k) := by
  intro h
  exact (h 2 1 0 (by norm_num)) witness_a_eq_2b

/-- Both classical families are inhabited (matches the Python gate). -/
theorem both_families :
    (∃ a b : ℤ, b ≠ 0 ∧ a = 2 * b ∧ Eq48 1 a b 0) ∧
      (∃ a b : ℤ, b ≠ 0 ∧ a = b ∧ Eq48 1 a b 1) := by
  refine ⟨⟨2, 1, by norm_num, rfl, witness_a_eq_2b⟩,
    ⟨1, 1, by norm_num, rfl, witness_a_eq_b⟩⟩

end FragileProofAudit.SumanZeta5.BaseCase
