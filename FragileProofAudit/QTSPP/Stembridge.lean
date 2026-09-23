/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Private campaign artifact. Gates refute routes, not theorems.
-/

import Mathlib

/-!
# Stembridge's TSPP theorem — q=1 shakedown (arXiv:0906.1018)

Koutschan's algorithmic proof of Stembridge's enumeration of totally
symmetric plane partitions, via Zeilberger's holonomic ansatz. This is the
q=1 staging case for the q-TSPP infrastructure build (harvest rank 10):
fully written up, smaller certificates, ordinary (non-q) Ore algebra.

This module states Okada's determinant reduction (Theorem 2.5 of
arXiv:0906.1018) as the machine target, and proves the abstract closing
lemma used by identity (3.2): uniqueness for variable-coefficient linear
recurrences. No proof of the determinant identity itself is claimed here —
the certificate identities (3.1)–(3.3) are future work (see
`docs/blueprint/qtspp-q1.md`). No `sorry`.
-/

namespace FragileProofAudit.QTSPP

/-- Okada's matrix entry (2.3) of arXiv:0906.1018:
    a(i,j) = C(i+j-2,i-1) + C(i+j-1,i) + 2δ(i,j) − δ(i,j+1), over ℚ.
    Indices are 1-based; the truncated subtractions are safe for i, j ≥ 1. -/
def tsppEntry (i j : ℕ) : ℚ :=
  ((i + j - 2).choose (i - 1) : ℚ) + ((i + j - 1).choose i : ℚ)
    + 2 * (if i = j then 1 else 0) - (if i = j + 1 then 1 else 0)

/-- The n×n Okada matrix, with 1-based `tsppEntry` adapted to `Fin n`. -/
def tsppMatrix (n : ℕ) : Matrix (Fin n) (Fin n) ℚ :=
  Matrix.of fun i j => tsppEntry (i.val + 1) (j.val + 1)

/-- Stembridge's product formula (2.1): ∏_{1≤i≤j≤k≤n} (i+j+k−1)/(i+j+k−2). -/
def tsppProduct (n : ℕ) : ℚ :=
  ∏ i ∈ Finset.Icc 1 n, ∏ j ∈ Finset.Icc i n, ∏ k ∈ Finset.Icc j n,
    ((i + j + k : ℚ) - 1) / ((i + j + k : ℚ) - 2)

/-- Okada's determinant evaluation (Theorem 2.5 of arXiv:0906.1018):
    det(a(i,j)) = (product)². Stated as a `Prop`; proving it for all `n`
    is the certificate work of identities (3.1)–(3.3). -/
def stembridgeDetIdentity (n : ℕ) : Prop :=
  (tsppMatrix n).det = (tsppProduct n) ^ 2

/-- Uniqueness for variable-coefficient linear recurrences: the abstract
    closing argument behind identity (3.2) of arXiv:0906.1018 (and identity
    (1) of the q-case). If two sequences satisfy the same order-`m`
    recurrence with everywhere-nonzero leading coefficient and agree on the
    first `m` values, they are equal. In (3.2) the two sequences are the
    diagonal `B'(n,n)` and the constant sequence `1`, and the recurrence is
    the certified order-7 operator (whose leading coefficient is explicitly
    factored and nonvanishing on ℕ). -/
theorem recurrence_unique {m : ℕ} {p : ℕ → ℕ → ℚ} {f g : ℕ → ℚ}
    (hlead : ∀ n, p m n ≠ 0)
    (hf : ∀ n, ∑ i ∈ Finset.range (m + 1), p i n * f (n + i) = 0)
    (hg : ∀ n, ∑ i ∈ Finset.range (m + 1), p i n * g (n + i) = 0)
    (hinit : ∀ i < m, f i = g i) :
    f = g := by
  have key : ∀ n, f n = g n := by
    intro n
    induction n using Nat.strong_induction_on with
    | _ n ih =>
      by_cases h : n < m
      · exact hinit n h
      · have h1 := hf (n - m)
        have h2 := hg (n - m)
        rw [Finset.sum_range_succ] at h1 h2
        have hnm : n - m + m = n := Nat.sub_add_cancel (Nat.le_of_not_lt h)
        rw [hnm] at h1 h2
        have hsum : ∑ i ∈ Finset.range m, p i (n - m) * f (n - m + i)
            = ∑ i ∈ Finset.range m, p i (n - m) * g (n - m + i) := by
          apply Finset.sum_congr rfl
          intro i hi
          have hlt : n - m + i < n := by
            have him : i < m := Finset.mem_range.mp hi
            omega
          rw [ih _ hlt]
        have e : p m (n - m) * f n = p m (n - m) * g n := by linarith
        exact mul_right_cancel₀ (hlead (n - m)) e
  funext n
  exact key n

end FragileProofAudit.QTSPP
