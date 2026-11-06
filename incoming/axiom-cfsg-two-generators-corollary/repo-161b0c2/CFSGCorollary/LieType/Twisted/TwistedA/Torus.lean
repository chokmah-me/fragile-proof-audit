module

public import CFSGCorollary.LieType.Twisted.TwistedA.Coxeter
public import CFSGCorollary.LieType.Twisted.TwistedA.RootGroups
public import CFSGCorollary.LieType.LambdaRootGroup.SpanningScalar
import CFSGCorollary.LieType.Steinberg.GeneratingScalar
import CFSGCorollary.LieType.Twisted.TwistedA.Monomial

/-!
# The torus elements of the unitary groups

Let `F` be a field with `q ^ 2` elements, `q = p ^ f`, `σ = unitaryInvolution F p f`, and let `g`
be the twisted Coxeter element of `SU σ n`. For `n ≥ 4` we define the torus element
`d = torusElement`, the diagonal element `shortTorus` attached to the indices `0` and `n / 2 - 1`
with parameter `κ`; for `n = 3` we use `diag(κ, κ ^ (q - 1), κ ^ (-q))` instead. We show that `d`
and `d₁ = g d g⁻¹` commute and, when `κ` generates `Fˣ`, compute the scalars by which `d` and `d₁`
act on the root group `S(0, 1)` (for `n` even) or `H(0)` (for `n` odd).

## Main results

* `TwistedA.commute_torusElement_conj_coxeterElement_of_ne_zero`: `d` and `g d g⁻¹` commute.
* `TwistedA.exists_su_coe_eq_diagonal_three`: the diagonal element used for `n = 3`.
* `TwistedA.exists_shortRootGroup_actions_of_eq_four`,
  `TwistedA.exists_shortRootGroup_actions_of_even`,
  `TwistedA.exists_heisenbergRootGroup_actions_of_odd`,
  `TwistedA.exists_heisenbergRootGroup_actions_of_eq_three`: the actions of `d` and `d₁` on the
  root group, by scalars `k ≠ 1` and `l ≠ 1` with `k` spanning.
-/

@[expose] public section

namespace CFSGCorollary.TwistedA

open CFSG.LieType.Universal.Unitary CFSG.LieType.BorelTits

section TorusDiag

variable {F : Type} [Field F] {n : ℕ}

/-- The diagonal of the matrix of `torusElement`. -/
noncomputable def torusDiag (σ : F ≃+* F) (hn : 4 ≤ n) (κ : F) : Fin n → F :=
  shortTorusFun σ (lowIdx ⟨0, by omega⟩ : Fin n) (lowIdx ⟨n / 2 - 1, by omega⟩) κ

theorem torusDiag_zero (σ : F ≃+* F) (hn : 4 ≤ n) (κ : F) :
    torusDiag σ hn κ (lowIdx ⟨0, by omega⟩) = κ := by
  unfold torusDiag shortTorusFun
  rw [ite_eq_left rfl]

theorem torusDiag_one_of_lt (σ : F ≃+* F) (hn : 4 ≤ n) (κ : F) (hm : 3 ≤ n / 2) :
    torusDiag σ hn κ (lowIdx ⟨1, by omega⟩) = 1 := by
  unfold torusDiag shortTorusFun
  rw [ite_eq_right, ite_eq_right, ite_eq_right, ite_eq_right]
  all_goals exact Fin.ne_of_val_ne (by simp only [Fin.val_rev, val_lowIdx]; omega)

theorem torusDiag_one_of_eq (σ : F ≃+* F) (hn : 4 ≤ n) (κ : F) (hm : n / 2 = 2) :
    torusDiag σ hn κ (lowIdx ⟨1, by omega⟩) = κ⁻¹ := by
  unfold torusDiag shortTorusFun
  rw [ite_eq_right, ite_eq_left]
  · exact Fin.ext (by simp only [val_lowIdx]; omega)
  · exact Fin.ne_of_val_ne (by simp only [val_lowIdx]; omega)

theorem torusDiag_mid (σ : F ≃+* F) (hn : 4 ≤ n) (κ : F) (hodd : n % 2 = 1) :
    torusDiag σ hn κ (midIdx hodd) = 1 := by
  unfold torusDiag shortTorusFun
  rw [ite_eq_right, ite_eq_right, ite_eq_right, ite_eq_right]
  all_goals exact Fin.ne_of_val_ne (by simp only [Fin.val_rev, val_lowIdx, midIdx]; omega)

theorem torusDiag_rev_last (σ : F ≃+* F) (hn : 4 ≤ n) (κ : F) :
    torusDiag σ hn κ (Fin.rev (lowIdx ⟨n / 2 - 1, by omega⟩)) = σ κ := by
  unfold torusDiag shortTorusFun
  rw [ite_eq_right, ite_eq_right, ite_eq_right, ite_eq_left rfl]
  all_goals exact Fin.ne_of_val_ne (by simp only [Fin.val_rev, val_lowIdx]; omega)

end TorusDiag

section Arith

variable {F : Type} [Field F] {p f : ℕ}

/-- A generator of `Fˣ` has order `q ^ 2 - 1`. -/
theorem orderOf_eq_of_forall_mem_zpowers (hF : Nat.card F = (p ^ f) ^ 2) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ) : orderOf κ = (p ^ f) ^ 2 - 1 := by
  rw [orderOf_eq_card_of_forall_mem_zpowers hκ, Nat.card_units, hF]

theorem pow_ne_one_of_lt (hF : Nat.card F = (p ^ f) ^ 2) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ) (e : ℕ) (h0 : 0 < e) (h1 : e < (p ^ f) ^ 2 - 1) :
    κ ^ e ≠ 1 := by
  intro h
  have := Nat.le_of_dvd h0 (orderOf_dvd_of_pow_eq_one h)
  rw [orderOf_eq_of_forall_mem_zpowers hF κ hκ] at this
  omega

theorem zpow_neg_ne_one_of_lt (hF : Nat.card F = (p ^ f) ^ 2) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ) (e : ℕ) (h0 : 0 < e) (h1 : e < (p ^ f) ^ 2 - 1) :
    κ ^ (-(e : ℤ)) ≠ 1 := by
  rw [zpow_neg, zpow_natCast, inv_ne_one]
  exact pow_ne_one_of_lt hF κ hκ e h0 h1

variable [Finite F]

/-- If `|F| = q ^ 2` then `2 ≤ q`. -/
theorem two_le_pow_of_card (hF : Nat.card F = (p ^ f) ^ 2) : 2 ≤ p ^ f := by
  have h1 : 1 < Nat.card F := Finite.one_lt_card
  rw [hF] at h1
  by_contra h
  have : p ^ f ≤ 1 := by omega
  have : (p ^ f) ^ 2 ≤ 1 := by
    rw [sq]; exact Nat.mul_le_mul this this |>.trans (by norm_num)
  omega

/-- For a generator `κ` of `Fˣ` and `q ≠ 2`, `κ ^ (2 - q)` is a spanning scalar. -/
theorem isSpanningScalar_zpow_two_sub (hF : Nat.card F = (p ^ f) ^ 2) (hq : p ^ f ≠ 2) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ) :
    IsSpanningScalar (((κ ^ ((2 : ℤ) - (p ^ f : ℕ)) : Fˣ)) : F) := by
  have hq2 := two_le_pow_of_card hF
  have hq3 : 3 ≤ p ^ f := by omega
  have hN0 := orderOf_eq_of_forall_mem_zpowers hF κ hκ
  obtain ⟨r, hr⟩ : ∃ r, p ^ f = r + 3 := ⟨p ^ f - 3, by omega⟩
  rw [hr] at hN0 hF hq2 hq3 hq
  have hN := hN0
  have hk : κ ^ ((2 : ℤ) - ((r + 3 : ℕ) : ℤ)) = (κ ^ (r + 1))⁻¹ := by
    rw [← zpow_natCast, ← zpow_neg]; congr 1
  rw [hr, hk]
  refine isSpanningScalar_of_le_orderOf (Q := r + 3) (by omega) hF ?_ ?_
  · simp
  · rw [orderOf_units, orderOf_inv, orderOf_pow' _ (by omega), hN]
    have e2 : (r + 3) ^ 2 - 1 = r ^ 2 + 6 * r + 8 := by
      have : 1 ≤ (r + 3) ^ 2 := by nlinarith
      zify [this]; ring
    set g := Nat.gcd ((r + 3) ^ 2 - 1) (r + 1) with hg
    have hg1 : g ∣ r + 1 := Nat.gcd_dvd_right _ _
    have hg2 : g ∣ (r + 3) ^ 2 - 1 := Nat.gcd_dvd_left _ _
    have hg3 : g ∣ 3 := by
      have e : (r + 3) ^ 2 - 1 = (r + 1) * (r + 5) + 3 := by
        zify [show 1 ≤ (r + 3) ^ 2 by nlinarith]; ring
      rw [e] at hg2
      exact (Nat.dvd_add_right (Dvd.dvd.mul_right hg1 _)).mp hg2
    have hgpos : 0 < g := Nat.pos_of_dvd_of_pos hg2 (by rw [e2]; omega)
    have hg3' : g ≤ 3 := Nat.le_of_dvd (by norm_num) hg3
    rcases Nat.lt_or_ge r 1 with hr | hr
    · have : r = 0 := by omega
      subst this
      have : g ∣ 1 := hg1
      have : g = 1 := Nat.dvd_one.mp this
      rw [this]; norm_num
    · rw [Nat.le_div_iff_mul_le hgpos, e2]
      nlinarith

/-- A generator `κ` of `Fˣ` and its square are spanning scalars. -/
theorem isSpanningScalar_of_forall_mem_zpowers (κ k : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ) (h : k = κ ∨ k = κ ^ 2) :
    IsSpanningScalar (k : F) := by
  have := addSubgroup_closure_mul_pow_eq_top (1 : F) one_ne_zero k
    ⟨κ, eq_top_iff.2 fun x _ ↦ hκ x, h⟩
  unfold IsSpanningScalar
  rw [← this]
  congr 1
  ext x
  simp [Units.val_pow_eq_pow_val, eq_comm]

theorem zpow_two_sub_ne_one_and_zpow_one_sub_two_mul_ne_one (hF : Nat.card F = (p ^ f) ^ 2)
    (hq : p ^ f ≠ 2) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ) :
    κ ^ ((2 : ℤ) - (p ^ f : ℕ)) ≠ 1 ∧ κ ^ ((1 : ℤ) - 2 * (p ^ f : ℕ)) ≠ 1 := by
  have hq2 := two_le_pow_of_card hF
  have key : ∀ e : ℕ, 0 < e → e < (p ^ f) ^ 2 - 1 → κ ^ (-(e : ℤ)) ≠ 1 :=
    fun e a b ↦ zpow_neg_ne_one_of_lt hF κ hκ e a b
  generalize p ^ f = q at *
  have h3 : 3 ≤ q := by omega
  have h4 : 3 * q ≤ q ^ 2 := by nlinarith
  constructor
  · have := key (q - 2) (by omega) (by omega)
    rwa [show ((2 : ℤ) - q) = -((q - 2 : ℕ) : ℤ) by omega]
  · have := key (2 * q - 1) (by omega) (by omega)
    rwa [show ((1 : ℤ) - 2 * q) = -((2 * q - 1 : ℕ) : ℤ) by omega]

end Arith

variable {F : Type} [Field F] [Finite F] {p f : ℕ} [Fact p.Prime] [CharP F p]
  (hF : Nat.card F = (p ^ f) ^ 2) {n : ℕ}

/-- The torus element `d`: `shortTorus` at the indices `(0, n / 2 - 1)` with parameter `κ`. -/
noncomputable def torusElement (hn : 4 ≤ n) (κ : F) : SU (unitaryInvolution F p f) n :=
  shortTorus (unitaryInvolution F p f) (unitaryInvolution_involutive hF)
    (a := lowIdx ⟨0, by omega⟩) (b := lowIdx ⟨n / 2 - 1, by omega⟩)
    (Fin.ne_of_val_ne (by simp [val_lowIdx]; omega))
    (lowIdx_ne_rev_self _) (lowIdx_ne_rev_self _) κ

/-- Conjugating a diagonal element by the Coxeter element permutes its diagonal by
`coxeterPerm n`. -/
theorem coe_conj_coxeterElement_eq_diagonal
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0)
    {D : SU (unitaryInvolution F p f) n} {t : Fin n → F}
    (hD : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal t) :
    ((coxeterElement (unitaryInvolution_involutive hF) ζ n * D *
      (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹ : SU (unitaryInvolution F p f) n) :
        GL (Fin n) F).val = Matrix.diagonal (fun s ↦ t ((coxeterPerm n).symm s)) := by
  obtain ⟨ε, hε⟩ := exists_coe_coxeterElement_eq_signedPerm (unitaryInvolution_involutive hF) hζ
  exact coe_conj_eq_diagonal hε hD

/-- Two elements of `SU` with diagonal matrices `D` and `g D g⁻¹` commute. -/
theorem commute_conj_coxeterElement_of_coe_eq_diagonal
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0)
    {D : SU (unitaryInvolution F p f) n} {t : Fin n → F}
    (hD : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal t) :
    Commute D (coxeterElement (unitaryInvolution_involutive hF) ζ n * D *
      (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) :=
  commute_of_coe_eq_diagonal hD (coe_conj_coxeterElement_eq_diagonal hF hζ hD)

/-- The matrix of `torusElement` is diagonal. -/
theorem coe_torusElement (hn : 4 ≤ n) {κ : F} (hκ : κ ≠ 0) :
    ((torusElement hF hn κ : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) =
      Matrix.diagonal (shortTorusFun (unitaryInvolution F p f)
        (lowIdx ⟨0, by omega⟩ : Fin n) (lowIdx ⟨n / 2 - 1, by omega⟩) κ) := by
  unfold torusElement
  exact coe_shortTorus _ _ _ _ _ (Fin.ne_of_val_ne (by simp [val_lowIdx]; omega)) hκ

/-- `d` and `g d g⁻¹` act on `S(0, 1)` by the ratios of the corresponding diagonal entries. -/
theorem nonempty_action_shortRootGroup_torusElement_and_conj (hn : 4 ≤ n) (κ : Fˣ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0)
    (k l : Fˣ)
    (hk : (k : F) = torusDiag (unitaryInvolution F p f) hn (κ : F) (lowIdx ⟨0, by omega⟩) *
      (torusDiag (unitaryInvolution F p f) hn (κ : F) (lowIdx ⟨1, by omega⟩))⁻¹)
    (hl : (l : F) = torusDiag (unitaryInvolution F p f) hn (κ : F)
        (Fin.rev (lowIdx ⟨n / 2 - 1, by omega⟩)) *
      (torusDiag (unitaryInvolution F p f) hn (κ : F) (lowIdx ⟨0, by omega⟩))⁻¹) :
    Nonempty ((shortRootGroup (σ := unitaryInvolution F p f) (unitaryInvolution_involutive hF)
          (n := n) hn).Action (torusElement hF hn (κ : F)) k) ∧
      Nonempty ((shortRootGroup (σ := unitaryInvolution F p f) (unitaryInvolution_involutive hF)
          (n := n) hn).Action
          (coxeterElement (unitaryInvolution_involutive hF) ζ n * torusElement hF hn (κ : F) *
            (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) l) := by
  have hD := coe_torusElement (hF := hF) hn κ.ne_zero
  refine ⟨nonempty_action_shortRootGroup _ hn hD k hk, ?_⟩
  refine nonempty_action_shortRootGroup _ hn
    (coe_conj_coxeterElement_eq_diagonal (hF := hF) hζ hD) l ?_
  simp only [coxeterPerm_symm_zero (by omega : 3 ≤ n), coxeterPerm_symm_one hn]
  exact hl

/-- `d` and `g d g⁻¹` act on `H(0)` by the ratios of the corresponding diagonal entries. -/
theorem nonempty_action_heisenbergRootGroup_torusElement_and_conj (hodd : n % 2 = 1) (hn : 5 ≤ n)
    (hn4 : 4 ≤ n) (κ : Fˣ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0)
    (k l : Fˣ)
    (hk : (k : F) = torusDiag (unitaryInvolution F p f) hn4 (κ : F) (lowIdx ⟨0, by omega⟩) *
      (torusDiag (unitaryInvolution F p f) hn4 (κ : F) (midIdx hodd))⁻¹)
    (hl : (l : F) = torusDiag (unitaryInvolution F p f) hn4 (κ : F)
        (Fin.rev (lowIdx ⟨n / 2 - 1, by omega⟩)) *
      (torusDiag (unitaryInvolution F p f) hn4 (κ : F) (midIdx hodd))⁻¹) :
    Nonempty ((heisenbergRootGroup hF hodd (by omega)).Action
        (torusElement hF hn4 (κ : F)) k) ∧
      Nonempty ((heisenbergRootGroup hF hodd (by omega)).Action
          (coxeterElement (unitaryInvolution_involutive hF) ζ n * torusElement hF hn4 (κ : F) *
            (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) l) := by
  have hD := coe_torusElement (hF := hF) hn4 κ.ne_zero
  refine ⟨nonempty_action_heisenbergRootGroup hF hodd (by omega) hD k hk, ?_⟩
  refine nonempty_action_heisenbergRootGroup hF hodd (by omega)
    (coe_conj_coxeterElement_eq_diagonal (hF := hF) hζ hD) l ?_
  have hmid : (coxeterPerm n).symm (midIdx hodd) = midIdx hodd :=
    (coxeterPerm n).symm_apply_eq.2 (coxeterPerm_midIdx hodd).symm
  simp only [coxeterPerm_symm_zero (by omega : 3 ≤ n), hmid]
  exact hl

/-- `d` and `d₁ = g d g⁻¹` commute (`n ≥ 4`, even or odd), for a nonzero parameter `κ`. -/
theorem commute_torusElement_conj_coxeterElement_of_ne_zero (hn : 4 ≤ n) (κ : F) (hκ : κ ≠ 0)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0) :
    Commute (torusElement hF hn κ)
      (coxeterElement (unitaryInvolution_involutive hF) ζ n * torusElement hF hn κ *
        (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) :=
  commute_conj_coxeterElement_of_coe_eq_diagonal hF hζ (coe_torusElement hF hn hκ)

include hF in
/-- For `n = 3`, `diag(κ, κ ^ (q - 1), κ ^ (-q))` is the matrix of an element of `SU`. -/
theorem exists_su_coe_eq_diagonal_three (κ : Fˣ) (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ) :
    ∃ D : SU (unitaryInvolution F p f) 3,
      ((D : GL (Fin 3) F) : Matrix (Fin 3) (Fin 3) F) =
        Matrix.diagonal ![(κ : F), (κ : F) ^ (p ^ f - 1), ((κ ^ (p ^ f))⁻¹ : Fˣ)] := by
  have hq2 := two_le_pow_of_card hF
  have hκN : κ ^ ((p ^ f) ^ 2 - 1) = 1 := by
    rw [← orderOf_eq_of_forall_mem_zpowers hF κ hκ]; exact pow_orderOf_eq_one κ
  have hκN' : (κ : F) ^ ((p ^ f) ^ 2 - 1) = 1 := by
    rw [← Units.val_pow_eq_pow_val, hκN]; rfl
  refine exists_su_coe_eq_diagonal (σ := unitaryInvolution F p f)
    (t := ![(κ : F), (κ : F) ^ (p ^ f - 1), ((κ ^ (p ^ f))⁻¹ : Fˣ)]) ?_ ?_
  · rw [Fin.prod_univ_three]
    change (κ : F) * (κ : F) ^ (p ^ f - 1) * ((κ ^ (p ^ f))⁻¹ : Fˣ) = 1
    have h : (κ : F) * (κ : F) ^ (p ^ f - 1) = ((κ ^ (p ^ f) : Fˣ) : F) := by
      rw [Units.val_pow_eq_pow_val, ← pow_succ']
      congr 1
      omega
    rw [h]
    exact Units.mul_inv _
  · have e : (p ^ f - 1) * p ^ f + (p ^ f - 1) = (p ^ f) ^ 2 - 1 := by
      obtain ⟨r, hr⟩ : ∃ r, p ^ f = r + 1 := ⟨p ^ f - 1, by omega⟩
      rw [hr]
      simp only [Nat.add_sub_cancel]
      exact (Nat.sub_eq_of_eq_add (by ring)).symm
    have e2 : ((κ ^ (p ^ f))⁻¹ ^ p ^ f * κ : Fˣ) = 1 := by
      have hqq : κ ^ ((p ^ f) * (p ^ f)) = κ := by
        have : (p ^ f) * (p ^ f) = ((p ^ f) ^ 2 - 1) + 1 := by
          have : 1 ≤ (p ^ f) ^ 2 := by nlinarith
          rw [Nat.sub_add_cancel this]; ring
        rw [this, pow_succ, hκN, one_mul]
      rw [inv_pow, ← pow_mul, hqq]
      exact inv_mul_cancel κ
    intro s
    fin_cases s
    · change unitaryInvolution F p f (κ : F) * ((κ ^ (p ^ f))⁻¹ : Fˣ) = 1
      rw [unitaryInvolution_apply, ← Units.val_pow_eq_pow_val]
      exact Units.mul_inv _
    · change unitaryInvolution F p f ((κ : F) ^ (p ^ f - 1)) * (κ : F) ^ (p ^ f - 1) = 1
      rw [unitaryInvolution_apply, ← pow_mul, ← pow_add, e]
      exact hκN'
    · change unitaryInvolution F p f (((κ ^ (p ^ f))⁻¹ : Fˣ) : F) * (κ : F) = 1
      rw [unitaryInvolution_apply]
      simpa only [Units.val_mul, Units.val_pow_eq_pow_val, Units.val_one] using
        congrArg Units.val e2

/-- Case `n` even, `n = 4`: `d, d₁` act on `S(0,1)` by `κ ^ 2`, `κ ^ (q - 1)`. -/
theorem exists_shortRootGroup_actions_of_eq_four (hn : n = 4) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0) :
    ∃ k l : Fˣ, k = κ ^ 2 ∧ l = κ ^ (p ^ f - 1) ∧ k ≠ 1 ∧ l ≠ 1 ∧ IsSpanningScalar (k : F) ∧
      Nonempty ((shortRootGroup (σ := unitaryInvolution F p f) (unitaryInvolution_involutive hF)
          (n := n) (by omega)).Action (torusElement hF (by omega) (κ : F)) k) ∧
      Nonempty ((shortRootGroup (σ := unitaryInvolution F p f) (unitaryInvolution_involutive hF)
          (n := n) (by omega)).Action
          (coxeterElement (unitaryInvolution_involutive hF) ζ n *
            torusElement hF (by omega) (κ : F) *
            (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) l) := by
  have hq2 := two_le_pow_of_card hF
  have hm : n / 2 = 2 := by omega
  have h0 := κ.ne_zero
  have h4 : 2 * p ^ f ≤ (p ^ f) ^ 2 := by nlinarith
  have hN : 2 < (p ^ f) ^ 2 - 1 := by omega
  obtain ⟨hc1, hc2⟩ := nonempty_action_shortRootGroup_torusElement_and_conj (hF := hF) (n := n)
    (by omega) κ hζ (κ ^ 2) (κ ^ (p ^ f - 1))
    (by rw [torusDiag_zero, torusDiag_one_of_eq _ _ _ hm, inv_inv, Units.val_pow_eq_pow_val, sq])
    (by
      rw [torusDiag_rev_last, torusDiag_zero, unitaryInvolution_apply,
        Units.val_pow_eq_pow_val, eq_mul_inv_iff_mul_eq₀ h0, ← pow_succ]
      congr 1; omega)
  refine ⟨κ ^ 2, κ ^ (p ^ f - 1), rfl, rfl, ?_, ?_,
    isSpanningScalar_of_forall_mem_zpowers κ _ hκ (Or.inr rfl), hc1, hc2⟩
  · exact pow_ne_one_of_lt hF κ hκ 2 (by omega) (by omega)
  · exact pow_ne_one_of_lt hF κ hκ _ (by omega) (by omega)

/-- Case `n` even, `n ≥ 6`: actions by `κ`, `κ ^ (q - 1)`. -/
theorem exists_shortRootGroup_actions_of_even (hn : 6 ≤ n) (hev : n % 2 = 0) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0) :
    ∃ k l : Fˣ, k = κ ∧ l = κ ^ (p ^ f - 1) ∧ k ≠ 1 ∧ l ≠ 1 ∧ IsSpanningScalar (k : F) ∧
      Nonempty ((shortRootGroup (σ := unitaryInvolution F p f) (unitaryInvolution_involutive hF)
          (n := n) (by omega)).Action (torusElement hF (by omega) (κ : F)) k) ∧
      Nonempty ((shortRootGroup (σ := unitaryInvolution F p f) (unitaryInvolution_involutive hF)
          (n := n) (by omega)).Action
          (coxeterElement (unitaryInvolution_involutive hF) ζ n *
            torusElement hF (by omega) (κ : F) *
            (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) l) := by
  have hq2 := two_le_pow_of_card hF
  have hm : 3 ≤ n / 2 := by omega
  have h0 := κ.ne_zero
  have h4 : 2 * p ^ f ≤ (p ^ f) ^ 2 := by nlinarith
  have hN : 2 < (p ^ f) ^ 2 - 1 := by omega
  obtain ⟨hc1, hc2⟩ := nonempty_action_shortRootGroup_torusElement_and_conj (hF := hF) (n := n)
    (by omega) κ hζ κ (κ ^ (p ^ f - 1))
    (by rw [torusDiag_zero, torusDiag_one_of_lt _ _ _ hm, inv_one, mul_one])
    (by
      rw [torusDiag_rev_last, torusDiag_zero, unitaryInvolution_apply,
        Units.val_pow_eq_pow_val, eq_mul_inv_iff_mul_eq₀ h0, ← pow_succ]
      congr 1; omega)
  refine ⟨κ, κ ^ (p ^ f - 1), rfl, rfl, ?_, ?_,
    isSpanningScalar_of_forall_mem_zpowers κ _ hκ (Or.inl rfl), hc1, hc2⟩
  · simpa using pow_ne_one_of_lt hF κ hκ 1 (by omega) (by omega)
  · exact pow_ne_one_of_lt hF κ hκ _ (by omega) (by omega)

/-- Case `n` odd, `n ≥ 5`: actions on `H(0)` by `κ`, `κ ^ q`. -/
theorem exists_heisenbergRootGroup_actions_of_odd (hodd : n % 2 = 1) (hn : 5 ≤ n) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0) :
    ∃ k l : Fˣ, k = κ ∧ l = κ ^ (p ^ f) ∧ k ≠ 1 ∧ l ≠ 1 ∧ IsSpanningScalar (k : F) ∧
      Nonempty ((heisenbergRootGroup hF hodd (by omega)).Action
        (torusElement hF (by omega) (κ : F)) k) ∧
      Nonempty ((heisenbergRootGroup hF hodd (by omega)).Action
          (coxeterElement (unitaryInvolution_involutive hF) ζ n *
            torusElement hF (by omega) (κ : F) *
            (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) l) := by
  have hq2 := two_le_pow_of_card hF
  have h0 := κ.ne_zero
  have h4 : 2 * p ^ f ≤ (p ^ f) ^ 2 := by nlinarith
  have hN : 2 < (p ^ f) ^ 2 - 1 := by omega
  obtain ⟨hc1, hc2⟩ := nonempty_action_heisenbergRootGroup_torusElement_and_conj (hF := hF) hodd hn
    (by omega) κ hζ κ (κ ^ (p ^ f))
    (by rw [torusDiag_zero, torusDiag_mid, inv_one, mul_one])
    (by
      rw [torusDiag_rev_last, torusDiag_mid, unitaryInvolution_apply,
        Units.val_pow_eq_pow_val, inv_one, mul_one])
  refine ⟨κ, κ ^ (p ^ f), rfl, rfl, ?_, ?_,
    isSpanningScalar_of_forall_mem_zpowers κ _ hκ (Or.inl rfl), hc1, hc2⟩
  · simpa using pow_ne_one_of_lt hF κ hκ 1 (by omega) (by omega)
  · exact pow_ne_one_of_lt hF κ hκ _ (by omega) (by omega)

/-- Case `n = 3`: actions on `H(0)` by `κ ^ (2 - q)`, `κ ^ (1 - 2 q)`. -/
theorem exists_heisenbergRootGroup_actions_of_eq_three (hnq : p ^ f ≠ 2) (hn : n = 3) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0)
    {D : SU (unitaryInvolution F p f) n} {t : Fin n → F}
    (hD : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal t)
    (ht : ∀ s : Fin n, (t s) = ![(κ : F), (κ : F) ^ (p ^ f - 1), ((κ ^ (p ^ f))⁻¹ : Fˣ)]
      (Fin.cast hn s)) :
    ∃ k l : Fˣ, k = κ ^ ((2 : ℤ) - (p ^ f : ℕ)) ∧ l = κ ^ ((1 : ℤ) - 2 * (p ^ f : ℕ)) ∧
      k ≠ 1 ∧ l ≠ 1 ∧ IsSpanningScalar (k : F) ∧
      Nonempty ((heisenbergRootGroup hF (by omega) (by omega)).Action D k) ∧
      Nonempty ((heisenbergRootGroup hF (by omega) (by omega)).Action
          (coxeterElement (unitaryInvolution_involutive hF) ζ n * D *
            (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) l) := by
  subst hn
  have hq2 := two_le_pow_of_card hF
  have hodd : 3 % 2 = 1 := by norm_num
  have hμ : (midIdx hodd : Fin 3) = ⟨1, by norm_num⟩ := rfl
  have t0 : t (lowIdx ⟨0, by norm_num⟩) = (κ : F) := ht _
  have tμ : t (midIdx hodd) = (κ : F) ^ (p ^ f - 1) := ht _
  have t2 : t (Fin.rev (lowIdx ⟨3 / 2 - 1, by norm_num⟩)) = ((κ ^ (p ^ f))⁻¹ : Fˣ) := ht _
  have hpq : (κ : F) ^ (p ^ f - 1) ≠ 0 := pow_ne_zero _ κ.ne_zero
  have hk : κ ^ ((2 : ℤ) - (p ^ f : ℕ)) = κ * (κ ^ (p ^ f - 1))⁻¹ := by
    rw [show κ * (κ ^ (p ^ f - 1))⁻¹ = κ ^ ((1 : ℤ) + -((p ^ f - 1 : ℕ) : ℤ)) by
      rw [zpow_add, zpow_one, zpow_neg, zpow_natCast]]
    congr 1
    omega
  have hl : κ ^ ((1 : ℤ) - 2 * (p ^ f : ℕ)) = (κ ^ (p ^ f))⁻¹ * (κ ^ (p ^ f - 1))⁻¹ := by
    rw [← zpow_natCast κ (p ^ f), ← zpow_natCast κ (p ^ f - 1), ← zpow_neg, ← zpow_neg,
      ← zpow_add]
    congr 1
    omega
  obtain ⟨hne1, hne2⟩ := zpow_two_sub_ne_one_and_zpow_one_sub_two_mul_ne_one hF hnq κ hκ
  refine ⟨_, _, rfl, rfl, hne1, hne2, isSpanningScalar_zpow_two_sub hF hnq κ hκ,
    nonempty_action_heisenbergRootGroup hF hodd (le_refl 3) hD _ ?_, ?_⟩
  · rw [hk, t0, tμ]; simp
  · refine nonempty_action_heisenbergRootGroup hF hodd (le_refl 3)
      (coe_conj_coxeterElement_eq_diagonal (hF := hF) hζ hD) _ ?_
    have hmid : (coxeterPerm 3).symm (midIdx hodd) = midIdx hodd :=
      (coxeterPerm 3).symm_apply_eq.2 (coxeterPerm_midIdx hodd).symm
    simp only [coxeterPerm_symm_zero (le_refl 3), hmid]
    rw [t2, tμ, hl]; simp

end CFSGCorollary.TwistedA
