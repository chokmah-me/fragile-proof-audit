/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/
import FragileProofAudit.AgohGiuga.Criteria
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.NormNum.Prime

/-!
# Agoh–Giuga kit — finite oracle table

OEIS A007850 terms 1–7 with pinned factorizations. Each row is an
`OracleWitness`: Giuga on the listed primes and Korselt fails.

Matches `results/giuga_oracle_gate_meta.json`. No `native_decide`.
Does **not** claim the Agoh–Giuga conjecture.
-/

namespace FragileProofAudit.AgohGiuga.Oracle

open FragileProofAudit.AgohGiuga.Criteria

/-! ### Helpers for concrete lists -/

theorem mem3 {a b c p : ℕ} (hp : p ∈ ([a, b, c] : List ℕ)) :
    p = a ∨ p = b ∨ p = c := by
  simpa using hp

theorem mem4 {a b c d p : ℕ} (hp : p ∈ ([a, b, c, d] : List ℕ)) :
    p = a ∨ p = b ∨ p = c ∨ p = d := by
  simpa using hp

theorem mem5 {a b c d e p : ℕ}
    (hp : p ∈ ([a, b, c, d, e] : List ℕ)) :
    p = a ∨ p = b ∨ p = c ∨ p = d ∨ p = e := by
  simpa using hp

theorem mem6 {a b c d e f p : ℕ}
    (hp : p ∈ ([a, b, c, d, e, f] : List ℕ)) :
    p = a ∨ p = b ∨ p = c ∨ p = d ∨ p = e ∨ p = f := by
  simpa using hp

theorem mem7 {a b c d e f g p : ℕ}
    (hp : p ∈ ([a, b, c, d, e, f, g] : List ℕ)) :
    p = a ∨ p = b ∨ p = c ∨ p = d ∨ p = e ∨ p = f ∨ p = g := by
  simpa using hp

/-! ### g = 30 = 2·3·5 -/

def factors30 : List ℕ := [2, 3, 5]

theorem giuga_30 : GiugaOnFactors 30 factors30 := by
  refine ⟨by decide, by decide, ?_, ?_⟩
  · intro p hp; rcases mem3 hp with rfl | rfl | rfl <;> norm_num
  · intro p hp; rcases mem3 hp with rfl | rfl | rfl <;> norm_num

theorem not_korselt_30 : ¬ KorseltOnFactors 30 factors30 := by
  intro h
  have h3 : 3 - 1 ∣ 30 - 1 := h.2.2.2 3 (by decide)
  exact absurd h3 (by decide)

theorem oracle_30 : OracleWitness 30 factors30 :=
  ⟨giuga_30, not_korselt_30⟩

/-! ### g = 858 = 2·3·11·13 -/

def factors858 : List ℕ := [2, 3, 11, 13]

theorem giuga_858 : GiugaOnFactors 858 factors858 := by
  refine ⟨by decide, by decide, ?_, ?_⟩
  · intro p hp; rcases mem4 hp with rfl | rfl | rfl | rfl <;> norm_num
  · intro p hp; rcases mem4 hp with rfl | rfl | rfl | rfl <;> norm_num

theorem not_korselt_858 : ¬ KorseltOnFactors 858 factors858 := by
  intro h
  have h3 : 3 - 1 ∣ 858 - 1 := h.2.2.2 3 (by decide)
  exact absurd h3 (by decide)

theorem oracle_858 : OracleWitness 858 factors858 :=
  ⟨giuga_858, not_korselt_858⟩

/-! ### g = 1722 = 2·3·7·41 -/

def factors1722 : List ℕ := [2, 3, 7, 41]

theorem giuga_1722 : GiugaOnFactors 1722 factors1722 := by
  refine ⟨by decide, by decide, ?_, ?_⟩
  · intro p hp; rcases mem4 hp with rfl | rfl | rfl | rfl <;> norm_num
  · intro p hp; rcases mem4 hp with rfl | rfl | rfl | rfl <;> norm_num

theorem not_korselt_1722 : ¬ KorseltOnFactors 1722 factors1722 := by
  intro h
  have h3 : 3 - 1 ∣ 1722 - 1 := h.2.2.2 3 (by decide)
  exact absurd h3 (by decide)

theorem oracle_1722 : OracleWitness 1722 factors1722 :=
  ⟨giuga_1722, not_korselt_1722⟩

/-! ### g = 66198 = 2·3·11·17·59 -/

def factors66198 : List ℕ := [2, 3, 11, 17, 59]

theorem giuga_66198 : GiugaOnFactors 66198 factors66198 := by
  refine ⟨by decide, by decide, ?_, ?_⟩
  · intro p hp; rcases mem5 hp with rfl | rfl | rfl | rfl | rfl <;> norm_num
  · intro p hp; rcases mem5 hp with rfl | rfl | rfl | rfl | rfl <;> norm_num

theorem not_korselt_66198 : ¬ KorseltOnFactors 66198 factors66198 := by
  intro h
  have h3 : 3 - 1 ∣ 66198 - 1 := h.2.2.2 3 (by decide)
  exact absurd h3 (by decide)

theorem oracle_66198 : OracleWitness 66198 factors66198 :=
  ⟨giuga_66198, not_korselt_66198⟩

/-! ### g = 2214408306 = 2·3·11·23·31·47057 -/

def factors2214408306 : List ℕ := [2, 3, 11, 23, 31, 47057]

theorem giuga_2214408306 : GiugaOnFactors 2214408306 factors2214408306 := by
  refine ⟨by decide, by decide, ?_, ?_⟩
  · intro p hp
    rcases mem6 hp with rfl | rfl | rfl | rfl | rfl | rfl <;> norm_num
  · intro p hp
    rcases mem6 hp with rfl | rfl | rfl | rfl | rfl | rfl <;> norm_num

theorem not_korselt_2214408306 :
    ¬ KorseltOnFactors 2214408306 factors2214408306 := by
  intro h
  have h3 : 3 - 1 ∣ 2214408306 - 1 := h.2.2.2 3 (by decide)
  exact absurd h3 (by decide)

theorem oracle_2214408306 : OracleWitness 2214408306 factors2214408306 :=
  ⟨giuga_2214408306, not_korselt_2214408306⟩

/-! ### g = 24423128562 = 2·3·7·43·3041·4447 -/

def factors24423128562 : List ℕ := [2, 3, 7, 43, 3041, 4447]

theorem giuga_24423128562 : GiugaOnFactors 24423128562 factors24423128562 := by
  refine ⟨by decide, by decide, ?_, ?_⟩
  · intro p hp
    rcases mem6 hp with rfl | rfl | rfl | rfl | rfl | rfl <;> norm_num
  · intro p hp
    rcases mem6 hp with rfl | rfl | rfl | rfl | rfl | rfl <;> norm_num

theorem not_korselt_24423128562 :
    ¬ KorseltOnFactors 24423128562 factors24423128562 := by
  intro h
  have h3 : 3 - 1 ∣ 24423128562 - 1 := h.2.2.2 3 (by decide)
  exact absurd h3 (by decide)

theorem oracle_24423128562 : OracleWitness 24423128562 factors24423128562 :=
  ⟨giuga_24423128562, not_korselt_24423128562⟩

/-! ### g = 432749205173838 = 2·3·7·59·163·1381·775807 (OEIS A007850 #7) -/

def factors432749205173838 : List ℕ := [2, 3, 7, 59, 163, 1381, 775807]

theorem giuga_432749205173838 :
    GiugaOnFactors 432749205173838 factors432749205173838 := by
  refine ⟨by decide, by decide, ?_, ?_⟩
  · intro p hp
    rcases mem7 hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> norm_num
  · intro p hp
    rcases mem7 hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> norm_num

theorem not_korselt_432749205173838 :
    ¬ KorseltOnFactors 432749205173838 factors432749205173838 := by
  intro h
  have h3 : 3 - 1 ∣ 432749205173838 - 1 := h.2.2.2 3 (by decide)
  exact absurd h3 (by decide)

theorem oracle_432749205173838 :
    OracleWitness 432749205173838 factors432749205173838 :=
  ⟨giuga_432749205173838, not_korselt_432749205173838⟩

/-! ### Bundle -/

/-- All seven classical oracle rows. -/
theorem oracle_seven :
    OracleWitness 30 factors30 ∧
      OracleWitness 858 factors858 ∧
      OracleWitness 1722 factors1722 ∧
      OracleWitness 66198 factors66198 ∧
      OracleWitness 2214408306 factors2214408306 ∧
      OracleWitness 24423128562 factors24423128562 ∧
      OracleWitness 432749205173838 factors432749205173838 :=
  ⟨oracle_30, oracle_858, oracle_1722, oracle_66198, oracle_2214408306,
    oracle_24423128562, oracle_432749205173838⟩

end FragileProofAudit.AgohGiuga.Oracle
