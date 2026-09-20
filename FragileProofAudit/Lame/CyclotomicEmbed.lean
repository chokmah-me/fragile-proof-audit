/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import FragileProofAudit.Lame.Premise
import Mathlib.NumberTheory.Cyclotomic.PrimitiveRoots
import Mathlib.NumberTheory.GaussSum
import Mathlib.NumberTheory.LegendreSymbol.AddCharacter
import Mathlib.NumberTheory.LegendreSymbol.QuadraticChar.Basic

/-!
# Lamé 1847 — Gauss-sum embedding of `√−23` into `ℚ(ζ₂₃)`

Classical fact: for an odd prime `p ≡ 3 (mod 4)`, the quadratic Gauss sum
`τ = ∑ₐ χ(a) ζᵖᵃ` (Legendre `χ`, primitive `p`-th root `ζ`) satisfies
`τ² = −p`. Instantiated at `p = 23`, this puts a square root of `-23` inside
`CyclotomicField 23 ℚ`, connecting the quadratic model `OKNeg23` to the
cyclotomic ring of Lamé's argument.

Honest scope of this module:
* proves `gauss23 ^ 2 = -23` in `CyclotomicField 23 ℚ` via mathlib
  `gaussSum_sq`;
* does **not** yet map `OKNeg23` into `𝓞 (CyclotomicField 23 ℚ)`, nor prove
  a non-principal ideal there, nor `classNumber = 3` / `h⁺ = 1`.
-/

namespace FragileProofAudit.Lame.CyclotomicEmbed

open AddChar MulChar NumberField
open scoped NumberField

/-- Local abbrev (same carrier as `Premise.Cyclotomic23`). -/
abbrev Cyclotomic23 : Type := CyclotomicField 23 ℚ

/-- Needed so `CyclotomicField.isCyclotomicExtension` can fire at `n = 23`.
Mathlib's `[CharZero K]` wrapper matches on Peano `0` / `_+1` and does not
reduce binary numerals, so we supply `NeZero` and apply the instance by hand. -/
instance neZero_23 : NeZero (23 : ℕ) := ⟨by decide⟩

noncomputable section

/-- Explicit cyclotomic-extension instance at conductor `23`. -/
instance isCyclotomic23 : IsCyclotomicExtension {23} ℚ Cyclotomic23 :=
  @CyclotomicField.isCyclotomicExtension 23 _ ℚ _ _

/-- Distinguished primitive `23`-rd root of unity in `Cyclotomic23`. -/
def zeta23 : Cyclotomic23 :=
  IsCyclotomicExtension.zeta 23 ℚ Cyclotomic23

theorem zeta23_pow : zeta23 ^ 23 = 1 :=
  IsCyclotomicExtension.zeta_pow 23 ℚ Cyclotomic23

theorem zeta23_primitive : IsPrimitiveRoot zeta23 23 :=
  IsCyclotomicExtension.zeta_spec 23 ℚ Cyclotomic23

/-- Additive character `a ↦ ζᵃ` on `ZMod 23`. -/
def psi23 : AddChar (ZMod 23) Cyclotomic23 :=
  zmodChar 23 zeta23_pow

theorem psi23_primitive : psi23.IsPrimitive :=
  zmodChar_primitive_of_primitive_root 23 zeta23_primitive

/-- Quadratic character of `𝔽₂₃`, valued in `Cyclotomic23` via `ℤ → Cyclotomic23`. -/
def chi23 : MulChar (ZMod 23) Cyclotomic23 :=
  (quadraticChar (ZMod 23)).ringHomComp (Int.castRingHom Cyclotomic23)

theorem chi23_isQuadratic : chi23.IsQuadratic :=
  (quadraticChar_isQuadratic (ZMod 23)).comp _

theorem chi23_ne_one : chi23 ≠ 1 := by
  refine (ringHomComp_ne_one_iff ?_).mpr ?_
  · exact Int.cast_injective
  · exact quadraticChar_ne_one (by rw [ZMod.ringChar_zmod_n (n := 23)]; norm_num)

/-- Quadratic Gauss sum `∑ χ(a) ζᵃ` in `ℚ(ζ₂₃)`. -/
def gauss23 : Cyclotomic23 :=
  gaussSum chi23 psi23

/-- `-1` is not a square in `𝔽₂₃` (since `23 ≡ 3 (mod 4)`), so `χ(-1) = -1`. -/
theorem quadraticChar_neg_one_zmod23 :
    quadraticChar (ZMod 23) (-1) = -1 := by
  have hnot : ¬ IsSquare (-1 : ZMod 23) := by
    rw [FiniteField.isSquare_neg_one_iff, ZMod.card]
    norm_num
  exact (quadraticChar_neg_one_iff_not_isSquare (F := ZMod 23)).mpr hnot

theorem chi23_neg_one : chi23 (-1) = -1 := by
  simp only [chi23, ringHomComp_apply, quadraticChar_neg_one_zmod23, map_neg, map_one]

theorem card_zmod23_cast : (Fintype.card (ZMod 23) : Cyclotomic23) = 23 := by
  simp [ZMod.card]

/-- **Gauss-sum square.** `τ² = −23` in `ℚ(ζ₂₃)`. -/
theorem gauss23_sq : gauss23 ^ 2 = -23 := by
  have h := gaussSum_sq chi23_ne_one chi23_isQuadratic psi23_primitive
  simpa [gauss23, chi23_neg_one, card_zmod23_cast, mul_comm] using h

/-- Existence form: `-23` is a square in `ℚ(ζ₂₃)`. -/
theorem exists_sq_eq_neg_twenty_three : ∃ x : Cyclotomic23, x ^ 2 = -23 :=
  ⟨gauss23, gauss23_sq⟩

end

end FragileProofAudit.Lame.CyclotomicEmbed
