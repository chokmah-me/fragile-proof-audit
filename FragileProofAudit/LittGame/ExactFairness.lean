/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Private campaign artifact. Gates refute routes, not theorems.
-/

import Mathlib.Data.Finset.Interval
import Mathlib.Data.Finset.Max
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

/-!
## M4 core lemmas (proved 2026-10-05)

Transcription of Basdevant et al. arXiv:2406.20049v2, Proposition 1
(well-definedness of φ) and the `θ`/`Cor` bridge.

The repo's `overlapSet q U V` is the paper's `Cor(U,V)` (overlap lengths
`1 ≤ k ≤ |U|-1` with matching suffix/prefix), restricted here to equal-length
words. "Same auto-correlation" (`Cor(A) = Cor(B)`) is `overlapSet q A A =
overlapSet q B B`; equal `θ` values imply it by base-`q` uniqueness of the
power sum (needs `2 ≤ q` and `|A| = |B|`).
-/

namespace FragileProofAudit.LittGame

open Finset

variable {q : ℕ}

/-- Geometric-series strict bound: `∑_{k<m} q^k < q^m` for `2 ≤ q`. -/
theorem sum_range_pow_lt {q m : ℕ} (hq : 2 ≤ q) :
    ∑ k ∈ Finset.range m, q ^ k < q ^ m := by
  induction m with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ]
    have h2q : 2 * q ^ m ≤ q * q ^ m := Nat.mul_le_mul_right _ hq
    calc ∑ k ∈ Finset.range m, q ^ k + q ^ m
        < q ^ m + q ^ m := by gcongr
      _ = 2 * q ^ m := by ring
      _ ≤ q * q ^ m := h2q
      _ = q ^ (m + 1) := by rw [mul_comm, pow_succ]

/-- The power-sum map `S ↦ ∑_{k∈S} q^k` is injective for `2 ≤ q`
    (base-`q` uniqueness). -/
theorem sum_pow_injective {q : ℕ} (hq : 2 ≤ q) {S T : Finset ℕ}
    (h : ∑ k ∈ S, q ^ k = ∑ k ∈ T, q ^ k) : S = T := by
  have hdisj : Disjoint (S \ T) (T \ S) := by
    rw [Finset.disjoint_left]
    intro x hxS hxT
    exact (Finset.mem_sdiff.mp hxT).2 (Finset.mem_sdiff.mp hxS).1
  have key : ∑ k ∈ S \ T, q ^ k = ∑ k ∈ T \ S, q ^ k := by
    have e1 : ∑ k ∈ S, q ^ k
        = ∑ k ∈ S \ T, q ^ k + ∑ k ∈ S ∩ T, q ^ k := by
      conv_lhs => rw [← Finset.sdiff_union_inter S T,
        Finset.sum_union (Finset.disjoint_sdiff_inter S T)]
    have e2 : ∑ k ∈ T, q ^ k
        = ∑ k ∈ T \ S, q ^ k + ∑ k ∈ S ∩ T, q ^ k := by
      conv_lhs => rw [← Finset.sdiff_union_inter T S,
        Finset.sum_union (Finset.disjoint_sdiff_inter T S),
        Finset.inter_comm T S]
    omega
  by_cases hST : S \ T = ∅
  · have hTS : T \ S = ∅ := by
      rw [hST, Finset.sum_empty] at key
      rw [Finset.eq_empty_iff_forall_notMem]
      intro x hx
      have hall := (Finset.sum_eq_zero_iff_of_nonneg
        (fun k _ => Nat.zero_le _)).mp key.symm x hx
      exact absurd hall (pow_ne_zero _ (by omega : q ≠ 0))
    have eS : S = S ∩ T := by
      have h1 : S ∩ T = S := by
        have h1' := Finset.sdiff_union_inter S T
        rwa [hST, Finset.empty_union] at h1'
      exact h1.symm
    have eT : T = S ∩ T := by
      have h2 : T ∩ S = T := by
        have h2' := Finset.sdiff_union_inter T S
        rwa [hTS, Finset.empty_union] at h2'
      calc T = T ∩ S := h2.symm
        _ = S ∩ T := Finset.inter_comm _ _
    exact eS.trans eT.symm
  · obtain ⟨m, hm⟩ := Finset.nonempty_iff_ne_empty.mpr hST
    have hUne : ((S \ T) ∪ (T \ S)).Nonempty :=
      ⟨m, Finset.mem_union_left _ hm⟩
    set M := Finset.max' _ hUne with hMdef
    have hMmax : ∀ k ∈ (S \ T) ∪ (T \ S), k ≤ M :=
      fun k hk => Finset.le_max' _ k hk
    have hMmem : M ∈ (S \ T) ∪ (T \ S) := Finset.max'_mem _ hUne
    -- whichever side holds the maximum strictly dominates the other side
    rcases Finset.mem_union.mp hMmem with hM | hM
    · have hge : q ^ M ≤ ∑ k ∈ S \ T, q ^ k :=
        Finset.single_le_sum (fun k _ => Nat.zero_le _) hM
      have hlt : ∑ k ∈ T \ S, q ^ k < q ^ M := by
        have hsub : T \ S ⊆ Finset.range M := by
          intro k hk
          have hle := hMmax k (Finset.mem_union_right _ hk)
          have hne : k ≠ M := fun heq => by
            subst heq
            exact (Finset.disjoint_left.mp hdisj hM hk).elim
          rw [Finset.mem_range]; omega
        calc ∑ k ∈ T \ S, q ^ k
            ≤ ∑ k ∈ Finset.range M, q ^ k :=
              Finset.sum_le_sum_of_subset_of_nonneg hsub
                (fun k _ _ => Nat.zero_le _)
          _ < q ^ M := sum_range_pow_lt hq
      omega
    · have hge : q ^ M ≤ ∑ k ∈ T \ S, q ^ k :=
        Finset.single_le_sum (fun k _ => Nat.zero_le _) hM
      have hlt : ∑ k ∈ S \ T, q ^ k < q ^ M := by
        have hsub : S \ T ⊆ Finset.range M := by
          intro k hk
          have hle := hMmax k (Finset.mem_union_left _ hk)
          have hne : k ≠ M := fun heq => by
            subst heq
            exact (Finset.disjoint_left.mp hdisj hk hM).elim
          rw [Finset.mem_range]; omega
        calc ∑ k ∈ S \ T, q ^ k
            ≤ ∑ k ∈ Finset.range M, q ^ k :=
              Finset.sum_le_sum_of_subset_of_nonneg hsub
                (fun k _ _ => Nat.zero_le _)
          _ < q ^ M := sum_range_pow_lt hq
      omega

/-- Bridge: equal `θ` values (and equal word lengths, `2 ≤ q`) give equal
    self-overlap sets — the paper's "same auto-correlation" hypothesis. -/
theorem overlapSet_eq_of_theta_eq {A B : List (Fin q)}
    (hq : 2 ≤ q) (hlen : A.length = B.length)
    (h : theta q A A = theta q B B) :
    overlapSet q A A = overlapSet q B B := by
  have hqpos : (0:ℚ) < q := by exact_mod_cast (by omega : 0 < q)
  have hden : ((q : ℚ) ^ A.length) ≠ 0 := pow_ne_zero _ (ne_of_gt hqpos)
  unfold theta at h
  rw [← hlen] at h
  have hnum : (∑ k ∈ overlapSet q A A, (q:ℚ) ^ k)
      = ∑ k ∈ overlapSet q B B, (q:ℚ) ^ k := by
    have h' := congrArg (· * ((q:ℚ) ^ A.length)) h
    rw [div_mul_cancel₀ _ hden, div_mul_cancel₀ _ hden] at h'
    exact h'
  have hnat : ∑ k ∈ overlapSet q A A, q ^ k
      = ∑ k ∈ overlapSet q B B, q ^ k := by
    have hcast : ((∑ k ∈ overlapSet q A A, q ^ k : ℕ) : ℚ)
        = ((∑ k ∈ overlapSet q B B, q ^ k : ℕ) : ℚ) := by
      show (Nat.castRingHom ℚ) (∑ k ∈ overlapSet q A A, q ^ k)
        = (Nat.castRingHom ℚ) (∑ k ∈ overlapSet q B B, q ^ k)
      rw [map_sum, map_sum]
      simp only [map_pow]
      exact hnum
    exact Nat.cast_injective hcast
  exact sum_pow_injective hq hnat

/-- Proposition 1, well-definedness core (Basdevant et al.):
    if `m ∈ Cor(Cᵢ, Cᵢ₊₁)` then `m ∈ Cor(C̄ᵢ₊₁, C̄ᵢ)`.
    The equal-block cases use `Cor(A) = Cor(B)`; the mixed cases are
    definitional, since reversing *and* swapping fixes the pair `(A,B)`. -/
theorem overlap_mem_swap {A B C D : List (Fin q)}
    (hAA : overlapSet q A A = overlapSet q B B)
    (hC : C = A ∨ C = B) (hD : D = A ∨ D = B)
    {m : ℕ} (hm : m ∈ overlapSet q C D) :
    m ∈ overlapSet q (swapAB' A B D) (swapAB' A B C) := by
  by_cases hab : A = B
  · have hCA : C = A := hC.elim id (fun h => h.trans hab.symm)
    have hDA : D = A := hD.elim id (fun h => h.trans hab.symm)
    rw [hCA, hDA] at hm ⊢
    have e : swapAB' A B A = B := if_pos rfl
    rw [e, ← hab]; exact hm
  · rcases hC with hC | hC <;> rcases hD with hD | hD
    · rw [hC, hD] at hm ⊢
      have e : swapAB' A B A = B := if_pos rfl
      rw [e, ← hAA]; exact hm
    · rw [hC, hD] at hm ⊢
      have e1 : swapAB' A B A = B := if_pos rfl
      have e2 : swapAB' A B B = A := if_neg (Ne.symm hab)
      rw [e2, e1]; exact hm
    · rw [hC, hD] at hm ⊢
      have e1 : swapAB' A B A = B := if_pos rfl
      have e2 : swapAB' A B B = A := if_neg (Ne.symm hab)
      rw [e1, e2]; exact hm
    · rw [hC, hD] at hm ⊢
      have e : swapAB' A B B = A := if_neg (Ne.symm hab)
      rw [e, hAA]; exact hm

end FragileProofAudit.LittGame
