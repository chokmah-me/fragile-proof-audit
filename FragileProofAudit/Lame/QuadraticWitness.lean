/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import Mathlib.Data.Int.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-!
# Lamé 1847 — quadratic class-number witness for `ℚ(√−23)`

Supporting finite certificate matching `scripts/gates/lame_h23.py`: there are
exactly three reduced positive-definite binary quadratic forms of discriminant
`-23`, namely `(1,1,6)`, `(2,-1,3)`, `(2,1,3)`.

No `native_decide`.
-/

namespace FragileProofAudit.Lame.QuadraticWitness

/-- A binary quadratic form `ax² + bxy + cy²`. -/
structure BinQuad where
  a : ℤ
  b : ℤ
  c : ℤ
  deriving DecidableEq, Repr

def BinQuad.discr (f : BinQuad) : ℤ :=
  f.b ^ 2 - 4 * f.a * f.c

/-- Reduced positive-definite (decidable form). -/
def BinQuad.IsReducedPosDef (f : BinQuad) : Prop :=
  0 < f.a ∧
    Int.natAbs f.b ≤ Int.natAbs f.a ∧
    f.a ≤ f.c ∧
    (Int.natAbs f.b ≠ Int.natAbs f.a ∨ 0 ≤ f.b) ∧
    (f.a ≠ f.c ∨ 0 ≤ f.b)

instance (f : BinQuad) : Decidable (f.IsReducedPosDef) := by
  dsimp [BinQuad.IsReducedPosDef]
  infer_instance

def reducedNeg23 : List BinQuad :=
  [⟨1, 1, 6⟩, ⟨2, -1, 3⟩, ⟨2, 1, 3⟩]

theorem reducedNeg23_length : reducedNeg23.length = 3 := by decide

theorem form_116 :
    BinQuad.discr ⟨1, 1, 6⟩ = -23 ∧ BinQuad.IsReducedPosDef ⟨1, 1, 6⟩ := by
  decide

theorem form_2m13 :
    BinQuad.discr ⟨2, -1, 3⟩ = -23 ∧ BinQuad.IsReducedPosDef ⟨2, -1, 3⟩ := by
  decide

theorem form_213 :
    BinQuad.discr ⟨2, 1, 3⟩ = -23 ∧ BinQuad.IsReducedPosDef ⟨2, 1, 3⟩ := by
  decide

theorem reducedNeg23_ok :
    ∀ f ∈ reducedNeg23, f.discr = -23 ∧ f.IsReducedPosDef := by
  intro f hf
  simp only [reducedNeg23, List.mem_cons, List.not_mem_nil, or_false] at hf
  rcases hf with rfl | rfl | rfl
  · exact form_116
  · exact form_2m13
  · exact form_213

theorem four_ac_eq {f : BinQuad} (hd : f.discr = -23) :
    4 * f.a * f.c = f.b ^ 2 + 23 := by
  simp [BinQuad.discr] at hd
  linarith

/-- Bound: reduced + disc `-23` ⇒ `a ≤ 2`. -/
theorem a_le_two {f : BinQuad}
    (hr : f.IsReducedPosDef) (hd : f.discr = -23) : f.a ≤ 2 := by
  have ha0 : 0 < f.a := hr.1
  have hba : Int.natAbs f.b ≤ Int.natAbs f.a := hr.2.1
  have hac : f.a ≤ f.c := hr.2.2.1
  have hdisc := four_ac_eq hd
  have ha_abs : (Int.natAbs f.a : ℤ) = f.a := Int.natAbs_of_nonneg (le_of_lt ha0)
  have hb_le : (Int.natAbs f.b : ℤ) ≤ f.a :=
    (Nat.cast_le.mpr hba).trans_eq ha_abs
  -- b² = (natAbs b)² ≤ a²
  have hb2 : f.b ^ 2 ≤ f.a ^ 2 := by
    have : ((Int.natAbs f.b : ℤ) ^ 2) ≤ f.a ^ 2 := by
      nlinarith [ha0, hb_le]
    rwa [Int.natAbs_pow_two] at this
  have : 3 * f.a ^ 2 ≤ 23 := by
    have h1 : 4 * f.a ^ 2 ≤ 4 * f.a * f.c := by nlinarith
    have h2 : 4 * f.a * f.c = f.b ^ 2 + 23 := hdisc
    nlinarith
  by_contra h
  push Not at h
  have : 3 ≤ f.a := by omega
  nlinarith

theorem a_eq_one_or_two {f : BinQuad}
    (hr : f.IsReducedPosDef) (hd : f.discr = -23) :
    f.a = 1 ∨ f.a = 2 := by
  have ha0 : 0 < f.a := hr.1
  have hale := a_le_two hr hd
  omega

theorem natAbs_le_one {z : ℤ} (h : Int.natAbs z ≤ 1) :
    z = -1 ∨ z = 0 ∨ z = 1 := by
  match hz : Int.natAbs z with
  | 0 =>
    have : z = 0 := Int.natAbs_eq_zero.mp (by omega)
    exact Or.inr (Or.inl this)
  | 1 =>
    have := Int.natAbs_eq_iff.mp (by omega : Int.natAbs z = 1)
    exact this.elim (fun h => Or.inr (Or.inr h)) (fun h => Or.inl h)
  | n + 2 => omega

theorem natAbs_le_two {z : ℤ} (h : Int.natAbs z ≤ 2) :
    z = -2 ∨ z = -1 ∨ z = 0 ∨ z = 1 ∨ z = 2 := by
  have h' : Int.natAbs z ≤ 1 ∨ Int.natAbs z = 2 := by omega
  rcases h' with h' | h'
  · rcases natAbs_le_one h' with h | h | h
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr (Or.inl h))
    · exact Or.inr (Or.inr (Or.inr (Or.inl h)))
  · have := Int.natAbs_eq_iff.mp h'
    exact this.elim (fun h => Or.inr (Or.inr (Or.inr (Or.inr h)))) Or.inl

theorem reduced_of_discr_neg_23 {f : BinQuad}
    (hr : f.IsReducedPosDef) (hd : f.discr = -23) :
    f ∈ reducedNeg23 := by
  have hba : Int.natAbs f.b ≤ Int.natAbs f.a := hr.2.1
  have hdisc := four_ac_eq hd
  have hsignb : Int.natAbs f.b ≠ Int.natAbs f.a ∨ 0 ≤ f.b := hr.2.2.2.1
  rcases a_eq_one_or_two hr hd with ha | ha
  · have hbabs : Int.natAbs f.b ≤ 1 := by
      have : Int.natAbs f.a = 1 := by simp [ha]
      exact this ▸ hba
    rcases natAbs_le_one hbabs with hb | hb | hb
    · -- b = -1, a = 1: reduction forbids
      have heq : Int.natAbs f.b = Int.natAbs f.a := by simp [ha, hb]
      rcases hsignb with hneq | hge
      · exact (hneq heq).elim
      · simp [hb] at hge
    · have : 4 * f.c = 23 := by rw [ha, hb] at hdisc; simpa using hdisc
      omega
    · have : 4 * f.c = 24 := by rw [ha, hb] at hdisc; simpa using hdisc
      have hc : f.c = 6 := by omega
      cases f with | mk a b c =>
        simp only at ha hb hc
        simp [ha, hb, hc, reducedNeg23]
  · have hbabs : Int.natAbs f.b ≤ 2 := by
      have : Int.natAbs f.a = 2 := by simp [ha]
      exact this ▸ hba
    rcases natAbs_le_two hbabs with hb | hb | hb | hb | hb
    · have heq : Int.natAbs f.b = Int.natAbs f.a := by simp [ha, hb]
      rcases hsignb with hneq | hge
      · exact (hneq heq).elim
      · simp [hb] at hge
    · have : 8 * f.c = 24 := by rw [ha, hb] at hdisc; linarith
      have hc : f.c = 3 := by omega
      cases f with | mk a b c =>
        simp only at ha hb hc
        simp [ha, hb, hc, reducedNeg23]
    · have : 8 * f.c = 23 := by rw [ha, hb] at hdisc; linarith
      omega
    · have : 8 * f.c = 24 := by rw [ha, hb] at hdisc; linarith
      have hc : f.c = 3 := by omega
      cases f with | mk a b c =>
        simp only at ha hb hc
        simp [ha, hb, hc, reducedNeg23]
    · have : 8 * f.c = 27 := by rw [ha, hb] at hdisc; linarith
      omega

theorem reduced_forms_neg_23_equiv (f : BinQuad) :
    (f.IsReducedPosDef ∧ f.discr = -23) ↔ f ∈ reducedNeg23 := by
  constructor
  · exact fun ⟨hr, hd⟩ => reduced_of_discr_neg_23 hr hd
  · intro hf
    have ⟨hd, hr⟩ := reducedNeg23_ok f hf
    exact ⟨hr, hd⟩

theorem card_reduced_forms_neg_23 : reducedNeg23.length = 3 :=
  reducedNeg23_length

end FragileProofAudit.Lame.QuadraticWitness
