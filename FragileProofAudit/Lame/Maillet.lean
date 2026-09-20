/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.Data.Int.Basic
import Mathlib.Data.List.Basic
import Mathlib.Tactic.NormNum

/-!
# Lamé 1847 — Maillet / OEIS A000927 determinant (Bareiss)

The relative class-number formula used by the Python gate
`scripts/gates/lame_h23.py` is the absolute value of the Maillet determinant
(OEIS A000927). This module defines that matrix, computes its determinant by a
**fuel-bounded fraction-free Bareiss** algorithm (no `Id.run`, no
`native_decide`), and proves

`mailletAbsDet 23 = 3`

by kernel `decide`. Matching OEIS pins for smaller primes are included.

Honest scope: this is the **Bareiss determinant of the Maillet entry matrix**,
i.e. the same integer the gate/OEIS formula uses. It does **not** prove
equality with mathlib `Matrix.det`, nor `classNumber (CyclotomicField 23 ℚ) = 3`
(the `h^+` factor remains cited as in the gate).
-/

namespace FragileProofAudit.Lame.Maillet

/-! ### Maillet entries -/

/-- OEIS A000927 Maillet matrix entry, 0-based indices into an
`n × n` matrix for prime `p` with `n = (p - 3) / 2`.

`Mᵢⱼ = ⌊(i+1)(j+2)/p⌋ − ⌊i(j+2)/p⌋` with 1-based `i,j` in the OEIS
convention; here `i,j` are 0-based so `ii = i+1`, `jj = j+1`. -/
def mailletEntry (p : ℕ) (i j : ℕ) : ℤ :=
  let ii := i + 1
  let jj := j + 1
  ((ii + 1) * (jj + 2) / p : ℕ) - (ii * (jj + 2) / p : ℕ)

/-- Maillet matrix as list-of-rows (size `n = (p-3)/2`). -/
def mailletMat (p : ℕ) : List (List ℤ) :=
  let n := (p - 3) / 2
  (List.range n).map fun i =>
    (List.range n).map fun j => mailletEntry p i j

theorem mailletEntry_23_0_0 : mailletEntry 23 0 0 = 0 := by decide
theorem mailletEntry_23_0_1 : mailletEntry 23 0 1 = 0 := by decide
theorem mailletEntry_5_0_0 : mailletEntry 5 0 0 = 1 := by decide

/-! ### Fuel-bounded Bareiss (kernel-reducible) -/

abbrev Mat := List (List ℤ)

def get (A : Mat) (i j : ℕ) : ℤ :=
  match A[i]? with
  | none => 0
  | some row =>
    match row[j]? with
    | none => 0
    | some v => v

def swapRows (A : Mat) (i k : ℕ) : Mat :=
  A.mapIdx fun ri row =>
    if ri = i then (A[k]?).getD []
    else if ri = k then (A[i]?).getD []
    else row

/-- Fuel-bounded pivot search starting at row `r`. -/
def findPivotFrom : ℕ → Mat → ℕ → ℕ → Option ℕ
  | 0, _, _, _ => none
  | fuel + 1, A, k, r =>
    if get A r k ≠ 0 then some r
    else findPivotFrom fuel A k (r + 1)

def findPivot (A : Mat) (k n : ℕ) : Option ℕ :=
  findPivotFrom (n - k) A k k

def bareissUpdate (A : Mat) (k : ℕ) (pivot prev : ℤ) : Mat :=
  A.mapIdx fun i row =>
    if i ≤ k then row
    else
      row.mapIdx fun j _ =>
        if j < k then get A i j
        else if j = k then (0 : ℤ)
        else (get A i j * pivot - get A i k * get A k j) / prev

/-- Fuel-bounded Bareiss; use `fuel = A.length` at the top call. -/
def bareissGo : ℕ → Mat → ℕ → ℤ → ℤ → ℤ
  | 0, _, _, _, _ => 0
  | fuel + 1, A, k, sign, prev =>
    let n := A.length
    if k ≥ n then 0
    else
      match findPivot A k n with
      | none => 0
      | some piv =>
        let A1 := if piv = k then A else swapRows A k piv
        let sign1 : ℤ := if piv = k then sign else -sign
        let pivot := get A1 k k
        if k + 1 = n then sign1 * pivot
        else bareissGo fuel (bareissUpdate A1 k pivot prev) (k + 1) sign1 pivot

/-- Signed Bareiss determinant of a square list-matrix. -/
def bareissDet (A : Mat) : ℤ :=
  if A.length = 0 then 1 else bareissGo A.length A 0 1 1

/-- Absolute Maillet determinant (OEIS A000927 / gate `h_minus_maillet`). -/
def mailletAbsDet (p : ℕ) : ℕ :=
  Int.natAbs (bareissDet (mailletMat p))

set_option maxHeartbeats 8000000
set_option maxRecDepth 100000

/-- Gate/OEIS pin: `h^-_5 = 1`. -/
theorem mailletAbsDet_5 : mailletAbsDet 5 = 1 := by decide

/-- Gate/OEIS pin: `h^-_7 = 1`. -/
theorem mailletAbsDet_7 : mailletAbsDet 7 = 1 := by decide

/-- Gate/OEIS pin: `h^-_11 = 1`. -/
theorem mailletAbsDet_11 : mailletAbsDet 11 = 1 := by decide

/-- Gate/OEIS pin: `h^-_13 = 1`. -/
theorem mailletAbsDet_13 : mailletAbsDet 13 = 1 := by decide

/-- Gate/OEIS pin: `h^-_17 = 1`. -/
theorem mailletAbsDet_17 : mailletAbsDet 17 = 1 := by decide

/-- Gate/OEIS pin: `h^-_19 = 1`. -/
theorem mailletAbsDet_19 : mailletAbsDet 19 = 1 := by decide

/-- **Load-bearing Maillet certificate:** `|det| = 3` at `p = 23`. -/
theorem mailletAbsDet_23 : mailletAbsDet 23 = 3 := by decide

/-- First odd-prime UFD-relevant failure among the OEIS prefix pins above. -/
theorem mailletAbsDet_23_first_failure_among_pins :
    mailletAbsDet 5 = 1 ∧ mailletAbsDet 7 = 1 ∧ mailletAbsDet 11 = 1 ∧
      mailletAbsDet 13 = 1 ∧ mailletAbsDet 17 = 1 ∧ mailletAbsDet 19 = 1 ∧
      mailletAbsDet 23 = 3 :=
  ⟨mailletAbsDet_5, mailletAbsDet_7, mailletAbsDet_11, mailletAbsDet_13,
    mailletAbsDet_17, mailletAbsDet_19, mailletAbsDet_23⟩

end FragileProofAudit.Lame.Maillet
