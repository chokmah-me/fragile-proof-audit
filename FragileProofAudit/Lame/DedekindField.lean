/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import FragileProofAudit.Lame.IdealPrincipal
import FragileProofAudit.Lame.DedekindScratch
import Mathlib.Algebra.Polynomial.Degree.SmallDegree
import Mathlib.Algebra.Polynomial.SpecificDegree
import Mathlib.FieldTheory.Minpoly.IsIntegrallyClosed
import Mathlib.FieldTheory.Separable
import Mathlib.RingTheory.AdjoinRoot
import Mathlib.RingTheory.DedekindDomain.IntegralClosure
import Mathlib.RingTheory.PowerBasis
import Mathlib.Tactic.ComputeDegree
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Lamé 1847 — `IsDedekindDomain OKNeg23` via integral closure

Construct `L23 = ℚ(√−23)` as `AdjoinRoot (X² − X + 6)`, prove that
`OKNeg23 = ℤ[θ]` is the integral closure of `ℤ` in `L23` (using the elementary
discriminant lemma `disc_neg23_forces_integers`), and obtain
`IsDedekindDomain OKNeg23` from mathlib's
`IsIntegralClosure.isDedekindDomain`.
-/

open Polynomial FragileProofAudit.Lame.IdealPrincipal

noncomputable section

namespace FragileProofAudit.Lame.DedekindField

/-- `f = X² − X + 6`, minimal polynomial of `θ = (1+√−23)/2`. -/
def f23 : ℚ[X] := X ^ 2 - X + C 6

theorem f23_natDegree : f23.natDegree = 2 := by
  unfold f23
  compute_degree!

theorem f23_monic : f23.Monic := by
  unfold f23
  monicity!

theorem f23_ne_zero : f23 ≠ 0 := f23_monic.ne_zero

theorem f23_no_root (x : ℚ) : ¬ f23.IsRoot x := by
  unfold f23 Polynomial.IsRoot
  simp only [eval_add, eval_sub, eval_pow, eval_X, eval_C]
  intro h
  nlinarith [sq_nonneg (2 * x - 1)]

theorem f23_irreducible : Irreducible f23 := by
  apply Polynomial.irreducible_of_degree_le_three_of_not_isRoot
  · rw [Finset.mem_Icc, f23_natDegree]; exact ⟨by norm_num, by norm_num⟩
  · exact f23_no_root

instance f23_fact : Fact (Irreducible f23) := ⟨f23_irreducible⟩

/-- `L = ℚ(√−23)` as a concrete field. -/
abbrev L23 : Type := AdjoinRoot f23

noncomputable instance : Field L23 := AdjoinRoot.instField (f := f23)

/-- The distinguished root, standing for `θ`. -/
abbrev rootL23 : L23 := AdjoinRoot.root f23

theorem rootL23_sq : rootL23 * rootL23 = (-6 : ℤ) • (1 : L23) + (1 : ℤ) • rootL23 := by
  have h := AdjoinRoot.eval₂_root f23
  have heval : eval₂ (AdjoinRoot.of f23) (AdjoinRoot.root f23) f23
      = (AdjoinRoot.root f23) ^ 2 - AdjoinRoot.root f23 + AdjoinRoot.of f23 6 := by
    change eval₂ (AdjoinRoot.of f23) (AdjoinRoot.root f23) (X ^ 2 - X + C 6)
        = (AdjoinRoot.root f23) ^ 2 - AdjoinRoot.root f23 + AdjoinRoot.of f23 6
    simp [eval₂_add, eval₂_sub, eval₂_pow, eval₂_X, eval₂_C]
  rw [heval] at h
  have h6 : AdjoinRoot.of f23 (6 : ℚ) = (6 : L23) := by
    simp [AdjoinRoot.of]
  rw [h6] at h
  simp only [zsmul_eq_mul]
  push_cast
  linear_combination h

theorem rootL23_mul_eq_sub : rootL23 * rootL23 = rootL23 - 6 := by
  have h := rootL23_sq
  simp only [zsmul_eq_mul] at h
  push_cast at h
  linear_combination h

/-- The algebra map `OKNeg23 →ₐ[ℤ] L23` sending `θ ↦ rootL23`. -/
noncomputable def algMap23 : OKNeg23 →ₐ[ℤ] L23 :=
  QuadraticAlgebra.lift ⟨rootL23, rootL23_sq⟩

theorem algMap23_apply (z : OKNeg23) :
    algMap23 z = (z.re : L23) + (z.im : L23) * rootL23 := by
  unfold algMap23
  simp [QuadraticAlgebra.lift, zsmul_eq_mul]

theorem f23_aeval_root : Polynomial.aeval rootL23 f23 = 0 := by
  rw [Polynomial.aeval_def]
  exact AdjoinRoot.eval₂_root f23

theorem algMap23_injective : Function.Injective algMap23 := by
  have inj_rat : Function.Injective (algebraMap ℚ L23) :=
    FaithfulSMul.algebraMap_injective ℚ L23
  have inj_int : Function.Injective (algebraMap ℤ L23) := by
    have hcomp : algebraMap ℤ L23 = (algebraMap ℚ L23).comp (algebraMap ℤ ℚ) := by
      ext n; simp [IsScalarTower.algebraMap_apply ℤ ℚ L23]
    rw [hcomp]
    exact inj_rat.comp (RingHom.injective_int (algebraMap ℤ ℚ))
  intro z w hzw
  rw [algMap23_apply, algMap23_apply] at hzw
  by_cases him : z.im = w.im
  · have hre : (z.re : L23) = (w.re : L23) := by
      rw [him] at hzw; exact add_right_cancel hzw
    have hreZ : z.re = w.re := inj_int hre
    exact QuadraticAlgebra.ext hreZ him
  · exfalso
    set q0 : ℚ := ((w.re - z.re : ℤ) : ℚ) / ((z.im - w.im : ℤ) : ℚ) with hq0_def
    have hden_ne : ((z.im - w.im : ℤ) : ℚ) ≠ 0 := by
      exact_mod_cast sub_ne_zero.mpr him
    have hkey : algebraMap ℚ L23 q0 = rootL23 := by
      have hD : algebraMap ℚ L23 ((z.im - w.im : ℤ) : ℚ) ≠ 0 := by
        intro h0; exact hden_ne (inj_rat (by simpa using h0))
      rw [hq0_def, map_div₀]
      rw [div_eq_iff hD]
      have expand : (algebraMap ℚ L23) ((w.re - z.re : ℤ) : ℚ)
          = rootL23 * (algebraMap ℚ L23) ((z.im - w.im : ℤ) : ℚ) := by
        have h1 : algebraMap ℚ L23 ((w.re - z.re : ℤ) : ℚ) = ((w.re - z.re : ℤ) : L23) :=
          map_intCast (algebraMap ℚ L23) (w.re - z.re)
        have h2 : algebraMap ℚ L23 ((z.im - w.im : ℤ) : ℚ) = ((z.im - w.im : ℤ) : L23) :=
          map_intCast (algebraMap ℚ L23) (z.im - w.im)
        rw [h1, h2]
        push_cast
        linear_combination -hzw
      rw [expand]
    have hq0_root : f23.eval q0 = 0 := by
      have h1 : Polynomial.aeval (algebraMap ℚ L23 q0) f23 = 0 := by
        rw [hkey]; exact f23_aeval_root
      have h2 : Polynomial.aeval (algebraMap ℚ L23 q0) f23
          = algebraMap ℚ L23 (Polynomial.aeval q0 f23) := by
        rw [Polynomial.aeval_algebraMap_apply]
      rw [h2] at h1
      have h3 : Polynomial.aeval q0 f23 = 0 := inj_rat (by simpa using h1)
      simpa [Polynomial.aeval_def, Polynomial.eval₂_eq_eval_map] using h3
    exact f23_no_root q0 hq0_root

/-- `OKNeg23` acts as an algebra on `L23` via `algMap23`. -/
noncomputable instance OKNeg23_algebra_L23 : Algebra OKNeg23 L23 :=
  algMap23.toRingHom.toAlgebra

theorem algebraMap_OKNeg23_L23_apply (z : OKNeg23) :
    algebraMap OKNeg23 L23 z = algMap23 z := rfl

instance OKNeg23_scalarTower : IsScalarTower ℤ OKNeg23 L23 := by
  apply IsScalarTower.of_algebraMap_eq
  intro n
  rw [algebraMap_OKNeg23_L23_apply]
  exact (algMap23.commutes n).symm

instance : IsDomain OKNeg23 :=
  algMap23_injective.isDomain _

/-- Power basis `1, rootL23` for `L23 / ℚ`. -/
noncomputable def pb23 : PowerBasis ℚ L23 :=
  AdjoinRoot.powerBasis' f23_monic

theorem pb23_dim : pb23.dim = 2 := by
  simp [pb23, AdjoinRoot.powerBasis'_dim, f23_natDegree]

theorem pb23_gen : pb23.gen = rootL23 := rfl

instance : Module.Finite ℚ L23 := pb23.finite

instance : FiniteDimensional ℚ L23 := inferInstance

instance : Algebra.IsIntegral ℚ L23 :=
  Algebra.IsIntegral.of_finite ℚ L23

/-- Every element of `L23` is `p + q · rootL23` for rationals `p, q`. -/
theorem exists_coords (y : L23) :
    ∃ p q : ℚ, y = algebraMap ℚ L23 p + algebraMap ℚ L23 q * rootL23 := by
  obtain ⟨f, hfdeg, rfl⟩ := pb23.exists_eq_aeval y
  have hfdeg' : f.natDegree ≤ 1 := (Nat.lt_succ_iff).mp (by simpa [pb23_dim] using hfdeg)
  obtain ⟨q, p, rfl⟩ := exists_eq_X_add_C_of_natDegree_le_one hfdeg'
  refine ⟨p, q, ?_⟩
  simp [pb23_gen, aeval_add, aeval_mul, aeval_C, aeval_X]
  ring

/-- Explicit monic quadratic killing `p + q · rootL23`. -/
def charPolyCoords (p q : ℚ) : ℚ[X] :=
  X ^ 2 - C (2 * p + q) * X + C (p ^ 2 + p * q + 6 * q ^ 2)

theorem charPolyCoords_monic (p q : ℚ) : (charPolyCoords p q).Monic := by
  unfold charPolyCoords
  monicity!

theorem charPolyCoords_natDegree (p q : ℚ) : (charPolyCoords p q).natDegree = 2 := by
  unfold charPolyCoords
  compute_degree!

theorem charPolyCoords_coeff_one (p q : ℚ) :
    (charPolyCoords p q).coeff 1 = -(2 * p + q) := by
  unfold charPolyCoords
  rw [coeff_add, coeff_sub, coeff_X_pow, coeff_C_mul_X, coeff_C]
  simp

theorem charPolyCoords_coeff_zero (p q : ℚ) :
    (charPolyCoords p q).coeff 0 = p ^ 2 + p * q + 6 * q ^ 2 := by
  unfold charPolyCoords
  rw [coeff_add, coeff_sub, coeff_X_pow, coeff_C_mul_X, coeff_C]
  simp

theorem charPolyCoords_aeval (p q : ℚ) :
    Polynomial.aeval (algebraMap ℚ L23 p + algebraMap ℚ L23 q * rootL23)
      (charPolyCoords p q) = 0 := by
  set P := algebraMap ℚ L23 p
  set Q := algebraMap ℚ L23 q
  set θ := rootL23
  set x := P + Q * θ
  have hθ : θ * θ = θ - 6 := rootL23_mul_eq_sub
  have hlin : algebraMap ℚ L23 (2 * p + q) = 2 * P + Q := by
    rw [map_add, map_mul, map_ofNat]
  have hconst :
      algebraMap ℚ L23 (p ^ 2 + p * q + 6 * q ^ 2) = P ^ 2 + P * Q + 6 * Q ^ 2 := by
    simp only [P, Q]
    push_cast
    simp
  have hx2 : x ^ 2 = P ^ 2 + 2 * P * Q * θ + Q ^ 2 * (θ - 6) := by
    dsimp [x]
    have : (P + Q * θ) ^ 2 = P ^ 2 + 2 * P * Q * θ + Q ^ 2 * (θ * θ) := by ring
    simpa [hθ] using this
  -- `x` is defeq to the aeval argument, so the goal is already `(aeval x) (...) = 0`.
  -- Use `rw` (not `simp`) so `C (2p+q)` is not split by `map_add`.
  rw [charPolyCoords, map_add, map_sub, map_mul, aeval_X_pow, aeval_C, aeval_X, aeval_C]
  rw [hlin, hconst, hx2]
  dsimp [x]
  ring

theorem charPolyCoords_no_root (p q : ℚ) (hq : q ≠ 0) (r : ℚ) :
    ¬ (charPolyCoords p q).IsRoot r := by
  intro hr
  have hr' : r ^ 2 - (2 * p + q) * r + (p ^ 2 + p * q + 6 * q ^ 2) = 0 := by
    simpa [charPolyCoords, IsRoot, eval_add, eval_sub, eval_mul, eval_pow, eval_X, eval_C]
      using hr
  set s : ℚ := (r - p) / q
  have hclear :
      q ^ 2 * (s ^ 2 - s + 6)
        = r ^ 2 - (2 * p + q) * r + (p ^ 2 + p * q + 6 * q ^ 2) := by
    dsimp [s]
    field_simp
    ring
  have hs0 : s ^ 2 - s + 6 = 0 := by
    have : q ^ 2 * (s ^ 2 - s + 6) = 0 := by rw [hclear, hr']
    exact (mul_eq_zero.mp this).resolve_left (pow_ne_zero 2 hq)
  exact f23_no_root s (by unfold f23 IsRoot; simpa using hs0)

theorem charPolyCoords_irreducible (p q : ℚ) (hq : q ≠ 0) :
    Irreducible (charPolyCoords p q) := by
  apply Polynomial.irreducible_of_degree_le_three_of_not_isRoot
  · rw [Finset.mem_Icc, charPolyCoords_natDegree]; exact ⟨by norm_num, by norm_num⟩
  · exact charPolyCoords_no_root p q hq

theorem coords_unique {p q p' q' : ℚ}
    (h : algebraMap ℚ L23 p + algebraMap ℚ L23 q * rootL23
        = algebraMap ℚ L23 p' + algebraMap ℚ L23 q' * rootL23) :
    p = p' ∧ q = q' := by
  have inj_rat : Function.Injective (algebraMap ℚ L23) :=
    FaithfulSMul.algebraMap_injective ℚ L23
  by_cases hq : q = q'
  · subst hq
    have : algebraMap ℚ L23 p = algebraMap ℚ L23 p' := add_right_cancel h
    exact ⟨inj_rat this, rfl⟩
  · exfalso
    set s : ℚ := (p' - p) / (q - q') with hs
    have hden : (q - q' : ℚ) ≠ 0 := sub_ne_zero.mpr hq
    have hkey : algebraMap ℚ L23 s = rootL23 := by
      have hD : algebraMap ℚ L23 (q - q') ≠ 0 := by
        intro h0; exact hden (inj_rat (by simpa using h0))
      rw [hs, map_div₀, div_eq_iff hD]
      simp only [map_sub]
      linear_combination -h
    have hs_root : f23.eval s = 0 := by
      have h1 : Polynomial.aeval (algebraMap ℚ L23 s) f23 = 0 := by
        rw [hkey]; exact f23_aeval_root
      have h2 : Polynomial.aeval (algebraMap ℚ L23 s) f23
          = algebraMap ℚ L23 (Polynomial.aeval s f23) := by
        rw [Polynomial.aeval_algebraMap_apply]
      rw [h2] at h1
      have h3 : Polynomial.aeval s f23 = 0 := inj_rat (by simpa using h1)
      simpa [Polynomial.aeval_def, Polynomial.eval₂_eq_eval_map] using h3
    exact f23_no_root s hs_root

/-- **Hard direction:** integral over `ℤ` ⇒ lies in the image of `OKNeg23`. -/
theorem isIntegral_iff_mem_range {x : L23} :
    IsIntegral ℤ x ↔ ∃ y : OKNeg23, algebraMap OKNeg23 L23 y = x := by
  constructor
  · intro hx
    obtain ⟨p, q, hpq⟩ := exists_coords x
    by_cases hq0 : q = 0
    · subst hq0
      simp only [map_zero, zero_mul, add_zero] at hpq
      have hxp : IsIntegral ℤ (algebraMap ℚ L23 p) := hpq ▸ hx
      have hp_int : IsIntegral ℤ p :=
        IsIntegral.tower_bot (FaithfulSMul.algebraMap_injective ℚ L23) hxp
      obtain ⟨a, ha⟩ := IsIntegrallyClosed.isIntegral_iff.mp hp_int
      refine ⟨⟨a, 0⟩, ?_⟩
      simp [algebraMap_OKNeg23_L23_apply, algMap23_apply, hpq, ← ha]
    · have hgae : Polynomial.aeval x (charPolyCoords p q) = 0 := by
        simpa [hpq] using charPolyCoords_aeval p q
      have hmin : minpoly ℚ x = charPolyCoords p q :=
        (minpoly.eq_of_irreducible_of_monic
          (charPolyCoords_irreducible p q hq0) hgae (charPolyCoords_monic p q)).symm
      have hfrac : minpoly ℚ x = (minpoly ℤ x).map (algebraMap ℤ ℚ) :=
        minpoly.isIntegrallyClosed_eq_field_fractions' (R := ℤ) (K := ℚ) hx
      have hcoeff1 : (charPolyCoords p q).coeff 1
          = algebraMap ℤ ℚ ((minpoly ℤ x).coeff 1) := by
        rw [← hmin, hfrac, coeff_map]
      have hcoeff0 : (charPolyCoords p q).coeff 0
          = algebraMap ℤ ℚ ((minpoly ℤ x).coeff 0) := by
        rw [← hmin, hfrac, coeff_map]
      set u : ℤ := -((minpoly ℤ x).coeff 1)
      set t : ℤ := (minpoly ℤ x).coeff 0
      have hu : (u : ℚ) = 2 * p + q := by
        have h := hcoeff1
        rw [charPolyCoords_coeff_one] at h
        -- h : -(2p+q) = algebraMap ℤ ℚ (coeff 1) = ↑(coeff 1)
        simp only [u, Int.cast_neg]
        linarith [show
          (algebraMap ℤ ℚ) ((minpoly ℤ x).coeff 1) = ((minpoly ℤ x).coeff 1 : ℚ) from rfl]
      have ht : (t : ℚ) = p ^ 2 + p * q + 6 * q ^ 2 := by
        have h := hcoeff0
        rw [charPolyCoords_coeff_zero] at h
        simpa [t, show (algebraMap ℤ ℚ) t = (t : ℚ) from rfl] using h.symm
      obtain ⟨a, b, ha, hb⟩ := disc_neg23_forces_integers p q u t hu ht
      refine ⟨⟨a, b⟩, ?_⟩
      simp only [algebraMap_OKNeg23_L23_apply, algMap23_apply]
      -- `↑a : L23` = algebraMap ℚ L23 (↑a : ℚ) via `map_intCast`
      have haL : (a : L23) = algebraMap ℚ L23 p := by
        rw [← ha]
        exact (map_intCast (algebraMap ℚ L23) a).symm
      have hbL : (b : L23) = algebraMap ℚ L23 q := by
        rw [← hb]
        exact (map_intCast (algebraMap ℚ L23) b).symm
      rw [haL, hbL, hpq]
  · rintro ⟨y, rfl⟩
    exact (Algebra.IsIntegral.isIntegral (R := ℤ) y).map algMap23

instance : IsIntegralClosure OKNeg23 ℤ L23 where
  algebraMap_injective := by
    intro z w h
    exact algMap23_injective (by simpa [algebraMap_OKNeg23_L23_apply] using h)
  isIntegral_iff := isIntegral_iff_mem_range

/-- Unconditional Dedekind-domain instance on the coordinate model. -/
instance : IsDedekindDomain OKNeg23 :=
  IsIntegralClosure.isDedekindDomain ℤ ℚ L23 OKNeg23

end FragileProofAudit.Lame.DedekindField

end
