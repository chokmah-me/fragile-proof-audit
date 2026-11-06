module

public import CFSGCorollary.LieType.Steinberg.Basic

@[expose] public section

/-!
# λ-root groups

Steinberg's generation argument (Lemmas 3.9, 3.10 and 3.12 of [Steinberg1962]) uses root groups
`X_r ≅ (K, +)` on which torus elements act by multiplication with a scalar. In the twisted groups
the root groups need not be abelian; what survives is a homomorphism `λ : X → (L, +)` to a finite
field whose kernel lies in the commutator subgroup `[X, X]`. This file sets up this
structure; the generation lemmas are in `CFSGCorollary.LieType.LambdaRootGroup.ClosurePair` and
`CFSGCorollary.LieType.LambdaRootGroup.SpanningScalar`.

## Main definitions

* `CFSGCorollary.LambdaRootGroup`: a finite nilpotent subgroup `X` with a coordinate
  `λ : X →* Multiplicative L` whose kernel lies in `[X, X]`.
* `CFSGCorollary.LambdaRootGroup.Action`: an element `d` normalising `X` and scaling `λ` by `k`.
* `CFSGCorollary.IsNontrivialGeneratingScalar`: a generator of `Lˣ` or its square, other than `1`.

## Main results

* `CFSGCorollary.eq_top_of_sup_commutator_eq_top`: in a finite nilpotent group `X`, a subgroup
  `Y` with `Y ⊔ [X, X] = X` is all of `X`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

namespace CFSGCorollary

/-- A *λ-root group* of `G` over the finite field `L`: a finite nilpotent subgroup `X` of `G`
with a coordinate homomorphism `λ : X →* Multiplicative L` whose kernel lies in `[X, X]`. -/
structure LambdaRootGroup (G L : Type*) [Group G] [Field L] [Finite L] where
  carrier : Subgroup G
  finite : Finite carrier
  isNilpotent : Group.IsNilpotent carrier
  coordinate : carrier →* Multiplicative L
  ker_coordinate_le_commutator : coordinate.ker ≤
    ⁅(⊤ : Subgroup carrier), (⊤ : Subgroup carrier)⁆

/-- The element `element` acts on the λ-root group `X` by the scalar `scalar`: conjugation by
`element` restricts to an automorphism of `X` multiplying the coordinate `λ` by `scalar`. -/
structure LambdaRootGroup.Action {G L : Type*} [Group G] [Field L] [Finite L]
    (rootGroup : LambdaRootGroup G L) (element : G) (scalar : Lˣ) where
  conjugation : rootGroup.carrier ≃* rootGroup.carrier
  coe_conjugation : ∀ rootElement : rootGroup.carrier,
    (conjugation rootElement : G) = element * (rootElement : G) * element⁻¹
  coordinate_conjugation : ∀ rootElement : rootGroup.carrier,
    Multiplicative.toAdd (rootGroup.coordinate (conjugation rootElement)) =
      (scalar : L) * Multiplicative.toAdd (rootGroup.coordinate rootElement)

/-- A scalar `c ∈ Kˣ` is a nontrivial generating scalar if it is a generator of `Kˣ` or the
square of one (`IsGeneratingScalar`), and `c ≠ 1`. -/
def IsNontrivialGeneratingScalar {K : Type*} [Field K] (scalar : Kˣ) : Prop :=
  IsGeneratingScalar scalar ∧ scalar ≠ 1

open scoped commutatorElement in
/-- In a finite nilpotent group `X`, a subgroup `Y` with `Y ⊔ [X, X] = X` is all of `X`: a
maximal subgroup containing `Y` would be normal of prime index, hence contain `[X, X]`. -/
theorem eq_top_of_sup_commutator_eq_top {X : Type*} [Group X] [Finite X]
    [Group.IsNilpotent X] {Y : Subgroup X}
    (h : Y ⊔ ⁅(⊤ : Subgroup X), (⊤ : Subgroup X)⁆ = ⊤) : Y = ⊤ := by
  by_contra hY
  obtain ⟨M, hM, hYM⟩ := (eq_top_or_exists_le_coatom Y).resolve_left hY
  have : M.Normal := Subgroup.NormalizerCondition.normal_of_coatom M
    Group.normalizerCondition_of_isNilpotent hM
  have : IsSimpleGroup (X ⧸ M) := Group.isSimpleGroup_of_isCoatom hM
  have hprime : (Nat.card (X ⧸ M)).Prime := Group.is_simple_iff_prime_card.mp this
  have : Fact (Nat.card (X ⧸ M)).Prime := ⟨hprime⟩
  have : IsCyclic (X ⧸ M) := isCyclic_of_prime_card (p := Nat.card (X ⧸ M)) rfl
  have hcomm : ⁅(⊤ : Subgroup X), (⊤ : Subgroup X)⁆ ≤ M := by
    rw [Subgroup.commutator_le]
    intro a _ b _
    rw [← QuotientGroup.eq_one_iff]
    change QuotientGroup.mk' M ⁅a, b⁆ = 1
    rw [map_commutatorElement]
    exact commutatorElement_eq_one_iff_commute.mpr (Commute.all _ _)
  exact hM.1 (top_le_iff.mp (h ▸ sup_le hYM hcomm))

end CFSGCorollary
