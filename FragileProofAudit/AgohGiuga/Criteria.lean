/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.List.Basic

/-!
# Agoh–Giuga kit — Giuga / Korselt criteria

Finite oracle definitions matching `scripts/gates/giuga_oracle.py`.

A composite counterexample to the Agoh–Giuga conjecture must be both a
**Giuga number** and a **Carmichael number**. Carmichael numbers are
characterized by Korselt’s criterion (Mathlib does not yet define them;
see `Mathlib.NumberTheory.FermatPsp`).

This module does **not** claim the Agoh–Giuga conjecture.
-/

namespace FragileProofAudit.AgohGiuga.Criteria

/-- Explicit-factor form of the Giuga criterion.

`ps` is a pinned prime factorization of `n`: product equals `n`, factors
are pairwise distinct primes, and each satisfies `p ∣ (n / p - 1)`. -/
def GiugaOnFactors (n : ℕ) (ps : List ℕ) : Prop :=
  ps.prod = n ∧
    ps.Nodup ∧
    (∀ p ∈ ps, Nat.Prime p) ∧
    (∀ p ∈ ps, p ∣ n / p - 1)

/-- Explicit-factor form of Korselt’s criterion (Carmichael characterization).

Same factorization hygiene as `GiugaOnFactors`, plus `(p - 1) ∣ (n - 1)`
for every listed prime. -/
def KorseltOnFactors (n : ℕ) (ps : List ℕ) : Prop :=
  ps.prod = n ∧
    ps.Nodup ∧
    (∀ p ∈ ps, Nat.Prime p) ∧
    (∀ p ∈ ps, p - 1 ∣ n - 1)

/-- Standing oracle predicate: Giuga on `ps` and Korselt fails on `ps`. -/
def OracleWitness (n : ℕ) (ps : List ℕ) : Prop :=
  GiugaOnFactors n ps ∧ ¬ KorseltOnFactors n ps

end FragileProofAudit.AgohGiuga.Criteria
