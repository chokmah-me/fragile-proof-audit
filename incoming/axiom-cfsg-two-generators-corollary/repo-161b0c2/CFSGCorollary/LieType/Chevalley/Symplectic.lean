module

public import CFSGCorollary.LieType.Steinberg.Basic
public import CFSG.LieType.Steinberg.Classical.Symplectic.Basic
import CFSG.LieType.Steinberg.Families
import CFSGCorollary.LieType.Steinberg.Commutator

/-!
# Steinberg data on the symplectic groups

We equip CFSG's model `StatedSp m K` of `Sp_{2m}(K)` over a finite field `K` with Steinberg data of
type `C_m` (CFSG's `cartanC m`), using CFSG's commutator formula and Chevalley extras.

## Main results

* `CFSGCorollary.Sp.exists_steinbergData`: Steinberg data on `StatedSp m K`, `m ≥ 2`, with unit
  single commutators when `(2 : K) ≠ 0`.
-/

@[expose] public section

namespace CFSGCorollary

open CFSG.Open

/-- Steinberg data on `Sp`: for a finite field `K` and `m ≥ 2`, `Sp.x m K` on `StatedSp m K`
satisfies (S0)–(S3) for `A = cartanC m`; if `(2 : K) ≠ 0` it has unit single commutators. (S4)
is imposed after passing to a centerless quotient, see `SteinbergData.mapSystem`. -/
theorem Sp.exists_steinbergData (m : ℕ) (hm : 2 ≤ m) (K : Type) [Field K] [Finite K] :
    ∃ data : SteinbergData (CFSG.LieType.Universal.Symplectic.cartanC m)
        (CFSG.LieType.Universal.Symplectic.isFiniteType_cartanC m) K (StatedSp m K),
      data.rootElement = CFSG.LieType.Steinberg.Sp.x m K ∧
        ((2 : K) ≠ 0 → data.HasUnitCommutatorConstants) := by
  obtain ⟨O⟩ := CFSG.LieType.Steinberg.nonempty_commOrder_ofCartan
    (CFSG.LieType.Universal.Symplectic.isFiniteType_cartanC m) (Dv := ∅) rfl
  have hcomm : CFSG.LieType.Steinberg.CommutatorFormula (CFSG.LieType.Steinberg.Sp.x m K) O
      CFSG.LieType.Steinberg.Sp.commC := CFSG.LieType.Steinberg.Sp.commutatorFormula O
  have hext := CFSG.LieType.Steinberg.Sp.chevalleyExtras hm O _ hcomm
  have hA := (CFSG.LieType.Steinberg.sp_conclusionA.{0} m K).1.1
  refine ⟨{
    rootElement := CFSG.LieType.Steinberg.Sp.x m K
    rootElement_add := fun root hr a b ↦ (hext.param root hr).2.1 a b
    closure_rootElement_eq_top := ?_
    rootElement_commute := fun α hα β hβ hαβ hnone c d ↦
      commute_of_commutatorFormula hcomm hα hβ hαβ hnone c d
    weylElement_conj_rootElement := fun i β hβ ↦ hext.weyl i β hβ }, rfl, ?_⟩
  · rw [eq_top_iff, ← hA]
    refine iSup₂_le fun γ hγ g hg ↦ ?_
    exact Subgroup.subset_closure ⟨γ, hγ, ((hext.param γ hγ).1 g).1 hg⟩
  · intro h2 α hα β hβ hsum honly
    have hmem : ((1, 1) : ℕ × ℕ) ∈ CFSG.LieType.Steinberg.expPairs
        (CFSG.LieType.Steinberg.Sp.Φ m K) α β :=
      ⟨one_pos, one_pos, by simp only [one_smul]; exact hsum⟩
    have hu : IsUnit ((CFSG.LieType.Steinberg.Sp.commC α β (1, 1) : ℤ) : K) := by
      rcases CFSG.LieType.Steinberg.Sp.commC_natAbs (F := K) hα hβ hmem with h | h <;>
        rcases Int.natAbs_eq_iff.1 h with h' | h' <;> rw [h'] <;> simp [h2]
    refine ⟨hu.unit, fun c d ↦ ?_⟩
    have hαβ : α + β ≠ 0 :=
      CFSG.LieType.RootSystem.ne_zero_of_mem_roots _ ∅ hsum
    exact commutator_eq_of_commutatorFormula hcomm hα hβ hαβ hsum honly c d

end CFSGCorollary
