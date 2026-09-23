/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Private campaign artifact. Gates refute routes, not theorems.
-/

import Mathlib.NumberTheory.ArithmeticFunction.Liouville

/-!
# Liouville bridge

Mathlib's Liouville function `λ` and the summatory `L`, plus the key
bridge identity: `Ω n` equals the number of prime-power divisors of `n`.
The sieve slice (`SieveCheck`) computes that count from a pinned literal
list and proves it equal to `Ω n` on its range; this file supplies the
`Ω`-side identity it needs.
-/

namespace FragileProofAudit.Polya

open ArithmeticFunction

/-- The summatory Liouville function `L(n) = ∑_{k=1}^n λ(k)`. -/
def L : ℕ → ℤ := fun n => ∑ k ∈ Finset.Icc 1 n, liouville k

theorem liouville_prime_pow {p k : ℕ} (hp : p.Prime) :
    liouville (p ^ k) = (-1 : ℤ) ^ k := by
  rw [liouville_apply (pow_ne_zero k hp.ne_zero), cardFactors_apply_prime_pow hp]

theorem liouville_prime {p : ℕ} (hp : p.Prime) : liouville p = -1 := by
  rw [liouville_apply hp.ne_zero, cardFactors_apply_prime hp, pow_one]

/-- `Ω n` counts prime-power divisors: each prime `p ∣ n` contributes
`v_p(n)` distinct prime powers `p^1, …, p^{v_p(n)}`. -/
theorem cardFactors_eq_primePowCard {n : ℕ} (hn : n ≠ 0) :
    cardFactors n
      = ((Finset.Icc 1 n).filter (fun q => IsPrimePow q ∧ q ∣ n)).card := by
  have h1 : cardFactors n = ∑ p ∈ n.primeFactors, n.factorization p := by
    rw [cardFactors_eq_sum_factorization,
      show n.factorization.sum (fun _ k => k)
        = ∑ p ∈ n.factorization.support, n.factorization p from rfl,
      Nat.support_factorization]
  -- Pair set: `(p, k)` with `p` a prime factor of `n`, `1 ≤ k ≤ v_p(n)`.
  set S : Finset (ℕ × ℕ) :=
    n.primeFactors.biUnion fun p =>
      (Finset.Icc 1 (n.factorization p)).image fun k => (p, k) with hS
  have hdisj : (↑n.primeFactors : Set ℕ).PairwiseDisjoint
      fun p => (Finset.Icc 1 (n.factorization p)).image fun k => (p, k) := by
    intro p₁ hp₁ p₂ hp₂ hne
    simp only [Function.onFun]
    rw [Finset.disjoint_left]
    rintro ⟨a, b⟩ ha hb
    simp only [Finset.mem_image, Finset.mem_Icc] at ha hb
    obtain ⟨k₁, -, h1⟩ := ha
    obtain ⟨k₂, -, h2⟩ := hb
    exact hne ((Prod.mk.inj h1).1.trans (Prod.mk.inj h2).1.symm)
  have hcard : S.card = cardFactors n := by
    rw [h1, hS, Finset.card_biUnion hdisj]
    refine Finset.sum_congr rfl fun p _ => ?_
    rw [Finset.card_image_of_injective _ ?_, Nat.card_Icc]
    · omega
    · intro a b hab
      exact (Prod.mk.inj hab).2
  have himage : S.image (fun pk => pk.1 ^ pk.2)
      = (Finset.Icc 1 n).filter (fun q => IsPrimePow q ∧ q ∣ n) := by
    ext q
    simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_Icc]
    constructor
    · rintro ⟨⟨p, k⟩, hmem, rfl⟩
      rw [hS, Finset.mem_biUnion] at hmem
      obtain ⟨a, hamem, hkmem⟩ := hmem
      obtain ⟨k', hkmem', hpk⟩ := Finset.mem_image.mp hkmem
      rw [Finset.mem_Icc] at hkmem'
      obtain ⟨hap, hkk⟩ := Prod.mk.inj hpk
      rw [hap] at hamem hkmem'
      rw [hkk] at hkmem'
      have hpprime : p.Prime := (Nat.mem_primeFactors.mp hamem).1
      have hppow_dvd : p ^ k ∣ n :=
        (hpprime.pow_dvd_iff_le_factorization hn).mpr hkmem'.2
      exact ⟨⟨one_le_pow₀ hpprime.one_le,
          Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hppow_dvd⟩,
        isPrimePow_nat_iff _ |>.mpr ⟨p, k, hpprime, by omega, rfl⟩, hppow_dvd⟩
    · rintro ⟨⟨hq1, hqn⟩, hqpp, hqdvd⟩
      obtain ⟨p, k, hpprime, hkpos, rfl⟩ := isPrimePow_nat_iff _ |>.mp hqpp
      have hpmem : p ∈ n.primeFactors := by
        rw [Nat.mem_primeFactors]
        exact ⟨hpprime, dvd_trans (dvd_pow_self p hkpos.ne') hqdvd, hn⟩
      have hkle : k ≤ n.factorization p :=
        (hpprime.pow_dvd_iff_le_factorization hn).mp hqdvd
      refine ⟨(p, k), ?_, rfl⟩
      rw [hS, Finset.mem_biUnion]
      exact ⟨p, hpmem,
        Finset.mem_image.mpr ⟨k, Finset.mem_Icc.mpr ⟨hkpos, hkle⟩, rfl⟩⟩
  have hinj : Set.InjOn (fun pk : ℕ × ℕ => pk.1 ^ pk.2) ↑S := by
    intro ⟨p₁, k₁⟩ h1 ⟨p₂, k₂⟩ h2 heq
    have heq' : p₁ ^ k₁ = p₂ ^ k₂ := heq
    rw [Finset.mem_coe, hS, Finset.mem_biUnion] at h1 h2
    obtain ⟨a, hamem, hkmem⟩ := h1
    obtain ⟨k', hkmem', hpk⟩ := Finset.mem_image.mp hkmem
    rw [Finset.mem_Icc] at hkmem'
    obtain ⟨hap, hkk⟩ := Prod.mk.inj hpk
    rw [hap] at hamem hkmem'
    rw [hkk] at hkmem'
    obtain ⟨b, hbmem, hkmem2⟩ := h2
    obtain ⟨j', hkmem2', hpj⟩ := Finset.mem_image.mp hkmem2
    rw [Finset.mem_Icc] at hkmem2'
    obtain ⟨hbp, hjk⟩ := Prod.mk.inj hpj
    rw [hbp] at hbmem hkmem2'
    rw [hjk] at hkmem2'
    have hp1 : p₁.Prime := (Nat.mem_primeFactors.mp hamem).1
    have hp2 : p₂.Prime := (Nat.mem_primeFactors.mp hbmem).1
    -- Same prime: `minFac` of both sides.
    have hmin : p₁ = p₂ := by
      have e1 := hp1.pow_minFac (by omega : k₁ ≠ 0)
      have e2 := hp2.pow_minFac (by omega : k₂ ≠ 0)
      exact (e2.symm.trans (heq' ▸ e1)).symm
    -- Same exponent: injectivity of `p ^ ·`.
    have hexp : k₁ = k₂ := by
      have h1k : p₁ ^ k₁ = p₁ ^ k₂ := heq'.trans (by rw [hmin])
      exact Nat.pow_right_injective hp1.two_le h1k
    exact Prod.ext hmin hexp
  rw [← himage, Finset.card_image_of_injOn hinj, hcard]

end FragileProofAudit.Polya
