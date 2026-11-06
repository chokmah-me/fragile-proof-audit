module

public import CFSGCorollary.LieType.Twisted.ReeG2.Basic
public import CFSGCorollary.TwoGenerated.Basic
import all TauCeti.GroupTheory.SpecificGroups.CFSG.Index
import CFSG.Adapters.TauCetiExceptional.ReeBridge
import CFSGCorollary.LieType.LambdaRootGroup.ClosurePair
import CFSGCorollary.LieType.Twisted.ReeG2.RootGroup

@[expose] public section

/-!
# The small Ree groups are two-generated

For `a ≥ 1` and a generator `s` of `Kˣ`, `K = GF(3 ^ (2a + 1))`, the torus element `h(s)` and
`u₁ ω` generate the small Ree group `Γ`. The torus element acts on the λ-root group `(U, π)` by
`s ^ (2θ - 1)`, again a generator of `Kˣ`, and `ω` inverts it, so the rank one case
`LambdaRootGroup.le_closure_pair_of_inverting` of Steinberg's argument gives `U ≤ ⟨h(s), u₁ ω⟩`
and `ω ∈ ⟨h(s), u₁ ω⟩`. Then `⟨h(s), u₁ ω⟩` contains the Borel subgroup `T U` and `ω`, hence `Γ`
by the Bruhat decomposition.

## Main results

* `CFSGCorollary.ReeG2.closure_torusElement_unipotentOne_mul_longestWeylRep`:
  `⟨h(s), u₁ ω⟩ = Γ`.
* `CFSGCorollary.twoGenerated_reeG2`: TauCeti's small Ree groups are two-generated.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

namespace CFSGCorollary

namespace ReeG2

open CFSG.Blueprint.Chevalley CFSG.LieType.Chevalley CFSG.LieType.Ree

/-- For a generator `s` of `Kˣ`, `h(s)` and `u₁ ω` generate `Γ`. -/
theorem closure_torusElement_unipotentOne_mul_longestWeylRep {a : ℕ} (ha : 1 ≤ a)
    {s : (ReeField a)ˣ} (hs : ∀ y : (ReeField a)ˣ, y ∈ Subgroup.zpowers s) :
    Subgroup.closure {torusElement a s, ((unipotentOne a : fixedUnipotent a) :
      ModGL ReeTag.G2.tag (ReeField a)) * longestWeylRep a} = fixedGroup a := by
  set F := Subgroup.closure {torusElement a s, ((unipotentOne a : fixedUnipotent a) :
      ModGL ReeTag.G2.tag (ReeField a)) * longestWeylRep a} with hF
  obtain ⟨hgen', hk⟩ := zpowers_pow_eq_top_and_ne_one ha hs
  have hgen : Subgroup.zpowers (s ^ (2 * 3 ^ a - 1)) = ⊤ := Subgroup.eq_top_iff' _ |>.2 hgen'
  have hu : Multiplicative.toAdd ((lambdaRootGroup ha).coordinate (unipotentOne a)) ≠ 0 := by
    change Multiplicative.toAdd
      (leadingCoordinate ha ⟨unipotent a 1 0 0, unipotent_mem_fixedUnipotent a 1 0 0⟩) ≠ 0
    rw [leadingCoordinate_unipotent]
    exact one_ne_zero
  obtain ⟨hU, hω⟩ := (lambdaRootGroup ha).le_closure_pair_of_inverting (torusElement a s)
    (longestWeylRep a) _ hgen hk (torusAction ha s)
    (longestWeylRep_mul_torusElement_mul_longestWeylRep_inv a s) (unipotentOne a) hu
  have hd : ∀ n : ℤ, torusElement a (s ^ n) ∈ F := by
    obtain ⟨φ, hφ⟩ := (small_Ree_positive_torus_action a (ReeField a) (card_reeField a)).1
    intro n
    have : torusElement a (s ^ n) = (torusElement a s) ^ n := by
      have h3 : ((φ (s ^ n) : fixedTorus a) : ModGL ReeTag.G2.tag (ReeField a)) =
          ((φ s : fixedTorus a) : ModGL ReeTag.G2.tag (ReeField a)) ^ n := by
        rw [map_zpow]; rfl
      exact (hφ (s ^ n)).symm.trans (h3.trans (by rw [hφ s]; rfl))
    rw [this]
    exact zpow_mem (Subgroup.subset_closure (by simp)) n
  have hB : ReeTag.G2.reeFixedBorel (ReeField a) a ≤ F := by
    intro x hx
    have hx' : x ∈ ((ReeTag.G2.reeFixedBorel (ReeField a) a : Set _)) := hx
    rw [(ReeTag.ree_fixed_Bruhat_decomposition ReeTag.G2 a (ReeField a)).1] at hx'
    obtain ⟨t, ht, u, hu', rfl⟩ := hx'
    obtain ⟨s', rfl⟩ := exists_eq_torusElement_of_mem_fixedTorus ht
    obtain ⟨n, rfl⟩ := hs s'
    exact F.mul_mem (hd n) (hU hu')
  have hG : fixedGroup a ≤ F := by
    rw [show fixedGroup a = ReeTag.G2.reeGamma (ReeField a) a from rfl,
      (ReeTag.ree_fixed_Bruhat_decomposition ReeTag.G2 a
        (ReeField a)).2.2.2.2.2.2.2.2.2.2.2.2]
    refine sup_le hB ((Subgroup.closure_le F).2 ?_)
    rintro _ ⟨j, rfl⟩
    have hn : ReeTag.G2.fixedOrbitCount = 1 := by decide
    have hj : j = ⟨0, by decide⟩ := Fin.ext (by have := j.2; change (j : ℕ) = 0; omega)
    rw [hj]
    beta_reduce
    rw [← ReeTag.longest_eq_fixedOrbitElement length_le_length_longestWeyl]
    exact hω
  refine le_antisymm ?_ hG
  rw [hF, Subgroup.closure_le]
  rintro x (rfl | rfl)
  · exact torusElement_mem_fixedGroup a s
  · exact (fixedGroup a).mul_mem (ReeTag.reeFixedPosUnipotent_le_reeGamma (unipotentOne a).2)
      (longestWeylRep_mem_fixedGroup a)

/-- `Γ` is perfect: `⁅Γ, Γ⁆ = Γ`. -/
theorem commutator_fixedGroup_eq_self {a : ℕ} (ha : 1 ≤ a) :
    ⁅fixedGroup a, fixedGroup a⁆ = fixedGroup a := by
  have h : commutator ↥(fixedGroup a) = ⊤ :=
    ReeTag.commutator_reeGamma_eq_top (t := ReeTag.G2) (K := ReeField a) (a := a) ha
      (card_reeField a)
  rw [← Subgroup.map_subtype_commutator]
  change Subgroup.map (fixedGroup a).subtype (commutator ↥(fixedGroup a)) = fixedGroup a
  rw [h, Subgroup.map_top, Subgroup.range_subtype]

/-- The derived central quotient `[Γ, Γ] / Z([Γ, Γ])` of `Γ` is two-generated. -/
theorem twoGenerated_derivedCentralQuotient {a : ℕ} (ha : 1 ≤ a) :
    TwoGenerated
      (↥⁅fixedGroup a, fixedGroup a⁆ ⧸ Subgroup.center ↥⁅fixedGroup a, fixedGroup a⁆) := by
  obtain ⟨s, hs⟩ := IsCyclic.exists_generator (α := (ReeField a)ˣ)
  have hgen := closure_torusElement_unipotentOne_mul_longestWeylRep ha hs
  have hc := commutator_fixedGroup_eq_self ha
  have h1 : torusElement a s ∈ ⁅fixedGroup a, fixedGroup a⁆ := by
    rw [hc]; exact torusElement_mem_fixedGroup a s
  have h2 : ((unipotentOne a : fixedUnipotent a) : ModGL ReeTag.G2.tag (ReeField a)) *
      longestWeylRep a ∈ ⁅fixedGroup a, fixedGroup a⁆ := by
    rw [hc]
    exact (fixedGroup a).mul_mem (ReeTag.reeFixedPosUnipotent_le_reeGamma (unipotentOne a).2)
      (longestWeylRep_mem_fixedGroup a)
  exact twoGenerated_of_surjective (QuotientGroup.mk' _) (QuotientGroup.mk'_surjective _)
    (twoGenerated_subgroup_of_closure_pair_eq _ _ _ h1 h2 (hgen.trans hc.symm))

end ReeG2

open CFSG CFSG.Blueprint CFSG.LieType.Ree in
/-- The small Ree groups `²G₂(3 ^ (2m + 1))` are two-generated. -/
theorem twoGenerated_reeG2 (m : ℕ)
    (hv : (TauCeti.LieTypeIndex.reeG2 m).Valid)
    [Finite (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.reeG2 m, hv⟩)]
    [IsSimpleGroup (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.reeG2 m, hv⟩)] :
    TwoGenerated (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.reeG2 m, hv⟩) := by
  have hm : 1 ≤ m := by simpa using hv.1
  obtain ⟨e⟩ := CFSG.TauCetiBridge.reeG2Bridge m hv (ReeG2.ReeField m) (ReeG2.card_reeField m)
  have h : ReeG2.fixedGroup m = reeFixedGroup .G2 (ReeG2.ReeField m) reeG2Perm
      (fun i ↦ if i ∈ reeG2Long then 3 ^ m else 3 ^ (m + 1)) :=
    ReeTag.reeGamma_eq_reeFixedGroup (t := ReeTag.G2) (K := ReeG2.ReeField m) (a := m)
  have h2 : TwoGenerated (DerivedCentralQuotient (ReeG2.fixedGroup m)) :=
    ReeG2.twoGenerated_derivedCentralQuotient hm
  rw [h] at h2
  exact twoGenerated_of_mulEquiv e.symm h2

end CFSGCorollary
