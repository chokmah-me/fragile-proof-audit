/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.NumberTheory.Cyclotomic.Basic
import Mathlib.NumberTheory.NumberField.ClassNumber
import Mathlib.RingTheory.DedekindDomain.PID
import Mathlib.Tactic.NormNum.Prime

/-!
# Lamé 1847 — logical pinpoint at \(p = 23\)

Lamé’s FLT route requires unique factorization of the cyclotomic integers
`𝓞 (CyclotomicField p ℚ)`. For the ring of integers of a number field this is
equivalent to being a PID, which is equivalent to class number `1`
(`NumberField.classNumber_eq_one_iff`).

This module records the **logical** pinpoint: if
`classNumber (CyclotomicField 23 ℚ) = 3`, then Lamé’s PID/UFD premise fails at
exponent `23`. The numerical identification `classNumber = 3` is the content of
the Python gate `lame_h23` (Maillet \(h^- = 3\), cited \(h^+ = 1\)); Lean does
not re-prove that identification here.

Does **not** claim FLT. Does **not** claim a new class-number theorem.
-/

namespace FragileProofAudit.Lame.Premise

open NumberField

instance fact_prime_23 : Fact (Nat.Prime 23) :=
  ⟨by norm_num⟩

/-- The `23`-rd cyclotomic field over `ℚ`. -/
abbrev Cyclotomic23 : Type :=
  CyclotomicField 23 ℚ

/-- Lamé’s load-bearing premise at exponent `p`: the cyclotomic integers are a PID.

For Dedekind domains this is equivalent to unique factorization into elements
(`IsPrincipalIdealRing.of_isDedekindDomain_of_uniqueFactorizationMonoid`). -/
def LamePIDPremise (p : ℕ) [Fact p.Prime] : Prop :=
  IsPrincipalIdealRing (𝓞 (CyclotomicField p ℚ))

/-- Lamé’s UFD premise (elementwise unique factorization). -/
def LameUFDPremise (p : ℕ) [Fact p.Prime] : Prop :=
  UniqueFactorizationMonoid (𝓞 (CyclotomicField p ℚ))

/-- PID premise at `23` ↔ class number `1` (mathlib). -/
theorem lame_pid_iff_classNumber_one :
    LamePIDPremise 23 ↔ classNumber Cyclotomic23 = 1 := by
  simpa [LamePIDPremise, Cyclotomic23] using
    (classNumber_eq_one_iff (K := Cyclotomic23)).symm

/-- **Logical pinpoint.** If `h₂₃ = 3`, Lamé’s PID premise fails at `p = 23`. -/
theorem not_lame_pid_of_classNumber_eq_three
    (h : classNumber Cyclotomic23 = 3) : ¬ LamePIDPremise 23 := by
  intro hp
  have h1 : classNumber Cyclotomic23 = 1 :=
    lame_pid_iff_classNumber_one.mp hp
  omega

/-- **Logical pinpoint (UFD form).** Dedekind + UFM ⇒ PID, so class number `3`
also kills elementwise unique factorization. -/
theorem not_lame_ufd_of_classNumber_eq_three
    (h : classNumber Cyclotomic23 = 3) : ¬ LameUFDPremise 23 := by
  intro hu
  haveI : UniqueFactorizationMonoid (𝓞 Cyclotomic23) := hu
  have hpid : IsPrincipalIdealRing (𝓞 Cyclotomic23) :=
    IsPrincipalIdealRing.of_isDedekindDomain_of_uniqueFactorizationMonoid _
  exact not_lame_pid_of_classNumber_eq_three h hpid

/-- Packaged pinpoint: class number `3` refutes both PID and UFD premises. -/
theorem lame_premises_fail_of_classNumber_eq_three
    (h : classNumber Cyclotomic23 = 3) :
    ¬ LamePIDPremise 23 ∧ ¬ LameUFDPremise 23 :=
  ⟨not_lame_pid_of_classNumber_eq_three h, not_lame_ufd_of_classNumber_eq_three h⟩

end FragileProofAudit.Lame.Premise
