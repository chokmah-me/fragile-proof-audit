/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under MIT license as described in the file LICENSE.
Authors: Daniyel Yaacov Bilar, Muse
-/
import FragileProofAudit.LittGame.Game
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Field

/-!
# The de Bruijn block chain of the Litt game

This module formalizes §4 of arXiv:2503.19035v1 (Janson–Nica–Segert,
"The generalized Alice HH vs Bob HT problem"): the Markov chain on
length-`ℓ` blocks over the alphabet `Fin q` whose transition appends a
fresh uniform letter and drops the first letter of the block.

Main results:

* `card_block`: there are `q ^ ℓ` blocks.
* `step_eq_iff`: characterization of the one-step transition.
* `transProb_row_sum`: rows of the transition kernel sum to `1`
  (out-degree `q`: every block has exactly `q` successors).
* `transProb_col_sum` / `uniform_stationary`: columns sum to `1`, i.e. the
  uniform distribution on blocks is stationary
  (in-degree `q`: every block has exactly `q` predecessors).
* `irreducible`: every block reaches every other block, via the explicit
  path that spells the target block letter by letter.
* `aperiodic_self_loop`: every constant block `a^ℓ` is a self-loop; this is
  the paper's aperiodicity witness (a self-loop has period one).
* `bridge_occCount`: chain partial sums of the block score function equal
  the M2 substring occurrence counts `occCount`.

Mathlib has no finite-Markov-chain stationary-distribution framework, so the
general finite-kernel lemmas needed here (`transProb_row_sum`,
`transProb_col_sum`) are proved directly.
-/

namespace FragileProofAudit.LittGame

variable {q ℓ : ℕ}

/-- Length-`ℓ` blocks over `Fin q`: the states of the de Bruijn chain. -/
def Block (q ℓ : ℕ) := { w : List (Fin q) // w.length = ℓ }

/-- Blocks are the same as length-`ℓ` words, i.e. functions `Fin ℓ → Fin q`. -/
def blockEquiv : Block q ℓ ≃ (Fin ℓ → Fin q) where
  toFun w := fun i : Fin ℓ => w.1[i.1]'(by have h1 := w.2; have h2 := i.2; omega)
  invFun f := ⟨List.ofFn f, by simp⟩
  left_inv := by
    rintro ⟨l, hlen⟩
    apply Subtype.ext
    show List.ofFn (fun i : Fin ℓ => l[i.1]'(by have h2 := i.2; omega)) = l
    subst hlen
    exact List.ofFn_getElem
  right_inv := by
    intro f
    funext i
    have hlen : i.1 < (List.ofFn f).length := by simp [i.2]
    show (List.ofFn f)[i.1]'hlen = f i
    rw [List.getElem_ofFn hlen]

instance : Fintype (Block q ℓ) := Fintype.ofEquiv _ (blockEquiv).symm

instance : DecidableEq (Block q ℓ) := fun a b =>
  if h : a.1 = b.1 then isTrue (Subtype.ext h)
  else isFalse (fun hab => h (congrArg Subtype.val hab))

/-- There are `q ^ ℓ` blocks. -/
theorem card_block : Fintype.card (Block q ℓ) = q ^ ℓ := by
  rw [Fintype.card_congr (blockEquiv), Fintype.card_fun, Fintype.card_fin,
    Fintype.card_fin]

/-- The constant block `a^ℓ` (the paper's self-loop state). -/
def constBlock (a : Fin q) : Block q ℓ := ⟨List.replicate ℓ a, List.length_replicate⟩

/-- One chain step: append the fresh letter `a`, drop the first letter. -/
def step (hℓ : 1 ≤ ℓ) (u : Block q ℓ) (a : Fin q) : Block q ℓ :=
  ⟨(u.1.drop 1) ++ [a], by
    have hu := u.2
    simp only [List.length_append, List.length_drop, List.length_cons,
      List.length_nil]
    omega⟩

/-- Characterization of the one-step transition: stepping from `u` with
    letter `a` lands on `v` iff `u` without its first letter agrees with `v`
    without its last letter, and `a` is the last letter of `v`. -/
theorem step_eq_iff (hℓ : 1 ≤ ℓ) (u v : Block q ℓ) (a : Fin q) (hne : v.1 ≠ []) :
    step hℓ u a = v ↔ u.1.drop 1 = v.1.dropLast ∧ a = v.1.getLast hne := by
  have hlen : (u.1.drop 1).length = v.1.dropLast.length := by
    have hu := u.2
    have hv := v.2
    simp only [List.length_drop, List.length_dropLast]
    omega
  constructor
  · intro h
    have h1 : (u.1.drop 1) ++ [a] = v.1.dropLast ++ [v.1.getLast hne] := by
      have h1' : (u.1.drop 1) ++ [a] = v.1 := congrArg Subtype.val h
      rwa [← List.dropLast_append_getLast hne] at h1'
    obtain ⟨hp, htl⟩ := List.append_inj h1 hlen
    refine ⟨hp, by simpa using htl⟩
  · rintro ⟨hp, heq⟩
    rw [heq]
    apply Subtype.ext
    show (u.1.drop 1) ++ [v.1.getLast hne] = v.1
    rw [hp]
    exact List.dropLast_append_getLast hne

/-- Transition probability: uniform over the `q` letters, so `P(u,v)` is the
    fraction of letters stepping from `u` to `v`. -/
def transProb (hℓ : 1 ≤ ℓ) (u v : Block q ℓ) : ℚ :=
  ((Finset.univ.filter fun a : Fin q => step hℓ u a = v).card : ℚ) / (q : ℚ)

/-- Rows sum to one: every block has exactly `q` successors (out-degree). -/
theorem transProb_row_sum (hℓ : 1 ≤ ℓ) (hq : 1 ≤ q) (u : Block q ℓ) :
    ∑ v, transProb hℓ u v = 1 := by
  have hq' : (q : ℚ) ≠ 0 := by exact_mod_cast (by omega : q ≠ 0)
  have hfib : (∑ b ∈ (Finset.univ : Finset (Block q ℓ)),
      (Finset.univ.filter fun a : Fin q => step hℓ u a = b).card) = q := by
    have h := Finset.card_eq_sum_card_fiberwise (s := (Finset.univ : Finset (Fin q)))
      (t := (Finset.univ : Finset (Block q ℓ)))
      (f := fun a : Fin q => step hℓ u a)
      (fun a _ => Finset.mem_coe.mpr (Finset.mem_univ _))
    rw [Finset.card_univ, Fintype.card_fin] at h
    exact h.symm
  have hunfold : ∀ v : Block q ℓ, transProb hℓ u v
      = ((Finset.univ.filter fun a : Fin q => step hℓ u a = v).card : ℚ) / (q : ℚ) :=
    fun v => rfl
  have key : (∑ v : Block q ℓ,
      ((Finset.univ.filter fun a : Fin q => step hℓ u a = v).card : ℚ)) = (q : ℚ) := by
    rw [← Nat.cast_sum]
    exact_mod_cast hfib
  simp_rw [hunfold, ← Finset.sum_div, key]
  exact div_self hq'

/-- Every block has exactly `q` predecessors (in-degree). -/
theorem card_predecessors (hℓ : 1 ≤ ℓ) (v : Block q ℓ) :
    (Finset.univ.filter fun u : Block q ℓ => u.1.drop 1 = v.1.dropLast).card = q := by
  have hne : v.1 ≠ [] := by
    intro h
    have hv := v.2
    rw [h, List.length_nil] at hv
    omega
  let mk : Fin q → Block q ℓ := fun c => ⟨c :: v.1.dropLast, by
    have hv := v.2
    simp only [List.length_cons, List.length_dropLast]
    omega⟩
  have himg : (Finset.univ.filter fun u : Block q ℓ => u.1.drop 1 = v.1.dropLast)
      = Finset.univ.image mk := by
    ext u
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · intro hu
      have hne_u : u.1 ≠ [] := by
        intro h
        have hu2 := u.2
        rw [h, List.length_nil] at hu2
        omega
      obtain ⟨c, t, hct⟩ := List.exists_cons_of_ne_nil hne_u
      apply Exists.intro c
      apply Subtype.ext
      show (c :: v.1.dropLast) = u.1
      have ht : t = v.1.dropLast := by
        have hu2 : (c :: t).drop 1 = v.1.dropLast := by rwa [← hct]
        exact hu2
      rw [← ht]
      exact hct.symm
    · intro h
      obtain ⟨c, hc⟩ := h
      rw [← hc]
      show (c :: v.1.dropLast).drop 1 = v.1.dropLast
      rfl
  have hinj : Function.Injective mk := by
    intro a b hab
    have h2 : (a :: v.1.dropLast) = (b :: v.1.dropLast) := congrArg Subtype.val hab
    cases h2
    rfl
  rw [himg, Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_fin]

/-- Columns sum to one: with in-degree `q`, each column holds total mass `1`. -/
theorem transProb_col_sum (hℓ : 1 ≤ ℓ) (hq : 1 ≤ q) (v : Block q ℓ) :
    ∑ u, transProb hℓ u v = 1 := by
  have hq' : (q : ℚ) ≠ 0 := by exact_mod_cast (by omega : q ≠ 0)
  have hne : v.1 ≠ [] := by
    intro h
    have hv := v.2
    rw [h, List.length_nil] at hv
    omega
  have hcard : ∀ u : Block q ℓ,
      (Finset.univ.filter fun a : Fin q => step hℓ u a = v).card =
        (if u.1.drop 1 = v.1.dropLast then 1 else 0) := by
    intro u
    by_cases hu : u.1.drop 1 = v.1.dropLast
    · have hset : (Finset.univ.filter fun a : Fin q => step hℓ u a = v)
          = {v.1.getLast hne} := by
        ext a
        simp only [Finset.mem_filter, Finset.mem_univ, true_and,
          Finset.mem_singleton]
        rw [step_eq_iff hℓ u v a hne]
        exact ⟨fun h => h.2, fun h => ⟨hu, h⟩⟩
      rw [if_pos hu, hset, Finset.card_singleton]
    · rw [if_neg hu, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
      intro a ha
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
      rw [step_eq_iff hℓ u v a hne] at ha
      exact hu ha.1
  have key : (∑ u : Block q ℓ,
      ((Finset.univ.filter fun a : Fin q => step hℓ u a = v).card : ℚ)) = (q : ℚ) := by
    have hsum : (∑ u : Block q ℓ,
        (Finset.univ.filter fun a : Fin q => step hℓ u a = v).card) = q := by
      simp_rw [hcard, Finset.sum_boole]
      exact card_predecessors hℓ v
    rw [← Nat.cast_sum]
    exact_mod_cast hsum
  have hunfold : ∀ u : Block q ℓ, transProb hℓ u v
      = ((Finset.univ.filter fun a : Fin q => step hℓ u a = v).card : ℚ) / (q : ℚ) :=
    fun u => rfl
  simp_rw [hunfold, ← Finset.sum_div, key]
  exact div_self hq'

/-- The uniform distribution on blocks is stationary: every column of the
    transition kernel sums to one. -/
theorem uniform_stationary (hℓ : 1 ≤ ℓ) (hq : 1 ≤ q) :
    ∀ v : Block q ℓ, ∑ u, transProb hℓ u v = 1 :=
  fun v => transProb_col_sum hℓ hq v

/-- Forward reachability by chain steps. -/
inductive Reachable (hℓ : 1 ≤ ℓ) : Block q ℓ → Block q ℓ → Prop where
  | refl (u : Block q ℓ) : Reachable hℓ u u
  | step {u v : Block q ℓ} (a : Fin q) (h : Reachable hℓ u v) :
      Reachable hℓ u (step hℓ v a)

/-- The `k`-th block on the path that spells `v` starting from `u`:
    keep the last `ℓ - k` letters of `u`, then the first `k` letters of `v`. -/
def walkBlock (u v : Block q ℓ) (k : ℕ) : Block q ℓ :=
  ⟨(u.1.drop k) ++ (v.1.take k), by
    have hu := u.2
    have hv := v.2
    simp only [List.length_append, List.length_drop, List.length_take]
    omega⟩

/-- The spelling path is a genuine chain path: each step appends the next
    letter of the target block. -/
theorem reachable_walk (hℓ : 1 ≤ ℓ) (u v : Block q ℓ) (k : ℕ) (hk : k ≤ ℓ) :
    Reachable hℓ u (walkBlock u v k) := by
  revert hk
  induction k with
  | zero =>
    intro hk
    have heq : walkBlock u v 0 = u := by
      apply Subtype.ext
      show (u.1.drop 0) ++ (v.1.take 0) = u.1
      simp
    rw [heq]
    exact Reachable.refl u
  | succ k ih =>
    intro hk
    have hk' : k ≤ ℓ := by omega
    have hget : k < v.1.length := by have hv := v.2; omega
    have heq : step hℓ (walkBlock u v k) (v.1.get ⟨k, hget⟩)
        = walkBlock u v (k + 1) := by
      apply Subtype.ext
      show ((u.1.drop k) ++ (v.1.take k)).drop 1 ++ [v.1.get ⟨k, hget⟩]
        = (u.1.drop (k + 1)) ++ (v.1.take (k + 1))
      have hne : (u.1.drop k) ≠ [] := by
        intro hcon
        have hu := u.2
        have h1 : (u.1.drop k).length = 0 := by rw [hcon]; rfl
        simp only [List.length_drop] at h1
        omega
      obtain ⟨c, t, hct⟩ := List.exists_cons_of_ne_nil hne
      have e1 : ((u.1.drop k) ++ (v.1.take k)).drop 1 = t ++ (v.1.take k) := by
        rw [hct]
        rfl
      have e2 : u.1.drop (k + 1) = t := by
        have hdd : u.1.drop (k + 1) = (u.1.drop k).drop 1 := (List.drop_drop).symm
        rw [hdd, hct]
        rfl
      have e3 : (v.1.take k) ++ [v.1.get ⟨k, hget⟩] = v.1.take (k + 1) := by
        conv_rhs => rw [List.take_succ_eq_append_getElem hget]
        rfl
      rw [e1, List.append_assoc, e2, e3]
    have hstep := Reachable.step (v.1.get ⟨k, hget⟩) (ih hk')
    rw [heq] at hstep
    exact hstep

/-- The chain is irreducible: every block reaches every other block. -/
theorem irreducible (hℓ : 1 ≤ ℓ) (u v : Block q ℓ) : Reachable hℓ u v := by
  have h := reachable_walk hℓ u v ℓ le_rfl
  have heq : walkBlock u v ℓ = v := by
    apply Subtype.ext
    show (u.1.drop ℓ) ++ (v.1.take ℓ) = v.1
    have hu := u.2
    have hv := v.2
    have e1 : u.1.drop ℓ = [] := List.drop_eq_nil_of_le (by omega)
    have e2 : v.1.take ℓ = v.1 := by
      have h := List.take_length (l := v.1)
      rwa [hv] at h
    rw [e1, List.nil_append]
    exact e2
  rw [heq] at h
  exact h

/-- Aperiodicity witness: every constant block `a^ℓ` is a self-loop
    (hence has period one), as recorded in the audit of §4. -/
theorem aperiodic_self_loop (hℓ : 1 ≤ ℓ) (a : Fin q) :
    step hℓ (constBlock a) a = constBlock a := by
  obtain ⟨m, hm⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : ℓ ≠ 0)
  subst hm
  apply Subtype.ext
  show ((List.replicate (m + 1) a).drop 1) ++ [a] = List.replicate (m + 1) a
  have e1 : (List.replicate (m + 1) a).drop 1 = List.replicate m a := by
    rw [List.replicate_succ]
    rfl
  rw [e1]
  have e2 : ([a] : List (Fin q)) = List.replicate 1 a := rfl
  rw [e2, ← List.replicate_add]

/-- Block q ℓ score function: `1` if the block equals `A`, else `0`. -/
def blockScore (A : List (Fin q)) (w : Block q ℓ) : ℕ :=
  if w.1 = A then 1 else 0

/-- The chain trajectory read off a letter sequence: the block at time `i`. -/
def trajBlock (hℓ : 1 ≤ ℓ) (s : List (Fin q)) (i : ℕ) (hi : i + ℓ ≤ s.length) :
    Block q ℓ :=
  ⟨(s.drop i).take ℓ, by
    have h1 : ((s.drop i).take ℓ).length = ℓ := by
      simp only [List.length_take, List.length_drop]
      omega
    exact h1⟩

/-- Consecutive trajectory blocks are linked by a chain step with the next
    letter of the sequence. -/
theorem trajBlock_step (hℓ : 1 ≤ ℓ) (s : List (Fin q)) (i : ℕ)
    (hi : i + 1 + ℓ ≤ s.length) :
    step hℓ (trajBlock hℓ s i (by omega)) (s.get ⟨i + ℓ, by omega⟩)
      = trajBlock hℓ s (i + 1) (by omega) := by
  obtain ⟨m, hm⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : ℓ ≠ 0)
  subst hm
  apply Subtype.ext
  show ((s.drop i).take (m + 1)).drop 1 ++ [s.get ⟨i + (m + 1), by omega⟩]
    = (s.drop (i + 1)).take (m + 1)
  have hdrop1 : (s.drop i).drop 1 = s.drop (i + 1) := List.drop_drop
  have hlen : m < (s.drop (i + 1)).length := by
    have h_eq : (s.drop (i + 1)).length = s.length - (i + 1) := by simp
    have h1 : m + (i + 2) ≤ s.length := by omega
    omega
  have hget : s.get ⟨i + (m + 1), by omega⟩ = (s.drop (i + 1))[m]'hlen := by
    rw [List.get_eq_getElem, List.getElem_drop]
    simp only [Fin.val_mk]
    congr 1
    omega
  rw [List.drop_take, hdrop1]
  have hm1 : m + 1 - 1 = m := by omega
  rw [hm1, List.take_succ_eq_append_getElem hlen, hget]

/-- Score of the trajectory block at time `i`, defaulting to `0` outside the
    valid range. -/
def blockScoreAt (hℓ : 1 ≤ ℓ) (A s : List (Fin q)) (i : ℕ) : ℕ :=
  if hi : i + ℓ ≤ s.length then blockScore A (trajBlock hℓ s i hi) else 0

/-- Within the valid range, the trajectory score is the substring indicator. -/
theorem blockScoreAt_eq (hℓ : 1 ≤ ℓ) (A s : List (Fin q)) (i : ℕ)
    (hi : i + ℓ ≤ s.length) :
    blockScoreAt hℓ A s i = (if (s.drop i).take ℓ = A then 1 else 0) := by
  have h : blockScoreAt hℓ A s i = blockScore A (trajBlock hℓ s i hi) := by
    unfold blockScoreAt
    rw [dif_pos hi]
  rw [h]
  rfl

/-- Bridge lemma: the chain partial sums of the block score function equal
    the M2 substring occurrence counts. -/
theorem bridge_occCount (hℓ : 1 ≤ ℓ) (A s : List (Fin q)) (hA : A.length = ℓ) :
    ∑ i ∈ Finset.range (s.length + 1 - ℓ), blockScoreAt hℓ A s i
      = occCount q A s := by
  have key : ∀ i ∈ Finset.range (s.length + 1 - ℓ),
      blockScoreAt hℓ A s i = (if (s.drop i).take ℓ = A then 1 else 0) := by
    intro i hi
    apply blockScoreAt_eq
    rw [Finset.mem_range] at hi
    omega
  rw [Finset.sum_congr rfl key, Finset.sum_boole, Nat.cast_id]
  unfold occCount
  rw [hA]

end FragileProofAudit.LittGame
