module

public import CFSGCorollary.LieType.Steinberg.Basic
public import CFSG.LieType.Steinberg.Classical.SpecialLinear
import CFSG.LieType.Steinberg.Families
import CFSGCorollary.LieType.Steinberg.Commutator

/-!
# Steinberg data on the special linear groups

We equip `SL_{m+1}(K)` over a finite field `K` with Steinberg data of type `A_m`. For `m ≥ 2` the
root elements are CFSG's `SL.x m K`, and the axioms come from CFSG's commutator formula and
Chevalley extras. For `m = 1` we write the root elements of `SL₂(K)` down explicitly as the upper
and lower transvections and check the axioms by matrix computation.

## Main results

* `CFSGCorollary.SL.exists_steinbergData`: Steinberg data of type `A_m` on `SL_{m+1}(K)`,
  `m ≥ 2`, with unit single commutators.
* `CFSGCorollary.SL2.exists_steinbergData`: Steinberg data of type `A_1` on `SL₂(K)`.
-/

@[expose] public section

namespace CFSGCorollary

open CFSG.LieType.RootSystem (reflection)
open CFSG.LieType.Steinberg (weylElement)

/-- Steinberg data on `SL`: for a finite field `K` and `m ≥ 2`, `SL.x m K` on
`SL_{m+1}(K)` satisfies (S0)–(S3) for `A = CartanMatrix.A m` and has unit
single commutators. (S4) fails for `SL` itself unless its center is trivial; it is imposed after
passing to a centerless quotient, see `SteinbergData.mapSystem`. -/
theorem SL.exists_steinbergData (m : ℕ) (hm : 2 ≤ m) (K : Type) [Field K] [Finite K] :
    ∃ data : SteinbergData (CartanMatrix.A m)
        (CFSG.LieType.Universal.SpecialLinear.isFiniteType_A m) K
        (Matrix.SpecialLinearGroup (Fin (m + 1)) K),
      data.rootElement = CFSG.LieType.Steinberg.SL.x m K ∧ data.HasUnitCommutatorConstants := by
  obtain ⟨O⟩ : Nonempty (CFSG.LieType.Steinberg.CommOrder
      (CFSG.LieType.Steinberg.SL.Φ (m := m) (F := K))) :=
    CFSG.LieType.Steinberg.nonempty_commOrder_ofCartan
      (CFSG.LieType.Universal.SpecialLinear.rootDatum m K).isFiniteType
      (Dv := (CFSG.LieType.Universal.SpecialLinear.rootDatum m K).divisible) rfl
  have hcomm := CFSG.LieType.Steinberg.SL.commutatorFormula (m := m) (F := K) O
  have hext := CFSG.LieType.Steinberg.SL.chevalleyExtras (m := m) (F := K) hm O _ hcomm
  have hA := (CFSG.LieType.Steinberg.sl_conclusionA.{0} m K).1.1
  refine ⟨{
    rootElement := CFSG.LieType.Steinberg.SL.x m K
    rootElement_add := fun root hroot a b ↦ (hext.param root hroot).2.1 a b
    closure_rootElement_eq_top := ?_
    rootElement_commute := fun α hα β hβ hne hnone a b ↦
      commute_of_commutatorFormula hcomm hα hβ hne hnone a b
    weylElement_conj_rootElement := fun i β hβ ↦ CFSG.LieType.Steinberg.SL.weyl i hβ }, rfl, ?_⟩
  · rw [eq_top_iff, ← hA]
    refine iSup₂_le fun γ hγ g hg ↦ ?_
    obtain ⟨c, rfl⟩ := ((hext.param γ hγ).1 g).1 hg
    exact Subgroup.subset_closure ⟨γ, hγ, c, rfl⟩
  · intro α hα β hβ hsum honly
    have hne : α + β ≠ 0 := fun h ↦ by
      rw [h] at hsum
      exact CFSG.LieType.RootSystem.ne_zero_of_mem_roots _ _ hsum rfl
    obtain ⟨u, hu⟩ : IsUnit ((CFSG.LieType.Steinberg.SL.commC α β (1, 1) : ℤ) : K) :=
      (Int.isUnit_iff_natAbs_eq.2 (CFSG.LieType.Steinberg.SL.commC_natAbs α β (1, 1))).map
        (Int.castRingHom K)
    refine ⟨u, fun a b ↦ ?_⟩
    rw [hu]
    exact commutator_eq_of_commutatorFormula hcomm hα hβ hne hsum honly a b

namespace SL2

variable {K : Type*} [Field K]

/-- The upper unitriangular transvection `!![1, c; 0, 1]` in `SL₂(K)`. -/
abbrev upperTransvection (c : K) : Matrix.SpecialLinearGroup (Fin 2) K :=
  Matrix.SpecialLinearGroup.transvection (show (0 : Fin 2) ≠ 1 by decide) c

/-- The lower unitriangular transvection `!![1, 0; c, 1]` in `SL₂(K)`. -/
abbrev lowerTransvection (c : K) : Matrix.SpecialLinearGroup (Fin 2) K :=
  Matrix.SpecialLinearGroup.transvection (show (1 : Fin 2) ≠ 0 by decide) c

end SL2

open SL2 in
/-- The root elements of `SL₂(K)`: `x α₀ c = upperTransvection c`, `x (-α₀) c =
lowerTransvection c`, and `1` on every other vector. -/
noncomputable def sl2RootElement (K : Type*) [Field K] :
    (Fin 1 → ℤ) → K → Matrix.SpecialLinearGroup (Fin 2) K :=
  fun γ c ↦
    if γ = Pi.single 0 1 then upperTransvection c
    else if γ = -Pi.single 0 1 then lowerTransvection c
    else 1

namespace SL2

section

variable {K : Type*} [Field K]

theorem coe_upperTransvection (c : K) :
    (upperTransvection c : Matrix (Fin 2) (Fin 2) K) = !![1, c; 0, 1] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.SpecialLinearGroup.transvection_coe]

theorem coe_lowerTransvection (c : K) :
    (lowerTransvection c : Matrix (Fin 2) (Fin 2) K) = !![1, 0; c, 1] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.SpecialLinearGroup.transvection_coe]

theorem upperTransvection_add (a b : K) :
    upperTransvection (a + b) = upperTransvection a * upperTransvection b := by
  refine Subtype.ext ?_
  simp only [Matrix.SpecialLinearGroup.coe_mul, coe_upperTransvection]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two, add_comm]

theorem lowerTransvection_add (a b : K) :
    lowerTransvection (a + b) = lowerTransvection a * lowerTransvection b := by
  refine Subtype.ext ?_
  simp only [Matrix.SpecialLinearGroup.coe_mul, coe_lowerTransvection]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two, add_comm]

theorem weylElement_mul_upperTransvection (t : Kˣ) (u : K) :
    upperTransvection (t : K) * lowerTransvection (-((t⁻¹ : Kˣ) : K)) *
        upperTransvection (t : K) * upperTransvection u =
      lowerTransvection (-((t ^ (-2 : ℤ) : Kˣ) : K) * u) *
        (upperTransvection (t : K) * lowerTransvection (-((t⁻¹ : Kˣ) : K)) *
          upperTransvection (t : K)) := by
  refine Subtype.ext ?_
  simp only [Matrix.SpecialLinearGroup.coe_mul, coe_upperTransvection, coe_lowerTransvection]
  have h : (t : K) ≠ 0 := t.ne_zero
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two, zpow_neg, h, pow_two, mul_assoc, mul_comm u]

theorem weylElement_mul_lowerTransvection (t : Kˣ) (u : K) :
    upperTransvection (t : K) * lowerTransvection (-((t⁻¹ : Kˣ) : K)) *
        upperTransvection (t : K) * lowerTransvection u =
      upperTransvection (-((t ^ (2 : ℤ) : Kˣ) : K) * u) *
        (upperTransvection (t : K) * lowerTransvection (-((t⁻¹ : Kˣ) : K)) *
          upperTransvection (t : K)) := by
  refine Subtype.ext ?_
  simp only [Matrix.SpecialLinearGroup.coe_mul, coe_upperTransvection, coe_lowerTransvection]
  have h : (t : K) ≠ 0 := t.ne_zero
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two, h, pow_two, mul_assoc, mul_comm u]

theorem reflection_eq_neg (v : Fin 1 → ℤ) : reflection (CartanMatrix.A 1) 0 v = -v := by
  rw [CFSG.LieType.RootSystem.reflection_apply]
  ext i
  obtain rfl : i = 0 := Subsingleton.elim _ _
  simp [CartanMatrix.A_one]
  ring

theorem roots_eq :
    CFSG.LieType.RootSystem.roots (TauCeti.isFiniteType_cartanMatrix_A 1) ∅ =
      {Pi.single 0 1, -Pi.single 0 1} := by
  set hA := TauCeti.isFiniteType_cartanMatrix_A 1
  have key (w : (CFSG.LieType.RootSystem.coxeterMatrix hA).Group) :
      CFSG.LieType.RootSystem.weylAction hA w (Pi.single 0 1) = Pi.single 0 1 ∨
        CFSG.LieType.RootSystem.weylAction hA w (Pi.single 0 1) = -Pi.single 0 1 := by
    refine (CFSG.LieType.RootSystem.coxeterMatrix hA).toCoxeterSystem.simple_induction
      (p := fun w ↦ CFSG.LieType.RootSystem.weylAction hA w (Pi.single 0 1) = Pi.single 0 1 ∨
        CFSG.LieType.RootSystem.weylAction hA w (Pi.single 0 1) = -Pi.single 0 1) w ?_ ?_ ?_
    · intro i
      obtain rfl : i = 0 := Subsingleton.elim _ _
      exact Or.inr (CFSG.LieType.RootSystem.weylAction_simple_single hA 0)
    · left; simp
    · intro w w' h h'
      rw [map_mul, Module.End.mul_apply]
      rcases h' with h' | h'
      · rw [h']; exact h
      · rw [h', map_neg]
        rcases h with h | h
        · right; rw [h]
        · left; rw [h, neg_neg]
  ext γ
  simp only [CFSG.LieType.RootSystem.roots, Set.mem_union, Set.mem_ofPred_eq,
    Set.mem_empty_iff_false, false_and, exists_false, or_false, Set.mem_insert_iff,
    Set.mem_singleton_iff]
  constructor
  · rintro ⟨w, i, rfl⟩
    obtain rfl : i = 0 := Subsingleton.elim _ _
    exact key w
  · rintro (rfl | rfl)
    · exact ⟨1, 0, by simp⟩
    · exact ⟨(CFSG.LieType.RootSystem.coxeterMatrix hA).toCoxeterSystem.simple 0, 0,
        (CFSG.LieType.RootSystem.weylAction_simple_single hA 0).symm⟩

theorem single_ne_neg_single : (Pi.single 0 1 : Fin 1 → ℤ) ≠ -Pi.single 0 1 := by
  intro h
  simpa using congrFun h 0

theorem sl2RootElement_single (c : K) :
    sl2RootElement K (Pi.single 0 1) c = upperTransvection c := by
  simp [sl2RootElement]

theorem sl2RootElement_neg_single (c : K) :
    sl2RootElement K (-Pi.single 0 1) c = lowerTransvection c := by
  simp [sl2RootElement, single_ne_neg_single.symm]

theorem weylElement_eq (t : Kˣ) :
    weylElement (sl2RootElement K) (0 : Fin 1) t =
      upperTransvection (t : K) * lowerTransvection (-((t⁻¹ : Kˣ) : K)) *
        upperTransvection (t : K) := by
  simp only [weylElement, sl2RootElement_single, sl2RootElement_neg_single]

end

/-- Steinberg data on `SL₂`: for a finite field `K`, `sl2RootElement K` satisfies (S0)–(S3) for
`A = CartanMatrix.A 1` (`Φ = {±α₀}`) and has (vacuously) unit single commutators. -/
theorem exists_steinbergData (K : Type*) [Field K] [Finite K] :
    ∃ data : SteinbergData (CartanMatrix.A 1) (TauCeti.isFiniteType_cartanMatrix_A 1) K
        (Matrix.SpecialLinearGroup (Fin 2) K),
      data.rootElement = sl2RootElement K ∧ data.HasUnitCommutatorConstants := by
  have hroots := roots_eq
  refine ⟨{
    rootElement := sl2RootElement K
    rootElement_add := ?_
    closure_rootElement_eq_top := ?_
    rootElement_commute := ?_
    weylElement_conj_rootElement := ?_ }, rfl, ?_⟩
  · intro root hr a b
    rw [hroots] at hr
    rcases hr with rfl | rfl
    · simp only [sl2RootElement_single]; exact upperTransvection_add a b
    · simp only [sl2RootElement_neg_single]; exact lowerTransvection_add a b
  · refine top_unique ?_
    rw [← Matrix.SpecialLinearGroup.closure_range_toSpecialLinearGroup_eq_top_of_field (ι := Fin 2)
      (K := K)]
    refine Subgroup.closure_mono ?_
    rintro _ ⟨⟨i, j, hij, c⟩, rfl⟩
    simp only [Matrix.TransvectionStruct.toSpecialLinearGroup_mk]
    fin_cases i <;> fin_cases j
    · exact absurd rfl hij
    · exact ⟨Pi.single 0 1, by rw [hroots]; simp, c, sl2RootElement_single c⟩
    · exact ⟨-Pi.single 0 1, by rw [hroots]; simp, c, sl2RootElement_neg_single c⟩
    · exact absurd rfl hij
  · intro r₁ h₁ r₂ h₂ hne _ a b
    rw [hroots] at h₁ h₂
    rcases h₁ with rfl | rfl <;> rcases h₂ with rfl | rfl
    · simp only [sl2RootElement_single, Commute, SemiconjBy, ← upperTransvection_add, add_comm]
    · exact absurd (by simp) hne
    · exact absurd (by simp) hne
    · simp only [sl2RootElement_neg_single, Commute, SemiconjBy, ← lowerTransvection_add,
        add_comm]
  · intro simple r hr
    obtain rfl : simple = 0 := Subsingleton.elim _ _
    refine ⟨-1, Or.inr rfl, fun t u ↦ ?_⟩
    rw [hroots] at hr
    rcases hr with rfl | rfl
    · have hsum : (∑ index : Fin 1, CartanMatrix.A 1 0 index *
          (Pi.single 0 1 : Fin 1 → ℤ) index) = 2 := by simp [CartanMatrix.A_one]
      rw [reflection_eq_neg, hsum, sl2RootElement_single, sl2RootElement_neg_single,
        weylElement_eq, mul_inv_eq_iff_eq_mul, weylElement_mul_upperTransvection]
      congr 2
      push_cast
      ring
    · have hsum : (∑ index : Fin 1, CartanMatrix.A 1 0 index *
          (-Pi.single 0 1 : Fin 1 → ℤ) index) = -2 := by simp [CartanMatrix.A_one]
      rw [reflection_eq_neg, hsum, neg_neg, sl2RootElement_single, sl2RootElement_neg_single,
        weylElement_eq, mul_inv_eq_iff_eq_mul, weylElement_mul_lowerTransvection]
      congr 2
      push_cast
      ring
  · intro r₁ h₁ r₂ h₂ hsum _
    exfalso
    rw [hroots] at h₁ h₂ hsum
    have h0 : ∀ z ∈ ({Pi.single 0 1, -Pi.single 0 1} : Set (Fin 1 → ℤ)), z 0 = 1 ∨ z 0 = -1 := by
      rintro z (rfl | rfl) <;> simp
    have a1 := h0 _ h₁
    have a2 := h0 _ h₂
    have a3 := h0 _ hsum
    simp only [Pi.add_apply] at a3
    omega

end SL2

end CFSGCorollary
