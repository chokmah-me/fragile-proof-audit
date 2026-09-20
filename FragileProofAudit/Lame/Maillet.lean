/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.Data.Int.Basic
import Mathlib.Tactic.NormNum

/-!
# Lamé 1847 — Maillet matrix entries (Lean stub)

The absolute Maillet / OEIS A000927 determinant certificate
`mailletAbsDet 23 = 3` is proved by the Python gate
`scripts/gates/lame_h23.py` (fraction-free elimination over `Fraction`).

A kernel-reducible Lean Bareiss (or an approved `native_decide` exception)
is **deferred**: `decide` does not reduce `Id.run`/`for` Bareiss, and a
well-founded recursive version needs more plumbing than this slice budget.

This module pins the **entry formula** matching the gate / OEIS Maple program,
so a later det proof can reuse it.
-/

namespace FragileProofAudit.Lame.Maillet

/-- OEIS A000927 Maillet matrix entry, 0-based indices into an
`n × n` matrix for prime `p` with `n = (p - 3) / 2`.

`Mᵢⱼ = ⌊(i+1)(j+2)/p⌋ − ⌊i(j+2)/p⌋` with 1-based `i,j` in the OEIS
convention; here `i,j` are 0-based so `ii = i+1`, `jj = j+1`. -/
def mailletEntry (p : ℕ) (i j : ℕ) : ℤ :=
  let ii := i + 1
  let jj := j + 1
  ((ii + 1) * (jj + 2) / p : ℕ) - (ii * (jj + 2) / p : ℕ)

/-- Spot-check: leading entry of the `p = 23` Maillet matrix. -/
theorem mailletEntry_23_0_0 : mailletEntry 23 0 0 = 0 := by decide

/-- Spot-check matching the Python gate’s matrix construction. -/
theorem mailletEntry_23_0_1 : mailletEntry 23 0 1 = 0 := by decide

theorem mailletEntry_5_0_0 : mailletEntry 5 0 0 = 1 := by decide

/-- Deferred: `mailletAbsDet 23 = 3` (see `results/lame_h23_gate_meta.json`). -/
def mailletAbsDetDeferred : String :=
  "Python gate lame_h23: Maillet/OEIS A000927 |det| at p=23 equals 3"

end FragileProofAudit.Lame.Maillet
