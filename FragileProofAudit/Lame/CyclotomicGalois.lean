/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import FragileProofAudit.Lame.CyclotomicPrimeTwo
import Mathlib.NumberTheory.Cyclotomic.Gal
import Mathlib.RingTheory.ZMod.UnitsCyclic

/-!
# Lamé 1847 — `Gal(ℚ(ζ₂₃)/ℚ)` is cyclic of order `22`

Track A, decomposition-group sub-step. Before attempting the full
decomposition-field identification (`docs/WORKPLAN.md`, 3(i)#+), pin down the
structure of the ambient Galois group.

* `Cyclotomic23 / ℚ` is Galois (`IsCyclotomicExtension.isGalois`).
* `Polynomial.cyclotomic 23 ℚ` is irreducible (`cyclotomic.irreducible_rat`), so
  `IsCyclotomicExtension.autEquivPow` gives a `MulEquiv`
  `Gal(Cyclotomic23/ℚ) ≃* (ZMod 23)ˣ`.
* `(ZMod 23)ˣ` is cyclic (`ZMod.isCyclic_units_prime`, `23` prime), and cyclicity
  transports along a `MulEquiv`, so `Gal(Cyclotomic23/ℚ)` is cyclic.
* `Nat.card Gal(Cyclotomic23/ℚ) = 22` via `Nat.card (ZMod 23)ˣ = (23).totient = 22`
  (equivalently `finrank ℚ Cyclotomic23 = 22` and `IsGalois.card_aut_eq_finrank`).

Honest scope: this file only pins the group `Gal(ℚ(ζ₂₃)/ℚ)` itself — cyclic of
order `22`. It does **not** identify the order-`11` subgroup with a
decomposition group of a specific prime above `2`, does **not** build the
`IntermediateField` realizing `L23`, and does **not** touch
`Ideal.map embedToRingOfIntegers P2`. Those remain future work under 3(i)#+.
-/

open FragileProofAudit.Lame.CyclotomicEmbed (Cyclotomic23 isCyclotomic23)

namespace FragileProofAudit.Lame.CyclotomicGalois

noncomputable section

/-- `Cyclotomic23 = CyclotomicField 23 ℚ` is a Galois extension of `ℚ`. -/
instance instIsGalois : IsGalois ℚ Cyclotomic23 :=
  IsCyclotomicExtension.isGalois (S := ({23} : Set ℕ)) (K := ℚ) (L := Cyclotomic23)

/-- The `23`rd cyclotomic polynomial is irreducible over `ℚ`. -/
theorem cyclotomic23_irreducible : Irreducible (Polynomial.cyclotomic 23 ℚ) :=
  Polynomial.cyclotomic.irreducible_rat (by norm_num)

/-- `Gal(ℚ(ζ₂₃)/ℚ) ≃* (ZMod 23)ˣ`. -/
noncomputable def galEquivUnitsZMod23 : Gal(Cyclotomic23/ℚ) ≃* (ZMod 23)ˣ :=
  IsCyclotomicExtension.autEquivPow Cyclotomic23 cyclotomic23_irreducible

/-- `(ZMod 23)ˣ` is cyclic, since `23` is prime. -/
instance instIsCyclicUnitsZMod23 : IsCyclic (ZMod 23)ˣ :=
  ZMod.isCyclic_units_prime (by norm_num)

/-- **`Gal(ℚ(ζ₂₃)/ℚ)` is cyclic**, transported from `(ZMod 23)ˣ` along
`galEquivUnitsZMod23`. -/
instance instIsCyclicGal : IsCyclic Gal(Cyclotomic23/ℚ) :=
  isCyclic_of_surjective galEquivUnitsZMod23.symm galEquivUnitsZMod23.symm.surjective

theorem natCard_unitsZMod23 : Nat.card (ZMod 23)ˣ = 22 := by
  rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient]
  decide

/-- **`Gal(ℚ(ζ₂₃)/ℚ)` has order `22`.** -/
theorem natCard_gal_eq_22 : Nat.card Gal(Cyclotomic23/ℚ) = 22 := by
  rw [Nat.card_congr galEquivUnitsZMod23.toEquiv, natCard_unitsZMod23]

end

end FragileProofAudit.Lame.CyclotomicGalois
