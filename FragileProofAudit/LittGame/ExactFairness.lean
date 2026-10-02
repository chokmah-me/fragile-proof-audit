/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Private campaign artifact. Gates refute routes, not theorems.
-/

import Mathlib.Data.Finset.Interval
import Mathlib.Order.Interval.Finset.Nat
import Mathlib.Data.Finset.Card
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.GCongr
import FragileProofAudit.LittGame.Theta
import FragileProofAudit.LittGame.Game

/-!
# LittGame M4 — Exact fairness (`ExactFairness.lean`)

Transcription of Basdevant et al., "On cases where Litt's game is fair"
(arXiv:2406.20049v2), Theorem (bijection):

If `θ_AA = θ_BB` (equal autocorrelations), then for every `n`,
`P(Alice wins) = P(Bob wins)`.

## Proof plan (Basdevant et al.)

1. **Overlaps**: Words `Y = C_1^{m_1} C_2 ... ^{m_{k-1}} C_k` where `C_i ∈ {A,B}`
   and `m_i ∈ Cor(C_i, C_{i+1})`. (`overlapConcat` implements `C^m D`.)
2. **φ on overlaps**: `φ(Y) = C̄_k^{m_{k-1}} ... ^{m_1} C̄_1`
   (reverse order, swap A↔B). (`phiBlocks` implements the block reversal.)
   - Well-defined: needs `Cor(A,A) = Cor(B,B)` to ensure
     `m ∈ Cor(C_i, C_{i+1}) → m ∈ Cor(C̄_{i+1}, C̄_i)`.
   - Involution, preserves length, swaps `(N_A, N_B)`.
3. **Pattern decomposition**: Every word `Y` writes uniquely as
   `X_0 E_1 X_1 ... E_k X_k` with `E_i` overlaps and `X_i` containing no A/B.
4. **Key lemma**: `L_M(n) = L_{φ(M)}(n)` (pattern counts preserved).
5. **Main theorem**: The bijection swaps scores, so
   `winEvent` ↔ `loseEvent` bijectively, giving equal probabilities.

## Status

Definitions (`overlapConcat`, `swapAB'`, `phiBlocks`) are in place and build.
The proofs (well-definedness, involution, count-swapping, pattern decomposition,
main theorem) remain. This is the 2–4 week estimate from the workplan.
-/

namespace FragileProofAudit.LittGame

open Finset

/-- Overlapping concatenation: `C ++ (D.drop m)`, where `m ∈ overlapSet q C D`
    ensures the suffix of `C` of length `m` equals the prefix of `D` of length `m`.
    This is the `C^m D` notation from Basdevant et al. -/
def overlapConcat (q : ℕ) (C D : List (Fin q)) (m : ℕ)
    (_h : m ∈ overlapSet q C D) : List (Fin q) :=
  C ++ (D.drop m)

/-- Swap A and B: `Ā = B`, `B̄ = A`.
    If `C = A` returns `B`, otherwise returns `A`
    (in our use case `C` is always `A` or `B`). -/
def swapAB' (A B C : List (Fin q)) : List (Fin q) :=
  if C = A then B else A

/-- φ on block lists: reverse the order and swap A↔B.
    Given `[C_1, ..., C_k]`, produces `[C̄_k, ..., C̄_1]`.
    This is the core of the Basdevant bijection. -/
def phiBlocks (A B : List (Fin q)) (cs : List (List (Fin q))) :
    List (List (Fin q)) :=
  (cs.reverse.map fun C => swapAB' A B C)

end FragileProofAudit.LittGame
