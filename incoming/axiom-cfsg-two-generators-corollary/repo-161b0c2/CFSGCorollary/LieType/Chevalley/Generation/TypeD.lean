module

public import CFSGCorollary.TwoGenerated.Basic
public import CFSGCorollary.LieType.Chevalley.Roots.TypeD
public import CFSGCorollary.LieType.Steinberg.Diagonal
import CFSGCorollary.LieType.Steinberg.ClosurePair
import CFSGCorollary.LieType.Steinberg.GeneratingScalar
public import CFSGCorollary.LieType.Steinberg.SimpleRootGroups

@[expose] public section

/-!
# Generation of Chevalley groups of type `D_m`

Steinberg's two-generation theorem [Steinberg1962, §3.11, §3.13] for a Steinberg system `x` of
type `D_m` (`m ≥ 4`) with unit commutator constants. With `a, b, c` and the Coxeter word `L` as in
`CFSGCorollary.LieType.Chevalley.Roots.TypeD`, `ω(L) = weylWordElement x.rootElement L`,
`h_μ(k) = cocharacterElement x.rootElement μ k` and `k` a generator of `Kˣ`:

* `m` odd: `G = ⟨h_a(k), x_a(1) ω(L)⟩` if `|K| ≥ 4`, and `G = ⟨x_a(1), ω(L)⟩` if `|K| ≤ 3`;
* `m` even: `G = ⟨h_b(k), x_{-a}(1) x_c(1) ω(L)⟩` if `|K| ≥ 3`, and
  `G = ⟨x_a(1) x_c(1), ω(L)⟩` if `|K| = 2`.

The diagonal criteria [Steinberg1962, §3.10, §3.12] put a first root group into the subgroup
generated; conjugating by `ω(L)` and taking commutators then yields root groups whose `w`-orbits
contain every `±αᵢ`, so the subgroup is everything.

## Main results

* `TypeD.closure_diagonal_mul_eq_top_odd`, `TypeD.closure_pair_eq_top_odd`: the odd case.
* `TypeD.closure_diagonal_mul_eq_top_even`, `TypeD.closure_pair_eq_top_even`: the even case.
* `TypeD.twoGenerated`: a group with a Steinberg system of type `D_m` is two-generated.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

namespace CFSGCorollary

namespace TypeD

open CFSG.LieType.Universal.Spin

variable {m : ℕ} {K G : Type*} [Field K] [Finite K] [Group G]

omit [Finite K] in
theorem eq_one_of_ne_zero_of_card_eq_two (hK : Nat.card K = 2) {u : K} (hu : u ≠ 0) : u = 1 := by
  obtain ⟨y, hy, huniq⟩ := (Nat.card_eq_two_iff' (0 : K)).1 hK
  exact (huniq u hu).trans (huniq 1 one_ne_zero).symm

theorem rootGroupIn_of_card_eq_two (hK : Nat.card K = 2) {rank : ℕ}
    {cartan : Matrix (Fin rank) (Fin rank) ℤ} {finiteType : TauCeti.IsFiniteType cartan}
    (x : SteinbergSystem cartan finiteType K G) (F : Subgroup G) {γ : Fin rank → ℤ}
    (hγ : γ ∈ CFSG.LieType.RootSystem.roots finiteType ∅) (h : x.rootElement γ 1 ∈ F) :
    x.RootGroupIn F γ := by
  refine ⟨hγ, fun u ↦ ?_⟩
  by_cases hu0 : u = 0
  · rw [hu0, x.rootElement_zero hγ]; exact F.one_mem
  · rw [eq_one_of_ne_zero_of_card_eq_two hK hu0]; exact h

omit [Finite K] in
theorem one_add_one_eq_zero_of_card_eq_two (hK : Nat.card K = 2) : (1 : K) + 1 = 0 := by
  by_contra h
  have h1 : (1 : K) + 1 = 1 := eq_one_of_ne_zero_of_card_eq_two hK h
  simp at h1

omit [Finite K] in
theorem units_eq_one_of_card_eq_two (hK : Nat.card K = 2) (κ : Kˣ) : (κ : K) = 1 :=
  eq_one_of_ne_zero_of_card_eq_two hK κ.ne_zero

/-! ### Odd `m` -/

section Odd

variable (hm : 4 ≤ m) (hodd : m % 2 = 1)
include hm hodd

theorem eq_top_of_rootGroupIn_rootA_odd
    (x : SteinbergSystem (cartanD m) (isFiniteType_cartanD m) K G)
    (hx : x.HasUnitCommutatorConstants) (F : Subgroup G)
    (hg : weylWordElement x.rootElement (coxeterList m) ∈ F) (ha : x.RootGroupIn F (rootA m hm)) :
    F = ⊤ := by
  have hbc : x.RootGroupIn F (rootB m hm + rootC m hm) := by
    have := (x.rootGroupIn_weylWordRoot F (coxeterList m) hg ha).1
    rwa [← reflectionWord_apply, reflectionWord_rootA_odd hm hodd] at this
  have hnb : x.RootGroupIn F (-rootB m hm) := by
    have := (x.rootGroupIn_iterate F (coxeterList m) hg ha (m - 1)).1
    rwa [← reflectionWord_pow_apply, reflectionWord_pow_pred_rootA_odd hm hodd] at this
  have hnac : x.RootGroupIn F (-rootA m hm - rootC m hm) := by
    have := (x.rootGroupIn_weylWordRoot F (coxeterList m) hg hnb).1
    rwa [← reflectionWord_apply, reflectionWord_neg_rootB_odd hm hodd] at this
  have hc : x.RootGroupIn F (rootC m hm) :=
    x.rootGroupIn_of_onlyPositiveCombination hx F hbc hnb
      (onlyPositiveCombination_rootC_odd hm hodd)
  have hna : x.RootGroupIn F (-rootA m hm) :=
    x.rootGroupIn_of_onlyPositiveCombination hx F hc hnac
      (onlyPositiveCombination_neg_rootA_odd hm hodd)
  refine x.eq_top_of_rootGroupIn F (coxeterList m) hg {rootA m hm, -rootA m hm, rootC m hm} ?_ ?_
  · rintro ρ (rfl | rfl | rfl) <;> assumption
  · exact inWeylWordOrbit_odd hm hodd

end Odd

/-- Odd `m`, `|K| ≤ 3`: `G = ⟨x_a(1), ω(L)⟩`. -/
theorem closure_pair_eq_top_odd (hm : 4 ≤ m) (hodd : m % 2 = 1)
    (x : SteinbergSystem (cartanD m) (isFiniteType_cartanD m) K G)
    (hx : x.HasUnitCommutatorConstants) (hK : Nat.card K ≤ 3) :
    Subgroup.closure {x.rootElement (rootA m hm) 1,
      weylWordElement x.rootElement (coxeterList m)} = ⊤ := by
  have ha : rootA m hm ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanD m) ∅ :=
    single_mem_roots _ _
  have h2 : 2 ≤ Nat.card K := Finite.one_lt_card
  have hp : (Nat.card K).Prime := by
    rcases (by omega : Nat.card K = 2 ∨ Nat.card K = 3) with h | h <;> rw [h]
    · exact Nat.prime_two
    · exact Nat.prime_three
  set F : Subgroup G := Subgroup.closure {x.rootElement (rootA m hm) 1,
      weylWordElement x.rootElement (coxeterList m)} with hF
  have h1 : x.rootElement (rootA m hm) 1 ∈ F := Subgroup.subset_closure (by simp)
  have hg : weylWordElement x.rootElement (coxeterList m) ∈ F := Subgroup.subset_closure (by simp)
  have hr := range_subset_of_card_eq_prime_of_mem (Nat.card K) hp rfl
    (x.rootElement (rootA m hm)) (x.rootElement_add _ ha) F h1
  exact eq_top_of_rootGroupIn_rootA_odd hm hodd x hx F hg ⟨ha, fun u ↦ hr ⟨u, rfl⟩⟩

/-- Odd `m`, `|K| ≥ 4`: `G = ⟨h_a(k), x_a(1) ω(L)⟩` for a generator `k` of `Kˣ`. -/
theorem closure_diagonal_mul_eq_top_odd (hm : 4 ≤ m) (hodd : m % 2 = 1)
    (x : SteinbergSystem (cartanD m) (isFiniteType_cartanD m) K G)
    (hx : x.HasUnitCommutatorConstants) (hK : 4 ≤ Nat.card K) (k : Kˣ)
    (hk : Subgroup.zpowers k = ⊤) :
    Subgroup.closure {cocharacterElement x.rootElement (rootA m hm) k,
      x.rootElement (rootA m hm) 1 * weylWordElement x.rootElement (coxeterList m)} = ⊤ := by
  have ha : rootA m hm ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanD m) ∅ :=
    single_mem_roots _ _
  have hn : cocharacterPairing (cartanD m) (rootA m hm) (rootA m hm) = 2 :=
    cocharacterPairing_rootA_odd hm hodd
  have hn' : cocharacterPairing (cartanD m) (rootA m hm)
      (weylWordRootInv (cartanD m) (coxeterList m) (rootA m hm)) = -1 := by
    rw [← reflectionWord_reverse_apply]
    exact cocharacterPairing_reflectionWord_reverse_rootA_odd hm hodd
  have hk3 : 3 ≤ Nat.card K := by omega
  have hk1 := ne_one_of_zpowers_eq_top hk3 hk
  obtain ⟨h1, h2⟩ := x.rootGroupIn_closure_diagonal_mul (coxeterList m) (rootA m hm) k ha hn hn'
    ⟨k, hk, Or.inr (by simp)⟩ (by simpa using sq_ne_one_of_zpowers_eq_top hK hk)
    (by simpa using hk1)
  exact eq_top_of_rootGroupIn_rootA_odd hm hodd x hx _ h2 h1

/-! ### Even `m` -/

section Even

variable (hm : 4 ≤ m) (heven : m % 2 = 0)
include hm heven

theorem eq_top_of_rootGroupIn_rootA_rootB_rootC_even
    (x : SteinbergSystem (cartanD m) (isFiniteType_cartanD m) K G) (F : Subgroup G)
    (hg : weylWordElement x.rootElement (coxeterList m) ∈ F) (ha : x.RootGroupIn F (rootA m hm))
    (hb : x.RootGroupIn F (rootB m hm)) (hc : x.RootGroupIn F (rootC m hm)) :
    F = ⊤ := by
  refine x.eq_top_of_rootGroupIn F (coxeterList m) hg {rootA m hm, rootB m hm, rootC m hm} ?_ ?_
  · rintro ρ (rfl | rfl | rfl) <;> assumption
  · exact inWeylWordOrbit_even hm heven

theorem eq_top_of_rootGroupIn_neg_rootA_even
    (x : SteinbergSystem (cartanD m) (isFiniteType_cartanD m) K G)
    (hx : x.HasUnitCommutatorConstants) (F : Subgroup G)
    (hg : weylWordElement x.rootElement (coxeterList m) ∈ F) (ha : x.RootGroupIn F (-rootA m hm))
    (hc : x.RootGroupIn F (rootC m hm)) : F = ⊤ := by
  have hnbc : x.RootGroupIn F (-rootB m hm - rootC m hm) := by
    have := (x.rootGroupIn_weylWordRoot F (coxeterList m) hg ha).1
    rwa [← reflectionWord_apply, reflectionWord_neg_rootA_even hm heven] at this
  have hnb : x.RootGroupIn F (-rootB m hm) :=
    x.rootGroupIn_of_onlyPositiveCombination hx F hnbc hc
      (onlyPositiveCombination_neg_rootB_even hm heven)
  have hA : x.RootGroupIn F (rootA m hm) := by
    have := (x.rootGroupIn_iterate F (coxeterList m) hg ha (m - 1)).1
    rwa [← reflectionWord_pow_apply, reflectionWord_pow_pred_apply_eq_neg_even hm heven,
      neg_neg] at this
  have hB : x.RootGroupIn F (rootB m hm) := by
    have := (x.rootGroupIn_iterate F (coxeterList m) hg hnb (m - 1)).1
    rwa [← reflectionWord_pow_apply, reflectionWord_pow_pred_apply_eq_neg_even hm heven,
      neg_neg] at this
  exact eq_top_of_rootGroupIn_rootA_rootB_rootC_even hm heven x F hg hA hB hc

end Even

/-- Even `m`, `|K| ≥ 3`: `G = ⟨h_b(k), x_{-a}(1) x_c(1) ω(L)⟩` for a generator `k` of `Kˣ`. -/
theorem closure_diagonal_mul_eq_top_even (hm : 4 ≤ m) (heven : m % 2 = 0)
    (x : SteinbergSystem (cartanD m) (isFiniteType_cartanD m) K G)
    (hx : x.HasUnitCommutatorConstants) (hK : 3 ≤ Nat.card K) (k : Kˣ)
    (hk : Subgroup.zpowers k = ⊤) :
    Subgroup.closure {cocharacterElement x.rootElement (rootB m hm) k,
      x.rootElement (-rootA m hm) 1 * x.rootElement (rootC m hm) 1 *
        weylWordElement x.rootElement (coxeterList m)} = ⊤ := by
  have hr := neg_rootA_mem_even hm heven
  have hs := rootC_mem_even hm heven
  have hrs : ∀ c c' : K, Commute (x.rootElement (-rootA m hm) c) (x.rootElement (rootC m hm) c') :=
    fun c c' ↦ x.rootElement_commute _ hr _ hs (neg_rootA_add_rootC_ne_zero_even hm heven)
      (noPositiveCombination_neg_rootA_rootC_even hm heven) c c'
  have hk1 := ne_one_of_zpowers_eq_top hK hk
  have hk1' : k ^ (-1 : ℤ) ≠ 1 := by simpa using hk1
  have hk1'' : k ^ (1 : ℤ) ≠ 1 := by simpa using hk1
  obtain ⟨h1, h2, h3⟩ := x.rootGroupIn_closure_diagonal_mul_pair (coxeterList m) (rootB m hm) k
    hr hs hrs (n₁ := -1) (n₂ := -1) (n₃ := 1) (n₄ := -1)
    (cocharacterPairing_neg_rootA_even hm heven)
    (cocharacterPairing_rootC_even hm heven)
    (by rw [← reflectionWord_reverse_apply]
        exact cocharacterPairing_reflectionWord_reverse_neg_rootA_even hm heven)
    (by rw [← reflectionWord_reverse_apply]
        exact cocharacterPairing_reflectionWord_reverse_rootC_even hm heven)
    (by rw [← reflectionWord_apply]
        exact cocharacterPairing_reflectionWord_neg_rootA_even hm heven)
    (.zpow_of_zpowers_eq_top hk (.inr rfl)) (.zpow_of_zpowers_eq_top hk (.inr rfl))
    hk1' hk1' hk1'' hk1'
  exact eq_top_of_rootGroupIn_neg_rootA_even hm heven x hx _ h3 h1 h2

/-- Even `m`, `|K| = 2`: `G = ⟨x_a(1) x_c(1), ω(L)⟩`. -/
theorem closure_pair_eq_top_even (hm : 4 ≤ m) (heven : m % 2 = 0)
    (x : SteinbergSystem (cartanD m) (isFiniteType_cartanD m) K G)
    (hx : x.HasUnitCommutatorConstants) (hK : Nat.card K = 2) :
    Subgroup.closure {x.rootElement (rootA m hm) 1 * x.rootElement (rootC m hm) 1,
      weylWordElement x.rootElement (coxeterList m)} = ⊤ := by
  have ha : rootA m hm ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanD m) ∅ :=
    single_mem_roots _ _
  have hb : rootB m hm ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanD m) ∅ :=
    single_mem_roots _ _
  have hc := rootC_mem_even hm heven
  set F : Subgroup G := Subgroup.closure
    {x.rootElement (rootA m hm) 1 * x.rootElement (rootC m hm) 1,
      weylWordElement x.rootElement (coxeterList m)} with hF
  have hy : x.rootElement (rootA m hm) 1 * x.rootElement (rootC m hm) 1 ∈ F :=
    Subgroup.subset_closure (by simp)
  have hg : weylWordElement x.rootElement (coxeterList m) ∈ F :=
    Subgroup.subset_closure (by simp)
  set A := x.rootElement (rootA m hm) 1 with hA
  set B := x.rootElement (rootB m hm) 1 with hB
  set C := x.rootElement (rootC m hm) 1 with hC
  have hinv : ∀ γ ∈ CFSG.LieType.RootSystem.roots (isFiniteType_cartanD m) ∅,
      (x.rootElement γ 1)⁻¹ = x.rootElement γ 1 := by
    intro γ hγ
    apply inv_eq_of_mul_eq_one_right
    rw [← x.rootElement_add γ hγ, one_add_one_eq_zero_of_card_eq_two hK, x.rootElement_zero hγ]
  have hAi : A⁻¹ = A := hinv _ ha
  have hCi : C⁻¹ = C := hinv _ hc
  have hAA : A * A = 1 := by rw [mul_eq_one_iff_eq_inv, hAi]
  -- `a + c`
  obtain ⟨hs1, hs2, hs3⟩ := onlyPositiveCombination_rootA_add_rootC_even hm heven
  obtain ⟨κ, hκ⟩ := hx _ ha _ hc (hs1 ▸ hs2) hs3
  have hκ1 : A * C * A⁻¹ * C⁻¹ = x.rootElement (rootA m hm + rootC m hm) 1 := by
    have := hκ 1 1
    rw [units_eq_one_of_card_eq_two hK κ] at this
    simpa using this
  have hsq : A * C * (A * C) = x.rootElement (rootA m hm + rootC m hm) 1 := by
    rw [hs1, ← hκ1, hAi, hCi]
    simp [mul_assoc]
  have hac : x.RootGroupIn F (rootA m hm + rootC m hm) := by
    refine rootGroupIn_of_card_eq_two hK x F (hs1 ▸ hs2) ?_
    rw [← hsq]; exact F.mul_mem hy hy
  have hbF : x.RootGroupIn F (rootB m hm) := by
    have := (x.rootGroupIn_weylWordRoot F (coxeterList m) hg hac).2
    rwa [← reflectionWord_reverse_apply, reflectionWord_reverse_rootA_add_rootC_even hm heven]
      at this
  -- `b + c`
  obtain ⟨ht1, ht2, ht3⟩ := onlyPositiveCombination_rootC_add_rootB_even hm heven
  obtain ⟨κ', hκ'⟩ := hx _ hc _ hb (ht1 ▸ ht2) ht3
  have hκ2 : C * B * C⁻¹ * B⁻¹ = x.rootElement (rootB m hm + rootC m hm) 1 := by
    have := hκ' 1 1
    rw [units_eq_one_of_card_eq_two hK κ', ← ht1] at this
    simpa using this
  have hab : ∀ c c' : K, Commute (x.rootElement (rootA m hm) c) (x.rootElement (rootB m hm) c') :=
    fun c c' ↦ x.rootElement_commute _ ha _ hb (by
      intro h
      have := congrFun h ⟨m - 1, by omega⟩
      simp [rootA, rootB, Pi.single_apply, Fin.ext_iff] at this
      omega) (noPositiveCombination_rootA_rootB_even hm heven) c c'
  have hAB : A * B = B * A := (hab 1 1).eq
  have hABA : A⁻¹ * B * A = B := by
    rw [hAi, mul_assoc, ← hAB]
    calc A * (A * B) = (A * A) * B := by rw [mul_assoc]
      _ = B := by rw [hAA, one_mul]
  have hcomm : (A * C)⁻¹ * B * (A * C) * B⁻¹ = x.rootElement (rootB m hm + rootC m hm) 1 := by
    rw [← hκ2]
    have : (A * C)⁻¹ * B * (A * C) * B⁻¹ = C⁻¹ * (A⁻¹ * B * A) * C * B⁻¹ := by group
    rw [this, hABA, hCi]
  have hbc : x.RootGroupIn F (rootB m hm + rootC m hm) := by
    refine rootGroupIn_of_card_eq_two hK x F (ht1 ▸ ht2) ?_
    rw [← hcomm]
    exact F.mul_mem (F.mul_mem (F.mul_mem (F.inv_mem hy) (hbF.2 1)) hy) (F.inv_mem (hbF.2 1))
  have haF : x.RootGroupIn F (rootA m hm) := by
    have := (x.rootGroupIn_weylWordRoot F (coxeterList m) hg hbc).2
    rwa [← reflectionWord_reverse_apply, reflectionWord_reverse_rootB_add_rootC_even hm heven]
      at this
  have hcF : x.RootGroupIn F (rootC m hm) := by
    refine rootGroupIn_of_card_eq_two hK x F hc ?_
    change C ∈ F
    have : C = A⁻¹ * (A * C) := by group
    rw [this]
    exact F.mul_mem (F.inv_mem (haF.2 1)) hy
  exact eq_top_of_rootGroupIn_rootA_rootB_rootC_even hm heven x F hg haF hbF hcF

/-- A group with a Steinberg system of type `D_m` (`m ≥ 4`) with unit commutator constants over
a finite field is two-generated. -/
theorem twoGenerated (hm : 4 ≤ m)
    (x : SteinbergSystem (cartanD m) (isFiniteType_cartanD m) K G)
    (hx : x.HasUnitCommutatorConstants) : TwoGenerated G := by
  have h2 : 2 ≤ Nat.card K := Finite.one_lt_card
  rcases Nat.mod_two_eq_zero_or_one m with heven | hodd
  · by_cases hK : 3 ≤ Nat.card K
    · obtain ⟨k, hk⟩ := isCyclic_iff_exists_zpowers_eq_top.1 (inferInstance : IsCyclic Kˣ)
      exact ⟨_, _, closure_diagonal_mul_eq_top_even hm heven x hx hK k hk⟩
    · exact ⟨_, _, closure_pair_eq_top_even hm heven x hx (by omega)⟩
  · by_cases hK : 4 ≤ Nat.card K
    · obtain ⟨k, hk⟩ := isCyclic_iff_exists_zpowers_eq_top.1 (inferInstance : IsCyclic Kˣ)
      exact ⟨_, _, closure_diagonal_mul_eq_top_odd hm hodd x hx hK k hk⟩
    · exact ⟨_, _, closure_pair_eq_top_odd hm hodd x hx (by omega)⟩

end TypeD

end CFSGCorollary
