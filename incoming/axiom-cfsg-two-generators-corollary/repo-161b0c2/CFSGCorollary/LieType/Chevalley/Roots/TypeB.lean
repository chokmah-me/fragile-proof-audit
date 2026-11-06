module

public import CFSGCorollary.LieType.Chevalley.Roots.Basic
public import CFSG.LieType.Universal.Spin.Roots.TypeB

/-!
# Root computations for type `B_m`

Let `A = cartanB m` (`m ≥ 3`, in CFSG's convention: `α_{m-1}` is the short simple root, and in
standard coordinates `αᵢ = eᵢ - eᵢ₊₁` for `i ≤ m-2` and `α_{m-1} = e_{m-1}`), `L = [0, 1, …, m-1]`,
`w = reflectionWord A L` with inverse `w⁻¹ = reflectionWord A L.reverse`, `r = -(α₀ + ⋯ + α_{m-1})`,
`s = -α₀`, `μ = (0, 1, …, 1)` and `e γ = cocharacterPairing A μ γ`. In standard coordinates
(`toStdB`), `w` acts as the signed cyclic shift `stdWeylWord m`, so `wᵐ = -1`; from this we
compute the `w`-orbits of `r` and `s` and the weights `e` needed for the generation proof in
type `B`.

## Main results

* `TypeB.noPositiveCombination_rootR_rootS`: no positive combination of `r` and `s` is a root.
* `TypeB.inWeylWordOrbit_rootR_rootS`: every `±αᵢ` lies in the `w`-orbit of `r` or `s`.
* `TypeB.cocharacterPairing_rootR`, `TypeB.cocharacterPairing_rootS`,
  `TypeB.cocharacterPairing_reflectionWord_rootR`,
  `TypeB.cocharacterPairing_reflectionWord_reverse_rootR`,
  `TypeB.cocharacterPairing_reflectionWord_reverse_rootS`: the weights `e` of `r`, `s`, `w r`,
  `w⁻¹ r` and `w⁻¹ s`.
-/

@[expose] public section

namespace CFSGCorollary

namespace TypeB

open CFSG.LieType.Universal.Spin

/-- The root system `Φ` of type `B_m` (CFSG's `cartanB`, no doubled indices). -/
abbrev roots (m : ℕ) : Set (Fin m → ℤ) :=
  CFSG.LieType.RootSystem.roots (isFiniteType_cartanB m) ∅

/-- `r = −(α₀ + ⋯ + α_{m-1})`. -/
def rootR (m : ℕ) : Fin m → ℤ := -∑ i : Fin m, Pi.single i 1

/-- `s = −α₀`. -/
def rootS (m : ℕ) (hm : 0 < m) : Fin m → ℤ := -Pi.single ⟨0, hm⟩ 1

/-- `μ = (0, 1, …, 1)`. -/
def cocharacter (m : ℕ) : Fin m → ℤ := fun i ↦ if i.val = 0 then 0 else 1

variable {m : ℕ}

/-- The action of `w` in standard coordinates: the signed cyclic shift
`(e₀, …, e_{m-1}) ↦ (-e_{m-1}, e₀, …, e_{m-2})`. -/
def stdWeylWord (m : ℕ) (e : Fin m → ℤ) : Fin m → ℤ := fun a ↦
  if h : a.val = 0 then -e ⟨m - 1, by omega⟩ else e ⟨a.val - 1, by omega⟩

/-- The action of `s_j ⋯ s_{m-1}` in standard coordinates: the signed cyclic shift of the last
`m - j` coordinates. -/
def stdWeylWordDrop (m j : ℕ) (e : Fin m → ℤ) : Fin m → ℤ := fun a ↦
  if a.val < j then e a else if h : a.val = j then -e ⟨m - 1, by omega⟩
  else e ⟨a.val - 1, by omega⟩

private theorem toStdB_prod_drop (m : ℕ) (γ : Fin m → ℤ) :
    ∀ d j, j + d + 1 = m →
      toStdB m ((((List.finRange m).drop j).map
          (CFSG.LieType.RootSystem.reflection (cartanB m))).prod γ) =
        stdWeylWordDrop m j (toStdB m γ) := by
  have hdrop (j) (hj : j < m) :
      (List.finRange m).drop j = ⟨j, hj⟩ :: (List.finRange m).drop (j + 1) := by
    rw [List.drop_eq_getElem_cons (by simpa using hj)]
    simp
  have hc (e : Fin m → ℤ) (x y : Fin m) (h : x.val = y.val) : e x = e y := by rw [Fin.ext h]
  intro d
  induction d with
  | zero =>
    intro j hj
    rw [hdrop j (by omega), List.drop_of_length_le (by simp; omega)]
    simp only [List.map_cons, List.map_nil, List.prod_cons, List.prod_nil, Module.End.mul_apply,
      Module.End.one_apply]
    rw [toStdB_reflection, stdReflB_of_not_lt m (by simp; omega)]
    funext a
    simp only [stdWeylWordDrop]
    by_cases h1 : a.val < j
    · have : a ≠ ⟨j, by omega⟩ := fun h ↦ by simp [Fin.ext_iff] at h; omega
      simp [h1, this]
    · have h3 : a.val = j := by have := a.2; omega
      have h2 : a = ⟨j, by omega⟩ := Fin.ext h3
      rw [ite_eq_left h2, ite_eq_right h1, dite_eq_left h3, neg_one_mul,
        hc (toStdB m γ) a ⟨m - 1, by omega⟩ (by simp; omega)]
  | succ d ih =>
    intro j hj
    rw [hdrop j (by omega)]
    simp only [List.map_cons, List.prod_cons, Module.End.mul_apply]
    rw [toStdB_reflection, ih (j + 1) (by omega),
      stdReflB_of_lt m (k := ⟨j, by omega⟩) (by simp; omega)]
    funext a
    simp only [stdWeylWordDrop, Function.comp]
    by_cases h1 : a.val < j
    · rw [Equiv.swap_apply_of_ne_of_ne (Fin.ne_of_val_ne (by simp; omega))
        (Fin.ne_of_val_ne (by simp; omega)), ite_eq_left h1, ite_eq_left (by omega)]
    by_cases h2 : a.val = j
    · have : a = ⟨j, by omega⟩ := Fin.ext h2
      rw [this, Equiv.swap_apply_left]
      simp only [lt_self_iff_false, ite_false, dite_true]
    by_cases h3 : a.val = j + 1
    · have : a = ⟨j + 1, by omega⟩ := Fin.ext h3
      rw [this, Equiv.swap_apply_right]
      rw [ite_eq_left (show j < j + 1 by omega), dite_eq_right (by omega),
        ite_eq_right (by omega)]
      simp
    · rw [Equiv.swap_apply_of_ne_of_ne (Fin.ne_of_val_ne (by simp; omega))
        (Fin.ne_of_val_ne (by simp; omega)), ite_eq_right (by omega), ite_eq_right (by omega),
        dite_eq_right (by omega), dite_eq_right (by omega)]

private theorem toStdB_reflectionWord (hm : 0 < m) (γ : Fin m → ℤ) :
    toStdB m (reflectionWord (cartanB m) (List.finRange m) γ) = stdWeylWord m (toStdB m γ) := by
  have h0 : reflectionWord (cartanB m) (List.finRange m) γ =
      (((List.finRange m).drop 0).map (CFSG.LieType.RootSystem.reflection (cartanB m))).prod γ :=
    rfl
  rw [h0, toStdB_prod_drop m γ (m - 1) 0 (by omega)]
  funext a
  simp only [stdWeylWordDrop, stdWeylWord]
  by_cases h : a.val = 0 <;> simp [h]

private theorem toStdB_reflectionWord_pow (hm : 0 < m) (k : ℕ) (γ : Fin m → ℤ) :
    toStdB m ((reflectionWord (cartanB m) (List.finRange m) ^ k) γ) =
      (stdWeylWord m)^[k] (toStdB m γ) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ', Module.End.mul_apply, toStdB_reflectionWord hm, ih, Function.iterate_succ_apply']

private theorem stdWeylWord_iterate (hm : 0 < m) (e : Fin m → ℤ) : ∀ k, k ≤ m → ∀ a : Fin m,
    (stdWeylWord m)^[k] e a =
      if h : a.val < k then -e ⟨m - k + a.val, by omega⟩ else e ⟨a.val - k, by omega⟩ := by
  have hc (e : Fin m → ℤ) (x y : Fin m) (h : x.val = y.val) : e x = e y := by rw [Fin.ext h]
  intro k
  induction k with
  | zero => intro _ a; simp
  | succ k ih =>
    intro hk a
    rw [Function.iterate_succ_apply']
    simp only [stdWeylWord]
    by_cases ha : a.val = 0
    · rw [dite_eq_left ha, ih (by omega)]
      simp only
      rw [dite_eq_right (by omega), dite_eq_left (by omega)]
      congr 1
      apply hc
      simp only; omega
    · rw [dite_eq_right ha, ih (by omega)]
      simp only
      by_cases h : a.val < k + 1
      · rw [dite_eq_left (by omega), dite_eq_left h]
        congr 1
        apply hc
        simp only; omega
      · rw [dite_eq_right (by omega), dite_eq_right h]
        apply hc
        simp only; omega

private theorem stdWeylWord_iterate_m (hm : 0 < m) (e : Fin m → ℤ) :
    (stdWeylWord m)^[m] e = -e := by
  funext a
  rw [stdWeylWord_iterate hm e m le_rfl, dite_eq_left a.2]
  simp only [Pi.neg_apply]
  congr 2
  apply Fin.ext
  simp

private theorem reflectionWord_pow_m (hm : 0 < m) (γ : Fin m → ℤ) :
    (reflectionWord (cartanB m) (List.finRange m) ^ m) γ = -γ := by
  apply toStdB_injective m
  rw [toStdB_reflectionWord_pow hm, stdWeylWord_iterate_m hm, toStdB_neg]

private theorem toStdB_rootR (hm : 0 < m) : toStdB m (rootR m) = -Pi.single ⟨0, hm⟩ 1 := by
  have h : ∑ i : Fin m, (Pi.single i (1 : ℤ) : Fin m → ℤ) = fun _ ↦ 1 :=
    Finset.univ_sum_single (fun _ ↦ (1 : ℤ))
  funext a
  simp only [toStdB, rootR, h, Pi.neg_apply, Pi.single_apply]
  split_ifs <;> simp_all [Fin.ext_iff]

private theorem toStdB_rootS (hm : 1 < m) :
    toStdB m (rootS m (by omega)) = Pi.single ⟨1, hm⟩ 1 - Pi.single ⟨0, by omega⟩ 1 := by
  funext a
  simp only [toStdB, rootS, Pi.neg_apply, Pi.sub_apply, Pi.single_apply]
  split_ifs <;> simp_all [Fin.ext_iff] <;> omega

private theorem cocharacterPairing_eq (hm : 3 ≤ m) (γ : Fin m → ℤ) :
    cocharacterPairing (cartanB m) (cocharacter m) γ =
      toStdB m γ ⟨1, by omega⟩ + toStdB m γ ⟨m - 1, by omega⟩ := by
  set g : ℕ → ℤ := fun n ↦ if h : n < m then toStdB m γ ⟨n, h⟩ else 0 with hg
  have key : ∀ i : Fin m, cocharacter m i * ∑ j, cartanB m i j * γ j =
      (if i.val = 0 then 0 else 1) * (g i.val - g (i.val + 1)) +
        (if i.val = m - 1 then g (m - 1) else 0) := by
    intro i
    rw [← CFSG.LieType.RootSystem.coroot_apply]
    by_cases h : i.val + 1 < m
    · rw [coroot_cartanB_of_lt m h]
      have e1 : g i.val = toStdB m γ i := by simp [hg, i.2]
      have e2 : g (i.val + 1) = toStdB m γ ⟨i.val + 1, h⟩ := by simp [hg, h]
      rw [e1, e2]
      simp only [cocharacter]
      split_ifs <;> first | (exfalso; omega) | simp
    · rw [coroot_cartanB_of_not_lt m h]
      have e1 : g i.val = toStdB m γ i := by simp [hg, i.2]
      have e2 : g (i.val + 1) = 0 := by simp [hg, h]
      have e3 : g (m - 1) = toStdB m γ i := by
        have : i.val = m - 1 := by omega
        simp only [hg]
        rw [dite_eq_left (by omega)]
        congr 1
        exact Fin.ext this.symm
      rw [e1, e2, e3]
      simp only [cocharacter]
      split_ifs <;> first | (exfalso; omega) | (simp; ring)
  unfold cocharacterPairing
  rw [Finset.sum_congr rfl (fun i _ ↦ key i),
    Fin.sum_univ_eq_sum_range (fun n ↦ (if n = 0 then 0 else 1) * (g n - g (n + 1)) +
      (if n = m - 1 then g (m - 1) else 0)) m, Finset.sum_add_distrib]
  have h1 (n : ℕ) : (if n = 0 then (0 : ℤ) else 1) * (g n - g (n + 1)) =
      (g n - g (n + 1)) - (if n = 0 then g 0 - g 1 else 0) := by
    split_ifs with h
    · subst h; simp
    · simp
  simp only [h1]
  rw [Finset.sum_sub_distrib, Finset.sum_range_sub', Finset.sum_ite_eq' (Finset.range m) 0,
    Finset.sum_ite_eq' (Finset.range m) (m - 1), ite_eq_left (by simp; omega),
    ite_eq_left (by simp; omega)]
  have e0 : g m = 0 := by simp [hg]
  have e1 : g 1 = toStdB m γ ⟨1, by omega⟩ := by
    simp only [hg]; rw [dite_eq_left (by omega)]
  have e2 : g (m - 1) = toStdB m γ ⟨m - 1, by omega⟩ := by
    simp only [hg]; rw [dite_eq_left (by omega)]
  rw [e0, e2, e1]
  ring

private theorem rootR_apply (a : Fin m) : rootR m a = -1 := by
  have h : ∑ i : Fin m, (Pi.single i (1 : ℤ) : Fin m → ℤ) = fun _ ↦ 1 :=
    Finset.univ_sum_single (fun _ ↦ (1 : ℤ))
  simp [rootR, h]

private theorem rootS_apply_zero (hm : 0 < m) : rootS m hm ⟨0, hm⟩ = -1 := by
  simp [rootS]

theorem rootR_mem (hm : 3 ≤ m) : rootR m ∈ roots m := by
  rw [roots, rootsB_eq]
  refine Or.inr ⟨⟨0, by omega⟩, -1, Or.inr rfl, ?_⟩
  rw [toStdB_rootR (by omega), Pi.single_neg]

theorem rootS_mem (hm : 3 ≤ m) : rootS m (by omega) ∈ roots m := by
  rw [roots, rootsB_eq]
  refine Or.inl ⟨⟨1, by omega⟩, ⟨0, by omega⟩, 1, -1, by simp [Fin.ext_iff], Or.inl rfl,
    Or.inr rfl, ?_⟩
  rw [toStdB_rootS (by omega), Pi.single_neg, sub_eq_add_neg]

theorem rootR_add_rootS_ne_zero (hm : 3 ≤ m) : rootR m + rootS m (by omega) ≠ 0 := by
  intro h
  have := congrFun h ⟨0, by omega⟩
  rw [Pi.add_apply, rootR_apply, rootS_apply_zero] at this
  simp at this

/-- No `i • r + j • s` with `i, j ≥ 1` is a root. -/
theorem noPositiveCombination_rootR_rootS (hm : 3 ≤ m) :
    NoPositiveCombination (roots m) (rootR m) (rootS m (by omega)) := by
  intro i j hi hj hmem
  have h0 : toStdB m (i • rootR m + j • rootS m (by omega)) ⟨0, by omega⟩ = -((i : ℤ) + j) := by
    simp [toStdB, rootR_apply, rootS_apply_zero]
    ring
  have hmem' : _ ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanB m) ∅ := hmem
  rw [rootsB_eq] at hmem'
  rcases hmem' with ⟨a, b, s, t, hab, hs, ht, h⟩ | ⟨a, s, hs, h⟩
  · rw [h] at h0
    simp only [Pi.add_apply, Pi.single_apply] at h0
    rcases hs with rfl | rfl <;> rcases ht with rfl | rfl <;>
      split_ifs at h0 <;> simp_all [Fin.ext_iff] <;> omega
  · rw [h] at h0
    simp only [Pi.single_apply] at h0
    rcases hs with rfl | rfl <;> split_ifs at h0 <;> omega

theorem cocharacterPairing_rootR (hm : 3 ≤ m) :
    cocharacterPairing (cartanB m) (cocharacter m) (rootR m) = 0 := by
  rw [cocharacterPairing_eq hm, toStdB_rootR (by omega)]
  simp [Pi.single_apply, Fin.ext_iff]
  omega

theorem cocharacterPairing_rootS (hm : 3 ≤ m) :
    cocharacterPairing (cartanB m) (cocharacter m) (rootS m (by omega)) = 1 := by
  rw [cocharacterPairing_eq hm, toStdB_rootS (by omega)]
  simp [Pi.single_apply, Fin.ext_iff]
  omega

/-- `e(w r) = −1`. -/
theorem cocharacterPairing_reflectionWord_rootR (hm : 3 ≤ m) :
    cocharacterPairing (cartanB m) (cocharacter m)
      (reflectionWord (cartanB m) (List.finRange m) (rootR m)) = -1 := by
  rw [cocharacterPairing_eq hm, toStdB_reflectionWord (by omega), toStdB_rootR (by omega)]
  simp [stdWeylWord, Pi.single_apply, Fin.ext_iff]
  omega

private theorem toStdB_reflectionWord_pow_rootS (hm : 3 ≤ m) (i : ℕ) (hi : i + 2 ≤ m) :
    toStdB m ((reflectionWord (cartanB m) (List.finRange m) ^ i) (rootS m (by omega))) =
      Pi.single ⟨i + 1, by omega⟩ 1 - Pi.single ⟨i, by omega⟩ 1 := by
  rw [toStdB_reflectionWord_pow (by omega), toStdB_rootS (by omega)]
  funext a
  rw [stdWeylWord_iterate (by omega) _ i (by omega)]
  simp only [Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
  split_ifs <;> simp_all <;> omega

/-- `wⁱ s = −αᵢ` for `0 ≤ i ≤ m-2`. -/
theorem reflectionWord_pow_rootS (hm : 3 ≤ m) (i : Fin m) (hi : i.val + 2 ≤ m) :
    (reflectionWord (cartanB m) (List.finRange m) ^ i.val) (rootS m (by omega)) =
      -Pi.single i 1 := by
  apply toStdB_injective m
  rw [toStdB_reflectionWord_pow_rootS hm i.val hi, toStdB_neg, toStdB_single_of_lt m (by omega)]
  simp only [neg_sub]

/-- `w^{m+i} s = αᵢ` for `0 ≤ i ≤ m-2`. -/
theorem reflectionWord_pow_add_rootS (hm : 3 ≤ m) (i : Fin m) (hi : i.val + 2 ≤ m) :
    (reflectionWord (cartanB m) (List.finRange m) ^ (m + i.val)) (rootS m (by omega)) =
      Pi.single i 1 := by
  rw [pow_add, Module.End.mul_apply, reflectionWord_pow_rootS hm i hi,
    reflectionWord_pow_m (by omega),
    neg_neg]

/-- `w^{m-1} r = −α_{m-1}`. -/
theorem reflectionWord_pow_pred_rootR (hm : 3 ≤ m) :
    (reflectionWord (cartanB m) (List.finRange m) ^ (m - 1)) (rootR m) =
      -Pi.single (⟨m - 1, by omega⟩ : Fin m) 1 := by
  apply toStdB_injective m
  rw [toStdB_reflectionWord_pow (by omega), toStdB_rootR (by omega), toStdB_neg,
    toStdB_single_of_not_lt m (by simp; omega)]
  funext a
  rw [stdWeylWord_iterate (by omega) _ (m - 1) (by omega)]
  simp only [Pi.neg_apply, Pi.single_apply, Fin.ext_iff]
  split_ifs <;> simp_all <;> omega

/-- `w^{2m-1} r = α_{m-1}`. -/
theorem reflectionWord_pow_two_mul_pred_rootR (hm : 3 ≤ m) :
    (reflectionWord (cartanB m) (List.finRange m) ^ (2 * m - 1)) (rootR m) =
      Pi.single (⟨m - 1, by omega⟩ : Fin m) 1 := by
  have : 2 * m - 1 = m + (m - 1) := by omega
  rw [this, pow_add, Module.End.mul_apply, reflectionWord_pow_pred_rootR hm, map_neg,
    reflectionWord_pow_m (by omega), neg_neg]

private theorem reflectionWord_finRange_reverse_apply (hm : 0 < m) (γ : Fin m → ℤ) :
    reflectionWord (cartanB m) (List.finRange m).reverse γ =
      -(reflectionWord (cartanB m) (List.finRange m) ^ (m - 1)) γ := by
  have h1 : reflectionWord (cartanB m) (List.finRange m).reverse *
      reflectionWord (cartanB m) (List.finRange m) = 1 :=
    reflectionWord_reverse_mul (isFiniteType_cartanB m).apply_self _
  have h2 := reflectionWord_pow_m hm γ
  have h2' : (reflectionWord (cartanB m) (List.finRange m) ^ ((m - 1) + 1)) γ = -γ := by
    rwa [Nat.sub_add_cancel hm]
  rw [pow_succ', Module.End.mul_apply] at h2'
  have h4 := congrArg (reflectionWord (cartanB m) (List.finRange m).reverse) h2'
  rw [← Module.End.mul_apply, h1, map_neg] at h4
  simp only [Module.End.one_apply] at h4
  rw [h4, neg_neg]

/-- `e(w⁻¹ r) = 1`. -/
theorem cocharacterPairing_reflectionWord_reverse_rootR (hm : 3 ≤ m) :
    cocharacterPairing (cartanB m) (cocharacter m)
      (reflectionWord (cartanB m) (List.finRange m).reverse (rootR m)) = 1 := by
  rw [reflectionWord_finRange_reverse_apply (by omega), reflectionWord_pow_pred_rootR hm, neg_neg,
    cocharacterPairing_eq hm, toStdB_single_of_not_lt m (by simp; omega)]
  simp [Pi.single_apply, Fin.ext_iff]
  omega

/-- `e(w⁻¹ s) = 1`. -/
theorem cocharacterPairing_reflectionWord_reverse_rootS (hm : 3 ≤ m) :
    cocharacterPairing (cartanB m) (cocharacter m)
      (reflectionWord (cartanB m) (List.finRange m).reverse (rootS m (by omega))) = 1 := by
  rw [reflectionWord_finRange_reverse_apply (by omega), cocharacterPairing_eq hm, toStdB_neg,
    toStdB_reflectionWord_pow (by omega), toStdB_rootS (by omega)]
  simp only [Pi.neg_apply]
  rw [stdWeylWord_iterate (by omega) _ (m - 1) (by omega),
    stdWeylWord_iterate (by omega) _ (m - 1) (by omega)]
  simp only
  rw [dite_eq_left (by omega), dite_eq_right (by omega)]
  simp [Pi.single_apply, Fin.ext_iff]
  omega

/-- Every `±αᵢ` lies in the `w`-orbit of `r` or `s`. -/
theorem inWeylWordOrbit_rootR_rootS (hm : 3 ≤ m) (i : Fin m) (γ : Fin m → ℤ)
    (hγ : γ = Pi.single i 1 ∨ γ = -Pi.single i 1) :
    InWeylWordOrbit (cartanB m) (List.finRange m) {rootR m, rootS m (by omega)} γ := by
  by_cases hi : i.val + 2 ≤ m
  · rcases hγ with rfl | rfl
    · exact ⟨m + i.val, _, by simp, reflectionWord_pow_add_rootS hm i hi⟩
    · exact ⟨i.val, _, by simp, reflectionWord_pow_rootS hm i hi⟩
  · have : i = ⟨m - 1, by omega⟩ := Fin.ext (by simp; omega)
    rw [this] at hγ
    rcases hγ with rfl | rfl
    · exact ⟨2 * m - 1, _, by simp, reflectionWord_pow_two_mul_pred_rootR hm⟩
    · exact ⟨m - 1, _, by simp, reflectionWord_pow_pred_rootR hm⟩

end TypeB

end CFSGCorollary
