module

public import CFSG.LieType.Steinberg.CentralExt.TrialityLift

/-!
# The Coxeter element of `³D₄(q)` on the torus

In CFSG's model `twistedGroup σ` of `³D₄(q)`, the Coxeter element `n = n₀ n₁` conjugates the
torus element `tor 1 t` to `tor (nu t)⁻¹ t⁻¹`. The computation takes place in the adjoint
Chevalley group of type `D₄`, where `n₀` and `n₁` are products of the simple Weyl elements and
conjugation by a Weyl element acts on the diagonal torus through the Cartan matrix.

## Main results

* `CFSGCorollary.TrialityD4.nHat_mul_tor_mul_inv`
-/

@[expose] public section

open CFSG.LieType.Steinberg.TwistedD4 (ng nHat)
open CFSG.LieType.Steinberg.CentralExt.TrialityClosed (nu tor)

namespace CFSGCorollary.TrialityD4

section Aux

open CFSG.LieType.Steinberg.TwistedD4 CFSG.LieType.Steinberg.CentralExt.TrialityClosed
open CFSG.LieType.Chevalley (weylElement torusElement)
open CFSG.LieType.Steinberg.Adjoint (torusHom)

variable {K : Type} [Field K]

private theorem prod_univ_d4 (f : Fin d4.rank → Kˣ) :
    ∏ j, f j = f (nd 0) * f (nd 1) * f (nd 2) * f (nd 3) := Fin.prod_univ_four f

private theorem nd_zero_ne_nd_one : (nd 0 : Fin d4.rank) ≠ nd 1 := by decide
private theorem nd_zero_ne_nd_two : (nd 0 : Fin d4.rank) ≠ nd 2 := by decide
private theorem nd_zero_ne_nd_three : (nd 0 : Fin d4.rank) ≠ nd 3 := by decide
private theorem nd_one_ne_nd_zero : (nd 1 : Fin d4.rank) ≠ nd 0 := by decide
private theorem nd_one_ne_nd_two : (nd 1 : Fin d4.rank) ≠ nd 2 := by decide
private theorem nd_one_ne_nd_three : (nd 1 : Fin d4.rank) ≠ nd 3 := by decide
private theorem nd_two_ne_nd_zero : (nd 2 : Fin d4.rank) ≠ nd 0 := by decide
private theorem nd_two_ne_nd_one : (nd 2 : Fin d4.rank) ≠ nd 1 := by decide
private theorem nd_two_ne_nd_three : (nd 2 : Fin d4.rank) ≠ nd 3 := by decide
private theorem nd_three_ne_nd_zero : (nd 3 : Fin d4.rank) ≠ nd 0 := by decide
private theorem nd_three_ne_nd_one : (nd 3 : Fin d4.rank) ≠ nd 1 := by decide
private theorem nd_three_ne_nd_two : (nd 3 : Fin d4.rank) ≠ nd 2 := by decide

private theorem chiHom_nd_zero (v : Fin d4.rank → Kˣ) :
    chiHom (nd 0) v = v (nd 0) ^ (-2 : ℤ) * v (nd 2) := by
  have c0 : d4.cartan (nd 0) (nd 0) = 2 := by decide
  have c1 : d4.cartan (nd 1) (nd 0) = 0 := by decide
  have c2 : d4.cartan (nd 2) (nd 0) = -1 := by decide
  have c3 : d4.cartan (nd 3) (nd 0) = 0 := by decide
  simp only [chiHom_apply, prod_univ_d4, c0, c1, c2, c3]
  simp

private theorem chiHom_nd_one (v : Fin d4.rank → Kˣ) :
    chiHom (nd 1) v = v (nd 1) ^ (-2 : ℤ) * v (nd 2) := by
  have c0 : d4.cartan (nd 0) (nd 1) = 0 := by decide
  have c1 : d4.cartan (nd 1) (nd 1) = 2 := by decide
  have c2 : d4.cartan (nd 2) (nd 1) = -1 := by decide
  have c3 : d4.cartan (nd 3) (nd 1) = 0 := by decide
  simp only [chiHom_apply, prod_univ_d4, c0, c1, c2, c3]
  simp

private theorem chiHom_nd_two (v : Fin d4.rank → Kˣ) :
    chiHom (nd 2) v = v (nd 0) * v (nd 1) * v (nd 2) ^ (-2 : ℤ) * v (nd 3) := by
  have c0 : d4.cartan (nd 0) (nd 2) = -1 := by decide
  have c1 : d4.cartan (nd 1) (nd 2) = -1 := by decide
  have c2 : d4.cartan (nd 2) (nd 2) = 2 := by decide
  have c3 : d4.cartan (nd 3) (nd 2) = -1 := by decide
  simp only [chiHom_apply, prod_univ_d4, c0, c1, c2, c3]
  simp

private theorem chiHom_nd_three (v : Fin d4.rank → Kˣ) :
    chiHom (nd 3) v = v (nd 2) * v (nd 3) ^ (-2 : ℤ) := by
  have c0 : d4.cartan (nd 0) (nd 3) = 0 := by decide
  have c1 : d4.cartan (nd 1) (nd 3) = 0 := by decide
  have c2 : d4.cartan (nd 2) (nd 3) = -1 := by decide
  have c3 : d4.cartan (nd 3) (nd 3) = 2 := by decide
  simp only [chiHom_apply, prod_univ_d4, c0, c1, c2, c3]
  simp

private theorem nHatE_mul_torE_mul_inv (σ : K →+* K) (t : Kˣ) :
    nHatE K (ng 0) * nHatE K (ng 1) * torE σ 1 t * (nHatE K (ng 0) * nHatE K (ng 1))⁻¹ =
      torE σ (normU σ t)⁻¹ t⁻¹ := by
  obtain ⟨u, hu⟩ : ∃ u : Fin d4.rank → Kˣ, u = Pi.mulSingle (nd 0) t *
      Pi.mulSingle (nd 1) (Units.map σ.toMonoidHom t) *
      Pi.mulSingle (nd 3) (Units.map σ.toMonoidHom (Units.map σ.toMonoidHom t)) := ⟨_, rfl⟩
  have h1 : torusElement d4 K (nd 2) (1 : Kˣ) = 1 := (torusHom (τ := d4) K (nd 2)).map_one
  have hT : torE σ 1 t = torusT K u := by
    rw [torE, h1, one_mul, hShortHom_apply, hu]
    simp only [map_mul, torusT_mulSingle]
  have hu0 : u (nd 0) = t := by
    rw [hu]
    simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_zero_ne_nd_one,
      Pi.mulSingle_eq_of_ne nd_zero_ne_nd_three, mul_one]
  have hu1' : u (nd 1) = Units.map σ.toMonoidHom t := by
    rw [hu]
    simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_one_ne_nd_zero,
      Pi.mulSingle_eq_of_ne nd_one_ne_nd_three, mul_one, one_mul]
  have hu2 : u (nd 2) = 1 := by
    rw [hu]
    simp only [Pi.mul_apply, Pi.mulSingle_eq_of_ne nd_two_ne_nd_zero,
      Pi.mulSingle_eq_of_ne nd_two_ne_nd_one, Pi.mulSingle_eq_of_ne nd_two_ne_nd_three, mul_one]
  have hu3 : u (nd 3) = Units.map σ.toMonoidHom (Units.map σ.toMonoidHom t) := by
    rw [hu]
    simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_three_ne_nd_zero,
      Pi.mulSingle_eq_of_ne nd_three_ne_nd_one, mul_one, one_mul]
  obtain ⟨u1, hu1⟩ : ∃ u1 : Fin d4.rank → Kˣ, u1 = u * Pi.mulSingle (nd 3) (chiHom (nd 3) u) *
      Pi.mulSingle (nd 1) (chiHom (nd 1) u) * Pi.mulSingle (nd 0) (chiHom (nd 0) u) := ⟨_, rfl⟩
  have hn1 : weylElement d4 K (nd 0) * weylElement d4 K (nd 1) * weylElement d4 K (nd 3) *
      torusT K u * (weylElement d4 K (nd 0) * weylElement d4 K (nd 1) *
        weylElement d4 K (nd 3))⁻¹ = torusT K u1 := by
    calc _ = weylElement d4 K (nd 0) * (weylElement d4 K (nd 1) *
          (weylElement d4 K (nd 3) * torusT K u * (weylElement d4 K (nd 3))⁻¹) *
            (weylElement d4 K (nd 1))⁻¹) * (weylElement d4 K (nd 0))⁻¹ := by group
      _ = _ := by
          rw [hu1, weylElement_conj_torusT, weylElement_conj_torusT, weylElement_conj_torusT,
            chiHom_mul_mulSingle_of_eq_zero (c := nd 1) (a := nd 3) (by decide),
            chiHom_mul_mulSingle_of_eq_zero (c := nd 0) (a := nd 1) (by decide),
            chiHom_mul_mulSingle_of_eq_zero (c := nd 0) (a := nd 3) (by decide)]
  have hv0 : u1 (nd 0) = t⁻¹ := by
    rw [hu1]
    simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_zero_ne_nd_one,
      Pi.mulSingle_eq_of_ne nd_zero_ne_nd_three, hu0, hu2, chiHom_nd_zero, mul_one]
    try group
  have hv1 : u1 (nd 1) = (Units.map σ.toMonoidHom t)⁻¹ := by
    rw [hu1]
    simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_one_ne_nd_zero,
      Pi.mulSingle_eq_of_ne nd_one_ne_nd_three, hu1', hu2, chiHom_nd_one, mul_one]
    try group
  have hv2 : u1 (nd 2) = 1 := by
    rw [hu1]
    simp only [Pi.mul_apply, Pi.mulSingle_eq_of_ne nd_two_ne_nd_zero,
      Pi.mulSingle_eq_of_ne nd_two_ne_nd_one, Pi.mulSingle_eq_of_ne nd_two_ne_nd_three, hu2,
      mul_one]
  have hv3 : u1 (nd 3) = (Units.map σ.toMonoidHom (Units.map σ.toMonoidHom t))⁻¹ := by
    rw [hu1]
    simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_three_ne_nd_zero,
      Pi.mulSingle_eq_of_ne nd_three_ne_nd_one, hu2, hu3, chiHom_nd_three, mul_one, one_mul]
    try group
  have hc2 : chiHom (nd 2) u1 = (normU σ t)⁻¹ := by
    rw [chiHom_nd_two, hv0, hv1, hv2, hv3]
    simp only [normU, mul_inv, one_zpow, mul_one]
  have hv : u1 * Pi.mulSingle (nd 2) (normU σ t)⁻¹ =
      Pi.mulSingle (nd 2) (normU σ t)⁻¹ * Pi.mulSingle (nd 0) t⁻¹ *
        Pi.mulSingle (nd 1) (Units.map σ.toMonoidHom t⁻¹) *
          Pi.mulSingle (nd 3) (Units.map σ.toMonoidHom (Units.map σ.toMonoidHom t⁻¹)) := by
    funext a
    match a with
    | ⟨0, _⟩ =>
      simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_zero_ne_nd_one,
        Pi.mulSingle_eq_of_ne nd_zero_ne_nd_two, Pi.mulSingle_eq_of_ne nd_zero_ne_nd_three, hv0,
        map_inv, mul_one, one_mul]
    | ⟨1, _⟩ =>
      simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_one_ne_nd_zero,
        Pi.mulSingle_eq_of_ne nd_one_ne_nd_two, Pi.mulSingle_eq_of_ne nd_one_ne_nd_three, hv1,
        map_inv, mul_one, one_mul]
    | ⟨2, _⟩ =>
      simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_two_ne_nd_zero,
        Pi.mulSingle_eq_of_ne nd_two_ne_nd_one, Pi.mulSingle_eq_of_ne nd_two_ne_nd_three, hv2,
        map_inv, mul_one, one_mul]
    | ⟨3, _⟩ =>
      simp only [Pi.mul_apply, Pi.mulSingle_eq_same, Pi.mulSingle_eq_of_ne nd_three_ne_nd_zero,
        Pi.mulSingle_eq_of_ne nd_three_ne_nd_one, Pi.mulSingle_eq_of_ne nd_three_ne_nd_two, hv3,
        map_inv, mul_one, one_mul]
  have hfinal : torusT K (u1 * Pi.mulSingle (nd 2) (chiHom (nd 2) u1)) =
      torE σ (normU σ t)⁻¹ t⁻¹ := by
    rw [hc2, hv, torE, hShortHom_apply]
    simp only [map_mul, torusT_mulSingle, mul_assoc]
  have hn2 : weylElement d4 K (nd 2) * torusT K u1 * (weylElement d4 K (nd 2))⁻¹ =
      torusT K (u1 * Pi.mulSingle (nd 2) (chiHom (nd 2) u1)) := weylElement_conj_torusT _ _
  rw [← hfinal, ← hn2, ← hn1, hT, nHatE_zero, nHatE_one]
  group

end Aux

/-- The Coxeter element `n = n₀ n₁` conjugates the ³D₄ torus element `tor 1 t` to
`tor (nu t)⁻¹ t⁻¹`. -/
theorem nHat_mul_tor_mul_inv {K : Type} [Field K] {σ : K →+* K}
    (hσ : ∀ c : K, σ (σ (σ c)) = c) (t : Kˣ) :
    nHat σ (ng 0) * nHat σ (ng 1) * tor hσ 1 t * (nHat σ (ng 0) * nHat σ (ng 1))⁻¹ =
      tor hσ (nu hσ t)⁻¹ t⁻¹ :=
  Subtype.ext (nHatE_mul_torE_mul_inv σ t)

end CFSGCorollary.TrialityD4
