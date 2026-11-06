module

public import CFSGCorollary.LieType.Chevalley.Roots.TypeF4
import CFSGCorollary.LieType.Steinberg.ClosurePair
public import CFSGCorollary.LieType.Steinberg.Diagonal
import CFSGCorollary.LieType.Steinberg.GeneratingScalar

/-!
# Two-generation of Chevalley groups of type `F₄`

Steinberg's theorem for type `F₄`, for a group `G` with a Steinberg system of type `F₄` over a
finite field `K`, with `L` as in `TypeF4.coxeterList` and `ω(L)` the corresponding product of
Weyl elements:

* if `|K| ≥ 3` and `k` generates `Kˣ`, then `G = ⟨h_μ(k), x_r(1) x_s(1) ω(L)⟩` for the roots `r`,
  `s` and the cocharacter `μ` of `Roots.TypeF4`; every root group `X_{±αᵢ}` is a conjugate of
  `X_r` or `X_s` by a power of `ω(L)`;
* if `|K| = 2` and the commutators `⁅x_{r₂}(1), x_{w⁵ r₂}(1)⁆` and `⁅x_{s₂}(1), x_{w s₂}(1)⁆`
  are `x_{t₁}(1)` and `x_{t₂}(1)`, then `G = ⟨x_{r₂}(1) x_{s₂}(1), ω(L)⟩`; the root groups
  `X_{±αᵢ}` are obtained from `X_{t₁}`, `X_{t₂}` using `ω(L)` and simple Weyl elements.

## Main results

* `TypeF4.closure_diagonal_mul_eq_top`: the case `|K| ≥ 3`.
* `TypeF4.closure_pair_eq_top_of_card_eq_two`: the case `|K| = 2`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

open scoped commutatorElement

namespace CFSGCorollary.TypeF4

private theorem word_apply (γ : Fin 4 → ℤ) :
    coxeterElement γ = weylWordRoot cartan coxeterList γ :=
  reflectionWord_apply _ _ _

private theorem wordInv_apply (γ : Fin 4 → ℤ) :
    coxeterElementInv γ = weylWordRootInv cartan coxeterList γ :=
  reflectionWord_reverse_apply _ _ _

private theorem word_pow_apply (k : ℕ) (γ : Fin 4 → ℤ) :
    (coxeterElement ^ k) γ = (weylWordRoot cartan coxeterList)^[k] γ := by
  rw [Module.End.pow_apply]
  congr 1

private theorem wordInv_pow_apply (k : ℕ) (γ : Fin 4 → ℤ) :
    (coxeterElementInv ^ k) γ = (weylWordRootInv cartan coxeterList)^[k] γ := by
  rw [Module.End.pow_apply]
  congr 1

private theorem commutatorElement_mul_mul_eq_left {G : Type*} [Group G] {a b a' b' : G}
    (hba' : Commute b a') (hbb' : Commute b b') (hab' : Commute a b') :
    ⁅a * b, a' * b'⁆ = ⁅a, a'⁆ := by
  simp only [commutatorElement_def]
  have e1 : b * (a' * b') * b⁻¹ = a' * b' := by
    rw [(hba'.mul_right hbb').eq]; group
  have e2 : b' * a⁻¹ * b'⁻¹ = a⁻¹ := by
    rw [hab'.symm.inv_right.eq]; group
  calc a * b * (a' * b') * (a * b)⁻¹ * (a' * b')⁻¹
      = a * (b * (a' * b') * b⁻¹) * a⁻¹ * b'⁻¹ * a'⁻¹ := by group
    _ = a * (a' * b') * a⁻¹ * b'⁻¹ * a'⁻¹ := by rw [e1]
    _ = a * a' * (b' * a⁻¹ * b'⁻¹) * a'⁻¹ := by group
    _ = a * a' * a⁻¹ * a'⁻¹ := by rw [e2]

private theorem commutatorElement_mul_mul_eq_right {G : Type*} [Group G] {a b a' b' : G}
    (hab : Commute a b) (haa' : Commute a a') (hab' : Commute a b') (hba' : Commute b a')
    (hT : Commute a' ⁅b, b'⁆) : ⁅a * b, a' * b'⁆ = ⁅b, b'⁆ := by
  have e1 : a * (b * a' * b' * b⁻¹) * a⁻¹ = b * a' * b' * b⁻¹ := by
    have := (((hab.mul_right haa').mul_right hab').mul_right hab.inv_right).eq
    rw [this]; group
  have e3 : a' * ⁅b, b'⁆ * a'⁻¹ = ⁅b, b'⁆ := by
    rw [hT.eq]; group
  calc ⁅a * b, a' * b'⁆
      = (a * (b * a' * b' * b⁻¹) * a⁻¹) * b'⁻¹ * a'⁻¹ := by
        simp only [commutatorElement_def]; group
    _ = b * a' * b' * b⁻¹ * b'⁻¹ * a'⁻¹ := by rw [e1]
    _ = (b * a') * (b' * b⁻¹ * b'⁻¹) * a'⁻¹ := by group
    _ = a' * ⁅b, b'⁆ * a'⁻¹ := by
        rw [hba'.eq]; simp only [commutatorElement_def]; group
    _ = ⁅b, b'⁆ := e3

variable {K G : Type*} [Field K] [Finite K] [Group G]

/-- Type `F₄`, `|K| ≥ 3`: `G = ⟨h_μ(k), x_r(1) x_s(1) ω(L)⟩` for a generator `k` of `Kˣ`. -/
theorem closure_diagonal_mul_eq_top
    (system : SteinbergSystem cartan isFiniteType K G) (hK : 3 ≤ Nat.card K)
    {k : Kˣ} (hk : Subgroup.zpowers k = ⊤) :
    Subgroup.closure
      {cocharacterElement system.rootElement cocharacter k,
        system.rootElement rootR 1 * system.rootElement rootS 1 *
          weylWordElement system.rootElement coxeterList} = ⊤ := by
  classical
  set g := weylWordElement system.rootElement coxeterList with hgdef
  set d := cocharacterElement system.rootElement cocharacter k with hddef
  let v := weylWordPerm isFiniteType coxeterList
  have hvγ : ∀ γ, v γ = weylWordRoot cartan coxeterList γ := fun γ ↦ rfl
  have hvs : ∀ γ, v.symm γ = weylWordRootInv cartan coxeterList γ := fun γ ↦ rfl
  have hv : ∀ γ, γ ∈ rootSet ↔ v γ ∈ rootSet :=
    fun γ ↦ (weylWordPerm_mem_iff isFiniteType coxeterList γ).symm
  have hv' : ∀ γ, γ ∈ rootSet ↔ v.symm γ ∈ rootSet :=
    fun γ ↦ (weylWordPerm_symm_mem_iff isFiniteType coxeterList γ).symm
  obtain ⟨ε, -, hε, -, hg, -⟩ := system.exists_signs_weylWordElement_conj coxeterList
  have hd := SteinbergSystem.cocharacterElement_isDiagonal system cocharacter k
  obtain ⟨hdiag1, hdiag2⟩ := system.isDiagonal_conj_weylWordElement coxeterList hd.1
  have hc1 : Commute d (g * d * g⁻¹) := SteinbergSystem.IsDiagonal.commute system hd.1 hdiag1
  have hc3 : Commute (g * d * g⁻¹) (g⁻¹ * d * g) :=
    SteinbergSystem.IsDiagonal.commute system hdiag1 hdiag2
  -- scalars
  have hsc : ∀ γ ∈ rootSet, ∀ e : ℤ, (e = 1 ∨ e = -1) →
      (∑ i, cocharacter i * ∑ j, cartan i j * γ j) = e →
      ∃ n : Kˣ, IsGeneratingScalar n ∧ n ≠ 1 ∧ RootScaling system.rootElement γ d (n : K) := by
    intro γ hγ e he hpe
    refine ⟨k ^ e, .zpow_of_zpowers_eq_top hk he, ?_, ?_⟩
    · rcases he with rfl | rfl
      · simpa using ne_one_of_zpowers_eq_top hK hk
      · simpa using ne_one_of_zpowers_eq_top hK hk
    · have := hd.2 γ hγ
      rwa [hpe] at this
  have hr : rootR ∈ rootSet := rootR_mem
  have hs : rootS ∈ rootSet := rootS_mem
  have hdr : RootScaling system.rootElement rootR d (1 : Kˣ) := by
    have := hd.2 rootR hr
    have h0 : (∑ i, cocharacter i * ∑ j, cartan i j * rootR j) = 0 := cocharacterPairing_rootR
    rw [h0, zpow_zero] at this
    exact this
  have hsc' : ∀ γ ∈ rootSet, (cocharacterPairing cartan cocharacter γ = 1 ∨
      cocharacterPairing cartan cocharacter γ = -1) →
      ∃ n : Kˣ, IsGeneratingScalar n ∧ n ≠ 1 ∧ RootScaling system.rootElement γ d (n : K) :=
    fun γ hγ he ↦ hsc γ hγ _ he rfl
  obtain ⟨k₁, hk₁, hk₁1, hds⟩ := hsc' rootS hs cocharacterPairing_rootS
  obtain ⟨k₂, -, hk₂1, hdl⟩ := hsc' (v.symm rootR) ((hv' rootR).1 hr) (by
    rw [hvs, ← wordInv_apply]; exact cocharacterPairing_coxeterElementInv_rootR)
  obtain ⟨k₃, -, hk₃1, hdm⟩ := hsc' (v.symm rootS) ((hv' rootS).1 hs) (by
    rw [hvs, ← wordInv_apply]; exact cocharacterPairing_coxeterElementInv_rootS)
  obtain ⟨k₄, hk₄, hk₄1, hdn⟩ := hsc' (v rootR) ((hv rootR).1 hr) (by
    rw [hvγ, ← word_apply]; exact cocharacterPairing_coxeterElement_rootR)
  have hrs : ∀ c c' : K, Commute (system.rootElement rootR c) (system.rootElement rootS c') :=
    system.rootElement_commute rootR hr rootS hs rootR_add_rootS_ne_zero
      noPositiveCombination_rootR_rootS
  obtain ⟨hXr, hXs, hgF⟩ := system.rootElement_mem_and_mem_closure_pair_of_commuting hr hs hrs
    (g := g) (d := d) (v := v) (fun γ ↦ (hv γ).symm) (ε := ε) hε hg hk₁ hk₄ hk₁1 hk₂1 hk₃1
    hk₄1 hdr hds hdl hdm hdn hc1 hc3
  refine system.eq_top_of_weylWord_orbit _ coxeterList hgF {rootR, rootS} ?_ ?_ ?_ ?_
  · intro ρ hρ
    rcases hρ with rfl | rfl
    · exact hr
    · exact hs
  · intro ρ hρ u
    rcases hρ with rfl | rfl
    · exact hXr u
    · exact hXs u
  · intro i
    obtain ⟨n, hn⟩ := exists_coxeterElement_pow_eq i 1 (Or.inl rfl)
    rw [one_smul] at hn
    rcases hn with hn | hn
    · exact ⟨rootR, by simp, n, Or.inl (by rw [← word_pow_apply]; exact hn)⟩
    · exact ⟨rootS, by simp, n, Or.inl (by rw [← word_pow_apply]; exact hn)⟩
  · intro i
    obtain ⟨n, hn⟩ := exists_coxeterElement_pow_eq i (-1) (Or.inr rfl)
    rw [neg_one_smul] at hn
    rcases hn with hn | hn
    · exact ⟨rootR, by simp, n, Or.inl (by rw [← word_pow_apply]; exact hn)⟩
    · exact ⟨rootS, by simp, n, Or.inl (by rw [← word_pow_apply]; exact hn)⟩

theorem conj_pow_rootElement_one (system : SteinbergSystem cartan isFiniteType K G)
    (hK : Nat.card K = 2) (n : ℕ) :
    ∀ γ ∈ rootSet,
      (weylWordElement system.rootElement coxeterList) ^ n * system.rootElement γ 1 *
          ((weylWordElement system.rootElement coxeterList) ^ n)⁻¹ =
        system.rootElement ((weylWordRoot cartan coxeterList)^[n] γ) 1 := by
  have h2 : (-1 : K) = 1 := by
    have := Fintype.ofFinite K
    have h := Nat.cast_card_eq_zero K
    rw [← Nat.card_eq_fintype_card, hK] at h
    have : (2 : K) = 0 := by exact_mod_cast h
    linear_combination -this
  induction n with
  | zero => intro γ hγ; simp
  | succ n ih =>
    intro γ hγ
    have hmem := weylWordRoot_mem_roots isFiniteType coxeterList hγ
    obtain ⟨-, -, e, _, he, -, hc⟩ := system.weylWordElement_conj coxeterList γ hγ
    have h1 := (hc 1).1
    rw [show (e : K) = 1 by rcases he with h' | h' <;> simp [h', h2], mul_one] at h1
    rw [Function.iterate_succ_apply, ← ih _ hmem, ← h1, pow_succ]
    group

theorem weylWordRoot_iterate_mem {γ : Fin 4 → ℤ} (hγ : γ ∈ rootSet) (n : ℕ) :
    (weylWordRoot cartan coxeterList)^[n] γ ∈ rootSet := by
  induction n with
  | zero => exact hγ
  | succ n ih =>
    rw [Function.iterate_succ_apply']
    exact weylWordRoot_mem_roots isFiniteType coxeterList ih

/-- Type `F₄`, `|K| = 2`: if `⁅x_{r₂}(1), x_{w⁵ r₂}(1)⁆ = x_{t₁}(1)` and
`⁅x_{s₂}(1), x_{w s₂}(1)⁆ = x_{t₂}(1)`, then `G = ⟨x_{r₂}(1) x_{s₂}(1), ω(L)⟩`. -/
theorem closure_pair_eq_top_of_card_eq_two
    (system : SteinbergSystem cartan isFiniteType K G) (hK : Nat.card K = 2)
    (h₁ : ⁅system.rootElement rootRCardTwo 1,
        system.rootElement ((coxeterElement ^ 5) rootRCardTwo) 1⁆ =
      system.rootElement rootRCardTwoSum 1)
    (h₂ : ⁅system.rootElement rootSCardTwo 1, system.rootElement (coxeterElement rootSCardTwo) 1⁆ =
      system.rootElement rootSCardTwoSum 1) :
    Subgroup.closure
      {system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1,
        weylWordElement system.rootElement coxeterList} = ⊤ := by
  classical
  have hgpow := conj_pow_rootElement_one system hK
  set g := weylWordElement system.rootElement coxeterList with hgdef
  set F :=
    Subgroup.closure {system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1, g}
    with hF
  have hyF : system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1 ∈ F :=
    Subgroup.subset_closure (by simp)
  have hgF : g ∈ F := Subgroup.subset_closure (by simp)
  have hr₂ : rootRCardTwo ∈ rootSet := rootRCardTwo_mem
  have hs₂ : rootSCardTwo ∈ rootSet := rootSCardTwo_mem
  have hr₂' : rootRCardTwoPowFive ∈ rootSet := by
    have := weylWordRoot_iterate_mem hr₂ 5
    rwa [← word_pow_apply, coxeterElement_pow_five_rootRCardTwo] at this
  have hs₂' : rootSCardTwoPowFive ∈ rootSet := by
    have := weylWordRoot_iterate_mem hs₂ 5
    rwa [← word_pow_apply, coxeterElement_pow_five_rootSCardTwo] at this
  have hr₂'' : rootRCardTwoPowOne ∈ rootSet := by
    have := weylWordRoot_mem_roots isFiniteType coxeterList hr₂
    rwa [← word_apply, coxeterElement_rootRCardTwo] at this
  have hs₂'' : rootSCardTwoPowOne ∈ rootSet := by
    have := weylWordRoot_mem_roots isFiniteType coxeterList hs₂
    rwa [← word_apply, coxeterElement_rootSCardTwo] at this
  have ht₁ : rootRCardTwoSum ∈ rootSet := rootRCardTwoSum_mem
  have ht₂ : rootSCardTwoSum ∈ rootSet := rootSCardTwoSum_mem
  have hcom : ∀ {u v : Fin 4 → ℤ}, u ∈ rootSet → v ∈ rootSet → u + v ≠ 0 →
      NoPositiveCombination rootSet u v →
      ∀ c c' : K, Commute (system.rootElement u c) (system.rootElement v c') :=
    fun hu hv hne hnp ↦ system.rootElement_commute _ hu _ hv hne hnp
  -- conjugates of `y`
  have hy5 :
      g ^ 5 * (system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1) * (g ^ 5)⁻¹ =
      system.rootElement rootRCardTwoPowFive 1 * system.rootElement rootSCardTwoPowFive 1 := by
    have e1 := hgpow 5 rootRCardTwo hr₂
    have e2 := hgpow 5 rootSCardTwo hs₂
    rw [← word_pow_apply, coxeterElement_pow_five_rootRCardTwo] at e1
    rw [← word_pow_apply, coxeterElement_pow_five_rootSCardTwo] at e2
    rw [← e1, ← e2]; group
  have hy1 : g * (system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1) * g⁻¹ =
      system.rootElement rootRCardTwoPowOne 1 * system.rootElement rootSCardTwoPowOne 1 := by
    have e1 := hgpow 1 rootRCardTwo hr₂
    have e2 := hgpow 1 rootSCardTwo hs₂
    simp only [pow_one, Function.iterate_one] at e1 e2
    rw [← word_apply, coxeterElement_rootRCardTwo] at e1
    rw [← word_apply, coxeterElement_rootSCardTwo] at e2
    rw [← e1, ← e2]; group
  have hcomm : ∀ {y z : G}, y ∈ F → z ∈ F → ⁅y, z⁆ ∈ F := by
    intro y z hy hz
    rw [commutatorElement_def]
    exact F.mul_mem (F.mul_mem (F.mul_mem hy hz) (F.inv_mem hy)) (F.inv_mem hz)
  have hT1 : system.rootElement rootRCardTwoSum 1 ∈ F := by
    have hm : ⁅system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1,
        g ^ 5 * (system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1) *
          (g ^ 5)⁻¹⁆ ∈ F :=
      hcomm hyF (F.mul_mem (F.mul_mem (F.pow_mem hgF 5) hyF) (F.inv_mem (F.pow_mem hgF 5)))
    rw [hy5, commutatorElement_mul_mul_eq_left
        (hcom hs₂ hr₂' (by decide +kernel)
          noPositiveCombination_rootSCardTwo_rootRCardTwoPowFive 1 1)
        (hcom hs₂ hs₂' (by decide +kernel)
          noPositiveCombination_rootSCardTwo_rootSCardTwoPowFive 1 1)
        (hcom hr₂ hs₂' (by decide +kernel)
          noPositiveCombination_rootRCardTwo_rootSCardTwoPowFive 1 1),
        ← coxeterElement_pow_five_rootRCardTwo, h₁] at hm
    exact hm
  have h₂' : ⁅system.rootElement rootSCardTwo 1, system.rootElement rootSCardTwoPowOne 1⁆ =
      system.rootElement rootSCardTwoSum 1 := by
    rw [← coxeterElement_rootSCardTwo]; exact h₂
  have hT2 : system.rootElement rootSCardTwoSum 1 ∈ F := by
    have hm : ⁅system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1,
        g * (system.rootElement rootRCardTwo 1 * system.rootElement rootSCardTwo 1) * g⁻¹⁆ ∈ F :=
      hcomm hyF (F.mul_mem (F.mul_mem hgF hyF) (F.inv_mem hgF))
    rw [hy1, commutatorElement_mul_mul_eq_right
        (hcom hr₂ hs₂ (by decide +kernel)
          noPositiveCombination_rootRCardTwo_rootSCardTwo 1 1)
        (hcom hr₂ hr₂'' (by decide +kernel)
          noPositiveCombination_rootRCardTwo_rootRCardTwoPowOne 1 1)
        (hcom hr₂ hs₂'' (by decide +kernel)
          noPositiveCombination_rootRCardTwo_rootSCardTwoPowOne 1 1)
        (hcom hs₂ hr₂'' (by decide +kernel)
          noPositiveCombination_rootSCardTwo_rootRCardTwoPowOne 1 1)
        (by
          rw [h₂']
          exact hcom hr₂'' ht₂ (by decide +kernel)
            noPositiveCombination_rootRCardTwoPowOne_rootSCardTwoSum 1 1),
        h₂'] at hm
    exact hm
  have hXt₁ : ∀ u : K, system.rootElement rootRCardTwoSum u ∈ F := fun u ↦
    range_subset_of_card_eq_prime_of_mem 2 Nat.prime_two hK (system.rootElement rootRCardTwoSum)
      (system.rootElement_add rootRCardTwoSum ht₁) F hT1 ⟨u, rfl⟩
  have hXt₂ : ∀ u : K, system.rootElement rootSCardTwoSum u ∈ F := fun u ↦
    range_subset_of_card_eq_prime_of_mem 2 Nat.prime_two hK (system.rootElement rootSCardTwoSum)
      (system.rootElement_add rootSCardTwoSum ht₂) F hT2 ⟨u, rfl⟩
  let P : (Fin 4 → ℤ) → Prop := fun γ ↦ γ ∈ rootSet ∧ ∀ u : K, system.rootElement γ u ∈ F
  have hPw : ∀ γ, P γ → ∀ n : ℕ, P ((coxeterElement ^ n) γ) ∧ P ((coxeterElementInv ^ n) γ) := by
    intro γ hγ n
    rw [word_pow_apply, wordInv_pow_apply]
    exact system.rootGroupIn_iterate F coxeterList hgF hγ n
  have hPs : ∀ (i : Fin 4) γ, P γ →
      CFSG.LieType.Steinberg.weylElement system.rootElement i (1 : Kˣ) ∈ F →
      P (CFSG.LieType.RootSystem.reflection cartan i γ) := fun i γ hγ hω ↦
    system.rootGroupIn_reflection F i hω hγ
  have hω : ∀ i : Fin 4, P (simpleRoot i) → P (-simpleRoot i) →
      CFSG.LieType.Steinberg.weylElement system.rootElement i (1 : Kˣ) ∈ F := by
    intro i hp hn
    unfold CFSG.LieType.Steinberg.weylElement
    exact F.mul_mem (F.mul_mem (hp.2 _) (hn.2 _)) (hp.2 _)
  have hP₁ : P rootRCardTwoSum := ⟨ht₁, hXt₁⟩
  have hP₂ : P rootSCardTwoSum := ⟨ht₂, hXt₂⟩
  have hp0 : P (simpleRoot 0) := by
    rw [simpleRoot_zero]; simpa using (hPw rootRCardTwoSum hP₁ 1).1
  have hn0 : P (-simpleRoot 0) := by
    rw [neg_simpleRoot_zero]; exact (hPw rootRCardTwoSum hP₁ 5).2
  have hp1 : P (simpleRoot 1) := by
    rw [simpleRoot_one]; exact (hPw rootRCardTwoSum hP₁ 2).1
  have hn1 : P (-simpleRoot 1) := by
    rw [neg_simpleRoot_one]; exact (hPw rootRCardTwoSum hP₁ 4).2
  have hω1 := hω 1 hp1 hn1
  have hp2 : P (simpleRoot 2) := by
    rw [simpleRoot_two]
    simpa using (hPw _ (hPs 1 _ (hPw rootSCardTwoSum hP₂ 4).2 hω1) 1).1
  have hn2 : P (-simpleRoot 2) := by
    rw [neg_simpleRoot_two]
    simpa using (hPw _ (hPs 1 _ (hPw rootSCardTwoSum hP₂ 2).1 hω1) 1).1
  have hω2 := hω 2 hp2 hn2
  have hp3 : P (simpleRoot 3) := by
    rw [simpleRoot_three]; exact hPs 2 _ (hPw rootSCardTwoSum hP₂ 4).2 hω2
  have hn3 : P (-simpleRoot 3) := by
    rw [neg_simpleRoot_three]; exact hPs 2 _ (hPw rootSCardTwoSum hP₂ 2).1 hω2
  refine system.eq_top_of_simple_root_groups F ?_ ?_
  · intro i u
    fin_cases i
    · exact hp0.2 u
    · exact hp1.2 u
    · exact hp2.2 u
    · exact hp3.2 u
  · intro i u
    fin_cases i
    · exact hn0.2 u
    · exact hn1.2 u
    · exact hn2.2 u
    · exact hn3.2 u

end CFSGCorollary.TypeF4
