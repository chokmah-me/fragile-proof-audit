module

public import CFSG.LieType.Steinberg.CentralExt.TrialityLift
public import CFSGCorollary.LieType.LambdaRootGroup.Basic
import CFSGCorollary.LieType.Twisted.Basic
import CFSGCorollary.LieType.Twisted.TwistedD.RootGroup

/-!
# Root groups of the triality group `³D₄(q)`

We work in CFSG's model `twistedGroup σ` of `³D₄(q)`, the fixed points of the triality twist
`σ` (with `σ c = c ^ q`) acting on the adjoint Chevalley group of type `D₄` over a field `K`
with `q ^ 3` elements. Its root groups `twistedRootGroup σ β` are indexed by the roots `β` of
`G₂`, with simple roots `![1, 0]` (long) and `![0, 1]` (short).

* The commutator of the short root elements `xS c` and `xS 1` for the roots `![0, 1]` and
  `![1, 2]` is a long root element for `![1, 3]` with parameter `± Tr(c)`; since the trace is
  onto the fixed field, a subgroup containing `X ![0, 1]` and `X ![1, 2]` contains `X ![1, 3]`.
* The short simple root group `X ![0, 1]` is a λ-root group over `K` on which the torus
  elements `tor s t` act by `s⁻¹ t²`.
* Conjugating by powers of the Coxeter element `n = n₀ n₁` moves `X ![0, 1]` and `X ![1, 3]`
  to the root groups of `± ![0, 1]`, `![1, 2]` and `± ![1, 0]`.
* For a generator `t` of `Kˣ`, `t ^ 2` and `normU σ t * t⁻¹ ^ 2` are good scalars.

## Main results

* `CFSGCorollary.TrialityD4.exists_shortRootGroup`
* `CFSGCorollary.TrialityD4.rootGroup_one_three_le`
* `CFSGCorollary.TrialityD4.rootGroup_neg_short_le`
* `CFSGCorollary.TrialityD4.rootGroup_long_simple_le`
* `CFSGCorollary.TrialityD4.isGoodScalar_sq_and_normU_mul_inv_sq`
-/

@[expose] public section

open scoped commutatorElement
open CFSG.LieType.Steinberg.TwistedD4
  (d4 rho d4Root isRoot_d4Root xOrbit twistSign twistSign_eq_one_or twistSign_of_rho_eq twistC_xPar
    twistedGroup twistedRootGroup fixedUnits fixedField ng hHat nHat proj)
open CFSG.LieType.Steinberg.CentralExt.TrialityClosed
  (xL xS tor d01 d12 d13 isRoot_d01 rho_d01 isRoot_d12 rho_d12 isRoot_d13 rho_d13 proj_d01
    proj_d12 proj_d13 r01 r12 r13 not_isRoot_of_cert xL_val xS_val xS_add xS_eq_one mem_iff_xS
    mem_iff_xL normU)
open CFSG.LieType.Steinberg.Adjoint (xPar xPar_add xPar_injective xPar_of_isRoot)
open CFSG.LieType.Chevalley (rootOperatorFamily twistC)
open CFSG.LieType.Chevalley.RootOps (repCheck allValid d4_allValid rootPos_eq)
open CFSG.Blueprint.Chevalley (Tag reflect)

namespace CFSGCorollary.TrialityD4

local notation "𝕩" => xPar (rootOperatorFamily d4)

/-! ### The commutator of two short root elements -/

theorem commutatorElement_mul_left_of_commute {G : Type*} [Group G] {a b y : G}
    (h : Commute a ⁅b, y⁆) : ⁅a * b, y⁆ = ⁅b, y⁆ * ⁅a, y⁆ := by
  have e : ⁅a * b, y⁆ = a * ⁅b, y⁆ * a⁻¹ * ⁅a, y⁆ := by
    simp only [commutatorElement_def]
    group
  rw [e, h.eq]
  group

theorem commutatorElement_mul_right_of_commute {G : Type*} [Group G] {x y z : G}
    (h : Commute y ⁅x, z⁆) : ⁅x, y * z⁆ = ⁅x, y⁆ * ⁅x, z⁆ := by
  have e : ⁅x, y * z⁆ = ⁅x, y⁆ * (y * ⁅x, z⁆ * y⁻¹) := by
    simp only [commutatorElement_def]
    group
  rw [e, h.eq, mul_inv_cancel_right]

theorem commutator_mul_mul_mul_mul {G : Type*} [Group G] {x0 x1 x2 y0 y1 y2 z0 z1 z2 : G}
    (h00 : Commute x0 y0) (h02 : Commute x0 y2) (h10 : Commute x1 y0) (h11 : Commute x1 y1)
    (h21 : Commute x2 y1) (h22 : Commute x2 y2)
    (c01 : ⁅x0, y1⁆ = z0) (c12 : ⁅x1, y2⁆ = z1) (c20 : ⁅x2, y0⁆ = z2)
    (hz : ∀ w, (w = x0 ∨ w = x1 ∨ w = x2 ∨ w = y0 ∨ w = y1 ∨ w = y2) →
      Commute z0 w ∧ Commute z1 w ∧ Commute z2 w) :
    ⁅x0 * x1 * x2, y0 * y1 * y2⁆ = z2 * (z1 * z0) := by
  have hx0 := hz x0 (by simp)
  have hx1 := hz x1 (by simp)
  have hy0 := hz y0 (by simp)
  have hy1 := hz y1 (by simp)
  have k0 : ⁅x0, y0 * y1 * y2⁆ = z0 := by
    have e0 : ⁅x0, y0⁆ = 1 := commutatorElement_eq_one_iff_commute.2 h00
    have e2 : ⁅x0, y2⁆ = 1 := commutatorElement_eq_one_iff_commute.2 h02
    rw [commutatorElement_mul_right_of_commute (by rw [e2]; exact Commute.one_right _),
      commutatorElement_mul_right_of_commute (by rw [c01]; exact hy0.1.symm), e0, c01, e2]
    simp
  have k1 : ⁅x1, y0 * y1 * y2⁆ = z1 := by
    have e0 : ⁅x1, y0⁆ = 1 := commutatorElement_eq_one_iff_commute.2 h10
    have e1 : ⁅x1, y1⁆ = 1 := commutatorElement_eq_one_iff_commute.2 h11
    rw [commutatorElement_mul_right_of_commute
        (by rw [c12]; exact hy0.2.1.symm.mul_left hy1.2.1.symm),
      commutatorElement_mul_right_of_commute (by rw [e1]; exact Commute.one_right _), e0, e1, c12]
    simp
  have k2 : ⁅x2, y0 * y1 * y2⁆ = z2 := by
    have e1 : ⁅x2, y1⁆ = 1 := commutatorElement_eq_one_iff_commute.2 h21
    have e2 : ⁅x2, y2⁆ = 1 := commutatorElement_eq_one_iff_commute.2 h22
    rw [commutatorElement_mul_right_of_commute (by rw [e2]; exact Commute.one_right _),
      commutatorElement_mul_right_of_commute (by rw [e1]; exact Commute.one_right _), c20, e1, e2]
    simp
  rw [commutatorElement_mul_left_of_commute
      (by rw [k2]; exact hx0.2.2.symm.mul_left hx1.2.2.symm),
    commutatorElement_mul_left_of_commute (by rw [k1]; exact hx0.2.1.symm), k0, k1, k2]

theorem commute_xPar_d4Root {K : Type} [Field K] {k l : ℕ} (hk : k < 24) (hl : l < 24)
    (h : d4Root k ≠ d4Root l ∧ d4Root k ≠ -d4Root l ∧ ∀ m < 24, d4Root m ≠ d4Root k + d4Root l)
    (a b : K) : Commute (𝕩 (d4Root k) a) (𝕩 (d4Root l) b) :=
  CFSG.LieType.Steinberg.TwistedD4.commute_xPar (isRoot_d4Root hk) (isRoot_d4Root hl) h.1 h.2.1
    (not_isRoot_of_cert fun m hm hm' ↦ h.2.2 m hm hm') a b

theorem commutator_xPar_d4Root_of_repCheck {K : Type} [Field K] {a b g : ℕ} {C : ℤ} (ha : a < 24)
    (hb : b < 24) (hg : g < 24) (h : repCheck d4 a b [(1, 1, g, C)] = true) (s t : K) :
    ⁅𝕩 (d4Root a) s, 𝕩 (d4Root b) t⁆ = 𝕩 (d4Root g) ((C : K) * s * t) := by
  have key := CFSG.LieType.Chevalley.commutator_eltElement_of_repCheck (τ := d4)
    (d4_allValid : allValid d4 = true) h hg
    (α := ⟨d4Root a, isRoot_d4Root ha⟩) (β := ⟨d4Root b, isRoot_d4Root hb⟩)
    (rootPos_eq ha rfl) (rootPos_eq hb rfl) s t
  rw [commutatorElement_def, xPar_of_isRoot (isRoot_d4Root ha),
    xPar_of_isRoot (isRoot_d4Root hb), xPar_of_isRoot (isRoot_d4Root hg), key]
  rfl

theorem commutator_xOrbit {K : Type} [Field K] (σ : K →+* K) :
    ∃ A B C : K, (A = 1 ∨ A = -1) ∧ (B = 1 ∨ B = -1) ∧ (C = 1 ∨ C = -1) ∧ ∀ c : K,
      ⁅xOrbit σ d01 c, xOrbit σ d12 1⁆ = 𝕩 d13 (A * c + B * σ c + C * σ (σ c)) := by
  have r1 : rho d01 = d4Root 1 := by decide
  have r2 : rho (d4Root 1) = d4Root 3 := by decide
  have s1 : rho d12 = d4Root 15 := by decide
  have s2 : rho (d4Root 15) = d4Root 13 := by decide
  have h0 : d01 = d4Root 0 := rfl
  have h12 : d12 = d4Root 12 := rfl
  have he1 := twistSign_eq_one_or σ d01
  have he2 := twistSign_eq_one_or σ (d4Root 1)
  have hf1 := twistSign_eq_one_or σ d12
  have hf2 := twistSign_eq_one_or σ (d4Root 15)
  refine ⟨twistSign σ d12, twistSign σ d01 * twistSign σ d12 * twistSign σ (d4Root 15),
    twistSign σ d01 * twistSign σ (d4Root 1), hf1, ?_, ?_, fun c ↦ ?_⟩
  · rcases he1 with h | h <;> rcases hf1 with h' | h' <;> rcases hf2 with h'' | h'' <;>
      simp [h, h', h'']
  · rcases he1 with h | h <;> rcases he2 with h' | h' <;> simp [h, h']
  rw [xOrbit, xOrbit]
  simp only [r1, r2, s1, s2]
  rw [h0, h12]
  have hz' (v : K) : 𝕩 d13 v = 𝕩 (d4Root 19) v := rfl
  rw [hz', commutator_mul_mul_mul_mul
    (c01 := commutator_xPar_d4Root_of_repCheck (by decide) (by decide) (by decide)
      (by decide +kernel : repCheck d4 0 15 [(1, 1, 19, 1)] = true) _ _)
    (c12 := commutator_xPar_d4Root_of_repCheck (by decide) (by decide) (by decide)
      (by decide +kernel : repCheck d4 1 13 [(1, 1, 19, 1)] = true) _ _)
    (c20 := commutator_xPar_d4Root_of_repCheck (by decide) (by decide) (by decide)
      (by decide +kernel : repCheck d4 3 12 [(1, 1, 19, 1)] = true) _ _)]
  · rw [← xPar_add, ← xPar_add]
    simp only [map_one, Int.cast_one]
    congr 1
    ring
  · exact commute_xPar_d4Root (by decide) (by decide) (by decide) _ _
  · exact commute_xPar_d4Root (by decide) (by decide) (by decide) _ _
  · exact commute_xPar_d4Root (by decide) (by decide) (by decide) _ _
  · exact commute_xPar_d4Root (by decide) (by decide) (by decide) _ _
  · exact commute_xPar_d4Root (by decide) (by decide) (by decide) _ _
  · exact commute_xPar_d4Root (by decide) (by decide) (by decide) _ _
  · intro w hw
    rcases hw with rfl | rfl | rfl | rfl | rfl | rfl <;> refine ⟨?_, ?_, ?_⟩ <;>
      exact commute_xPar_d4Root (by decide) (by decide) (by decide) _ _

/-- The commutator of the two short root elements is a long root element up to sign. -/
theorem commutator_xS_xS {K : Type} [Field K] [Finite K] {σ : K →+* K} {q : ℕ} (hq : 2 ≤ q)
    (hK : Nat.card K = q ^ 3) (hσq : ∀ c : K, σ c = c ^ q)
    (hσ : ∀ c : K, σ (σ (σ c)) = c) :
    ∃ N : K, (N = 1 ∨ N = -1) ∧
      ∃ h : ∀ c : K, σ (N * (c + σ c + σ (σ c))) = N * (c + σ c + σ (σ c)),
        ∀ c : K, ⁅xS hσ isRoot_d01 rho_d01 c, xS hσ isRoot_d12 rho_d12 1⁆ =
          xL hσ isRoot_d13 rho_d13 ⟨N * (c + σ c + σ (σ c)), h c⟩ := by
  obtain ⟨A, B, C, hA, hB, hC, hcomm⟩ := commutator_xOrbit σ
  have hval (c : K) : (⁅xS hσ isRoot_d01 rho_d01 c, xS hσ isRoot_d12 rho_d12 1⁆ :
      twistedGroup σ).1 = 𝕩 d13 (A * c + B * σ c + C * σ (σ c)) := by
    rw [← hcomm c]
    simp only [commutatorElement_def, Subgroup.coe_mul, Subgroup.coe_inv, xS_val]
  have hfix (c : K) : σ (A * c + B * σ c + C * σ (σ c)) = A * c + B * σ c + C * σ (σ c) := by
    have hmem := CFSG.LieType.Steinberg.TwistedD4.twistedGroup_le_twistFixed σ
      (⁅xS hσ isRoot_d01 rho_d01 c, xS hσ isRoot_d12 rho_d12 1⁆ : twistedGroup σ).2
    rw [CFSG.LieType.Chevalley.mem_twistFixed, hval, twistC_xPar σ isRoot_d13,
      rho_d13, twistSign_of_rho_eq σ hσ isRoot_d13 rho_d13, one_mul] at hmem
    exact xPar_injective isRoot_d13 hmem
  have hAA : σ A = A := by rcases hA with rfl | rfl <;> simp
  have hBB : σ B = B := by rcases hB with rfl | rfl <;> simp
  have hCC : σ C = C := by rcases hC with rfl | rfl <;> simp
  have key (c : K) : (A - C) * c + (B - A) * c ^ q + (C - B) * c ^ (q ^ 2) = 0 := by
    have h := hfix c
    rw [map_add, map_add, map_mul, map_mul, map_mul, hAA, hBB, hCC, hσ] at h
    have e2 : σ (σ c) = c ^ (q ^ 2) := by rw [hσq, hσq, ← pow_mul, sq]
    rw [e2, hσq] at h
    linear_combination -h
  set p : Polynomial K := Polynomial.C (A - C) * Polynomial.X +
    Polynomial.C (B - A) * Polynomial.X ^ q + Polynomial.C (C - B) * Polynomial.X ^ (q ^ 2)
    with hp
  have hq1 : q ≠ 1 := by omega
  have hq2 : q ^ 2 ≠ 1 := by nlinarith
  have hq3 : q ≠ q ^ 2 := by nlinarith
  have hpz : p = 0 := by
    apply Polynomial.eq_zero_of_forall_eval_zero_of_natDegree_lt_card
    · intro c
      simp only [hp, Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_C,
        Polynomial.eval_X, Polynomial.eval_pow]
      exact key c
    · have hdeg : p.natDegree ≤ q ^ 2 := by
        refine (Polynomial.natDegree_add_le _ _).trans
          (max_le ((Polynomial.natDegree_add_le _ _).trans (max_le ?_ ?_)) ?_)
        · exact (Polynomial.natDegree_C_mul_le _ _).trans (by simp; nlinarith)
        · exact (Polynomial.natDegree_C_mul_le _ _).trans (by simp; nlinarith)
        · exact (Polynomial.natDegree_C_mul_le _ _).trans (by simp)
      have hc : Cardinal.mk K = ((q ^ 3 : ℕ) : Cardinal) := by
        rw [← hK]
        exact Nat.cast_card.symm
      rw [hc]
      have : p.natDegree < q ^ 3 := by
        have : q ^ 2 < q ^ 3 := Nat.pow_lt_pow_right (by omega) (by omega)
        omega
      exact_mod_cast this
  have c1 : p.coeff 1 = A - C := by
    simp only [hp, Polynomial.coeff_add, Polynomial.coeff_C_mul, Polynomial.coeff_X,
      Polynomial.coeff_X_pow]
    simp [Ne.symm hq1, Ne.symm hq2]
  have c2 : p.coeff q = B - A := by
    simp only [hp, Polynomial.coeff_add, Polynomial.coeff_C_mul, Polynomial.coeff_X,
      Polynomial.coeff_X_pow]
    simp [hq3, Ne.symm hq1]
  have c3 : p.coeff (q ^ 2) = C - B := by
    simp only [hp, Polynomial.coeff_add, Polynomial.coeff_C_mul, Polynomial.coeff_X,
      Polynomial.coeff_X_pow]
    simp [Ne.symm hq3, Ne.symm hq2]
  rw [hpz] at c1 c2 c3
  simp only [Polynomial.coeff_zero] at c1 c2 c3
  have hAC : A = C := by linear_combination -c1
  have hBA : B = A := by linear_combination -c2
  have e (c : K) : A * (c + σ c + σ (σ c)) = A * c + B * σ c + C * σ (σ c) := by
    rw [hBA, ← hAC]
    ring
  refine ⟨A, hA, fun c ↦ ?_, fun c ↦ ?_⟩
  · rw [e]
    exact hfix c
  · refine Subtype.ext ?_
    rw [hval c, xL_val]
    exact congrArg (𝕩 d13) (e c).symm

/-! ### The short simple root group as a λ-root group -/

/-- The short simple root group `X a` of ³D₄ (`a = ![0,1]`) is a λ-root group over `K` with
`λ (xS c) = c`, and `tor s t` acts on it by `s⁻¹ t²`. In particular `tor 1 t` acts by `t ^ 2`
and `tor (nu t)⁻¹ t⁻¹` acts by `normU σ t * t⁻¹ ^ 2`. -/
theorem exists_shortRootGroup {K : Type} [Field K] [Finite K] (σ : K →+* K)
    (hσ : ∀ c : K, σ (σ (σ c)) = c) :
    ∃ R : LambdaRootGroup (twistedGroup σ) K,
      R.carrier = twistedRootGroup σ ![0, 1] ∧
      (∀ (c : K) (h : xS hσ isRoot_d01 rho_d01 c ∈ R.carrier),
        R.coordinate ⟨xS hσ isRoot_d01 rho_d01 c, h⟩ = Multiplicative.ofAdd c) ∧
      (∀ (s : fixedUnits σ) (t : Kˣ),
        Nonempty (R.Action (tor hσ s t) ((s : Kˣ)⁻¹ * t ^ 2))) := by
  have hp : proj d01 = ![0, 1] := proj_d01.trans (by funext i; fin_cases i <;> decide)
  let f : Multiplicative K →* twistedGroup σ :=
    { toFun := fun c ↦ xS hσ isRoot_d01 rho_d01 (Multiplicative.toAdd c)
      map_one' := by
        have h := xS_add hσ isRoot_d01 rho_d01 (0 : K) 0
        rw [add_zero] at h
        exact left_eq_mul.mp h
      map_mul' := fun a b ↦ xS_add hσ isRoot_d01 rho_d01 _ _ }
  have hmem (c) : f c ∈ twistedRootGroup σ ![0, 1] :=
    (mem_iff_xS hσ isRoot_d01 rho_d01 hp _).2 ⟨_, rfl⟩
  let e : Multiplicative K ≃* twistedRootGroup σ ![0, 1] :=
    MulEquiv.ofBijective (f.codRestrict _ hmem)
      ⟨fun a b h ↦ by
        have h1 : f a = f b := congrArg Subtype.val h
        have h2 : f (a * b⁻¹) = 1 := by rw [map_mul, map_inv, h1, mul_inv_cancel]
        have := xS_eq_one hσ isRoot_d01 rho_d01 h2
        simp only [toAdd_mul, toAdd_inv] at this
        exact Multiplicative.toAdd.injective (by linear_combination this),
       by
        rintro ⟨z, hz⟩
        obtain ⟨c, rfl⟩ := (mem_iff_xS hσ isRoot_d01 rho_d01 hp z).1 hz
        exact ⟨Multiplicative.ofAdd c, rfl⟩⟩
  have hel (c : K) : ((e (Multiplicative.ofAdd c) : twistedRootGroup σ ![0, 1]) :
      twistedGroup σ) = xS hσ isRoot_d01 rho_d01 c := rfl
  refine ⟨LambdaRootGroup.ofMulEquiv _ e, rfl, fun c h ↦ ?_, fun s t ↦ ?_⟩
  · change e.symm ⟨_, h⟩ = _
    rw [MulEquiv.symm_apply_eq]
    exact Subtype.ext (hel c).symm
  · refine LambdaRootGroup.nonempty_action_ofMulEquiv _ _ _ _ fun c ↦ ?_
    rw [hel, hel, CFSG.LieType.Steinberg.CentralExt.TrialityClosed.tor_conj_xS hσ isRoot_d01
      rho_d01 s t c, CFSG.LieType.Steinberg.CentralExt.TrialityClosed.chi_d01]

/-! ### Generation of the root groups -/

/-- ³D₄: a subgroup containing `X a` and `X ![1,2]` contains `X ![1,3]`. -/
theorem rootGroup_one_three_le {K : Type} [Field K] [Finite K] {σ : K →+* K} {q : ℕ}
    (hq : 2 ≤ q) (hK : Nat.card K = q ^ 3) (hσq : ∀ c : K, σ c = c ^ q)
    (F : Subgroup (twistedGroup σ)) (ha : twistedRootGroup σ ![0, 1] ≤ F)
    (h12 : twistedRootGroup σ ![1, 2] ≤ F) :
    twistedRootGroup σ ![1, 3] ≤ F := by
  have hσ : ∀ c : K, σ (σ (σ c)) = c := CFSG.LieType.Steinberg.TwistedD4.sigma_three_of_card hK hσq
  obtain ⟨N, hN, h, hcomm⟩ := commutator_xS_xS hq hK hσq hσ
  obtain ⟨-, htr2⟩ := trace_surjective_onto_fixed hq (m := 3) (by norm_num) hK σ hσq
  have e01 : r01 = ![0, 1] := by funext i; fin_cases i <;> rfl
  have e12 : r12 = ![1, 2] := by funext i; fin_cases i <;> rfl
  have e13 : r13 = ![1, 3] := by funext i; fin_cases i <;> rfl
  intro g hg
  rw [← e13] at hg
  obtain ⟨c', rfl⟩ := (mem_iff_xL hσ isRoot_d13 rho_d13 proj_d13 g).1 hg
  have hN2 : N * N = 1 := by rcases hN with rfl | rfl <;> simp
  have hfix : σ (N * c'.1) = N * c'.1 := by
    have h1 : σ c'.1 = c'.1 := c'.2
    have hN' : σ N = N := by rcases hN with rfl | rfl <;> simp
    rw [map_mul, hN', h1]
  obtain ⟨c, hc⟩ := htr2 _ hfix
  have hc' : c + σ c + σ (σ c) = N * c'.1 := by
    simpa [Finset.sum_range_succ] using hc
  have heq : (⟨N * (c + σ c + σ (σ c)), h c⟩ : fixedField σ) = c' := by
    apply Subtype.ext
    simp only
    rw [hc', ← mul_assoc, hN2, one_mul]
  have hxa : xS hσ isRoot_d01 rho_d01 c ∈ F :=
    ha (e01 ▸ (mem_iff_xS hσ isRoot_d01 rho_d01 proj_d01 _).2 ⟨c, rfl⟩)
  have hxb : xS hσ isRoot_d12 rho_d12 (1 : K) ∈ F :=
    h12 (e12 ▸ (mem_iff_xS hσ isRoot_d12 rho_d12 proj_d12 _).2 ⟨1, rfl⟩)
  have := F.mul_mem (F.mul_mem (F.mul_mem hxa hxb) (F.inv_mem hxa)) (F.inv_mem hxb)
  rwa [← commutatorElement_def, hcomm c, heq] at this

theorem isRoot_G2_zero_one : CFSG.Blueprint.Chevalley.IsRoot .G2 ![0, 1] := by
  have e : (![0, 1] : Fin (Tag.rank .G2) → ℤ) = Pi.single (ng 1) 1 := by
    funext i; fin_cases i <;> decide
  rw [e]
  exact CFSG.Blueprint.Chevalley.IsRoot.basis _

theorem isRoot_G2_one_three : CFSG.Blueprint.Chevalley.IsRoot .G2 ![1, 3] := by
  have h := CFSG.Blueprint.Chevalley.IsRoot.reflect (τ := .G2) (ng 1)
    (CFSG.Blueprint.Chevalley.IsRoot.basis (τ := .G2) (ng 0))
  have e : reflect .G2 (ng 1) (Pi.single (ng 0) 1) = ![1, 3] := by
    funext i; fin_cases i <;> decide
  rwa [e] at h

private theorem twistedRootGroup_le_of_word_mem {K : Type} [Field K] (σ : K →+* K)
    (word : List (Fin (Tag.rank .G2))) {β : Fin (Tag.rank .G2) → ℤ}
    (hβ : CFSG.Blueprint.Chevalley.IsRoot .G2 β) (F : Subgroup (twistedGroup σ))
    (hg : (word.map (nHat σ)).prod ∈ F) (hX : twistedRootGroup σ β ≤ F) :
    twistedRootGroup σ (word.foldr (fun i v ↦ reflect .G2 i v) β) ≤ F :=
  rootGroup_le_of_word_mem (twistedRootGroup σ) (nHat σ)
    (fun i _ hβ _ hx ↦ CFSG.LieType.Steinberg.TwistedD4.nHat_conj_mem σ i hβ hx) (hHat σ)
    (fun i ↦ CFSG.LieType.Steinberg.TwistedD4.nHat_sq_mem σ i)
    (fun i _ hβ _ hh _ hx ↦ CFSG.LieType.Steinberg.TwistedD4.hHat_conj_mem σ i hβ hh hx)
    word β hβ F hg hX

/-- ³D₄: a subgroup containing `n` and `X a` contains `X (-a)` and `X ![1,2]`. -/
theorem rootGroup_neg_short_le {K : Type} [Field K] (σ : K →+* K) (F : Subgroup (twistedGroup σ))
    (hn : nHat σ (ng 0) * nHat σ (ng 1) ∈ F) (ha : twistedRootGroup σ ![0, 1] ≤ F) :
    twistedRootGroup σ (-![0, 1]) ≤ F ∧ twistedRootGroup σ ![1, 2] ≤ F := by
  have e3 : [ng 0, ng 1, ng 0, ng 1, ng 0, ng 1].foldr (fun i v ↦ reflect .G2 i v) ![0, 1] =
      -![0, 1] := by
    funext i; fin_cases i <;> decide
  have e5 : [ng 0, ng 1, ng 0, ng 1, ng 0, ng 1, ng 0, ng 1, ng 0, ng 1].foldr
      (fun i v ↦ reflect .G2 i v) ![0, 1] = ![1, 2] := by
    funext i; fin_cases i <;> decide
  have h3 := twistedRootGroup_le_of_word_mem σ [ng 0, ng 1, ng 0, ng 1, ng 0, ng 1]
    isRoot_G2_zero_one F (by simpa [mul_assoc] using F.mul_mem hn (F.mul_mem hn hn)) ha
  have h5 := twistedRootGroup_le_of_word_mem σ
    [ng 0, ng 1, ng 0, ng 1, ng 0, ng 1, ng 0, ng 1, ng 0, ng 1] isRoot_G2_zero_one F
    (by simpa [mul_assoc] using F.mul_mem hn (F.mul_mem hn (F.mul_mem hn (F.mul_mem hn hn)))) ha
  rw [e3] at h3
  rw [e5] at h5
  exact ⟨h3, h5⟩

/-- ³D₄: a subgroup containing `n` and `X ![1,3]` contains `X b` and `X (-b)`. -/
theorem rootGroup_long_simple_le {K : Type} [Field K] (σ : K →+* K)
    (F : Subgroup (twistedGroup σ)) (hn : nHat σ (ng 0) * nHat σ (ng 1) ∈ F)
    (hl : twistedRootGroup σ ![1, 3] ≤ F) :
    twistedRootGroup σ ![1, 0] ≤ F ∧ twistedRootGroup σ (-![1, 0]) ≤ F := by
  have e1 : [ng 0, ng 1].foldr (fun i v ↦ reflect .G2 i v) ![1, 3] = -![1, 0] := by
    funext i; fin_cases i <;> decide
  have e4 : [ng 0, ng 1, ng 0, ng 1, ng 0, ng 1, ng 0, ng 1].foldr
      (fun i v ↦ reflect .G2 i v) ![1, 3] = ![1, 0] := by
    funext i; fin_cases i <;> decide
  have h1 := twistedRootGroup_le_of_word_mem σ [ng 0, ng 1] isRoot_G2_one_three F
    (by simpa using hn) hl
  have h4 := twistedRootGroup_le_of_word_mem σ [ng 0, ng 1, ng 0, ng 1, ng 0, ng 1, ng 0, ng 1]
    isRoot_G2_one_three F
    (by simpa [mul_assoc] using F.mul_mem hn (F.mul_mem hn (F.mul_mem hn hn))) hl
  rw [e1] at h1
  rw [e4] at h4
  exact ⟨h4, h1⟩

/-! ### The character values are good -/

/-- The ³D₄ character values are good: for `t` a generator of `Kˣ`, `t ^ 2` and
`normU σ t * (t⁻¹) ^ 2` are good scalars. -/
theorem isGoodScalar_sq_and_normU_mul_inv_sq {K : Type} [Field K] [Finite K] {σ : K →+* K}
    {q : ℕ} (hq : 2 ≤ q) (hK : Nat.card K = q ^ 3) (hσq : ∀ c : K, σ c = c ^ q) (t : Kˣ)
    (ht : Subgroup.zpowers t = ⊤) :
    IsNontrivialGeneratingScalar (t ^ 2) ∧ IsNontrivialGeneratingScalar (normU σ t * t⁻¹ ^ 2) := by
  obtain ⟨r, rfl⟩ : ∃ r, q = r + 1 := ⟨q - 1, by omega⟩
  have hr : 1 ≤ r := by omega
  have hcard : Nat.card Kˣ = (r + 1) ^ 3 - 1 := by
    rw [Nat.card_units, hK]
  have hord : orderOf t = r * (r ^ 2 + 3 * r + 3) := by
    rw [orderOf_eq_card_of_zpowers_eq_top ht, hcard]
    have : (r + 1) ^ 3 = r * (r ^ 2 + 3 * r + 3) + 1 := by ring
    omega
  have hbig : 2 < orderOf t := by
    rw [hord]
    nlinarith
  have hcop : (orderOf t).Coprime (r ^ 2 + 3 * r + 1) := by
    rw [hord]
    apply Nat.Coprime.mul_left
    · have : r ^ 2 + 3 * r + 1 = (r + 3) * r + 1 := by ring
      rw [this]
      simp
    · have h2 : (r ^ 2 + 3 * r + 1) + 2 = r ^ 2 + 3 * r + 3 := by ring
      rw [← h2]
      have hodd : ¬ 2 ∣ r ^ 2 + 3 * r + 1 := by
        intro h
        have : 2 ∣ r * (r + 1) := (Nat.even_mul_succ_self r).two_dvd
        have e : r ^ 2 + 3 * r + 1 = r * (r + 1) + (2 * r + 1) := by ring
        omega
      rw [add_comm, Nat.coprime_add_self_left]
      exact (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).2 hodd
  have hl : normU σ t * t⁻¹ ^ 2 = t ^ (r ^ 2 + 3 * r + 1) := by
    rw [CFSG.LieType.Steinberg.CentralExt.TrialityClosed.normU_eq_pow hσq]
    have : (1 + (r + 1) + (r + 1) ^ 2) = (r ^ 2 + 3 * r + 1) + 2 := by ring
    rw [this, pow_add, mul_assoc, ← mul_pow, mul_inv_cancel, one_pow, mul_one]
  have hlord : orderOf (t ^ (r ^ 2 + 3 * r + 1)) = orderOf t := Nat.Coprime.orderOf_pow hcop
  refine ⟨⟨⟨t, ht, Or.inr rfl⟩, ?_⟩, ⟨⟨t ^ (r ^ 2 + 3 * r + 1), ?_, Or.inl hl⟩, ?_⟩⟩
  · intro h
    have := Nat.le_of_dvd (by norm_num) (orderOf_dvd_of_pow_eq_one h)
    omega
  · apply Subgroup.eq_top_of_card_eq
    rw [Nat.card_zpowers, hlord, orderOf_eq_card_of_zpowers_eq_top ht]
  · rw [hl]
    intro h
    have := orderOf_eq_one_iff.2 h
    omega

end CFSGCorollary.TrialityD4
