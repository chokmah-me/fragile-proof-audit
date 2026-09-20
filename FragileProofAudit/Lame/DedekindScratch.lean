/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Int.GCD
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.IntervalCases
import Mathlib.RingTheory.Coprime.Basic
import Mathlib.RingTheory.Coprime.Lemmas

/-!
# Disc −23 forces integrality of coordinates

Elementary core of "disc(θ) = −23 squarefree ⇒ ℤ[θ] = O_K" for K = ℚ(√−23):
if `2p+q` and `p²+pq+6q²` are both integers for `p q : ℚ`, then `p, q ∈ ℤ`.
-/

/-- Core arithmetic step: if `2p+q` and `p²+pq+6q²` are both (rational
values of) integers, for `p q : ℚ`, then `p` and `q` are themselves
integers. This is the disc = -23 squarefree fact, made elementary. -/
theorem disc_neg23_forces_integers (p q : ℚ) (u t : ℤ)
    (hu : (u : ℚ) = 2 * p + q) (ht : (t : ℚ) = p ^ 2 + p * q + 6 * q ^ 2) :
    ∃ a b : ℤ, (a : ℚ) = p ∧ (b : ℚ) = q := by
  -- Step 1: 23 q² = 4t − u² as integers, via witness n.
  set n : ℤ := 4 * t - u ^ 2 with hn_def
  have hn : (23 : ℚ) * q ^ 2 = (n : ℚ) := by
    have : (n : ℚ) = 4 * (t : ℚ) - (u : ℚ) ^ 2 := by rw [hn_def]; push_cast; ring
    rw [this, ht, hu]; ring
  -- Step 2: q must be an integer, since 23 is prime.
  have hnum : (23 : ℤ) * q.num ^ 2 = n * (q.den : ℤ) ^ 2 := by
    have hden0 : (q.den : ℚ) ≠ 0 := by exact_mod_cast q.den_nz
    have hqe : (q.num : ℚ) = q * (q.den : ℚ) := by
      have h : (q.num : ℚ) / (q.den : ℚ) = q := Rat.num_div_den q
      field_simp at h
      linarith [h]
    have key : (23 : ℚ) * (q.num : ℚ) ^ 2 = (n : ℚ) * (q.den : ℚ) ^ 2 := by
      rw [hqe]
      have expand : (23 : ℚ) * (q * (q.den : ℚ)) ^ 2 = (23 * q ^ 2) * (q.den : ℚ) ^ 2 := by ring
      rw [expand, hn]
    exact_mod_cast key
  have hcop : IsCoprime q.num (q.den : ℤ) := Rat.isCoprime_num_den q
  have hcop2 : IsCoprime ((q.den : ℤ) ^ 2) (q.num ^ 2) := IsCoprime.pow hcop.symm
  have hdvd : (q.den : ℤ) ^ 2 ∣ 23 * q.num ^ 2 := ⟨n, by linarith [hnum]⟩
  have hdvd23 : (q.den : ℤ) ^ 2 ∣ 23 :=
    (IsCoprime.dvd_of_dvd_mul_right hcop2 hdvd)
  have hden_pos : 0 < (q.den : ℤ) := by exact_mod_cast q.pos
  have hden1 : (q.den : ℤ) = 1 := by
    have hle : (q.den : ℤ) ^ 2 ≤ 23 := Int.le_of_dvd (by norm_num) hdvd23
    have hle' : q.den ≤ 4 := by nlinarith [hden_pos]
    interval_cases h : q.den <;> simp_all
  have hq_den1 : q.den = 1 := by exact_mod_cast hden1
  -- b := q.num is our integer witness for q.
  have hbq : (q.num : ℚ) = q := by
    have h := Rat.num_div_den q
    rw [hq_den1] at h
    simpa using h
  -- Step 3: c := u − q.num is even, giving the integer witness for p.
  set c : ℤ := u - q.num with hc_def
  have hc_rat : (c : ℚ) = 2 * p := by
    rw [hc_def]; push_cast; rw [hu, hbq]; ring
  have h4t : 4 * t = c ^ 2 + 2 * c * q.num + 24 * q.num ^ 2 := by
    have key : (4 * t : ℚ) = (c : ℚ) ^ 2 + 2 * (c : ℚ) * (q.num : ℚ) + 24 * (q.num : ℚ) ^ 2 := by
      rw [hc_rat, hbq, ht]; ring
    exact_mod_cast key
  have hc_even : Even c := by
    have hc2 : c ^ 2 = 4 * (t - 6 * q.num ^ 2) - 2 * c * q.num := by linarith [h4t]
    have : Even (c ^ 2) := ⟨2 * (t - 6 * q.num ^ 2) - c * q.num, by linarith [hc2]⟩
    exact (Int.even_pow' (by norm_num)).mp this
  obtain ⟨p', hp'⟩ := hc_even
  have hpp : (p' : ℚ) = p := by
    have : (c : ℚ) = 2 * (p' : ℚ) := by rw [hp']; push_cast; ring
    have h2 : (2 : ℚ) * (p' : ℚ) = 2 * p := this ▸ hc_rat
    linarith [mul_left_cancel₀ (by norm_num : (2:ℚ) ≠ 0) h2]
  exact ⟨p', q.num, hpp, hbq⟩
