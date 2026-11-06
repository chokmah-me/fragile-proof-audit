module

public import CFSG.Blueprint.Chevalley
import CFSG.Blueprint.ChevalleyStringsInputs

@[expose] public section

/-!
# Common lemmas for the twisted groups

Two general tools used for several families of twisted groups.

* Root groups indexed by the roots of a Chevalley type `τ`, with Weyl representatives `n i`
  permuting them like the simple reflections: a subgroup containing the root groups of all
  simple roots and their negatives is everything (`eq_top_of_simple_root_groups_le`), and words in
  the `n i` transport root groups (`map_conj_word_rootGroup_eq`, `rootGroup_le_of_word_mem`).
* The trace `c ↦ ∑ i < m, c ^ (q ^ i)` of `GF(q ^ m)` maps onto the fixed field of `c ↦ c ^ q`
  (`trace_surjective_onto_fixed`).

## Main results

* `CFSGCorollary.eq_top_of_simple_root_groups_le`
* `CFSGCorollary.map_conj_word_rootGroup_eq`
* `CFSGCorollary.rootGroup_le_of_word_mem`
* `CFSGCorollary.trace_surjective_onto_fixed`
-/

namespace CFSGCorollary

open CFSG.Blueprint.Chevalley

/-- Root groups of all simple roots and their negatives generate: if `n i` conjugates `X β` into
`X (reflect τ i β)` (W), `n i ∈ X (e i) ⊔ X (-e i)` (R), and the root groups generate `G` (T), then
a subgroup containing `X (e i)` and `X (-e i)` for all `i` is `⊤`. -/
theorem eq_top_of_simple_root_groups_le {τ : Tag} {G : Type*} [Group G]
    (X : (Fin τ.rank → ℤ) → Subgroup G) (n : Fin τ.rank → G)
    (hW : ∀ (i : Fin τ.rank) (β : Fin τ.rank → ℤ), IsRoot τ β → ∀ x ∈ X β,
      n i * x * (n i)⁻¹ ∈ X (reflect τ i β))
    (hR : ∀ i : Fin τ.rank, n i ∈ X (Pi.single i 1) ⊔ X (-Pi.single i 1))
    (hT : ⨆ β ∈ {β : Fin τ.rank → ℤ | IsRoot τ β}, X β = ⊤)
    (F : Subgroup G)
    (hF : ∀ i : Fin τ.rank, X (Pi.single i 1) ≤ F ∧ X (-Pi.single i 1) ≤ F) :
    F = ⊤ := by
  have hn : ∀ i, n i ∈ F := fun i ↦ sup_le (hF i).1 (hF i).2 (hR i)
  have hroot : ∀ β, IsRoot τ β → X β ≤ F := by
    intro β hβ
    induction hβ with
    | basis j => exact (hF j).1
    | @reflect i v hv ih =>
      intro y hy
      have hz : n i * y * (n i)⁻¹ ∈ X (reflect τ i (reflect τ i v)) :=
        hW i _ (IsRoot.reflect i hv) y hy
      rw [reflect_reflect] at hz
      have : y = (n i)⁻¹ * (n i * y * (n i)⁻¹) * n i := by group
      rw [this]
      exact F.mul_mem (F.mul_mem (F.inv_mem (hn i)) (ih hz)) (hn i)
  rw [eq_top_iff, ← hT]
  exact iSup₂_le fun β hβ ↦ hroot β hβ

/-- Weyl representatives map root groups onto root groups. -/
theorem map_conj_rootGroup_eq_reflect {τ : Tag} {G : Type*} [Group G]
    (X : (Fin τ.rank → ℤ) → Subgroup G) (n : Fin τ.rank → G)
    (hW : ∀ (i : Fin τ.rank) (β : Fin τ.rank → ℤ), IsRoot τ β → ∀ x ∈ X β,
      n i * x * (n i)⁻¹ ∈ X (reflect τ i β))
    (H : Fin τ.rank → Subgroup G) (hsq : ∀ i, n i ^ 2 ∈ H i)
    (hH : ∀ (i : Fin τ.rank) (β : Fin τ.rank → ℤ), IsRoot τ β → ∀ h ∈ H i, ∀ x ∈ X β,
      h * x * h⁻¹ ∈ X β)
    (i : Fin τ.rank) (β : Fin τ.rank → ℤ) (hβ : IsRoot τ β) :
    (X β).map (MulAut.conj (n i)).toMonoidHom = X (reflect τ i β) := by
  apply le_antisymm
  · rintro _ ⟨x, hx, rfl⟩
    exact hW i β hβ x hx
  · intro y hy
    have hz : n i * y * (n i)⁻¹ ∈ X (reflect τ i (reflect τ i β)) :=
      hW i _ (IsRoot.reflect i hβ) y hy
    rw [reflect_reflect] at hz
    refine ⟨(n i ^ 2)⁻¹ * (n i * y * (n i)⁻¹) * ((n i ^ 2)⁻¹)⁻¹,
      hH i β hβ _ (inv_mem (hsq i)) _ hz, ?_⟩
    change n i * ((n i ^ 2)⁻¹ * (n i * y * (n i)⁻¹) * ((n i ^ 2)⁻¹)⁻¹) * (n i)⁻¹ = y
    group

/-- The word version: conjugating by `n i₁ * ⋯ * n i_r` maps `X β` onto
`X (reflect τ i₁ (⋯ (reflect τ i_r β)))`. -/
theorem map_conj_word_rootGroup_eq {τ : Tag} {G : Type*} [Group G]
    (X : (Fin τ.rank → ℤ) → Subgroup G) (n : Fin τ.rank → G)
    (hW : ∀ (i : Fin τ.rank) (β : Fin τ.rank → ℤ), IsRoot τ β → ∀ x ∈ X β,
      n i * x * (n i)⁻¹ ∈ X (reflect τ i β))
    (H : Fin τ.rank → Subgroup G) (hsq : ∀ i, n i ^ 2 ∈ H i)
    (hH : ∀ (i : Fin τ.rank) (β : Fin τ.rank → ℤ), IsRoot τ β → ∀ h ∈ H i, ∀ x ∈ X β,
      h * x * h⁻¹ ∈ X β)
    (word : List (Fin τ.rank)) (β : Fin τ.rank → ℤ) (hβ : IsRoot τ β) :
    (X β).map (MulAut.conj (word.map n).prod).toMonoidHom =
      X (word.foldr (fun i v ↦ reflect τ i v) β) := by
  induction word with
  | nil => ext x; simp
  | cons i word ih =>
    have hroot : IsRoot τ (word.foldr (fun i v ↦ reflect τ i v) β) := by
      clear ih
      induction word with
      | nil => exact hβ
      | cons j word ih' => exact IsRoot.reflect j ih'
    have h1 := map_conj_rootGroup_eq_reflect X n hW H hsq hH i _ hroot
    rw [List.foldr_cons, ← h1, ← ih]
    simp only [List.map_cons, List.prod_cons, map_mul, MulAut.conj]
    rw [Subgroup.map_map]
    rfl

/-- A subgroup containing a word `g = n i₁ * ⋯ * n i_r` and `X β` contains
`X (reflect τ i₁ (⋯ (reflect τ i_r β)))`. -/
theorem rootGroup_le_of_word_mem {τ : Tag} {G : Type*} [Group G]
    (X : (Fin τ.rank → ℤ) → Subgroup G) (n : Fin τ.rank → G)
    (hW : ∀ (i : Fin τ.rank) (β : Fin τ.rank → ℤ), IsRoot τ β → ∀ x ∈ X β,
      n i * x * (n i)⁻¹ ∈ X (reflect τ i β))
    (H : Fin τ.rank → Subgroup G) (hsq : ∀ i, n i ^ 2 ∈ H i)
    (hH : ∀ (i : Fin τ.rank) (β : Fin τ.rank → ℤ), IsRoot τ β → ∀ h ∈ H i, ∀ x ∈ X β,
      h * x * h⁻¹ ∈ X β)
    (word : List (Fin τ.rank)) (β : Fin τ.rank → ℤ) (hβ : IsRoot τ β)
    (F : Subgroup G) (hg : (word.map n).prod ∈ F) (hX : X β ≤ F) :
    X (word.foldr (fun i v ↦ reflect τ i v) β) ≤ F := by
  rw [← map_conj_word_rootGroup_eq X n hW H hsq hH word β hβ]
  rintro _ ⟨x, hx, rfl⟩
  have := F.mul_mem (F.mul_mem hg (hX hx)) (F.inv_mem hg)
  simpa [MulAut.conj_apply] using this

open Polynomial in
/-- The trace of a finite field extension is onto the fixed field: with `σ c = c ^ q` and
`Nat.card K = q ^ m`, `T c = ∑ i < m, σ^[i] c` is `σ`-fixed and every `σ`-fixed element is a
value of `T`. The polynomial `∑ i < m, X ^ (q ^ i)` bounds the kernel of `T`, and `X ^ q - X`
bounds the fixed field. -/
theorem trace_surjective_onto_fixed {K : Type*} [Field K] [Finite K] {q m : ℕ} (hq : 2 ≤ q)
    (hm : 1 ≤ m) (hK : Nat.card K = q ^ m) (σ : K →+* K) (hσ : ∀ c : K, σ c = c ^ q) :
    (∀ c : K, σ (∑ i ∈ Finset.range m, σ^[i] c) = ∑ i ∈ Finset.range m, σ^[i] c) ∧
      ∀ c' : K, σ c' = c' → ∃ c : K, ∑ i ∈ Finset.range m, σ^[i] c = c' := by
  classical
  have := Fintype.ofFinite K
  have hit : ∀ i : ℕ, ∀ c : K, σ^[i] c = c ^ (q ^ i) := by
    intro i c
    induction i with
    | zero => simp
    | succ i ih => rw [Function.iterate_succ_apply', ih, hσ, ← pow_mul, pow_succ]
  have hcard : Fintype.card K = q ^ m := by rw [← Nat.card_eq_fintype_card]; exact hK
  have hfix : ∀ c : K, σ^[m] c = c := by
    intro c; rw [hit, ← hcard, FiniteField.pow_card]
  have hT : ∀ c : K, σ (∑ i ∈ Finset.range m, σ^[i] c) = ∑ i ∈ Finset.range m, σ^[i] c := by
    intro c
    rw [map_sum]
    simp_rw [← Function.iterate_succ_apply' σ]
    have h1 := Finset.sum_range_succ (fun i ↦ σ^[i] c) m
    have h2 := Finset.sum_range_succ' (fun i ↦ σ^[i] c) m
    rw [h1, hfix c] at h2
    simp only [Function.iterate_zero, id_eq] at h2
    exact add_right_cancel h2.symm
  refine ⟨hT, ?_⟩
  let T : K →+ K :=
    { toFun := fun c ↦ ∑ i ∈ Finset.range m, σ^[i] c
      map_zero' := by simp
      map_add' := fun a b ↦ by simp only [iterate_map_add, Finset.sum_add_distrib] }
  have hTapp : ∀ c, T c = ∑ i ∈ Finset.range m, σ^[i] c := fun c ↦ rfl
  have hq0 : 0 < q := by omega
  -- the kernel of `T` has at most `q ^ (m - 1)` elements
  let P : K[X] := ∑ i ∈ Finset.range m, (X : K[X]) ^ (q ^ i)
  have hPdeg : P.natDegree ≤ q ^ (m - 1) := by
    refine natDegree_sum_le_of_forall_le _ _ fun i hi ↦ ?_
    rw [natDegree_X_pow]
    exact Nat.pow_le_pow_right hq0 (by have := Finset.mem_range.1 hi; omega)
  have hPne : P ≠ 0 := by
    intro h0
    have hc : P.coeff (q ^ (m - 1)) = 1 := by
      simp only [P, finsetSum_coeff, coeff_X_pow]
      rw [Finset.sum_eq_single (m - 1)]
      · simp
      · intro b _ hb
        rw [ite_eq_right_iff]
        intro h
        exact (hb (Nat.pow_right_injective hq h.symm)).elim
      · intro h; exact absurd (Finset.mem_range.2 (by omega)) h
    rw [h0] at hc; simp at hc
  have hPeval : ∀ c : K, P.eval c = T c := by
    intro c
    simp [P, eval_finsetSum, hTapp, hit]
  have hker : Nat.card T.ker ≤ q ^ (m - 1) := by
    have hsub : (T.ker : Set K) ⊆ (P.roots.toFinset : Set K) := by
      intro c hc
      simp only [SetLike.mem_coe, AddMonoidHom.mem_ker] at hc
      simp [mem_roots hPne, hPeval, hc]
    have := Set.ncard_le_ncard hsub (Finset.finite_toSet _)
    rw [Set.ncard_coe_finset] at this
    calc Nat.card T.ker = (T.ker : Set K).ncard := Nat.card_coe_set_eq _
      _ ≤ P.roots.toFinset.card := this
      _ ≤ Multiset.card P.roots := Multiset.toFinset_card_le _
      _ ≤ P.natDegree := card_roots' P
      _ ≤ _ := hPdeg
  have hrange : q ≤ Nat.card T.range := by
    have h := AddSubgroup.card_ker_mul_card_range T
    rw [hK] at h
    by_contra hlt
    push Not at hlt
    have : Nat.card T.ker * Nat.card T.range < q ^ (m - 1) * q := by
      calc Nat.card T.ker * Nat.card T.range ≤ q ^ (m - 1) * Nat.card T.range :=
            Nat.mul_le_mul_right _ hker
        _ < q ^ (m - 1) * q := Nat.mul_lt_mul_of_pos_left hlt (by positivity)
    rw [h, ← pow_succ, Nat.sub_add_cancel hm] at this
    exact lt_irrefl _ this
  -- the fixed field of `σ` has at most `q` elements
  let F : Set K := {c' | σ c' = c'}
  have hF : F.ncard ≤ q := by
    have hdeg : (X ^ q - X : K[X]).natDegree = q := by
      rw [natDegree_sub_eq_left_of_natDegree_lt] <;> simp; omega
    have hQ : (X ^ q - X : K[X]) ≠ 0 := ne_zero_of_natDegree_gt (n := 0) (by omega)
    have hsub : F ⊆ ((X ^ q - X : K[X]).roots.toFinset : Set K) := by
      intro c hc
      have hc' : σ c = c := hc
      rw [hσ] at hc'
      simp [mem_roots hQ, hc']
    have := Set.ncard_le_ncard hsub (Finset.finite_toSet _)
    rw [Set.ncard_coe_finset] at this
    calc F.ncard ≤ _ := this
      _ ≤ _ := Multiset.toFinset_card_le _
      _ ≤ _ := card_roots' _
      _ = q := hdeg
  have hRF : (T.range : Set K) ⊆ F := by
    rintro _ ⟨c, rfl⟩
    exact hT c
  have hRncard : (T.range : Set K).ncard = Nat.card T.range := Nat.card_coe_set_eq _
  have heq := Set.eq_of_subset_of_ncard_le hRF (by omega) (Set.toFinite F)
  intro c' hc'
  obtain ⟨c, hc⟩ : c' ∈ (T.range : Set K) := heq ▸ hc'
  exact ⟨c, hc⟩

end CFSGCorollary
