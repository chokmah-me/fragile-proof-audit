module

public import CFSGCorollary.LieType.Chevalley.Roots.Basic
public import CFSG.LieType.Universal.SymplecticRoots
import CFSG.LieType.Universal.SymplecticExtras.Matrices

/-!
# Root computations for type `C_m` over fields with at least four elements

Let `A = cartanC m` with `m ≥ 2` (simple roots `αᵢ = eᵢ − eᵢ₊₁` and `α_{m-1} = 2 e_{m-1}` in
standard coordinates), `L = [0, 1, …, m-1]`, `w = reflectionWord A L`
(so `w⁻¹ = reflectionWord A L.reverse`),
`r = −(2α₀ + ⋯ + 2α_{m-2} + α_{m-1})`, `s = −α₀`, `μ = (0, 1, …, 1, 2)` (`μ = (0, 1)` if `m = 2`)
and `e γ = cocharacterPairing A μ γ`. We prove the root-theoretic input of Steinberg's argument
for `C_m(K)`, `|K| ≥ 4`: `r` and `s` are roots with no positive combination in `Φ`, the values of
`e` on `r`, `s`, `w r`, `w⁻¹ r` and `w⁻¹ s`, and that every `±αᵢ` is in the `w`-orbit of `r` or
`s`. All computations are done in the standard coordinates `toStd m`, in which `w` is a
negacyclic shift.

The first section contains lemmas on `toStd` and on `reflectionWord (cartanC m)` that are also
used for `|K| = 3` and `|K| = 2`.

## Main results

* `TypeCCardLarge.noPositiveCombination_rootR_rootS`: no `i • r + j • s` (`i, j ≥ 1`) is a root.
* `TypeCCardLarge.cocharacterPairing_rootR`, `TypeCCardLarge.cocharacterPairing_rootS`,
  `TypeCCardLarge.cocharacterPairing_reflectionWord_rootR`, …: the values of `e`.
* `TypeCCardLarge.inWeylWordOrbit_rootR_rootS`: every `±αᵢ` lies in the `w`-orbit of `{r, s}`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

section Symplectic

open CFSG.LieType.Universal.Symplectic CFSG.LieType.RootSystem
open SpExtras (toStd_add' toStd_zsmul' toStd_single_of_lt' toStd_single_of_not_lt')

variable {n : ℕ}

private def toStdLin (n : ℕ) : (Fin n → ℤ) →ₗ[ℤ] (Fin n → ℤ) where
  toFun := toStd n
  map_add' := toStd_add'
  map_smul' := toStd_zsmul'

/-- `toStd` commutes with subtraction. -/
theorem toStd_sub (v w : Fin n → ℤ) : toStd n (v - w) = toStd n v - toStd n w :=
  map_sub (toStdLin n) v w

/-- The coroot of a short simple root `αₖ` in standard coordinates. -/
theorem coroot_cartanC_of_lt {k : Fin n} (h : k.val + 1 < n) (v : Fin n → ℤ) :
    coroot (cartanC n) k v = toStd n v k - toStd n v ⟨k.val + 1, h⟩ := by
  have key : coroot (cartanC n) k =
      ((LinearMap.proj k : (Fin n → ℤ) →ₗ[ℤ] ℤ) - LinearMap.proj (⟨k.val + 1, h⟩ : Fin n)).comp
        (toStdLin n) := by
    ext l
    simp only [LinearMap.comp_apply, LinearMap.sub_apply, LinearMap.proj_apply,
      LinearMap.coe_single, coroot_single, toStdLin, LinearMap.coe_mk, AddHom.coe_mk, toStd,
      cartanC, Matrix.of_apply, Pi.single_apply, Fin.ext_iff]
    split_ifs <;> omega
  exact LinearMap.congr_fun key v

/-- The coroot of the long simple root `α_{m-1}` in standard coordinates. -/
theorem coroot_cartanC_of_not_lt {k : Fin n} (h : ¬k.val + 1 < n) (v : Fin n → ℤ) :
    coroot (cartanC n) k v = toStd n v k := by
  have key : coroot (cartanC n) k = (LinearMap.proj k).comp (toStdLin n) := by
    ext l
    simp only [LinearMap.comp_apply, LinearMap.proj_apply, LinearMap.coe_single, coroot_single,
      toStdLin, LinearMap.coe_mk, AddHom.coe_mk, toStd, cartanC, Matrix.of_apply,
      Pi.single_apply, Fin.ext_iff]
    split_ifs <;> omega
  exact LinearMap.congr_fun key v

/-- In standard coordinates, the reflection in a short simple root `αₖ` swaps `eₖ` and `eₖ₊₁`. -/
theorem toStd_reflection_of_lt {k : Fin n} (h : k.val + 1 < n) (v : Fin n → ℤ) :
    toStd n (reflection (cartanC n) k v) = toStd n v ∘ Equiv.swap k ⟨k.val + 1, h⟩ := by
  rw [reflection_apply_coroot, toStd_sub, toStd_zsmul', coroot_cartanC_of_lt h,
    toStd_single_of_lt' h]
  have hne : (⟨k.val + 1, h⟩ : Fin n) ≠ k := Fin.ne_of_val_ne (by simp)
  funext a
  by_cases ha : a = k
  · subst ha
    simp [Ne.symm hne]
  by_cases ha' : a = ⟨k.val + 1, h⟩
  · subst ha'
    simp [hne]
  · simp [ha, ha', Equiv.swap_apply_of_ne_of_ne ha ha']

/-- In standard coordinates, the reflection in the long simple root negates `eₖ`. -/
theorem toStd_reflection_of_not_lt {k : Fin n} (h : ¬k.val + 1 < n) (v : Fin n → ℤ) :
    toStd n (reflection (cartanC n) k v) = fun a ↦ (if a = k then -1 else 1) * toStd n v a := by
  rw [reflection_apply_coroot, toStd_sub, toStd_zsmul', coroot_cartanC_of_not_lt h,
    toStd_single_of_not_lt' h]
  funext a
  by_cases ha : a = k
  · subst ha
    simp only [Pi.sub_apply, Pi.smul_apply, Pi.single_eq_same, smul_eq_mul, ite_true]
    ring
  · simp [ha]

end Symplectic

open CFSG.LieType.Universal.Symplectic

namespace TypeCCardLarge

open CFSG.LieType.RootSystem (coroot reflection)
open SpExtras (toStd_inj toStd_neg' toStd_zsmul' toStd_single_of_lt' toStd_single_of_not_lt')

/-- The root system `Φ` of type `C_m` (no doubled indices). -/
abbrev roots (m : ℕ) : Set (Fin m → ℤ) :=
  CFSG.LieType.RootSystem.roots (isFiniteType_cartanC m) ∅

/-- `r = −(2α₀ + ⋯ + 2α_{m-2} + α_{m-1})`. -/
def rootR (m : ℕ) : Fin m → ℤ :=
  -∑ i : Fin m, (if i.val + 1 < m then (2 : ℤ) else 1) • (Pi.single i 1 : Fin m → ℤ)

/-- `s = −α₀`. -/
def rootS (m : ℕ) (hm : 0 < m) : Fin m → ℤ := -Pi.single ⟨0, hm⟩ 1

/-- `μ = (0, 1, …, 1, 2)` for `m ≥ 3` and `μ = (0, 1)` for `m = 2`. -/
def cocharacter (m : ℕ) : Fin m → ℤ :=
  fun i ↦ if i.val = 0 then 0 else if i.val + 1 = m ∧ 3 ≤ m then 2 else 1

variable {m : ℕ}

private def singleNat (m n : ℕ) (x : ℤ) : Fin m → ℤ := fun b ↦ if b.val = n then x else 0

private theorem single_eq_singleNat (i : Fin m) (x : ℤ) :
    (Pi.single i x : Fin m → ℤ) = singleNat m i.val x := by
  funext b
  simp [singleNat, Pi.single_apply, Fin.ext_iff]

private theorem toStd_single_eq_singleNat_of_lt {i : Fin m} (h : i.val + 1 < m) :
    toStd m (Pi.single i 1) = singleNat m i.val 1 - singleNat m (i.val + 1) 1 := by
  rw [toStd_single_of_lt' h, single_eq_singleNat, single_eq_singleNat]

private theorem toStd_single_eq_singleNat_of_not_lt {i : Fin m} (h : ¬ i.val + 1 < m) :
    toStd m (Pi.single i 1) = singleNat m i.val 2 := by
  rw [toStd_single_of_not_lt' h]
  funext b
  simp [singleNat, Pi.single_apply, Fin.ext_iff]

private theorem rootR_apply (a : Fin m) :
    rootR m a = -(if a.val + 1 < m then 2 else 1) := by
  rw [rootR, Pi.neg_apply, Finset.sum_apply, Finset.sum_eq_single a]
  · simp
  · intro b _ hb
    simp [hb.symm]
  · simp

private theorem toStd_rootR (hm : 2 ≤ m) : toStd m (rootR m) = singleNat m 0 (-2) := by
  funext a
  simp only [toStd, rootR_apply, singleNat]
  split_ifs <;> omega

private theorem toStd_rootS (hm : 2 ≤ m) :
    toStd m (rootS m (by omega)) = singleNat m 1 1 - singleNat m 0 1 := by
  have h : (⟨0, by omega⟩ : Fin m).val + 1 < m := by simp only; omega
  rw [rootS, toStd_neg', toStd_single_eq_singleNat_of_lt h]
  simp

/-- The action of `w` in standard coordinates: `eᵢ ↦ eᵢ₊₁` for `i < m - 1`, `e_{m-1} ↦ −e₀`. -/
private def stdWeylWord (m : ℕ) : Module.End ℤ (Fin m → ℤ) where
  toFun E a := if a.val = 0 then -E ⟨m - 1, by have := a.2; omega⟩
    else E ⟨a.val - 1, by have := a.2; omega⟩
  map_add' E F := by
    funext a
    simp only [Pi.add_apply]
    split_ifs <;> ring
  map_smul' c E := by
    funext a
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    split_ifs <;> ring

private theorem stdWeylWord_singleNat {n : ℕ} (hn : n < m) (x : ℤ) :
    stdWeylWord m (singleNat m n x) =
      if n + 1 < m then singleNat m (n + 1) x else singleNat m 0 (-x) := by
  funext a
  by_cases h : n + 1 < m
  · rw [ite_eq_left h]
    simp only [stdWeylWord, LinearMap.coe_mk, AddHom.coe_mk, singleNat]
    split_ifs <;> omega
  · rw [ite_eq_right h]
    simp only [stdWeylWord, LinearMap.coe_mk, AddHom.coe_mk, singleNat]
    split_ifs <;> omega

private theorem stdWeylWord_pow_singleNat {a : ℕ} (x : ℤ) (k : ℕ) (h : a + k < m) :
    (stdWeylWord m ^ k) (singleNat m a x) = singleNat m (a + k) x := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ', Module.End.mul_apply, ih (by omega), stdWeylWord_singleNat (by omega),
      ite_eq_left (by omega)]
    rfl

private theorem stdWeylWord_pow_m_singleNat {a : ℕ} (ha : a < m) (x : ℤ) :
    (stdWeylWord m ^ m) (singleNat m a x) = singleNat m a (-x) := by
  have e : stdWeylWord m ^ m =
      stdWeylWord m ^ a * (stdWeylWord m * stdWeylWord m ^ (m - a - 1)) := by
    rw [← pow_succ', ← pow_add]
    congr 1
    omega
  rw [e, Module.End.mul_apply, Module.End.mul_apply, stdWeylWord_pow_singleNat x _ (by omega),
    stdWeylWord_singleNat (by omega), ite_eq_right (by omega),
    stdWeylWord_pow_singleNat _ _ (by omega)]
  simp

private theorem stdWeylWord_pow_m : stdWeylWord m ^ m = -1 := by
  apply LinearMap.pi_ext
  intro i x
  rw [single_eq_singleNat, LinearMap.neg_apply, Module.End.one_apply,
    stdWeylWord_pow_m_singleNat i.2]
  funext b
  simp only [singleNat, Pi.neg_apply]
  split_ifs <;> simp

private def prefixProdIndex (m k : ℕ) (a : Fin m) : ℕ :=
  if a.val = 0 then k else if a.val ≤ k then a.val - 1 else a.val

private noncomputable def prefixProd (m k : ℕ) : Module.End ℤ (Fin m → ℤ) :=
  (((List.finRange m).take k).map (reflection (cartanC m))).prod

private theorem prefixProd_succ {k : ℕ} (hk : k < m) :
    prefixProd m (k + 1) = prefixProd m k * reflection (cartanC m) ⟨k, hk⟩ := by
  unfold prefixProd
  rw [List.take_add_one]
  simp [hk]

private theorem toStd_prefixProd (k : ℕ) (hk : k < m) (γ : Fin m → ℤ) (a j : Fin m)
    (hj : j.val = prefixProdIndex m k a) :
    toStd m (prefixProd m k γ) a = toStd m γ j := by
  induction k generalizing γ j with
  | zero =>
    have : j = a := by
      apply Fin.ext
      simp only [prefixProdIndex] at hj
      split_ifs at hj <;> omega
    subst this
    simp [prefixProd]
  | succ k ih =>
    have hk' : k < m := by omega
    rw [prefixProd_succ hk', Module.End.mul_apply]
    have hj0 : prefixProdIndex m k a < m := by
      have := a.2
      unfold prefixProdIndex
      split_ifs <;> omega
    rw [ih hk' _ ⟨prefixProdIndex m k a, hj0⟩ rfl,
      toStd_reflection_of_lt (k := ⟨k, hk'⟩) hk]
    simp only [Function.comp_apply]
    have hsw : Equiv.swap (⟨k, hk'⟩ : Fin m) ⟨k + 1, hk⟩ ⟨prefixProdIndex m k a, hj0⟩ = j := by
      have hc : prefixProdIndex m k a =
          if a.val = 0 then k else if a.val ≤ k then a.val - 1 else a.val :=
        rfl
      have hj' : j.val =
          if a.val = 0 then k + 1 else if a.val ≤ k + 1 then a.val - 1 else a.val :=
        hj
      generalize prefixProdIndex m k a = c at hj0 hc ⊢
      apply Fin.ext
      simp only [Equiv.swap_apply_def, Fin.ext_iff]
      split_ifs at hc hj' ⊢ <;>
        first | omega | (rw [Fin.val_mk]; omega)
    rw [hsw]

private theorem toStd_reflectionWord (hm : 1 ≤ m) (γ : Fin m → ℤ) :
    toStd m (reflectionWord (cartanC m) (List.finRange m) γ) = stdWeylWord m (toStd m γ) := by
  have e : reflectionWord (cartanC m) (List.finRange m) = prefixProd m m := by
    unfold reflectionWord prefixProd
    rw [List.take_of_length_le (by simp)]
  have hlast : ¬ (m - 1 + 1 < m) := by omega
  have e2 : prefixProd m m =
      prefixProd m (m - 1) * reflection (cartanC m) ⟨m - 1, by omega⟩ := by
    have := prefixProd_succ (m := m) (k := m - 1) (by omega)
    rwa [show m - 1 + 1 = m by omega] at this
  rw [e, e2, Module.End.mul_apply]
  funext a
  have hj0 : prefixProdIndex m (m - 1) a < m := by
    have := a.2
    unfold prefixProdIndex
    split_ifs <;> omega
  rw [toStd_prefixProd (m - 1) (by omega) _ a ⟨prefixProdIndex m (m - 1) a, hj0⟩ rfl,
    toStd_reflection_of_not_lt (k := ⟨m - 1, by omega⟩) hlast]
  simp only [stdWeylWord, LinearMap.coe_mk, AddHom.coe_mk, prefixProdIndex]
  by_cases h0 : a.val = 0
  · simp [h0]
  · have := a.2
    simp only [h0, ite_false, show a.val ≤ m - 1 by omega, ite_true]
    have hne : (⟨a.val - 1, by omega⟩ : Fin m) ≠ ⟨m - 1, by omega⟩ := by
      intro h
      have := congrArg Fin.val h
      simp only at this
      omega
    simp [hne]

private theorem toStd_reflectionWord_pow (hm : 1 ≤ m) (k : ℕ) (γ : Fin m → ℤ) :
    toStd m ((reflectionWord (cartanC m) (List.finRange m) ^ k) γ) =
      (stdWeylWord m ^ k) (toStd m γ) := by
  induction k generalizing γ with
  | zero => simp
  | succ k ih =>
    rw [pow_succ, Module.End.mul_apply, ih, toStd_reflectionWord hm, pow_succ, Module.End.mul_apply]

private def cocharacterNat (m k : ℕ) : ℤ :=
  if k = 0 then 0 else if k + 1 = m ∧ 3 ≤ m then 2 else 1

private theorem coroot_cartanC_eq (a : Fin m) (v : Fin m → ℤ) :
    coroot (cartanC m) a v =
      extendByZero (toStd m v) a.val - extendByZero (toStd m v) (a.val + 1) := by
  by_cases h : a.val + 1 < m
  · rw [coroot_cartanC_of_lt h]
    simp [extendByZero, h, a.2]
  · rw [coroot_cartanC_of_not_lt h]
    simp [extendByZero, h, a.2]

private theorem cocharacterPairing_eq (hm : 2 ≤ m) (γ : Fin m → ℤ) :
    cocharacterPairing (cartanC m) (cocharacter m) γ =
      extendByZero (toStd m γ) 1 +
        if 3 ≤ m then extendByZero (toStd m γ) (m - 1) else 0 := by
  have h1 : cocharacterPairing (cartanC m) (cocharacter m) γ =
      ∑ i : Fin m, cocharacterNat m i.val *
        (extendByZero (toStd m γ) i.val - extendByZero (toStd m γ) (i.val + 1)) := by
    unfold cocharacterPairing
    refine Finset.sum_congr rfl fun i _ ↦ ?_
    rw [← CFSG.LieType.RootSystem.coroot_apply, coroot_cartanC_eq]
    rfl
  rw [h1, Fin.sum_univ_eq_sum_range (fun k ↦ cocharacterNat m k *
    (extendByZero (toStd m γ) k - extendByZero (toStd m γ) (k + 1))) m]
  generalize toStd m γ = E
  obtain ⟨n, rfl⟩ : ∃ n, m = n + 2 := ⟨m - 2, by omega⟩
  have hE : extendByZero E (n + 2) = 0 := by simp [extendByZero]
  rw [Finset.sum_range_succ']
  have hsplit : ∀ k ∈ Finset.range (n + 1), cocharacterNat (n + 2) (k + 1) *
      (extendByZero E (k + 1) - extendByZero E (k + 1 + 1)) =
      (extendByZero E (k + 1) - extendByZero E (k + 1 + 1)) +
      (if k = n ∧ 3 ≤ n + 2 then
        (extendByZero E (k + 1) - extendByZero E (k + 1 + 1)) else 0) := by
    intro k hk
    unfold cocharacterNat
    split_ifs <;> first | (exfalso; omega) | ring
  rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib,
    Finset.sum_range_sub' (fun k ↦ extendByZero E (k + 1)) (n + 1)]
  simp only [cocharacterNat]
  by_cases h3 : 3 ≤ n + 2
  · simp [h3, Finset.sum_ite_eq', hE]
  · simp [h3, hE]

private theorem extendByZero_singleNat {a : ℕ} (x : ℤ) {n : ℕ} (hn : n < m) :
    extendByZero (singleNat m a x) n = if n = a then x else 0 := by
  simp [extendByZero, singleNat, hn]

private theorem mem_roots_iff (γ : Fin m → ℤ) :
    γ ∈ roots m ↔ ∃ r, stdVec r = toStd m γ :=
  Set.ext_iff.mp (roots_eq m) γ

private theorem stdVec_bound (r : TauCeti.GLSymplecticFin.RootSubgroupIndex m) (a : Fin m) :
    -2 ≤ stdVec r a ∧ stdVec r a ≤ 2 := by
  cases r <;>
    simp only [stdVec, two_nsmul, Pi.add_apply, Pi.sub_apply, Pi.neg_apply, Pi.single_apply] <;>
    split_ifs <;> omega

private theorem rootR_apply_zero (hm : 2 ≤ m) : rootR m ⟨0, by omega⟩ = -2 := by
  rw [rootR_apply, ite_eq_left (by simp only; omega)]

private theorem rootS_apply_zero (hm : 2 ≤ m) : rootS m (by omega) ⟨0, by omega⟩ = -1 := by
  simp [rootS]

/-- `r` is a root. -/
theorem rootR_mem (hm : 2 ≤ m) : rootR m ∈ roots m := by
  rw [mem_roots_iff]
  refine ⟨.negativeLong ⟨0, by omega⟩, ?_⟩
  rw [toStd_rootR hm]
  funext b
  simp only [stdVec, singleNat, two_nsmul, Pi.neg_apply, Pi.add_apply, Pi.single_apply,
    Fin.ext_iff]
  split_ifs <;> omega

/-- `s` is a root. -/
theorem rootS_mem (hm : 2 ≤ m) : rootS m (by omega) ∈ roots m := by
  rw [mem_roots_iff]
  refine ⟨.difference ⟨1, by omega⟩ ⟨0, by omega⟩ (by simp [Fin.ext_iff]), ?_⟩
  rw [toStd_rootS hm]
  simp only [stdVec]
  rw [single_eq_singleNat, single_eq_singleNat]

/-- `r + s ≠ 0`. -/
theorem rootR_add_rootS_ne_zero (hm : 2 ≤ m) : rootR m + rootS m (by omega) ≠ 0 := by
  intro h
  have := congrFun h ⟨0, by omega⟩
  rw [Pi.add_apply, rootR_apply_zero hm, rootS_apply_zero hm] at this
  simp at this

/-- No `i • r + j • s` with `i, j ≥ 1` is a root. -/
theorem noPositiveCombination_rootR_rootS (hm : 2 ≤ m) :
    NoPositiveCombination (roots m) (rootR m) (rootS m (by omega)) := by
  intro i j hi hj h
  rw [mem_roots_iff] at h
  obtain ⟨r, hr⟩ := h
  have h1 := stdVec_bound r ⟨0, by omega⟩
  have h2 := congrFun hr ⟨0, by omega⟩
  have h0 : ¬ ((⟨0, by omega⟩ : Fin m).val + 1 = m) := by simp only; omega
  simp only [toStd, Pi.add_apply, Pi.smul_apply, rootR_apply_zero hm, rootS_apply_zero hm, h0,
    ite_false] at h2
  simp at h2
  omega

/-- `e r = 0`. -/
theorem cocharacterPairing_rootR (hm : 2 ≤ m) :
    cocharacterPairing (cartanC m) (cocharacter m) (rootR m) = 0 := by
  rw [cocharacterPairing_eq hm, toStd_rootR hm]
  have h1 : 1 < m := by omega
  have h2 : m - 1 < m := by omega
  by_cases h3 : 3 ≤ m
  · rw [ite_eq_left h3]
    simp only [extendByZero_singleNat _ h1, extendByZero_singleNat _ h2]
    split_ifs <;> first | omega | contradiction
  · rw [ite_eq_right h3]
    simp only [extendByZero_singleNat _ h1]
    split_ifs <;> first | omega | contradiction

/-- `e s = 1`. -/
theorem cocharacterPairing_rootS (hm : 2 ≤ m) :
    cocharacterPairing (cartanC m) (cocharacter m) (rootS m (by omega)) = 1 := by
  rw [cocharacterPairing_eq hm, toStd_rootS hm]
  have h1 : 1 < m := by omega
  have h2 : m - 1 < m := by omega
  by_cases h3 : 3 ≤ m
  · rw [ite_eq_left h3]
    simp only [extendByZero_sub, extendByZero_singleNat _ h1, extendByZero_singleNat _ h2]
    split_ifs <;> first | omega | contradiction
  · rw [ite_eq_right h3]
    simp only [extendByZero_sub, extendByZero_singleNat _ h1]
    split_ifs <;> first | omega | contradiction

private theorem toStd_single_last (hm : 1 ≤ m) :
    toStd m (Pi.single (⟨m - 1, by omega⟩ : Fin m) 1) = singleNat m (m - 1) 2 :=
  toStd_single_eq_singleNat_of_not_lt (by simp only; omega)

private theorem reflectionWord_single_last (hm : 2 ≤ m) :
    reflectionWord (cartanC m) (List.finRange m) (Pi.single (⟨m - 1, by omega⟩ : Fin m) 1) =
      rootR m := by
  apply toStd_inj
  rw [toStd_reflectionWord (by omega), toStd_single_last (by omega), toStd_rootR hm,
    stdWeylWord_singleNat (by omega), ite_eq_right (by omega)]

private theorem toStd_ones (hm : 2 ≤ m) :
    toStd m (fun _ ↦ 1) = singleNat m 0 1 + singleNat m (m - 1) 1 := by
  funext a
  simp only [toStd, singleNat, Pi.add_apply]
  split_ifs <;> omega

private theorem reflectionWord_ones (hm : 2 ≤ m) :
    reflectionWord (cartanC m) (List.finRange m) (fun _ ↦ 1) = rootS m (by omega) := by
  apply toStd_inj
  rw [toStd_reflectionWord (by omega), toStd_ones hm, toStd_rootS hm, map_add,
    stdWeylWord_singleNat (by omega), stdWeylWord_singleNat (by omega), ite_eq_left (by omega),
    ite_eq_right (by omega)]
  funext a
  simp only [singleNat, Pi.add_apply, Pi.sub_apply]
  split_ifs <;> omega

/-- `e (w⁻¹ r) = 2`. -/
theorem cocharacterPairing_reflectionWord_reverse_rootR (hm : 2 ≤ m) :
    cocharacterPairing (cartanC m) (cocharacter m)
      (reflectionWord (cartanC m) (List.finRange m).reverse (rootR m)) = 2 := by
  rw [reflectionWord_reverse_apply_of_eq (isFiniteType_cartanC m).apply_self _
    (reflectionWord_single_last hm), cocharacterPairing_eq hm,
    toStd_single_last (by omega)]
  have h1 : 1 < m := by omega
  have h2 : m - 1 < m := by omega
  by_cases h3 : 3 ≤ m
  · rw [ite_eq_left h3]
    simp only [extendByZero_singleNat _ h1, extendByZero_singleNat _ h2]
    split_ifs <;> omega
  · rw [ite_eq_right h3]
    simp only [extendByZero_singleNat _ h1]
    split_ifs <;> omega

/-- `e (w⁻¹ s) = 1`. -/
theorem cocharacterPairing_reflectionWord_reverse_rootS (hm : 2 ≤ m) :
    cocharacterPairing (cartanC m) (cocharacter m)
      (reflectionWord (cartanC m) (List.finRange m).reverse (rootS m (by omega))) = 1 := by
  rw [reflectionWord_reverse_apply_of_eq (isFiniteType_cartanC m).apply_self _
    (reflectionWord_ones hm), cocharacterPairing_eq hm, toStd_ones hm]
  have h1 : 1 < m := by omega
  have h2 : m - 1 < m := by omega
  by_cases h3 : 3 ≤ m
  · rw [ite_eq_left h3]
    simp only [extendByZero_add, extendByZero_singleNat _ h1, extendByZero_singleNat _ h2]
    split_ifs <;> first | omega | contradiction
  · rw [ite_eq_right h3]
    simp only [extendByZero_add, extendByZero_singleNat _ h1]
    split_ifs <;> first | omega | contradiction

/-- `e (w r) = −2`. -/
theorem cocharacterPairing_reflectionWord_rootR (hm : 2 ≤ m) :
    cocharacterPairing (cartanC m) (cocharacter m)
      (reflectionWord (cartanC m) (List.finRange m) (rootR m)) = -2 := by
  rw [cocharacterPairing_eq hm, toStd_reflectionWord (by omega), toStd_rootR hm,
    stdWeylWord_singleNat (by omega), ite_eq_left (by omega)]
  have h1 : 1 < m := by omega
  have h2 : m - 1 < m := by omega
  by_cases h3 : 3 ≤ m
  · rw [ite_eq_left h3]
    simp only [extendByZero_singleNat _ h1, extendByZero_singleNat _ h2]
    split_ifs <;> omega
  · rw [ite_eq_right h3]
    simp only [extendByZero_singleNat _ h1]
    split_ifs <;> omega

/-- `wⁱ s = −αᵢ` for `0 ≤ i ≤ m-2`. -/
theorem reflectionWord_pow_rootS (hm : 2 ≤ m) (i : Fin m) (hi : i.val + 2 ≤ m) :
    (reflectionWord (cartanC m) (List.finRange m) ^ i.val) (rootS m (by omega)) =
      -Pi.single i 1 := by
  apply toStd_inj
  rw [toStd_reflectionWord_pow (by omega), toStd_rootS hm, map_sub,
    stdWeylWord_pow_singleNat _ _ (by omega), stdWeylWord_pow_singleNat _ _ (by omega),
    toStd_neg', toStd_single_eq_singleNat_of_lt (by omega)]
  funext a
  simp only [singleNat, Pi.sub_apply, Pi.neg_apply]
  split_ifs <;> omega

/-- `w^{m+i} s = αᵢ` for `0 ≤ i ≤ m-2`. -/
theorem reflectionWord_pow_add_rootS (hm : 2 ≤ m) (i : Fin m) (hi : i.val + 2 ≤ m) :
    (reflectionWord (cartanC m) (List.finRange m) ^ (m + i.val)) (rootS m (by omega)) =
      Pi.single i 1 := by
  apply toStd_inj
  rw [toStd_reflectionWord_pow (by omega), pow_add, Module.End.mul_apply, stdWeylWord_pow_m,
    LinearMap.neg_apply, Module.End.one_apply, toStd_rootS hm, map_sub,
    stdWeylWord_pow_singleNat _ _ (by omega), stdWeylWord_pow_singleNat _ _ (by omega),
    toStd_single_eq_singleNat_of_lt (by omega)]
  funext a
  simp only [singleNat, Pi.sub_apply, Pi.neg_apply]
  split_ifs <;> omega

/-- `w^{m-1} r = −α_{m-1}`. -/
theorem reflectionWord_pow_pred_rootR (hm : 2 ≤ m) :
    (reflectionWord (cartanC m) (List.finRange m) ^ (m - 1)) (rootR m) =
      -Pi.single (⟨m - 1, by omega⟩ : Fin m) 1 := by
  apply toStd_inj
  rw [toStd_reflectionWord_pow (by omega), toStd_rootR hm, stdWeylWord_pow_singleNat _ _ (by omega),
    toStd_neg', toStd_single_last (by omega)]
  funext a
  simp only [singleNat, Pi.neg_apply]
  split_ifs <;> omega

/-- `w^{2m-1} r = α_{m-1}`. -/
theorem reflectionWord_pow_two_mul_pred_rootR (hm : 2 ≤ m) :
    (reflectionWord (cartanC m) (List.finRange m) ^ (2 * m - 1)) (rootR m) =
      Pi.single (⟨m - 1, by omega⟩ : Fin m) 1 := by
  apply toStd_inj
  rw [show 2 * m - 1 = m + (m - 1) by omega, toStd_reflectionWord_pow (by omega), pow_add,
    Module.End.mul_apply, stdWeylWord_pow_m, LinearMap.neg_apply, Module.End.one_apply,
    toStd_rootR hm, stdWeylWord_pow_singleNat _ _ (by omega), toStd_single_last (by omega)]
  funext a
  simp only [singleNat, Pi.neg_apply]
  split_ifs <;> omega

/-- Every `±αᵢ` lies in the `w`-orbit of `r` or `s`. -/
theorem inWeylWordOrbit_rootR_rootS (hm : 2 ≤ m) (i : Fin m) (γ : Fin m → ℤ)
    (hγ : γ = Pi.single i 1 ∨ γ = -Pi.single i 1) :
    InWeylWordOrbit (cartanC m) (List.finRange m) {rootR m, rootS m (by omega)} γ := by
  by_cases hi : i.val + 2 ≤ m
  · rcases hγ with rfl | rfl
    · exact ⟨m + i.val, rootS m (by omega), by simp, reflectionWord_pow_add_rootS hm i hi⟩
    · exact ⟨i.val, rootS m (by omega), by simp, reflectionWord_pow_rootS hm i hi⟩
  · have hi' : i = ⟨m - 1, by omega⟩ := Fin.ext (by simp only; omega)
    rcases hi' ▸ hγ with rfl | rfl
    · exact ⟨2 * m - 1, rootR m, by simp, reflectionWord_pow_two_mul_pred_rootR hm⟩
    · exact ⟨m - 1, rootR m, by simp, reflectionWord_pow_pred_rootR hm⟩

end TypeCCardLarge

end CFSGCorollary
