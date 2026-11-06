module

public import CFSGCorollary.LieType.Twisted.TwistedD.Torus
import CFSG.LieType.Universal.Spin.Twisted.Generation
import CFSGCorollary.LieType.Twisted.TwistedD.Weyl

/-!
# The short simple root group of `²D_r` as a λ-root group

We show that the short simple root group `X = X_{ℓ,true}` of `Spin⁻_{2r}(K)`, with coordinate
`λ(x_{ℓ,true}(t)) = t`, is a λ-root group over `L = ShortField b c` on which `d` acts by `α²`,
`d₁ = g d g⁻¹` acts by `(star α)²`, and `λ(u) = 1`. We also show that the short root groups
generate `Spin⁻_{2r}(K)`: their commutators give all long root groups.

## Main definitions

* `CFSGCorollary.LambdaRootGroup.ofMulEquiv`: the λ-root group structure on a subgroup isomorphic
  to `Multiplicative L`.

## Main results

* `CFSGCorollary.TwistedD.exists_lambdaRootGroup_shortRootGroup`
* `CFSGCorollary.TwistedD.eq_top_of_shortRootGroup_le`
-/

@[expose] public section

open CFSG.LieType.Universal.Spin CFSG.LieType.Universal.Spin.Twisted

namespace CFSGCorollary

/-! ### λ-root groups from isomorphisms with `Multiplicative L` -/

section Generic

variable {G L : Type*} [Group G] [Field L]

/-- Multiplication by a unit as an automorphism of `Multiplicative L`. -/
noncomputable def mulUnitEquiv (a : Lˣ) : Multiplicative L ≃* Multiplicative L where
  toFun x := Multiplicative.ofAdd ((a : L) * Multiplicative.toAdd x)
  invFun x := Multiplicative.ofAdd (((a⁻¹ : Lˣ) : L) * Multiplicative.toAdd x)
  left_inv x := by simp
  right_inv x := by simp
  map_mul' x y := by simp [mul_add]

variable [Finite L]

namespace LambdaRootGroup

/-- The `λ`-root group on a subgroup `X` isomorphic to `Multiplicative L`, with coordinate the
inverse isomorphism. -/
noncomputable def ofMulEquiv (X : Subgroup G) (e : Multiplicative L ≃* X) :
    LambdaRootGroup G L where
  carrier := X
  finite := Finite.of_equiv _ e.toEquiv
  isNilpotent := Group.nilpotent_of_mulEquiv e
  coordinate := e.symm.toMonoidHom
  ker_coordinate_le_commutator := by
    rw [(MonoidHom.ker_eq_bot_iff _).2 e.symm.injective]
    exact bot_le

/-- If conjugation by `g` acts on `X ≅ Multiplicative L` as multiplication by `a`, then `g` acts
on `ofMulEquiv X e` by `a`. -/
theorem nonempty_action_ofMulEquiv (X : Subgroup G) (e : Multiplicative L ≃* X) (g : G)
    (a : Lˣ) (h : ∀ t : L, g * (e (Multiplicative.ofAdd t) : G) * g⁻¹ =
      (e (Multiplicative.ofAdd ((a : L) * t)) : G)) :
    Nonempty ((ofMulEquiv X e).Action g a) := by
  refine ⟨⟨e.symm.trans ((mulUnitEquiv a).trans e), fun y ↦ ?_, fun y ↦ ?_⟩⟩
  · obtain ⟨t, rfl⟩ := e.surjective y
    change ((e ((mulUnitEquiv a) (e.symm (e t))) : X) : G) = _
    rw [MulEquiv.symm_apply_apply]
    exact (h (Multiplicative.toAdd t)).symm
  · change Multiplicative.toAdd (e.symm (e ((mulUnitEquiv a) (e.symm y)))) = _
    simp [mulUnitEquiv]
    rfl

end LambdaRootGroup

end Generic

namespace TwistedD

/-! ### The short simple root group -/

section ShortRootGroup

variable (r : ℕ) {K : Type} [Field K] {b c : K} (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0)

/-- `t ↦ x_{ℓ,true}(t)` as a homomorphism from `Multiplicative (ShortField b c)`. -/
noncomputable def shortRootHom (hr : 4 ≤ r) :
    Multiplicative (ShortField b c) →* spinGroup (quadMinus r K b c) :=
  (twShortRoot r hirr (lastIndex r hr) true).comp
    (AddEquiv.toMultiplicative fieldCoordAddEquiv).toMonoidHom

theorem shortRootHom_injective (hr : 4 ≤ r) :
    Function.Injective (shortRootHom r hirr hr : Multiplicative (ShortField b c) →* _) :=
  (twShortRoot_injective r hirr (lastIndex r hr) true).comp
    (MulEquiv.injective (AddEquiv.toMultiplicative fieldCoordAddEquiv))

theorem shortRootHom_mem_shortRootGroup (hr : 4 ≤ r) (x : Multiplicative (ShortField b c)) :
    shortRootHom r hirr hr x ∈ shortRootGroup r hirr (lastIndex r hr) true :=
  (mem_shortRootGroup_iff r hirr _ _ _).2 ⟨fieldCoord (Multiplicative.toAdd x), rfl⟩

/-- `t ↦ x_{ℓ,true}(t)` as an isomorphism onto `X_{ℓ,true}`. -/
noncomputable def shortRootEquiv (hr : 4 ≤ r) :
    Multiplicative (ShortField b c) ≃* shortRootGroup r hirr (lastIndex r hr) true :=
  MulEquiv.ofBijective
    ((shortRootHom r hirr hr).codRestrict _ (shortRootHom_mem_shortRootGroup r hirr hr))
    ⟨fun _ _ h ↦ shortRootHom_injective r hirr hr (congrArg Subtype.val h), by
      rintro ⟨z, hz⟩
      obtain ⟨p, rfl⟩ := (mem_shortRootGroup_iff r hirr _ _ _).1 hz
      refine ⟨Multiplicative.ofAdd (fieldCoordAddEquiv.symm p), Subtype.ext ?_⟩
      change twShortRoot r hirr _ true (.ofAdd (fieldCoord (fieldCoordAddEquiv.symm p))) = _
      rw [← fieldCoordAddEquiv_apply, AddEquiv.apply_symm_apply]⟩

theorem coe_shortRootEquiv_ofAdd (hr : 4 ≤ r) (t : ShortField b c) :
    ((shortRootEquiv r hirr hr (Multiplicative.ofAdd t) :
      shortRootGroup r hirr (lastIndex r hr) true) : spinGroup (quadMinus r K b c)) =
      shortRootElement r hirr (lastIndex r hr) true t :=
  rfl

/-- `X_{ℓ,true}` is a `λ`-root group with `λ (x_{ℓ,true} t) = t`, on which `d` acts by `α ^ 2`,
`d₁ = g d g⁻¹` by `(star α) ^ 2`, and `λ u = 1`. -/
theorem exists_lambdaRootGroup_shortRootGroup [Finite K] [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)]
    (hr : 4 ≤ r) (α : (ShortField b c)ˣ) :
    ∃ rootGroup : LambdaRootGroup (spinGroup (quadMinus r K b c)) (ShortField b c),
      rootGroup.carrier = shortRootGroup r hirr (lastIndex r hr) true ∧
      (∀ (t : ShortField b c)
          (h : shortRootElement r hirr (lastIndex r hr) true t ∈ rootGroup.carrier),
        rootGroup.coordinate ⟨_, h⟩ = Multiplicative.ofAdd t) ∧
      Nonempty (rootGroup.Action (torusElement r hirr hr α) (α ^ 2)) ∧
      Nonempty (rootGroup.Action
        (coxeterElement r hirr * torusElement r hirr hr α * (coxeterElement r hirr)⁻¹)
        (starUnit α ^ 2)) ∧
      ∃ h : unipotent r hirr hr ∈ rootGroup.carrier,
        rootGroup.coordinate ⟨_, h⟩ = Multiplicative.ofAdd 1 := by
  have hel := coe_shortRootEquiv_ofAdd r hirr hr (b := b) (c := c)
  have hs : ((starUnit α : (ShortField b c)ˣ) : ShortField b c) = star (α : ShortField b c) :=
    rfl
  have hu : unipotent r hirr hr = shortRootElement r hirr (lastIndex r hr) true 1 := by
    unfold unipotent shortRootElement
    rw [fieldCoord_one]
  have key (t : ShortField b c) :
      coxeterElement r hirr * torusElement r hirr hr α * (coxeterElement r hirr)⁻¹ *
          shortRootElement r hirr (lastIndex r hr) true t *
          (coxeterElement r hirr * torusElement r hirr hr α * (coxeterElement r hirr)⁻¹)⁻¹ =
        shortRootElement r hirr (lastIndex r hr) true ((star (α : ShortField b c)) ^ 2 * t) := by
    have h1 := coxeterElement_conj_shortRootElement_secondLastIndex r hirr hr (star t)
    rw [star_star] at h1
    have h2 := torusElement_conj_shortRootElement_secondLastIndex r hirr hr α (star t)
    have h3 := coxeterElement_conj_shortRootElement_secondLastIndex r hirr hr
      ((α : ShortField b c) ^ 2 * star t)
    rw [star_mul', star_pow, star_star] at h3
    rw [← h3, ← h2, ← h1]
    group
  refine ⟨LambdaRootGroup.ofMulEquiv _ (shortRootEquiv r hirr hr), rfl, ?_, ?_, ?_, ?_⟩
  · intro t h
    change (shortRootEquiv r hirr hr).symm ⟨_, h⟩ = _
    rw [MulEquiv.symm_apply_eq]
    exact Subtype.ext (hel t).symm
  · refine LambdaRootGroup.nonempty_action_ofMulEquiv _ _ _ _ fun t ↦ ?_
    rw [Units.val_pow_eq_pow_val]
    exact torusElement_conj_shortRootElement_lastIndex r hirr hr α t
  · refine LambdaRootGroup.nonempty_action_ofMulEquiv _ _ _ _ fun t ↦ ?_
    rw [Units.val_pow_eq_pow_val, hs]
    exact key t
  · have hy : ((shortRootEquiv r hirr hr (Multiplicative.ofAdd (1 : ShortField b c)) :
        shortRootGroup r hirr (lastIndex r hr) true) : spinGroup (quadMinus r K b c)) =
        unipotent r hirr hr := (hel 1).trans hu.symm
    have h : unipotent r hirr hr ∈
        (LambdaRootGroup.ofMulEquiv _ (shortRootEquiv r hirr hr)).carrier := by
      rw [← hy]
      exact (shortRootEquiv r hirr hr (Multiplicative.ofAdd 1)).2
    refine ⟨h, ?_⟩
    change (shortRootEquiv r hirr hr).symm ⟨_, h⟩ = _
    rw [MulEquiv.symm_apply_eq]
    exact Subtype.ext hy.symm

end ShortRootGroup

/-! ### The short root groups generate `Spin⁻` -/

open scoped commutatorElement in
/-- A subgroup of `Spin⁻_{2r}(K)` containing all short root groups is everything. -/
theorem eq_top_of_shortRootGroup_le (r : ℕ) {K : Type} [Field K] [Finite K] {b c : K}
    (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0) (hr : 4 ≤ r)
    (F : Subgroup (spinGroup (quadMinus r K b c)))
    (hF : ∀ (i : Fin (r - 1)) (s : Bool), shortRootGroup r hirr i s ≤ F) : F = ⊤ := by
  have hlong (i j : Fin (r - 1)) (hij : i ≠ j) (s t : Bool) (a : K) :
      (minusFrame r b c).longRoot hij s t (.ofAdd a) ∈ F := by
    obtain ⟨p, hp⟩ := exists_neg_polarPlane_planeOne_eq hirr a
    have h1 : twShortRoot r hirr i s (.ofAdd p) ∈ F := hF i s ⟨_, rfl⟩
    have h2 : twShortRoot r hirr j t (.ofAdd planeOne) ∈ F := hF j t ⟨_, rfl⟩
    have hmem :
        ⁅twShortRoot r hirr i s (.ofAdd p), twShortRoot r hirr j t (.ofAdd planeOne)⁆ ∈ F := by
      rw [commutatorElement_def]
      exact F.mul_mem (F.mul_mem (F.mul_mem h1 h2) (F.inv_mem h1)) (F.inv_mem h2)
    rwa [commutator_twShortRoot_twShortRoot (n := r) (hirr := hirr) hij s t p planeOne, hp]
      at hmem
  rw [eq_top_iff, ← minusDatum_iSup_eq_top r hirr hr]
  refine iSup₂_le fun γ hγ ↦ ?_
  rcases exists_toStdB_eq_of_mem_roots r hγ with ⟨i, j, hij, s, t, h⟩ | ⟨i, s, h⟩
  · intro x hx
    obtain ⟨a, rfl⟩ := (mem_minusRootGroup_long_iff r hirr hij s t h).1 hx
    exact hlong i j hij s t a
  · intro x hx
    obtain ⟨p, rfl⟩ := (mem_minusRootGroup_short_iff r hirr i s h).1 hx
    exact hF i s ⟨_, rfl⟩

end TwistedD

end CFSGCorollary
