module

public import CFSGCorollary.LieType.Chevalley.Roots.Basic
public import CFSG.LieType.Universal.SymplecticRoots
import CFSGCorollary.LieType.Chevalley.Roots.TypeCCardLarge
import CFSG.LieType.Universal.SymplecticExtras.Matrices

/-!
# Root computations for type `C_m` over the field with two elements

Let `A = cartanC m` with `m ≥ 3`, `L' = [m-1, m-2, …, 0]` (`coxeterList m`),
`w' = reflectionWord A L'`, `r' = α₀ + ⋯ + α_{m-2}` and `s' = −α_{m-1}`. We prove the root-theoretic
input of Steinberg's argument for `C_m(𝔽₂)`: `r'` and `s'` are roots, every `±αᵢ` with
`i ≤ m - 2` is in the `w'`-orbit of `α_{m-2}`, `±α_{m-1}` are in the `w'`-orbit of `s'`, and the
product of the reflections in `α_{m-2}, …, α₁` maps `α₀` to `r'`. The computations are done in the
standard coordinates `toStd m`, in which `w'` is a negacyclic shift.

## Main results

* `TypeCCardTwo.rootR_mem`, `TypeCCardTwo.rootS_mem`: `r'` and `s'` are roots.
* `TypeCCardTwo.exists_reflectionWord_pow_single`, `TypeCCardTwo.exists_reflectionWord_pow_rootS`:
  orbit statements for `w'`.
* `TypeCCardTwo.reflectionWord_reflectionList_single_zero`: `w_{[m-2, …, 1]} α₀ = r'`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

namespace TypeCCardTwo

open CFSG.LieType.Universal.Symplectic
open CFSG.LieType.RootSystem (reflection)
open SpExtras (toStd_add' toStd_inj toStd_neg' toStd_zsmul' toStd_single_of_not_lt')

/-- The root system `Φ` of type `C_m` (no doubled indices). -/
abbrev roots (m : ℕ) : Set (Fin m → ℤ) :=
  CFSG.LieType.RootSystem.roots (isFiniteType_cartanC m) ∅

/-- `L' = [m-1, m-2, …, 0]`. -/
def coxeterList (m : ℕ) : List (Fin m) := (List.finRange m).reverse

/-- `r' = α₀ + ⋯ + α_{m-2}`. -/
def rootR (m : ℕ) : Fin m → ℤ := partialSumRoot m (m - 2)

/-- `s' = −α_{m-1}`. -/
def rootS (m : ℕ) (hm : 0 < m) : Fin m → ℤ := -Pi.single ⟨m - 1, by omega⟩ 1

/-- The list `[m-2, m-3, …, 1]`, so that `reflectionWord A (reflectionList m)` is
`reflection A (m-2) (⋯ (reflection A 1 ·))`. -/
def reflectionList (m : ℕ) : List (Fin m) :=
  ((List.finRange m).filter fun i ↦ 1 ≤ i.val ∧ i.val + 2 ≤ m).reverse

variable {m : ℕ}

private theorem toStd_single_apply (k a : Fin m) :
    toStd m (Pi.single k 1) a =
      (if a.val + 1 = m then 2 else 1) * (if a = k then 1 else 0) -
        (if a.val = k.val + 1 then 1 else 0) := by
  simp only [toStd, Pi.single_apply, Fin.ext_iff]
  split_ifs <;> omega

private noncomputable def reflectionNat (m i : ℕ) : Module.End ℤ (Fin m → ℤ) :=
  if h : i < m then reflection (cartanC m) ⟨i, h⟩ else 1

private theorem reflectionWord_eq_prod (L : List (Fin m)) :
    reflectionWord (cartanC m) L = ((L.map Fin.val).map (reflectionNat m)).prod := by
  rw [reflectionWord, List.map_map]
  congr 1
  apply List.map_congr_left
  intro i _
  simp [reflectionNat, i.isLt]

private noncomputable def reflectionProdDownToZero (m n : ℕ) : Module.End ℤ (Fin m → ℤ) :=
  ((List.range n).reverse.map (reflectionNat m)).prod

private theorem reflectionProdDownToZero_zero : reflectionProdDownToZero m 0 = 1 := by
  simp [reflectionProdDownToZero]

private theorem reflectionProdDownToZero_succ (n : ℕ) :
    reflectionProdDownToZero m (n + 1) = reflectionNat m n * reflectionProdDownToZero m n := by
  simp [reflectionProdDownToZero, List.range_succ]

private theorem reflectionWord_coxeterList :
    reflectionWord (cartanC m) (coxeterList m) = reflectionProdDownToZero m m := by
  rw [reflectionWord_eq_prod, reflectionProdDownToZero, coxeterList, List.map_reverse,
    List.map_coe_finRange_eq_range]

private theorem toStd_reflectionProdDownToZero_apply (n : ℕ) (hn : n < m) (v : Fin m → ℤ)
    (i : Fin m) :
    toStd m (reflectionProdDownToZero m n v) i =
      if i.val < n then extendByZero (toStd m v) (i.val + 1)
      else if i.val = n then extendByZero (toStd m v) 0 else extendByZero (toStd m v) i.val := by
  induction n generalizing i with
  | zero =>
    rw [reflectionProdDownToZero_zero]
    simp only [Module.End.one_apply]
    by_cases h : i.val = 0
    · have e : i = ⟨0, by omega⟩ := Fin.ext h
      subst e
      simp [extendByZero, show 0 < m by omega]
    · simp [h, extendByZero_val]
  | succ n ih =>
    rw [reflectionProdDownToZero_succ, Module.End.mul_apply]
    have hn' : n < m := by omega
    have hr : reflectionNat m n = reflection (cartanC m) ⟨n, hn'⟩ := by simp [reflectionNat, hn']
    rw [hr, toStd_reflection_of_lt (k := ⟨n, hn'⟩) (by simpa using hn)]
    simp only [Function.comp_apply]
    by_cases h1 : i.val = n
    · have : i = ⟨n, hn'⟩ := Fin.ext h1
      subst this
      rw [Equiv.swap_apply_left, ih hn' _]
      simp
    by_cases h2 : i.val = n + 1
    · have : i = ⟨n + 1, hn⟩ := Fin.ext h2
      subst this
      rw [Equiv.swap_apply_right, ih hn' _]
      simp
    · rw [Equiv.swap_apply_of_ne_of_ne (by simpa [Fin.ext_iff] using h1)
        (by simpa [Fin.ext_iff] using h2), ih hn' _]
      by_cases h3 : i.val < n
      · simp [h3, show i.val < n + 1 by omega]
      · simp [h3, h1, h2, show ¬ i.val < n + 1 by omega]

/-- The action of `w'` in standard coordinates. -/
private def stdWeylWord (m : ℕ) (s : Fin m → ℤ) : Fin m → ℤ :=
  fun i ↦ if i.val + 1 < m then extendByZero s (i.val + 1) else -extendByZero s 0

private theorem toStd_reflectionWord_coxeterList (hm : 0 < m) (v : Fin m → ℤ) :
    toStd m (reflectionWord (cartanC m) (coxeterList m) v) = stdWeylWord m (toStd m v) := by
  rw [reflectionWord_coxeterList]
  obtain ⟨n, rfl⟩ : ∃ n, m = n + 1 := ⟨m - 1, by omega⟩
  rw [reflectionProdDownToZero_succ, Module.End.mul_apply]
  have hr : reflectionNat (n + 1) n = reflection (cartanC (n + 1)) ⟨n, by omega⟩ := by
    simp [reflectionNat]
  rw [hr, toStd_reflection_of_not_lt (k := ⟨n, by omega⟩) (by simp)]
  funext i
  rw [toStd_reflectionProdDownToZero_apply n (by omega)]
  simp only [stdWeylWord]
  by_cases h1 : i.val = n
  · have : i = ⟨n, by omega⟩ := Fin.ext h1
    rw [ite_eq_left this]
    simp [h1]
  · have : i ≠ ⟨n, by omega⟩ := fun h ↦ h1 (by simp [h])
    simp only [ite_eq_right this]
    by_cases h3 : i.val < n
    · simp [h3, show i.val + 1 < n + 1 by omega]
    · omega

private theorem extendByZero_stdWeylWord (F : Fin m → ℤ) {j : ℕ} (hj : j < m) :
    extendByZero (stdWeylWord m F) j =
      if j + 1 < m then extendByZero F (j + 1) else -extendByZero F 0 := by
  rw [extendByZero_of_lt _ hj]
  rfl

private theorem extendByZero_stdWeylWord_iterate (hm : 0 < m) (s : Fin m → ℤ) (k : ℕ) (hk : k ≤ m)
    (j : ℕ) (hj : j < m) :
    extendByZero ((stdWeylWord m)^[k] s) j =
      if j + k < m then extendByZero s (j + k) else -extendByZero s (j + k - m) := by
  induction k generalizing j with
  | zero => simp only [Function.iterate_zero, id, Nat.add_zero, ite_eq_left hj]
  | succ k ih =>
    rw [Function.iterate_succ_apply', extendByZero_stdWeylWord _ hj]
    by_cases h1 : j + 1 < m
    · rw [ite_eq_left h1, ih (by omega) (j + 1) h1]
      have e : j + 1 + k = j + (k + 1) := by omega
      rw [e]
    · rw [ite_eq_right h1, ih (by omega) 0 hm]
      have e : j + (k + 1) - m = k := by omega
      rw [e]
      simp only [Nat.zero_add]
      split_ifs <;> first | rfl | omega

private theorem stdWeylWord_iterate_m (hm : 0 < m) (s : Fin m → ℤ) :
    (stdWeylWord m)^[m] s = -s := by
  funext i
  have := extendByZero_stdWeylWord_iterate hm s m le_rfl i.val i.isLt
  rw [extendByZero_val] at this
  rw [this, ite_eq_right (by omega), show i.val + m - m = i.val by omega, extendByZero_val]
  rfl

private noncomputable abbrev coxeterElement (m : ℕ) : Module.End ℤ (Fin m → ℤ) :=
  reflectionWord (cartanC m) (coxeterList m)

private theorem toStd_coxeterElement_pow (hm : 0 < m) (k : ℕ) (v : Fin m → ℤ) :
    toStd m ((coxeterElement m ^ k) v) = (stdWeylWord m)^[k] (toStd m v) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ', Module.End.mul_apply, toStd_reflectionWord_coxeterList hm, ih,
      Function.iterate_succ_apply']

private theorem coxeterElement_pow_m (hm : 0 < m) (v : Fin m → ℤ) :
    (coxeterElement m ^ m) v = -v := by
  apply toStd_inj
  rw [toStd_coxeterElement_pow hm, stdWeylWord_iterate_m hm, toStd_neg']

private theorem extendByZero_toStd_single (k : Fin m) (j : ℕ) :
    extendByZero (toStd m (Pi.single k 1)) j = if j < m then
      ((if j + 1 = m then 2 else 1) * (if j = k.val then 1 else 0) -
        (if j = k.val + 1 then 1 else 0)) else 0 := by
  by_cases h : j < m
  · rw [extendByZero_of_lt _ h, ite_eq_left h, toStd_single_apply]
    simp [Fin.ext_iff]
  · simp [extendByZero, h]

private theorem exists_coxeterElement_pow_single (hm : 3 ≤ m) (i : Fin m) (hi : i.val + 2 ≤ m)
    (γ : Fin m → ℤ) (hγ : γ = Pi.single i 1 ∨ γ = -Pi.single i 1) :
    ∃ k : ℕ, (coxeterElement m ^ k) (Pi.single (⟨m - 2, by omega⟩ : Fin m) 1) = γ := by
  have key : (coxeterElement m ^ (m - 2 - i.val)) (Pi.single (⟨m - 2, by omega⟩ : Fin m) 1) =
      Pi.single i 1 := by
    apply toStd_inj
    rw [toStd_coxeterElement_pow (by omega)]
    funext a
    have := extendByZero_stdWeylWord_iterate (by omega)
      (toStd m (Pi.single (⟨m - 2, by omega⟩ : Fin m) 1)) (m - 2 - i.val) (by omega) a.val a.isLt
    rw [extendByZero_val] at this
    rw [this, extendByZero_toStd_single, extendByZero_toStd_single, toStd_single_apply]
    simp only [Fin.ext_iff]
    split_ifs <;> omega
  rcases hγ with rfl | rfl
  · exact ⟨_, key⟩
  · refine ⟨m - 2 - i.val + m, ?_⟩
    rw [pow_add, Module.End.mul_apply, coxeterElement_pow_m (by omega), map_neg, key]

private theorem rootR_apply (a : Fin m) : rootR m a = if a.val ≤ m - 2 then 1 else 0 := by
  simp [rootR, partialSumRoot, Finset.sum_apply, Pi.single_apply]

private theorem toStd_rootR (hm : 3 ≤ m) :
    toStd m (rootR m) = Pi.single ⟨0, by omega⟩ 1 - Pi.single ⟨m - 1, by omega⟩ 1 := by
  funext a
  simp only [toStd, rootR_apply, Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
  split_ifs <;> omega

private theorem toStd_rootS (hm : 3 ≤ m) :
    toStd m (rootS m (by omega)) = -(2 • Pi.single (⟨m - 1, by omega⟩ : Fin m) 1) := by
  rw [rootS, toStd_neg', toStd_single_of_not_lt' (by simp only; omega)]

private theorem mem_roots_iff (γ : Fin m → ℤ) :
    γ ∈ roots m ↔ ∃ r, stdVec r = toStd m γ :=
  Set.ext_iff.mp (roots_eq m) γ

/-- `r'` is a root. -/
theorem rootR_mem (hm : 3 ≤ m) : rootR m ∈ roots m := by
  rw [mem_roots_iff]
  refine ⟨.difference ⟨0, by omega⟩ ⟨m - 1, by omega⟩ (by simp [Fin.ext_iff]; omega), ?_⟩
  rw [toStd_rootR hm]
  rfl

/-- `s'` is a root. -/
theorem rootS_mem (hm : 3 ≤ m) : rootS m (by omega) ∈ roots m := by
  rw [mem_roots_iff]
  refine ⟨.negativeLong ⟨m - 1, by omega⟩, ?_⟩
  rw [toStd_rootS hm]
  rfl

/-- For `i ≤ m - 2`, `±αᵢ` lies in the `w'`-orbit of `α_{m-2}`. -/
theorem exists_reflectionWord_pow_single (hm : 3 ≤ m) (i : Fin m) (hi : i.val + 2 ≤ m)
    (γ : Fin m → ℤ) (hγ : γ = Pi.single i 1 ∨ γ = -Pi.single i 1) :
    ∃ k : ℕ, (reflectionWord (cartanC m) (coxeterList m) ^ k)
      (Pi.single (⟨m - 2, by omega⟩ : Fin m) 1) = γ :=
  exists_coxeterElement_pow_single hm i hi γ hγ

/-- `±α_{m-1}` lies in the `w'`-orbit of `s'`. -/
theorem exists_reflectionWord_pow_rootS (hm : 3 ≤ m) (γ : Fin m → ℤ)
    (hγ : γ = Pi.single (⟨m - 1, by omega⟩ : Fin m) 1 ∨
      γ = -Pi.single (⟨m - 1, by omega⟩ : Fin m) 1) :
    ∃ k : ℕ, (reflectionWord (cartanC m) (coxeterList m) ^ k) (rootS m (by omega)) = γ := by
  rcases hγ with rfl | rfl
  · refine ⟨m, ?_⟩
    have := coxeterElement_pow_m (m := m) (by omega) (rootS m (by omega))
    simpa [rootS] using this
  · exact ⟨0, by simp [rootS]⟩

private noncomputable def reflectionProdDownToOne (m n : ℕ) : Module.End ℤ (Fin m → ℤ) :=
  ((List.range' 1 n).reverse.map (reflectionNat m)).prod

private theorem reflectionProdDownToOne_zero : reflectionProdDownToOne m 0 = 1 := by
  simp [reflectionProdDownToOne]

private theorem reflectionProdDownToOne_succ (n : ℕ) :
    reflectionProdDownToOne m (n + 1) = reflectionNat m (n + 1) * reflectionProdDownToOne m n := by
  simp [reflectionProdDownToOne, List.range'_concat, Nat.add_comm]

private theorem toStd_reflectionProdDownToOne_apply (n : ℕ) (hn : n + 2 ≤ m) (v : Fin m → ℤ)
    (i : Fin m) :
    toStd m (reflectionProdDownToOne m n v) i =
      if i.val = 0 then extendByZero (toStd m v) 0
      else if i.val ≤ n then extendByZero (toStd m v) (i.val + 1)
      else if i.val = n + 1 then extendByZero (toStd m v) 1
      else extendByZero (toStd m v) i.val := by
  induction n generalizing i with
  | zero =>
    rw [reflectionProdDownToOne_zero]
    simp only [Module.End.one_apply]
    split_ifs
    all_goals (rw [← extendByZero_val (toStd m v) i] <;> (congr 1 <;> omega))
  | succ n ih =>
    rw [reflectionProdDownToOne_succ, Module.End.mul_apply]
    have hn' : n + 1 < m := by omega
    have hr : reflectionNat m (n + 1) = reflection (cartanC m) ⟨n + 1, hn'⟩ := by
      simp [reflectionNat, hn']
    rw [hr, toStd_reflection_of_lt (k := ⟨n + 1, hn'⟩) (by simp only; omega)]
    simp only [Function.comp_apply]
    by_cases h1 : i.val = n + 1
    · have : i = ⟨n + 1, hn'⟩ := Fin.ext h1
      subst this
      rw [Equiv.swap_apply_left, ih (by omega)]
      simp only
      split_ifs <;> first | rfl | omega
    by_cases h2 : i.val = n + 2
    · have hn2 : n + 2 < m := by omega
      have : i = ⟨n + 2, hn2⟩ := Fin.ext h2
      subst this
      rw [Equiv.swap_apply_right, ih (by omega)]
      simp only
      split_ifs <;> first | rfl | omega
    · rw [Equiv.swap_apply_of_ne_of_ne (by simpa [Fin.ext_iff] using h1)
        (by simpa [Fin.ext_iff] using h2), ih (by omega)]
      split_ifs <;> first | rfl | omega

private theorem reflectionWord_reflectionList (m : ℕ) :
    reflectionWord (cartanC m) (reflectionList m) = reflectionProdDownToOne m (m - 2) := by
  have h1 : ((List.finRange m).filter fun i : Fin m ↦ 1 ≤ i.val ∧ i.val + 2 ≤ m).map Fin.val =
      List.range' 1 (m - 2) := by
    have h1 : ((List.finRange m).map Fin.val).filter (fun i : ℕ ↦ 1 ≤ i ∧ i + 2 ≤ m) =
        ((List.finRange m).filter fun i : Fin m ↦ 1 ≤ i.val ∧ i.val + 2 ≤ m).map Fin.val := by
      rw [List.filter_map]; rfl
    rw [← h1, List.map_coe_finRange_eq_range]
    apply List.Perm.eq_of_pairwise (le := (· ≤ ·))
    · intro a b _ _ h1 h2; omega
    · exact (List.pairwise_lt_range.imp le_of_lt).sublist List.filter_sublist
    · exact List.pairwise_le_range'
    · refine (List.perm_ext_iff_of_nodup ?_ ?_).2 fun a ↦ ?_
      · exact List.nodup_range.filter _
      · exact List.nodup_range'
      · simp [List.mem_range'_1]; omega
  rw [reflectionWord_eq_prod, reflectionList, List.map_reverse, h1, reflectionProdDownToOne]

/-- The product of the reflections in `α_{m-2}, …, α₁` maps `α₀` to `r'`. -/
theorem reflectionWord_reflectionList_single_zero (hm : 3 ≤ m) :
    reflectionWord (cartanC m) (reflectionList m) (Pi.single ⟨0, by omega⟩ 1) = rootR m := by
  apply toStd_inj
  rw [reflectionWord_reflectionList]
  funext i
  rw [toStd_reflectionProdDownToOne_apply (m - 2) (by omega), toStd_rootR hm]
  split_ifs <;> simp [extendByZero_toStd_single, Pi.single_apply, Fin.ext_iff] <;> omega

end TypeCCardTwo

end CFSGCorollary
