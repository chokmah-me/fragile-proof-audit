module

public import TauCeti.GroupTheory.SpecificGroups.CFSG.Suzuki.Generated
public import CFSG.Monster.B.TwoA.Census.PermClasses
public import CFSGCorollary.LieType.LambdaRootGroup.Basic

@[expose] public section

/-!
# The root group of the Suzuki groups

Let `F = GF(2 ^ (2m + 1))` and `θ = 2 ^ (m + 1)`, so that `x ↦ x ^ θ` squares to the Frobenius.
The Suzuki group `Sz(F) ≤ GL₄(F)` (TauCeti's `TauCeti.suzukiGroup`) contains the unipotent
matrices `u(a, b)`, which form a group `X_m` of order `|F|²`. We show that `X_m` with the
coordinate `u(a, b) ↦ a` is a λ-root group: `X_m` is a `2`-group, and the kernel `{u(0, b)}` of
the coordinate consists of commutators `[u(a, 0), u(a c, 0)] = u(0, a ^ (1 + θ) (c + c ^ θ))`.

## Main definitions

* `CFSGCorollary.Suzuki.unipotentSubgroup`: the group `X_m = {u(a, b)}`.
* `CFSGCorollary.Suzuki.leadingCoordinate`: the coordinate `u(a, b) ↦ a`.
* `CFSGCorollary.Suzuki.torusCharacter`: the character `κ ↦ κ ^ θ κ⁻²` by which the torus acts.
* `CFSGCorollary.Suzuki.lambdaRootGroup`: `X_m` as a λ-root group.
-/

namespace CFSGCorollary.Suzuki

open TauCeti.Suzuki (unipotent unipotent_mul_unipotent unipotent_inv unipotent_zero_zero
  unipotentMatrix_apply pow_two_pow_succ_pow_two_pow_succ)
open scoped commutatorElement

/-- The subgroup `X_m = {u(a, b)}` of unipotent matrices. -/
noncomputable def unipotentSubgroup (m : ℕ) :
    Subgroup (GL (Fin 4) (GaloisField 2 (2 * m + 1))) where
  carrier := {x | ∃ a b, x = unipotent m a b}
  mul_mem' := by
    rintro _ _ ⟨a, b, rfl⟩ ⟨c, d, rfl⟩
    exact ⟨_, _, unipotent_mul_unipotent m a b c d⟩
  one_mem' := ⟨0, 0, (unipotent_zero_zero m).symm⟩
  inv_mem' := by
    rintro _ ⟨a, b, rfl⟩
    exact ⟨_, _, unipotent_inv m a b⟩

theorem unipotent_mem_unipotentSubgroup (m : ℕ) (a b : GaloisField 2 (2 * m + 1)) :
    unipotent m a b ∈ unipotentSubgroup m :=
  ⟨a, b, rfl⟩

theorem exists_eq_unipotent_of_mem_unipotentSubgroup {m : ℕ}
    {x : GL (Fin 4) (GaloisField 2 (2 * m + 1))} (hx : x ∈ unipotentSubgroup m) :
    ∃ a b, x = unipotent m a b :=
  hx

/-- The `(1, 0)` entry of an element of `X_m`, as a multiplicative element. -/
noncomputable def leadingCoordinate (m : ℕ) :
    unipotentSubgroup m →* Multiplicative (GaloisField 2 (2 * m + 1)) where
  toFun x := Multiplicative.ofAdd ((x : GL (Fin 4) (GaloisField 2 (2 * m + 1))).1 1 0)
  map_one' := by simp
  map_mul' := by
    rintro ⟨x, a, b, rfl⟩ ⟨y, c, d, rfl⟩
    simp [ofAdd_add]

theorem leadingCoordinate_unipotent (m : ℕ) (a b : GaloisField 2 (2 * m + 1)) :
    leadingCoordinate m ⟨unipotent m a b, unipotent_mem_unipotentSubgroup m a b⟩ =
      Multiplicative.ofAdd a := by
  simp [leadingCoordinate]

/-- The character `χ(κ) = κ ^ θ κ⁻²` of the torus on the leading coordinate, `θ = 2 ^ (m + 1)`. -/
noncomputable def torusCharacter (m : ℕ) :
    (GaloisField 2 (2 * m + 1))ˣ →* (GaloisField 2 (2 * m + 1))ˣ where
  toFun κ := κ ^ 2 ^ (m + 1) * (κ ^ 2)⁻¹
  map_one' := by simp
  map_mul' x y := by
    simp only [mul_pow, mul_inv]
    exact mul_mul_mul_comm _ _ _ _

theorem coe_torusCharacter (m : ℕ) (κ : (GaloisField 2 (2 * m + 1))ˣ) :
    ((torusCharacter m κ : (GaloisField 2 (2 * m + 1))ˣ) : GaloisField 2 (2 * m + 1)) =
      (κ : GaloisField 2 (2 * m + 1)) ^ 2 ^ (m + 1) / (κ : GaloisField 2 (2 * m + 1)) ^ 2 := by
  simp [torusCharacter, div_eq_mul_inv]

theorem commutatorElement_unipotent (m : ℕ) (a c : GaloisField 2 (2 * m + 1)) :
    ⁅unipotent m a 0, unipotent m (a * c) 0⁆ =
      unipotent m 0 (a ^ (1 + 2 ^ (m + 1)) * (c + c ^ 2 ^ (m + 1))) := by
  have htwo : (2 : GaloisField 2 (2 * m + 1)) = 0 := CharTwo.two_eq_zero
  rw [commutatorElement_def, mul_assoc, ← mul_inv_rev, unipotent_mul_unipotent,
    unipotent_mul_unipotent, unipotent_inv, unipotent_mul_unipotent]
  congr 1
  · linear_combination (a + a * c) * htwo
  · rw [add_comm (a * c) a, mul_pow, pow_add]
    linear_combination ((a + a * c) * (a + a * c) ^ 2 ^ (m + 1)) * htwo

/-- Every `u(0, b)` lies in the commutator subgroup of `X_m`. -/
theorem unipotent_zero_mem_commutator {m : ℕ} (hm : 1 ≤ m) (b : GaloisField 2 (2 * m + 1)) :
    (⟨unipotent m 0 b, unipotent_mem_unipotentSubgroup m 0 b⟩ : unipotentSubgroup m) ∈
      ⁅(⊤ : Subgroup (unipotentSubgroup m)), (⊤ : Subgroup (unipotentSubgroup m))⁆ := by
  classical
  have htwo : (2 : (GaloisField 2 (2 * m + 1))) = 0 := CharTwo.two_eq_zero
  -- some `c₀` has `c₀ ^ θ ≠ c₀`, since `F ≠ GF(2)`
  have hex : ∃ c₀ : (GaloisField 2 (2 * m + 1)), c₀ + c₀ ^ 2 ^ (m + 1) ≠ 0 := by
    by_contra hcon
    push Not at hcon
    have h1 : ∀ c : (GaloisField 2 (2 * m + 1)), c ^ 2 = c := by
      intro c
      have h : c ^ 2 ^ (m + 1) = c := by linear_combination hcon c - c * htwo
      rw [← pow_two_pow_succ_pow_two_pow_succ m c, h, h]
    have hsub : (Set.univ : Set (GaloisField 2 (2 * m + 1))) ⊆ {0, 1} := by
      intro c _
      have : c * (c - 1) = 0 := by linear_combination h1 c
      rcases mul_eq_zero.mp this with h | h
      · simp [h]
      · simp [sub_eq_zero.mp h]
    have hcard : Nat.card (GaloisField 2 (2 * m + 1)) = 2 ^ (2 * m + 1) :=
      GaloisField.card 2 (2 * m + 1) (by omega)
    have hle : Nat.card (GaloisField 2 (2 * m + 1)) ≤ 2 := by
      have := Set.ncard_le_ncard hsub (Set.toFinite _)
      rw [Set.ncard_univ] at this
      exact this.trans ((Set.ncard_insert_le _ _).trans (by simp))
    have h8 : 2 ^ 3 ≤ 2 ^ (2 * m + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
    omega
  obtain ⟨c₀, he⟩ := hex
  set e := c₀ + c₀ ^ 2 ^ (m + 1) with he_def
  by_cases hb : b = 0
  · rw [hb, show (⟨unipotent m 0 0, unipotent_mem_unipotentSubgroup m 0 0⟩ :
      unipotentSubgroup m) = 1 from Subtype.ext (unipotent_zero_zero m)]
    exact Subgroup.one_mem _
  · obtain ⟨μ, hμ⟩ :=
      (bijective_iterateFrobenius (GaloisField 2 (2 * m + 1)) 2 (m + 1)).2 (e / b)
    rw [iterateFrobenius_def] at hμ
    have hμ0 : μ ≠ 0 := by
      rintro rfl
      have : e / b = 0 := by rw [← hμ]; simp
      rcases div_eq_zero_iff.mp this with h | h
      · exact he h
      · exact hb h
    have hμθ0 : μ ^ 2 ^ (m + 1) ≠ 0 := pow_ne_zero _ hμ0
    set a : (GaloisField 2 (2 * m + 1)) := μ ^ 2 ^ (m + 1) / μ ^ 2 with ha
    have haθ : a ^ 2 ^ (m + 1) = μ ^ 2 / (μ ^ 2 ^ (m + 1)) ^ 2 := by
      rw [ha, div_pow, pow_two_pow_succ_pow_two_pow_succ, pow_right_comm]
    have hab : a ^ (1 + 2 ^ (m + 1)) * (c₀ + c₀ ^ 2 ^ (m + 1)) = b := by
      rw [pow_add, pow_one, haθ, ha]
      have : e = b * μ ^ 2 ^ (m + 1) := by
        rw [hμ]; field_simp
      rw [← he_def, this]
      field_simp
    have hc := commutatorElement_unipotent m a c₀
    rw [hab] at hc
    have hmem := Subgroup.commutator_mem_commutator (H₁ := (⊤ : Subgroup (unipotentSubgroup m)))
      (H₂ := ⊤) (g₁ := ⟨unipotent m a 0, unipotent_mem_unipotentSubgroup m a 0⟩)
      (g₂ := ⟨unipotent m (a * c₀) 0, unipotent_mem_unipotentSubgroup m _ 0⟩)
      trivial trivial
    convert hmem using 1
    exact Subtype.ext hc.symm

/-- `X_m` is a `2`-group, hence nilpotent. -/
theorem isNilpotent_unipotentSubgroup (m : ℕ) : Group.IsNilpotent (unipotentSubgroup m) := by
  have h2 : ∀ x : GaloisField 2 (2 * m + 1), x + x = 0 := CharTwo.add_self_eq_zero
  have hp : IsPGroup 2 (unipotentSubgroup m) := by
    intro x
    obtain ⟨a, b, hab⟩ := exists_eq_unipotent_of_mem_unipotentSubgroup x.2
    refine ⟨2, ?_⟩
    apply Subtype.ext
    have hsq : (x : GL (Fin 4) (GaloisField 2 (2 * m + 1))) * x =
        unipotent m 0 (a * a ^ 2 ^ (m + 1)) := by
      rw [hab, unipotent_mul_unipotent, h2 a, h2 b, zero_add]
    have h4 : (x : GL (Fin 4) (GaloisField 2 (2 * m + 1))) ^ 4 = 1 := by
      have : (x : GL (Fin 4) (GaloisField 2 (2 * m + 1))) ^ 4 = (x * x) * (x * x) := by
        simp only [pow_succ, pow_zero, one_mul, mul_assoc]
      rw [this, hsq, unipotent_mul_unipotent, zero_add, zero_mul, add_zero, h2,
        unipotent_zero_zero]
    simpa using h4
  exact IsPGroup.isNilpotent hp

theorem ker_leadingCoordinate_le_commutator {m : ℕ} (hm : 1 ≤ m) :
    (leadingCoordinate m).ker ≤
      ⁅(⊤ : Subgroup (unipotentSubgroup m)), (⊤ : Subgroup (unipotentSubgroup m))⁆ := by
  intro x hx
  obtain ⟨a, b, hab⟩ := exists_eq_unipotent_of_mem_unipotentSubgroup x.2
  have ha : a = 0 := by
    have := congrArg Multiplicative.toAdd (MonoidHom.mem_ker.mp hx)
    have h2 : leadingCoordinate m x = Multiplicative.ofAdd a := by
      rw [show x = ⟨unipotent m a b, unipotent_mem_unipotentSubgroup m a b⟩ from Subtype.ext hab,
        leadingCoordinate_unipotent]
    rw [h2] at this
    simpa using this
  have : x = ⟨unipotent m 0 b, unipotent_mem_unipotentSubgroup m 0 b⟩ := by
    apply Subtype.ext; simp [hab, ha]
  rw [this]
  exact unipotent_zero_mem_commutator hm b

/-- For `m ≥ 1`, `(X_m, λ_m)` is a λ-root group in `GL₄(F)` over `F`. -/
noncomputable def lambdaRootGroup {m : ℕ} (hm : 1 ≤ m) :
    LambdaRootGroup (GL (Fin 4) (GaloisField 2 (2 * m + 1))) (GaloisField 2 (2 * m + 1)) where
  carrier := unipotentSubgroup m
  finite := inferInstance
  isNilpotent := isNilpotent_unipotentSubgroup m
  coordinate := leadingCoordinate m
  ker_coordinate_le_commutator := ker_leadingCoordinate_le_commutator hm

end CFSGCorollary.Suzuki
