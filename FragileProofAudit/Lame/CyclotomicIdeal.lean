/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import FragileProofAudit.Lame.DedekindField
import FragileProofAudit.Lame.CyclotomicEmbed

/-!
# Lamé 1847 — `OKNeg23 ↪ 𝓞 (ℚ(ζ₂₃))`

Track A, first milestone: transport the quadratic coordinate model
`OKNeg23` (proved `IsDedekindDomain` in `DedekindField.lean`, integral closure
of `ℤ` in `L23 = ℚ(√−23)`) into the ring of integers of the cyclotomic field
`ℚ(ζ₂₃)`, using the Gauss-sum root `gauss23` of `X² = −23` built in
`CyclotomicEmbed.lean`.

Construction:
* `theta_image := (1 + gauss23) / 2 : Cyclotomic23` satisfies the same
  minimal polynomial `f23 = X² − X + 6` as `rootL23`, since
  `4 · (θ² − θ + 6) = gauss23² + 23 = 0`.
* `embedL23 : L23 →+* Cyclotomic23` is `AdjoinRoot.lift` sending
  `rootL23 ↦ theta_image`; injective because `L23` is a field (any nonzero
  ring hom out of a field is injective — proved directly, no library lemma
  needed).
* `embedOK := embedL23.comp (algebraMap OKNeg23 L23) : OKNeg23 →+* Cyclotomic23`
  is injective (composite of two injective maps) and sends every element to
  an integral one (`Module.Finite ℤ OKNeg23` supplies `Algebra.IsIntegral ℤ
  OKNeg23` automatically; `map_isIntegral_int` transports integrality along
  a ring hom).
* Corestricting along integrality gives
  `embedToRingOfIntegers : OKNeg23 →+* 𝓞 (CyclotomicField 23 ℚ)`, injective.

Honest scope: this is a ring embedding, not (yet) a pushed-forward
non-principal ideal in `𝓞 (ℚ(ζ₂₃))`, and does not touch `classNumber` or
`h⁺`. Those remain the next steps under Track A.
-/

open Polynomial FragileProofAudit.Lame.IdealPrincipal FragileProofAudit.Lame.DedekindField
open FragileProofAudit.Lame.CyclotomicEmbed
open NumberField

namespace FragileProofAudit.Lame.CyclotomicIdeal

noncomputable section

/-- Candidate image of `θ = (1+√−23)/2` inside `ℚ(ζ₂₃)`, built from the
Gauss-sum square root of `−23`. -/
def theta_image : Cyclotomic23 := (1 + gauss23) / 2

/-- `4 · (θ² − θ + 6) = gauss23² + 23`, a bookkeeping identity independent of
`gauss23_sq`. -/
theorem four_mul_theta_image_charpoly :
    (4 : Cyclotomic23) * (theta_image ^ 2 - theta_image + 6) = gauss23 ^ 2 + 23 := by
  unfold theta_image; ring

/-- `theta_image` satisfies the same monic quadratic as `rootL23`. -/
theorem theta_image_charpoly : theta_image ^ 2 - theta_image + 6 = 0 := by
  have h0 : (4 : Cyclotomic23) * (theta_image ^ 2 - theta_image + 6) = 0 := by
    rw [four_mul_theta_image_charpoly, gauss23_sq]; ring
  have h4 : (4 : Cyclotomic23) ≠ 0 := by norm_num
  exact (mul_eq_zero.mp h0).resolve_left h4

theorem f23_aeval_theta_image : Polynomial.aeval theta_image f23 = 0 := by
  have h : Polynomial.aeval theta_image f23 = theta_image ^ 2 - theta_image + 6 := by
    unfold f23
    simp [aeval_X_pow, aeval_X, aeval_C, map_add, map_sub]
  rw [h]; exact theta_image_charpoly

theorem f23_eval2_theta_image :
    f23.eval₂ (algebraMap ℚ Cyclotomic23) theta_image = 0 := by
  simpa [Polynomial.aeval_def] using f23_aeval_theta_image

/-- Field embedding `L23 = ℚ(√−23) ↪ ℚ(ζ₂₃)` sending `rootL23 ↦ theta_image`,
built by the universal property of `L23 = AdjoinRoot f23`. -/
def embedL23 : L23 →+* Cyclotomic23 :=
  AdjoinRoot.lift (algebraMap ℚ Cyclotomic23) theta_image f23_eval2_theta_image

theorem embedL23_apply_root : embedL23 rootL23 = theta_image :=
  AdjoinRoot.lift_root f23_eval2_theta_image

/-- Any nonzero ring hom out of a field is injective: if it killed a nonzero
`x`, it would kill `x · x⁻¹ = 1`, contradicting `Nontrivial` on the target. -/
theorem embedL23_injective : Function.Injective embedL23 := by
  intro x y hxy
  by_contra hne
  have hxyne : x - y ≠ 0 := sub_ne_zero.mpr hne
  have h0 : embedL23 (x - y) = 0 := by rw [map_sub, hxy, sub_self]
  have hone : embedL23 (x - y) * embedL23 (x - y)⁻¹ = 1 := by
    rw [← map_mul, mul_inv_cancel₀ hxyne, map_one]
  rw [h0, zero_mul] at hone
  exact zero_ne_one hone

/-- `OKNeg23 → ℚ(ζ₂₃)`, composite of the coordinate embedding into `L23` and
`embedL23`. -/
def embedOK : OKNeg23 →+* Cyclotomic23 :=
  embedL23.comp (algebraMap OKNeg23 L23)

theorem embedOK_apply (z : OKNeg23) : embedOK z = embedL23 (algebraMap OKNeg23 L23 z) := rfl

theorem embedOK_injective : Function.Injective embedOK :=
  embedL23_injective.comp algMap23_injective

/-- Every image point is integral over `ℤ`: `OKNeg23` is a finite free
`ℤ`-module (`Module.Finite ℤ OKNeg23`, from `QuadraticAlgebra`'s basis),
hence `Algebra.IsIntegral ℤ OKNeg23` fires automatically, and integrality
transports along any ring hom. -/
theorem embedOK_isIntegral (z : OKNeg23) : IsIntegral ℤ (embedOK z) :=
  map_isIntegral_int embedOK (Algebra.IsIntegral.isIntegral (R := ℤ) z)

/-- **Track A milestone.** Ring embedding `OKNeg23 ↪ 𝓞 (ℚ(ζ₂₃))`. -/
def embedToRingOfIntegers : OKNeg23 →+* 𝓞 Cyclotomic23 where
  toFun z := ⟨embedOK z, embedOK_isIntegral z⟩
  map_zero' := by ext; simp only [RingOfIntegers.map_mk, map_zero]
  map_one' := by ext; simp only [RingOfIntegers.map_mk, map_one]
  map_add' x y := by ext; simp only [RingOfIntegers.map_mk, map_add]
  map_mul' x y := by ext; simp only [RingOfIntegers.map_mk, map_mul]

theorem embedToRingOfIntegers_coe (z : OKNeg23) :
    (embedToRingOfIntegers z : Cyclotomic23) = embedOK z := rfl

theorem embedToRingOfIntegers_injective : Function.Injective embedToRingOfIntegers := by
  intro x y hxy
  apply embedOK_injective
  have h : (embedToRingOfIntegers x : Cyclotomic23) = (embedToRingOfIntegers y : Cyclotomic23) :=
    congrArg _ hxy
  simpa [embedToRingOfIntegers_coe] using h

/-- **Headline existence statement.** `OKNeg23` embeds into `𝓞 (ℚ(ζ₂₃))`. -/
theorem exists_embedding : ∃ φ : OKNeg23 →+* 𝓞 Cyclotomic23, Function.Injective φ :=
  ⟨embedToRingOfIntegers, embedToRingOfIntegers_injective⟩

end

end FragileProofAudit.Lame.CyclotomicIdeal
