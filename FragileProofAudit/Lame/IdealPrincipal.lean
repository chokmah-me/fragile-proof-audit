/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import FragileProofAudit.Lame.IdealWitness
import Mathlib.Algebra.QuadraticAlgebra.Basic
import Mathlib.Data.Int.ModEq
import Mathlib.RingTheory.Ideal.Norm.AbsNorm
import Mathlib.RingTheory.Norm.Defs
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Lamé 1847 — Ideal.IsPrincipal obstruction for `O_K` of `ℚ(√−23)`

Model the ring of integers of `K = ℚ(√−23)` as the quadratic algebra
`OKNeg23 := QuadraticAlgebra ℤ (-6) 1`, i.e. `ℤ[θ]` with `θ² = −6 + θ`,
matching `θ = (1+√−23)/2` (minimal polynomial `X² − X + 6`).

For `z = re + im·θ` one has
`N(z) = re² + re·im + 6·im² = ((2·re+im)² + 23·im²)/4`,
so `|N(z)| = 2` forces the Diophantine equation `a² + 23 b² = 8` already
killed in `IdealWitness`.

Under `IsDedekindDomain OKNeg23` (now available as an instance via
`FragileProofAudit.Lame.DedekindField`), any ideal of absolute norm `2` is
therefore **not** `Submodule.IsPrincipal`, via mathlib
`Ideal.absNorm_span_singleton`.

Honest scope:
* mathlib `Submodule.IsPrincipal` / `Ideal.absNorm` on the coordinate model
  `OKNeg23`, not yet `𝓞 (CyclotomicField 23 ℚ)`.
* `IsDedekindDomain OKNeg23` is proved in `DedekindField.lean` (integral
  closure of `ℤ` in `AdjoinRoot (X²−X+6)`); a concrete ideal with
  `absNorm = 2` is still outstanding.
* flt-regular lake dependency remains blocked by toolchain mismatch
  (upstream `v4.34.*` vs campaign pin `v4.32.2`).
-/

namespace FragileProofAudit.Lame.IdealPrincipal

open Ideal QuadraticAlgebra

/-- Coordinate model of `O_K` for `K = ℚ(√−23)`: `ℤ[θ]`, `θ² = −6 + θ`. -/
abbrev OKNeg23 : Type :=
  QuadraticAlgebra ℤ (-6) 1

/-- Even-parity numerator coordinates: `z ↦ (2·re + im, im)`. -/
def numCoords (z : OKNeg23) : ℤ × ℤ :=
  (2 * z.re + z.im, z.im)

theorem numCoords_parity (z : OKNeg23) :
    (numCoords z).1 ≡ (numCoords z).2 [ZMOD 2] := by
  rw [Int.modEq_iff_dvd]
  -- `a ≡ b [ZMOD n]` packages `b - a = n * c`; here `im - (2re+im) = 2*(-re)`.
  refine ⟨-z.re, ?_⟩
  simp only [numCoords]
  ring

/-- `4 · N(z) = a² + 23 b²` for the even-parity numerator of `z`. -/
theorem four_mul_norm_eq (z : OKNeg23) :
    4 * (z.norm : ℤ) = (numCoords z).1 ^ 2 + 23 * (numCoords z).2 ^ 2 := by
  dsimp [numCoords, QuadraticAlgebra.norm_def]
  ring

/-- QuadraticAlgebra-norm on `OKNeg23` is nonnegative. -/
theorem norm_nonneg (z : OKNeg23) : 0 ≤ z.norm := by
  have h4 := four_mul_norm_eq z
  have : 0 ≤ (numCoords z).1 ^ 2 + 23 * (numCoords z).2 ^ 2 := by
    nlinarith [sq_nonneg (numCoords z).1, sq_nonneg (numCoords z).2]
  nlinarith

/-- No element of `OKNeg23` has absolute QuadraticAlgebra-norm `2`. -/
theorem no_quad_norm_two (z : OKNeg23) : z.norm.natAbs ≠ 2 := by
  intro h
  have h2 : z.norm = 2 := by
    have := Int.natAbs_eq_iff.mp h
    cases this with
    | inl h' => exact h'
    | inr h' =>
      have hnn := norm_nonneg z
      rw [h'] at hnn
      norm_num at hnn
  have h8 : (numCoords z).1 ^ 2 + 23 * (numCoords z).2 ^ 2 = 8 := by
    have := four_mul_norm_eq z
    simp [h2] at this
    linarith
  exact IdealWitness.no_norm_two_equation (numCoords z).1 (numCoords z).2 h8

theorem basis0 : (basis (-6 : ℤ) (1 : ℤ) : Fin 2 → OKNeg23) 0 = 1 := by
  apply (basis (-6 : ℤ) (1 : ℤ)).repr.injective
  ext k
  fin_cases k <;> simp [basis_repr_apply]

theorem basis1 : (basis (-6 : ℤ) (1 : ℤ) : Fin 2 → OKNeg23) 1 = ⟨0, 1⟩ := by
  apply (basis (-6 : ℤ) (1 : ℤ)).repr.injective
  ext k
  fin_cases k <;> simp [basis_repr_apply]

/-- Left-multiplication matrix of `z` on the standard basis. -/
theorem leftMulMatrix_ok (z : OKNeg23) :
    Algebra.leftMulMatrix (basis (-6 : ℤ) (1 : ℤ)) z =
      !![z.re, (-6 : ℤ) * z.im; z.im, z.re + z.im] := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    (simp [Algebra.leftMulMatrix_apply, LinearMap.toMatrix_apply, basis_repr_apply,
      Algebra.coe_lmul_eq_mul, basis0, basis1, re_mul, im_mul]; try ring)

/-- `Algebra.norm ℤ` agrees with `QuadraticAlgebra.norm` on `OKNeg23`. -/
theorem algebraNorm_eq_norm (z : OKNeg23) :
    Algebra.norm ℤ z = z.norm := by
  rw [Algebra.norm_eq_matrix_det (basis (-6 : ℤ) (1 : ℤ)), leftMulMatrix_ok]
  simp [QuadraticAlgebra.norm_def]
  ring

/-- No element of `OKNeg23` has absolute `Algebra.norm ℤ` equal to `2`. -/
theorem no_algebra_norm_two (z : OKNeg23) : (Algebra.norm ℤ z).natAbs ≠ 2 := by
  simpa [algebraNorm_eq_norm] using no_quad_norm_two z

/-- Packaged: no generator of absolute Algebra-norm `2`. -/
theorem not_exists_generator_norm_two :
    ¬ ∃ z : OKNeg23, (Algebra.norm ℤ z).natAbs = 2 := by
  rintro ⟨z, hz⟩
  exact no_algebra_norm_two z hz

/-- **Ideal.IsPrincipal obstruction**: an ideal of absolute norm `2` cannot be
principal. The Dedekind hypothesis is discharged by the instance in
`DedekindField`. -/
theorem not_isPrincipal_of_absNorm_two [IsDedekindDomain OKNeg23]
    (I : Ideal OKNeg23) (hI : Ideal.absNorm I = 2) :
    ¬ Submodule.IsPrincipal I := by
  intro hp
  obtain ⟨z, hz⟩ := hp
  have : (Algebra.norm ℤ z).natAbs = 2 := by
    rw [hz] at hI
    simpa [Ideal.absNorm_span_singleton] using hI
  exact no_algebra_norm_two z this

end FragileProofAudit.Lame.IdealPrincipal
