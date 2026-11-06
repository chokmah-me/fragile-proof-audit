module

public import CFSGCorollary.LieType.Twisted.ReeF4.Basic
public import CFSGCorollary.TwoGenerated.Basic
public import CFSG.LieType.Ree.LocalBlockSylowAction
import CFSG.RankThree.PartOne.SEITZX.ReeSplit
import CFSGCorollary.LieType.LambdaRootGroup.ClosurePair
import CFSGCorollary.LieType.Twisted.ReeF4.Actions
import CFSGCorollary.LieType.Twisted.ReeF4.Scalars

/-!
# The large Ree groups `²F₄(q)` are two-generated

Let `u` generate `Kˣ`. We show that `a = d = torusPair (u, u²)` and
`b = y 1 * x_s (1, 0) * g` generate the large Ree group `Γ = F4.reeGamma K m`:

* the λ-root groups `X_r = X_{-S₂}` and `X_s = X_{S₁}` commute elementwise, and the commuting
  torus elements `d`, `d₁ = g d g⁻¹`, `d₂ = g⁻¹ d g` act on them by generating scalars, so
  `⟨a, b⟩` contains `X_r`, `X_s` and `g`;
* conjugating by `g ^ 4` gives the opposite root groups `X_{S₂}` and `X_{-S₁}`, and the four
  root groups generate `Γ`.

## Main results

* `CFSGCorollary.ReeF4.closure_fixedTorusElt_secondGenerator_eq_reeGamma`: `⟨a, b⟩ = Γ`.
* `CFSGCorollary.twoGenerated_reeF4`: every simple `²F₄(q)` is two-generated.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

noncomputable section

namespace CFSGCorollary.ReeF4

open CFSG.Blueprint.Chevalley CFSG.LieType.Chevalley CFSG.LieType.Ree CFSG.LieType.Ree.ReeTag

variable {K : Type} [Field K] [Finite K] [CharP K F4.prime] {m : ℕ}

/-! ### `X_{-S₂}` and `X_{S₁}` commute elementwise -/

omit [Finite K] [CharP K F4.prime] in
theorem commute_of_mem_rootSpan_of_mem_rootSpan {S T : Set (Fin F4.tag.rank → ℤ)}
    (h : ∀ α ∈ S, ∀ β ∈ T, ∀ c d : K, Commute (pinnedX F4.tag K α c) (pinnedX F4.tag K β d))
    {x y : ModGL F4.tag K} (hx : x ∈ rootSpan F4.tag K S) (hy : y ∈ rootSpan F4.tag K T) :
    Commute x y := by
  have h1 : ∀ α ∈ S, ∀ β ∈ T, rootSubgroup F4.tag K α ≤
      Subgroup.centralizer (rootSubgroup F4.tag K β : Set (ModGL F4.tag K)) := by
    intro α hα β hβ
    unfold rootSubgroup
    rw [Subgroup.closure_le]
    rintro _ ⟨c, rfl⟩ z hz
    have : rootSubgroup F4.tag K β ≤ Subgroup.centralizer {pinnedX F4.tag K α c} := by
      unfold rootSubgroup
      rw [Subgroup.closure_le]
      rintro _ ⟨d, rfl⟩
      simp only [SetLike.mem_coe, Subgroup.mem_centralizer_iff, Set.mem_singleton_iff,
        forall_eq]
      exact (h α hα β hβ c d).eq
    have := this hz
    rw [Subgroup.mem_centralizer_iff] at this
    exact (this _ rfl).symm
  have h2 : ∀ α ∈ S, rootSubgroup F4.tag K α ≤
      Subgroup.centralizer (rootSpan F4.tag K T : Set (ModGL F4.tag K)) := by
    intro α hα
    have : rootSpan F4.tag K T ≤
        Subgroup.centralizer (rootSubgroup F4.tag K α : Set (ModGL F4.tag K)) := by
      unfold rootSpan
      refine iSup₂_le fun β hβ ↦ ?_
      intro z hz
      rw [Subgroup.mem_centralizer_iff]
      intro g hg
      have := h1 α hα β hβ hg
      rw [Subgroup.mem_centralizer_iff] at this
      exact (this z hz).symm
    intro g hg z hz
    exact (this hz g hg).symm
  have h3 : rootSpan F4.tag K S ≤
      Subgroup.centralizer (rootSpan F4.tag K T : Set (ModGL F4.tag K)) :=
    iSup₂_le h2
  have := h3 hx
  rw [Subgroup.mem_centralizer_iff] at this
  exact (this y hy).symm

theorem commute_of_mem_rootSubgroupR_of_mem_rootSubgroupS {x y : ModGL F4.tag K}
    (hx : x ∈ rootSubgroupR K m) (hy : y ∈ rootSubgroupS K m) : Commute x y := by
  have hx' : x ∈ rootSpan F4.tag K (Neg.neg '' F4.fixedOrbitRoots ⟨0, by decide⟩) :=
    hx.1
  have hy' : y ∈ rootSpan F4.tag K (parabolicPosRoots Tag.F4 largeReeBlock) := by
    have := hy.1
    rwa [F4_fixedOrbitRoots_one] at this
  refine commute_of_mem_rootSpan_of_mem_rootSpan ?_ hx' hy'
  intro α hα β hβ c d
  rw [F4_fixedOrbitRoots_zero] at hα
  obtain ⟨α', hα', rfl⟩ := hα
  obtain ⟨i, rfl⟩ := (mem_largeReeBlockRoots).1 hβ
  have hα1 : -α' ∈ ({-(Pi.single largeReeI1 (1 : ℤ)), -(Pi.single largeReeI4 (1 : ℤ))} :
      Set (Fin F4.tag.rank → ℤ)) := by
    rcases hα' with rfl | rfl <;> simp
  have hβ1 : largeReeRoot i ∈ ({f4RootVector 0 0 1 0, f4RootVector 0 1 0 0,
      f4RootVector 0 1 1 0, f4RootVector 0 1 2 0} : Set (Fin F4.tag.rank → ℤ)) := by
    fin_cases i
    · exact Or.inl rfl
    · exact Or.inr (Or.inl rfl)
    · exact Or.inr (Or.inr (Or.inl rfl))
    · exact Or.inr (Or.inr (Or.inr rfl))
  obtain ⟨-, hne, hne'⟩ := not_isRoot_orbit_sum hα1 hβ1 1 1 one_pos one_pos
  refine commute_pinnedX_of_forall_not_isRoot K ?_ (largeReeRoot_pos i).1 hne hne' ?_ c d
  · rcases hα' with rfl | rfl <;> exact isRoot_neg_single _ _
  · intro a b ha hb
    exact (not_isRoot_orbit_sum hα1 hβ1 a b ha hb).1

/-! ### `g ^ 4` exchanges each simple root group with its opposite -/

theorem coxeterRep_pow_conj_mem_rootSpan_inf {S : Set (Fin F4.tag.rank → ℤ)}
    (hS : ∀ α ∈ S, IsRoot F4.tag α) {x : ModGL F4.tag K}
    (hx : x ∈ rootSpan F4.tag K S ⊓ F4.reeGamma K m) (n : ℕ) :
    coxeterRep K ^ n * x * (coxeterRep K ^ n)⁻¹ ∈
      rootSpan F4.tag K ((fun β ↦ coxeterWeylElement ^ n • β) '' S) ⊓ F4.reeGamma K m := by
  induction n with
  | zero => simpa using hx
  | succ n ih =>
    have h := coxeterRep_conj_mem_rootSpan_inf (m := m)
      (S := (fun β ↦ coxeterWeylElement ^ n • β) '' S)
      (by rintro _ ⟨β, hβ, rfl⟩; exact IsRoot.smul (hS β hβ) _) ih
    have e : (fun β ↦ coxeterWeylElement • β) '' ((fun β ↦ coxeterWeylElement ^ n • β) '' S) =
        (fun β ↦ coxeterWeylElement ^ (n + 1) • β) '' S := by
      rw [Set.image_image]
      simp [pow_succ', mul_smul]
    rw [e] at h
    have e2 : coxeterRep K ^ (n + 1) * x * (coxeterRep K ^ (n + 1))⁻¹ =
        coxeterRep K * (coxeterRep K ^ n * x * (coxeterRep K ^ n)⁻¹) * (coxeterRep K)⁻¹ := by
      simp [pow_succ', mul_assoc]
    rw [e2]
    exact h

/-- A subgroup containing `X_r`, `X_s` and `g` contains the opposite root groups `X_{S₂}` and
`X_{-S₁}`. -/
theorem opposite_rootSubgroups_le {F : Subgroup (ModGL F4.tag K)}
    (hXr : rootSubgroupR K m ≤ F) (hXs : rootSubgroupS K m ≤ F) (hg : coxeterRep K ∈ F) :
    F4.reeFixedOrbitUnipotent K m ⟨0, by decide⟩ ≤ F ∧
      F4.reeFixedOrbitNegUnipotent K m ⟨1, by decide⟩ ≤ F := by
  have hg4 : coxeterRep K ^ 4 ∈ F := F.pow_mem hg 4
  have key : ∀ (S T : Set (Fin F4.tag.rank → ℤ)) (A B : Subgroup (ModGL F4.tag K)),
      (∀ α ∈ S, IsRoot F4.tag α) → A = rootSpan F4.tag K S ⊓ F4.reeGamma K m →
      B = rootSpan F4.tag K T ⊓ F4.reeGamma K m →
      (fun β ↦ coxeterWeylElement ^ 4 • β) '' S = T → B ≤ F → A ≤ F := by
    intro S T A B hS hA hB hST hBF x hx
    have h := coxeterRep_pow_conj_mem_rootSpan_inf (m := m) hS (hA ▸ hx) 4
    rw [hST, ← hB] at h
    have h2 := F.mul_mem (F.mul_mem (F.inv_mem hg4) (hBF h)) (F.inv_mem (F.inv_mem hg4))
    simpa [mul_assoc] using h2
  have h1 : (Pi.single largeReeI1 (1 : ℤ) : Fin F4.tag.rank → ℤ) = f4RootVector 1 0 0 0 := by
    funext i; fin_cases i <;> rfl
  have h4 : (Pi.single largeReeI4 (1 : ℤ) : Fin F4.tag.rank → ℤ) = f4RootVector 0 0 0 1 := by
    funext i; fin_cases i <;> rfl
  have hroot : ∀ i : Fin 4, largeReeRoot i ∈ ({f4RootVector 1 0 0 0, f4RootVector 0 0 0 1,
      f4RootVector 0 0 1 0, f4RootVector 0 1 0 0, f4RootVector 0 1 1 0,
      f4RootVector 0 1 2 0} : Set (Fin F4.tag.rank → ℤ)) := by
    intro i
    fin_cases i
    · exact Or.inr (Or.inr (Or.inl rfl))
    · exact Or.inr (Or.inr (Or.inr (Or.inl rfl)))
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl rfl))))
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr rfl))))
  constructor
  · refine key (F4.fixedOrbitRoots ⟨0, by decide⟩) (Neg.neg '' F4.fixedOrbitRoots ⟨0, by decide⟩)
      _ (rootSubgroupR K m) ?_ rfl rfl ?_ hXr
    · intro α hα
      exact ((mem_fixedOrbitRoots _).1 hα).1.1
    · rw [F4_fixedOrbitRoots_zero, h1, h4, Set.image_pair]
      simp only [Set.image_insert_eq, Set.image_singleton]
      rw [(coxeterWeylElement_pow_four_smul _ (by simp)).1,
        (coxeterWeylElement_pow_four_smul (f4RootVector 0 0 0 1) (by simp)).1]
  · refine key (Neg.neg '' F4.fixedOrbitRoots ⟨1, by decide⟩) (F4.fixedOrbitRoots ⟨1, by decide⟩)
      _ (rootSubgroupS K m) ?_ rfl rfl ?_ hXs
    · rintro _ ⟨α, hα, rfl⟩
      exact IsRoot.neg ((mem_fixedOrbitRoots _).1 hα).1.1
    · ext γ
      constructor
      · rintro ⟨_, ⟨α, hα, rfl⟩, rfl⟩
        have hα' := hα
        rw [F4_fixedOrbitRoots_one] at hα'
        obtain ⟨i, rfl⟩ := mem_largeReeBlockRoots.1 hα'
        have := (coxeterWeylElement_pow_four_smul (largeReeRoot i) (hroot i)).2
        exact (congrArg (fun x ↦ x ∈ F4.fixedOrbitRoots ⟨1, by decide⟩) this).mpr hα
      · intro hγ
        have hα' := hγ
        rw [F4_fixedOrbitRoots_one] at hα'
        obtain ⟨i, rfl⟩ := mem_largeReeBlockRoots.1 hα'
        have := (coxeterWeylElement_pow_four_smul (largeReeRoot i) (hroot i)).2
        exact ⟨_, ⟨largeReeRoot i, hγ, rfl⟩, this⟩

/-! ### The pair generates the large Ree group -/

/-- The subgroup `⟨a, b⟩` contains `X_r`, `X_s` and `g`. -/
theorem rootSubgroups_le_closure_and_coxeterRep_mem (hm : 1 ≤ m)
    (hK : Nat.card K = 2 ^ (2 * m + 1)) {u : Kˣ} (hu : orderOf u = Nat.card K - 1) :
    rootSubgroupR K m ≤ Subgroup.closure {fixedTorusElt m u, secondGenerator K m} ∧
      rootSubgroupS K m ≤ Subgroup.closure {fixedTorusElt m u, secondGenerator K m} ∧
      coxeterRep K ∈ Subgroup.closure {fixedTorusElt m u, secondGenerator K m} := by
  obtain ⟨aDS⟩ := nonempty_action_fixedTorusElt_lambdaRootGroupS hm hK u
  obtain ⟨aD₁S⟩ := nonempty_action_fixedTorusEltConj_lambdaRootGroupS hm hK u
  obtain ⟨aD₁R⟩ := nonempty_action_fixedTorusEltConj_lambdaRootGroupR hK u
  obtain ⟨aD₂R⟩ := nonempty_action_fixedTorusEltConjInv_lambdaRootGroupR hK u
  have hmemR : rootElemR m (1 : K) ∈ rootSubgroupR K m := rootElemR_mem_rootSubgroupR hK 1
  have hmemS : rootElemS m (1 : K) 0 ∈ rootSubgroupS K m := rootElemS_mem_rootSubgroupS hK _ _
  have hgood : ∀ e ∈ ({3 * 2 ^ m - 2, 2 - 2 * 2 ^ m, 1 - 2 ^ m, 2 * 2 ^ m - 2} : Set ℤ),
      IsNontrivialGeneratingScalar (u ^ e) :=
    fun _ he ↦ isGoodScalar_zpow_torusExponent hm hK hu he
  exact LambdaRootGroup.le_closure_pair_mul_mul (lambdaRootGroupR hK) (lambdaRootGroupS hm hK)
    (fun a ha b hb ↦ commute_of_mem_rootSubgroupR_of_mem_rootSubgroupS ha hb)
    (fixedTorusElt m u) (coxeterRep K) (u ^ (3 * 2 ^ m - 2 : ℤ)) (u ^ (2 - 2 * 2 ^ m : ℤ))
    (u ^ (1 - 2 ^ m : ℤ)) (u ^ (2 * 2 ^ m - 2 : ℤ))
    (hgood _ (by simp)) (hgood _ (by simp)) (hgood _ (by simp)) (hgood _ (by simp))
    (commute_fixedTorusElt_fixedTorusEltConj hK u)
    (commute_fixedTorusElt_fixedTorusEltConjInv hK u)
    (commute_fixedTorusEltConj_fixedTorusEltConjInv hK u)
    (fun a ha ↦ commute_fixedTorusElt_of_mem_rootSubgroupR hK u ha)
    aDS aD₁R aD₁S aD₂R ⟨_, hmemR⟩ ⟨_, hmemS⟩
    (by
      change Multiplicative.toAdd (coordinateR hK ⟨rootElemR m 1, hmemR⟩) ≠ 0
      rw [coordinateR_rootElemR hK]; simp)
    (by
      change Multiplicative.toAdd (coordinateS hK ⟨rootElemS m 1 0, hmemS⟩) ≠ 0
      rw [coordinateS_rootElemS hK]; simp)

/-- `⟨a, b⟩ = Γ`, as subgroups of `ModGL F4.tag K`. -/
theorem closure_fixedTorusElt_secondGenerator_eq_reeGamma (hm : 1 ≤ m)
    (hK : Nat.card K = 2 ^ (2 * m + 1)) {u : Kˣ} (hu : orderOf u = Nat.card K - 1) :
    Subgroup.closure {fixedTorusElt m u, secondGenerator K m} = F4.reeGamma K m := by
  have hXr : rootSubgroupR K m ≤ F4.reeGamma K m := inf_le_right
  have hXs : rootSubgroupS K m ≤ F4.reeGamma K m := inf_le_right
  apply le_antisymm
  · rw [Subgroup.closure_le]
    rintro x (rfl | rfl)
    · exact LargeReeCover.torusPair_mem_reeGamma m hK _
    · exact mul_mem (mul_mem (hXr (rootElemR_mem_rootSubgroupR hK 1))
        (hXs (rootElemS_mem_rootSubgroupS hK 1 0))) coxeterRep_mem_reeGamma
  · obtain ⟨hr, hs, hg⟩ := rootSubgroups_le_closure_and_coxeterRep_mem hm hK hu
    obtain ⟨h0, h1⟩ := opposite_rootSubgroups_le hr hs hg
    rw [large_Ree_simple_pair_generation m K hK]
    exact sup_le (sup_le h0 hr) (sup_le hs h1)

/-- The large Ree group `F4.reeGamma K m` is two-generated. -/
theorem twoGenerated_reeGamma (hm : 1 ≤ m) (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    TwoGenerated (F4.reeGamma K m) := by
  obtain ⟨u, hu⟩ := IsCyclic.exists_generator (α := Kˣ)
  have hord : orderOf u = Nat.card K - 1 := by
    rw [orderOf_eq_card_of_forall_mem_zpowers hu, Nat.card_units]
  have hmem := closure_fixedTorusElt_secondGenerator_eq_reeGamma hm hK hord
  have ha : fixedTorusElt m u ∈ F4.reeGamma K m := hmem ▸ Subgroup.subset_closure (by simp)
  have hb : secondGenerator K m ∈ F4.reeGamma K m := hmem ▸ Subgroup.subset_closure (by simp)
  refine ⟨⟨_, ha⟩, ⟨_, hb⟩, ?_⟩
  apply Subgroup.map_injective (Subgroup.subtype_injective (F4.reeGamma K m))
  rw [MonoidHom.map_closure, Subgroup.map_top, Subgroup.range_subtype,
    Set.image_insert_eq, Set.image_singleton]
  exact hmem

end CFSGCorollary.ReeF4

namespace CFSGCorollary

/-- Every simple large Ree group `²F₄(2 ^ (2m+1))` is two-generated. -/
theorem twoGenerated_reeF4 (m : ℕ)
    (hv : (TauCeti.LieTypeIndex.reeF4 m).Valid)
    [Finite (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.reeF4 m, hv⟩)]
    [IsSimpleGroup (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.reeF4 m, hv⟩)] :
    TwoGenerated (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.reeF4 m, hv⟩) := by
  obtain ⟨X, _, _, _, hm, hX, ⟨e⟩⟩ :=
    CFSG.RankThree.PartOne.SEITZX.exists_reeGamma_model (m := m)
      (K := TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.reeF4 m, hv⟩)
      ⟨hv, ⟨MulEquiv.refl _⟩⟩
  exact twoGenerated_of_mulEquiv e (ReeF4.twoGenerated_reeGamma hm hX)

end CFSGCorollary
