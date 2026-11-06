module

public import CFSGCorollary.TwoGenerated.Basic
public import CFSGCorollary.LieType.Chevalley.Roots.TypeA
import CFSGCorollary.LieType.Steinberg.ClosurePair
public import CFSGCorollary.LieType.Steinberg.Diagonal
import CFSGCorollary.LieType.Steinberg.GeneratingScalar

/-!
# Two-generation for type `A_m`

Let `G` carry a Steinberg system `x` of type `A_m = CartanMatrix.A m` over a finite field `K`
with unit single commutators, and let `μ = (1, 0, …, 0)`, `L = [0, 1, …, m-1]`. Following
Steinberg 1962 §3.11:

* if `|K| ≥ 4` and `k` generates `Kˣ`, then `G = ⟨h_μ(k), x α₀ 1 · ω(L)⟩`;
* if `|K| ≤ 3`, then `G = ⟨x α₀ 1, ω(L)⟩`.

In both cases a subgroup containing `ω(L)` and the root group `X_{α₀}` contains every `X_{±αᵢ}`
(the Coxeter element `w` moves `α₀` to each `αᵢ`, and `-α₀` is reached through the highest
root), hence is all of `G`.

## Main results

* `CFSGCorollary.TypeA.closure_diagonal_mul_eq_top`
* `CFSGCorollary.TypeA.closure_pair_eq_top_of_card_le_three`
* `CFSGCorollary.TypeA.twoGenerated`

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

namespace TypeA

/-- `μ = (1, 0, …, 0)`. -/
def cocharacter (m : ℕ) : Fin m → ℤ := fun i ↦ if i.val = 0 then 1 else 0

variable {m : ℕ} {K G : Type*} [Field K] [Finite K] [Group G]

theorem partialSumRoot_zero (hm : 1 ≤ m) :
    partialSumRoot m 0 = Pi.single ⟨0, hm⟩ 1 := by
  unfold partialSumRoot
  have : Finset.univ.filter (fun j : Fin m ↦ j.val ≤ 0) = {⟨0, hm⟩} := by
    ext j; simp [Fin.ext_iff]
  rw [this]
  simp

theorem partialSumRoot_pred_eq_highestRoot (hm : 1 ≤ m) :
    partialSumRoot m (m - 1) = highestRoot m := by
  unfold partialSumRoot highestRoot
  rw [Finset.filter_true_of_mem]
  intro j _
  have := j.2
  omega

/-- A subgroup containing `ω(L)` and `X_{α₀}` is everything. -/
theorem eq_top_of_weylWordElement_mem_of_rootElement_mem (hm : 1 ≤ m)
    (x : SteinbergSystem (CartanMatrix.A m) (TauCeti.isFiniteType_cartanMatrix_A m) K G)
    (hx : x.HasUnitCommutatorConstants) (F : Subgroup G)
    (hg : weylWordElement x.rootElement (List.finRange m) ∈ F)
    (h0 : ∀ u, x.rootElement (Pi.single ⟨0, hm⟩ 1) u ∈ F) : F = ⊤ := by
  have hα0 := single_mem_roots (TauCeti.isFiniteType_cartanMatrix_A m) ⟨0, hm⟩
  have hα : ∀ i : Fin m, ∀ u, x.rootElement (Pi.single i 1) u ∈ F := by
    intro i u
    have := (x.rootGroupIn_iterate F _ hg ⟨hα0, h0⟩ i.val).1.2 u
    rwa [← reflectionWord_pow_apply, reflectionWord_pow_single_zero hm i] at this
  have hβ : ∀ n, ∀ hn : n < m, ∀ u, x.rootElement (partialSumRoot m n) u ∈ F := by
    intro n
    induction n with
    | zero => intro hn u; rw [partialSumRoot_zero hm]; exact h0 u
    | succ n ih =>
      intro hn u
      have hn' : n < m := by omega
      have hu : OnlyPositiveCombination (roots m) (partialSumRoot m n) (Pi.single ⟨n + 1, hn⟩ 1)
          (partialSumRoot m (n + 1)) :=
        onlyPositiveCombination_partialSumRoot (m := m) ⟨n + 1, hn⟩ (by simp)
      have hrootβ : partialSumRoot m n ∈ roots m := by
        rcases Nat.eq_zero_or_pos n with rfl | hpos
        · rw [partialSumRoot_zero hm]; exact hα0
        · have : OnlyPositiveCombination (roots m) (partialSumRoot m (n - 1))
              (Pi.single ⟨n, hn'⟩ 1) (partialSumRoot m n) :=
            onlyPositiveCombination_partialSumRoot (m := m) ⟨n, hn'⟩ hpos
          exact this.2.1
      obtain ⟨c, hc⟩ := hx _ hrootβ _ (single_mem_roots _ ⟨n + 1, hn⟩)
        (by rw [← hu.1]; exact hu.2.1) (fun a b ha hb h ↦ hu.2.2 a b ha hb h)
      rw [← hu.1] at hc
      have h1 := hc (((c⁻¹ : Kˣ) : K) * u) 1
      have h2 : (c : K) * (((c⁻¹ : Kˣ) : K) * u) * 1 = u := by
        rw [mul_one, ← mul_assoc, ← Units.val_mul, mul_inv_cancel, Units.val_one, one_mul]
      rw [h2] at h1
      rw [← h1]
      have hb := ih hn' (((c⁻¹ : Kˣ) : K) * u)
      have ha := hα ⟨n + 1, hn⟩ 1
      exact F.mul_mem (F.mul_mem (F.mul_mem hb ha) (F.inv_mem hb)) (F.inv_mem ha)
  have hθ : ∀ u, x.rootElement (highestRoot m) u ∈ F := by
    intro u
    rw [← partialSumRoot_pred_eq_highestRoot hm]
    exact hβ (m - 1) (by omega) u
  have hθr : highestRoot m ∈ roots m := by
    rw [← partialSumRoot_pred_eq_highestRoot hm]
    rcases Nat.eq_zero_or_pos (m - 1) with h | hpos
    · rw [h, partialSumRoot_zero hm]; exact hα0
    · have := onlyPositiveCombination_partialSumRoot (m := m) ⟨m - 1, by omega⟩ hpos
      exact this.2.1
  have hneg0 := (x.rootGroupIn_weylWordRoot F _ hg ⟨hθr, hθ⟩).1
  rw [← reflectionWord_apply, reflectionWord_highestRoot hm] at hneg0
  have hneg : ∀ (i : Fin m) (u : K), x.rootElement (-Pi.single i 1) u ∈ F := by
    intro i u
    have := (x.rootGroupIn_iterate F _ hg hneg0 i.val).1.2 u
    rwa [← reflectionWord_pow_apply, reflectionWord_pow_neg_single_zero hm i] at this
  exact x.eq_top_of_simple_root_groups F hα hneg

theorem sum_cocharacter (hm : 1 ≤ m) (γ : Fin m → ℤ) :
    ∑ i, cocharacter m i * ∑ j, CartanMatrix.A m i j * γ j =
      ∑ j, CartanMatrix.A m ⟨0, hm⟩ j * γ j := by
  rw [Finset.sum_eq_single ⟨0, hm⟩]
  · simp [cocharacter]
  · intro b _ hb
    have : b.val ≠ 0 := fun h ↦ hb (Fin.ext h)
    simp [cocharacter, this]
  · simp

/-- `|K| ≥ 4`: `G = ⟨h_μ(k), x α₀ 1 · ω(L)⟩` for a generator `k` of `Kˣ`. -/
theorem closure_diagonal_mul_eq_top (hm : 1 ≤ m)
    (x : SteinbergSystem (CartanMatrix.A m) (TauCeti.isFiniteType_cartanMatrix_A m) K G)
    (hx : x.HasUnitCommutatorConstants) (hK : 4 ≤ Nat.card K) (k : Kˣ)
    (hk : Subgroup.zpowers k = ⊤) :
    Subgroup.closure {cocharacterElement x.rootElement (cocharacter m) k,
      x.rootElement (Pi.single ⟨0, hm⟩ 1) 1 * weylWordElement x.rootElement (List.finRange m)} =
      ⊤ := by
  have hα0 := single_mem_roots (TauCeti.isFiniteType_cartanMatrix_A m) ⟨0, hm⟩
  have hk1 := ne_one_of_zpowers_eq_top (by omega) hk
  have hk2 := sq_ne_one_of_zpowers_eq_top hK hk
  have hinv : weylWordRootInv (CartanMatrix.A m) (List.finRange m) (Pi.single ⟨0, hm⟩ 1) =
      -highestRoot m := by
    rw [← reflectionWord_reverse_apply]
    exact reflectionWord_reverse_single_zero hm
  have he : ∃ e : ℤ, (e = -1 ∨ e = -2) ∧
      ∑ j, CartanMatrix.A m ⟨0, hm⟩ j * (-highestRoot m) j = e := by
    rcases (by omega : m = 1 ∨ 2 ≤ m) with h | h
    · exact ⟨-2, Or.inr rfl, by subst h; exact sum_cartan_zero_mul_neg_highestRoot_one⟩
    · exact ⟨-1, Or.inl rfl, sum_cartan_zero_mul_neg_highestRoot_of_two_le h⟩
  obtain ⟨e, he1, he2⟩ := he
  have hl1 : k ^ e ≠ 1 := by
    rcases he1 with rfl | rfl
    · simpa using hk1
    · simpa [zpow_neg] using hk2
  obtain ⟨h0, hgF⟩ := x.rootGroupIn_closure_diagonal_mul (List.finRange m) (cocharacter m) k hα0
    (n := 2) (by rw [cocharacterPairing, sum_cocharacter hm, sum_cartan_zero_mul_single_zero hm])
    (by rw [cocharacterPairing, sum_cocharacter hm, hinv, he2])
    ⟨k, hk, Or.inr (by simp)⟩ (by simpa using hk2) hl1
  exact eq_top_of_weylWordElement_mem_of_rootElement_mem hm x hx _ hgF h0.2

/-- `|K| ≤ 3`: `G = ⟨x α₀ 1, ω(L)⟩`. -/
theorem closure_pair_eq_top_of_card_le_three (hm : 1 ≤ m)
    (x : SteinbergSystem (CartanMatrix.A m) (TauCeti.isFiniteType_cartanMatrix_A m) K G)
    (hx : x.HasUnitCommutatorConstants) (hK : Nat.card K ≤ 3) :
    Subgroup.closure {x.rootElement (Pi.single ⟨0, hm⟩ 1) 1,
      weylWordElement x.rootElement (List.finRange m)} = ⊤ := by
  have hα0 := single_mem_roots (TauCeti.isFiniteType_cartanMatrix_A m) ⟨0, hm⟩
  have hK2 : 2 ≤ Nat.card K := Finite.one_lt_card
  have hp : (Nat.card K).Prime := by
    interval_cases h : Nat.card K
    · exact Nat.prime_two
    · exact Nat.prime_three
  refine eq_top_of_weylWordElement_mem_of_rootElement_mem hm x hx _
    (Subgroup.subset_closure (by simp))
    fun u ↦ ?_
  exact range_subset_of_card_eq_prime_of_mem _ hp rfl (x.rootElement _)
    (x.rootElement_add _ hα0) _ (Subgroup.subset_closure (by simp)) ⟨u, rfl⟩

/-- Steinberg 1962 §3.11 for type `A`: `G` is two-generated. -/
theorem twoGenerated (hm : 1 ≤ m)
    (x : SteinbergSystem (CartanMatrix.A m) (TauCeti.isFiniteType_cartanMatrix_A m) K G)
    (hx : x.HasUnitCommutatorConstants) : TwoGenerated G := by
  by_cases hK : 4 ≤ Nat.card K
  · obtain ⟨k, hk⟩ := isCyclic_iff_exists_zpowers_eq_top.1 (inferInstance : IsCyclic Kˣ)
    exact ⟨_, _, closure_diagonal_mul_eq_top hm x hx hK k hk⟩
  · exact ⟨_, _, closure_pair_eq_top_of_card_le_three hm x hx (by omega)⟩

end TypeA

end CFSGCorollary
