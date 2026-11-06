module

public import Mathlib.Algebra.BigOperators.Group.List.Defs
public import Mathlib.Algebra.Group.Subgroup.Defs
import Mathlib.Algebra.BigOperators.Group.List.Basic
import Mathlib.Tactic.Group

/-!
# Paths of involutions and their Coxeter elements

A list `[s₁, …, s_m]` of elements of a group is an *involution path* (of type `A_m`) if the `sᵢ`
are involutions, consecutive ones satisfy the braid relation `(sᵢ sᵢ₊₁)³ = 1`, and non-adjacent
ones commute. Its *Coxeter element* is `c = s₁ s₂ ⋯ s_m`. Conjugation by `c` moves each node to the
next one, and `c ^ (m + 1) = 1`, as in the symmetric group `S_{m+1}` with its Coxeter generators.
Consequently a subgroup containing `c` and one node contains the whole path.

## Main definitions

* `CFSGCorollary.IsInvolutionPath`: the list is a path of involutions of type `A_m`.
* `CFSGCorollary.pathCoxeterElement`: the product of the path.

## Main results

* `CFSGCorollary.pathCoxeterElement_conj_getElem`: `c sᵢ c⁻¹ = sᵢ₊₁`.
* `CFSGCorollary.pathCoxeterElement_pow_length_succ`: `c ^ (m + 1) = 1`.
* `CFSGCorollary.mem_of_pathCoxeterElement_mem_of_getElem_mem`: a subgroup containing `c` and one
  node contains every node.
-/

@[expose] public section

namespace CFSGCorollary

variable {G : Type*} [Group G]

/-- The list `[s₁, …, s_m]` (with `m ≥ 1`) is a path of involutions of type `A_m`:
`sᵢ² = 1`, `(sᵢ sᵢ₊₁)³ = 1`, and `sᵢ sⱼ = sⱼ sᵢ` whenever `|i - j| ≥ 2`. -/
def IsInvolutionPath (path : List G) : Prop :=
  path ≠ [] ∧
  (∀ (i : ℕ) (hi : i < path.length), path[i] * path[i] = 1) ∧
  (∀ (i : ℕ) (hi : i + 1 < path.length),
    (path[i] * path[i + 1]'hi) ^ 3 = 1) ∧
  (∀ (i j : ℕ) (hi : i < path.length) (hj : j < path.length), i + 2 ≤ j →
    path[i] * path[j] = path[j] * path[i])

/-- The Coxeter element `c = s₁ s₂ ⋯ s_m` of a path: the product of the list in order. -/
def pathCoxeterElement (path : List G) : G :=
  path.prod

/-! ### Conjugation by the Coxeter element -/

/-- Adjacent nodes `x, y` of an involution path satisfy `x y x y x = y`. -/
theorem IsInvolutionPath.braid {path : List G}
    (h : IsInvolutionPath path) (i : ℕ) (hi : i + 1 < path.length) :
    path[i] * path[i + 1] * path[i] * path[i + 1] * path[i] = path[i + 1] := by
  obtain ⟨-, h2, h3, -⟩ := h
  have a := h2 i (by omega)
  have b := h2 (i + 1) hi
  have c := h3 i hi
  generalize path[i] = x at *
  generalize path[i + 1] = y at *
  have hx : x⁻¹ = x := inv_eq_of_mul_eq_one_right a
  have hy : y⁻¹ = y := inv_eq_of_mul_eq_one_right b
  have : x * y * x * y * x * y = 1 := by simpa [pow_succ, mul_assoc] using c
  calc x * y * x * y * x = (x * y * x * y * x * y) * y⁻¹ := by group
    _ = y⁻¹ := by rw [this]; simp
    _ = y := hy

/-- For a path `s₁, …, s_m` of involutions, `c sᵢ c⁻¹ = s_{i+1}` (0-indexed). -/
theorem pathCoxeterElement_conj_getElem {path : List G}
    (h : IsInvolutionPath path) (i : ℕ) (hi : i + 1 < path.length) :
    pathCoxeterElement path * path[i] * (pathCoxeterElement path)⁻¹ = path[i + 1] := by
  have hbr := h.braid i hi
  obtain ⟨-, h2, -, h4⟩ := h
  have hA : Commute path[i + 1] (path.take i).prod := by
    refine Commute.list_prod_right _ _ fun z hz ↦ ?_
    obtain ⟨k, hk, rfl⟩ := List.mem_iff_getElem.mp hz
    simp only [List.length_take, List.getElem_take] at hk ⊢
    exact (h4 k (i + 1) (by omega) hi (by omega)).symm
  have hB : Commute path[i] (path.drop (i + 2)).prod := by
    refine Commute.list_prod_right _ _ fun z hz ↦ ?_
    obtain ⟨k, hk, rfl⟩ := List.mem_iff_getElem.mp hz
    simp only [List.length_drop, List.getElem_drop] at hk ⊢
    exact h4 i (i + 2 + k) (by omega) (by omega) (by omega)
  have hd : path.drop i = path[i] :: path[i + 1] :: path.drop (i + 2) := by
    rw [List.drop_eq_getElem_cons (by omega), List.drop_eq_getElem_cons (by omega)]
  have hc : pathCoxeterElement path =
      (path.take i).prod * (path[i] * (path[i + 1] * (path.drop (i + 2)).prod)) := by
    unfold pathCoxeterElement
    refine (List.prod_take_mul_prod_drop path i).symm.trans ?_
    rw [hd, List.prod_cons, List.prod_cons]
  have hx := h2 i (by omega)
  have hy := h2 (i + 1) hi
  rw [hc]
  generalize (path.take i).prod = A at *
  generalize (path.drop (i + 2)).prod = B at *
  generalize path[i] = x at *
  generalize path[i + 1] = y at *
  have hxi : x⁻¹ = x := inv_eq_of_mul_eq_one_right hx
  have hyi : y⁻¹ = y := inv_eq_of_mul_eq_one_right hy
  have hB' : B * x = x * B := hB.symm.eq
  have hA' : A * y = y * A := hA.symm.eq
  have hBx : B * x * B⁻¹ = x := by rw [hB']; group
  calc A * (x * (y * B)) * x * (A * (x * (y * B)))⁻¹
      = A * (x * y * (B * x * B⁻¹) * y⁻¹ * x⁻¹) * A⁻¹ := by group
    _ = A * (x * y * x * y * x) * A⁻¹ := by
        rw [hBx, hxi, hyi]
    _ = A * y * A⁻¹ := by rw [hbr]
    _ = y := by rw [hA']; group

/-! ### The order of the Coxeter element -/

theorem IsInvolutionPath.tail {a : G} {t : List G}
    (h : IsInvolutionPath (a :: t)) (ht : t ≠ []) : IsInvolutionPath t := by
  obtain ⟨-, h2, h3, h4⟩ := h
  refine ⟨ht, fun i hi ↦ ?_, fun i hi ↦ ?_, fun i j hi hj hij ↦ ?_⟩
  · exact h2 (i + 1) (by simpa using hi)
  · exact h3 (i + 1) (by simpa using hi)
  · exact h4 (i + 1) (j + 1) (by simpa using hi) (by simpa using hj) (by omega)

private theorem pathCoxeterElement_pow_length_succ_of_length_eq (n : ℕ) (path : List G)
    (hn : path.length = n) (h : IsInvolutionPath path) :
    pathCoxeterElement path ^ (path.length + 1) = 1 := by
  induction n using Nat.strong_induction_on generalizing path with
  | _ n ih =>
    obtain ⟨a, t, rfl⟩ : ∃ a t, path = a :: t := by
      rcases path with _ | ⟨a, t⟩
      · exact absurd rfl h.1
      · exact ⟨a, t, rfl⟩
    have ha : a * a = 1 := h.2.1 0 (by simp)
    rcases t with _ | ⟨b, t'⟩
    · simp [pathCoxeterElement, pow_two, ha]
    · have ht := h.tail (by simp)
      have ih' := ih _ (by rw [← hn]; simp) (b :: t') rfl ht
      set c := pathCoxeterElement (a :: b :: t') with hc
      have hc' : pathCoxeterElement (b :: t') = a * c := by
        rw [hc]; simp only [pathCoxeterElement, List.prod_cons]; rw [← mul_assoc, ha, one_mul]
      rw [hc'] at ih'
      set N := (b :: t').length with hN
      have hNn : n = N + 1 := by simp [hN] at hn ⊢; omega
      have key : ∀ k (hk : k < n), c ^ k * a * (c ^ k)⁻¹ = (a :: b :: t')[k] := by
        intro k
        induction k with
        | zero => intro _; simp
        | succ k ihk =>
          intro hk
          calc c ^ (k + 1) * a * (c ^ (k + 1))⁻¹
              = c * (c ^ k * a * (c ^ k)⁻¹) * c⁻¹ := by group
            _ = _ := by
              rw [ihk (by omega)]
              exact pathCoxeterElement_conj_getElem h k (by simp at hn hk ⊢; omega)
      have prod : ∀ k (hk : k + 1 ≤ n), ((a :: b :: t').take (k + 1)).prod =
          (a * c) ^ k * a * (c ^ k)⁻¹ := by
        intro k
        induction k with
        | zero => intro _; simp
        | succ k ihk =>
          intro hk
          have hlen : k + 1 < (a :: b :: t').length := by simp at hn hk ⊢; omega
          rw [List.take_succ_eq_append_getElem hlen, List.prod_append, ihk (by omega)]
          rw [List.prod_singleton, ← key (k + 1) (by omega), pow_succ (a * c) k]
          generalize (a * c) ^ k = P
          group
      have hfull := prod N (by omega)
      have htake : (a :: b :: t').take (N + 1) = a :: b :: t' := by
        apply List.take_of_length_le; simp [hN]
      rw [htake] at hfull
      have hc2 : c = (a * c) ^ N * a * (c ^ N)⁻¹ := hfull
      have : c ^ (N + 1) = (a * c) ^ N * a := by
        calc c ^ (N + 1) = ((a * c) ^ N * a * (c ^ N)⁻¹) * c ^ N := by
                rw [← hc2]; group
          _ = _ := by group
      have hlen : (a :: b :: t').length = N + 1 := by simp [hN]
      rw [hlen, pow_succ c (N + 1), this]
      calc (a * c) ^ N * a * c = (a * c) ^ (N + 1) := by rw [pow_succ (a * c) N]; group
        _ = 1 := ih'

/-- For a path of involutions of type `A_m`, `c ^ (m + 1) = 1`. -/
theorem pathCoxeterElement_pow_length_succ {path : List G}
    (h : IsInvolutionPath path) :
    pathCoxeterElement path ^ (path.length + 1) = 1 :=
  pathCoxeterElement_pow_length_succ_of_length_eq _ path rfl h

/-! ### Generating the path from the Coxeter element and one node -/

/-- If a subgroup contains the Coxeter element `c` and some node `sᵢ` of an involution path,
it contains every node. -/
theorem mem_of_pathCoxeterElement_mem_of_getElem_mem {path : List G}
    (h : IsInvolutionPath path) (H : Subgroup G) (hc : pathCoxeterElement path ∈ H)
    (i : ℕ) (hi : i < path.length) (hsi : path[i] ∈ H) (j : ℕ) (hj : j < path.length) :
    path[j] ∈ H := by
  have up : ∀ k (hk : k + 1 < path.length), path[k] ∈ H → path[k + 1] ∈ H := fun k hk hm ↦ by
    rw [← pathCoxeterElement_conj_getElem h k hk]
    exact H.mul_mem (H.mul_mem hc hm) (H.inv_mem hc)
  have down : ∀ k (hk : k + 1 < path.length), path[k + 1] ∈ H → path[k] ∈ H := fun k hk hm ↦ by
    have : path[k] = (pathCoxeterElement path)⁻¹ * path[k + 1] * pathCoxeterElement path := by
      rw [← pathCoxeterElement_conj_getElem h k hk]; group
    rw [this]
    exact H.mul_mem (H.mul_mem (H.inv_mem hc) hm) hc
  have upAll : ∀ n (hn : i + n < path.length), path[i + n] ∈ H := by
    intro n
    induction n with
    | zero => intro _; exact hsi
    | succ n ih => intro hn; exact up (i + n) hn (ih (by omega))
  have downAll : ∀ n (hn : n ≤ i), path[i - n]'(by omega) ∈ H := by
    intro n
    induction n with
    | zero => intro _; exact hsi
    | succ n ih =>
      intro hn
      have := down (i - (n + 1)) (by omega) (by
        have e : i - (n + 1) + 1 = i - n := by omega
        simpa only [e] using ih (by omega))
      exact this
  rcases le_total i j with hij | hij
  · have := upAll (j - i) (by omega)
    simpa [Nat.add_sub_cancel' hij] using this
  · have := downAll (i - j) (by omega)
    simpa [Nat.sub_sub_self hij] using this

end CFSGCorollary
