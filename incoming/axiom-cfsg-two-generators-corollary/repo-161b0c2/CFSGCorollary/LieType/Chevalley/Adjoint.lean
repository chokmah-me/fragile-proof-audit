module

public import CFSGCorollary.LieType.Steinberg.Basic
public import CFSG.Blueprint.ChevalleyPinned
public import CFSG.LieType.Chevalley.RootOps.All
public import CFSG.LieType.Steinberg.Adjoint.Group
import CFSG.LieType.Chevalley.AdjointCenter
import CFSG.LieType.Chevalley.AllRootWeylConjugation
import CFSG.LieType.Chevalley.RootCommutator
import CFSG.LieType.SeitzGeneration.ExcOuterLeOne.A2Hom

/-!
# Steinberg systems on the exceptional adjoint groups

For `τ ∈ {F₄, E₆, E₇, E₈}` the root elements `xPar (rootOperatorFamily τ)` form a Steinberg system
on CFSG's adjoint group `adjointGroup τ K`, and for `G₂` the pinned root elements do. In the
simply laced case all roots have the same length, which forces the single commutator constants
to be units.

## Main results

* `CFSGCorollary.exists_steinbergSystem_adjointGroup`: types `F₄`, `E₆`, `E₇`, `E₈`, with unit
  single commutators for `E₆`, `E₇`, `E₈`.
* `CFSGCorollary.commutator_xPar_pair_F4`: single commutators of root elements in type `F₄`.
* `CFSGCorollary.exists_steinbergSystem_adjointGroup_G2`: type `G₂`.
-/

@[expose] public section

namespace CFSGCorollary

open CFSG.Blueprint.Chevalley (Tag ModGL pinnedX adjointGroup IsRoot)
open CFSG.LieType.Chevalley (rootOperatorFamily isFiniteType_cartan)
open CFSG.LieType.Steinberg.Adjoint (xPar NoG2 iform iform_self_cases iform_self_of_isRoot
  iform_add_left iform_add_right iform_sub_left iform_sub_right iform_comm)
open scoped commutatorElement

private theorem ne_of_isRoot_add {τ : Tag} (hN : NoG2 τ) {α β : Fin τ.rank → ℤ}
    (hα : IsRoot τ α) (hs : IsRoot τ (α + β)) : α ≠ β := by
  rintro rfl
  have h1 := iform_self_cases hN hα
  have h2 := iform_self_cases hN hs
  have : iform (α + α) (α + α) = 4 * iform α α := by
    simp only [iform_add_left, iform_add_right]; ring
  omega

private theorem iform_self_eq_two {τ : Tag} (hτ : τ = Tag.E6 ∨ τ = Tag.E7 ∨ τ = Tag.E8)
    {α : Fin τ.rank → ℤ} (hα : IsRoot τ α) : iform α α = 2 := by
  obtain ⟨j, hj⟩ := iform_self_of_isRoot hα
  have : τ.symmetrizer j j = 1 := by
    rcases hτ with rfl | rfl | rfl <;> simp [Tag.symmetrizer]
  rw [hj, this]; norm_num

private theorem not_isRoot_sub_of_isRoot_add {τ : Tag}
    (hτ : τ = Tag.E6 ∨ τ = Tag.E7 ∨ τ = Tag.E8) {α β : Fin τ.rank → ℤ} (hα : IsRoot τ α)
    (hβ : IsRoot τ β) (hs : IsRoot τ (α + β)) : ¬IsRoot τ (β - α) := by
  intro hd
  have h1 := iform_self_eq_two hτ hα
  have h2 := iform_self_eq_two hτ hβ
  have h3 := iform_self_eq_two hτ hs
  have h4 := iform_self_eq_two hτ hd
  simp only [iform_add_left, iform_add_right, iform_sub_left, iform_sub_right] at h3 h4
  rw [iform_comm β α] at h3 h4
  omega

/-- `F₄` and `E`: `xPar (rootOperatorFamily τ)` is a Steinberg system on the adjoint group; for
`E₆, E₇, E₈` it has unit single commutators. -/
theorem exists_steinbergSystem_adjointGroup {τ : Tag}
    (hτ : τ = Tag.F4 ∨ τ = Tag.E6 ∨ τ = Tag.E7 ∨ τ = Tag.E8)
    (K : Type) [Field K] [Finite K] :
    ∃ S : SteinbergSystem τ.cartan (isFiniteType_cartan τ) K ↥(adjointGroup τ K),
      S.rootElement = xPar (rootOperatorFamily τ) ∧
        (τ ≠ Tag.F4 → S.HasUnitCommutatorConstants) := by
  obtain ⟨D, hD, hN⟩ := CFSG.LieType.SeitzGeneration.ExcOuterLeOne.exists_adjData_valid_all hτ
  have hA := isFiniteType_cartan τ
  have hR (γ) : γ ∈ CFSG.LieType.RootSystem.roots hA ∅ ↔ IsRoot τ γ := by
    rw [CFSG.LieType.Steinberg.Adjoint.roots_eq_setOf_isRoot hA]; rfl
  set F := rootOperatorFamily τ with hF
  refine ⟨{
    rootElement := xPar F
    rootElement_add := fun _ _ _ _ ↦ CFSG.LieType.Steinberg.Adjoint.xPar_add _ _ _
    closure_rootElement_eq_top := ?_
    rootElement_commute := ?_
    weylElement_conj_rootElement := ?_
    center_eq_bot := CFSG.LieType.Chevalley.center_adjointGroup_eq_bot }, rfl, ?_⟩
  · rw [eq_top_iff, ← CFSG.LieType.Steinberg.Adjoint.iSup_rootGroup_eq_top F K]
    refine iSup₂_le fun γ hγ g hg ↦ ?_
    obtain ⟨c, rfl⟩ := CFSG.LieType.Steinberg.Adjoint.exists_of_mem_rootGroup hγ hg
    exact Subgroup.subset_closure
      ⟨γ, (hR γ).2 hγ, c, CFSG.LieType.Steinberg.Adjoint.xPar_of_isRoot hγ c⟩
  · intro α hα β hβ hne hn a b
    refine CFSG.LieType.Steinberg.Adjoint.commute_xPar hD hN ((hR _).1 hα) ((hR _).1 hβ) hne ?_
      a b
    have := hn 1 1 one_pos one_pos
    rw [hR] at this
    simpa using this
  · intro i β hβ
    exact CFSG.LieType.Steinberg.Adjoint.weylElement_xPar_conj i ((hR _).1 hβ)
  · intro hne
    have hτ' : τ = Tag.E6 ∨ τ = Tag.E7 ∨ τ = Tag.E8 := by
      rcases hτ with h | h | h | h
      · exact absurd h hne
      all_goals tauto
    intro α hα β hβ hs hdiv
    rw [hR] at hα hβ hs
    have hd := not_isRoot_sub_of_isRoot_add hτ' hα hβ hs
    have h12 : ¬IsRoot τ (α + (2 : ℕ) • β) := fun h ↦ by
      have := hdiv 1 2 one_pos two_pos (by rw [hR]; simpa using h)
      omega
    have h21 : ¬IsRoot τ ((2 : ℕ) • α + β) := fun h ↦ by
      have := hdiv 2 1 two_pos one_pos (by rw [hR]; simpa using h)
      omega
    obtain ⟨ε, hε, hc⟩ := CFSG.LieType.SeitzGeneration.ExcOuterLeOne.commutator_xPar_pair (K := K)
      hD hN hα hβ (ne_of_isRoot_add hN hα hs)
      (fun h ↦ CFSG.Blueprint.Chevalley.IsRoot.ne_zero hs (by rw [h]; simp)) hs hd h12 h21
    have hu : IsUnit (ε : K) := by
      rcases hε with rfl | rfl <;> simp
    refine ⟨hu.unit, fun a b ↦ ?_⟩
    simpa [commutatorElement_def] using hc a b

/-- `F₄`: single commutators of root elements for pairs with `α + β ∈ Φ` and
`β − α, α + 2β, 2α + β ∉ Φ`. -/
theorem commutator_xPar_pair_F4 {K : Type} [Field K] {α β : Fin Tag.F4.rank → ℤ}
    (hα : IsRoot Tag.F4 α) (hβ : IsRoot Tag.F4 β) (hs : IsRoot Tag.F4 (α + β))
    (hd : ¬IsRoot Tag.F4 (β - α)) (h12 : ¬IsRoot Tag.F4 (α + (2 : ℕ) • β))
    (h21 : ¬IsRoot Tag.F4 ((2 : ℕ) • α + β)) :
    ∃ ε : ℤ, (ε = 1 ∨ ε = -1) ∧ ∀ a b : K,
      ⁅xPar (rootOperatorFamily Tag.F4) α a, xPar (rootOperatorFamily Tag.F4) β b⁆ =
        xPar (rootOperatorFamily Tag.F4) (α + β) ((ε : K) * a * b) := by
  obtain ⟨D, hD, hN⟩ := CFSG.LieType.SeitzGeneration.ExcOuterLeOne.exists_adjData_valid_all
    (Or.inl rfl : Tag.F4 = Tag.F4 ∨ _)
  exact CFSG.LieType.SeitzGeneration.ExcOuterLeOne.commutator_xPar_pair hD hN hα hβ
    (ne_of_isRoot_add hN hα hs)
    (fun h ↦ CFSG.Blueprint.Chevalley.IsRoot.ne_zero hs (by rw [h]; simp)) hs hd h12 h21

/-- `G₂`: the pinned root elements form a Steinberg system on the adjoint group. -/
theorem exists_steinbergSystem_adjointGroup_G2 (K : Type) [Field K] [Finite K] :
    ∃ S : SteinbergSystem Tag.G2.cartan (isFiniteType_cartan Tag.G2) K ↥(adjointGroup Tag.G2 K),
      ∀ (α : Fin Tag.G2.rank → ℤ) (c : K),
        ((S.rootElement α c : ↥(adjointGroup Tag.G2 K)) : ModGL Tag.G2 K) =
          pinnedX Tag.G2 K α c := by
  have hA := isFiniteType_cartan Tag.G2
  have hR (γ) : γ ∈ CFSG.LieType.RootSystem.roots hA ∅ ↔ IsRoot Tag.G2 γ := by
    rw [CFSG.LieType.Steinberg.Adjoint.roots_eq_setOf_isRoot hA]; rfl
  let X : (Fin Tag.G2.rank → ℤ) → K → ↥(adjointGroup Tag.G2 K) := fun α c ↦
    ⟨pinnedX Tag.G2 K α c, CFSG.Blueprint.Chevalley.pinnedX_mem_adjointGroup α c⟩
  have hadd (α a b) : X α (a + b) = X α a * X α b :=
    Subtype.ext (CFSG.Blueprint.Chevalley.pinnedX_add Tag.G2 K α a b)
  have hgen : Subgroup.closure {element : ↥(adjointGroup Tag.G2 K) |
      ∃ root ∈ CFSG.LieType.RootSystem.roots hA ∅, ∃ parameter : K, X root parameter = element} =
        ⊤ := by
    set H := Subgroup.closure {element : ↥(adjointGroup Tag.G2 K) |
      ∃ root ∈ CFSG.LieType.RootSystem.roots hA ∅, ∃ parameter : K, X root parameter = element}
    rw [eq_top_iff]
    intro g _
    have hle : CFSG.Blueprint.Chevalley.rootSpan Tag.G2 K {α | IsRoot Tag.G2 α} ≤
        H.map (adjointGroup Tag.G2 K).subtype := by
      unfold CFSG.Blueprint.Chevalley.rootSpan
      refine iSup₂_le fun α hα ↦ (Subgroup.closure_le _).2 ?_
      rintro _ ⟨c, rfl⟩
      exact ⟨X α c, Subgroup.subset_closure ⟨α, (hR α).2 hα, c, rfl⟩, rfl⟩
    have h1 : (g : ModGL Tag.G2 K) ∈
        CFSG.Blueprint.Chevalley.rootSpan Tag.G2 K {α | IsRoot Tag.G2 α} := by
      rw [← CFSG.Blueprint.Chevalley.adjointGroup_eq_rootSpan]; exact g.2
    obtain ⟨h, hh, he⟩ := hle h1
    rwa [← Subtype.ext he]
  have hcomm : ∀ α β, IsRoot Tag.G2 α → IsRoot Tag.G2 β → α + β ≠ 0 →
      (∀ first second : ℕ, 0 < first → 0 < second → ¬IsRoot Tag.G2 (first • α + second • β)) →
        ∀ a b : K, Commute (X α a) (X β b) := by
    intro α β hα hβ hne hn a b
    by_cases hαβ : α = β
    · subst hαβ
      rw [Commute, SemiconjBy, ← hadd, ← hadd, add_comm]
    · have hne' : α ≠ -β := fun h ↦ hne (by rw [h]; simp)
      obtain ⟨-, hmem, -, -, hform⟩ :=
        CFSG.LieType.Chevalley.root_commutator_formula Tag.G2 hα hβ hαβ hne'
      have hnil : CFSG.LieType.Chevalley.commPairs Tag.G2 α β = [] :=
        List.eq_nil_iff_forall_not_mem.2 fun p hp ↦ by
          obtain ⟨h1, h2, h3⟩ := (hmem p).1 hp
          exact hn p.1 p.2 h1 h2 h3
      have h := hform K a b
      rw [hnil] at h
      simp only [List.map_nil, List.prod_nil] at h
      rw [← CFSG.Blueprint.Chevalley.pinnedX_neg, ← CFSG.Blueprint.Chevalley.pinnedX_neg] at h
      have hc : Commute (pinnedX Tag.G2 K α a) (pinnedX Tag.G2 K β b) := by
        rw [← commutatorElement_eq_one_iff_commute, commutatorElement_def]
        simpa using h
      exact Subtype.ext hc.eq
  have hweyl (i : Fin Tag.G2.rank) (t : Kˣ) :
      ((CFSG.LieType.Steinberg.weylElement X i t : ↥(adjointGroup Tag.G2 K)) : ModGL Tag.G2 K) =
        CFSG.Blueprint.Chevalley.weylElt Tag.G2 K i t := by
    rw [CFSG.Blueprint.Chevalley.weylElt_eq_xUnit_mul]
    change pinnedX Tag.G2 K (Pi.single i 1) (t : K) *
        pinnedX Tag.G2 K (-Pi.single i 1) (-((t⁻¹ : Kˣ) : K)) *
          pinnedX Tag.G2 K (Pi.single i 1) (t : K) = _
    rw [CFSG.Blueprint.Chevalley.pinnedX_single, CFSG.Blueprint.Chevalley.pinnedX_neg_single]
  refine ⟨{
    rootElement := X
    rootElement_add := fun α _ a b ↦ hadd α a b
    closure_rootElement_eq_top := hgen
    rootElement_commute := ?_
    weylElement_conj_rootElement := ?_
    center_eq_bot := CFSG.LieType.Chevalley.center_adjointGroup_eq_bot }, fun α c ↦ rfl⟩
  · intro α hα β hβ hne hn a b
    refine hcomm α β ((hR _).1 hα) ((hR _).1 hβ) hne (fun p q hp hq h ↦ ?_) a b
    exact hn p q hp hq ((hR _).2 h)
  · intro i β hβ
    have hβ' := (hR _).1 hβ
    refine ⟨CFSG.LieType.Chevalley.allRootWeylSign Tag.G2 i β,
      (CFSG.LieType.Chevalley.all_root_weyl_infinitesimal.{0} Tag.G2).2.2.2.1 i β hβ',
      fun t u ↦ Subtype.ext ?_⟩
    have hr : CFSG.LieType.RootSystem.reflection Tag.G2.cartan i β =
        CFSG.Blueprint.Chevalley.reflect Tag.G2 i β := by
      rw [CFSG.LieType.RootSystem.reflection_apply]; rfl
    change ((CFSG.LieType.Steinberg.weylElement X i t : ↥(adjointGroup Tag.G2 K)) :
        ModGL Tag.G2 K) * pinnedX Tag.G2 K β u *
      ((CFSG.LieType.Steinberg.weylElement X i t : ↥(adjointGroup Tag.G2 K)) :
        ModGL Tag.G2 K)⁻¹ = _
    rw [hweyl, CFSG.LieType.Chevalley.all_root_weyl_conjugation Tag.G2 K i hβ' t u, hr]

end CFSGCorollary
