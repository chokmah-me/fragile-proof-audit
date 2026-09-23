/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Private campaign artifact. Gates refute routes, not theorems.
-/

import FragileProofAudit.Polya.Liouville
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.NormNum

/-!
# Formally checked Pólya sieve slice

A kernel-checked computation of the summatory Liouville function `L`
on `n ≤ 100`, proved equal to mathlib's `ArithmeticFunction.liouville`
on that range.

Why a "slice": mathlib's `liouville` factors via `Nat.minFac`, whose
well-founded recursion does not reduce in the kernel, so `decide` cannot
evaluate it directly. Instead we count prime-power divisors from a
pinned literal table (`ppLit`), prove the count equals `Ω n`
(`omegaSieve_eq_cardFactors`, via `cardFactors_eq_primePowCard`), and
kernel-check `L(n) ≤ 0` for `2 ≤ n ≤ 100` plus the anchor `L(100) = -2`.

This is a checked sieve slice, not a Lean proof of anything about the
full `906150257` prefix.
-/

set_option maxRecDepth 4096

namespace FragileProofAudit.Polya.SieveCheck

open ArithmeticFunction

/-- Pinned list of all primes `≤ 100`. Correctness: `primesLE_correct`. -/
def primesLE : List ℕ :=
  [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
   53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

theorem primesLE_correct : ∀ p ∈ Finset.Icc 2 100, (p.Prime ↔ p ∈ primesLE) := by
  decide

/-- Literal table of all prime powers `≤ 100` (35 entries). -/
def ppLit : Finset ℕ :=
  {2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31, 32, 37,
   41, 43, 47, 49, 53, 59, 61, 64, 67, 71, 73, 79, 81, 83, 89, 97}

/-- Every entry of `ppLit` is a prime power (explicit witnesses). -/
theorem ppLit_isPrimePow : ∀ q ∈ ppLit, IsPrimePow q := by
  intro q hq
  simp only [ppLit] at hq
  fin_cases hq <;>
    first
      | exact Nat.Prime.isPrimePow (by decide)
      | exact isPrimePow_nat_iff _ |>.mpr ⟨2, 2, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨2, 3, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨3, 2, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨2, 4, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨5, 2, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨3, 3, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨2, 5, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨7, 2, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨2, 6, by decide, by decide, by decide⟩
      | exact isPrimePow_nat_iff _ |>.mpr ⟨3, 4, by decide, by decide, by decide⟩

/-- Sieve count of prime-power divisors: the Lean-side "sieve". -/
def omegaSieve (n : ℕ) : ℕ := (ppLit.filter (fun q => q ∣ n)).card

/-- The sieve count agrees with `Ω` on `1 ≤ n ≤ 100`. -/
theorem omegaSieve_eq_cardFactors {n : ℕ} (hn1 : 1 ≤ n) (hn100 : n ≤ 100) :
    omegaSieve n = cardFactors n := by
  rw [cardFactors_eq_primePowCard (by omega : n ≠ 0)]
  unfold omegaSieve
  congr 1
  apply Finset.ext
  intro q
  simp only [Finset.mem_filter, Finset.mem_Icc]
  constructor
  · rintro ⟨hqmem, hqdvd⟩
    have hqpp := ppLit_isPrimePow q hqmem
    exact ⟨⟨by have h2 := IsPrimePow.two_le hqpp; omega,
      Nat.le_of_dvd (by omega) hqdvd⟩, hqpp, hqdvd⟩
  · rintro ⟨⟨hq1, hqn⟩, hqpp, hqdvd⟩
    obtain ⟨p, k, hpprime, hkpos, rfl⟩ := isPrimePow_nat_iff _ |>.mp hqpp
    have hpk100 : p ^ k ≤ 100 :=
      le_trans (Nat.le_of_dvd (by omega) hqdvd) hn100
    have hp100 : p ≤ 100 := by
      have h1 : p ≤ p ^ k :=
        Nat.le_of_dvd (pow_pos hpprime.pos k) (dvd_pow_self p hkpos.ne')
      omega
    -- `2^7 = 128 > 100 ≥ p^k` forces `k ≤ 6`.
    have hk6 : k ≤ 6 := by
      by_contra h
      have h7 : 7 ≤ k := by omega
      have h27 : (2:ℕ)^7 ≤ p^7 := Nat.pow_le_pow_left hpprime.two_le 7
      have h7k : p^7 ≤ p^k := Nat.pow_le_pow_right hpprime.one_le h7
      have h128 : (128:ℕ) ≤ 100 :=
        calc (128:ℕ) = 2^7 := by norm_num
        _ ≤ p^7 := h27
        _ ≤ p^k := h7k
        _ ≤ 100 := hpk100
      norm_num at h128
    have hk1 : 1 ≤ k := hkpos
    refine ⟨?_, hqdvd⟩
    -- Enumerate `2 ≤ p ≤ 100` (non-primes are discharged by `hpprime`),
    -- then `1 ≤ k ≤ 6`; each `p^k ∈ ppLit` is decidable, and impossible
    -- pairs contradict `p^k ≤ 100`.
    have hp2 : 2 ≤ p := hpprime.two_le
    interval_cases p <;>
      first
        | (exfalso; exact absurd hpprime (by decide))
        | (interval_cases k <;>
            first
              | decide
              | (exfalso; exact absurd hpk100 (by decide)))

/-- Sieve Liouville value: `(-1)^Ω(n)` computed from the pinned table. -/
def lambdaSieve (n : ℕ) : ℤ := if n = 0 then 0 else (-1) ^ omegaSieve n

theorem lambdaSieve_eq_liouville {n : ℕ} (hn1 : 1 ≤ n) (hn100 : n ≤ 100) :
    lambdaSieve n = liouville n := by
  unfold lambdaSieve
  rw [if_neg (by omega : n ≠ 0), liouville_apply (by omega : n ≠ 0),
    omegaSieve_eq_cardFactors hn1 hn100]

/-- Sieve summatory: kernel-computable twin of `L` on `n ≤ 100`. -/
def Lck (n : ℕ) : ℤ := ∑ k ∈ Finset.Icc 1 n, lambdaSieve k

theorem Lck_eq_L {n : ℕ} (hn : n ≤ 100) : Lck n = L n := by
  unfold Lck L
  refine Finset.sum_congr rfl fun k hk => ?_
  rw [Finset.mem_Icc] at hk
  exact lambdaSieve_eq_liouville hk.1 (le_trans hk.2 hn)

/-- Kernel-checked anchor: `L(100) = -2` (matches the sieve selftest). -/
theorem check_L100 : Lck 100 = -2 := by decide

/-- Kernel-checked: Pólya's conjecture holds on `2 ≤ n ≤ 100`. -/
theorem check_polya_range : ∀ n ∈ Finset.Icc 2 100, Lck n ≤ 0 := by decide

/-- The checked range, stated for the real `L`. -/
theorem polya_holds_to_100 : ∀ n ∈ Finset.Icc 2 100, L n ≤ 0 := by
  intro n hn
  rw [Finset.mem_Icc] at hn
  rw [← Lck_eq_L (by omega : n ≤ 100)]
  exact check_polya_range n (Finset.mem_Icc.mpr hn)

end FragileProofAudit.Polya.SieveCheck
