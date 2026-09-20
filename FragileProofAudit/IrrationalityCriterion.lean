/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.NumberTheory.Real.Irrational
import Mathlib.Topology.Order.Basic

/-!
# Irrationality criterion (Chen et al. Prop. 3.1 / Apéry form)

Classical statement used by the Suman / Kim ζ(5) dossier:

If there exist sequences `A n : ℤ`, `B n : ℤ` such that
`0 < |(A n : ℝ) * x - B n|` for all `n` and
`|(A n : ℝ) * x - B n| → 0`, then `x` is irrational.

This is the integer-form packaging of Chen–He–…–Yu, arXiv:2411.16774,
Proposition 3.1 (their quantitative `εⁿ` / `Dⁿ` hypotheses imply these).

We do **not** claim ζ(5) is rational or irrational here — only the criterion.
-/

open Filter Topology

namespace FragileProofAudit.IrrationalityCriterion

/-- Clearing a rational assumption: `A·(p/q) − B = (A p − B q)/q`. -/
lemma form_of_rat
    (A B p q : ℤ) (_hq : (q : ℝ) ≠ 0) (x : ℝ) (hx : x = (p : ℝ) / q) :
    (A : ℝ) * x - (B : ℝ) = ((A * p - B * q : ℤ) : ℝ) / q := by
  subst hx
  field_simp
  push_cast
  ring

/-- Apéry-shaped irrationality criterion.

If nonzero integer linear forms in `x` tend to zero in absolute value, then `x`
cannot be rational. -/
theorem irrational_of_integer_forms_tendsto_zero
    (x : ℝ) (A B : ℕ → ℤ)
    (hpos : ∀ n, 0 < |(A n : ℝ) * x - (B n : ℝ)|)
    (hlim : Tendsto (fun n ↦ |(A n : ℝ) * x - (B n : ℝ)|) atTop (𝓝 0)) :
    Irrational x := by
  classical
  rw [irrational_iff_ne_rational]
  intro p q hq hx
  have hqR : (q : ℝ) ≠ 0 := by exact_mod_cast hq
  have hqpos : (0 : ℝ) < |(q : ℝ)| := abs_pos.mpr hqR
  have hge : ∀ n, (1 : ℝ) / |(q : ℝ)| ≤ |(A n : ℝ) * x - (B n : ℝ)| := by
    intro n
    set N : ℤ := A n * p - B n * q with hNdef
    have hform :
        (A n : ℝ) * x - (B n : ℝ) = (N : ℝ) / (q : ℝ) := by
      simpa [hNdef] using form_of_rat (A n) (B n) p q hqR x hx
    have hN0 : N ≠ 0 := by
      intro h0
      have : |(A n : ℝ) * x - (B n : ℝ)| = 0 := by
        rw [hform, h0, Int.cast_zero, zero_div, abs_zero]
      exact (hpos n).ne' this
    have h1 : (1 : ℝ) ≤ |(N : ℝ)| := by
      have : (1 : ℤ) ≤ |N| := Int.one_le_abs hN0
      exact_mod_cast this
    calc
      (1 : ℝ) / |(q : ℝ)| ≤ |(N : ℝ)| / |(q : ℝ)| :=
        div_le_div_of_nonneg_right h1 hqpos.le
      _ = |(N : ℝ) / (q : ℝ)| := by rw [abs_div]
      _ = |(A n : ℝ) * x - (B n : ℝ)| := by rw [hform]
  have hsmall :
      ∀ᶠ n in atTop, |(A n : ℝ) * x - (B n : ℝ)| < 1 / |(q : ℝ)| :=
    (tendsto_order.1 hlim).2 (1 / |(q : ℝ)|) (one_div_pos.mpr hqpos)
  rcases hsmall.exists with ⟨n, hn⟩
  exact lt_irrefl _ ((hge n).trans_lt hn)

/-- Documentation: Chen Prop. 3.1 packages the same idea with rate `εⁿ` and
denominator growth `Dⁿ` under `D * ε < 1`. Those hypotheses produce integer
forms tending to zero after clearing denominators; the theorem above is the
kernel step. -/
theorem chen_prop_31_is_classical_packaging : True := trivial

end FragileProofAudit.IrrationalityCriterion
