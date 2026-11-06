module

public import CFSGCorollary.LieType.Chevalley.Roots.Basic
public import TauCeti.LinearAlgebra.RootSystem.FiniteType.Classical
import CFSG.LieType.Universal.SpecialLinearRoots

/-!
# Root computations for type `A_m`

Let `A = CartanMatrix.A m` (`m ≥ 1`), `αᵢ = Pi.single i 1`, `θ = α₀ + ⋯ + α_{m-1}` the highest
root, `βᵢ = α₀ + ⋯ + αᵢ = partialSumRoot m i`, `L = [0, 1, …, m-1]` and
`w = reflectionWord A L` the Coxeter element, with inverse `w⁻¹ = reflectionWord A L.reverse`. In
the standard coordinates of CFSG's `SL` model (`toStd`), `w` acts on `Fin (m + 1)` as the cyclic
shift `weylWordPerm m`, from which we read off the action of `w` on the roots needed for the
generation proof in type `A`.

## Main results

* `TypeA.reflectionWord_pow_single_zero`: `wⁱ α₀ = αᵢ`.
* `TypeA.reflectionWord_highestRoot`: `w θ = -α₀`, and `TypeA.reflectionWord_reverse_single_zero`:
  `w⁻¹ α₀ = -θ`.
* `TypeA.onlyPositiveCombination_partialSumRoot`: `βᵢ` is the only positive combination of
  `βᵢ₋₁` and `αᵢ` that is a root.
-/

@[expose] public section

namespace CFSGCorollary

namespace TypeA

open CFSG.LieType.Universal.SpecialLinear
  (toStd toStd_injective toStd_neg toStd_single toStd_reflection roots_eq)

/-- The root system `Φ` of type `A_m` (no doubled indices). -/
abbrev roots (m : ℕ) : Set (Fin m → ℤ) :=
  CFSG.LieType.RootSystem.roots (TauCeti.isFiniteType_cartanMatrix_A m) ∅

/-- `θ = α₀ + ⋯ + α_{m-1}`. -/
def highestRoot (m : ℕ) : Fin m → ℤ := ∑ i : Fin m, Pi.single i 1

variable {m : ℕ}

/-- The permutation of `Fin (m+1)` induced by the first `n` reflections of `coxeterList m`. -/
def prefixPerm (m n : ℕ) (hn : n ≤ m) (a : Fin (m + 1)) : Fin (m + 1) :=
  ⟨if a.val = 0 then n else if a.val ≤ n then a.val - 1 else a.val, by
    split_ifs <;> omega⟩

private theorem reflectionWord_append_single (L : List (Fin m)) (x : Fin m) :
    reflectionWord (CartanMatrix.A m) (L ++ [x]) =
      reflectionWord (CartanMatrix.A m) L *
        CFSG.LieType.RootSystem.reflection (CartanMatrix.A m) x := by
  simp [reflectionWord, List.map_append, List.prod_append]

private theorem take_finRange_succ (n : ℕ) (hn : n < m) :
    (List.finRange m).take (n + 1) = (List.finRange m).take n ++ [⟨n, hn⟩] := by
  rw [List.take_add_one, List.getElem?_eq_getElem (by simp [List.finRange]; omega)]
  simp [List.finRange]

private theorem swap_val (k : Fin m) (b : Fin (m + 1)) :
    (Equiv.swap k.castSucc k.succ b).val =
      if b.val = k.val then k.val + 1 else if b.val = k.val + 1 then k.val else b.val := by
  rw [Equiv.swap_apply_def]
  split_ifs <;> simp_all [Fin.ext_iff]

private theorem toStd_reflectionWord_take (n : ℕ) (hn : n ≤ m) (v : Fin m → ℤ) :
    toStd m (reflectionWord (CartanMatrix.A m) ((List.finRange m).take n) v) =
      toStd m v ∘ prefixPerm m n hn := by
  induction n generalizing v with
  | zero =>
    funext a
    simp only [List.take_zero, reflectionWord, List.map_nil, List.prod_nil, Module.End.one_apply,
      Function.comp_apply]
    congr 1
    ext
    simp only [prefixPerm]
    have := a.isLt
    split_ifs <;> omega
  | succ n ih =>
    rw [take_finRange_succ n (by omega), reflectionWord_append_single, Module.End.mul_apply,
      ih (by omega), toStd_reflection]
    funext a
    simp only [Function.comp_apply]
    congr 1
    apply Fin.ext
    rw [swap_val]
    simp only [prefixPerm]
    have := a.isLt
    split_ifs <;> omega

/-- The cyclic shift of `Fin (m + 1)` by which `w` acts in standard coordinates. -/
def weylWordPerm (m : ℕ) : Fin (m + 1) → Fin (m + 1) := prefixPerm m m le_rfl

private theorem toStd_reflectionWord (v : Fin m → ℤ) :
    toStd m (reflectionWord (CartanMatrix.A m) (List.finRange m) v) =
      toStd m v ∘ weylWordPerm m := by
  have := toStd_reflectionWord_take m le_rfl v
  rwa [List.take_of_length_le (by simp [List.finRange])] at this

private theorem toStd_reflectionWord_pow (n : ℕ) (v : Fin m → ℤ) :
    toStd m ((reflectionWord (CartanMatrix.A m) (List.finRange m) ^ n) v) =
      toStd m v ∘ (weylWordPerm m)^[n] := by
  induction n generalizing v with
  | zero => simp
  | succ n ih =>
    rw [pow_succ, Module.End.mul_apply, ih, toStd_reflectionWord, Function.iterate_succ']
    rfl

private theorem weylWordPerm_val (a : Fin (m + 1)) :
    (weylWordPerm m a).val = if a.val = 0 then m else a.val - 1 := by
  have := a.isLt
  simp only [weylWordPerm, prefixPerm]
  split_ifs <;> omega

private theorem weylWordPerm_iterate_val (i : ℕ) (hi : i ≤ m + 1) (a : Fin (m + 1)) :
    ((weylWordPerm m)^[i] a).val = if i ≤ a.val then a.val - i else a.val + (m + 1) - i := by
  induction i generalizing a with
  | zero => simp
  | succ i ih =>
    rw [Function.iterate_succ_apply, ih (by omega), weylWordPerm_val]
    have := a.isLt
    split_ifs <;> omega

/-- `wⁱ α₀ = αᵢ` for `0 ≤ i ≤ m-1`. -/
theorem reflectionWord_pow_single_zero (hm : 1 ≤ m) (i : Fin m) :
    (reflectionWord (CartanMatrix.A m) (List.finRange m) ^ i.val) (Pi.single ⟨0, hm⟩ 1) =
      Pi.single i 1 := by
  apply toStd_injective m
  rw [toStd_reflectionWord_pow, toStd_single, toStd_single]
  funext a
  have h1 := weylWordPerm_iterate_val i.val (by omega) a
  have := i.isLt
  have := a.isLt
  simp only [Function.comp_apply, Pi.sub_apply, Pi.single_apply, Fin.ext_iff, Fin.val_castSucc,
    Fin.val_succ, h1]
  split_ifs <;> omega

/-- `wⁱ (−α₀) = −αᵢ` for `0 ≤ i ≤ m-1`. -/
theorem reflectionWord_pow_neg_single_zero (hm : 1 ≤ m) (i : Fin m) :
    (reflectionWord (CartanMatrix.A m) (List.finRange m) ^ i.val) (-Pi.single ⟨0, hm⟩ 1) =
      -Pi.single i 1 := by
  rw [map_neg, reflectionWord_pow_single_zero hm]

private theorem highestRoot_eq (m : ℕ) : highestRoot m = fun _ ↦ 1 := by
  funext j
  simp [highestRoot, Finset.sum_apply, Pi.single_apply]

/-- `w θ = −α₀`. -/
theorem reflectionWord_highestRoot (hm : 1 ≤ m) :
    reflectionWord (CartanMatrix.A m) (List.finRange m) (highestRoot m) = -Pi.single ⟨0, hm⟩ 1 := by
  apply toStd_injective m
  rw [toStd_reflectionWord, toStd_neg, toStd_single, highestRoot_eq]
  funext a
  have := a.isLt
  have hs := weylWordPerm_val a
  have h3 : toStd m (fun _ ↦ 1) (weylWordPerm m a) =
        (if (weylWordPerm m a).val < m then 1 else 0) -
          (if 0 < (weylWordPerm m a).val then 1 else 0) := by
    simp [toStd]
  simp only [Function.comp_apply, Pi.neg_apply, Pi.sub_apply, Pi.single_apply, Fin.ext_iff,
    Fin.val_castSucc, Fin.val_succ, h3]
  split_ifs at hs <;> split_ifs <;> omega

/-- `w⁻¹ α₀ = −θ`. -/
theorem reflectionWord_reverse_single_zero (hm : 1 ≤ m) :
    reflectionWord (CartanMatrix.A m) (List.finRange m).reverse (Pi.single ⟨0, hm⟩ 1) =
      -highestRoot m := by
  have h := reflectionWord_highestRoot hm
  have h2 := congrArg (reflectionWord (CartanMatrix.A m) (List.finRange m).reverse) h
  rw [← Module.End.mul_apply,
    reflectionWord_reverse_mul (TauCeti.isFiniteType_cartanMatrix_A m).apply_self, map_neg,
    Module.End.one_apply] at h2
  simp [h2]

private theorem toStd_partialSumRoot (i : ℕ) (a : Fin (m + 1)) :
    toStd m (partialSumRoot m i) a =
      (if a.val < m ∧ a.val ≤ i then 1 else 0) -
        (if 0 < a.val ∧ a.val - 1 ≤ i then 1 else 0) := by
  have h : partialSumRoot m i = fun j ↦ if j.val ≤ i then 1 else 0 := by
    funext j
    simp [partialSumRoot, Finset.sum_apply, Pi.single_apply]
  rw [h, toStd]
  have := a.isLt
  by_cases h1 : a.val < m <;> by_cases h2 : 0 < a.val <;> simp [h1, h2]

/-- For `1 ≤ i ≤ m-1`, `βᵢ` is the only positive combination of `(βᵢ₋₁, αᵢ)` in `Φ`. -/
theorem onlyPositiveCombination_partialSumRoot (i : Fin m) (hi : 1 ≤ i.val) :
    OnlyPositiveCombination (roots m) (partialSumRoot m (i.val - 1)) (Pi.single i 1)
      (partialSumRoot m i.val) := by
  have hi' := i.isLt
  have hsum (j : ℕ) : partialSumRoot m j = fun k ↦ if k.val ≤ j then 1 else 0 := by
    funext k
    simp [partialSumRoot, Finset.sum_apply, Pi.single_apply]
  refine ⟨?_, ?_, ?_⟩
  · funext k
    simp only [hsum, Pi.add_apply, Pi.single_apply, Fin.ext_iff]
    split_ifs <;> omega
  · change _ ∈ CFSG.LieType.RootSystem.roots _ _
    rw [roots_eq]
    refine ⟨⟨0, by omega⟩, ⟨i.val + 1, by omega⟩, by simp [Fin.ext_iff], ?_⟩
    funext a
    rw [toStd_partialSumRoot]
    simp only [Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
    have := a.isLt
    split_ifs <;> omega
  · intro p q hp hq hmem
    change _ ∈ CFSG.LieType.RootSystem.roots _ _ at hmem
    rw [roots_eq] at hmem
    obtain ⟨x, y, hxy, h⟩ := hmem
    have hxy' : x.val ≠ y.val := fun h ↦ hxy (Fin.ext h)
    have hv : p • partialSumRoot m (i.val - 1) + q • (Pi.single i 1 : Fin m → ℤ) =
        fun k ↦ if k.val ≤ i.val - 1 then (p : ℤ) else if k.val = i.val then (q : ℤ) else 0 := by
      funext k
      simp only [Pi.add_apply, Pi.smul_apply]
      simp only [hsum, Pi.single_apply, nsmul_eq_mul, Fin.ext_iff]
      split_ifs <;> omega
    rw [hv] at h
    have h0 := congrFun h ⟨0, by omega⟩
    have h1 := congrFun h ⟨i.val + 1, by omega⟩
    have e0 : toStd m (fun k : Fin m ↦ if k.val ≤ i.val - 1 then (p : ℤ)
        else if k.val = i.val then (q : ℤ) else 0) ⟨0, by omega⟩ = p := by
      simp [toStd, show 0 < m by omega]
    have e1 : toStd m (fun k : Fin m ↦ if k.val ≤ i.val - 1 then (p : ℤ)
        else if k.val = i.val then (q : ℤ) else 0) ⟨i.val + 1, by omega⟩ = -q := by
      by_cases h' : i.val + 1 < m
      · have h2 : ¬ (i.val + 1 ≤ i.val - 1) := by omega
        have h4 : ¬ (i.val ≤ i.val - 1) := by omega
        simp [toStd, h', h2, h4]
      · have h4 : ¬ (i.val ≤ i.val - 1) := by omega
        simp [toStd, h', h4]
    rw [e0] at h0
    rw [e1] at h1
    simp only [Pi.sub_apply, Pi.single_apply, Fin.ext_iff] at h0 h1
    split_ifs at h0 h1 <;> omega

/-- `∑ⱼ A 0 j · (α₀) j = 2`. -/
theorem sum_cartan_zero_mul_single_zero (hm : 1 ≤ m) :
    ∑ j, CartanMatrix.A m ⟨0, hm⟩ j * (Pi.single (⟨0, hm⟩ : Fin m) 1 : Fin m → ℤ) j = 2 := by
  simp [Pi.single_apply, CartanMatrix.A]

/-- `∑ⱼ A 0 j · (−θ) j = −1` for `m ≥ 2`. -/
theorem sum_cartan_zero_mul_neg_highestRoot_of_two_le (hm : 2 ≤ m) :
    ∑ j, CartanMatrix.A m ⟨0, by omega⟩ j * (-highestRoot m) j = -1 := by
  rw [highestRoot_eq, Finset.sum_eq_add_of_mem (⟨0, by omega⟩ : Fin m) ⟨1, by omega⟩
    (Finset.mem_univ _) (Finset.mem_univ _) (by simp [Fin.ext_iff])]
  · simp [CartanMatrix.A]
  · intro c _ hc
    simp only [CartanMatrix.A, Matrix.of_apply]
    have h1 : c.val ≠ 0 := fun h ↦ hc.1 (Fin.ext h)
    have h2 : c.val ≠ 1 := fun h ↦ hc.2 (Fin.ext h)
    have h3 : (⟨0, by omega⟩ : Fin m) ≠ c := fun h ↦ h1 (by rw [← h])
    simp [h3]
    omega

/-- `∑ⱼ A 0 j · (−θ) j = −2` for `m = 1`. -/
theorem sum_cartan_zero_mul_neg_highestRoot_one :
    ∑ j, CartanMatrix.A 1 ⟨0, by omega⟩ j * (-highestRoot 1) j = -2 := by
  simp [highestRoot, CartanMatrix.A]

end TypeA

end CFSGCorollary
