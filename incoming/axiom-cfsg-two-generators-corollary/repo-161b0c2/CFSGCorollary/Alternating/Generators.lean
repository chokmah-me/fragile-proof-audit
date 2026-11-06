module

public import Mathlib.GroupTheory.SpecificGroups.Alternating

/-!
# Two generators of the alternating group

For `n ≥ 5` we define two even permutations `a_n, b_n` of `Fin n` which will be shown to generate
the alternating group `Aₙ`:

* for odd `n`, `a_n` is the 3-cycle `(0 2 1)` and `b_n` is the `n`-cycle `finRotate n`;
* for even `n`, `a_n` is the 3-cycle `(0 (n-1) 1)` and `b_n` is the `(n-1)`-cycle
  `Fin.cycleRange (n - 2)`, which fixes `n - 1`.

This file computes their action on the points that matter and shows that both are even.

## Main definitions

* `CFSGCorollary.alternatingGeneratorA`, `CFSGCorollary.alternatingGeneratorB`: the generators.
* `CFSGCorollary.alternatingBasePoint`: the point used in the primitivity argument.

## Main results

* `CFSGCorollary.alternatingGeneratorA_isThreeCycle`: `a_n` is an even 3-cycle.
* `CFSGCorollary.alternatingGeneratorB_mem_alternatingGroup`: `b_n` is even.
-/

@[expose] public section

namespace CFSGCorollary

/-- The first generator `a_n`: the 3-cycle `0 ↦ 2 ↦ 1 ↦ 0` for odd `n`, and
`0 ↦ n-1 ↦ 1 ↦ 0` for even `n`. -/
def alternatingGeneratorA (n : ℕ) [NeZero n] : Equiv.Perm (Fin n) :=
  if Odd n then Equiv.swap 0 (Fin.ofNat n 1) * Equiv.swap 0 (Fin.ofNat n 2)
  else Equiv.swap 0 (Fin.ofNat n 1) * Equiv.swap 0 (Fin.ofNat n (n - 1))

/-- The second generator `b_n`: `finRotate n` for odd `n`, and `Fin.cycleRange (n-2)` for
even `n`. -/
def alternatingGeneratorB (n : ℕ) [NeZero n] : Equiv.Perm (Fin n) :=
  if Odd n then finRotate n else Fin.cycleRange (Fin.ofNat n (n - 2))

/-- The base point `x₀`: `0` for odd `n`, `n-1` for even `n`. -/
def alternatingBasePoint (n : ℕ) [NeZero n] : Fin n :=
  if Odd n then 0 else Fin.ofNat n (n - 1)

theorem val_ofNat_of_lt (n : ℕ) [NeZero n] {k : ℕ} (hk : k < n) :
    (Fin.ofNat n k : Fin n).val = k := by
  rw [Fin.val_ofNat, Nat.mod_eq_of_lt hk]

/-- The action of `a_n` and the powers of `b_n` for odd `n`. -/
theorem alternatingGenerator_apply_of_odd (n : ℕ) [NeZero n] (h : 5 ≤ n) (hn : Odd n) :
    alternatingGeneratorA n 0 = Fin.ofNat n 2 ∧
      alternatingGeneratorA n (Fin.ofNat n 2) = Fin.ofNat n 1 ∧
      alternatingGeneratorA n (Fin.ofNat n 1) = 0 ∧
      (∀ x : Fin n, 3 ≤ x.val → alternatingGeneratorA n x = x) ∧
      ∀ k : ℕ, (alternatingGeneratorB n ^ k) 0 = Fin.ofNat n k := by
  have h1 : (Fin.ofNat n 1 : Fin n).val = 1 := val_ofNat_of_lt n (by omega)
  have h2 : (Fin.ofNat n 2 : Fin n).val = 2 := val_ofNat_of_lt n (by omega)
  have h0 : (0 : Fin n).val = 0 := rfl
  refine ⟨?_, ?_, ?_, fun x hx ↦ ?_, fun k ↦ ?_⟩
  pick_goal 5
  · simp only [alternatingGeneratorB, hn, ↓reduceIte]
    induction k with
    | zero => simp
    | succ k ih =>
      rw [pow_succ', Equiv.Perm.mul_apply, ih, finRotate_apply]
      apply Fin.ext
      simp [Fin.val_add, Nat.add_mod]
  all_goals
    simp only [alternatingGeneratorA, hn, ↓reduceIte, Equiv.Perm.mul_apply,
      Equiv.swap_apply_def, Fin.ext_iff, h0, h1, h2]
    split_ifs <;> first | contradiction | omega

/-- The action of `a_n` and `b_n` for even `n`. -/
theorem alternatingGenerator_apply_of_even (n : ℕ) [NeZero n] (h : 5 ≤ n) (hn : Even n) :
    alternatingGeneratorA n 0 = Fin.ofNat n (n - 1) ∧
      alternatingGeneratorA n (Fin.ofNat n (n - 1)) = Fin.ofNat n 1 ∧
      alternatingGeneratorA n (Fin.ofNat n 1) = 0 ∧
      (∀ x : Fin n, 2 ≤ x.val → x.val ≤ n - 2 → alternatingGeneratorA n x = x) ∧
      alternatingGeneratorB n (Fin.ofNat n (n - 1)) = Fin.ofNat n (n - 1) ∧
      ∀ k : ℕ, k ≤ n - 2 → (alternatingGeneratorB n ^ k) 0 = Fin.ofNat n k := by
  have hn' : ¬ Odd n := Nat.not_odd_iff_even.mpr hn
  have h1 : (Fin.ofNat n 1 : Fin n).val = 1 := val_ofNat_of_lt n (by omega)
  have h2 : (Fin.ofNat n (n - 1) : Fin n).val = n - 1 := val_ofNat_of_lt n (by omega)
  have h3 : (Fin.ofNat n (n - 2) : Fin n).val = n - 2 := val_ofNat_of_lt n (by omega)
  have h0 : (0 : Fin n).val = 0 := rfl
  refine ⟨?_, ?_, ?_, fun x hx hx' ↦ ?_, ?_, fun k hk ↦ ?_⟩
  pick_goal 5
  · simp only [alternatingGeneratorB, hn', ↓reduceIte]
    exact Fin.cycleRange_of_gt (by rw [Fin.lt_def, h2, h3]; omega)
  pick_goal 5
  · simp only [alternatingGeneratorB, hn', ↓reduceIte]
    induction k with
    | zero => simp
    | succ k ih =>
      rw [pow_succ', Equiv.Perm.mul_apply, ih (by omega),
        Fin.cycleRange_of_lt (by rw [Fin.lt_def, val_ofNat_of_lt n (by omega), h3]; omega)]
      apply Fin.ext
      simp [Fin.val_add, Nat.add_mod]
  all_goals
    simp only [alternatingGeneratorA, hn', ↓reduceIte, Equiv.Perm.mul_apply,
      Equiv.swap_apply_def, Fin.ext_iff, h0, h1, h2]
    split_ifs <;> first | contradiction | omega

/-- `a_n` is a 3-cycle, hence lies in the alternating group. -/
theorem alternatingGeneratorA_isThreeCycle (n : ℕ) [NeZero n] (h : 5 ≤ n) :
    (alternatingGeneratorA n).IsThreeCycle ∧
      alternatingGeneratorA n ∈ alternatingGroup (Fin n) := by
  have key (k : ℕ) (hk2 : 2 ≤ k) (hkn : k < n) :
      (Equiv.swap (0 : Fin n) (Fin.ofNat n 1) * Equiv.swap 0 (Fin.ofNat n k)).IsThreeCycle := by
    have h1 := val_ofNat_of_lt n (k := 1) (by omega)
    have h2 := val_ofNat_of_lt n hkn
    have h0 : (0 : Fin n).val = 0 := rfl
    refine Equiv.Perm.isThreeCycle_swap_mul_swap_same ?_ ?_ ?_ <;>
      exact fun e ↦ by have := congrArg Fin.val e; omega
  have hc : (alternatingGeneratorA n).IsThreeCycle := by
    unfold alternatingGeneratorA
    split_ifs
    · exact key 2 le_rfl (by omega)
    · exact key (n - 1) (by omega) (by omega)
  exact ⟨hc, Equiv.Perm.mem_alternatingGroup.mpr hc.sign⟩

/-- `b_n` is an even permutation. -/
theorem alternatingGeneratorB_mem_alternatingGroup (n : ℕ) [NeZero n] (h : 5 ≤ n) :
    alternatingGeneratorB n ∈ alternatingGroup (Fin n) := by
  rw [Equiv.Perm.mem_alternatingGroup]
  unfold alternatingGeneratorB
  split_ifs with hn
  · rw [sign_finRotate]
    exact Even.neg_one_pow (by obtain ⟨m, rfl⟩ := hn; exact ⟨m, by omega⟩)
  · rw [Fin.sign_cycleRange, Fin.val_ofNat, Nat.mod_eq_of_lt (by omega)]
    obtain ⟨m, hm⟩ := Nat.not_odd_iff_even.mp hn
    exact Even.neg_one_pow ⟨m - 1, by omega⟩

end CFSGCorollary
