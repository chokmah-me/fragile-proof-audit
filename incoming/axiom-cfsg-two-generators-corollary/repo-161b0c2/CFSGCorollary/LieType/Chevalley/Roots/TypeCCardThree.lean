module

public import CFSGCorollary.LieType.Chevalley.Roots.Basic
public import CFSG.LieType.Universal.SymplecticRoots
import CFSG.LieType.Universal.SymplecticExtras.Matrices
import CFSGCorollary.LieType.Chevalley.Roots.TypeCCardLarge

/-!
# Root computations for type `C_m` over a field with three elements

Let `A = cartanC m` with `m ≥ 3`, `L = [0, …, m-1]`, `w = reflectionWord A L` (so that
`w⁻¹ = reflectionWord A L.reverse`) and `βᵢ = α₀ + ⋯ + αᵢ = partialSumRoot m i`. We prove the
root-theoretic input of Steinberg's argument for `C_m(𝔽₃)`: `w^m = −1` on `Φ`, `wⁱ α₀ = αᵢ`,
`w⁻¹ β_{m-2} = −α_{m-2} − α_{m-1}`, and two "unique sum" statements that let unit single
commutators produce `βᵢ` from `βᵢ₋₁, αᵢ` and `−α_{m-1}` from `α_{m-2}, −α_{m-2} − α_{m-1}`.
The computations are done in the standard coordinates `toStd m`.

## Main results

* `TypeCCardThree.reflectionWord_pow_apply_eq_neg`: `w^m γ = −γ`.
* `TypeCCardThree.reflectionWord_pow_single_zero`: `wⁱ α₀ = αᵢ` for `i ≤ m - 2`.
* `TypeCCardThree.reflectionWord_reverse_partialSumRoot`: `w⁻¹ β_{m-2} = −α_{m-2} − α_{m-1}`.
* `TypeCCardThree.onlyPositiveCombination_partialSumRoot`,
  `TypeCCardThree.onlyPositiveCombination_neg_single_last`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

namespace TypeCCardThree

open CFSG.LieType.Universal.Symplectic
open CFSG.LieType.RootSystem (reflection reflection_apply_coroot)
open SpExtras (toStd_inj toStd_add' toStd_neg' toStd_nsmul' toStd_zsmul' toStd_single_of_lt'
  toStd_single_of_not_lt')

/-- The root system `Φ` of type `C_m` (no doubled indices). -/
abbrev roots (m : ℕ) : Set (Fin m → ℤ) :=
  CFSG.LieType.RootSystem.roots (isFiniteType_cartanC m) ∅

variable {m : ℕ}

private theorem toStd_reflection_apply_of_lt {k : Fin m} (h : k.val + 1 < m) (v : Fin m → ℤ)
    (a : Fin m) :
    toStd m (reflection (cartanC m) k v) a =
      if a.val = k.val then toStd m v ⟨k.val + 1, h⟩
      else if a.val = k.val + 1 then toStd m v k else toStd m v a := by
  have hne : (⟨k.val + 1, h⟩ : Fin m) ≠ k := Fin.ne_of_val_ne (by simp)
  rw [reflection_apply_coroot, toStd_sub, toStd_zsmul', coroot_cartanC_of_lt h,
    toStd_single_of_lt' h]
  simp only [Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
  by_cases h1 : a = k
  · subst h1
    simp [hne.symm]
  by_cases h2 : a = ⟨k.val + 1, h⟩
  · subst h2
    simp [hne]
  · have h1' : ¬ a.val = k.val := fun e ↦ h1 (Fin.ext e)
    have h2' : ¬ a.val = k.val + 1 := fun e ↦ h2 (Fin.ext e)
    simp [h1, h2, h1', h2']

private theorem toStd_reflection_apply_of_not_lt {k : Fin m} (h : ¬k.val + 1 < m) (v : Fin m → ℤ)
    (a : Fin m) :
    toStd m (reflection (cartanC m) k v) a =
      if a.val = k.val then - toStd m v a else toStd m v a := by
  rw [reflection_apply_coroot, toStd_sub, toStd_zsmul', coroot_cartanC_of_not_lt h,
    toStd_single_of_not_lt' h]
  by_cases h1 : a = k
  · subst h1
    simp only [Pi.sub_apply, Pi.smul_apply, Pi.single_eq_same, smul_eq_mul, ite_true]
    ring
  · have h1' : ¬ a.val = k.val := fun e ↦ h1 (Fin.ext e)
    simp [h1, h1']

private noncomputable def reflectionNat (m j : ℕ) : Module.End ℤ (Fin m → ℤ) :=
  if h : j < m then reflection (cartanC m) ⟨j, h⟩ else 1

private theorem finRange_map_reflection :
    ((List.finRange m).map (reflection (cartanC m))) = (List.range m).map (reflectionNat m) := by
  apply List.ext_getElem
  · simp
  · intro n h1 h2
    simp only [List.getElem_map, List.getElem_finRange, List.getElem_range, reflectionNat]
    have : n < m := by simpa using h1
    simp [this]

private def stdWeylWordDrop (k : ℕ) (e : Fin m → ℤ) (a : Fin m) : ℤ :=
  if a.val < k then extendByZero e a.val
  else if a.val = k then -extendByZero e (m - 1) else extendByZero e (a.val - 1)

private theorem toStd_prod_range'_apply (hm : 0 < m) :
    ∀ n k, k + n = m → ∀ (v : Fin m → ℤ) (a : Fin m),
      toStd m ((((List.range' k n).map (reflectionNat m)).prod) v) a =
        stdWeylWordDrop k (toStd m v) a := by
  intro n
  induction n with
  | zero =>
    intro k hk v a
    have : k = m := by omega
    subst this
    simp [stdWeylWordDrop, extendByZero_val, a.isLt]
  | succ n ih =>
    intro k hk v a
    have hkm : k < m := by omega
    rw [List.range'_succ, List.map_cons, List.prod_cons, Module.End.mul_apply]
    simp only [reflectionNat, hkm, dite_true]
    by_cases hk1 : k + 1 < m
    · rw [toStd_reflection_apply_of_lt hk1]
      rw [ih (k + 1) (by omega) v ⟨k + 1, hk1⟩, ih (k + 1) (by omega) v ⟨k, hkm⟩,
        ih (k + 1) (by omega) v a]
      simp only [stdWeylWordDrop, extendByZero_val]
      split_ifs <;> first | omega | simp_all
    · rw [toStd_reflection_apply_of_not_lt (by simpa using hk1)]
      rw [ih (k + 1) (by omega) v a]
      have hk2 : k + 1 = m := by omega
      have hk3 : m - 1 = k := by omega
      simp only [stdWeylWordDrop, extendByZero_val, hk3]
      split_ifs with h5 <;> first | omega | (rw [← h5, extendByZero_val])

private theorem reflectionWord_finRange_eq_prod :
    reflectionWord (cartanC m) (List.finRange m) =
      ((List.range' 0 m).map (reflectionNat m)).prod := by
  unfold reflectionWord
  rw [finRange_map_reflection, List.range_eq_range']

private theorem toStd_reflectionWord_apply (hm : 0 < m) (v : Fin m → ℤ) (a : Fin m) :
    toStd m (reflectionWord (cartanC m) (List.finRange m) v) a =
      if a.val = 0 then -extendByZero (toStd m v) (m - 1)
      else extendByZero (toStd m v) (a.val - 1) := by
  rw [reflectionWord_finRange_eq_prod, toStd_prod_range'_apply hm m 0 (by omega) v a]
  simp only [stdWeylWordDrop]
  split_ifs <;> omega

private theorem extendByZero_toStd_reflectionWord (hm : 0 < m) (v : Fin m → ℤ) (n : ℕ) :
    extendByZero (toStd m (reflectionWord (cartanC m) (List.finRange m) v)) n =
      if n < m then
        (if n = 0 then -extendByZero (toStd m v) (m - 1) else extendByZero (toStd m v) (n - 1))
      else 0 := by
  by_cases h : n < m
  · rw [show extendByZero (toStd m (reflectionWord (cartanC m) (List.finRange m) v)) n =
        toStd m (reflectionWord (cartanC m) (List.finRange m) v) ⟨n, h⟩ from
      extendByZero_val _ ⟨n, h⟩, toStd_reflectionWord_apply hm v ⟨n, h⟩]
    simp [h]
  · simp [extendByZero, h]

private def stdWeylWordPow (k : ℕ) (e : Fin m → ℤ) (n : ℕ) : ℤ :=
  if n < m then (if k ≤ n then extendByZero e (n - k) else - extendByZero e (n + m - k)) else 0

private theorem extendByZero_toStd_reflectionWord_pow (hm : 0 < m) :
    ∀ k, k ≤ m → ∀ (v : Fin m → ℤ) (n : ℕ),
      extendByZero (toStd m ((reflectionWord (cartanC m) (List.finRange m) ^ k) v)) n =
        stdWeylWordPow k (toStd m v) n := by
  intro k
  induction k with
  | zero =>
    intro _ v n
    simp only [pow_zero, Module.End.one_apply, stdWeylWordPow]
    by_cases h : n < m
    · simp [h]
    · simp [h, extendByZero]
  | succ k ih =>
    intro hk v n
    rw [pow_succ', Module.End.mul_apply, extendByZero_toStd_reflectionWord hm, ih (by omega),
      ih (by omega)]
    simp only [stdWeylWordPow]
    split_ifs <;> first | omega | rfl | (try simp only [neg_inj]); (congr 1; omega)

private theorem toStd_partialSumRoot (hm : 0 < m) (j : ℕ) (p : Fin m) (hp : j + 1 = p.val) :
    toStd m (partialSumRoot m j) = Pi.single (⟨0, hm⟩ : Fin m) 1 - Pi.single p 1 := by
  funext a
  simp only [toStd, partialSumRoot_apply, Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
  split_ifs <;> omega

/-- `w^m γ = −γ`. -/
theorem reflectionWord_pow_apply_eq_neg (hm : 3 ≤ m) (γ : Fin m → ℤ) :
    (reflectionWord (cartanC m) (List.finRange m) ^ m) γ = -γ := by
  apply toStd_inj
  funext a
  have h := extendByZero_toStd_reflectionWord_pow (by omega) m le_rfl γ a.val
  rw [extendByZero_val] at h
  rw [h, toStd_neg']
  simp [stdWeylWordPow, a.isLt, extendByZero_val]

/-- `wⁱ α₀ = αᵢ` for `i ≤ m-2`. -/
theorem reflectionWord_pow_single_zero (hm : 3 ≤ m) (i : Fin m) (hi : i.val + 2 ≤ m) :
    (reflectionWord (cartanC m) (List.finRange m) ^ i.val) (Pi.single ⟨0, by omega⟩ 1) =
      Pi.single i 1 := by
  apply toStd_inj
  funext a
  have hm0 : 0 < m := by omega
  have him : i.val ≤ m := by omega
  have h := extendByZero_toStd_reflectionWord_pow hm0 i.val him (Pi.single ⟨0, hm0⟩ 1) a.val
  rw [extendByZero_val] at h
  rw [h, toStd_single_of_lt' (k := i) (by omega),
    toStd_single_of_lt' (k := ⟨0, by omega⟩) (by simp only; omega)]
  simp only [stdWeylWordPow, extendByZero, Pi.sub_apply, Pi.single_apply, Fin.ext_iff, a.isLt,
    ite_true]
  split_ifs <;> omega

/-- `w⁻¹ β_{m-2} = −α_{m-2} − α_{m-1}`. -/
theorem reflectionWord_reverse_partialSumRoot (hm : 3 ≤ m) :
    reflectionWord (cartanC m) (List.finRange m).reverse (partialSumRoot m (m - 2)) =
      -Pi.single (⟨m - 2, by omega⟩ : Fin m) 1 - Pi.single (⟨m - 1, by omega⟩ : Fin m) 1 := by
  set u : Fin m → ℤ :=
    -Pi.single (⟨m - 2, by omega⟩ : Fin m) 1 - Pi.single (⟨m - 1, by omega⟩ : Fin m) 1 with hu
  have hw : reflectionWord (cartanC m) (List.finRange m) u = partialSumRoot m (m - 2) := by
    apply toStd_inj
    funext a
    have hTu : toStd m u = -Pi.single (⟨m - 2, by omega⟩ : Fin m) 1 -
        Pi.single (⟨m - 1, by omega⟩ : Fin m) 1 := by
      rw [hu, sub_eq_add_neg, toStd_add', toStd_neg', toStd_neg',
        toStd_single_of_lt' (k := ⟨m - 2, by omega⟩) (by simp; omega),
        toStd_single_of_not_lt' (k := ⟨m - 1, by omega⟩) (by simp; omega)]
      funext b
      simp only [Pi.add_apply, Pi.neg_apply, Pi.sub_apply, Pi.smul_apply, Pi.single_apply,
        Fin.ext_iff]
      simp only [nsmul_eq_mul, Nat.cast_ofNat]
      split_ifs <;> omega
    rw [toStd_reflectionWord_apply (by omega), toStd_partialSumRoot (by omega) (m - 2)
      (⟨m - 1, by omega⟩ : Fin m) (by simp; omega), hTu]
    simp only [extendByZero, Pi.sub_apply, Pi.neg_apply, Pi.single_apply, Fin.ext_iff]
    split_ifs <;> omega
  rw [← hw, ← Module.End.mul_apply,
    reflectionWord_reverse_mul (isFiniteType_cartanC m).apply_self]
  rfl

private theorem mem_roots_iff {γ : Fin m → ℤ} :
    γ ∈ roots m ↔ ∃ r, stdVec r = toStd m γ :=
  Set.ext_iff.mp (roots_eq m) γ

private def IsSignedSumOfTwoSingles (v : Fin m → ℤ) : Prop :=
  ∃ (a b : Fin m) (s t : ℤ), (s = 1 ∨ s = -1) ∧ (t = 1 ∨ t = -1) ∧
    v = Pi.single a s + Pi.single b t

private theorem isSignedSumOfTwoSingles_stdVec (r : TauCeti.GLSymplecticFin.RootSubgroupIndex m) :
    IsSignedSumOfTwoSingles (stdVec r) := by
  cases r with
  | positiveLong i => exact ⟨i, i, 1, 1, Or.inl rfl, Or.inl rfl, by simp only [stdVec, two_nsmul]⟩
  | negativeLong i =>
    exact ⟨i, i, -1, -1, Or.inr rfl, Or.inr rfl,
      by simp only [stdVec, two_nsmul, Pi.single_neg, neg_add]⟩
  | difference i j _ =>
    exact ⟨i, j, 1, -1, Or.inl rfl, Or.inr rfl, by rw [stdVec, sub_eq_add_neg, Pi.single_neg]⟩
  | positiveSum i j _ => exact ⟨i, j, 1, 1, Or.inl rfl, Or.inl rfl, rfl⟩
  | negativeSum i j _ =>
    exact ⟨i, j, -1, -1, Or.inr rfl, Or.inr rfl,
      by rw [stdVec, Pi.single_neg, Pi.single_neg, neg_add]⟩

private theorem IsSignedSumOfTwoSingles.bound {v : Fin m → ℤ} (hv : IsSignedSumOfTwoSingles v)
    (x : Fin m) :
    -2 ≤ v x ∧ v x ≤ 2 := by
  obtain ⟨a, b, s, t, hs, ht, rfl⟩ := hv
  simp only [Pi.add_apply, Pi.single_apply]
  split_ifs <;> omega

private theorem IsSignedSumOfTwoSingles.apply_eq_zero_of_apply_ne_zero {v : Fin m → ℤ}
    (hv : IsSignedSumOfTwoSingles v) {x y z : Fin m} (hxy : x ≠ y) (hyz : y ≠ z) (hxz : x ≠ z)
    (hx : v x ≠ 0) (hz : v z ≠ 0) :
    v y = 0 ∧ (v x = 1 ∨ v x = -1) := by
  obtain ⟨a, b, s, t, hs, ht, rfl⟩ := hv
  have hxy' : x.val ≠ y.val := fun e ↦ hxy (Fin.ext e)
  have hyz' : y.val ≠ z.val := fun e ↦ hyz (Fin.ext e)
  have hxz' : x.val ≠ z.val := fun e ↦ hxz (Fin.ext e)
  simp only [Pi.add_apply, Pi.single_apply, Fin.ext_iff] at hx hz ⊢
  split_ifs at hx hz ⊢ <;> omega

/-- For `1 ≤ i ≤ m-2`, `βᵢ` is the only positive combination of `(βᵢ₋₁, αᵢ)` in `Φ`. -/
theorem onlyPositiveCombination_partialSumRoot (hm : 3 ≤ m) (i : Fin m) (h1 : 1 ≤ i.val)
    (hi : i.val + 2 ≤ m) :
    OnlyPositiveCombination (roots m) (partialSumRoot m (i.val - 1)) (Pi.single i 1)
      (partialSumRoot m i.val) := by
  have hm0 : 0 < m := by omega
  have hi1 : i.val + 1 < m := by omega
  refine ⟨?_, ?_, ?_⟩
  · funext a
    simp only [Pi.add_apply, partialSumRoot_apply, Pi.single_apply, Fin.ext_iff]
    split_ifs <;> omega
  · rw [mem_roots_iff, toStd_partialSumRoot hm0 i.val ⟨i.val + 1, hi1⟩ rfl]
    exact ⟨.difference ⟨0, hm0⟩ ⟨i.val + 1, hi1⟩ (by simp [Fin.ext_iff]), rfl⟩
  · intro p q hp hq hmem
    rw [mem_roots_iff] at hmem
    obtain ⟨r, hr⟩ := hmem
    have hform := hr ▸ isSignedSumOfTwoSingles_stdVec r
    rw [toStd_add', toStd_nsmul', toStd_nsmul',
      toStd_partialSumRoot hm0 (i.val - 1) i (by omega), toStd_single_of_lt' hi1] at hform
    set v : Fin m → ℤ := p • (Pi.single (⟨0, hm0⟩ : Fin m) 1 - Pi.single i 1) +
      q • (Pi.single i 1 - Pi.single (⟨i.val + 1, hi1⟩ : Fin m) 1) with hv
    have c0 : v ⟨0, hm0⟩ = p := by
      simp only [hv, Pi.add_apply, Pi.smul_apply, Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
      simp only [nsmul_eq_mul]
      split_ifs <;> first | omega | simp_all
    have c1 : v i = q - p := by
      simp only [hv, Pi.add_apply, Pi.smul_apply, Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
      simp only [nsmul_eq_mul]
      split_ifs <;> omega
    have c2 : v ⟨i.val + 1, hi1⟩ = -q := by
      simp only [hv, Pi.add_apply, Pi.smul_apply, Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
      simp only [nsmul_eq_mul]
      split_ifs <;> first | omega | simp_all
    have := hform.apply_eq_zero_of_apply_ne_zero (x := ⟨0, hm0⟩) (y := i) (z := ⟨i.val + 1, hi1⟩)
      (by simp [Fin.ext_iff]; omega) (by simp [Fin.ext_iff]) (by simp [Fin.ext_iff])
      (by rw [c0]; omega) (by rw [c2]; omega)
    rw [c0, c1] at this
    omega

/-- `−α_{m-1}` is the only positive combination of `(α_{m-2}, −α_{m-2} − α_{m-1})` in `Φ`. -/
theorem onlyPositiveCombination_neg_single_last (hm : 3 ≤ m) :
    OnlyPositiveCombination (roots m) (Pi.single (⟨m - 2, by omega⟩ : Fin m) 1)
      (-Pi.single (⟨m - 2, by omega⟩ : Fin m) 1 - Pi.single (⟨m - 1, by omega⟩ : Fin m) 1)
      (-Pi.single (⟨m - 1, by omega⟩ : Fin m) 1) := by
  have hp : (⟨m - 2, by omega⟩ : Fin m).val + 1 < m := by simp; omega
  have hq : ¬ (⟨m - 1, by omega⟩ : Fin m).val + 1 < m := by simp; omega
  have hTa := toStd_single_of_lt' hp
  have hTq := toStd_single_of_not_lt' hq
  have hqe : (⟨(⟨m - 2, by omega⟩ : Fin m).val + 1, hp⟩ : Fin m) = ⟨m - 1, by omega⟩ :=
    Fin.ext (by simp; omega)
  rw [hqe] at hTa
  refine ⟨?_, ?_, ?_⟩
  · funext a
    simp only [Pi.add_apply, Pi.sub_apply, Pi.neg_apply]
    ring
  · rw [mem_roots_iff, toStd_neg', hTq]
    exact ⟨.negativeLong ⟨m - 1, by omega⟩, rfl⟩
  · intro p q hp0 hq0 hmem
    rw [mem_roots_iff] at hmem
    obtain ⟨r, hr⟩ := hmem
    have hform := hr ▸ isSignedSumOfTwoSingles_stdVec r
    have hb := hform.bound ⟨m - 1, by omega⟩
    rw [toStd_add', toStd_nsmul', toStd_nsmul', sub_eq_add_neg, toStd_add', toStd_neg', toStd_neg',
      hTa, hTq] at hb
    simp only [Pi.add_apply, Pi.smul_apply, Pi.sub_apply, Pi.neg_apply, Pi.single_apply,
      Fin.ext_iff] at hb
    simp only [nsmul_eq_mul, Nat.cast_ofNat] at hb
    split_ifs at hb <;> omega

end TypeCCardThree

end CFSGCorollary
