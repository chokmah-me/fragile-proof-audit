/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import FragileProofAudit.Lame.DedekindField

/-!
# Lamé 1847 — concrete ideal of absolute norm 2

On `OKNeg23 = ℤ[θ]` with `θ² = −6 + θ`, the ideal
`P2 = (2, θ) = Ideal.span {2, ω}` has `Ideal.absNorm P2 = 2`, hence is
non-principal by `not_isPrincipal_of_absNorm_two` (Dedekind instance from
`DedekindField`).
-/

namespace FragileProofAudit.Lame.IdealNormTwo

open Ideal QuadraticAlgebra
open FragileProofAudit.Lame.IdealPrincipal
open FragileProofAudit.Lame.DedekindField

/-- Candidate prime above 2: `(2, θ)`. -/
def P2 : Ideal OKNeg23 :=
  span {(2 : OKNeg23), (omega : OKNeg23)}

theorem P2_eq_span_insert :
    P2 = span (insert (2 : OKNeg23) {(omega : OKNeg23)}) := by
  simp [P2]

theorem two_mem_P2 : (2 : OKNeg23) ∈ P2 :=
  subset_span (by simp)

theorem omega_mem_P2 : (omega : OKNeg23) ∈ P2 :=
  subset_span (by simp)

/-- `1 ∉ (2, θ)`: coordinate parity — `2x + θ y` always has even real part. -/
theorem one_notMem_P2 : (1 : OKNeg23) ∉ P2 := by
  intro h
  obtain ⟨x, y, hxy⟩ := mem_span_pair.mp (by simpa [P2] using h)
  have hre : (x * (2 : OKNeg23) + y * omega).re = 1 := by
    rw [hxy]; simp
  have heven : Even ((x * (2 : OKNeg23) + y * omega).re) := by
    refine ⟨x.re - 3 * y.im, ?_⟩
    simp only [re_add, re_mul, re_ofNat, omega_re, omega_im, im_ofNat, Int.reduceNeg] at hre ⊢
    ring
  rw [hre] at heven
  exact Int.not_even_one heven

theorem P2_ne_top : P2 ≠ ⊤ := by
  intro h
  exact one_notMem_P2 (h ▸ trivial)

theorem P2_ne_bot : P2 ≠ ⊥ := by
  intro h
  have : (2 : OKNeg23) = 0 := by
    simpa [h, mem_bot] using two_mem_P2
  exact two_ne_zero this

theorem algebraNorm_two : Algebra.norm ℤ (2 : OKNeg23) = 4 := by
  rw [algebraNorm_eq_norm]
  simp [QuadraticAlgebra.norm_def]

theorem algebraNorm_omega : Algebra.norm ℤ (omega : OKNeg23) = 6 := by
  rw [algebraNorm_eq_norm]
  simp [QuadraticAlgebra.norm_def]

/-- Absolute norm of `(2, θ)` is 2. -/
theorem absNorm_P2 : Ideal.absNorm P2 = 2 := by
  have hdiv : Ideal.absNorm P2 ∣ 2 := by
    have h := Ideal.absNorm_span_insert (2 : OKNeg23) {(omega : OKNeg23)}
    rw [← P2_eq_span_insert] at h
    have hω : Ideal.absNorm (span {(omega : OKNeg23)}) = 6 := by
      rw [absNorm_span_singleton, algebraNorm_omega]
      norm_num
    have h2 : (Algebra.norm ℤ (2 : OKNeg23)).natAbs = 4 := by
      rw [algebraNorm_two]; norm_num
    rw [hω, h2] at h
    have hgcd : gcd 6 4 = 2 := by decide
    rwa [hgcd] at h
  have hne0 : Ideal.absNorm P2 ≠ 0 := by
    intro h0
    exact P2_ne_bot (absNorm_eq_zero_iff.mp h0)
  have hne1 : Ideal.absNorm P2 ≠ 1 := by
    intro h1
    exact P2_ne_top (absNorm_eq_one_iff.mp h1)
  have hpos : 0 < Ideal.absNorm P2 := Nat.pos_of_ne_zero hne0
  have hle : Ideal.absNorm P2 ≤ 2 := Nat.le_of_dvd (by norm_num) hdiv
  omega

/-- Unconditional: `(2, θ)` is not principal. -/
theorem P2_not_isPrincipal : ¬ Submodule.IsPrincipal P2 :=
  not_isPrincipal_of_absNorm_two P2 absNorm_P2

end FragileProofAudit.Lame.IdealNormTwo
