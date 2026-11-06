module

public import CFSGCorollary.LieType.Steinberg.WeylWord

@[expose] public section

/-!
# Weyl word orbits and partial sums of simple roots

Shared definitions for the per-type root computations in `CFSGCorollary.LieType.Chevalley.Roots`
and the generation proofs in `CFSGCorollary.LieType.Chevalley.Generation`; the Weyl words
`reflectionWord A L` themselves live in `CFSGCorollary.LieType.Steinberg.WeylWord`.

## Main definitions

* `InWeylWordOrbit A L S γ`: `γ` lies in the `⟨w_L⟩`-orbit of an element of `S`.
* `partialSumRoot m i = α₀ + ⋯ + αᵢ`.
* `extendByZero x n`: the coordinates of `x : Fin m → ℤ`, extended by `0` to all of `ℕ`.
-/

namespace CFSGCorollary

/-- `γ = w_Lᵏ ρ` for some `k : ℕ` and `ρ ∈ S`. -/
def InWeylWordOrbit {I : Type} [Fintype I] [DecidableEq I] (A : Matrix I I ℤ) (L : List I)
    (S : Set (I → ℤ)) (γ : I → ℤ) : Prop :=
  ∃ (k : ℕ) (ρ : I → ℤ), ρ ∈ S ∧ (reflectionWord A L ^ k) ρ = γ

/-- The partial sum `α₀ + ⋯ + αᵢ` of the simple roots. -/
def partialSumRoot (m i : ℕ) : Fin m → ℤ :=
  ∑ j ∈ Finset.univ.filter (fun j : Fin m ↦ j.val ≤ i), Pi.single j 1

theorem partialSumRoot_apply (m i : ℕ) (a : Fin m) :
    partialSumRoot m i a = if a.val ≤ i then 1 else 0 := by
  simp only [partialSumRoot, Finset.sum_apply, Pi.single_apply]
  rw [Finset.sum_ite_eq]
  simp

section ExtendByZero

variable {m : ℕ}

/-- The coordinates of `x : Fin m → ℤ` as a function on `ℕ`, extended by `0`. -/
def extendByZero (x : Fin m → ℤ) (n : ℕ) : ℤ := if h : n < m then x ⟨n, h⟩ else 0

theorem extendByZero_val (x : Fin m → ℤ) (p : Fin m) : extendByZero x p.val = x p := by
  simp [extendByZero]

theorem extendByZero_of_lt (x : Fin m → ℤ) {n : ℕ} (h : n < m) :
    extendByZero x n = x ⟨n, h⟩ := by
  simp [extendByZero, h]

theorem extendByZero_add (x y : Fin m → ℤ) (n : ℕ) :
    extendByZero (x + y) n = extendByZero x n + extendByZero y n := by
  unfold extendByZero; split_ifs <;> simp

theorem extendByZero_sub (x y : Fin m → ℤ) (n : ℕ) :
    extendByZero (x - y) n = extendByZero x n - extendByZero y n := by
  unfold extendByZero; split_ifs <;> simp

theorem extendByZero_neg (x : Fin m → ℤ) (n : ℕ) : extendByZero (-x) n = -extendByZero x n := by
  unfold extendByZero; split_ifs <;> simp

theorem extendByZero_comp_val (f : ℕ → ℤ) (hf : ∀ n, m ≤ n → f n = 0) (n : ℕ) :
    extendByZero (fun p : Fin m ↦ f p.val) n = f n := by
  unfold extendByZero; split_ifs with h
  · rfl
  · exact (hf n (by omega)).symm

end ExtendByZero

end CFSGCorollary
