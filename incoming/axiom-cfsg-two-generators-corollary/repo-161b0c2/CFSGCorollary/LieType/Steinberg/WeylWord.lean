module

public import CFSGCorollary.LieType.Steinberg.Basic


/-!
# Weyl words in a Steinberg system

For a list `L = [l₁, …, l_k]` of simple indices, this file defines the Weyl group element
`w_L = s_{l₁} ⋯ s_{l_k}` acting on root coordinates (`weylWordRoot`, `weylWordRootInv`,
`reflectionWord`) and the corresponding product of Weyl elements `ω(L) = ω_{l₁} ⋯ ω_{l_k}`
(`weylWordElement`), and shows that in Steinberg data `ω(L)` permutes the root groups up to sign
according to `w_L`. It also collects the root-lattice notions shared by the per-type computations:
the cocharacter pairing and positive combinations of two roots.

## Main results

* `CFSGCorollary.reflection_mem_roots`: simple reflections preserve the roots.
* `CFSGCorollary.reflectionWord_apply`, `CFSGCorollary.reflectionWord_reverse_apply`: `w_L` and
  `w_L⁻¹` as iterated reflections.
* `CFSGCorollary.SteinbergData.weylWordElement_conj`: `ω(L) X_γ ω(L)⁻¹ = X_{w_L γ}` and
  `ω(L)⁻¹ X_γ ω(L) = X_{w_L⁻¹ γ}`, up to signs.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

open CFSG.LieType.RootSystem (roots reflection weylAction coxeterMatrix)
open CFSG.LieType.Steinberg (weylElement)

/-- `w_L = s_{l₁} ⋯ s_{l_k}` for the list `L = [l₁, …, l_k]`, as a product of simple reflections
in `Module.End ℤ (I → ℤ)`. The inverse `w_L⁻¹` is `reflectionWord A L.reverse`. -/
noncomputable def reflectionWord {I : Type} [Fintype I] [DecidableEq I] (A : Matrix I I ℤ)
    (L : List I) : Module.End ℤ (I → ℤ) :=
  (L.map (reflection A)).prod

/-- `reflectionWord` is the Weyl group action of the product of the simple generators. -/
theorem reflectionWord_eq_weylAction {I : Type} [Fintype I] [DecidableEq I] {A : Matrix I I ℤ}
    (hA : TauCeti.IsFiniteType A) (L : List I) :
    reflectionWord A L =
      weylAction hA ((L.map (coxeterMatrix hA).toCoxeterSystem.simple).prod) := by
  unfold reflectionWord
  rw [map_list_prod, List.map_map]
  congr 1

theorem reflectionWord_reverse_mul {I : Type} [Fintype I] [DecidableEq I] {A : Matrix I I ℤ}
    (hA : ∀ i, A i i = 2) (L : List I) : reflectionWord A L.reverse * reflectionWord A L = 1 := by
  induction L with
  | nil => simp [reflectionWord]
  | cons a L ih =>
    simp only [reflectionWord, List.reverse_cons, List.map_append, List.prod_append,
      List.map_cons, List.map_nil, List.prod_cons, List.prod_nil, mul_one] at ih ⊢
    rw [mul_assoc, ← mul_assoc (reflection A a), CFSG.LieType.RootSystem.reflection_mul_self (hA a),
      one_mul, ih]

theorem reflectionWord_mul_reflectionWord_reverse {I : Type} [Fintype I] [DecidableEq I]
    {A : Matrix I I ℤ} (hA : ∀ i, A i i = 2) (L : List I) :
    reflectionWord A L * reflectionWord A L.reverse = 1 := by
  simpa using reflectionWord_reverse_mul hA L.reverse

theorem reflectionWord_reverse_apply_of_eq {I : Type} [Fintype I] [DecidableEq I]
    {A : Matrix I I ℤ} (hA : ∀ i, A i i = 2) (L : List I) {ρ γ : I → ℤ}
    (h : reflectionWord A L ρ = γ) : reflectionWord A L.reverse γ = ρ := by
  rw [← h, ← Module.End.mul_apply, reflectionWord_reverse_mul hA, Module.End.one_apply]

/-- `ω(L) = ω_{l₁} ⋯ ω_{l_k}` with `ωᵢ = weylElement x i 1`. -/
def weylWordElement {K G : Type*} [Field K] [Group G] {rank : ℕ}
    (x : (Fin rank → ℤ) → K → G) (L : List (Fin rank)) : G :=
  (L.map fun i ↦ weylElement x i 1).prod

/-- `e(γ) = ∑ᵢ μ i · ∑ⱼ A i j · γ j`: the exponent by which `h_μ(k)` acts on `X_γ`. -/
def cocharacterPairing {I : Type} [Fintype I] (A : Matrix I I ℤ) (μ : I → ℤ) (γ : I → ℤ) : ℤ :=
  ∑ i, μ i * ∑ j, A i j * γ j

/-- No positive combination `i • u + j • v` (`i, j ≥ 1`) lies in `Φ`. -/
def NoPositiveCombination {I : Type} (Φ : Set (I → ℤ)) (u v : I → ℤ) : Prop :=
  ∀ i j : ℕ, 0 < i → 0 < j → i • u + j • v ∉ Φ

/-- `t = u + v ∈ Φ` is the only positive combination of `(u, v)` in `Φ`. -/
def OnlyPositiveCombination {I : Type} (Φ : Set (I → ℤ)) (u v t : I → ℤ) : Prop :=
  t = u + v ∧ t ∈ Φ ∧ ∀ i j : ℕ, 0 < i → 0 < j → i • u + j • v ∈ Φ → i = 1 ∧ j = 1

section WeylWordRoot

variable {rank : ℕ}

/-- `w_L γ = s_{l₁} (⋯ (s_{l_k} γ))` for `L = [l₁, …, l_k]`. -/
def weylWordRoot (cartan : Matrix (Fin rank) (Fin rank) ℤ) (L : List (Fin rank))
    (γ : Fin rank → ℤ) : Fin rank → ℤ :=
  L.foldr (fun i v ↦ reflection cartan i v) γ

/-- `w_L⁻¹ γ = s_{l_k} (⋯ (s_{l₁} γ))`: the reflections of `L` applied in the reverse order. -/
def weylWordRootInv (cartan : Matrix (Fin rank) (Fin rank) ℤ) (L : List (Fin rank))
    (γ : Fin rank → ℤ) : Fin rank → ℤ :=
  L.foldl (fun v i ↦ reflection cartan i v) γ

variable {cartan : Matrix (Fin rank) (Fin rank) ℤ}

theorem reflectionWord_apply (A : Matrix (Fin rank) (Fin rank) ℤ) (L : List (Fin rank))
    (γ : Fin rank → ℤ) : reflectionWord A L γ = weylWordRoot A L γ := by
  induction L with
  | nil => rfl
  | cons i L ih =>
    simp only [reflectionWord, weylWordRoot, List.map_cons, List.prod_cons,
      List.foldr_cons] at ih ⊢
    rw [Module.End.mul_apply, ih]

theorem reflectionWord_reverse_apply (A : Matrix (Fin rank) (Fin rank) ℤ) (L : List (Fin rank))
    (γ : Fin rank → ℤ) : reflectionWord A L.reverse γ = weylWordRootInv A L γ := by
  rw [reflectionWord_apply, weylWordRoot, weylWordRootInv, List.foldr_reverse]

theorem reflectionWord_pow_apply (A : Matrix (Fin rank) (Fin rank) ℤ) (L : List (Fin rank))
    (k : ℕ) (γ : Fin rank → ℤ) : (reflectionWord A L ^ k) γ = (weylWordRoot A L)^[k] γ := by
  induction k generalizing γ with
  | zero => rfl
  | succ k ih =>
    rw [pow_succ, Module.End.mul_apply, ih, Function.iterate_succ_apply, reflectionWord_apply]

theorem single_mem_roots (finiteType : TauCeti.IsFiniteType cartan) (i : Fin rank) :
    (Pi.single i 1 : Fin rank → ℤ) ∈ roots finiteType ∅ :=
  Or.inl ⟨1, i, by simp⟩

/-- Simple reflections preserve the set of roots. -/
theorem reflection_mem_roots (finiteType : TauCeti.IsFiniteType cartan) (i : Fin rank)
    {γ : Fin rank → ℤ} (hγ : γ ∈ roots finiteType ∅) :
    reflection cartan i γ ∈ roots finiteType ∅ := by
  have := CFSG.LieType.RootSystem.weylAction_mem_roots (D := ∅) finiteType
    ((coxeterMatrix finiteType).toCoxeterSystem.simple i) hγ
  rwa [CFSG.LieType.RootSystem.weylAction_simple] at this

theorem weylWordRoot_mem_roots (finiteType : TauCeti.IsFiniteType cartan) (L : List (Fin rank))
    {γ : Fin rank → ℤ} (hγ : γ ∈ roots finiteType ∅) :
    weylWordRoot cartan L γ ∈ roots finiteType ∅ := by
  induction L with
  | nil => exact hγ
  | cons i L ih => exact reflection_mem_roots finiteType i ih

theorem weylWordRootInv_mem_roots (finiteType : TauCeti.IsFiniteType cartan)
    (L : List (Fin rank)) {γ : Fin rank → ℤ} (hγ : γ ∈ roots finiteType ∅) :
    weylWordRootInv cartan L γ ∈ roots finiteType ∅ := by
  induction L generalizing γ with
  | nil => exact hγ
  | cons i L ih => exact ih (reflection_mem_roots finiteType i hγ)

theorem weylWordRoot_weylWordRootInv (finiteType : TauCeti.IsFiniteType cartan)
    (L : List (Fin rank)) (γ : Fin rank → ℤ) :
    weylWordRoot cartan L (weylWordRootInv cartan L γ) = γ := by
  induction L generalizing γ with
  | nil => rfl
  | cons i L ih =>
    have h := CFSG.LieType.RootSystem.reflection_mul_self (A := cartan) (i := i)
      (finiteType.apply_self i)
    have h2 := congrArg (fun f ↦ f γ) h
    simp only [weylWordRoot, weylWordRootInv, List.foldr_cons, List.foldl_cons] at ih ⊢
    rw [ih]
    simpa using h2

theorem weylWordRootInv_weylWordRoot (finiteType : TauCeti.IsFiniteType cartan)
    (L : List (Fin rank)) (γ : Fin rank → ℤ) :
    weylWordRootInv cartan L (weylWordRoot cartan L γ) = γ := by
  induction L generalizing γ with
  | nil => rfl
  | cons i L ih =>
    have h := CFSG.LieType.RootSystem.reflection_mul_self (A := cartan) (i := i)
      (finiteType.apply_self i)
    have h2 := congrArg (fun f ↦ f (weylWordRoot cartan L γ)) h
    simp only [weylWordRoot, weylWordRootInv, List.foldr_cons, List.foldl_cons] at ih h2 ⊢
    simp only [Module.End.mul_apply, Module.End.one_apply] at h2
    rw [h2]
    exact ih γ

/-- `w_L` as a permutation of `ℤ^rank`. -/
def weylWordPerm (finiteType : TauCeti.IsFiniteType cartan) (L : List (Fin rank)) :
    Equiv.Perm (Fin rank → ℤ) where
  toFun := weylWordRoot cartan L
  invFun := weylWordRootInv cartan L
  left_inv := weylWordRootInv_weylWordRoot finiteType L
  right_inv := weylWordRoot_weylWordRootInv finiteType L

theorem weylWordPerm_mem_iff (finiteType : TauCeti.IsFiniteType cartan) (L : List (Fin rank))
    (γ : Fin rank → ℤ) :
    weylWordPerm finiteType L γ ∈ roots finiteType ∅ ↔ γ ∈ roots finiteType ∅ :=
  ⟨fun h ↦ by
    have : (weylWordPerm finiteType L).symm (weylWordPerm finiteType L γ) ∈
        roots finiteType ∅ :=
      weylWordRootInv_mem_roots finiteType L h
    rwa [Equiv.symm_apply_apply] at this,
   fun h ↦ weylWordRoot_mem_roots finiteType L h⟩

theorem weylWordPerm_symm_mem_iff (finiteType : TauCeti.IsFiniteType cartan)
    (L : List (Fin rank)) (γ : Fin rank → ℤ) :
    (weylWordPerm finiteType L).symm γ ∈ roots finiteType ∅ ↔ γ ∈ roots finiteType ∅ := by
  have := weylWordPerm_mem_iff finiteType L ((weylWordPerm finiteType L).symm γ)
  rw [Equiv.apply_symm_apply] at this
  exact this.symm

end WeylWordRoot

namespace SteinbergData

variable {rank : ℕ} {cartan : Matrix (Fin rank) (Fin rank) ℤ}
  {finiteType : TauCeti.IsFiniteType cartan} {K G : Type*}
  [Field K] [Finite K] [Group G]

theorem weylWordElement_conj_rootElement (data : SteinbergData cartan finiteType K G)
    (L : List (Fin rank)) (γ : Fin rank → ℤ) (hγ : γ ∈ roots finiteType ∅) :
    ∃ ε : ℤ, (ε = 1 ∨ ε = -1) ∧ ∀ u : K,
      weylWordElement data.rootElement L * data.rootElement γ u *
          (weylWordElement data.rootElement L)⁻¹ =
        data.rootElement (weylWordRoot cartan L γ) ((ε : K) * u) := by
  induction L with
  | nil => exact ⟨1, Or.inl rfl, fun u ↦ by simp [weylWordElement, weylWordRoot]⟩
  | cons i L ih =>
    obtain ⟨ε, hε, h⟩ := ih
    obtain ⟨s, hs, hs'⟩ :=
      data.weylElement_conj_rootElement i _ (weylWordRoot_mem_roots finiteType L hγ)
    refine ⟨s * ε, ?_, fun u ↦ ?_⟩
    · rcases hs with rfl | rfl <;> rcases hε with rfl | rfl <;> simp
    · have e : weylWordElement data.rootElement (i :: L) =
          weylElement data.rootElement i (1 : Kˣ) * weylWordElement data.rootElement L := by
        simp [weylWordElement]
      have h' := hs' 1 ((ε : K) * u)
      rw [e, mul_inv_rev]
      calc _ = weylElement data.rootElement i 1 *
            (weylWordElement data.rootElement L * data.rootElement γ u *
              (weylWordElement data.rootElement L)⁻¹) *
            (weylElement data.rootElement i 1)⁻¹ := by group
        _ = _ := by rw [h u, h']; simp [weylWordRoot, mul_assoc]

/-- Products of Weyl elements: `ω(L)` permutes root groups up to sign according to `w_L`. -/
theorem weylWordElement_conj (data : SteinbergData cartan finiteType K G)
    (L : List (Fin rank)) (γ : Fin rank → ℤ) (hγ : γ ∈ roots finiteType ∅) :
    weylWordRoot cartan L γ ∈ roots finiteType ∅ ∧
      weylWordRootInv cartan L γ ∈ roots finiteType ∅ ∧
      ∃ ε ε' : ℤ, (ε = 1 ∨ ε = -1) ∧ (ε' = 1 ∨ ε' = -1) ∧
        ∀ u : K,
          weylWordElement data.rootElement L * data.rootElement γ u *
              (weylWordElement data.rootElement L)⁻¹ =
              data.rootElement (weylWordRoot cartan L γ) ((ε : K) * u) ∧
          (weylWordElement data.rootElement L)⁻¹ * data.rootElement γ u *
              weylWordElement data.rootElement L =
              data.rootElement (weylWordRootInv cartan L γ) ((ε' : K) * u) := by
  have hinv := weylWordRootInv_mem_roots finiteType L hγ
  refine ⟨weylWordRoot_mem_roots finiteType L hγ, hinv, ?_⟩
  obtain ⟨ε, hε, h⟩ := weylWordElement_conj_rootElement data L γ hγ
  obtain ⟨δ, hδ, hδ'⟩ := weylWordElement_conj_rootElement data L _ hinv
  refine ⟨ε, δ, hε, hδ, fun u ↦ ⟨h u, ?_⟩⟩
  have hδ2 : (δ : K) * δ = 1 := by
    rcases hδ with rfl | rfl <;> simp
  have key := hδ' ((δ : K) * u)
  rw [weylWordRoot_weylWordRootInv finiteType, ← mul_assoc, hδ2, one_mul] at key
  rw [← key]
  group

end SteinbergData

end CFSGCorollary
