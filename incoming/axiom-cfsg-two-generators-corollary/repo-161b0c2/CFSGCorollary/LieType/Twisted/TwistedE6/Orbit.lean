module

public import CFSG.LieType.Steinberg.TwistedE6.Local
import CFSG.LieType.Steinberg.TwistedE6.Weyl
import CFSGCorollary.LieType.Twisted.Basic

/-!
# Orbits of the `²E₆` Coxeter element on root groups

Conjugation by `n = n₀ n₁ n₂ n₃` maps the root group `X β` of `fixedGroup K θ` to `X (w β)`,
where `w = s₀ s₁ s₂ s₃` is a Coxeter element of `W(F₄)`. Following the `w`-orbits of the short
simple root `e₃` and of the long root `![0,1,2,0]`, a subgroup containing `n` and one of these
root groups contains several simple root groups and their opposites.

## Main results

* `CFSGCorollary.TwistedE6.rootGroup_short_le`: from `n` and `X e₃` one gets `X (±e₂)`,
  `X (-e₃)` and `X ![0,1,1,0]`.
* `CFSGCorollary.TwistedE6.rootGroup_long_simple_le`: from `n` and `X ![0,1,2,0]` one gets
  `X (±e₀)` and `X (±e₁)`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedE6

open CFSG.Blueprint.Chevalley (Tag IsRoot reflect)
open CFSG.LieType.Steinberg.TwistedE6 (nf twistedRootGroup fixedGroup nHat)

/-- Conjugation by `n = n₀ n₁ n₂ n₃` maps `X β` onto
`X (reflect (nf 0) (reflect (nf 1) (reflect (nf 2) (reflect (nf 3) β))))`. -/
theorem map_conj_nHat_prod_rootGroup {K : Type} [Field K] (θ : K →+* K)
    {β : Fin (Tag.rank .F4) → ℤ} (hβ : IsRoot .F4 β) :
    (twistedRootGroup K θ β).map
        (MulAut.conj (nHat θ (nf 0) * nHat θ (nf 1) * nHat θ (nf 2) * nHat θ (nf 3))).toMonoidHom =
      twistedRootGroup K θ (reflect .F4 (nf 0) (reflect .F4 (nf 1)
        (reflect .F4 (nf 2) (reflect .F4 (nf 3) β)))) := by
  have := map_conj_word_rootGroup_eq (twistedRootGroup K θ) (nHat θ)
    (fun i _ hβ _ hx ↦ CFSG.LieType.Steinberg.TwistedE6.nHat_conj_mem θ i hβ hx)
    (CFSG.LieType.Steinberg.TwistedE6.hHat K θ)
    (fun i ↦ CFSG.LieType.Steinberg.TwistedE6.nHat_sq_mem θ i)
    (fun i _ hβ _ hh _ hx ↦ CFSG.LieType.Steinberg.TwistedE6.hHat_conj_mem θ i hβ hh hx)
    [nf 0, nf 1, nf 2, nf 3] β hβ
  simpa [mul_assoc] using this

/-- The Coxeter element `w = s₀ s₁ s₂ s₃` of `F₄`, acting on root coordinates. -/
abbrev coxeterMapF4 (v : Fin (Tag.rank .F4) → ℤ) : Fin (Tag.rank .F4) → ℤ :=
  reflect .F4 (nf 0) (reflect .F4 (nf 1) (reflect .F4 (nf 2) (reflect .F4 (nf 3) v)))

/-- Some values of `w ^ k` on `e₃` and on `ℓ = ![0,1,2,0]`. -/
theorem coxeterMapF4_iterate_values :
    coxeterMapF4^[5] (Pi.single (nf 3) 1) = -Pi.single (nf 2) 1 ∧
      coxeterMapF4^[6] (Pi.single (nf 3) 1) = -Pi.single (nf 3) 1 ∧
      coxeterMapF4^[8] (Pi.single (nf 3) 1) = ![0, 1, 1, 0] ∧
      coxeterMapF4^[11] (Pi.single (nf 3) 1) = Pi.single (nf 2) 1 ∧
      coxeterMapF4^[2] ![0, 1, 2, 0] = -Pi.single (nf 0) 1 ∧
      coxeterMapF4^[3] ![0, 1, 2, 0] = -Pi.single (nf 1) 1 ∧
      coxeterMapF4^[8] ![0, 1, 2, 0] = Pi.single (nf 0) 1 ∧
      coxeterMapF4^[9] ![0, 1, 2, 0] = Pi.single (nf 1) 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> (funext i; fin_cases i <;> decide)

theorem isRoot_iterate_coxeterMapF4 {β : Fin (Tag.rank .F4) → ℤ} (hβ : IsRoot .F4 β) (k : ℕ) :
    IsRoot .F4 (coxeterMapF4^[k] β) := by
  induction k with
  | zero => exact hβ
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    exact IsRoot.reflect _ (IsRoot.reflect _ (IsRoot.reflect _ (IsRoot.reflect _ ih)))

private theorem map_conj_le_of_mem {G : Type*} [Group G] {F : Subgroup G} {g : G} (hg : g ∈ F)
    {S : Subgroup G} (hS : S ≤ F) : S.map (MulAut.conj g).toMonoidHom ≤ F := by
  rintro _ ⟨x, hx, rfl⟩
  have := F.mul_mem (F.mul_mem hg (hS hx)) (F.inv_mem hg)
  simpa [MulAut.conj_apply] using this

theorem rootGroup_iterate_coxeterMapF4_le {K : Type} [Field K] (θ : K →+* K)
    (F : Subgroup (fixedGroup K θ))
    (hn : nHat θ (nf 0) * nHat θ (nf 1) * nHat θ (nf 2) * nHat θ (nf 3) ∈ F)
    {β : Fin (Tag.rank .F4) → ℤ} (hβ : IsRoot .F4 β) (h : twistedRootGroup K θ β ≤ F) (k : ℕ) :
    twistedRootGroup K θ (coxeterMapF4^[k] β) ≤ F := by
  induction k with
  | zero => exact h
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    have hr := isRoot_iterate_coxeterMapF4 hβ k
    rw [coxeterMapF4, ← map_conj_nHat_prod_rootGroup θ hr]
    exact map_conj_le_of_mem hn ih

/-- A subgroup containing `n` and `X e₃` contains `X (±e₂)`, `X (-e₃)` and `X ![0,1,1,0]`. -/
theorem rootGroup_short_le {K : Type} [Field K] (θ : K →+* K) (F : Subgroup (fixedGroup K θ))
    (hn : nHat θ (nf 0) * nHat θ (nf 1) * nHat θ (nf 2) * nHat θ (nf 3) ∈ F)
    (h : twistedRootGroup K θ (Pi.single (nf 3) 1) ≤ F) :
    twistedRootGroup K θ (Pi.single (nf 2) 1) ≤ F ∧
      twistedRootGroup K θ (-Pi.single (nf 2) 1) ≤ F ∧
      twistedRootGroup K θ (-Pi.single (nf 3) 1) ≤ F ∧
      twistedRootGroup K θ ![0, 1, 1, 0] ≤ F := by
  have hb : IsRoot .F4 (Pi.single (nf 3) 1 : Fin (Tag.rank .F4) → ℤ) := IsRoot.basis (nf 3)
  obtain ⟨h5, h6, h8, h11, -⟩ := coxeterMapF4_iterate_values
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [← h11]; exact rootGroup_iterate_coxeterMapF4_le θ F hn hb h _
  · rw [← h5]; exact rootGroup_iterate_coxeterMapF4_le θ F hn hb h _
  · rw [← h6]; exact rootGroup_iterate_coxeterMapF4_le θ F hn hb h _
  · rw [← h8]; exact rootGroup_iterate_coxeterMapF4_le θ F hn hb h _

/-- A subgroup containing `n` and `X ![0,1,2,0]` contains `X (±e₀)` and `X (±e₁)`. -/
theorem rootGroup_long_simple_le {K : Type} [Field K] (θ : K →+* K)
    (F : Subgroup (fixedGroup K θ))
    (hn : nHat θ (nf 0) * nHat θ (nf 1) * nHat θ (nf 2) * nHat θ (nf 3) ∈ F)
    (h : twistedRootGroup K θ ![0, 1, 2, 0] ≤ F) :
    twistedRootGroup K θ (Pi.single (nf 0) 1) ≤ F ∧
      twistedRootGroup K θ (-Pi.single (nf 0) 1) ≤ F ∧
      twistedRootGroup K θ (Pi.single (nf 1) 1) ≤ F ∧
      twistedRootGroup K θ (-Pi.single (nf 1) 1) ≤ F := by
  have h4 : coxeterMapF4^[4] (Pi.single (nf 0) 1) = ![0, 1, 2, 0] := by
    funext i; fin_cases i <;> decide
  have hb : IsRoot .F4 (![0, 1, 2, 0] : Fin (Tag.rank .F4) → ℤ) := by
    rw [← h4]
    exact isRoot_iterate_coxeterMapF4 (IsRoot.basis (nf 0)) 4
  obtain ⟨-, -, -, -, h2, h3, h8, h9⟩ := coxeterMapF4_iterate_values
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [← h8]; exact rootGroup_iterate_coxeterMapF4_le θ F hn hb h _
  · rw [← h2]; exact rootGroup_iterate_coxeterMapF4_le θ F hn hb h _
  · rw [← h9]; exact rootGroup_iterate_coxeterMapF4_le θ F hn hb h _
  · rw [← h3]; exact rootGroup_iterate_coxeterMapF4_le θ F hn hb h _

end CFSGCorollary.TwistedE6
