module

public import CFSGCorollary.LieType.Twisted.ReeG2.Basic
public import CFSGCorollary.LieType.LambdaRootGroup.Basic
import CFSG.LieType.Ree.SmallReeBorelCosetAction

@[expose] public section

/-!
# The root group of the small Ree groups

The fixed positive unipotent group `U` of the small Ree group, with the leading coordinate
`π : U →* K` of its Frattini quotient, is a λ-root group; the torus element `h(s)` acts on it by
`s ^ (2θ - 1)`, `θ = 3 ^ a`, and the longest Weyl representative `ω` inverts `h(s)`.

## Main definitions

* `CFSGCorollary.ReeG2.lambdaRootGroup`: `(U, π)` as a λ-root group.
* `CFSGCorollary.ReeG2.torusAction`: the action of `h(s)` on `(U, π)`.

## Main results

* `CFSGCorollary.ReeG2.longestWeylRep_mul_torusElement_mul_longestWeylRep_inv`:
  `ω h(s) ω⁻¹ = h(s)⁻¹`.
-/

namespace CFSGCorollary.ReeG2

open CFSG.Blueprint.Chevalley CFSG.LieType.Chevalley CFSG.LieType.Ree

/-- `U` is finite. -/
instance (a : ℕ) : Finite (fixedUnipotent a) := by
  have h := (small_Ree_positive_fixed_coordinates a (ReeField a) (card_reeField a)).2
  exact Nat.finite_of_card_ne_zero (by rw [h]; positivity)

theorem isNilpotent_fixedUnipotent (a : ℕ) : Group.IsNilpotent (fixedUnipotent a) :=
  (ReeTag.ree_fixed_Bruhat_decomposition ReeTag.G2 a (ReeField a)).2.2.2.2.2.1

theorem ker_leadingCoordinate_le_commutator {a : ℕ} (ha : 1 ≤ a) :
    (leadingCoordinate ha).ker ≤
      ⁅(⊤ : Subgroup (fixedUnipotent a)), (⊤ : Subgroup (fixedUnipotent a))⁆ := by
  have h := small_Ree_positive_Frattini_quotient a ha (ReeField a) (card_reeField a)
  have hk := (Classical.choose_spec h.2.2.2.2.2.2.2.2).2.2.1
  have hc := h.2.2.2.2.2.2.1
  intro x hx
  have hx' : x ∈ (leadingCoordinate ha).ker := hx
  rw [show (leadingCoordinate ha).ker = _ from hk, ← hc] at hx'
  exact hx'

/-- `(U, π)` is a λ-root group in `G` over `K`. -/
noncomputable def lambdaRootGroup {a : ℕ} (ha : 1 ≤ a) :
    LambdaRootGroup (ModGL ReeTag.G2.tag (ReeField a)) (ReeField a) where
  carrier := fixedUnipotent a
  finite := inferInstance
  isNilpotent := isNilpotent_fixedUnipotent a
  coordinate := leadingCoordinate ha
  ker_coordinate_le_commutator := ker_leadingCoordinate_le_commutator ha

theorem torusElement_mem_fixedTorus (a : ℕ) (s : (ReeField a)ˣ) :
    torusElement a s ∈ fixedTorus a := by
  obtain ⟨φ, hφ⟩ := (small_Ree_positive_torus_action a (ReeField a) (card_reeField a)).1
  have h := (φ s).2
  rw [hφ s] at h
  exact h

theorem torusElement_mem_fixedGroup (a : ℕ) (s : (ReeField a)ˣ) :
    torusElement a s ∈ fixedGroup a :=
  (Subgroup.mem_inf.1 (torusElement_mem_fixedTorus a s)).2

theorem torusElement_inv (a : ℕ) (s : (ReeField a)ˣ) :
    torusElement a s⁻¹ = (torusElement a s)⁻¹ := by
  obtain ⟨φ, hφ⟩ := (small_Ree_positive_torus_action a (ReeField a) (card_reeField a)).1
  have h3 : ((φ s⁻¹ : fixedTorus a) : ModGL ReeTag.G2.tag (ReeField a)) =
      ((φ s : fixedTorus a) : ModGL ReeTag.G2.tag (ReeField a))⁻¹ := by
    rw [map_inv]; rfl
  exact (hφ s⁻¹).symm.trans (h3.trans (congrArg _ (hφ s)))

theorem exists_eq_torusElement_of_mem_fixedTorus {a : ℕ} {x : ModGL ReeTag.G2.tag (ReeField a)}
    (hx : x ∈ fixedTorus a) : ∃ s : (ReeField a)ˣ, x = torusElement a s := by
  obtain ⟨φ, hφ⟩ := (small_Ree_positive_torus_action a (ReeField a) (card_reeField a)).1
  obtain ⟨s, hs⟩ := φ.surjective ⟨x, hx⟩
  have h := hφ s
  rw [hs] at h
  exact ⟨s, h⟩

theorem torusElement_mul_unipotent_mul_inv (a : ℕ) (s : (ReeField a)ˣ) (t b c : ReeField a) :
    torusElement a s * unipotent a t b c * (torusElement a s)⁻¹ =
      unipotent a (((s ^ (2 * 3 ^ a - 1) : (ReeField a)ˣ) : ReeField a) * t)
        (((s ^ (1 - (3 ^ a : ℤ)) : (ReeField a)ˣ) : ReeField a) * b)
        ((s : ReeField a) ^ 3 ^ a * c) :=
  (small_Ree_positive_torus_action a (ReeField a) (card_reeField a)).2.1 s t b c

theorem torusElement_mul_mul_inv_mem_fixedUnipotent {a : ℕ} (s : (ReeField a)ˣ)
    {x : ModGL ReeTag.G2.tag (ReeField a)} (hx : x ∈ fixedUnipotent a) :
    torusElement a s * x * (torusElement a s)⁻¹ ∈ fixedUnipotent a := by
  obtain ⟨t, b, c, rfl⟩ := exists_eq_unipotent_of_mem_fixedUnipotent hx
  rw [torusElement_mul_unipotent_mul_inv]
  exact unipotent_mem_fixedUnipotent a _ _ _

/-- Conjugation by `h(s)` as an automorphism of `U`. -/
noncomputable def torusConjugation (a : ℕ) (s : (ReeField a)ˣ) :
    fixedUnipotent a ≃* fixedUnipotent a where
  toFun x := ⟨torusElement a s * x * (torusElement a s)⁻¹,
    torusElement_mul_mul_inv_mem_fixedUnipotent s x.2⟩
  invFun y := ⟨(torusElement a s)⁻¹ * y * torusElement a s, by
    have := torusElement_mul_mul_inv_mem_fixedUnipotent s⁻¹ y.2
    rwa [torusElement_inv, inv_inv] at this⟩
  left_inv x := Subtype.ext (by simp [mul_assoc])
  right_inv y := Subtype.ext (by simp [mul_assoc])
  map_mul' x y := Subtype.ext (by simp [mul_assoc])

theorem leadingCoordinate_torusConjugation {a : ℕ} (ha : 1 ≤ a) (s : (ReeField a)ˣ)
    (x : fixedUnipotent a) :
    Multiplicative.toAdd (leadingCoordinate ha (torusConjugation a s x)) =
      ((s ^ (2 * 3 ^ a - 1) : (ReeField a)ˣ) : ReeField a) *
        Multiplicative.toAdd (leadingCoordinate ha x) := by
  rcases x with ⟨x, hx⟩
  obtain ⟨t, b, c, rfl⟩ := exists_eq_unipotent_of_mem_fixedUnipotent hx
  have h : torusConjugation a s ⟨unipotent a t b c, hx⟩ =
      ⟨unipotent a (((s ^ (2 * 3 ^ a - 1) : (ReeField a)ˣ) : ReeField a) * t)
        (((s ^ (1 - (3 ^ a : ℤ)) : (ReeField a)ˣ) : ReeField a) * b)
        ((s : ReeField a) ^ 3 ^ a * c), unipotent_mem_fixedUnipotent a _ _ _⟩ :=
    Subtype.ext (torusElement_mul_unipotent_mul_inv a s t b c)
  rw [h, leadingCoordinate_unipotent]
  rw [show (⟨unipotent a t b c, hx⟩ : fixedUnipotent a) =
    ⟨unipotent a t b c, unipotent_mem_fixedUnipotent a t b c⟩ from rfl, leadingCoordinate_unipotent]
  rfl

/-- `h(s)` acts on `(U, π)` by `s ^ (2θ - 1)`, `θ = 3 ^ a`. -/
noncomputable def torusAction {a : ℕ} (ha : 1 ≤ a) (s : (ReeField a)ˣ) :
    (lambdaRootGroup ha).Action (torusElement a s) (s ^ (2 * 3 ^ a - 1)) where
  conjugation := torusConjugation a s
  coe_conjugation _ := rfl
  coordinate_conjugation r := leadingCoordinate_torusConjugation ha s r

theorem longestWeylRep_mem_fixedGroup (a : ℕ) : longestWeylRep a ∈ fixedGroup a :=
  ReeTag.canonicalRep_longest_mem_reeGamma length_le_length_longestWeyl

/-- The longest Weyl representative `ω` inverts the torus element `h(s)`. -/
theorem longestWeylRep_mul_torusElement_mul_longestWeylRep_inv (a : ℕ) (s : (ReeField a)ˣ) :
    longestWeylRep a * torusElement a s * (longestWeylRep a)⁻¹ = (torusElement a s)⁻¹ :=
  ReeTag.canonicalRep_longest_conj_torus (t := ReeTag.G2) length_le_length_longestWeyl
    (Subgroup.mem_inf.1 (torusElement_mem_fixedTorus a s)).1

end CFSGCorollary.ReeG2
