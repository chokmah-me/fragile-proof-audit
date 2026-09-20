/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import FragileProofAudit.Lame.CyclotomicIdeal
import Mathlib.NumberTheory.NumberField.Cyclotomic.Ideal

/-!
# Lamé 1847 — norm of primes above `2` in `𝓞(ℚ(ζ₂₃))`

Track A, next milestone after `embedToRingOfIntegers` (`CyclotomicIdeal.lean`): before
attempting to push `P2 = (2, θ)` forward and argue non-principality there, pin down what
the target norm even has to be.

`ord₂ mod 23 = 11` (`2^11 = 2048 ≡ 1 mod 23`, and no smaller exponent works since
`11 = (23-1)/2` is prime and `2` is not itself `≡ 1`), so mathlib's
`IsCyclotomicExtension.Rat.inertiaDeg_eq_of_not_dvd` gives inertia degree `11` for any
prime of `𝓞(ζ₂₃)` lying over `(2)`, hence absolute norm `2^11 = 2048` — **not** `2`.

This confirms in Lean the informal note in `docs/WORKPLAN.md`: pushing `P2` (absNorm `2`)
forward via `embedToRingOfIntegers` cannot land on an ideal of the same norm, because
`𝓞(ℚ(ζ₂₃))` has degree `22` over `ℚ`, not `2`. Whatever `Ideal.map embedToRingOfIntegers P2`
turns out to be, either it fails to be prime (and factors as a product of norm-`2^11`
primes, only possible if it's a *power* of one), or it isn't the ideal that certifies
non-principality by norm alone.

Honest scope: this file only computes the norm invariant. It does **not** show
`Ideal.map embedToRingOfIntegers P2` is prime, does **not** identify it with a specific
prime above `(2)`, and does **not** conclude anything about its principality. That
identification needs the decomposition-group argument sketched in `docs/WORKPLAN.md`
(the order-`11` subgroup of `Gal(ℚ(ζ₂₃)/ℚ)` fixes exactly `L23`, so primes above `2` in
`ℚ(ζ₂₃)` sit over a *single* prime of `L23` — matching `P2`'s own norm-`2` residue field —
but formalizing that correspondence is future work).
-/

open Ideal NumberField
open FragileProofAudit.Lame.CyclotomicEmbed (Cyclotomic23 neZero_23 isCyclotomic23)

namespace FragileProofAudit.Lame.CyclotomicPrimeTwo

local notation3 "𝒑₂" => (span {((2 : ℕ) : ℤ)})

instance fact_prime_two : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
instance fact_prime_eleven : Fact (Nat.Prime 11) := ⟨by norm_num⟩

/-- `2^11 = 2048 = 89·23 + 1`, so `2^11 = 1` in `ZMod 23`. -/
theorem two_pow_eleven_zmod23 : (2 : ZMod 23) ^ 11 = 1 := by decide

theorem two_ne_one_zmod23 : (2 : ZMod 23) ≠ 1 := by decide

/-- `2` has order `11` in `ZMod 23`: `11` is prime and `2^11 = 1 ≠ 2^1`. -/
theorem orderOf_two_zmod23 : orderOf (2 : ZMod 23) = 11 :=
  orderOf_eq_prime two_pow_eleven_zmod23 two_ne_one_zmod23

/-- `2` does not divide `23`. -/
theorem two_not_dvd_23 : ¬ (2 : ℕ) ∣ 23 := by decide

variable (P : Ideal (𝓞 Cyclotomic23)) [hP : P.IsPrime] [hPp : P.LiesOver 𝒑₂]

/-- Inertia degree of any prime of `𝓞(ℚ(ζ₂₃))` lying over `(2)` is `11`. -/
theorem inertiaDeg_eq_eleven : Ideal.inertiaDeg P ℤ = 11 := by
  rw [IsCyclotomicExtension.Rat.inertiaDeg_eq_of_not_dvd 2 Cyclotomic23 P two_not_dvd_23]
  exact orderOf_two_zmod23

instance p2_isMaximal : 𝒑₂.IsMaximal := Int.ideal_span_isMaximal_of_prime 2

instance P_isMaximal : P.IsMaximal := Ideal.IsMaximal.of_liesOver_isMaximal P 𝒑₂

theorem inertiaDegPrime_eq_eleven : 𝒑₂.inertiaDeg' P = 11 := by
  rw [Ideal.inertiaDeg'_eq_inertiaDeg 𝒑₂ P]
  exact inertiaDeg_eq_eleven P

/-- **Headline fact.** Any prime of `𝓞(ℚ(ζ₂₃))` lying over the rational prime `2` has
absolute norm `2^11 = 2048`, not `2`. -/
theorem absNorm_eq_two_pow_eleven : Ideal.absNorm P = 2 ^ 11 := by
  rw [Ideal.absNorm_eq_pow_inertiaDeg' P Nat.prime_two, inertiaDegPrime_eq_eleven P]

end FragileProofAudit.Lame.CyclotomicPrimeTwo
