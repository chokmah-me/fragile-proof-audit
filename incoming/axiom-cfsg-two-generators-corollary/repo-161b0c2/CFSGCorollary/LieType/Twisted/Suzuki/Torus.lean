module

public import CFSGCorollary.LieType.Twisted.Suzuki.RootGroup
public import TauCeti.GroupTheory.SpecificGroups.CFSG.Suzuki.Torus

@[expose] public section

/-!
# The torus action on the Suzuki root group

The diagonal torus elements `h(κ)` of the Suzuki group normalise `X_m` and act on the leading
coordinate by the character `χ(κ) = κ ^ θ κ⁻²`, and the Weyl element `w` inverts `h(κ)`. The
character `χ` is injective, hence bijective, so some `χ(κ)` generates `Fˣ`.

## Main results

* `CFSGCorollary.Suzuki.torusAction`: `h(κ)` acts on `(X_m, λ_m)` by `χ(κ)`.
* `CFSGCorollary.Suzuki.weyl_mul_torus_mul_weyl_inv_eq_inv`: `w h(κ) w⁻¹ = h(κ)⁻¹`.
* `CFSGCorollary.Suzuki.exists_generator_torusCharacter`: some `χ(κ)` generates `Fˣ` and is
  not `1`.
-/

namespace CFSGCorollary.Suzuki

open TauCeti.Suzuki (unipotent torus weyl torus_mul_unipotent_mul_torus_inv)

theorem torus_mul_mul_torus_inv_mem_unipotentSubgroup {m : ℕ}
    (κ : (GaloisField 2 (2 * m + 1))ˣ) {x : GL (Fin 4) (GaloisField 2 (2 * m + 1))}
    (hx : x ∈ unipotentSubgroup m) : torus m κ * x * (torus m κ)⁻¹ ∈ unipotentSubgroup m := by
  obtain ⟨a, b, rfl⟩ := hx
  rw [torus_mul_unipotent_mul_torus_inv]
  exact unipotent_mem_unipotentSubgroup m _ _

/-- Conjugation by the torus element `h(κ)` as an automorphism of `X_m`. -/
noncomputable def torusConjugation (m : ℕ) (κ : (GaloisField 2 (2 * m + 1))ˣ) :
    unipotentSubgroup m ≃* unipotentSubgroup m where
  toFun x := ⟨torus m κ * x * (torus m κ)⁻¹,
    torus_mul_mul_torus_inv_mem_unipotentSubgroup κ x.2⟩
  invFun y := ⟨(torus m κ)⁻¹ * y * torus m κ, by
    simpa [map_inv] using torus_mul_mul_torus_inv_mem_unipotentSubgroup κ⁻¹ y.2⟩
  left_inv x := Subtype.ext (by simp [mul_assoc])
  right_inv y := Subtype.ext (by simp [mul_assoc])
  map_mul' x y := Subtype.ext (by simp [mul_assoc])

theorem leadingCoordinate_torusConjugation (m : ℕ) (κ : (GaloisField 2 (2 * m + 1))ˣ)
    (x : unipotentSubgroup m) :
    Multiplicative.toAdd (leadingCoordinate m (torusConjugation m κ x)) =
      ((torusCharacter m κ : (GaloisField 2 (2 * m + 1))ˣ) : GaloisField 2 (2 * m + 1)) *
        Multiplicative.toAdd (leadingCoordinate m x) := by
  rcases x with ⟨x, a, b, rfl⟩
  have h : torusConjugation m κ ⟨unipotent m a b, a, b, rfl⟩ =
      ⟨unipotent m ((κ : GaloisField 2 (2 * m + 1)) ^ 2 ^ (m + 1) /
          (κ : GaloisField 2 (2 * m + 1)) ^ 2 * a)
        (b / (κ : GaloisField 2 (2 * m + 1)) ^ 2 ^ (m + 1)),
        unipotent_mem_unipotentSubgroup m _ _⟩ :=
    Subtype.ext (torus_mul_unipotent_mul_torus_inv m κ a b)
  rw [h, leadingCoordinate_unipotent, leadingCoordinate_unipotent, coe_torusCharacter]
  simp [div_mul_eq_mul_div]

/-- For `m ≥ 1`, `h(κ)` acts on the λ-root group `(X_m, λ_m)` by `χ(κ) = κ ^ θ κ⁻²`. -/
noncomputable def torusAction {m : ℕ} (hm : 1 ≤ m) (κ : (GaloisField 2 (2 * m + 1))ˣ) :
    (lambdaRootGroup hm).Action (torus m κ) (torusCharacter m κ) where
  conjugation := torusConjugation m κ
  coe_conjugation _ := rfl
  coordinate_conjugation r := leadingCoordinate_torusConjugation m κ r

theorem weyl_mul_torus_mul_weyl_inv (m : ℕ) (κ : (GaloisField 2 (2 * m + 1))ˣ) :
    weyl m * torus m κ * (weyl m)⁻¹ = torus m κ⁻¹ := by
  rw [TauCeti.Suzuki.weyl_inv]
  apply Matrix.GeneralLinearGroup.ext
  intro i j
  have hκ : (κ : GaloisField 2 (2 * m + 1)) ≠ 0 := κ.ne_zero
  simp only [Units.val_mul, TauCeti.Suzuki.coe_weyl, TauCeti.Suzuki.coe_torus]
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_four, TauCeti.Suzuki.weylMatrix_apply,
      TauCeti.Suzuki.torusMatrix_apply, Matrix.diagonal_apply, inv_pow]
  all_goals field_simp

/-- The Weyl element `w` inverts the torus element `h(κ)`. -/
theorem weyl_mul_torus_mul_weyl_inv_eq_inv (m : ℕ) (κ : (GaloisField 2 (2 * m + 1))ˣ) :
    weyl m * torus m κ * (weyl m)⁻¹ = (torus m κ)⁻¹ := by
  rw [weyl_mul_torus_mul_weyl_inv, map_inv]

theorem torusCharacter_injective (m : ℕ) : Function.Injective (torusCharacter m) := by
  rw [injective_iff_map_eq_one]
  intro κ hκ
  have h := congrArg (fun x : (GaloisField 2 (2 * m + 1))ˣ ↦ (x : GaloisField 2 (2 * m + 1))) hκ
  simp only [coe_torusCharacter, Units.val_one] at h
  have hne : (κ : GaloisField 2 (2 * m + 1)) ≠ 0 := κ.ne_zero
  have h1 : (κ : GaloisField 2 (2 * m + 1)) ^ 2 ^ (m + 1) =
      (κ : GaloisField 2 (2 * m + 1)) ^ 2 := by
    rwa [div_eq_one_iff_eq (pow_ne_zero _ hne)] at h
  have h2 := TauCeti.Suzuki.pow_two_pow_succ_pow_two_pow_succ m (κ : GaloisField 2 (2 * m + 1))
  rw [h1] at h2
  have h2' : ((κ : GaloisField 2 (2 * m + 1)) ^ 2) ^ 2 ^ (m + 1) =
      ((κ : GaloisField 2 (2 * m + 1)) ^ 2 ^ (m + 1)) ^ 2 := by
    rw [← pow_mul, ← pow_mul]; exact congrArg _ (Nat.mul_comm _ _)
  rw [h2', h1] at h2
  have h3 : (κ : GaloisField 2 (2 * m + 1)) ^ 2 = 1 := by
    have : (κ : GaloisField 2 (2 * m + 1)) ^ 2 *
        ((κ : GaloisField 2 (2 * m + 1)) ^ 2 - 1) = 0 := by
      linear_combination h2
    rcases mul_eq_zero.1 this with h | h
    · exact absurd h (pow_ne_zero _ hne)
    · exact sub_eq_zero.1 h
  have h4 : ((κ : GaloisField 2 (2 * m + 1)) - 1) ^ 2 = 0 := by
    have : ((2 : GaloisField 2 (2 * m + 1))) = 0 := CharP.cast_eq_zero (GaloisField 2 (2 * m + 1)) 2
    linear_combination h3 + (1 - (κ : GaloisField 2 (2 * m + 1))) * this
  have := pow_eq_zero_iff two_ne_zero |>.1 h4
  ext
  simpa [sub_eq_zero] using this

/-- For `m ≥ 1` some torus character value `χ(κ) = κ ^ θ κ⁻²` generates `Fˣ` and is `≠ 1`. -/
theorem exists_generator_torusCharacter {m : ℕ} (hm : 1 ≤ m) :
    ∃ κ : (GaloisField 2 (2 * m + 1))ˣ,
      (∀ y : (GaloisField 2 (2 * m + 1))ˣ, y ∈ Subgroup.zpowers (torusCharacter m κ)) ∧
        torusCharacter m κ ≠ 1 := by
  obtain ⟨γ, hγ⟩ := IsCyclic.exists_generator (α := (GaloisField 2 (2 * m + 1))ˣ)
  have hsurj : Function.Surjective (torusCharacter m) :=
    Finite.injective_iff_surjective.1 (torusCharacter_injective m)
  obtain ⟨κ, hκ⟩ := hsurj γ
  refine ⟨κ, by rw [hκ]; exact hγ, ?_⟩
  rw [hκ]
  intro h1
  have hs : Subsingleton (GaloisField 2 (2 * m + 1))ˣ := by
    refine ⟨fun a b ↦ ?_⟩
    have ha := hγ a
    have hb := hγ b
    rw [h1, Subgroup.zpowers_one_eq_bot, Subgroup.mem_bot] at ha hb
    rw [ha, hb]
  have hc := Nat.card_units (GaloisField 2 (2 * m + 1))
  rw [GaloisField.card 2 (2 * m + 1) (by omega)] at hc
  have h1' : Nat.card (GaloisField 2 (2 * m + 1))ˣ = 1 := Nat.card_unique
  have : 2 ^ 3 ≤ 2 ^ (2 * m + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  omega

end CFSGCorollary.Suzuki
