module

public import CFSGCorollary.LieType.Chevalley.Roots.Basic
public import CFSG.LieType.Universal.Spin.Roots.TypeD

@[expose] public section

/-!
# Roots of type `D_m`

Root computations for the Cartan matrix `A = cartanD m` (`m ≥ 4`) used in Steinberg's
generation argument for type `D_m` [Steinberg1962, §3.11, §3.13]. In standard coordinates the
simple roots are `αᵢ = eᵢ - eᵢ₊₁` for `i ≤ m - 2` and `α_{m-1} = e_{m-2} + e_{m-1}`. We use the
Coxeter word `L = [m-1, m-2, …, 0]`, `w = reflectionWord A L`
(so `w⁻¹ = reflectionWord A L.reverse`) and the simple roots `a = α_{m-1}`, `b = α_{m-2}`,
`c = α_{m-3}`.

All computations go through the standard coordinates `toStdD`, in which `w` acts as the explicit
signed shift `stdWeylWord`. In particular `w ^ (m - 1)` acts as `-1` when `m` is even.

## Main results

* `TypeD.toStdD_reflectionWord`, `TypeD.toStdD_reflectionWord_reverse`: `w` and `w⁻¹` in standard
  coordinates.
* `TypeD.reflectionWord_pow_pred_apply_eq_neg_even`: `w ^ (m - 1) = -1` for even `m`.
* `TypeD.inWeylWordOrbit_odd`, `TypeD.inWeylWordOrbit_even`: every `±αᵢ` lies in the `w`-orbit of
  `{a, -a, c}` (`m` odd), resp. of `{a, b, c}` (`m` even).
* The root memberships, cocharacter pairings and unique-sum facts used in
  `CFSGCorollary.LieType.Chevalley.Generation.TypeD`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

namespace CFSGCorollary

namespace TypeD

open CFSG.LieType.Universal.Spin

/-- The root system `Φ` of type `D_m` (no doubled indices). -/
abbrev roots (m : ℕ) : Set (Fin m → ℤ) :=
  CFSG.LieType.RootSystem.roots (isFiniteType_cartanD m) ∅

/-- The Coxeter word `L = [m-1, m-2, …, 0]`. -/
def coxeterList (m : ℕ) : List (Fin m) := (List.finRange m).reverse

/-- The simple root `a = α_{m-1}`. -/
def rootA (m : ℕ) (hm : 4 ≤ m) : Fin m → ℤ := Pi.single ⟨m - 1, by omega⟩ 1

/-- The simple root `b = α_{m-2}`. -/
def rootB (m : ℕ) (hm : 4 ≤ m) : Fin m → ℤ := Pi.single ⟨m - 2, by omega⟩ 1

/-- The simple root `c = α_{m-3}`. -/
def rootC (m : ℕ) (hm : 4 ≤ m) : Fin m → ℤ := Pi.single ⟨m - 3, by omega⟩ 1

variable {m : ℕ}

open CFSG.LieType.RootSystem

theorem cartanD_diag (i : Fin m) : cartanD m i i = 2 := by simp [cartanD]

/-! ### Standard coordinates -/

/-- `w` in standard coordinates. -/
def stdWeylWord (m : ℕ) (x : Fin m → ℤ) : Fin m → ℤ := fun p ↦
  if p.val + 2 < m then extendByZero x (p.val + 1)
  else if p.val + 2 = m then -extendByZero x 0 else -x p

/-- `w⁻¹` in standard coordinates. -/
def stdWeylWordInv (m : ℕ) (x : Fin m → ℤ) : Fin m → ℤ := fun p ↦
  if p.val = 0 then -extendByZero x (m - 2)
  else if p.val + 1 = m then -x p else extendByZero x (p.val - 1)

theorem prod_take_succ (j : ℕ) (hj : j < m) :
    (((List.finRange m).take (j + 1)).reverse.map (reflection (cartanD m))).prod =
      reflection (cartanD m) ⟨j, hj⟩ *
        (((List.finRange m).take j).reverse.map (reflection (cartanD m))).prod := by
  rw [List.take_add_one]
  simp [hj]

theorem toStdD_prod_take (j : ℕ) (hj : j + 1 ≤ m) (γ : Fin m → ℤ) (p : Fin m) :
    toStdD m ((((List.finRange m).take j).reverse.map (reflection (cartanD m))).prod γ) p =
      if p.val < j then extendByZero (toStdD m γ) (p.val + 1)
      else if p.val = j then extendByZero (toStdD m γ) 0 else toStdD m γ p := by
  induction j generalizing p with
  | zero =>
    simp only [List.take_zero, List.reverse_nil, List.map_nil, List.prod_nil,
      Module.End.one_apply, Nat.not_lt_zero, ite_false]
    split_ifs with h
    · rw [← h, extendByZero_val]
    · rfl
  | succ j ih =>
    have hjm : j + 1 < m := by omega
    rw [prod_take_succ j (by omega), Module.End.mul_apply, toStdD_reflection,
      stdReflD_of_lt m (k := ⟨j, by omega⟩) hjm]
    simp only [Function.comp]
    by_cases h1 : p.val = j
    · have : Equiv.swap (⟨j, by omega⟩ : Fin m) ⟨j + 1, hjm⟩ p = ⟨j + 1, by omega⟩ := by
        rw [Equiv.swap_apply_def, ite_eq_left (Fin.ext h1)]
      rw [this, ih (by omega)]
      simp only [h1]
      split_ifs <;> first | (exfalso; omega) | exact (extendByZero_val _ ⟨j + 1, hjm⟩).symm
    by_cases h2 : p.val = j + 1
    · have : Equiv.swap (⟨j, by omega⟩ : Fin m) ⟨j + 1, hjm⟩ p = ⟨j, by omega⟩ := by
        rw [Equiv.swap_apply_def, ite_eq_right (fun h ↦ h1 (congrArg Fin.val h)),
          ite_eq_left (Fin.ext h2)]
      rw [this, ih (by omega)]
      simp only [h2]
      split_ifs <;> simp_all
    · have : Equiv.swap (⟨j, by omega⟩ : Fin m) ⟨j + 1, hjm⟩ p = p :=
        Equiv.swap_apply_of_ne_of_ne (fun h ↦ h1 (by rw [h])) (fun h ↦ h2 (by rw [h]))
      rw [this, ih (by omega)]
      split_ifs <;> simp_all <;> omega

/-- `w` acts in standard coordinates as `stdWeylWord`. -/
theorem toStdD_reflectionWord (hm : 2 ≤ m) (γ : Fin m → ℤ) :
    toStdD m (reflectionWord (cartanD m) (coxeterList m) γ) = stdWeylWord m (toStdD m γ) := by
  have h1 := prod_take_succ (m := m) (m - 1) (by omega)
  rw [show m - 1 + 1 = m by omega, List.take_of_length_le (by simp)] at h1
  have h2 : reflectionWord (cartanD m) (coxeterList m) =
      reflection (cartanD m) ⟨m - 1, by omega⟩ *
        (((List.finRange m).take (m - 1)).reverse.map (reflection (cartanD m))).prod := by
    rw [← h1]; rfl
  rw [h2, Module.End.mul_apply, toStdD_reflection]
  funext p
  rw [stdReflD_of_not_lt m (k := ⟨m - 1, by omega⟩) (by change ¬m - 1 + 1 < m; omega)]
  simp only [stdWeylWord]
  have key := toStdD_prod_take (m - 1) (by omega) γ
  by_cases hp : p.val + 2 < m
  · have : Equiv.swap (⟨m - 1 - 1, by omega⟩ : Fin m) ⟨m - 1, by omega⟩ p = p := by
      apply Equiv.swap_apply_of_ne_of_ne
      · intro h; rw [Fin.ext_iff] at h; simp only at h; omega
      · intro h; rw [Fin.ext_iff] at h; simp only at h; omega
    rw [this, key]
    split_ifs <;> first | (exfalso; omega) | simp
  · rcases (by omega : p.val + 2 = m ∨ p.val + 1 = m) with h | h
    · have : Equiv.swap (⟨m - 1 - 1, by omega⟩ : Fin m) ⟨m - 1, by omega⟩ p =
          ⟨m - 1, by omega⟩ := by
        rw [Equiv.swap_apply_def, ite_eq_left (Fin.ext (by first | omega | (simp only; omega)))]
      rw [this, key]
      split_ifs <;> first | (exfalso; omega) | (exfalso; simp only at *; omega) | simp
    · have hpx : extendByZero (toStdD m γ) (m - 1) = toStdD m γ p := by
        rw [← extendByZero_val (toStdD m γ) p]; congr 1; omega
      have : Equiv.swap (⟨m - 1 - 1, by omega⟩ : Fin m) ⟨m - 1, by omega⟩ p =
          ⟨m - 1 - 1, by omega⟩ := by
        rw [Equiv.swap_apply_def,
          ite_eq_right (fun h' ↦ by rw [Fin.ext_iff] at h'; simp only at h'; omega),
          ite_eq_left (Fin.ext (by first | omega | (simp only; omega)))]
      rw [this, key]
      split_ifs <;> first | (exfalso; omega) | (exfalso; simp only at *; omega) |
        (rw [show m - 1 - 1 + 1 = m - 1 by omega, hpx]; simp)

theorem stdWeylWordInv_stdWeylWord (hm : 2 ≤ m) (x : Fin m → ℤ) :
    stdWeylWordInv m (stdWeylWord m x) = x := by
  funext p
  simp only [stdWeylWordInv]
  split_ifs with h0 h1
  · rw [extendByZero_of_lt _ (by omega)]
    simp only [stdWeylWord]
    rw [ite_eq_right (by omega), ite_eq_left (by omega), neg_neg, extendByZero_of_lt _ (by omega)]
    congr 1; exact (Fin.ext h0).symm
  · simp only [stdWeylWord]
    rw [ite_eq_right (by omega), ite_eq_right (by omega), neg_neg]
  · rw [extendByZero_of_lt _ (by omega)]
    simp only [stdWeylWord]
    rw [ite_eq_left (by omega), extendByZero_of_lt _ (by omega)]
    congr 1; exact Fin.ext (by first | omega | (simp only; omega))

/-- `w⁻¹` acts in standard coordinates as `stdWeylWordInv`. -/
theorem toStdD_reflectionWord_reverse (hm : 2 ≤ m) (γ : Fin m → ℤ) :
    toStdD m (reflectionWord (cartanD m) (coxeterList m).reverse γ) =
      stdWeylWordInv m (toStdD m γ) := by
  have h := reflectionWord_mul_reflectionWord_reverse (A := cartanD m) cartanD_diag (coxeterList m)
  have h2 : reflectionWord (cartanD m) (coxeterList m)
      (reflectionWord (cartanD m) (coxeterList m).reverse γ) = γ := by
    simpa using LinearMap.congr_fun h γ
  have h3 := toStdD_reflectionWord hm (reflectionWord (cartanD m) (coxeterList m).reverse γ)
  rw [h2] at h3
  rw [h3, stdWeylWordInv_stdWeylWord hm]

theorem toStdD_reflectionWord_pow (hm : 2 ≤ m) (k : ℕ) (γ : Fin m → ℤ) :
    toStdD m ((reflectionWord (cartanD m) (coxeterList m) ^ k) γ) =
      (stdWeylWord m)^[k] (toStdD m γ) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ', Module.End.mul_apply, toStdD_reflectionWord hm, ih, Function.iterate_succ_apply']

theorem stdWeylWord_iterate (hm : 2 ≤ m) (k : ℕ) (hk : k ≤ m - 1) (x : Fin m → ℤ) (p : Fin m)
    (hp : p.val + 2 ≤ m) :
    (stdWeylWord m)^[k] x p =
      if p.val + k + 2 ≤ m then extendByZero x (p.val + k)
      else -extendByZero x (p.val + k - (m - 1)) := by
  induction k generalizing p with
  | zero =>
    simp only [Function.iterate_zero, id_eq, add_zero]
    rw [ite_eq_left hp, extendByZero_val]
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    simp only [stdWeylWord]
    by_cases h1 : p.val + 2 < m
    · rw [ite_eq_left h1, extendByZero_of_lt _ (by omega),
        ih (by omega) ⟨p.val + 1, by omega⟩ (by simp only; omega)]
      simp only
      split_ifs <;> first | (exfalso; omega) | (congr 1; omega) | (congr 2; omega)
    · have h2 : p.val + 2 = m := by omega
      rw [ite_eq_right h1, ite_eq_left h2, extendByZero_of_lt _ (by omega),
        ih (by omega) ⟨0, by omega⟩ (by omega)]
      simp only
      split_ifs <;> first | (exfalso; omega) | (congr 2; omega)

theorem stdWeylWord_iterate_last (k : ℕ) (x : Fin m → ℤ) (p : Fin m) (hp : p.val + 1 = m) :
    (stdWeylWord m)^[k] x p = (-1) ^ k * x p := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    simp only [stdWeylWord]
    rw [ite_eq_right (by omega), ite_eq_right (by omega), ih, pow_succ]
    ring

theorem stdWeylWord_iterate_pred_apply (hm : 2 ≤ m) (heven : m % 2 = 0) (x : Fin m → ℤ) :
    (stdWeylWord m)^[m - 1] x = -x := by
  funext p
  by_cases hp : p.val + 2 ≤ m
  · rw [stdWeylWord_iterate hm (m - 1) le_rfl x p hp, ite_eq_right (by omega), Pi.neg_apply,
      show p.val + (m - 1) - (m - 1) = p.val by omega, extendByZero_val]
  · rw [stdWeylWord_iterate_last _ x p (by omega), Pi.neg_apply]
    obtain ⟨t, ht⟩ : ∃ t, m - 1 = 2 * t + 1 := ⟨(m - 2) / 2, by omega⟩
    rw [ht, pow_succ, pow_mul]; simp

theorem stdWeylWord_iterate_pred_of_last_eq_zero (hm : 2 ≤ m) (x : Fin m → ℤ)
    (hx : extendByZero x (m - 1) = 0) : (stdWeylWord m)^[m - 1] x = -x := by
  funext p
  by_cases hp : p.val + 2 ≤ m
  · rw [stdWeylWord_iterate hm (m - 1) le_rfl x p hp, ite_eq_right (by omega), Pi.neg_apply,
      show p.val + (m - 1) - (m - 1) = p.val by omega, extendByZero_val]
  · rw [stdWeylWord_iterate_last _ x p (by omega), Pi.neg_apply]
    have : x p = 0 := by
      rw [← extendByZero_val x p, show p.val = m - 1 by omega]; exact hx
    rw [this]; simp

theorem stdWeylWord_iterate_pred_apply_of_odd (hm : 2 ≤ m) (hodd : m % 2 = 1) (x : Fin m → ℤ)
    (p : Fin m) : (stdWeylWord m)^[m - 1] x p = if p.val + 1 = m then x p else -x p := by
  by_cases hp : p.val + 2 ≤ m
  · rw [stdWeylWord_iterate hm (m - 1) le_rfl x p hp, ite_eq_right (by omega),
      ite_eq_right (by omega), show p.val + (m - 1) - (m - 1) = p.val by omega, extendByZero_val]
  · rw [stdWeylWord_iterate_last _ x p (by omega), ite_eq_left (by omega)]
    obtain ⟨t, ht⟩ : ∃ t, m - 1 = 2 * t := ⟨(m - 1) / 2, by omega⟩
    rw [ht, pow_mul]; simp

/-! ### The roots `a`, `b`, `c` in standard coordinates -/

/-- Coordinates of `a` in standard coordinates. -/
def stdRootA (m n : ℕ) : ℤ := if n + 2 = m ∨ n + 1 = m then 1 else 0

/-- Coordinates of `b` in standard coordinates. -/
def stdRootB (m n : ℕ) : ℤ := if n + 2 = m then 1 else if n + 1 = m then -1 else 0

/-- Coordinates of `c` in standard coordinates. -/
def stdRootC (m n : ℕ) : ℤ := if n + 3 = m then 1 else if n + 2 = m then -1 else 0

theorem toStdD_rootA (hm : 4 ≤ m) : toStdD m (rootA m hm) = fun p ↦ stdRootA m p.val := by
  rw [rootA, toStdD_single_of_not_lt m (by change ¬m - 1 + 1 < m; omega) (by omega)]
  funext p
  simp only [Pi.add_apply, Pi.single_apply, Fin.ext_iff, stdRootA]
  split_ifs <;> omega

theorem toStdD_rootB (hm : 4 ≤ m) : toStdD m (rootB m hm) = fun p ↦ stdRootB m p.val := by
  rw [rootB, toStdD_single_of_lt m (k := ⟨m - 2, by omega⟩) (by simp only; omega)]
  funext p
  simp only [Pi.sub_apply, Pi.single_apply, Fin.ext_iff, stdRootB]
  split_ifs <;> omega

theorem toStdD_rootC (hm : 4 ≤ m) : toStdD m (rootC m hm) = fun p ↦ stdRootC m p.val := by
  rw [rootC, toStdD_single_of_lt m (k := ⟨m - 3, by omega⟩) (by simp only; omega)]
  funext p
  simp only [Pi.sub_apply, Pi.single_apply, Fin.ext_iff, stdRootC]
  split_ifs <;> omega

theorem extendByZero_toStdD_rootA (hm : 4 ≤ m) (n : ℕ) :
    extendByZero (toStdD m (rootA m hm)) n = stdRootA m n := by
  rw [toStdD_rootA]
  exact extendByZero_comp_val _ (fun n hn ↦ by simp [stdRootA]; omega) n

theorem extendByZero_toStdD_rootB (hm : 4 ≤ m) (n : ℕ) :
    extendByZero (toStdD m (rootB m hm)) n = stdRootB m n := by
  rw [toStdD_rootB]
  exact extendByZero_comp_val _ (fun n hn ↦ by simp [stdRootB]; omega) n

theorem extendByZero_toStdD_rootC (hm : 4 ≤ m) (n : ℕ) :
    extendByZero (toStdD m (rootC m hm)) n = stdRootC m n := by
  rw [toStdD_rootC]
  exact extendByZero_comp_val _ (fun n hn ↦ by simp [stdRootC]; omega) n

theorem extendByZero_stdRootA (hm : 4 ≤ m) (n : ℕ) :
    extendByZero (fun p : Fin m ↦ stdRootA m p.val) n = stdRootA m n := by
  rw [← toStdD_rootA hm]; exact extendByZero_toStdD_rootA hm n

theorem extendByZero_stdRootB (hm : 4 ≤ m) (n : ℕ) :
    extendByZero (fun p : Fin m ↦ stdRootB m p.val) n = stdRootB m n := by
  rw [← toStdD_rootB hm]; exact extendByZero_toStdD_rootB hm n

theorem extendByZero_stdRootC (hm : 4 ≤ m) (n : ℕ) :
    extendByZero (fun p : Fin m ↦ stdRootC m p.val) n = stdRootC m n := by
  rw [← toStdD_rootC hm]; exact extendByZero_toStdD_rootC hm n

theorem cocharacterPairing_single (k : Fin m) (γ : Fin m → ℤ) :
    cocharacterPairing (cartanD m) (Pi.single k 1) γ = coroot (cartanD m) k γ := by
  simp [cocharacterPairing, coroot_apply, Pi.single_apply]

theorem cocharacterPairing_rootA (hm : 4 ≤ m) (γ : Fin m → ℤ) :
    cocharacterPairing (cartanD m) (rootA m hm) γ =
      extendByZero (toStdD m γ) (m - 2) + extendByZero (toStdD m γ) (m - 1) := by
  rw [rootA, cocharacterPairing_single,
    coroot_cartanD_of_not_lt m (by change ¬m - 1 + 1 < m; omega),
    extendByZero_of_lt _ (by omega), extendByZero_of_lt _ (by omega)]
  rfl

theorem cocharacterPairing_rootB (hm : 4 ≤ m) (γ : Fin m → ℤ) :
    cocharacterPairing (cartanD m) (rootB m hm) γ =
      extendByZero (toStdD m γ) (m - 2) - extendByZero (toStdD m γ) (m - 1) := by
  rw [rootB, cocharacterPairing_single, coroot_cartanD_of_lt m (by simp only; omega),
    extendByZero_of_lt _ (by omega), extendByZero_of_lt _ (by omega)]
  congr 2; apply Fin.ext; simp only; omega

/-! ### Roots of type `D` in standard coordinates -/

theorem toStdD_nsmul (c : ℕ) (v : Fin m → ℤ) : toStdD m (c • v) = c • toStdD m v := by
  simpa using toStdD_smul m (c : ℤ) v

theorem mem_roots_of_toStdD_eq (hm : 4 ≤ m) {γ : Fin m → ℤ} (i j : Fin m) (s t : ℤ)
    (hij : i ≠ j) (hs : s = 1 ∨ s = -1) (ht : t = 1 ∨ t = -1)
    (h : toStdD m γ = Pi.single i s + Pi.single j t) : γ ∈ roots m := by
  have hr : roots m = _ := rootsD_eq m (by omega)
  rw [hr]
  exact ⟨i, j, s, t, hij, hs, ht, h⟩

theorem abs_toStdD_le_one (hm : 4 ≤ m) {γ : Fin m → ℤ} (hγ : γ ∈ roots m) (p : Fin m) :
    |toStdD m γ p| ≤ 1 := by
  have hr : roots m = _ := rootsD_eq m (by omega)
  rw [hr] at hγ
  obtain ⟨i, j, s, t, hij, hs, ht, h⟩ := hγ
  rw [h]
  simp only [Pi.add_apply, Pi.single_apply]
  by_cases hpi : p = i
  · have hpj : p ≠ j := fun h' ↦ hij (hpi.symm.trans h')
    rw [ite_eq_left hpi, ite_eq_right hpj]
    rcases hs with rfl | rfl <;> simp
  · by_cases hpj : p = j
    · rw [ite_eq_right hpi, ite_eq_left hpj]
      rcases ht with rfl | rfl <;> simp
    · rw [ite_eq_right hpi, ite_eq_right hpj]; simp

theorem eq_one_and_eq_one_of_nsmul_add_nsmul_mem_roots (hm : 4 ≤ m) {u v : Fin m → ℤ}
    (p q : Fin m) {ε δ : ℤ} (hε : ε = 1 ∨ ε = -1) (hδ : δ = 1 ∨ δ = -1)
    (h1 : toStdD m u p = ε) (h2 : toStdD m v p = 0) (h3 : toStdD m u q = 0)
    (h4 : toStdD m v q = δ) (i j : ℕ) (hi : 0 < i) (hj : 0 < j) (h : i • u + j • v ∈ roots m) :
    i = 1 ∧ j = 1 := by
  have b1 := abs_toStdD_le_one hm h p
  have b2 := abs_toStdD_le_one hm h q
  rw [toStdD_add, toStdD_nsmul, toStdD_nsmul] at b1 b2
  simp only [Pi.add_apply, Pi.smul_apply] at b1 b2
  simp only [nsmul_eq_mul, h1, h2, h3, h4, mul_zero, add_zero, zero_add] at b1 b2
  rw [abs_le] at b1 b2
  rcases hε with rfl | rfl <;> rcases hδ with rfl | rfl <;> constructor <;> omega

theorem noRootPositiveCombination_of_toStdD_apply_eq (hm : 4 ≤ m) {u v : Fin m → ℤ} (p : Fin m)
    {ε : ℤ} (hε : ε = 1 ∨ ε = -1) (h1 : toStdD m u p = ε) (h2 : toStdD m v p = ε) :
    NoPositiveCombination (roots m) u v := by
  intro i j hi hj h
  have b1 := abs_toStdD_le_one hm h p
  rw [toStdD_add, toStdD_nsmul, toStdD_nsmul] at b1
  simp only [Pi.add_apply, Pi.smul_apply] at b1
  simp only [nsmul_eq_mul, h1, h2] at b1
  rw [abs_le] at b1
  rcases hε with rfl | rfl <;> omega

set_option hygiene false in
/-- Expand a standard-coordinate entry of a combination of `a`, `b`, `c` (and of their images
under `w`, `w⁻¹`) into explicit `if`s on the index. -/
local macro "cstd1" : tactic => `(tactic| simp only [toStdD_add, toStdD_sub, toStdD_neg,
  toStdD_rootA hm, toStdD_rootB hm, toStdD_rootC hm, Pi.add_apply, Pi.sub_apply, Pi.neg_apply,
  Pi.single_apply, Fin.ext_iff, extendByZero_neg, extendByZero_add, extendByZero_sub,
  extendByZero_stdRootA hm, extendByZero_stdRootB hm, extendByZero_stdRootC hm, stdWeylWord,
  stdWeylWordInv])

set_option hygiene false in
/-- Close a standard-coordinate identity between combinations of `a`, `b`, `c` by case analysis
on the index. -/
local macro "cstd" : tactic => `(tactic| (cstd1; simp only [stdRootA, stdRootB, stdRootC]; try
  split_ifs <;> first | omega | rfl | (exfalso; omega) | simp))

/-! ### Orbits of `±αᵢ` under `w` -/

theorem reflectionWord_pow_rootC (hm : 4 ≤ m) (i : Fin m) (hi : i.val + 3 ≤ m) :
    (reflectionWord (cartanD m) (coxeterList m) ^ (m - 3 - i.val)) (rootC m hm) =
      Pi.single i 1 := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord_pow (by omega), toStdD_single_of_lt m (by omega)]
  funext p
  by_cases hp : p.val + 2 ≤ m
  · rw [stdWeylWord_iterate (by omega) _ (by omega) _ p hp]
    simp only [toStdD_rootC hm, extendByZero_stdRootC hm, Pi.sub_apply, Pi.single_apply,
      Fin.ext_iff]
    simp only [stdRootC]
    split_ifs <;> omega
  · rw [stdWeylWord_iterate_last _ _ p (by omega)]
    simp only [toStdD_rootC hm, Pi.sub_apply, Pi.single_apply, Fin.ext_iff]
    simp only [stdRootC]
    split_ifs <;> omega

theorem reflectionWord_pow_pred_single (hm : 4 ≤ m) (i : Fin m) (hi : i.val + 3 ≤ m) :
    (reflectionWord (cartanD m) (coxeterList m) ^ (m - 1)) (Pi.single i 1) = -Pi.single i 1 := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord_pow (by omega), toStdD_neg, toStdD_single_of_lt m (by omega)]
  apply stdWeylWord_iterate_pred_of_last_eq_zero (by omega)
  rw [extendByZero_sub]
  simp only [extendByZero, Pi.single_apply, Fin.ext_iff]
  split_ifs <;> omega

theorem exists_reflectionWord_pow_rootC_eq (hm : 4 ≤ m) (i : Fin m) (hi : i.val + 3 ≤ m)
    (γ : Fin m → ℤ) (hγ : γ = Pi.single i 1 ∨ γ = -Pi.single i 1) :
    ∃ k : ℕ, (reflectionWord (cartanD m) (coxeterList m) ^ k) (rootC m hm) = γ := by
  rcases hγ with rfl | rfl
  · exact ⟨_, reflectionWord_pow_rootC hm i hi⟩
  · refine ⟨(m - 1) + (m - 3 - i.val), ?_⟩
    rw [pow_add, Module.End.mul_apply, reflectionWord_pow_rootC hm i hi,
      reflectionWord_pow_pred_single hm i hi]

/-! ### Odd `m` -/

section Odd

variable (hm : 4 ≤ m) (hodd : m % 2 = 1)
include hm hodd

theorem cocharacterPairing_rootA_odd :
    cocharacterPairing (cartanD m) (rootA m hm) (rootA m hm) = 2 := by
  rw [cocharacterPairing_rootA, extendByZero_toStdD_rootA, extendByZero_toStdD_rootA]
  simp only [stdRootA]
  rw [ite_eq_left (by omega), ite_eq_left (by omega)]; rfl

theorem cocharacterPairing_reflectionWord_reverse_rootA_odd :
    cocharacterPairing (cartanD m) (rootA m hm)
      (reflectionWord (cartanD m) (coxeterList m).reverse (rootA m hm)) = -1 := by
  rw [cocharacterPairing_rootA, toStdD_reflectionWord_reverse (by omega),
    extendByZero_of_lt _ (by omega), extendByZero_of_lt _ (by omega)]
  simp only [stdWeylWordInv, toStdD_rootA, extendByZero_stdRootA hm]
  simp only [stdRootA]
  split_ifs <;> omega

theorem reflectionWord_rootA_odd :
    reflectionWord (cartanD m) (coxeterList m) (rootA m hm) = rootB m hm + rootC m hm := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord (by omega), toStdD_add]
  funext p
  simp only [stdWeylWord, toStdD_rootA, extendByZero_stdRootA hm, Pi.add_apply, toStdD_rootB,
    toStdD_rootC]
  simp only [stdRootA, stdRootB, stdRootC]
  split_ifs <;> omega

theorem reflectionWord_pow_pred_rootA_odd :
    (reflectionWord (cartanD m) (coxeterList m) ^ (m - 1)) (rootA m hm) = -rootB m hm := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord_pow (by omega), toStdD_neg]
  funext p
  rw [stdWeylWord_iterate_pred_apply_of_odd (by omega) hodd, Pi.neg_apply]
  cstd

theorem reflectionWord_neg_rootB_odd :
    reflectionWord (cartanD m) (coxeterList m) (-rootB m hm) = -rootA m hm - rootC m hm := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord (by omega)]
  funext p
  cstd

theorem onlyPositiveCombination_rootC_odd :
    OnlyPositiveCombination (roots m) (rootB m hm + rootC m hm) (-rootB m hm) (rootC m hm) := by
  refine ⟨by abel, mem_roots_of_toStdD_eq hm ⟨m - 3, by omega⟩ ⟨m - 2, by omega⟩ 1 (-1)
    (by simp [Fin.ext_iff]; omega) (Or.inl rfl) (Or.inr rfl) (by funext p; cstd), ?_⟩
  intro i j hi hj h
  exact eq_one_and_eq_one_of_nsmul_add_nsmul_mem_roots hm ⟨m - 3, by omega⟩ ⟨m - 2, by omega⟩
    (ε := 1) (δ := -1) (Or.inl rfl) (Or.inr rfl) (by cstd) (by cstd) (by cstd) (by cstd)
    i j hi hj h

theorem onlyPositiveCombination_neg_rootA_odd :
    OnlyPositiveCombination (roots m) (rootC m hm) (-rootA m hm - rootC m hm) (-rootA m hm) := by
  refine ⟨by abel, mem_roots_of_toStdD_eq hm ⟨m - 2, by omega⟩ ⟨m - 1, by omega⟩ (-1) (-1)
    (by simp [Fin.ext_iff]; omega) (Or.inr rfl) (Or.inr rfl) (by funext p; cstd), ?_⟩
  intro i j hi hj h
  exact eq_one_and_eq_one_of_nsmul_add_nsmul_mem_roots hm ⟨m - 2, by omega⟩ ⟨m - 1, by omega⟩
    (ε := -1) (δ := -1) (Or.inr rfl) (Or.inr rfl) (by cstd) (by cstd) (by cstd) (by cstd)
    i j hi hj h

/-- For odd `m`, every `±αᵢ` lies in the `w`-orbit of `{a, -a, c}`. -/
theorem inWeylWordOrbit_odd (i : Fin m) (γ : Fin m → ℤ)
    (hγ : γ = Pi.single i 1 ∨ γ = -Pi.single i 1) :
    InWeylWordOrbit (cartanD m) (coxeterList m) {rootA m hm, -rootA m hm, rootC m hm} γ := by
  by_cases h3 : i.val + 3 ≤ m
  · obtain ⟨k, hk⟩ := exists_reflectionWord_pow_rootC_eq hm i h3 γ hγ
    exact ⟨k, _, by simp, hk⟩
  · by_cases h2 : i.val + 2 = m
    · have hlt : m - 2 < m := by omega
      obtain rfl : i = ⟨m - 2, hlt⟩ := Fin.ext (by simp only; omega)
      rcases hγ with rfl | rfl
      · refine ⟨m - 1, -rootA m hm, by simp, ?_⟩
        rw [map_neg, reflectionWord_pow_pred_rootA_odd hm hodd, neg_neg]; rfl
      · exact ⟨m - 1, rootA m hm, by simp, reflectionWord_pow_pred_rootA_odd hm hodd⟩
    · have hlt : m - 1 < m := by omega
      obtain rfl : i = ⟨m - 1, hlt⟩ := Fin.ext (by simp only; omega)
      rcases hγ with rfl | rfl
      · exact ⟨0, rootA m hm, by simp, by simp [rootA]⟩
      · exact ⟨0, -rootA m hm, by simp, by simp [rootA]⟩

end Odd

/-! ### Even `m` -/

section Even

variable (hm : 4 ≤ m) (heven : m % 2 = 0)
include hm heven

theorem neg_rootA_mem_even : -rootA m hm ∈ roots m :=
  mem_roots_of_toStdD_eq hm ⟨m - 2, by omega⟩ ⟨m - 1, by omega⟩ (-1) (-1)
    (by simp [Fin.ext_iff]; omega) (Or.inr rfl) (Or.inr rfl) (by funext p; cstd)

theorem rootC_mem_even : rootC m hm ∈ roots m :=
  mem_roots_of_toStdD_eq hm ⟨m - 3, by omega⟩ ⟨m - 2, by omega⟩ 1 (-1)
    (by simp [Fin.ext_iff]; omega) (Or.inl rfl) (Or.inr rfl) (by funext p; cstd)

theorem neg_rootA_add_rootC_ne_zero_even : -rootA m hm + rootC m hm ≠ 0 := by
  intro h
  have h' : toStdD m (-rootA m hm + rootC m hm) ⟨m - 1, by omega⟩ = -1 := by cstd
  rw [h, toStdD_zero] at h'
  simp at h'

theorem noPositiveCombination_neg_rootA_rootC_even :
    NoPositiveCombination (roots m) (-rootA m hm) (rootC m hm) :=
  noRootPositiveCombination_of_toStdD_apply_eq hm ⟨m - 2, by omega⟩ (ε := -1) (Or.inr rfl)
    (by cstd) (by cstd)

theorem cocharacterPairing_neg_rootA_even :
    cocharacterPairing (cartanD m) (rootB m hm) (-rootA m hm) = 0 := by
  rw [cocharacterPairing_rootB]; cstd

theorem cocharacterPairing_rootC_even :
    cocharacterPairing (cartanD m) (rootB m hm) (rootC m hm) = -1 := by
  rw [cocharacterPairing_rootB]; cstd

theorem cocharacterPairing_reflectionWord_reverse_neg_rootA_even :
    cocharacterPairing (cartanD m) (rootB m hm)
      (reflectionWord (cartanD m) (coxeterList m).reverse (-rootA m hm)) = -1 := by
  rw [cocharacterPairing_rootB, toStdD_reflectionWord_reverse (by omega),
    extendByZero_of_lt _ (by omega), extendByZero_of_lt _ (by omega)]
  cstd

theorem cocharacterPairing_reflectionWord_reverse_rootC_even :
    cocharacterPairing (cartanD m) (rootB m hm)
      (reflectionWord (cartanD m) (coxeterList m).reverse (rootC m hm)) = 1 := by
  rw [cocharacterPairing_rootB, toStdD_reflectionWord_reverse (by omega),
    extendByZero_of_lt _ (by omega), extendByZero_of_lt _ (by omega)]
  cstd

theorem cocharacterPairing_reflectionWord_neg_rootA_even :
    cocharacterPairing (cartanD m) (rootB m hm)
      (reflectionWord (cartanD m) (coxeterList m) (-rootA m hm)) = -1 := by
  rw [cocharacterPairing_rootB, toStdD_reflectionWord (by omega), extendByZero_of_lt _ (by omega),
    extendByZero_of_lt _ (by omega)]
  cstd

theorem reflectionWord_neg_rootA_even :
    reflectionWord (cartanD m) (coxeterList m) (-rootA m hm) = -rootB m hm - rootC m hm := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord (by omega)]
  funext p
  cstd

theorem onlyPositiveCombination_neg_rootB_even :
    OnlyPositiveCombination (roots m) (-rootB m hm - rootC m hm) (rootC m hm) (-rootB m hm) := by
  refine ⟨by abel, mem_roots_of_toStdD_eq hm ⟨m - 2, by omega⟩ ⟨m - 1, by omega⟩ (-1) 1
    (by simp [Fin.ext_iff]; omega) (Or.inr rfl) (Or.inl rfl) (by funext p; cstd), ?_⟩
  intro i j hi hj h
  exact eq_one_and_eq_one_of_nsmul_add_nsmul_mem_roots hm ⟨m - 1, by omega⟩ ⟨m - 2, by omega⟩
    (ε := 1) (δ := -1) (Or.inl rfl) (Or.inr rfl) (by cstd) (by cstd) (by cstd) (by cstd)
    i j hi hj h

theorem onlyPositiveCombination_rootA_add_rootC_even :
    OnlyPositiveCombination (roots m) (rootA m hm) (rootC m hm) (rootA m hm + rootC m hm) := by
  refine ⟨rfl, mem_roots_of_toStdD_eq hm ⟨m - 3, by omega⟩ ⟨m - 1, by omega⟩ 1 1
    (by simp [Fin.ext_iff]; omega) (Or.inl rfl) (Or.inl rfl) (by funext p; cstd), ?_⟩
  intro i j hi hj h
  exact eq_one_and_eq_one_of_nsmul_add_nsmul_mem_roots hm ⟨m - 1, by omega⟩ ⟨m - 3, by omega⟩
    (ε := 1) (δ := 1) (Or.inl rfl) (Or.inl rfl) (by cstd) (by cstd) (by cstd) (by cstd)
    i j hi hj h

theorem reflectionWord_reverse_rootA_add_rootC_even :
    reflectionWord (cartanD m) (coxeterList m).reverse (rootA m hm + rootC m hm) = rootB m hm := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord_reverse (by omega)]
  funext p
  cstd

theorem noPositiveCombination_rootA_rootB_even :
    NoPositiveCombination (roots m) (rootA m hm) (rootB m hm) :=
  noRootPositiveCombination_of_toStdD_apply_eq hm ⟨m - 2, by omega⟩ (ε := 1) (Or.inl rfl)
    (by cstd) (by cstd)

theorem onlyPositiveCombination_rootC_add_rootB_even :
    OnlyPositiveCombination (roots m) (rootC m hm) (rootB m hm) (rootB m hm + rootC m hm) := by
  refine ⟨add_comm _ _, mem_roots_of_toStdD_eq hm ⟨m - 3, by omega⟩ ⟨m - 1, by omega⟩ 1 (-1)
    (by simp [Fin.ext_iff]; omega) (Or.inl rfl) (Or.inr rfl) (by funext p; cstd), ?_⟩
  intro i j hi hj h
  exact eq_one_and_eq_one_of_nsmul_add_nsmul_mem_roots hm ⟨m - 3, by omega⟩ ⟨m - 1, by omega⟩
    (ε := 1) (δ := -1) (Or.inl rfl) (Or.inr rfl) (by cstd) (by cstd) (by cstd) (by cstd)
    i j hi hj h

theorem reflectionWord_reverse_rootB_add_rootC_even :
    reflectionWord (cartanD m) (coxeterList m).reverse (rootB m hm + rootC m hm) = rootA m hm := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord_reverse (by omega)]
  funext p
  cstd

/-- For even `m`, `w ^ (m - 1)` acts as `-1`. -/
theorem reflectionWord_pow_pred_apply_eq_neg_even (γ : Fin m → ℤ) :
    (reflectionWord (cartanD m) (coxeterList m) ^ (m - 1)) γ = -γ := by
  apply toStdD_injective m
  rw [toStdD_reflectionWord_pow (by omega), toStdD_neg,
    stdWeylWord_iterate_pred_apply (by omega) heven]

/-- For even `m`, every `±αᵢ` lies in the `w`-orbit of `{a, b, c}`. -/
theorem inWeylWordOrbit_even (i : Fin m) (γ : Fin m → ℤ)
    (hγ : γ = Pi.single i 1 ∨ γ = -Pi.single i 1) :
    InWeylWordOrbit (cartanD m) (coxeterList m) {rootA m hm, rootB m hm, rootC m hm} γ := by
  by_cases h3 : i.val + 3 ≤ m
  · obtain ⟨k, hk⟩ := exists_reflectionWord_pow_rootC_eq hm i h3 γ hγ
    exact ⟨k, _, by simp, hk⟩
  · by_cases h2 : i.val + 2 = m
    · have hlt : m - 2 < m := by omega
      obtain rfl : i = ⟨m - 2, hlt⟩ := Fin.ext (by simp only; omega)
      rcases hγ with rfl | rfl
      · exact ⟨0, rootB m hm, by simp, by simp [rootB]⟩
      · exact ⟨m - 1, rootB m hm, by simp, reflectionWord_pow_pred_apply_eq_neg_even hm heven _⟩
    · have hlt : m - 1 < m := by omega
      obtain rfl : i = ⟨m - 1, hlt⟩ := Fin.ext (by simp only; omega)
      rcases hγ with rfl | rfl
      · exact ⟨0, rootA m hm, by simp, by simp [rootA]⟩
      · exact ⟨m - 1, rootA m hm, by simp, reflectionWord_pow_pred_apply_eq_neg_even hm heven _⟩

end Even

end TypeD

end CFSGCorollary
