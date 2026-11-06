module

public import CFSGCorollary.LieType.Chevalley.Roots.TypeCCardTwo
public import CFSG.LieType.Steinberg.Classical.Symplectic.Basic
public import CFSG.Monster.B.TwoA.Census.PermClasses
import CFSG.LieType.Steinberg.Classical.Symplectic.Weyl
import CFSGCorollary.LieType.Chevalley.Roots.TypeCCardLarge

@[expose] public section

/-!
# A commutator identity in `Sp(2m, K)` in characteristic `2`

Let `m ≥ 3`, let `L' = [m-1, …, 0]` be the Coxeter word of type `C_m`, `ω = ω(L')`,
`r' = α₀ + ⋯ + α_{m-2}`, `s' = -α_{m-1}`, `y = x_{r'}(1) x_{s'}(1)` and `yₖ = ωᵏ y ω⁻ᵏ`.
Steinberg's treatment of `Sp(2m, 2)` [Steinberg1962, §3.14] rests on the identity
`⁅y, ⁅y_{m+1}, ⁅y, y_m⁆⁆⁆ = x_{α_{m-2}}(1)`, which we prove for the symplectic Steinberg system
`CFSG.LieType.Steinberg.Sp.x m F` over any field `F` of characteristic `2`.

In standard coordinates `w' = reflectionWord (cartanC m) L'` acts as the negacyclic shift
`negacyclicShift m`, which identifies all the root elements involved. They are all supported on
the coordinates `0, m-2, m-1`, so they lie in the image of the block embedding `blockHom` of
`3 × 3`-block matrices over `𝔽₂`, and the identity reduces to a finite computation over `𝔽₂`,
checked by `decide`.

## Main definitions

* `TypeCCardTwo.productElement`, `TypeCCardTwo.conjPowElement`: the elements `y` and `yₖ`.
* `TypeCCardTwo.CommutatorIdentity`: the identity above, for an arbitrary root-element map.

## Main results

* `TypeCCardTwo.commutatorIdentity_sp`: the identity holds in `Sp(2m, F)` when `char F = 2`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

namespace CFSGCorollary

namespace TypeCCardTwo

open CFSG.LieType.Universal.Symplectic
open scoped commutatorElement

section Statement

variable {m : ℕ} {K G : Type*} [Field K] [Group G]

/-- `y = x_{r'}(1) x_{s'}(1)`. -/
def productElement (hm : 3 ≤ m) (x : (Fin m → ℤ) → K → G) : G :=
  x (rootR m) 1 * x (rootS m (by omega)) 1

/-- `yₖ = ω(L')ᵏ y ω(L')⁻ᵏ`. -/
def conjPowElement (hm : 3 ≤ m) (x : (Fin m → ℤ) → K → G) (k : ℕ) : G :=
  weylWordElement x (coxeterList m) ^ k * productElement hm x *
    (weylWordElement x (coxeterList m) ^ k)⁻¹

/-- The identity `⁅y, ⁅y_{m+1}, ⁅y, y_m⁆⁆⁆ = x_{α_{m-2}}(1)`. -/
def CommutatorIdentity (hm : 3 ≤ m) (x : (Fin m → ℤ) → K → G) : Prop :=
  ⁅productElement hm x, ⁅conjPowElement hm x (m + 1),
      ⁅productElement hm x, conjPowElement hm x m⁆⁆⁆ =
    x (Pi.single (⟨m - 2, by omega⟩ : Fin m) 1) 1

end Statement

open CFSG.LieType.RootSystem CFSG.LieType.Steinberg CFSG.LieType.Steinberg.Sp
  TauCeti.GLSymplecticFin CFSG.LieType.Universal.Symplectic.SpExtras
open scoped Matrix

private theorem mul_conj_mul {H : Type*} [Group H] (a p X : H) :
    a * p * X * (a * p)⁻¹ = a * (p * X * p⁻¹) * a⁻¹ := by
  group

/-! ### Conjugation by `ω(L)` -/

/-- In characteristic `2`, conjugating `x_β(1)` by `ω(L)` gives `x_{w_L β}(1)`. -/
theorem weylWordElement_conj {m : ℕ} {F : Type} [Field F] [CharP F 2] (L : List (Fin m))
    {β : Fin m → ℤ} (hβ : β ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanC m) ∅) :
    weylWordElement (Sp.x m F) L * Sp.x m F β 1 * (weylWordElement (Sp.x m F) L)⁻¹ =
      Sp.x m F (reflectionWord (cartanC m) L β) 1 ∧
    reflectionWord (cartanC m) L β ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanC m) ∅ := by
  induction L with
  | nil => simp [weylWordElement, reflectionWord, hβ]
  | cons i L ih =>
    obtain ⟨h1, h2⟩ := ih
    have hw : reflectionWord (cartanC m) (i :: L) β =
        reflection (cartanC m) i (reflectionWord (cartanC m) L β) := by
      simp [reflectionWord]
    refine ⟨?_, hw ▸ (Φ m F).refl_mem i _ h2⟩
    obtain ⟨ε, hε, hc⟩ := Sp.weyl (F := F) i h2
    have hε' : (ε : F) = 1 := by
      rcases hε with rfl | rfl
      · simp
      · rw [Int.cast_neg, Int.cast_one, CharTwo.neg_eq]
    rw [hw]
    simp only [weylWordElement, List.map_cons, List.prod_cons] at h1 ⊢
    rw [mul_conj_mul, h1, hc 1 1]
    simp [hε']

/-! ### `w'` as a negacyclic shift -/

/-- The prefix `s_{j-1} ⋯ s_0` of the Coxeter word. -/
noncomputable def prefixWord (m j : ℕ) : Module.End ℤ (Fin m → ℤ) :=
  ((((List.finRange m).take j).reverse).map (reflection (cartanC m))).prod

theorem prefixWord_succ {m j : ℕ} (hj : j < m) :
    prefixWord m (j + 1) = reflection (cartanC m) ⟨j, hj⟩ * prefixWord m j := by
  rw [prefixWord, List.take_add_one, List.getElem?_eq_getElem (by simpa using hj)]
  simp [prefixWord]

theorem prefixWord_zero (m : ℕ) : prefixWord m 0 = 1 := by simp [prefixWord]

theorem toStd_prefixWord_apply {m : ℕ} (v : Fin m → ℤ) :
    ∀ j (hj : j < m) (a : Fin m), toStd m (prefixWord m j v) a =
      if h : a.val < j then toStd m v ⟨a.val + 1, by omega⟩
      else if a.val = j then toStd m v ⟨0, by omega⟩ else toStd m v a := by
  intro j
  induction j with
  | zero =>
    intro hj a
    rw [prefixWord_zero]
    by_cases ha : a.val = 0
    · have : a = ⟨0, hj⟩ := Fin.ext ha
      subst this; simp
    · simp [ha]
  | succ j ih =>
    intro hj a
    have hj' : j < m := by omega
    have hlt : (⟨j, hj'⟩ : Fin m).val + 1 < m := by simp; omega
    rw [prefixWord_succ hj', Module.End.mul_apply, toStd_reflection_of_lt hlt, Function.comp_apply,
      ih hj']
    by_cases h1 : a.val < j
    · have : Equiv.swap (⟨j, hj'⟩ : Fin m) ⟨(⟨j, hj'⟩ : Fin m).val + 1, hlt⟩ a = a :=
        Equiv.swap_apply_of_ne_of_ne (by simp [Fin.ext_iff]; omega) (by simp [Fin.ext_iff]; omega)
      rw [this]; simp [h1, show a.val < j + 1 by omega]
    by_cases h2 : a.val = j
    · have : a = ⟨j, hj'⟩ := Fin.ext h2
      subst this
      simp
    by_cases h3 : a.val = j + 1
    · have : a = ⟨(⟨j, hj'⟩ : Fin m).val + 1, hlt⟩ := Fin.ext (by simpa using h3)
      subst this
      simp
    · have : Equiv.swap (⟨j, hj'⟩ : Fin m) ⟨(⟨j, hj'⟩ : Fin m).val + 1, hlt⟩ a = a :=
        Equiv.swap_apply_of_ne_of_ne (by simp [Fin.ext_iff]; omega) (by simp [Fin.ext_iff]; omega)
      rw [this]; simp [h1, h2, h3, show ¬a.val < j + 1 by omega]

/-- The negacyclic shift `u ↦ (u₁, …, u_{m-1}, -u₀)`: the action of `w'` in standard
coordinates. -/
def negacyclicShift (m : ℕ) (u : Fin m → ℤ) : Fin m → ℤ := fun a ↦
  if h : a.val + 1 < m then u ⟨a.val + 1, h⟩ else -u ⟨0, by have := a.2; omega⟩

theorem toStd_reflectionWord_coxeterList (m : ℕ) (v : Fin m → ℤ) :
    toStd m (reflectionWord (cartanC m) (coxeterList m) v) = negacyclicShift m (toStd m v) := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · funext a; exact a.elim0
  have hw : reflectionWord (cartanC m) (coxeterList m) = prefixWord m m := by
    have : (List.finRange m).take m = List.finRange m := List.take_of_length_le (by simp)
    simp [reflectionWord, coxeterList, prefixWord, this]
  have hm1 : m - 1 < m := by omega
  have hlt : ¬ (⟨m - 1, hm1⟩ : Fin m).val + 1 < m := by simp; omega
  have hs : prefixWord m m = reflection (cartanC m) ⟨m - 1, hm1⟩ * prefixWord m (m - 1) := by
    have := prefixWord_succ hm1
    rwa [Nat.sub_add_cancel hm] at this
  funext a
  rw [hw, hs, Module.End.mul_apply, toStd_reflection_of_not_lt hlt]
  beta_reduce
  rw [toStd_prefixWord_apply _ _ hm1]
  by_cases h : a.val + 1 < m
  · have : a ≠ ⟨m - 1, hm1⟩ := by simp [Fin.ext_iff]; omega
    simp [negacyclicShift, h, this, show a.val < m - 1 by omega]
  · have : a = ⟨m - 1, hm1⟩ := Fin.ext (by simp; omega)
    subst this
    simp [negacyclicShift, h]

theorem toStd_reflectionWord_pow (m : ℕ) (k : ℕ) (v : Fin m → ℤ) :
    toStd m ((reflectionWord (cartanC m) (coxeterList m) ^ k) v) =
      (negacyclicShift m)^[k] (toStd m v) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ', Module.End.mul_apply, toStd_reflectionWord_coxeterList, ih,
      Function.iterate_succ_apply']

theorem negacyclicShift_apply {m : ℕ} (u : Fin m → ℤ) (a : Fin m) :
    negacyclicShift m u a =
      if a.val + 1 < m then extendByZero u (a.val + 1) else -extendByZero u 0 := by
  have hm : 0 < m := by have := a.2; omega
  by_cases h : a.val + 1 < m <;> simp [negacyclicShift, extendByZero, h, hm]

theorem negacyclicShift_iterate_apply (m : ℕ) (u : Fin m → ℤ) (k : ℕ) (hk : k ≤ m) (a : Fin m) :
    (negacyclicShift m)^[k] u a =
      if a.val + k < m then extendByZero u (a.val + k)
      else -extendByZero u (a.val + k - m) := by
  induction k generalizing a with
  | zero => simp [extendByZero, a.2]
  | succ k ih =>
    rw [Function.iterate_succ_apply', negacyclicShift_apply]
    by_cases h : a.val + 1 < m
    · have e : (negacyclicShift m)^[k] u ⟨a.val + 1, h⟩ = _ := ih (by omega) ⟨a.val + 1, h⟩
      simp only [h, ite_true]
      rw [extendByZero, dite_eq_left h]
      dsimp only at e
      rw [e]
      by_cases h2 : a.val + 1 + k < m
      · simp only [h2, ite_true, show a.val + (k + 1) < m by omega]
        congr 1; omega
      · simp only [h2, ite_false, show ¬a.val + (k + 1) < m by omega]
        congr 2; omega
    · have e : (negacyclicShift m)^[k] u ⟨0, by omega⟩ = _ := ih (by omega) ⟨0, by omega⟩
      simp only [h, ite_false]
      rw [extendByZero, dite_eq_left (by omega)]
      dsimp only at e
      rw [e]
      have : a.val + 1 = m := by have := a.2; omega
      simp only [show 0 + k < m by omega, ite_true, show ¬a.val + (k + 1) < m by omega,
        ite_false]
      congr 3; omega

theorem negacyclicShift_iterate_eq_neg (m : ℕ) (u : Fin m → ℤ) :
    (negacyclicShift m)^[m] u = -u := by
  funext a
  rw [negacyclicShift_iterate_apply m u m le_rfl]
  simp [extendByZero, a.2]

theorem negacyclicShift_neg (m : ℕ) (u : Fin m → ℤ) :
    negacyclicShift m (-u) = -negacyclicShift m u := by
  funext a
  by_cases h : a.val + 1 < m <;> simp [negacyclicShift, h]

/-! ### The block embedding on the coordinates `0, m-2, m-1` -/

/-- The three indices `0, m-2, m-1`. -/
def blockIndex {m : ℕ} (hm : 3 ≤ m) : Fin 3 → Fin m :=
  ![⟨0, by omega⟩, ⟨m - 2, by omega⟩, ⟨m - 1, by omega⟩]

theorem blockIndex_injective {m : ℕ} (hm : 3 ≤ m) : Function.Injective (blockIndex hm) := by
  intro a b h
  fin_cases a <;> fin_cases b <;> simp [blockIndex, Fin.ext_iff] at h ⊢ <;> omega

/-- `blockIndex` on both halves of the symplectic index set `Fin m ⊕ Fin m`. -/
def blockSum {m : ℕ} (hm : 3 ≤ m) : Fin 3 ⊕ Fin 3 → Fin m ⊕ Fin m :=
  Sum.map (blockIndex hm) (blockIndex hm)

theorem blockSum_injective {m : ℕ} (hm : 3 ≤ m) : Function.Injective (blockSum hm) :=
  Sum.map_injective.2 ⟨blockIndex_injective hm, blockIndex_injective hm⟩

variable {R : Type*} [CommRing R]

/-- The `0`-`1` matrix `P` of the coordinate inclusion `blockSum`. -/
def blockInclusion {m : ℕ} (hm : 3 ≤ m) (R : Type*) [CommRing R] :
    Matrix (Fin m ⊕ Fin m) (Fin 3 ⊕ Fin 3) R :=
  Matrix.of fun a j ↦ if a = blockSum hm j then 1 else 0

theorem blockInclusion_transpose_mul {m : ℕ} (hm : 3 ≤ m) :
    (blockInclusion hm R)ᵀ * blockInclusion hm R = 1 := by
  ext i j
  simp only [Matrix.mul_apply, Matrix.transpose_apply, blockInclusion, Matrix.of_apply,
    Matrix.one_apply]
  simp [(blockSum_injective hm).eq_iff, eq_comm]

theorem blockInclusion_mul_single_apply {m : ℕ} (hm : 3 ≤ m) (j k : Fin 3 ⊕ Fin 3) (c : R)
    (a : Fin m ⊕ Fin m) (l : Fin 3 ⊕ Fin 3) :
    (blockInclusion hm R * Matrix.single j k c) a l =
      if a = blockSum hm j ∧ k = l then c else 0 := by
  rw [Matrix.mul_apply, Finset.sum_eq_single j]
  · simp only [blockInclusion, Matrix.of_apply, Matrix.single_apply]
    by_cases h1 : a = blockSum hm j <;> by_cases h2 : k = l <;> simp [h1, h2]
  · intro x _ hx
    simp [hx.symm]
  · simp

theorem blockInclusion_mul_single_mul_transpose {m : ℕ} (hm : 3 ≤ m) (j k : Fin 3 ⊕ Fin 3)
    (c : R) :
    blockInclusion hm R * Matrix.single j k c * (blockInclusion hm R)ᵀ =
      Matrix.single (blockSum hm j) (blockSum hm k) c := by
  ext a b
  rw [Matrix.mul_apply, Finset.sum_eq_single k]
  · rw [blockInclusion_mul_single_apply]
    simp only [Matrix.transpose_apply, blockInclusion, Matrix.of_apply, Matrix.single_apply]
    by_cases h1 : a = blockSum hm j <;> by_cases h2 : b = blockSum hm k <;> simp [h1, h2, eq_comm]
  · intro x _ hx
    rw [blockInclusion_mul_single_apply]
    simp [hx.symm]
  · simp

/-- The block embedding `B ↦ 1 - P Pᵀ + P B Pᵀ`, a monoid hom. -/
def blockEmbedding {m : ℕ} (hm : 3 ≤ m) (R : Type*) [CommRing R] :
    Matrix (Fin 3 ⊕ Fin 3) (Fin 3 ⊕ Fin 3) R →* Matrix (Fin m ⊕ Fin m) (Fin m ⊕ Fin m) R where
  toFun B := 1 - blockInclusion hm R * (blockInclusion hm R)ᵀ +
    blockInclusion hm R * B * (blockInclusion hm R)ᵀ
  map_one' := by simp
  map_mul' B C := by
    have h := blockInclusion_transpose_mul (R := R) hm
    set P := blockInclusion hm R
    have f1 : (P * Pᵀ) * (P * Pᵀ) = P * Pᵀ := by
      rw [Matrix.mul_assoc, ← Matrix.mul_assoc Pᵀ P, h, Matrix.one_mul]
    have f2 : ∀ X : Matrix (Fin 3 ⊕ Fin 3) (Fin 3 ⊕ Fin 3) R,
        (P * Pᵀ) * (P * X * Pᵀ) = P * X * Pᵀ := by
      intro X
      rw [← Matrix.mul_assoc, ← Matrix.mul_assoc, Matrix.mul_assoc P Pᵀ P, h, Matrix.mul_one,
        Matrix.mul_assoc]
    have f3 : ∀ X : Matrix (Fin 3 ⊕ Fin 3) (Fin 3 ⊕ Fin 3) R,
        (P * X * Pᵀ) * (P * Pᵀ) = P * X * Pᵀ := by
      intro X
      rw [Matrix.mul_assoc, Matrix.mul_assoc, ← Matrix.mul_assoc Pᵀ P, h, Matrix.one_mul,
        Matrix.mul_assoc]
    have f4 : (P * B * Pᵀ) * (P * C * Pᵀ) = P * (B * C) * Pᵀ := by
      calc (P * B * Pᵀ) * (P * C * Pᵀ) = P * B * (Pᵀ * P) * C * Pᵀ := by
            simp only [Matrix.mul_assoc]
        _ = _ := by rw [h]; simp [Matrix.mul_assoc]
    simp only [sub_mul, mul_sub, add_mul, mul_add, Matrix.one_mul, Matrix.mul_one, f1, f2, f3, f4]
    abel

theorem blockEmbedding_apply {m : ℕ} (hm : 3 ≤ m) (B : Matrix (Fin 3 ⊕ Fin 3) (Fin 3 ⊕ Fin 3) R) :
    blockEmbedding hm R B = 1 - blockInclusion hm R * (blockInclusion hm R)ᵀ +
      blockInclusion hm R * B * (blockInclusion hm R)ᵀ := rfl

theorem blockEmbedding_one_add {m : ℕ} (hm : 3 ≤ m)
    (B : Matrix (Fin 3 ⊕ Fin 3) (Fin 3 ⊕ Fin 3) R) :
    blockEmbedding hm R (1 + B) = 1 + blockInclusion hm R * B * (blockInclusion hm R)ᵀ := by
  rw [blockEmbedding_apply, Matrix.mul_add, Matrix.add_mul, Matrix.mul_one]
  abel

section embedE

variable {m : ℕ} (hm : 3 ≤ m) (F : Type) [Field F]

theorem blockInclusion_mul_E_difference_mul_transpose (i j : Fin 3) (hij : i ≠ j) :
    blockInclusion hm F * E F (RootSubgroupIndex.difference i j hij) * (blockInclusion hm F)ᵀ =
      E F (RootSubgroupIndex.difference (blockIndex hm i) (blockIndex hm j)
        (fun h ↦ hij (blockIndex_injective hm h))) := by
  simp only [E, Matrix.mul_sub, Matrix.sub_mul, blockInclusion_mul_single_mul_transpose, blockSum,
    Sum.map_inl, Sum.map_inr]

theorem blockInclusion_mul_E_positiveLong_mul_transpose (i : Fin 3) :
    blockInclusion hm F * E F (RootSubgroupIndex.positiveLong i) * (blockInclusion hm F)ᵀ =
      E F (RootSubgroupIndex.positiveLong (blockIndex hm i)) := by
  simp only [E, blockInclusion_mul_single_mul_transpose, blockSum, Sum.map_inl, Sum.map_inr]

theorem blockInclusion_mul_E_negativeLong_mul_transpose (i : Fin 3) :
    blockInclusion hm F * E F (RootSubgroupIndex.negativeLong i) * (blockInclusion hm F)ᵀ =
      E F (RootSubgroupIndex.negativeLong (blockIndex hm i)) := by
  simp only [E, blockInclusion_mul_single_mul_transpose, blockSum, Sum.map_inl, Sum.map_inr]

theorem blockInclusion_mul_E_positiveSum_mul_transpose (i j : Fin 3) (hij : i < j)
    (hij' : blockIndex hm i < blockIndex hm j) :
    blockInclusion hm F * E F (RootSubgroupIndex.positiveSum i j hij) * (blockInclusion hm F)ᵀ =
      E F (RootSubgroupIndex.positiveSum (blockIndex hm i) (blockIndex hm j) hij') := by
  simp only [E, Matrix.mul_add, Matrix.add_mul, blockInclusion_mul_single_mul_transpose, blockSum,
    Sum.map_inl, Sum.map_inr]

end embedE

/-! ### Root elements of `Sp(2m, F)` in characteristic `2` -/

theorem weylWordElement_pow_conj {m : ℕ} {F : Type} [Field F] [CharP F 2] (k : ℕ)
    {β : Fin m → ℤ} (hβ : β ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanC m) ∅) :
    weylWordElement (Sp.x m F) (coxeterList m) ^ k * Sp.x m F β 1 *
        (weylWordElement (Sp.x m F) (coxeterList m) ^ k)⁻¹ =
      Sp.x m F ((reflectionWord (cartanC m) (coxeterList m) ^ k) β) 1 ∧
    (reflectionWord (cartanC m) (coxeterList m) ^ k) β ∈
      CFSG.LieType.RootSystem.roots (isFiniteType_cartanC m) ∅ := by
  induction k with
  | zero => simp [hβ]
  | succ k ih =>
    obtain ⟨h1, h2⟩ := ih
    obtain ⟨h3, h4⟩ := weylWordElement_conj (F := F) (coxeterList m) h2
    refine ⟨?_, ?_⟩
    · rw [pow_succ', pow_succ', Module.End.mul_apply, mul_conj_mul, h1, h3]
    · rw [pow_succ', Module.End.mul_apply]; exact h4

theorem weylWordElement_pow_conj_eq_elt {m : ℕ} {F : Type} [Field F] [CharP F 2] (k : ℕ)
    {β : Fin m → ℤ} (hβ : β ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanC m) ∅)
    (r : RootSubgroupIndex m)
    (hr : toStd m ((reflectionWord (cartanC m) (coxeterList m) ^ k) β) = stdVec r) :
    weylWordElement (Sp.x m F) (coxeterList m) ^ k * Sp.x m F β 1 *
        (weylWordElement (Sp.x m F) (coxeterList m) ^ k)⁻¹ =
      elt r (1 : F) := by
  rw [(weylWordElement_pow_conj k hβ).1, Sp.x_eq hr.symm]

theorem inv_elt_one {m : ℕ} {F : Type} [Field F] [CharP F 2] (r : RootSubgroupIndex m) :
    (elt r (1 : F))⁻¹ = elt r 1 := by
  apply inv_eq_of_mul_eq_one_right
  rw [← elt_add, CharTwo.add_self_eq_zero, elt_zero]

section roots

variable {m : ℕ} (hm : 3 ≤ m)

theorem blockIndex_zero : blockIndex hm 0 = ⟨0, by omega⟩ := rfl
theorem blockIndex_one : blockIndex hm 1 = ⟨m - 2, by omega⟩ := rfl
theorem blockIndex_two : blockIndex hm 2 = ⟨m - 1, by omega⟩ := rfl

theorem blockIndex_one_lt_two : blockIndex hm 1 < blockIndex hm 2 := by
  rw [blockIndex_one, blockIndex_two]; exact Fin.mk_lt_mk.2 (by omega)

/-- The root `e₀ - e_{m-1}` (this is `r'`). -/
def blockDifferenceZeroTwo : RootSubgroupIndex m :=
  .difference (blockIndex hm 0) (blockIndex hm 2) (fun h ↦ by
    have := congrArg Fin.val h; simp [blockIndex_zero, blockIndex_two] at this; omega)

/-- The root `-2e_{m-1}` (this is `s'`). -/
def blockNegativeLongTwo : RootSubgroupIndex m := .negativeLong (blockIndex hm 2)

/-- The root `e_{m-1} - e₀`. -/
def blockDifferenceTwoZero : RootSubgroupIndex m :=
  .difference (blockIndex hm 2) (blockIndex hm 0) (fun h ↦ by
    have := congrArg Fin.val h; simp [blockIndex_zero, blockIndex_two] at this; omega)

/-- The root `2e_{m-1}`. -/
def blockPositiveLongTwo : RootSubgroupIndex m := .positiveLong (blockIndex hm 2)

/-- The root `e_{m-2} + e_{m-1}`. -/
def blockPositiveSumOneTwo : RootSubgroupIndex m :=
  .positiveSum (blockIndex hm 1) (blockIndex hm 2) (blockIndex_one_lt_two hm)

/-- The root `2e_{m-2}`. -/
def blockPositiveLongOne : RootSubgroupIndex m := .positiveLong (blockIndex hm 1)

/-- The root `e_{m-2} - e_{m-1}` (this is `α_{m-2}`). -/
def blockDifferenceOneTwo : RootSubgroupIndex m :=
  .difference (blockIndex hm 1) (blockIndex hm 2) (fun h ↦ by
    have := congrArg Fin.val h; simp [blockIndex_one, blockIndex_two] at this; omega)

theorem toStd_rootR : toStd m (rootR m) = stdVec (blockDifferenceZeroTwo hm) := by
  funext a
  simp only [toStd, rootR, partialSumRoot_apply, stdVec, blockDifferenceZeroTwo, blockIndex_zero,
    blockIndex_two, Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
  split_ifs <;> omega

theorem toStd_rootS : toStd m (rootS m (by omega)) = stdVec (blockNegativeLongTwo hm) := by
  rw [rootS, SpExtras.toStd_neg', SpExtras.toStd_single_of_not_lt' (by simp; omega),
    blockNegativeLongTwo, blockIndex_two]
  rfl

theorem stdVec_blockDifferenceTwoZero :
    stdVec (blockDifferenceTwoZero hm) = -stdVec (blockDifferenceZeroTwo hm) := by
  simp [stdVec, blockDifferenceTwoZero, blockDifferenceZeroTwo, neg_sub]

theorem stdVec_blockPositiveLongTwo :
    stdVec (blockPositiveLongTwo hm) = -stdVec (blockNegativeLongTwo hm) := by
  simp [stdVec, blockPositiveLongTwo, blockNegativeLongTwo]

theorem stdVec_blockPositiveSumOneTwo :
    stdVec (blockPositiveSumOneTwo hm) =
      -negacyclicShift m (stdVec (blockDifferenceZeroTwo hm)) := by
  funext a
  simp only [negacyclicShift, stdVec, blockPositiveSumOneTwo, blockDifferenceZeroTwo,
    blockIndex_zero, blockIndex_one, blockIndex_two, Pi.add_apply, Pi.sub_apply, Pi.neg_apply,
    Pi.single_apply, Fin.ext_iff]
  split_ifs <;> first | omega | (exfalso; assumption)

theorem stdVec_blockPositiveLongOne :
    stdVec (blockPositiveLongOne hm) = -negacyclicShift m (stdVec (blockNegativeLongTwo hm)) := by
  funext a
  simp only [negacyclicShift, stdVec, blockPositiveLongOne, blockNegativeLongTwo, blockIndex_one,
    blockIndex_two, Pi.neg_apply, Pi.smul_apply, Pi.single_apply, Fin.ext_iff, nsmul_eq_mul,
    Pi.mul_apply, Pi.ofNat_apply, Nat.cast_ofNat]
  split_ifs <;> omega

end roots

/-! ### Reduction to `3 × 3` blocks over `𝔽₂` -/

/-- The `𝔽₂`-matrix `1 + E_r` of a root element of the `3 × 3` block. -/
abbrev blockEltMatrix (r : RootSubgroupIndex 3) :
    Matrix (Fin 3 ⊕ Fin 3) (Fin 3 ⊕ Fin 3) (ZMod 2) :=
  1 + (Ez r).map (Int.castRingHom (ZMod 2))

section assembly

variable {m : ℕ} (hm : 3 ≤ m) {F : Type} [Field F] [CharP F 2]

/-- The block embedding of `3 × 3`-block matrices over `𝔽₂` into `2m × 2m` matrices over `F`. -/
noncomputable def blockHom : Matrix (Fin 3 ⊕ Fin 3) (Fin 3 ⊕ Fin 3) (ZMod 2) →*
    Matrix (Fin m ⊕ Fin m) (Fin m ⊕ Fin m) F :=
  (blockEmbedding hm F).comp (RingHom.mapMatrix (ZMod.castHom (dvd_refl 2) F)).toMonoidHom

theorem mat_elt_eq_blockHom (r3 : RootSubgroupIndex 3) (rm : RootSubgroupIndex m)
    (h : blockInclusion hm F * E F r3 * (blockInclusion hm F)ᵀ = E F rm) :
    mat m F (elt rm (1 : F)) = blockHom hm (blockEltMatrix r3) := by
  rw [mat_elt, one_smul, ← h, blockHom, MonoidHom.comp_apply]
  have : (RingHom.mapMatrix (ZMod.castHom (dvd_refl 2) F)).toMonoidHom (blockEltMatrix r3) =
      1 + E F r3 := by
    ext i j
    by_cases h : i = j <;> simp [blockEltMatrix, E_eq_map, Matrix.map_apply, h]
  rw [this, blockEmbedding_one_add]

theorem productElement_eq :
    productElement hm (Sp.x m F) =
      elt (blockDifferenceZeroTwo hm) (1 : F) * elt (blockNegativeLongTwo hm) 1 := by
  have h1 := weylWordElement_pow_conj_eq_elt (F := F) 0 (rootR_mem hm)
    (blockDifferenceZeroTwo hm) (by simpa using toStd_rootR hm)
  have h2 := weylWordElement_pow_conj_eq_elt (F := F) 0 (rootS_mem hm)
    (blockNegativeLongTwo hm) (by simpa using toStd_rootS hm)
  simp only [pow_zero, one_mul, inv_one, mul_one] at h1 h2
  rw [productElement, h1, h2]

theorem conjPowElement_eq (k : ℕ) (r s : RootSubgroupIndex m)
    (hr : (negacyclicShift m)^[k] (stdVec (blockDifferenceZeroTwo hm)) = stdVec r)
    (hs : (negacyclicShift m)^[k] (stdVec (blockNegativeLongTwo hm)) = stdVec s) :
    conjPowElement hm (Sp.x m F) k = elt r (1 : F) * elt s 1 := by
  have h1 := weylWordElement_pow_conj_eq_elt (F := F) k (rootR_mem hm) r (by
    rw [toStd_reflectionWord_pow, toStd_rootR hm, hr])
  have h2 := weylWordElement_pow_conj_eq_elt (F := F) k (rootS_mem hm) s (by
    rw [toStd_reflectionWord_pow, toStd_rootS hm, hs])
  rw [← h1, ← h2, conjPowElement, productElement]
  group

omit [CharP F 2] in
theorem x_single_eq_elt :
    Sp.x m F (Pi.single (⟨m - 2, by omega⟩ : Fin m) 1) 1 =
      elt (blockDifferenceOneTwo hm) (1 : F) := by
  apply Sp.x_eq
  rw [SpExtras.toStd_single_of_lt' (k := ⟨m - 2, by omega⟩) (by simp; omega)]
  funext a
  simp only [stdVec, blockDifferenceOneTwo, blockIndex_one, blockIndex_two, Pi.sub_apply,
    Pi.single_apply, Fin.ext_iff]
  split_ifs <;> omega

end assembly

/-- Steinberg's characteristic-`2` commutator identity holds in `Sp(2m, F)` for `m ≥ 3`. -/
theorem commutatorIdentity_sp {m : ℕ} (hm : 3 ≤ m) {F : Type} [Field F] [CharP F 2] :
    CommutatorIdentity hm (Sp.x m F) := by
  have hmm : (negacyclicShift m)^[m] (stdVec (blockDifferenceZeroTwo hm)) =
      stdVec (blockDifferenceTwoZero hm) := by
    rw [negacyclicShift_iterate_eq_neg, stdVec_blockDifferenceTwoZero]
  have hms : (negacyclicShift m)^[m] (stdVec (blockNegativeLongTwo hm)) =
      stdVec (blockPositiveLongTwo hm) := by
    rw [negacyclicShift_iterate_eq_neg, stdVec_blockPositiveLongTwo]
  have hm1 : (negacyclicShift m)^[m + 1] (stdVec (blockDifferenceZeroTwo hm)) =
      stdVec (blockPositiveSumOneTwo hm) := by
    rw [Function.iterate_succ_apply', negacyclicShift_iterate_eq_neg, negacyclicShift_neg,
      stdVec_blockPositiveSumOneTwo]
  have hs1 : (negacyclicShift m)^[m + 1] (stdVec (blockNegativeLongTwo hm)) =
      stdVec (blockPositiveLongOne hm) := by
    rw [Function.iterate_succ_apply', negacyclicShift_iterate_eq_neg, negacyclicShift_neg,
      stdVec_blockPositiveLongOne]
  unfold CommutatorIdentity
  rw [productElement_eq hm, conjPowElement_eq hm m _ _ hmm hms,
    conjPowElement_eq hm (m + 1) _ _ hm1 hs1, x_single_eq_elt hm]
  simp only [commutatorElement_def, mul_inv_rev, inv_elt_one]
  apply mat_injective
  simp only [map_mul]
  rw [mat_elt_eq_blockHom hm (.difference 0 2 (by decide)) (blockDifferenceZeroTwo hm)
      (blockInclusion_mul_E_difference_mul_transpose hm F 0 2 _),
    mat_elt_eq_blockHom hm (.negativeLong 2) (blockNegativeLongTwo hm)
      (blockInclusion_mul_E_negativeLong_mul_transpose hm F 2),
    mat_elt_eq_blockHom hm (.difference 2 0 (by decide)) (blockDifferenceTwoZero hm)
      (blockInclusion_mul_E_difference_mul_transpose hm F 2 0 _),
    mat_elt_eq_blockHom hm (.positiveLong 2) (blockPositiveLongTwo hm)
      (blockInclusion_mul_E_positiveLong_mul_transpose hm F 2),
    mat_elt_eq_blockHom hm (.positiveSum 1 2 (by decide)) (blockPositiveSumOneTwo hm)
      (blockInclusion_mul_E_positiveSum_mul_transpose hm F 1 2 (by decide)
        (blockIndex_one_lt_two hm)),
    mat_elt_eq_blockHom hm (.positiveLong 1) (blockPositiveLongOne hm)
      (blockInclusion_mul_E_positiveLong_mul_transpose hm F 1),
    mat_elt_eq_blockHom hm (.difference 1 2 (by decide)) (blockDifferenceOneTwo hm)
      (blockInclusion_mul_E_difference_mul_transpose hm F 1 2 _)]
  simp only [← map_mul]
  refine congrArg (blockHom hm) ?_
  decide +kernel

end TypeCCardTwo

end CFSGCorollary
