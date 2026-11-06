module

public import CFSGCorollary.LieType.Twisted.TwistedE6.RootGroups
import CFSGCorollary.LieType.Twisted.Basic

/-!
# A commutator relation in `²E₆`

The commutator of the root elements `xPair γ s ∈ X e₂` and `xPair δ 1 ∈ X ![0,1,1,0]` of
`fixedGroup K θ` is `xm ε (± (s + θ s))`, a root element of the long root group `X ![0,1,2,0]`.
Since the trace `s ↦ s + θ s` is onto the fixed field, the long root group `X ![0,1,2,0]` lies
in every subgroup containing `X e₂` and `X ![0,1,1,0]`.

## Main results

* `CFSGCorollary.TwistedE6.commutator_xPair_xPair`: the commutator formula.
* `CFSGCorollary.TwistedE6.rootGroup_long_le`: `X ![0,1,2,0] ≤ F` whenever `X e₂ ≤ F` and
  `X ![0,1,1,0] ≤ F`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedE6

open CFSG.Blueprint.Chevalley (Tag IsRoot)
open CFSG.LieType.Steinberg.TwistedE6 (nf rho twistedRootGroup fixedGroup xPair proj twistSign
  twistSign_of_rho_eq twistSign_single twistSign_eq_one_or mem_fixedGroup isRoot_rho
  not_isRoot_of_form commute_xm)
open CFSG.LieType.Steinberg.Minuscule (e6Data_valid)
open scoped commutatorElement

private abbrev rhoGamma : Fin (Tag.rank .E6) → ℤ := ![0, 0, 0, 0, 1, 0]

private abbrev rhoDelta : Fin (Tag.rank .E6) → ℤ := ![0, 0, 0, 1, 1, 0]

private theorem commutator_mul_mul {G : Type*} [Group G] (A B C D z1 z2 : G)
    (hBD : B * D = D * B) (hAC : A * C = C * A) (hAD : A * D = z1 * (D * A))
    (hBC : B * C = z2 * (C * B)) (hz2 : A * z2 = z2 * A) (hz1 : z1 * C = C * z1) :
    ⁅A * B, C * D⁆ = z2 * z1 := by
  have e1 : A * B * (C * D) = z2 * (C * (A * D) * B) := by
    calc A * B * (C * D) = A * (B * C) * D := by group
      _ = (A * z2) * (C * B) * D := by rw [hBC]; group
      _ = z2 * (A * C) * (B * D) := by rw [hz2]; group
      _ = z2 * (C * A) * (D * B) := by rw [hAC, hBD]
      _ = _ := by group
  have e2 : C * (A * D) * B = z1 * (C * D * (A * B)) := by
    rw [hAD]
    calc C * (z1 * (D * A)) * B = (C * z1) * (D * A) * B := by group
      _ = (z1 * C) * (D * A) * B := by rw [hz1]
      _ = _ := by group
  have h : A * B * (C * D) = z2 * z1 * (C * D * (A * B)) := by
    rw [e1, e2]; group
  rw [commutatorElement_def, h]
  group

private theorem exists_theta_ne {K : Type} [Field K] [Finite K] {q : ℕ} (hq : 2 ≤ q)
    (hK : Nat.card K = q ^ 2) (θ : K →+* K) (hθq : ∀ c : K, θ c = c ^ q) :
    ∃ s : K, θ s ≠ s := by
  classical
  by_contra h
  push Not at h
  have := Fintype.ofFinite K
  have hne : (Polynomial.X ^ q - Polynomial.X : Polynomial K) ≠ 0 := by
    intro h0
    have := congrArg (fun p ↦ Polynomial.coeff p q) h0
    have hq1 : (1 : ℕ) ≠ q := by omega
    simp [Polynomial.coeff_X, hq1] at this
  have hdeg : (Polynomial.X ^ q - Polynomial.X : Polynomial K).natDegree ≤ q :=
    (Polynomial.natDegree_sub_le _ _).trans (max_le (by simp) (by simp; omega))
  have hsub : (Finset.univ : Finset K).val ⊆
      (Polynomial.X ^ q - Polynomial.X : Polynomial K).roots := by
    intro a _
    rw [Polynomial.mem_roots hne]
    have := h a
    rw [hθq] at this
    simp [Polynomial.IsRoot, this]
  have := Polynomial.card_le_degree_of_subset_roots hsub
  rw [Finset.card_univ, ← Nat.card_eq_fintype_card, hK] at this
  nlinarith

/-- There is `N = ±1` with `⁅xPair γ s, xPair δ 1⁆ = xm ε (N * (s + θ s))` for all `s`. -/
theorem commutator_xPair_xPair {K : Type} [Field K] [Finite K] {q : ℕ} (hq : 2 ≤ q)
    (hK : Nat.card K = q ^ 2) (θ : K →+* K) (hθq : ∀ c : K, θ c = c ^ q)
    (hθ : ∀ c : K, θ (θ c) = c) :
    ∃ N : K, (N = 1 ∨ N = -1) ∧ ∀ s : K,
      ((⁅xPair θ hθ isRoot_gammaRoot rho_gammaRoot_ne s,
          xPair θ hθ isRoot_deltaRoot rho_deltaRoot_ne 1⁆ : fixedGroup K θ) :
        e6Data_valid.minGroup K) =
        e6Data_valid.xm K epsRoot (N * (s + θ s)) := by
  classical
  have hργ : rho gammaRoot = rhoGamma := by funext i; fin_cases i <;> decide
  have hρδ : rho deltaRoot = rhoDelta := by funext i; fin_cases i <;> decide
  have hs1 : gammaRoot + rhoDelta = epsRoot := by funext i; fin_cases i <;> decide
  have hs2 : rhoGamma + deltaRoot = epsRoot := by funext i; fin_cases i <;> decide
  have hRG : IsRoot .E6 rhoGamma := hργ ▸ isRoot_rho isRoot_gammaRoot
  have hRD : IsRoot .E6 rhoDelta := hρδ ▸ isRoot_rho isRoot_deltaRoot
  have nr0 : ¬ IsRoot .E6 (gammaRoot + deltaRoot) := not_isRoot_of_form (by decide)
  have nr0' : ¬ IsRoot .E6 (rhoGamma + rhoDelta) := not_isRoot_of_form (by decide)
  have nrG : ¬ IsRoot .E6 (epsRoot + gammaRoot) := not_isRoot_of_form (by decide)
  have nrD : ¬ IsRoot .E6 (epsRoot + deltaRoot) := not_isRoot_of_form (by decide)
  obtain ⟨σ1, hσ1, h1⟩ := (e6Data_valid.commutator_xm K
    isRoot_gammaRoot hRD (by rw [hs1]; decide)).1 (by rw [hs1]; exact isRoot_epsRoot)
  obtain ⟨σ2, hσ2, h2⟩ := (e6Data_valid.commutator_xm K
    hRG isRoot_deltaRoot (by rw [hs2]; decide)).1 (by rw [hs2]; exact isRoot_epsRoot)
  rw [hs1] at h1
  rw [hs2] at h2
  have he : ((twistSign deltaRoot : ℤ) : K) = 1 ∨ ((twistSign deltaRoot : ℤ) : K) = -1 := by
    rcases twistSign_eq_one_or deltaRoot with h | h <;> simp [h]
  generalize hed : ((twistSign deltaRoot : ℤ) : K) = e at he
  have hval : ∀ s : K,
      ((⁅xPair θ hθ isRoot_gammaRoot rho_gammaRoot_ne s,
          xPair θ hθ isRoot_deltaRoot rho_deltaRoot_ne 1⁆ : fixedGroup K θ) :
        e6Data_valid.minGroup K) = e6Data_valid.xm K epsRoot ((σ1 * e) * s + σ2 * θ s) := by
    intro s
    have hx : ((xPair θ hθ isRoot_gammaRoot rho_gammaRoot_ne s : fixedGroup K θ) :
        e6Data_valid.minGroup K) =
        e6Data_valid.xm K gammaRoot s * e6Data_valid.xm K rhoGamma (θ s) := by
      rw [CFSG.LieType.Steinberg.TwistedE6.xPair_val, hργ, twistSign_single, Int.cast_one,
        one_mul]
    have hy : ((xPair θ hθ isRoot_deltaRoot rho_deltaRoot_ne 1 : fixedGroup K θ) :
        e6Data_valid.minGroup K) =
        e6Data_valid.xm K deltaRoot 1 * e6Data_valid.xm K rhoDelta e := by
      rw [CFSG.LieType.Steinberg.TwistedE6.xPair_val, hρδ, hed, map_one, mul_one]
    rw [commutatorElement_def, Subgroup.coe_mul, Subgroup.coe_mul, Subgroup.coe_mul,
      Subgroup.coe_inv, Subgroup.coe_inv, hx, hy, ← commutatorElement_def]
    have hz1e : ⁅e6Data_valid.xm K gammaRoot s, e6Data_valid.xm K rhoDelta e⁆ =
        e6Data_valid.xm K epsRoot (σ1 * s * e) := h1 _ _
    have hz2e : ⁅e6Data_valid.xm K rhoGamma (θ s), e6Data_valid.xm K deltaRoot 1⁆ =
        e6Data_valid.xm K epsRoot (σ2 * θ s * 1) := h2 _ _
    have cG : ∀ c d : K,
        Commute (e6Data_valid.xm K gammaRoot c) (e6Data_valid.xm K epsRoot d) :=
      fun c d ↦ (commute_xm isRoot_epsRoot isRoot_gammaRoot (by decide) nrG d c).symm
    have cD : ∀ c d : K,
        Commute (e6Data_valid.xm K deltaRoot c) (e6Data_valid.xm K epsRoot d) :=
      fun c d ↦ (commute_xm isRoot_epsRoot isRoot_deltaRoot (by decide) nrD d c).symm
    rw [commutator_mul_mul _ _ _ _ ⁅e6Data_valid.xm K gammaRoot s, e6Data_valid.xm K rhoDelta e⁆
      ⁅e6Data_valid.xm K rhoGamma (θ s), e6Data_valid.xm K deltaRoot 1⁆
      (commute_xm hRG hRD (by decide) nr0' _ _).eq
      (commute_xm isRoot_gammaRoot isRoot_deltaRoot (by decide) nr0 _ _).eq
      (by rw [commutatorElement_def]; group)
      (by rw [commutatorElement_def]; group)
      (by rw [hz2e]; exact cG _ _)
      (by rw [hz1e]; exact (cD _ _).symm.eq), hz2e, hz1e, ← e6Data_valid.xm_add]
    congr 1
    ring
  have hfix : ∀ s : K, θ ((σ1 * e) * s + σ2 * θ s) = (σ1 * e) * s + σ2 * θ s := by
    intro s
    have hg := (⁅xPair θ hθ isRoot_gammaRoot rho_gammaRoot_ne s,
      xPair θ hθ isRoot_deltaRoot rho_deltaRoot_ne 1⁆ : fixedGroup K θ).2
    rw [mem_fixedGroup, hval s, CFSG.LieType.Steinberg.TwistedE6.sigma_xm θ isRoot_epsRoot,
      rho_epsRoot, twistSign_of_rho_eq isRoot_epsRoot rho_epsRoot, Int.cast_one, one_mul] at hg
    exact e6Data_valid.xm_injective K isRoot_epsRoot hg
  have hσ1' : σ1 = 1 ∨ σ1 = -1 := hσ1
  have hσ2' : σ2 = 1 ∨ σ2 = -1 := hσ2
  have hA : σ1 * e = 1 ∨ σ1 * e = -1 := by
    rcases hσ1' with h | h <;> rcases he with h' | h' <;> simp [h, h']
  have hθA : θ (σ1 * e) = σ1 * e := by rcases hA with h | h <;> simp [h]
  have hθB : θ σ2 = σ2 := by rcases hσ2' with h | h <;> simp [h]
  have key : ∀ s : K, (σ1 * e - σ2) * (θ s - s) = 0 := by
    intro s
    have := hfix s
    rw [map_add, map_mul θ (σ1 * e) s, map_mul θ σ2, hθA, hθB, hθ] at this
    linear_combination this
  obtain ⟨s0, hs0⟩ := exists_theta_ne hq hK θ hθq
  have hAB : σ1 * e = σ2 := by
    rcases mul_eq_zero.1 (key s0) with h | h
    · exact sub_eq_zero.1 h
    · exact absurd (sub_eq_zero.1 h) hs0
  refine ⟨σ2, hσ2', fun s ↦ ?_⟩
  rw [hval s, hAB]
  congr 1
  ring

/-- A subgroup containing `X e₂` and `X ![0,1,1,0]` contains `X ![0,1,2,0]`. -/
theorem rootGroup_long_le {K : Type} [Field K] [Finite K] {q : ℕ} (hq : 2 ≤ q)
    (hK : Nat.card K = q ^ 2) (θ : K →+* K) (hθq : ∀ c : K, θ c = c ^ q)
    (F : Subgroup (fixedGroup K θ)) (h2 : twistedRootGroup K θ (Pi.single (nf 2) 1) ≤ F)
    (h3 : twistedRootGroup K θ ![0, 1, 1, 0] ≤ F) :
    twistedRootGroup K θ ![0, 1, 2, 0] ≤ F := by
  intro g hg
  have hθ : ∀ c : K, θ (θ c) = c :=
    CFSG.LieType.Steinberg.CentralExt.TwistedE6Closed.theta_theta_of_card hK hθq
  have hpe : proj epsRoot = (![0, 1, 2, 0] : Fin (Tag.rank .F4) → ℤ) := by
    funext i; fin_cases i <;> decide
  have hpg : proj gammaRoot = Pi.single (nf 2) 1 := by decide
  have hpd : proj deltaRoot = (![0, 1, 1, 0] : Fin (Tag.rank .F4) → ℤ) := by
    funext i; fin_cases i <;> decide
  obtain ⟨c', hc', hgc⟩ := (CFSG.LieType.Steinberg.TwistedE6.mem_twistedRootGroup_iff_of_fixed
    θ isRoot_epsRoot hpe rho_epsRoot g).1 hg
  obtain ⟨N, hN, hcomm⟩ := commutator_xPair_xPair hq hK θ hθq hθ
  have hNθ : θ N = N := by rcases hN with rfl | rfl <;> simp
  obtain ⟨-, hs⟩ := trace_surjective_onto_fixed hq (m := 2) (by norm_num) hK θ hθq
  obtain ⟨s, hs⟩ := hs (N * c') (by rw [map_mul, hNθ, hc'])
  simp only [Finset.sum_range_succ, Finset.range_zero, Finset.sum_empty, zero_add,
    Function.iterate_zero, id, Function.iterate_one] at hs
  have hNN : N * N = 1 := by rcases hN with rfl | rfl <;> simp
  have key : g = ⁅xPair θ hθ isRoot_gammaRoot rho_gammaRoot_ne s,
      xPair θ hθ isRoot_deltaRoot rho_deltaRoot_ne 1⁆ := by
    apply Subtype.ext
    rw [hcomm s, hgc, hs, ← mul_assoc, hNN, one_mul]
  rw [key]
  have ha : xPair θ hθ isRoot_gammaRoot rho_gammaRoot_ne s ∈ F := by
    apply h2
    have := CFSG.LieType.Steinberg.TwistedE6.xPair_mem θ hθ isRoot_gammaRoot rho_gammaRoot_ne s
    rwa [hpg] at this
  have hb : xPair θ hθ isRoot_deltaRoot rho_deltaRoot_ne 1 ∈ F := by
    apply h3
    have := CFSG.LieType.Steinberg.TwistedE6.xPair_mem θ hθ isRoot_deltaRoot rho_deltaRoot_ne 1
    rwa [hpd] at this
  rw [commutatorElement_def]
  exact F.mul_mem (F.mul_mem (F.mul_mem ha hb) (F.inv_mem ha)) (F.inv_mem hb)

end CFSGCorollary.TwistedE6
