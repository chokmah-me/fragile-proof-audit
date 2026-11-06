module

public import CFSGCorollary.LieType.Twisted.TwistedE6.RootGroups

/-!
# Conjugating the `²E₆` torus by the Coxeter element

The element `n = n₀ n₁ n₂ n₃` of `fixedGroup K θ` (a lift of a Coxeter element of the relative
Weyl group `W(F₄)`) conjugates the torus element `torU (torusVecD t)` to `torU (torusVecD₁ t)`.
We compute this by conjugating the `E₆` torus by the six simple reflections `n₁ n₄ n₃ n₅ n₂ n₆`
one at a time.

## Main results

* `CFSGCorollary.TwistedE6.nHat_prod_mul_torU_mul_inv_and_commute`
-/

@[expose] public section

namespace CFSGCorollary.TwistedE6

open CFSG.Blueprint.Chevalley (Tag)
open CFSG.LieType.Steinberg.TwistedE6 (nd nf IsSymU nHat)
open CFSG.LieType.Steinberg.CentralExt.TwistedE6Closed (torU torU_val)

open CFSG.LieType.Steinberg.CentralExt.MinusculeClosed CFSG.LieType.Steinberg.Minuscule
  CFSG.LieType.Steinberg.TwistedE6 in
/-- The Coxeter element `n = n₀ n₁ n₂ n₃` conjugates `torU (torusVecD t)` to
`torU (torusVecD₁ t)`, and these two torus elements commute. -/
theorem nHat_prod_mul_torU_mul_inv_and_commute {K : Type} [Field K] (θ : K →+* K)
    (t : Kˣ) (hd : IsSymU θ (torusVecD θ t)) (hd₁ : IsSymU θ (torusVecD₁ θ t)) :
    nHat θ (nf 0) * nHat θ (nf 1) * nHat θ (nf 2) * nHat θ (nf 3) * torU θ _ hd *
        (nHat θ (nf 0) * nHat θ (nf 1) * nHat θ (nf 2) * nHat θ (nf 3))⁻¹ = torU θ _ hd₁ ∧
      torU θ _ hd * torU θ _ hd₁ = torU θ _ hd₁ * torU θ _ hd := by
  have key : ∀ (c : Fin (Tag.rank .E6)) (u : Fin (Tag.rank .E6) → Kˣ),
      e6Data_valid.nm K c * minTorus e6Data_valid K u * (e6Data_valid.nm K c)⁻¹ =
      minTorus e6Data_valid K (u * Pi.mulSingle c (chiHom c u)) :=
    fun c u ↦ nm_conj_torusHom c u
  have comm : torU θ _ hd * torU θ _ hd₁ = torU θ _ hd₁ * torU θ _ hd := by
    refine Subtype.ext ?_
    simp only [Subgroup.coe_mul, torU_val, ← map_mul]
    congr 1
    exact mul_comm _ _
  refine ⟨?_, comm⟩
  refine Subtype.ext ?_
  simp only [Subgroup.coe_mul, Subgroup.coe_inv, nHat_val, torU_val, nHatE_zero, nHatE_one,
    nHatE_two, nHatE_three]
  have e : ∀ (a b c d e f x : e6Data_valid.minGroup K),
      a * b * (c * d) * (e * f) * x * (a * b * (c * d) * (e * f))⁻¹ =
      a * (b * (c * (d * (e * (f * x * f⁻¹) * e⁻¹) * d⁻¹) * c⁻¹) * b⁻¹) * a⁻¹ := by
    intros; group
  have chi : ∀ (u : Fin 6 → Kˣ),
      chiHom (0 : Fin 6) u = (u 0)⁻¹ ^ 2 * u 2 ∧ chiHom (1 : Fin 6) u = (u 1)⁻¹ ^ 2 * u 3 ∧
      chiHom (2 : Fin 6) u = (u 2)⁻¹ ^ 2 * u 0 * u 3 ∧
      chiHom (3 : Fin 6) u = (u 3)⁻¹ ^ 2 * u 1 * u 2 * u 4 ∧
      chiHom (4 : Fin 6) u = (u 4)⁻¹ ^ 2 * u 3 * u 5 ∧
      chiHom (5 : Fin 6) u = (u 5)⁻¹ ^ 2 * u 4 := by
    intro u
    have h0 : ∀ a, Tag.cartanE 6 a 0 = if a = 0 then 2 else if a = 2 then -1 else 0 := by
      decide
    have h1 : ∀ a, Tag.cartanE 6 a 1 = if a = 1 then 2 else if a = 3 then -1 else 0 := by
      decide
    have h2 : ∀ a, Tag.cartanE 6 a 2 =
        if a = 2 then 2 else if a = 0 ∨ a = 3 then -1 else 0 := by
      decide
    have h3 : ∀ a, Tag.cartanE 6 a 3 =
        if a = 3 then 2 else if a = 1 ∨ a = 2 ∨ a = 4 then -1 else 0 := by
      decide
    have h4 : ∀ a, Tag.cartanE 6 a 4 =
        if a = 4 then 2 else if a = 3 ∨ a = 5 then -1 else 0 := by
      decide
    have h5 : ∀ a, Tag.cartanE 6 a 5 = if a = 5 then 2 else if a = 4 then -1 else 0 := by
      decide
    refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
    · change ∏ a : Fin 6, u a ^ (-(Tag.cartanE 6 a 0)) = _
      rw [Fin.prod_univ_six]; simp only [h0]; simp [mul_comm]
    · change ∏ a : Fin 6, u a ^ (-(Tag.cartanE 6 a 1)) = _
      rw [Fin.prod_univ_six]; simp only [h1]; simp [mul_comm]
    · change ∏ a : Fin 6, u a ^ (-(Tag.cartanE 6 a 2)) = _
      rw [Fin.prod_univ_six]; simp only [h2]; simp [mul_comm, mul_assoc]
    · change ∏ a : Fin 6, u a ^ (-(Tag.cartanE 6 a 3)) = _
      rw [Fin.prod_univ_six]; simp only [h3]; simp [mul_comm, mul_left_comm, mul_assoc]
    · change ∏ a : Fin 6, u a ^ (-(Tag.cartanE 6 a 4)) = _
      rw [Fin.prod_univ_six]; simp only [h4]; simp [mul_comm, mul_assoc]
    · change ∏ a : Fin 6, u a ^ (-(Tag.cartanE 6 a 5)) = _
      rw [Fin.prod_univ_six]; simp only [h5]; simp [mul_comm]
  set s : Kˣ := Units.map (θ : K →* K) t with hs
  let T6 : (Fin 6 → Kˣ) → e6Data_valid.minGroup K := fun u ↦ minTorus e6Data_valid K u
  let N : Fin 6 → e6Data_valid.minGroup K := fun c ↦ e6Data_valid.nm K c
  have st : ∀ (c : Fin 6) (u v : Fin 6 → Kˣ) (x : Kˣ), chiHom c u = x →
      (∀ a : Fin 6, (u a * (Pi.mulSingle c x : Fin 6 → Kˣ) a = v a)) →
      N c * T6 u * (N c)⁻¹ = T6 v := fun c u v x hx h ↦ by
    refine (key c u).trans ?_
    rw [hx]; congr 1; exact funext h
  have hV : (torusVecD θ t : Fin 6 → Kˣ) =
      (Pi.mulSingle (0 : Fin 6) t * Pi.mulSingle (5 : Fin 6) s : Fin 6 → Kˣ) := rfl
  have s0 := st 5 (Pi.mulSingle (0 : Fin 6) t * Pi.mulSingle (5 : Fin 6) s)
    ![t, 1, 1, 1, 1, s⁻¹] _ (chi _).2.2.2.2.2 (by
      intro a
      fin_cases a <;> simp
      group)
  have s1 := st 0 ![t, 1, 1, 1, 1, s⁻¹] ![t⁻¹, 1, 1, 1, 1, s⁻¹] _ (chi _).1 (by
    intro a
    fin_cases a <;> simp
    group)
  have s2 := st 4 ![t⁻¹, 1, 1, 1, 1, s⁻¹] ![t⁻¹, 1, 1, 1, s⁻¹, s⁻¹] _ (chi _).2.2.2.2.1 (by
    intro a
    fin_cases a <;> simp)
  have s3 := st 2 ![t⁻¹, 1, 1, 1, s⁻¹, s⁻¹] ![t⁻¹, 1, t⁻¹, 1, s⁻¹, s⁻¹] _ (chi _).2.2.1 (by
    intro a
    fin_cases a <;> simp)
  have s4 := st 3 ![t⁻¹, 1, t⁻¹, 1, s⁻¹, s⁻¹] ![t⁻¹, 1, t⁻¹, (t * s)⁻¹, s⁻¹, s⁻¹] _
    (chi _).2.2.2.1 (by
      intro a
      fin_cases a <;> simp [mul_comm])
  have s5 := st 1 ![t⁻¹, 1, t⁻¹, (t * s)⁻¹, s⁻¹, s⁻¹] (torusVecD₁ θ t) _ (chi _).2.1 (by
    intro a
    fin_cases a <;> simp [torusVecD₁, hs])
  have final : N 1 * (N 3 * (N 2 * (N 4 * (N 0 * (N 5 *
      T6 (Pi.mulSingle (0 : Fin 6) t * Pi.mulSingle (5 : Fin 6) s) * (N 5)⁻¹) *
      (N 0)⁻¹) * (N 4)⁻¹) * (N 2)⁻¹) * (N 3)⁻¹) * (N 1)⁻¹ = T6 (torusVecD₁ θ t) := by
    rw [s0, s1, s2, s3, s4, s5]
  rw [← hV] at final
  rw [e]
  exact final

end CFSGCorollary.TwistedE6
