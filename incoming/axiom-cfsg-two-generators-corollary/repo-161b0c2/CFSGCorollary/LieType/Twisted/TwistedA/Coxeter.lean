module

public import CFSGCorollary.LieType.Twisted.TwistedA.Index

/-!
# The twisted Coxeter element of `SU`

For the special unitary group `SU σ n` of the antidiagonal Hermitian form, the twisted Coxeter
element `coxeterElement` is the product `levelWeyl 0 ⋯ levelWeyl (n / 2 - 1)` of the level Weyl
elements. Its matrix is a signed permutation matrix for the permutation `coxeterPerm n` of
`Fin n`, which commutes with `Fin.rev`, sends `j ↦ j + 1` for `j + 1 < n / 2` and
`n / 2 - 1 ↦ rev 0`, and fixes the middle index when `n` is odd. We compute the orbit of `0`.

## Main results

* `TwistedA.exists_coe_coxeterElement_eq_signedPerm`: the matrix of `coxeterElement` is a signed
  permutation matrix for `coxeterPerm n`.
* `TwistedA.coxeterPerm_pow_half`: `coxeterPerm n ^ (n / 2) = Fin.rev`.
* `TwistedA.coxeterPerm_pow_zero_of_lt`, `TwistedA.coxeterPerm_pow_zero_of_ge`: the orbit of `0`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedA

open CFSG.LieType.Universal.Unitary CFSG.LieType.Universal.SpecialLinear

variable {F : Type*} [Field F] {σ : F ≃+* F} {n : ℕ}

/-- The permutation `levelPerm 0 * ⋯ * levelPerm (n / 2 - 1)` of the twisted Coxeter element. -/
def coxeterPerm (n : ℕ) : Equiv.Perm (Fin n) :=
  ((List.finRange (n / 2)).map levelPerm).prod

/-- The twisted Coxeter element `levelWeyl 0 ⋯ levelWeyl (n / 2 - 1)`. -/
noncomputable def coxeterElement (hσ : ∀ c : F, σ (σ c) = c)
    (ζ : traceZero σ) (n : ℕ) : SU σ n :=
  ((List.finRange (n / 2)).map (levelWeyl hσ ζ)).prod

private theorem levelPerm_val_low (k : Fin (n / 2)) (s : Fin n) (hs : s.val < n / 2) :
    (levelPerm k s).val =
      if k.val + 1 < n / 2 then
        (if s.val = k.val then k.val + 1 else if s.val = k.val + 1 then k.val else s.val)
      else (if s.val = k.val then n - 1 - k.val else s.val) := by
  have a1 : s.val ≠ n - (k.val + 1) := by have := k.isLt; omega
  have a2 : k.val + 1 < n / 2 → s.val ≠ n - (k.val + 1 + 1) := by have := k.isLt; omega
  unfold levelPerm
  by_cases h : k.val + 1 < n / 2
  · simp only [h, dite_true, ite_true, Equiv.Perm.mul_apply, val_swap_apply, Fin.val_rev,
      val_lowIdx, a1, a2 h, ite_false]
  · simp only [h, dite_false, ite_false, val_swap_apply, Fin.val_rev, val_lowIdx, a1]
    split_ifs <;> omega

private theorem levelPerm_mid (k : Fin (n / 2)) (s : Fin n) (hs : s.val = n / 2)
    (hn : n % 2 = 1) :
    levelPerm k s = s := by
  apply Fin.ext
  have a1 : s.val ≠ n - (k.val + 1) := by have := k.isLt; omega
  have a2 : k.val + 1 < n / 2 → s.val ≠ n - (k.val + 1 + 1) := by have := k.isLt; omega
  have a3 : s.val ≠ k.val := by have := k.isLt; omega
  have a4 : k.val + 1 < n / 2 → s.val ≠ k.val + 1 := by have := k.isLt; omega
  unfold levelPerm
  by_cases h : k.val + 1 < n / 2
  · simp only [h, dite_true, Equiv.Perm.mul_apply, val_swap_apply, Fin.val_rev,
      val_lowIdx, a1, a2 h, a3, a4 h, ite_false]
  · simp only [h, dite_false, val_swap_apply, Fin.val_rev, val_lowIdx, a1, a3, ite_false]

/-- Partial products `levelPerm 0 * ⋯ * levelPerm (k - 1)`. -/
def partialCoxeterPerm (n k : ℕ) : Equiv.Perm (Fin n) :=
  ((List.range k).map fun j ↦ if h : j < n / 2 then levelPerm ⟨j, h⟩ else 1).prod

private theorem partialCoxeterPerm_succ (k : ℕ) (hk : k < n / 2) :
    partialCoxeterPerm n (k + 1) = partialCoxeterPerm n k * levelPerm ⟨k, hk⟩ := by
  simp [partialCoxeterPerm, List.range_succ, hk]

private theorem coxeterPerm_eq_partialCoxeterPerm (n : ℕ) :
    coxeterPerm n = partialCoxeterPerm n (n / 2) := by
  unfold coxeterPerm partialCoxeterPerm
  congr 1
  apply List.ext_getElem
  · simp
  · intro i h1 h2
    simp at h1
    simp [h1]

private theorem partialCoxeterPerm_rev (k : ℕ) (s : Fin n) :
    partialCoxeterPerm n k (Fin.rev s) = Fin.rev (partialCoxeterPerm n k s) := by
  induction k generalizing s with
  | zero => simp [partialCoxeterPerm]
  | succ k ih =>
    have : partialCoxeterPerm n (k + 1) = partialCoxeterPerm n k * (if h : k < n / 2 then
        levelPerm ⟨k, h⟩ else 1) := by
      simp [partialCoxeterPerm, List.range_succ]
    rw [this]
    simp only [Equiv.Perm.mul_apply]
    split_ifs with h
    · rw [levelPerm_rev, ih]
    · simp [ih]

private theorem partialCoxeterPerm_mid (k : ℕ) (hn : n % 2 = 1) (s : Fin n)
    (hs : s.val = n / 2) :
    partialCoxeterPerm n k s = s := by
  induction k with
  | zero => simp [partialCoxeterPerm]
  | succ k ih =>
    have : partialCoxeterPerm n (k + 1) = partialCoxeterPerm n k * (if h : k < n / 2 then
        levelPerm ⟨k, h⟩ else 1) := by
      simp [partialCoxeterPerm, List.range_succ]
    rw [this]
    simp only [Equiv.Perm.mul_apply]
    split_ifs with h
    · rw [levelPerm_mid _ _ hs hn, ih]
    · simp [ih]

private theorem partialCoxeterPerm_low (k : ℕ) (hk : k < n / 2) (s : Fin n)
    (hs : s.val < n / 2) :
    (partialCoxeterPerm n k s).val =
      if s.val < k then s.val + 1 else if s.val = k then 0 else s.val := by
  induction k generalizing s with
  | zero => simp [partialCoxeterPerm]
  | succ k ih =>
    rw [partialCoxeterPerm_succ k (by omega), Equiv.Perm.mul_apply]
    have h1 := levelPerm_val_low ⟨k, by omega⟩ s hs
    simp only [show k + 1 < n / 2 from hk, ite_true] at h1
    have h2 : (levelPerm (⟨k, by omega⟩ : Fin (n/2)) s).val < n / 2 := by
      rw [h1]; split_ifs <;> omega
    rw [ih (by omega) _ h2, h1]
    split_ifs <;> omega

private theorem exists_prod_signedPerm_eq (l : List (Fin (n / 2)))
    (sg : Fin (n / 2) → Fin n → F) :
    ∃ ε : Fin n → F,
      (l.map fun k ↦ signedPerm (levelPerm k) (sg k)).prod =
        signedPerm (l.map levelPerm).prod ε := by
  induction l with
  | nil =>
    refine ⟨fun _ ↦ 1, ?_⟩
    simp [signedPerm_one]
  | cons a l ih =>
    obtain ⟨ε, hε⟩ := ih
    refine ⟨fun s ↦ sg a ((l.map levelPerm).prod s) * ε s, ?_⟩
    simp only [List.map_cons, List.prod_cons, hε, signedPerm_mul_signedPerm]

/-- The matrix of the Coxeter element is a signed permutation matrix for `coxeterPerm`. -/
theorem exists_coe_coxeterElement_eq_signedPerm (hσ : ∀ c : F, σ (σ c) = c)
    {ζ : traceZero σ} (hζ : (ζ : F) ≠ 0) :
    ∃ ε : Fin n → F,
      (((coxeterElement hσ ζ n : SU σ n) : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) =
        signedPerm (coxeterPerm n) ε := by
  obtain ⟨ε, hε⟩ := exists_prod_signedPerm_eq (n := n) (F := F) (List.finRange (n / 2))
    (levelSign σ (ζ : F))
  exact ⟨ε, (coe_prod_levelWeyl hσ hζ _).trans hε⟩

private theorem coxeterPerm_val_low (hn : 3 ≤ n) (s : Fin n) (hs : s.val < n / 2) :
    (coxeterPerm n s).val = if s.val + 1 < n / 2 then s.val + 1 else n - 1 := by
  have e : n / 2 = (n / 2 - 1) + 1 := by omega
  rw [coxeterPerm_eq_partialCoxeterPerm]
  conv_lhs => rw [e]
  rw [partialCoxeterPerm_succ _ (by omega), Equiv.Perm.mul_apply]
  have h1 := levelPerm_val_low (⟨n / 2 - 1, by omega⟩ : Fin (n / 2)) s hs
  simp only [show ¬ (n / 2 - 1 + 1 < n / 2) by omega, ite_false] at h1
  by_cases hc : s.val = n / 2 - 1
  · have hs' : levelPerm (⟨n / 2 - 1, by omega⟩ : Fin (n / 2)) s =
        Fin.rev (lowIdx (⟨n / 2 - 1, by omega⟩ : Fin (n / 2))) := by
      apply Fin.ext
      rw [h1]; simp [Fin.val_rev, hc, val_lowIdx]
      omega
    rw [hs', partialCoxeterPerm_rev]
    have := partialCoxeterPerm_low (n / 2 - 1) (by omega)
      (lowIdx (⟨n / 2 - 1, by omega⟩ : Fin (n / 2))) (by simp [val_lowIdx]; omega)
    simp only [val_lowIdx, lt_irrefl, ite_false, ite_true] at this
    simp [Fin.val_rev, this]
    omega
  · have hs' : levelPerm (⟨n / 2 - 1, by omega⟩ : Fin (n / 2)) s = s := by
      apply Fin.ext
      rw [h1]; simp [hc]
    rw [hs', partialCoxeterPerm_low (n / 2 - 1) (by omega) s hs]
    split_ifs <;> omega

theorem coxeterPerm_lowIdx (hn : 3 ≤ n) (j : ℕ) (hj : j + 1 < n / 2) :
    coxeterPerm n (lowIdx ⟨j, by omega⟩) = lowIdx ⟨j + 1, hj⟩ := by
  apply Fin.ext
  rw [coxeterPerm_val_low hn _ (by simp [val_lowIdx]; omega)]
  simp [val_lowIdx, hj]

theorem coxeterPerm_lowIdx_last (hn : 3 ≤ n) :
    coxeterPerm n (lowIdx ⟨n / 2 - 1, by omega⟩) = Fin.rev (lowIdx ⟨0, by omega⟩) := by
  apply Fin.ext
  rw [coxeterPerm_val_low hn _ (by simp [val_lowIdx]; omega)]
  simp [val_lowIdx, Fin.val_rev]
  have : ¬ (n / 2 - 1 + 1 < n / 2) := by omega
  simp [this]

/-- `coxeterPerm n` commutes with `Fin.rev`. -/
theorem coxeterPerm_rev (s : Fin n) :
    coxeterPerm n (Fin.rev s) = Fin.rev (coxeterPerm n s) := by
  rw [coxeterPerm_eq_partialCoxeterPerm, partialCoxeterPerm_rev]

theorem coxeterPerm_rev_lowIdx_last (hn : 3 ≤ n) :
    coxeterPerm n (Fin.rev (lowIdx ⟨n / 2 - 1, by omega⟩)) = lowIdx ⟨0, by omega⟩ := by
  rw [coxeterPerm_rev, coxeterPerm_lowIdx_last hn, Fin.rev_rev]

theorem coxeterPerm_midIdx (hn : n % 2 = 1) :
    coxeterPerm n (midIdx hn) = midIdx hn := by
  rw [coxeterPerm_eq_partialCoxeterPerm]
  exact partialCoxeterPerm_mid _ hn _ rfl

/-- The powers of `coxeterPerm n` commute with `Fin.rev`. -/
theorem coxeterPerm_pow_rev (j : ℕ) (s : Fin n) :
    (coxeterPerm n ^ j) (Fin.rev s) = Fin.rev ((coxeterPerm n ^ j) s) := by
  induction j generalizing s with
  | zero => simp
  | succ j ih => rw [pow_succ, Equiv.Perm.mul_apply, Equiv.Perm.mul_apply, coxeterPerm_rev, ih]

/-- The orbit of `0`: `π ^ j 0 = j` for `j < n / 2`. -/
theorem coxeterPerm_pow_zero_of_lt (hn : 3 ≤ n) (j : ℕ) (hj : j < n / 2) :
    (coxeterPerm n ^ j) (lowIdx ⟨0, by omega⟩) = lowIdx ⟨j, hj⟩ := by
  induction j with
  | zero => simp
  | succ j ih =>
    rw [pow_succ', Equiv.Perm.mul_apply, ih (by omega), coxeterPerm_lowIdx hn j hj]

private theorem coxeterPerm_pow_lowIdx (hn : 3 ≤ n) (a : ℕ) (ha : a < n / 2) (i : ℕ)
    (hi : a + i < n / 2) :
    (coxeterPerm n ^ i) (lowIdx ⟨a, ha⟩) = lowIdx ⟨a + i, hi⟩ := by
  induction i with
  | zero => simp
  | succ i ih =>
    rw [pow_succ', Equiv.Perm.mul_apply, ih (by omega), coxeterPerm_lowIdx hn (a + i) (by omega)]
    rfl

/-- `coxeterPerm n ^ (n / 2)` is the reversal `Fin.rev`. -/
theorem coxeterPerm_pow_half (s : Fin n) : (coxeterPerm n ^ (n / 2)) s = Fin.rev s := by
  by_cases hn : 3 ≤ n
  · by_cases hs : s = Fin.rev s
    · have hn2 : n % 2 = 1 := by
        have := congrArg Fin.val hs
        simp [Fin.val_rev] at this
        omega
      have : s = midIdx hn2 := Fin.ext (by
        have := congrArg Fin.val hs
        simp [Fin.val_rev, midIdx] at this ⊢
        omega)
      subst this
      rw [rev_midIdx]
      have : ∀ j : ℕ, (coxeterPerm n ^ j) (midIdx hn2) = midIdx hn2 := by
        intro j
        induction j with
        | zero => simp
        | succ j ih => rw [pow_succ', Equiv.Perm.mul_apply, ih, coxeterPerm_midIdx hn2]
      exact this _
    · have hex : ∀ t : Fin n, t ≠ Fin.rev t → ∀ a : Fin (n / 2), t = lowIdx a →
          (coxeterPerm n ^ (n / 2)) t = Fin.rev t := by
        intro t _ a ha
        subst ha
        obtain ⟨a, ha⟩ := a
        have h1 : (coxeterPerm n ^ (n / 2 - a)) (lowIdx ⟨a, ha⟩) =
            Fin.rev (lowIdx ⟨0, by omega⟩) := by
          have e : n / 2 - a = (n / 2 - a - 1) + 1 := by omega
          rw [e, pow_succ', Equiv.Perm.mul_apply, coxeterPerm_pow_lowIdx hn a ha _ (by omega)]
          have e2 : a + (n / 2 - a - 1) = n / 2 - 1 := by omega
          have := coxeterPerm_lowIdx_last hn
          simp only [e2]
          exact this
        have h2 : n / 2 = a + (n / 2 - a) := by omega
        have h3 : coxeterPerm n ^ (n / 2) =
            coxeterPerm n ^ a * coxeterPerm n ^ (n / 2 - a) := by
          rw [← pow_add]; congr 1
        rw [h3, Equiv.Perm.mul_apply, h1, coxeterPerm_pow_rev,
          coxeterPerm_pow_zero_of_lt hn a ha]
      obtain ⟨a, ha⟩ := exists_lowIdx hs
      rcases ha with ha | ha
      · exact hex s hs a ha
      · have := hex (Fin.rev s) (by rw [Fin.rev_rev]; exact Ne.symm hs) a (by rw [ha, Fin.rev_rev])
        rw [coxeterPerm_pow_rev] at this
        have := congrArg Fin.rev this
        simpa using this
  · have : n = 0 ∨ n = 1 ∨ n = 2 := by omega
    rcases this with rfl | rfl | rfl
    · exact s.elim0
    · rw [show (1:ℕ) / 2 = 0 from rfl, pow_zero]; exact Subsingleton.elim _ _
    · fin_cases s <;> decide

theorem coxeterPerm_symm_zero (hn : 3 ≤ n) :
    (coxeterPerm n).symm (lowIdx ⟨0, by omega⟩) = Fin.rev (lowIdx ⟨n / 2 - 1, by omega⟩) := by
  rw [Equiv.symm_apply_eq]
  exact (coxeterPerm_rev_lowIdx_last hn).symm

theorem coxeterPerm_symm_one (hn : 4 ≤ n) :
    (coxeterPerm n).symm (lowIdx ⟨1, by omega⟩) = lowIdx ⟨0, by omega⟩ := by
  rw [Equiv.symm_apply_eq]
  exact (coxeterPerm_lowIdx (by omega) 0 (by omega)).symm

/-- The orbit of `0`: `π ^ j 0 = rev (j - n / 2)` for `n / 2 ≤ j < 2 * (n / 2)`. -/
theorem coxeterPerm_pow_zero_of_ge (hn : 3 ≤ n) (j : ℕ) (hj : n / 2 ≤ j)
    (hj' : j < 2 * (n / 2)) :
    (coxeterPerm n ^ j) (lowIdx ⟨0, by omega⟩) = Fin.rev (lowIdx ⟨j - n / 2, by omega⟩) := by
  have e : j = (j - n / 2) + n / 2 := by omega
  have h3 : coxeterPerm n ^ j = coxeterPerm n ^ (j - n / 2) * coxeterPerm n ^ (n / 2) := by
    rw [← pow_add]; congr 1
  rw [h3, Equiv.Perm.mul_apply, coxeterPerm_pow_half, coxeterPerm_pow_rev,
    coxeterPerm_pow_zero_of_lt hn _ (by omega)]

end CFSGCorollary.TwistedA
