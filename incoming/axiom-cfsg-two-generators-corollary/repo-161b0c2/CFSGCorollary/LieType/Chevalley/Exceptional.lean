module

public import CFSGCorollary.TwoGenerated.Basic
public import TauCeti.GroupTheory.SpecificGroups.CFSG.Assembly.LieType
import all TauCeti.GroupTheory.SpecificGroups.CFSG.Index
import CFSG.Adapters.CatalogueFieldBridges.Exceptional
import CFSGCorollary.LieType.Chevalley.Adjoint
import CFSGCorollary.LieType.Chevalley.Generation.TypeE6
import CFSGCorollary.LieType.Chevalley.Generation.TypeE7
import CFSGCorollary.LieType.Chevalley.Generation.TypeE8
import CFSGCorollary.LieType.Chevalley.Generation.TypeF4
import CFSGCorollary.LieType.Chevalley.Generation.TypeG2

/-!
# Two-generation of the exceptional groups of Lie type

Assembles the two-generation theorems for the untwisted exceptional families `E₆(q)`, `E₇(q)`,
`E₈(q)`, `F₄(q)` and `G₂(q)` of TauCeti's classification. Each such group is isomorphic to CFSG's
adjoint group `adjointGroup τ K` over a field with `q` elements, which carries a Steinberg system
(see `CFSGCorollary.LieType.Chevalley.Adjoint`), and the generation results of Steinberg 1962
§3.11 for the corresponding type apply. For `F₄(2)` the two single commutators needed by the
characteristic-two argument are supplied by `commutator_xPar_pair_F4`.

## Main results

* `CFSGCorollary.twoGenerated_E6`, `CFSGCorollary.twoGenerated_E7`,
  `CFSGCorollary.twoGenerated_E8`, `CFSGCorollary.twoGenerated_F4`,
  `CFSGCorollary.twoGenerated_G2`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

open CFSG.Blueprint.Chevalley (Tag IsRoot)
open CFSG.LieType.Chevalley (rootOperatorFamily)
open CFSG.LieType.Steinberg.Adjoint (xPar)
open TauCeti (LieTypeIndex ValidLieTypeIndex PrimePower)
open scoped commutatorElement

private theorem isRoot_coxeterElement_pow_apply {v : Fin 4 → ℤ} (hv : IsRoot Tag.F4 v) (k : ℕ) :
    IsRoot Tag.F4 ((TypeF4.coxeterElement ^ k) v) := by
  obtain ⟨g, hg⟩ : ∃ g, TypeF4.coxeterElement =
      CFSG.LieType.RootSystem.weylAction TypeF4.isFiniteType g :=
    ⟨_, reflectionWord_eq_weylAction TypeF4.isFiniteType TypeF4.coxeterList⟩
  rw [hg, ← map_pow]
  exact CFSG.LieType.Chevalley.IsRoot.smul hv (g ^ k)

private theorem isRoot_of_mem_rootSet {v : Fin 4 → ℤ} (hv : v ∈ TypeF4.rootSet) :
    IsRoot Tag.F4 v :=
  CFSG.LieType.Chevalley.isRoot_iff_mem_roots.2 hv

private theorem mem_rootSet_of_isRoot {v : Fin 4 → ℤ} (hv : IsRoot Tag.F4 v) :
    v ∈ TypeF4.rootSet :=
  CFSG.LieType.Chevalley.isRoot_iff_mem_roots.1 hv

/-- Commutator of root elements for a pair `(u, v)` with `t = u + v` the only positive combination
in `Φ` and `v - u ∉ Φ`, over a field of characteristic two. -/
private theorem commutator_xPar_pair_F4_of_neg_one_eq_one {K : Type} [Field K]
    (hK : (-1 : K) = 1) {u v t : Fin 4 → ℤ} (hu : u ∈ TypeF4.rootSet) (hv : v ∈ TypeF4.rootSet)
    (hp : OnlyPositiveCombination TypeF4.rootSet u v t) (hd : v - u ∉ TypeF4.rootSet) :
    ⁅xPar (rootOperatorFamily Tag.F4) u (1 : K), xPar (rootOperatorFamily Tag.F4) v (1 : K)⁆ =
      xPar (rootOperatorFamily Tag.F4) t (1 : K) := by
  obtain ⟨rfl, htm, hu'⟩ := hp
  obtain ⟨ε, hε, h⟩ := commutator_xPar_pair_F4 (K := K) (α := u) (β := v)
    (isRoot_of_mem_rootSet hu) (isRoot_of_mem_rootSet hv) (isRoot_of_mem_rootSet htm)
    (fun h ↦ hd (mem_rootSet_of_isRoot h))
    (fun h ↦ by
      have := hu' 1 2 one_pos two_pos (by rw [one_nsmul]; exact mem_rootSet_of_isRoot h)
      omega)
    (fun h ↦ by
      have := hu' 2 1 two_pos one_pos (by rw [one_nsmul]; exact mem_rootSet_of_isRoot h)
      omega)
  have : (ε : K) = 1 := by
    rcases hε with rfl | rfl
    · simp
    · simpa using hK
  rw [h, this, one_mul, one_mul]
  rfl

/-- The untwisted exceptional carrier is the adjoint group over `GaloisField q.p q.exponent`. -/
private theorem exists_adjointGroup_mulEquiv {τ : Tag} {c : PrimePower → LieTypeIndex}
    (hB : CFSG.TauCetiBridge.Even.UntwistedBridgeAll τ c) (q : PrimePower) (hv : (c q).Valid) :
    ∃ (K : Type) (_ : Field K) (_ : Finite K), Nat.card K = q.card ∧
      Nonempty (↥(CFSG.Blueprint.Chevalley.adjointGroup τ K) ≃*
        ValidLieTypeIndex.Group ⟨c q, hv⟩) := by
  have : Fact q.p.Prime := ⟨q.prime_p⟩
  have hK : Nat.card (GaloisField q.p q.exponent) = q.card := by
    rw [GaloisField.card _ _ q.exponent_pos.ne', TauCeti.PrimePower.card_def]
  exact ⟨GaloisField q.p q.exponent, inferInstance, inferInstance, hK,
    CFSG.Adapters.CatalogueFieldBridges.nonempty_adjointGroup_catEquiv hB hv hK⟩

/-- The simple groups `E₆(q)` are two-generated. -/
theorem twoGenerated_E6 (q : PrimePower) (hv : (LieTypeIndex.E6 q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.E6 q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.E6 q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.E6 q, hv⟩) := by
  obtain ⟨K, _, _, -, ⟨e⟩⟩ :=
    exists_adjointGroup_mulEquiv CFSG.TauCetiBridge.Even.chevalleyBridgesAll.e6 q hv
  obtain ⟨S, -, hS⟩ := exists_steinbergSystem_adjointGroup (τ := Tag.E6) (Or.inr (Or.inl rfl)) K
  exact twoGenerated_of_mulEquiv e.symm (TypeE6.twoGenerated S (hS (by simp)))

/-- The simple groups `E₇(q)` are two-generated. -/
theorem twoGenerated_E7 (q : PrimePower) (hv : (LieTypeIndex.E7 q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.E7 q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.E7 q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.E7 q, hv⟩) := by
  obtain ⟨K, _, _, -, ⟨e⟩⟩ :=
    exists_adjointGroup_mulEquiv CFSG.TauCetiBridge.Even.chevalleyBridgesAll.e7 q hv
  obtain ⟨S, -, -⟩ :=
    exists_steinbergSystem_adjointGroup (τ := Tag.E7) (Or.inr (Or.inr (Or.inl rfl))) K
  exact twoGenerated_of_mulEquiv e.symm (TypeE7.twoGenerated S)

/-- The simple groups `E₈(q)` are two-generated. -/
theorem twoGenerated_E8 (q : PrimePower) (hv : (LieTypeIndex.E8 q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.E8 q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.E8 q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.E8 q, hv⟩) := by
  obtain ⟨K, _, _, -, ⟨e⟩⟩ :=
    exists_adjointGroup_mulEquiv CFSG.TauCetiBridge.Even.chevalleyBridgesAll.e8 q hv
  obtain ⟨S, -, -⟩ :=
    exists_steinbergSystem_adjointGroup (τ := Tag.E8) (Or.inr (Or.inr (Or.inr rfl))) K
  exact twoGenerated_of_mulEquiv e.symm (TypeE8.twoGenerated S)

/-- The simple groups `G₂(q)` (`q ≥ 3`) are two-generated. -/
theorem twoGenerated_G2 (q : PrimePower) (hv : (LieTypeIndex.G2 q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.G2 q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.G2 q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.G2 q, hv⟩) := by
  obtain ⟨K, _, _, hK, ⟨e⟩⟩ :=
    exists_adjointGroup_mulEquiv CFSG.TauCetiBridge.Even.chevalleyBridgesAll.g2 q hv
  obtain ⟨S, -⟩ := exists_steinbergSystem_adjointGroup_G2 K
  have h3 : 3 ≤ q.card := by
    simpa [LieTypeIndex.inStandardRange_iff] using hv.1
  obtain ⟨k, hk⟩ := IsCyclic.exists_generator (α := Kˣ)
  exact twoGenerated_of_mulEquiv e.symm ⟨_, _, TypeG2.closure_diagonal_mul_eq_top S (by omega)
    (k := k) (Subgroup.eq_top_iff' _ |>.mpr hk)⟩

/-- The simple groups `F₄(q)` are two-generated. -/
theorem twoGenerated_F4 (q : PrimePower) (hv : (LieTypeIndex.F4 q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.F4 q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.F4 q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.F4 q, hv⟩) := by
  obtain ⟨K, _, _, -, ⟨e⟩⟩ :=
    exists_adjointGroup_mulEquiv CFSG.TauCetiBridge.Even.chevalleyBridgesAll.f4 q hv
  obtain ⟨S, hS, -⟩ := exists_steinbergSystem_adjointGroup (τ := Tag.F4) (Or.inl rfl) K
  refine twoGenerated_of_mulEquiv e.symm ?_
  by_cases h3 : 3 ≤ Nat.card K
  · obtain ⟨k, hk⟩ := IsCyclic.exists_generator (α := Kˣ)
    exact ⟨_, _, TypeF4.closure_diagonal_mul_eq_top S h3
      (k := k) (Subgroup.eq_top_iff' _ |>.mpr hk)⟩
  · have hK2 : Nat.card K = 2 := by
      have : 1 < Nat.card K := Finite.one_lt_card
      omega
    have hneg : (-1 : K) = 1 := by
      have := Fintype.ofFinite K
      have : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
      have : CharP K 2 := charP_of_card_eq_prime (by rw [← Nat.card_eq_fintype_card]; exact hK2)
      exact CharTwo.neg_eq 1
    refine ⟨_, _, TypeF4.closure_pair_eq_top_of_card_eq_two S hK2 ?_ ?_⟩
    · rw [hS, TypeF4.coxeterElement_pow_five_rootRCardTwo]
      refine commutator_xPar_pair_F4_of_neg_one_eq_one hneg TypeF4.rootRCardTwo_mem ?_
        TypeF4.onlyPositiveCombination_rootRCardTwo_rootRCardTwoPowFive
        TypeF4.rootRCardTwoPowFive_sub_rootRCardTwo_notMem
      have := isRoot_coxeterElement_pow_apply (isRoot_of_mem_rootSet TypeF4.rootRCardTwo_mem) 5
      rw [TypeF4.coxeterElement_pow_five_rootRCardTwo] at this
      exact mem_rootSet_of_isRoot this
    · rw [hS, TypeF4.coxeterElement_rootSCardTwo]
      refine commutator_xPar_pair_F4_of_neg_one_eq_one hneg TypeF4.rootSCardTwo_mem ?_
        TypeF4.onlyPositiveCombination_rootSCardTwo_rootSCardTwoPowOne
        TypeF4.rootSCardTwoPowOne_sub_rootSCardTwo_notMem
      have := isRoot_coxeterElement_pow_apply (isRoot_of_mem_rootSet TypeF4.rootSCardTwo_mem) 1
      rw [pow_one, TypeF4.coxeterElement_rootSCardTwo] at this
      exact mem_rootSet_of_isRoot this

end CFSGCorollary
