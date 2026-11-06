module

public import CFSG.LieType.Ree.SmallReeFrattini
public import CFSG.Sporadic.Suz.Simple

@[expose] public section

/-!
# The small Ree groups

Notation for the small Ree groups `²G₂(3 ^ (2a + 1))`, realised in the CFSG library as the
fixed points `Γ` of the exceptional automorphism of `G₂(K)`, `K = GF(3 ^ (2a + 1))`, together with
the fixed torus `T`, the fixed positive unipotent group `U` with its coordinates `x(t, b, c)`, the
torus elements `h(s)` and a representative `ω` of the longest Weyl group element.

## Main definitions

* `CFSGCorollary.ReeG2.fixedGroup`, `CFSGCorollary.ReeG2.fixedTorus`,
  `CFSGCorollary.ReeG2.fixedUnipotent`: the groups `Γ`, `T` and `U`.
* `CFSGCorollary.ReeG2.unipotent`, `CFSGCorollary.ReeG2.torusElement`: `x(t, b, c)` and `h(s)`.
* `CFSGCorollary.ReeG2.longestWeylRep`: `ω`.
* `CFSGCorollary.ReeG2.leadingCoordinate`: the coordinate `U →* K`, `x(t, b, c) ↦ t`.

## Main results

* `CFSGCorollary.ReeG2.zpowers_pow_eq_top_and_ne_one`: if `s` generates `Kˣ`, then so does the
  scalar `s ^ (2θ - 1)` by which `h(s)` acts on the leading coordinate, and it is not `1`.
-/

namespace CFSGCorollary.ReeG2

open CFSG.Blueprint.Chevalley CFSG.LieType.Chevalley CFSG.LieType.Ree

/-- The field `K = GF(3 ^ (2a + 1))`. -/
abbrev ReeField (a : ℕ) : Type := GaloisField 3 (2 * a + 1)

instance (a : ℕ) : CharP (ReeField a) ReeTag.G2.prime := inferInstanceAs (CharP (ReeField a) 3)

theorem card_reeField (a : ℕ) : Nat.card (ReeField a) = 3 ^ (2 * a + 1) :=
  GaloisField.card 3 (2 * a + 1) (by omega)

/-- `Γ`, the fixed points of the exceptional automorphism of `G₂(K)`: the small Ree group. -/
noncomputable abbrev fixedGroup (a : ℕ) : Subgroup (ModGL ReeTag.G2.tag (ReeField a)) :=
  ReeTag.G2.reeGamma (ReeField a) a

/-- The fixed torus `T`. -/
noncomputable abbrev fixedTorus (a : ℕ) : Subgroup (ModGL ReeTag.G2.tag (ReeField a)) :=
  ReeTag.G2.reeFixedTorus (ReeField a) a

/-- The fixed positive unipotent group `U`. -/
noncomputable abbrev fixedUnipotent (a : ℕ) : Subgroup (ModGL ReeTag.G2.tag (ReeField a)) :=
  ReeTag.G2.reeFixedPosUnipotent (ReeField a) a

/-- The element `x(t, b, c)` of `U` with coordinates `(t, b, c)`. -/
noncomputable def unipotent (a : ℕ) (t b c : ReeField a) : ModGL ReeTag.G2.tag (ReeField a) :=
  smallReeCoord a (ReeField a) t b c

/-- The torus element `h(s)`. -/
noncomputable def torusElement (a : ℕ) (s : (ReeField a)ˣ) : ModGL ReeTag.G2.tag (ReeField a) :=
  smallReeTorusElt a (ReeField a) s

theorem unipotent_mem_fixedUnipotent (a : ℕ) (t b c : ReeField a) :
    unipotent a t b c ∈ fixedUnipotent a := by
  have := (small_Ree_positive_fixed_coordinates a (ReeField a) (card_reeField a)).1.mapsTo
    (Set.mem_univ (t, b, c))
  exact this

theorem exists_eq_unipotent_of_mem_fixedUnipotent {a : ℕ}
    {x : ModGL ReeTag.G2.tag (ReeField a)} (hx : x ∈ fixedUnipotent a) :
    ∃ t b c : ReeField a, x = unipotent a t b c := by
  obtain ⟨p, -, hp⟩ :=
    (small_Ree_positive_fixed_coordinates a (ReeField a) (card_reeField a)).1.surjOn hx
  exact ⟨p.1, p.2.1, p.2.2, hp.symm⟩

theorem exists_forall_length_le : ∃ w₀ : WeylGroup ReeTag.G2.tag, ∀ w : WeylGroup ReeTag.G2.tag,
    (coxeterSystem ReeTag.G2.tag).length w ≤ (coxeterSystem ReeTag.G2.tag).length w₀ :=
  Finite.exists_max _

/-- A Weyl group element of maximal length, `w₀`. -/
noncomputable def longestWeyl : WeylGroup ReeTag.G2.tag := Classical.choose exists_forall_length_le

theorem length_le_length_longestWeyl (w : WeylGroup ReeTag.G2.tag) :
    (coxeterSystem ReeTag.G2.tag).length w ≤ (coxeterSystem ReeTag.G2.tag).length longestWeyl :=
  Classical.choose_spec exists_forall_length_le w

/-- `ω`, the canonical representative of `w₀`. -/
noncomputable def longestWeylRep (a : ℕ) : ModGL ReeTag.G2.tag (ReeField a) :=
  canonicalRep (coxeterSystem ReeTag.G2.tag) (ReeField a) longestWeyl

/-- The leading coordinate homomorphism `π : U →* K`, `x(t, b, c) ↦ t`, of the Frattini
quotient of `U`. -/
noncomputable def leadingCoordinate {a : ℕ} (ha : 1 ≤ a) :
    fixedUnipotent a →* Multiplicative (ReeField a) :=
  Classical.choose
    (small_Ree_positive_Frattini_quotient a ha (ReeField a) (card_reeField a)).2.2.2.2.2.2.2.2

theorem leadingCoordinate_unipotent {a : ℕ} (ha : 1 ≤ a) (t b c : ReeField a) :
    leadingCoordinate ha ⟨unipotent a t b c, unipotent_mem_fixedUnipotent a t b c⟩ =
      Multiplicative.ofAdd t :=
  (Classical.choose_spec
    (small_Ree_positive_Frattini_quotient a ha (ReeField a) (card_reeField a)).2.2.2.2.2.2.2.2).1
    t b c (unipotent_mem_fixedUnipotent a t b c)

/-- `u₁ = x(1, 0, 0) ∈ U`. -/
noncomputable def unipotentOne (a : ℕ) : fixedUnipotent a :=
  ⟨unipotent a 1 0 0, unipotent_mem_fixedUnipotent a 1 0 0⟩

/-- If `s` generates `Kˣ` then `k = s ^ (2θ - 1)` generates `Kˣ` and `k ≠ 1`. -/
theorem zpowers_pow_eq_top_and_ne_one {a : ℕ} (ha : 1 ≤ a) {s : (ReeField a)ˣ}
    (hs : ∀ y : (ReeField a)ˣ, y ∈ Subgroup.zpowers s) :
    (∀ y : (ReeField a)ˣ, y ∈ Subgroup.zpowers (s ^ (2 * 3 ^ a - 1))) ∧
      s ^ (2 * 3 ^ a - 1) ≠ 1 := by
  have hb := (small_Ree_positive_torus_action a (ReeField a) (card_reeField a)).2.2.1
  have hk : ∀ y : (ReeField a)ˣ, y ∈ Subgroup.zpowers (s ^ (2 * 3 ^ a - 1)) := by
    intro y
    obtain ⟨x, rfl⟩ := hb.2 y
    obtain ⟨n, rfl⟩ := Subgroup.mem_zpowers_iff.1 (hs x)
    refine Subgroup.mem_zpowers_iff.2 ⟨n, ?_⟩
    simp only
    rw [← zpow_natCast, ← zpow_natCast, ← zpow_mul, ← zpow_mul, Int.mul_comm]
  refine ⟨hk, fun h1 ↦ ?_⟩
  have hs1 : s = 1 := hb.1 (by simpa using h1)
  have htriv : ∀ y : (ReeField a)ˣ, y = 1 := by
    intro y
    have := hs y
    rw [hs1, Subgroup.zpowers_one_eq_bot] at this
    simpa using this
  have hc : Nat.card (ReeField a)ˣ = 1 := by
    rw [Nat.card_eq_one_iff_unique]
    exact ⟨⟨fun x y ↦ (htriv x).trans (htriv y).symm⟩, ⟨1⟩⟩
  rw [Nat.card_units, card_reeField] at hc
  have : 3 ^ 3 ≤ 3 ^ (2 * a + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  omega

end CFSGCorollary.ReeG2
