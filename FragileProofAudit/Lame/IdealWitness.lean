/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.Data.Int.ModEq
import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Lamé 1847 — quadratic ideal norm obstruction for `ℚ(√−23)`

For `K = ℚ(√−23)`, the ring of integers is
`O_K = ℤ[(1+√−23)/2] = { (a + b √−23)/2 | a,b ∈ ℤ, a ≡ b (mod 2) }`,
with field norm
`N((a + b √−23)/2) = (a² + 23 b²)/4`.

A prime ideal `P | (2)` of absolute norm `2` is therefore **non-principal**
as soon as no `O_K`-element has absolute norm `2`, i.e. as soon as the Diophantine
equation
`a² + 23 b² = 8` has no integer solutions (parity is then automatic).

This module proves that obstruction. Matching gate:
`scripts/gates/lame_ideal_neg23.py`.

Honest scope: this is **not** yet a mathlib `Ideal.IsPrincipal` statement, nor a
proof that `classNumber K = 3`, nor a cyclotomic ideal in `𝓞(ℚ(ζ₂₃))`.
flt-regular remains deferred.
-/

namespace FragileProofAudit.Lame.IdealWitness

/-- Absolute-norm-2 equation for `O_K` elements written with even-parity
numerator: `N = (a² + 23 b²)/4 = ±2` forces `a² + 23 b² = 8` (sign `−2`
impossible since the left side is nonnegative). -/
def NormTwoEquation (a b : ℤ) : Prop :=
  a ^ 2 + 23 * b ^ 2 = 8

/-- Auxiliary: no natural number squares to 8. -/
theorem natAbs_sq_ne_eight (n : ℕ) : ¬ ((n : ℤ) ^ 2 = 8) := by
  intro h
  have hn : n ≤ 3 := by
    by_contra hgt
    have h4 : 4 ≤ n := by omega
    have : (4 : ℤ) ^ 2 ≤ (n : ℤ) ^ 2 :=
      pow_le_pow_left₀ (by norm_num) (by exact_mod_cast h4) 2
    nlinarith
  interval_cases n <;> norm_num at h

/-- No integer solutions to `a² + 23 b² = 8`. -/
theorem no_norm_two_equation (a b : ℤ) : ¬ NormTwoEquation a b := by
  intro h
  dsimp [NormTwoEquation] at h
  have hb0 : b = 0 := by
    have hle : 23 * b ^ 2 ≤ 8 := by nlinarith [sq_nonneg a]
    have hb2 : b ^ 2 ≤ 0 := by nlinarith
    have : b ^ 2 = 0 := le_antisymm hb2 (sq_nonneg b)
    exact (sq_eq_zero_iff).1 this
  subst hb0
  have hsq : a ^ 2 = 8 := by simpa using h
  have : (Int.natAbs a : ℤ) ^ 2 = 8 := by
    rw [Int.natAbs_pow_two a]; exact hsq
  exact natAbs_sq_ne_eight (Int.natAbs a) this

/-- Packaged: no even-parity numerator yields absolute norm 2. -/
theorem no_even_parity_norm_two (a b : ℤ) (_hpar : a ≡ b [ZMOD 2]) :
    ¬ NormTwoEquation a b :=
  fun h => no_norm_two_equation a b h

/-- Witness numerator for `θ − 2` with `θ = (1+√−23)/2`. -/
theorem theta_minus_two_norm_numerator : (-3 : ℤ) ^ 2 + 23 * (1 : ℤ) ^ 2 = 32 := by
  norm_num

/-- Field norm of `θ − 2` is `8 = 2³`. -/
theorem theta_minus_two_norm : ((-3 : ℤ) ^ 2 + 23 * (1 : ℤ) ^ 2) / 4 = 8 := by
  norm_num

/-- Parity check: numerator of `θ − 2` is admissible in `O_K`. -/
theorem theta_minus_two_even_parity : (-3 : ℤ) ≡ 1 [ZMOD 2] := by
  decide

end FragileProofAudit.Lame.IdealWitness
