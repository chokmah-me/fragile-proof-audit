module

public import CFSGCorollary.LieType.Steinberg.Basic
public import CFSG.LieType.Steinberg.Classical.SpinOdd.Basic
public import CFSG.LieType.Steinberg.Classical.SpinPlus.Basic
import CFSG.LieType.Steinberg.Families
import CFSGCorollary.LieType.Steinberg.Commutator

/-!
# Steinberg data on the spin groups

We equip CFSG's spin groups over a finite field `K` with Steinberg data: the odd spin group
`spinGroup (quadOdd m K)` with data of type `B_m` (CFSG's `cartanB m`), and the split even spin
group `spinGroup (quadPlus m K)` with data of type `D_m` (CFSG's `cartanD m`).

## Main results

* `CFSGCorollary.SpinOdd.exists_steinbergData`: type `B_m`, `m ≥ 3`, `(2 : K) ≠ 0`.
* `CFSGCorollary.SpinPlus.exists_steinbergData`: type `D_m`, `m ≥ 4`, with unit single
  commutators.
-/

@[expose] public section

namespace CFSGCorollary

/-- Steinberg data on odd `Spin`: for a finite field `K` with `(2 : K) ≠ 0` and `m ≥ 3`,
`SpinOdd.x m K` on `spinGroup (quadOdd m K)` satisfies (S0)–(S3) for `A = cartanB m`. (S4) is
imposed after passing to a centerless quotient, see `SteinbergData.mapSystem`. -/
theorem SpinOdd.exists_steinbergData (m : ℕ) (hm : 3 ≤ m) (K : Type) [Field K] [Finite K]
    (h2 : (2 : K) ≠ 0) :
    ∃ data : SteinbergData (CFSG.LieType.Universal.Spin.cartanB m)
        (CFSG.LieType.Universal.Spin.isFiniteType_cartanB m) K
        (spinGroup (CFSG.LieType.Universal.Spin.quadOdd m K)),
      data.rootElement = CFSG.LieType.Steinberg.SpinOdd.x m K := by
  obtain ⟨O⟩ := CFSG.LieType.Steinberg.nonempty_commOrder_ofCartan
    (CFSG.LieType.Universal.Spin.isFiniteType_cartanB m) (Dv := ∅) rfl
  have hC := CFSG.LieType.Steinberg.SpinOdd.commutatorFormula (n := m) (K := K) O
  have hE := CFSG.LieType.Steinberg.SpinOdd.chevalleyExtras (n := m) (K := K) (by omega) O _ hC
  have hA := (CFSG.LieType.Steinberg.spinOdd_conclusionA.{0} m K h2 hm).1
  refine ⟨{
    rootElement := CFSG.LieType.Steinberg.SpinOdd.x m K
    rootElement_add := fun root hr a b ↦ (hE.param root hr).2.1 a b
    closure_rootElement_eq_top := ?_
    rootElement_commute := fun α hα β hβ hαβ hnone c d ↦
      commute_of_commutatorFormula hC hα hβ hαβ hnone c d
    weylElement_conj_rootElement := fun i β hβ ↦ hE.weyl i β hβ }, rfl⟩
  rw [eq_top_iff, ← hA.1]
  refine iSup₂_le fun γ hγ g hg ↦ Subgroup.subset_closure ⟨γ, hγ, ?_⟩
  exact ((hE.param γ hγ).1 g).1 hg

/-- Steinberg data on split even `Spin`: for a finite field `K` and `m ≥ 4`,
`SpinPlus.x m K _` on `spinGroup (quadPlus m K)` satisfies (S0)–(S3) for `A = cartanD m` and has
unit single commutators. (S4) is imposed after passing to a centerless quotient, see
`SteinbergData.mapSystem`. -/
theorem SpinPlus.exists_steinbergData (m : ℕ) (hm : 4 ≤ m) (K : Type) [Field K] [Finite K] :
    ∃ data : SteinbergData (CFSG.LieType.Universal.Spin.cartanD m)
        (CFSG.LieType.Universal.Spin.isFiniteType_cartanD m) K
        (spinGroup (CFSG.LieType.Universal.Spin.quadPlus m K)),
      data.rootElement = CFSG.LieType.Steinberg.SpinPlus.x m K (by omega) ∧
        data.HasUnitCommutatorConstants := by
  have hn : 3 ≤ m := by omega
  obtain ⟨O⟩ := CFSG.LieType.Steinberg.nonempty_commOrder_ofCartan
    (CFSG.LieType.Universal.Spin.plusDatum m K hn).isFiniteType
    (Dv := (CFSG.LieType.Universal.Spin.plusDatum m K hn).divisible) rfl
  have hC := CFSG.LieType.Steinberg.SpinPlus.commutatorFormula hn O
  have hE := CFSG.LieType.Steinberg.SpinPlus.chevalleyExtras hn O _ hC
  obtain ⟨⟨hgen, -⟩, -⟩ := CFSG.LieType.Steinberg.spinPlus_conclusionA.{0} m K hn
  refine ⟨{
    rootElement := CFSG.LieType.Steinberg.SpinPlus.x m K hn
    rootElement_add := fun root hr c d ↦ (hE.param root hr).2.1 c d
    closure_rootElement_eq_top := ?_
    rootElement_commute := fun α hα β hβ hne hnone c d ↦
      commute_of_commutatorFormula hC hα hβ hne hnone c d
    weylElement_conj_rootElement := fun i root hr ↦ hE.weyl i root hr }, rfl, ?_⟩
  · rw [eq_top_iff, ← hgen]
    refine iSup₂_le fun γ hγ g hg ↦ ?_
    obtain ⟨c, hc⟩ := ((hE.param γ hγ).1 g).1 hg
    exact Subgroup.subset_closure ⟨γ, hγ, c, hc⟩
  · intro α hα β hβ hsum honly
    obtain ⟨u, hu⟩ : IsUnit ((CFSG.LieType.Steinberg.SpinPlus.commC α β (1, 1) : ℤ) : K) :=
      (Int.isUnit_iff_natAbs_eq.2 (CFSG.LieType.Steinberg.SpinPlus.commC_natAbs α β (1, 1))).map
        (Int.castRingHom K)
    refine ⟨u, fun c d ↦ ?_⟩
    have hne : α + β ≠ 0 :=
      CFSG.LieType.RootSystem.ne_zero_of_mem_roots
        (CFSG.LieType.Universal.Spin.isFiniteType_cartanD m) ∅ hsum
    rw [hu]
    exact commutator_eq_of_commutatorFormula hC hα hβ hne hsum honly c d

end CFSGCorollary
