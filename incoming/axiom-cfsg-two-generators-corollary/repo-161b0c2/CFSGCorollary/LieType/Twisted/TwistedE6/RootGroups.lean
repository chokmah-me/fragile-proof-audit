module

public import CFSGCorollary.LieType.LambdaRootGroup.Basic
public import CFSG.LieType.Steinberg.CentralExt.TwistedE6Torus

/-!
# Roots, torus elements and the short root group of `²E₆`

We work in CFSG's model `fixedGroup K θ` of `²E₆(q)`: the fixed points of the graph-field
automorphism `σ` of the minuscule `E₆` group, where `θ` is a field involution with
`θ c = c ^ q`. The relative root system is of type `F₄`; its root groups are
`twistedRootGroup K θ β`.

This file fixes the `E₆` roots used in the two-generation argument and the torus vectors
`torusVecD θ t`, `torusVecD₁ θ t`, and shows that the short simple root group `X e₃` is a
λ-root group over `K` on which the torus acts through `rootChar`.

## Main definitions

* `CFSGCorollary.TwistedE6.alphaOne`, `gammaRoot`, `deltaRoot`, `epsRoot`: roots of `E₆`.
* `CFSGCorollary.TwistedE6.torusVecD`, `torusVecD₁`: two `σ`-symmetric torus vectors.
* `CFSGCorollary.TwistedE6.shortRootGroup`: the root group `X e₃` as a λ-root group.

## Main results

* `CFSGCorollary.TwistedE6.exists_shortRootGroup`: `X e₃` is a λ-root group on which
  `torU (torusVecD t)` acts by `t ^ 2` and `torU (torusVecD₁ t)` by `t⁻¹`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedE6

open CFSG.Blueprint.Chevalley (Tag IsRoot reflect)
open CFSG.LieType.Steinberg.TwistedE6 (nd nf rho IsSymU twistedRootGroup fixedGroup xPair proj
  twistSign)
open CFSG.LieType.Chevalley.ExceptionalCover (rootChar cartanCoord)
open CFSG.LieType.Steinberg.Minuscule (e6Data_valid)
open CFSG.LieType.Steinberg.CentralExt.TwistedE6Closed (torU)

/-- The simple root `α₁` of `E₆` (projecting to the short simple root `e₃` of `F₄`). -/
abbrev alphaOne : Fin (Tag.rank .E6) → ℤ := Pi.single (nd 0) 1

/-- The root `γ = α₃` of `E₆` (projecting to `e₂`). -/
abbrev gammaRoot : Fin (Tag.rank .E6) → ℤ := Pi.single (nd 2) 1

/-- The root `δ = α₃ + α₄` of `E₆` (projecting to `![0,1,1,0]`). -/
abbrev deltaRoot : Fin (Tag.rank .E6) → ℤ := ![0, 0, 1, 1, 0, 0]

/-- The `ρ`-fixed root `ε = α₃ + α₄ + α₅` of `E₆` (projecting to `![0,1,2,0]`). -/
abbrev epsRoot : Fin (Tag.rank .E6) → ℤ := ![0, 0, 1, 1, 1, 0]

theorem isRoot_alphaOne : IsRoot .E6 alphaOne := IsRoot.basis _

theorem isRoot_gammaRoot : IsRoot .E6 gammaRoot := IsRoot.basis _

theorem isRoot_deltaRoot : IsRoot .E6 deltaRoot := by
  have h := IsRoot.reflect (τ := .E6) (nd 3) (IsRoot.basis (τ := .E6) (nd 2))
  have e : reflect .E6 (nd 3) (Pi.single (nd 2) 1) = deltaRoot := by
    funext i; fin_cases i <;> decide
  rwa [e] at h

theorem isRoot_epsRoot : IsRoot .E6 epsRoot := by
  have h := IsRoot.reflect (τ := .E6) (nd 4) isRoot_deltaRoot
  have e : reflect .E6 (nd 4) deltaRoot = epsRoot := by
    funext i; fin_cases i <;> decide
  rwa [e] at h

theorem rho_alphaOne_ne : rho alphaOne ≠ alphaOne := by decide

theorem rho_gammaRoot_ne : rho gammaRoot ≠ gammaRoot := by decide

theorem rho_deltaRoot_ne : rho deltaRoot ≠ deltaRoot := by decide

theorem rho_epsRoot : rho epsRoot = epsRoot := by decide

/-- The torus vector `(t, 1, 1, 1, 1, θ t)` of `E₆`. -/
abbrev torusVecD {K : Type} [Field K] (θ : K →+* K) (t : Kˣ) : Fin (Tag.rank .E6) → Kˣ :=
  Pi.mulSingle (nd 0) t * Pi.mulSingle (nd 5) (Units.map (θ : K →* K) t)

/-- The torus vector `(t⁻¹, (t θt)⁻¹, t⁻¹, (t θt)⁻¹, θt⁻¹, θt⁻¹)` of `E₆`. -/
abbrev torusVecD₁ {K : Type} [Field K] (θ : K →+* K) (t : Kˣ) : Fin (Tag.rank .E6) → Kˣ :=
  ![t⁻¹, (t * Units.map (θ : K →* K) t)⁻¹, t⁻¹, (t * Units.map (θ : K →* K) t)⁻¹,
    (Units.map (θ : K →* K) t)⁻¹, (Units.map (θ : K →* K) t)⁻¹]

private theorem torusVecD_apply {K : Type} [Field K] (θ : K →+* K) (t : Kˣ)
    (i : Fin (Tag.rank .E6)) :
    torusVecD θ t i = (Pi.mulSingle (nd 0) t : Fin (Tag.rank .E6) → Kˣ) i *
      (Pi.mulSingle (nd 5) (Units.map (θ : K →* K) t) : Fin (Tag.rank .E6) → Kˣ) i :=
  rfl

private theorem torusVecD_nd_zero {K : Type} [Field K] (θ : K →+* K) (t : Kˣ) :
    torusVecD θ t (nd 0) = t := by
  rw [torusVecD_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne (by decide), mul_one]

private theorem torusVecD_nd_two {K : Type} [Field K] (θ : K →+* K) (t : Kˣ) :
    torusVecD θ t (nd 2) = 1 := by
  rw [torusVecD_apply, Pi.mulSingle_eq_of_ne (by decide), Pi.mulSingle_eq_of_ne (by decide),
    mul_one]

theorem isSymU_torusVecD {K : Type} [Field K] (θ : K →+* K) (hθ : ∀ c : K, θ (θ c) = c)
    (t : Kˣ) : IsSymU θ (torusVecD θ t) := by
  have hθu : ∀ s : Kˣ, Units.map (θ : K →* K) (Units.map (θ : K →* K) s) = s :=
    fun s ↦ Units.ext (hθ s)
  have e1 : torusVecD θ t (nd 1) = 1 := by
    rw [torusVecD_apply, Pi.mulSingle_eq_of_ne (by decide), Pi.mulSingle_eq_of_ne (by decide),
      mul_one]
  have e3 : torusVecD θ t (nd 3) = 1 := by
    rw [torusVecD_apply, Pi.mulSingle_eq_of_ne (by decide), Pi.mulSingle_eq_of_ne (by decide),
      mul_one]
  have e4 : torusVecD θ t (nd 4) = 1 := by
    rw [torusVecD_apply, Pi.mulSingle_eq_of_ne (by decide), Pi.mulSingle_eq_of_ne (by decide),
      mul_one]
  have e5 : torusVecD θ t (nd 5) = Units.map (θ : K →* K) t := by
    rw [torusVecD_apply, Pi.mulSingle_eq_of_ne (by decide), Pi.mulSingle_eq_same, one_mul]
  intro a
  fin_cases a
  · change torusVecD θ t (nd 5) = Units.map (θ : K →* K) (torusVecD θ t (nd 0))
    rw [e5, torusVecD_nd_zero]
  · change torusVecD θ t (nd 1) = Units.map (θ : K →* K) (torusVecD θ t (nd 1))
    rw [e1, map_one]
  · change torusVecD θ t (nd 4) = Units.map (θ : K →* K) (torusVecD θ t (nd 2))
    rw [e4, torusVecD_nd_two, map_one]
  · change torusVecD θ t (nd 3) = Units.map (θ : K →* K) (torusVecD θ t (nd 3))
    rw [e3, map_one]
  · change torusVecD θ t (nd 2) = Units.map (θ : K →* K) (torusVecD θ t (nd 4))
    rw [torusVecD_nd_two, e4, map_one]
  · change torusVecD θ t (nd 0) = Units.map (θ : K →* K) (torusVecD θ t (nd 5))
    rw [torusVecD_nd_zero, e5, hθu]

theorem isSymU_torusVecD₁ {K : Type} [Field K] (θ : K →+* K) (hθ : ∀ c : K, θ (θ c) = c)
    (t : Kˣ) : IsSymU θ (torusVecD₁ θ t) := by
  have hθu : ∀ s : Kˣ, Units.map (θ : K →* K) (Units.map (θ : K →* K) s) = s :=
    fun s ↦ Units.ext (hθ s)
  intro a
  fin_cases a
  · change (Units.map (θ : K →* K) t)⁻¹ = Units.map (θ : K →* K) t⁻¹
    rw [map_inv]
  · change (t * Units.map (θ : K →* K) t)⁻¹ =
      Units.map (θ : K →* K) (t * Units.map (θ : K →* K) t)⁻¹
    rw [map_inv, map_mul, hθu, mul_comm]
  · change (Units.map (θ : K →* K) t)⁻¹ = Units.map (θ : K →* K) t⁻¹
    rw [map_inv]
  · change (t * Units.map (θ : K →* K) t)⁻¹ =
      Units.map (θ : K →* K) (t * Units.map (θ : K →* K) t)⁻¹
    rw [map_inv, map_mul, hθu, mul_comm]
  · change t⁻¹ = Units.map (θ : K →* K) (Units.map (θ : K →* K) t)⁻¹
    rw [map_inv, hθu]
  · change t⁻¹ = Units.map (θ : K →* K) (Units.map (θ : K →* K) t)⁻¹
    rw [map_inv, hθu]

theorem rootChar_alphaOne {K : Type} [Field K] (u : Fin (Tag.rank .E6) → Kˣ) :
    rootChar K alphaOne u = u (nd 0) ^ 2 * (u (nd 2))⁻¹ := by
  have h0 : cartanCoord (τ := .E6) alphaOne (nd 0) = 2 := by decide +kernel
  have h1 : cartanCoord (τ := .E6) alphaOne (nd 1) = 0 := by decide +kernel
  have h2 : cartanCoord (τ := .E6) alphaOne (nd 2) = -1 := by decide +kernel
  have h3 : cartanCoord (τ := .E6) alphaOne (nd 3) = 0 := by decide +kernel
  have h4 : cartanCoord (τ := .E6) alphaOne (nd 4) = 0 := by decide +kernel
  have h5 : cartanCoord (τ := .E6) alphaOne (nd 5) = 0 := by decide +kernel
  rw [CFSG.LieType.Chevalley.ExceptionalCover.rootChar_apply]
  change ∏ k : Fin 6, u k ^ cartanCoord (τ := .E6) alphaOne k = _
  rw [Fin.prod_univ_six]
  change u (nd 0) ^ cartanCoord (τ := .E6) alphaOne (nd 0) *
    u (nd 1) ^ cartanCoord (τ := .E6) alphaOne (nd 1) *
    u (nd 2) ^ cartanCoord (τ := .E6) alphaOne (nd 2) *
    u (nd 3) ^ cartanCoord (τ := .E6) alphaOne (nd 3) *
    u (nd 4) ^ cartanCoord (τ := .E6) alphaOne (nd 4) *
    u (nd 5) ^ cartanCoord (τ := .E6) alphaOne (nd 5) = _
  rw [h0, h1, h2, h3, h4, h5]
  simp

theorem rootChar_torusVecD {K : Type} [Field K] (θ : K →+* K) (t : Kˣ) :
    rootChar K alphaOne (torusVecD θ t) = t ^ 2 := by
  rw [rootChar_alphaOne, torusVecD_nd_zero, torusVecD_nd_two]
  simp

theorem rootChar_torusVecD₁ {K : Type} [Field K] (θ : K →+* K) (t : Kˣ) :
    rootChar K alphaOne (torusVecD₁ θ t) = t⁻¹ := by
  have e0 : torusVecD₁ θ t (nd 0) = t⁻¹ := rfl
  have e2 : torusVecD₁ θ t (nd 2) = t⁻¹ := rfl
  rw [rootChar_alphaOne, e0, e2]
  group

section ShortRootGroup

variable {K : Type} [Field K] (θ : K →+* K) (hθ : ∀ c : K, θ (θ c) = c)

theorem xPair_alphaOne_val (c : K) :
    ((xPair θ hθ isRoot_alphaOne rho_alphaOne_ne c : fixedGroup K θ) :
        e6Data_valid.minGroup K) =
      e6Data_valid.xm K alphaOne c *
        e6Data_valid.xm K (rho alphaOne) ((twistSign alphaOne : K) * θ c) :=
  CFSG.LieType.Steinberg.TwistedE6.xPair_val θ hθ isRoot_alphaOne rho_alphaOne_ne c

theorem xPair_alphaOne_add (c d : K) :
    xPair θ hθ isRoot_alphaOne rho_alphaOne_ne (c + d) =
      xPair θ hθ isRoot_alphaOne rho_alphaOne_ne c *
        xPair θ hθ isRoot_alphaOne rho_alphaOne_ne d := by
  refine Subtype.ext ?_
  rw [Subgroup.coe_mul, xPair_alphaOne_val, xPair_alphaOne_val, xPair_alphaOne_val, map_add,
    mul_add, e6Data_valid.xm_add, e6Data_valid.xm_add]
  simp only [mul_assoc]
  rw [← mul_assoc (e6Data_valid.xm K alphaOne d),
    (CFSG.LieType.Steinberg.TwistedE6.commute_xm_rho isRoot_alphaOne rho_alphaOne_ne d
      ((twistSign alphaOne : K) * θ c)).eq, mul_assoc]

theorem xPair_alphaOne_injective :
    Function.Injective (xPair θ hθ isRoot_alphaOne rho_alphaOne_ne) := by
  intro c d h
  have h' := congrArg Subtype.val h
  rw [xPair_alphaOne_val, xPair_alphaOne_val] at h'
  exact (CFSG.LieType.Steinberg.TwistedE6.xm_mul_xm_rho_inj isRoot_alphaOne
    rho_alphaOne_ne h').1

theorem proj_alphaOne : proj alphaOne = Pi.single (nf 3) 1 :=
  (CFSG.LieType.Steinberg.TwistedE6.proj_single (nd 0)).trans
    (congrArg (fun i : Fin (Tag.rank .F4) ↦ (Pi.single i 1 : Fin (Tag.rank .F4) → ℤ))
      (by decide : CFSG.LieType.Steinberg.TwistedE6.orbitMap (nd 0) = nf 3))

theorem xPair_alphaOne_mem (c : K) :
    xPair θ hθ isRoot_alphaOne rho_alphaOne_ne c ∈ twistedRootGroup K θ (Pi.single (nf 3) 1) :=
  (CFSG.LieType.Steinberg.TwistedE6.mem_twistedRootGroup_iff_of_pair θ isRoot_alphaOne
    proj_alphaOne rho_alphaOne_ne _).2 ⟨c, xPair_alphaOne_val θ hθ c⟩

/-- The isomorphism `(K, +) ≃* X e₃`, `c ↦ xPair c`. -/
noncomputable def shortRootEquiv :
    Multiplicative K ≃* twistedRootGroup K θ (Pi.single (nf 3) 1) :=
  MulEquiv.ofBijective
    (MonoidHom.codRestrict
      (MonoidHom.mk' (fun c : Multiplicative K ↦
        xPair θ hθ isRoot_alphaOne rho_alphaOne_ne (Multiplicative.toAdd c))
        (fun _ _ ↦ xPair_alphaOne_add θ hθ _ _))
      _
      (fun _ ↦ xPair_alphaOne_mem θ hθ _))
    ⟨fun _ _ h ↦ Multiplicative.toAdd.injective
        (xPair_alphaOne_injective θ hθ (congrArg Subtype.val h)),
     by
      rintro ⟨g, hg⟩
      obtain ⟨c, hc⟩ :=
        (CFSG.LieType.Steinberg.TwistedE6.mem_twistedRootGroup_iff_of_pair θ isRoot_alphaOne
          proj_alphaOne rho_alphaOne_ne g).1 hg
      refine ⟨Multiplicative.ofAdd c, Subtype.ext (Subtype.ext ?_)⟩
      exact (xPair_alphaOne_val θ hθ c).trans hc.symm⟩

/-- The root group `X e₃` as a λ-root group over `K`, with coordinate `xPair c ↦ c`. -/
noncomputable def shortRootGroup [Finite K] : LambdaRootGroup (fixedGroup K θ) K where
  carrier := twistedRootGroup K θ (Pi.single (nf 3) 1)
  finite := Finite.of_equiv K (Multiplicative.ofAdd.trans (shortRootEquiv θ hθ).toEquiv)
  isNilpotent := Group.nilpotent_of_mulEquiv (shortRootEquiv θ hθ)
  coordinate := (shortRootEquiv θ hθ).symm.toMonoidHom
  ker_coordinate_le_commutator := by
    intro x hx
    have h1 : (shortRootEquiv θ hθ).symm x = 1 := hx
    have : x = 1 := (shortRootEquiv θ hθ).symm.injective (by rw [h1, map_one])
    rw [this]
    exact Subgroup.one_mem _

theorem shortRootGroup_coordinate [Finite K] (c : K)
    (h : xPair θ hθ isRoot_alphaOne rho_alphaOne_ne c ∈
      twistedRootGroup K θ (Pi.single (nf 3) 1)) :
    (shortRootGroup θ hθ).coordinate ⟨xPair θ hθ isRoot_alphaOne rho_alphaOne_ne c, h⟩ =
      Multiplicative.ofAdd c :=
  (MulEquiv.symm_apply_eq _).2 (Subtype.ext rfl)

theorem nonempty_shortRootGroup_action [Finite K] (g : fixedGroup K θ) (s : Kˣ)
    (hg : ∀ c : K, g * xPair θ hθ isRoot_alphaOne rho_alphaOne_ne c * g⁻¹ =
      xPair θ hθ isRoot_alphaOne rho_alphaOne_ne ((s : K) * c)) :
    Nonempty ((shortRootGroup θ hθ).Action g s) := by
  let e := shortRootEquiv θ hθ
  let m : Multiplicative K ≃* Multiplicative K :=
    { toFun := fun c ↦ Multiplicative.ofAdd ((s : K) * Multiplicative.toAdd c)
      invFun := fun c ↦ Multiplicative.ofAdd (((s⁻¹ : Kˣ) : K) * Multiplicative.toAdd c)
      left_inv := fun c ↦ by
        change Multiplicative.ofAdd (((s⁻¹ : Kˣ) : K) * ((s : K) * Multiplicative.toAdd c)) = c
        rw [← mul_assoc, Units.inv_mul, one_mul]
        rfl
      right_inv := fun c ↦ by
        change Multiplicative.ofAdd ((s : K) * (((s⁻¹ : Kˣ) : K) * Multiplicative.toAdd c)) = c
        rw [← mul_assoc, Units.mul_inv, one_mul]
        rfl
      map_mul' := fun a b ↦ by
        change Multiplicative.ofAdd ((s : K) * (Multiplicative.toAdd a + Multiplicative.toAdd b)) =
          Multiplicative.ofAdd ((s : K) * Multiplicative.toAdd a) *
            Multiplicative.ofAdd ((s : K) * Multiplicative.toAdd b)
        rw [mul_add]
        rfl }
  refine ⟨⟨e.symm.trans (m.trans e), ?_, ?_⟩⟩
  · intro x
    obtain ⟨y, rfl⟩ := e.surjective x
    change ((e (m (e.symm (e y))) : twistedRootGroup K θ (Pi.single (nf 3) 1)) :
        fixedGroup K θ) =
      g * ((e y : twistedRootGroup K θ (Pi.single (nf 3) 1)) : fixedGroup K θ) * g⁻¹
    rw [MulEquiv.symm_apply_apply]
    exact (hg (Multiplicative.toAdd y)).symm
  · intro x
    obtain ⟨y, rfl⟩ := e.surjective x
    change Multiplicative.toAdd (e.symm (e (m (e.symm (e y))))) =
      (s : K) * Multiplicative.toAdd (e.symm (e y))
    rw [MulEquiv.symm_apply_apply, MulEquiv.symm_apply_apply]
    rfl

end ShortRootGroup

/-- The short simple root group `X e₃` of `²E₆` is a λ-root group over `K` with
`λ (xPair c) = c`; `torU u` acts on it by `rootChar K α₁ u`. In particular `torU (torusVecD t)`
acts by `t ^ 2` and `torU (torusVecD₁ t)` by `t⁻¹`. -/
theorem exists_shortRootGroup {K : Type} [Field K] [Finite K] (θ : K →+* K)
    (hθ : ∀ c : K, θ (θ c) = c) :
    ∃ R : LambdaRootGroup (fixedGroup K θ) K,
      R.carrier = twistedRootGroup K θ (Pi.single (nf 3) 1) ∧
      (∀ (c : K) (h : xPair θ hθ isRoot_alphaOne rho_alphaOne_ne c ∈ R.carrier),
        R.coordinate ⟨xPair θ hθ isRoot_alphaOne rho_alphaOne_ne c, h⟩ =
          Multiplicative.ofAdd c) ∧
      (∀ (u : Fin (Tag.rank .E6) → Kˣ) (hu : IsSymU θ u),
        Nonempty (R.Action (torU θ u hu) (rootChar K alphaOne u))) ∧
      (∀ (t : Kˣ) (hu : IsSymU θ (torusVecD θ t)), Nonempty (R.Action (torU θ _ hu) (t ^ 2))) ∧
      (∀ (t : Kˣ) (hu : IsSymU θ (torusVecD₁ θ t)), Nonempty (R.Action (torU θ _ hu) t⁻¹)) := by
  have hgen : ∀ (u : Fin (Tag.rank .E6) → Kˣ) (hu : IsSymU θ u),
      Nonempty ((shortRootGroup θ hθ).Action (torU θ u hu) (rootChar K alphaOne u)) :=
    fun u hu ↦ nonempty_shortRootGroup_action θ hθ _ _ fun c ↦
      CFSG.LieType.Steinberg.CentralExt.TwistedE6Closed.torU_conj_xPair θ hθ hu isRoot_alphaOne
        rho_alphaOne_ne c
  refine ⟨shortRootGroup θ hθ, rfl, fun c h ↦ shortRootGroup_coordinate θ hθ c h, hgen, ?_, ?_⟩
  · intro t hu
    have h := hgen _ hu
    rwa [rootChar_torusVecD] at h
  · intro t hu
    have h := hgen _ hu
    rwa [rootChar_torusVecD₁] at h

end CFSGCorollary.TwistedE6
