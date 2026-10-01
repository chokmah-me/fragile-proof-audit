/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Private campaign artifact. Gates refute routes, not theorems.
-/

import FragileProofAudit.LittGame.Theta
import Mathlib.Data.Finset.Interval
import Mathlib.Order.Interval.Finset.Nat
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Fintype.Pi
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity

/-!
# The Litt game model — M2 of the Litt game formalization

This module formalizes the finite-horizon game model underlying the Litt game
(Janson–Nica–Segert, arXiv:2503.19035v1).  Fix an alphabet size `q` and words
`A`, `B` (each a list over `Fin q`).  For a sequence `x : Fin n → Fin q` of
length `n`:

* `occCount q A x` is the number of (possibly overlapping) occurrences of the
  word `A` as a contiguous block of `x` — the raw material of the scores.
* `scoreOn q A x` is Alice's (resp. Bob's) score `S_n`, the count of occurrences
  of their word in the first `n` letters; `scoreDiff` is `S_n = #A − #B`.
* `winEvent q n A B`, `loseEvent q n A B`, `tieEvent q n A B` partition the
  `q ^ n` sequences according to who wins; `eventProb q n E` is the uniform
  (counting-measure) probability of an event.  No measure theory is used —
  everything is a ratio of finite cardinalities.

The words here are the same `Fin q` words as in M1 (`Theta.lean`): the M2
worked examples below reuse the M1 words `A = [0, 0]` (`θ_AA = 1/2`) and
`B = [0, 1]` (`θ_BB = 0`) over `Fin 2`.

Key structural lemma: `occCount_append`, which splits occurrences in a
concatenation `x ++ y` into occurrences wholly in `x`, wholly in `y`, and
boundary-crossing ones (`crossOcc`).  This is the counting backbone that the
chain bridge lemma (M3) and the fairness argument (M4) will build on.

Key symmetry: permuting the alphabet letters preserves occurrence counts and
hence win/lose/tie probabilities (`winProb_map_perm` etc.).
-/

namespace FragileProofAudit.LittGame

variable (q : ℕ)

/-- Number of (possibly overlapping) occurrences of the word `A` as a contiguous
    block of the list `x`.  Position `i` counts iff the length-`A.length` block
    of `x` starting at `i` equals `A`. -/
def occCount (A x : List (Fin q)) : ℕ :=
  ((Finset.range (x.length + 1 - A.length)).filter
    fun i => (x.drop i).take A.length = A).card

/-- Boundary-crossing occurrences: positions `i` with
    `x.length + 1 - A.length ≤ i < x.length` (so the block starts in `x` but
    reaches into `y`) at which `A` occurs in `x ++ y`. -/
def crossOcc (A x y : List (Fin q)) : Finset ℕ :=
  (Finset.Ico (x.length + 1 - A.length) x.length).filter fun i =>
    i + A.length ≤ x.length + y.length ∧ ((x ++ y).drop i).take A.length = A

/-- Occurrences in a concatenation split into three disjoint parts.  The
    hypothesis `1 ≤ A.length` rules out the empty word, whose occurrences
    would otherwise not be position-localized. -/
theorem occCount_append (A x y : List (Fin q)) (hA : 1 ≤ A.length) :
    occCount q A (x ++ y) =
      occCount q A x + occCount q A y + (crossOcc q A x y).card := by
  have hdrop1 : ∀ i : ℕ, i + A.length ≤ x.length →
      ((x ++ y).drop i).take A.length = (x.drop i).take A.length := by
    intro i hi
    have hle : i ≤ x.length := by omega
    have hlen_le : A.length ≤ (x.drop i).length := by
      rw [List.length_drop]; omega
    rw [List.drop_append_of_le_length hle, List.take_append,
      Nat.sub_eq_zero_of_le hlen_le, List.take_zero, List.append_nil]
  have hdrop2 : ∀ j : ℕ,
      ((x ++ y).drop (x.length + j)).take A.length = (y.drop j).take A.length := by
    intro j
    have h1 : (x ++ y).drop (x.length + j) = y.drop j := by
      rw [List.drop_append, List.drop_eq_nil_of_le (by omega),
        Nat.add_sub_cancel_left, List.nil_append]
    rw [h1]
  have hset : (Finset.range (x.length + y.length + 1 - A.length)).filter
        (fun i => ((x ++ y).drop i).take A.length = A) =
      ((Finset.range (x.length + 1 - A.length)).filter
        (fun i => ((x ++ y).drop i).take A.length = A)) ∪
      (((Finset.range (y.length + 1 - A.length)).filter
        (fun j => (y.drop j).take A.length = A)).image (fun j => j + x.length)) ∪
      ((Finset.Ico (x.length + 1 - A.length) x.length).filter
        (fun i => i + A.length ≤ x.length + y.length ∧
          ((x ++ y).drop i).take A.length = A)) := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_union,
      Finset.mem_image, Finset.mem_Ico]
    constructor
    · rintro ⟨hi, hpred⟩
      by_cases h1 : i < x.length + 1 - A.length
      · exact Or.inl (Or.inl ⟨h1, hpred⟩)
      · by_cases h2 : i < x.length
        · exact Or.inr ⟨⟨by omega, h2⟩, ⟨by omega, hpred⟩⟩
        · have h2' : x.length ≤ i := not_lt.mp h2
          refine Or.inl (Or.inr ⟨i - x.length, ⟨by omega, ?_⟩, by omega⟩)
          have hi_eq : (i - x.length) + x.length = i := Nat.sub_add_cancel h2'
          rw [← hi_eq, Nat.add_comm (i - x.length) x.length] at hpred
          rwa [hdrop2] at hpred
    · intro h
      cases h with
      | inl hPQ =>
        cases hPQ with
        | inl hP =>
          obtain ⟨h1, hpred⟩ := hP
          exact ⟨by omega, hpred⟩
        | inr hQ =>
          obtain ⟨j, hj⟩ := hQ
          obtain ⟨⟨hj1, hj2⟩, hjeq⟩ := hj
          have hjeq' : j + x.length = i := hjeq
          rw [← hjeq']
          refine ⟨by omega, ?_⟩
          rw [show j + x.length = x.length + j from Nat.add_comm _ _, hdrop2]
          exact hj2
      | inr hR =>
        obtain ⟨⟨h1, h2⟩, ⟨h3, hpred⟩⟩ := hR
        exact ⟨by omega, hpred⟩
  have hPx : ((Finset.range (x.length + 1 - A.length)).filter
        (fun i => ((x ++ y).drop i).take A.length = A)).card
      = occCount q A x := by
    unfold occCount
    congr 1
    apply Finset.filter_congr
    intro i hi
    rw [Finset.mem_range] at hi
    have hle : i + A.length ≤ x.length := by omega
    rw [hdrop1 i hle]
  have hocc : occCount q A (x ++ y) =
      ((Finset.range (x.length + y.length + 1 - A.length)).filter
        (fun i => ((x ++ y).drop i).take A.length = A)).card := by
    simp only [occCount, List.length_append]
  have d1 : Disjoint
      ((Finset.range (x.length + 1 - A.length)).filter
        (fun i => ((x ++ y).drop i).take A.length = A))
      ((((Finset.range (y.length + 1 - A.length)).filter
        (fun j => (y.drop j).take A.length = A)).image (fun j => j + x.length)) ∪
      ((Finset.Ico (x.length + 1 - A.length) x.length).filter
        (fun i => i + A.length ≤ x.length + y.length ∧
          ((x ++ y).drop i).take A.length = A))) := by
    rw [Finset.disjoint_union_right]
    constructor
    · rw [Finset.disjoint_left]
      intro i hi1 hi2
      rw [Finset.mem_filter, Finset.mem_range] at hi1
      rw [Finset.mem_image] at hi2
      obtain ⟨h1, -⟩ := hi1
      obtain ⟨j, -, hj_eq⟩ := hi2
      have hj_eq' : j + x.length = i := hj_eq
      omega
    · rw [Finset.disjoint_left]
      intro i hi1 hi2
      rw [Finset.mem_filter, Finset.mem_range] at hi1
      rw [Finset.mem_filter, Finset.mem_Ico] at hi2
      obtain ⟨h1, -⟩ := hi1
      obtain ⟨⟨hlo, -⟩, -, -⟩ := hi2
      omega
  have d2 : Disjoint
      (((Finset.range (y.length + 1 - A.length)).filter
        (fun j => (y.drop j).take A.length = A)).image (fun j => j + x.length))
      ((Finset.Ico (x.length + 1 - A.length) x.length).filter
        (fun i => i + A.length ≤ x.length + y.length ∧
          ((x ++ y).drop i).take A.length = A)) := by
    rw [Finset.disjoint_left]
    intro i hi1 hi2
    rw [Finset.mem_image] at hi1
    rw [Finset.mem_filter, Finset.mem_Ico] at hi2
    obtain ⟨j, -, hj_eq⟩ := hi1
    obtain ⟨⟨-, hlo2⟩, -, -⟩ := hi2
    have hj_eq' : j + x.length = i := hj_eq
    omega
  have hPy : ((Finset.range (y.length + 1 - A.length)).filter
        (fun j => (y.drop j).take A.length = A)).card
      = occCount q A y := rfl
  have hPc : ((Finset.Ico (x.length + 1 - A.length) x.length).filter
        (fun i => i + A.length ≤ x.length + y.length ∧
          ((x ++ y).drop i).take A.length = A)).card
      = (crossOcc q A x y).card := rfl
  rw [hocc, hset, Finset.union_assoc,
    Finset.card_union_of_disjoint d1, Finset.card_union_of_disjoint d2,
    Finset.card_image_of_injective _ (fun a b h => Nat.add_right_cancel h), hPx,
    hPy, hPc, add_assoc]

/-- Occurrence counts are preserved when the alphabet letters are permuted. -/
theorem occCount_map_perm (σ : Equiv.Perm (Fin q)) (A x : List (Fin q)) :
    occCount q (A.map σ) (x.map σ) = occCount q A x := by
  unfold occCount
  simp only [List.length_map]
  congr 1
  apply Finset.filter_congr
  intro i _
  have h1 : ((x.map σ).drop i).take A.length =
      (((x.drop i).take A.length).map σ) := by simp
  rw [h1]
  exact (List.map_injective_iff.mpr (Equiv.injective σ)).eq_iff

/-- A player's score `S_n`: occurrences of their word `A` in the first `n`
    letters of the sequence. -/
def scoreOn (A : List (Fin q)) {n : ℕ} (x : Fin n → Fin q) : ℕ :=
  occCount q A (List.ofFn x)

/-- Score difference `S_n = #A − #B` (paper §1): positive iff Alice wins. -/
def scoreDiff (A B : List (Fin q)) {n : ℕ} (x : Fin n → Fin q) : ℤ :=
  (scoreOn q A x : ℤ) - (scoreOn q B x : ℤ)

/-- Scores are preserved when the alphabet letters are permuted. -/
theorem scoreOn_map_perm (σ : Equiv.Perm (Fin q)) (A : List (Fin q)) {n : ℕ}
    (x : Fin n → Fin q) :
    scoreOn q (A.map σ) (fun i => σ (x i)) = scoreOn q A x := by
  unfold scoreOn
  have h : List.ofFn (fun i => σ (x i)) = (List.ofFn x).map σ := by
    rw [List.map_ofFn]
    rfl
  rw [h]
  exact occCount_map_perm q σ A (List.ofFn x)

/-- Reindexing a score through `σ⁻¹`: used to transport win events across a
    letter permutation. -/
theorem scoreOn_perm_key (σ : Equiv.Perm (Fin q)) (A : List (Fin q)) {n : ℕ}
    (z : Fin n → Fin q) :
    scoreOn q (A.map σ) z = scoreOn q A (fun i => σ.symm (z i)) := by
  have h1 := scoreOn_map_perm (q := q) σ A (fun i => σ.symm (z i))
  have h2 : (fun i => σ ((fun j => σ.symm (z j)) i)) = z := by
    funext i
    exact σ.apply_symm_apply (z i)
  rw [h2] at h1
  exact h1

/-- The win event: sequences where Alice's word scores strictly more than
    Bob's (`S_n > 0`). -/
def winEvent (n : ℕ) (A B : List (Fin q)) : Finset (Fin n → Fin q) :=
  Finset.univ.filter fun x => scoreOn q B x < scoreOn q A x

/-- The lose event (`S_n < 0`). -/
def loseEvent (n : ℕ) (A B : List (Fin q)) : Finset (Fin n → Fin q) :=
  Finset.univ.filter fun x => scoreOn q A x < scoreOn q B x

/-- The tie event (`S_n = 0`). -/
def tieEvent (n : ℕ) (A B : List (Fin q)) : Finset (Fin n → Fin q) :=
  Finset.univ.filter fun x => scoreOn q A x = scoreOn q B x

/-- Losing with `(A, B)` is winning with the roles swapped. -/
theorem loseEvent_eq_winEvent_swap (A B : List (Fin q)) {n : ℕ} :
    loseEvent q n A B = winEvent q n B A := rfl

/-- Pushing a sequence through a letter permutation is injective. -/
theorem permSeq_injective (σ : Equiv.Perm (Fin q)) {n : ℕ} :
    Function.Injective (fun x : Fin n → Fin q => fun i => σ (x i)) := by
  intro a b h
  funext i
  exact σ.injective (congrFun h i)

/-- The win event for permuted words is the image of the win event under the
    letter permutation. -/
theorem winEvent_image_perm (σ : Equiv.Perm (Fin q)) (A B : List (Fin q))
    {n : ℕ} :
    winEvent q n (A.map σ) (B.map σ) =
      (winEvent q n A B).image (fun x : Fin n → Fin q => fun i => σ (x i)) := by
  unfold winEvent
  ext z
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
  constructor
  · intro hz
    refine ⟨fun i => σ.symm (z i), ?_, funext fun i => σ.apply_symm_apply (z i)⟩
    rw [← scoreOn_perm_key q σ B z, ← scoreOn_perm_key q σ A z]
    exact hz
  · rintro ⟨y, hy, hyeq⟩
    rw [← hyeq, scoreOn_map_perm q σ B y, scoreOn_map_perm q σ A y]
    exact hy

/-- The tie event is likewise transported by a letter permutation. -/
theorem tieEvent_image_perm (σ : Equiv.Perm (Fin q)) (A B : List (Fin q))
    {n : ℕ} :
    tieEvent q n (A.map σ) (B.map σ) =
      (tieEvent q n A B).image (fun x : Fin n → Fin q => fun i => σ (x i)) := by
  unfold tieEvent
  ext z
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
  constructor
  · intro hz
    refine ⟨fun i => σ.symm (z i), ?_, funext fun i => σ.apply_symm_apply (z i)⟩
    rw [← scoreOn_perm_key q σ B z, ← scoreOn_perm_key q σ A z]
    exact hz
  · rintro ⟨y, hy, hyeq⟩
    rw [← hyeq, scoreOn_map_perm q σ B y, scoreOn_map_perm q σ A y]
    exact hy

/-- Win-event counts are preserved under letter permutations. -/
theorem card_winEvent_map_perm (σ : Equiv.Perm (Fin q)) (A B : List (Fin q))
    {n : ℕ} :
    (winEvent q n (A.map σ) (B.map σ)).card = (winEvent q n A B).card := by
  rw [winEvent_image_perm q σ A B,
    Finset.card_image_of_injective _ (permSeq_injective q σ)]

/-- Lose-event counts are preserved under letter permutations (via the swap). -/
theorem card_loseEvent_map_perm (σ : Equiv.Perm (Fin q)) (A B : List (Fin q))
    {n : ℕ} :
    (loseEvent q n (A.map σ) (B.map σ)).card = (loseEvent q n A B).card := by
  rw [loseEvent_eq_winEvent_swap, loseEvent_eq_winEvent_swap,
    card_winEvent_map_perm]

/-- Tie-event counts are preserved under letter permutations. -/
theorem card_tieEvent_map_perm (σ : Equiv.Perm (Fin q)) (A B : List (Fin q))
    {n : ℕ} :
    (tieEvent q n (A.map σ) (B.map σ)).card = (tieEvent q n A B).card := by
  rw [tieEvent_image_perm q σ A B,
    Finset.card_image_of_injective _ (permSeq_injective q σ)]

/-- Uniform (counting-measure) probability of an event over length-`n`
    sequences: `|E| / q ^ n`.  This is the finite-horizon game probability;
    no measure theory is needed. -/
def eventProb (n : ℕ) (E : Finset (Fin n → Fin q)) : ℚ :=
  E.card / (q : ℚ) ^ n

/-- Alice's win probability `P(S_n > 0)`; Bob's; the tie probability. -/
def winProb (n : ℕ) (A B : List (Fin q)) : ℚ :=
  eventProb q n (winEvent q n A B)

def loseProb (n : ℕ) (A B : List (Fin q)) : ℚ :=
  eventProb q n (loseEvent q n A B)

def tieProb (n : ℕ) (A B : List (Fin q)) : ℚ :=
  eventProb q n (tieEvent q n A B)

/-- There are `q ^ n` sequences of length `n` over `Fin q`. -/
theorem card_univ_seq {n : ℕ} :
    (Finset.univ : Finset (Fin n → Fin q)).card = q ^ n := by
  rw [Finset.card_univ, Fintype.card_fun, Fintype.card_fin, Fintype.card_fin]

theorem eventProb_nonneg (n : ℕ) (E : Finset (Fin n → Fin q)) :
    0 ≤ eventProb q n E := by
  unfold eventProb
  positivity

theorem eventProb_univ (n : ℕ) (hq : 1 ≤ q) :
    eventProb q n Finset.univ = 1 := by
  unfold eventProb
  have hq' : (q : ℚ) ≠ 0 := by exact_mod_cast (by omega : q ≠ 0)
  rw [card_univ_seq, Nat.cast_pow, div_self (pow_ne_zero n hq')]

/-- Win, lose, and tie partition the whole sample space. -/
theorem win_lose_tie_partition (n : ℕ) (A B : List (Fin q)) :
    winEvent q n A B ∪ loseEvent q n A B ∪ tieEvent q n A B = Finset.univ := by
  unfold winEvent loseEvent tieEvent
  ext x
  simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro _
    trivial
  · intro _
    rcases lt_trichotomy (scoreOn q A x) (scoreOn q B x) with h | h | h
    · exact Or.inl (Or.inr h)
    · exact Or.inr h
    · exact Or.inl (Or.inl h)

theorem disjoint_win_lose (n : ℕ) (A B : List (Fin q)) :
    Disjoint (winEvent q n A B) (loseEvent q n A B) := by
  unfold winEvent loseEvent
  rw [Finset.disjoint_left]
  intro x hx1 hx2
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx1 hx2
  omega

theorem disjoint_win_tie (n : ℕ) (A B : List (Fin q)) :
    Disjoint (winEvent q n A B) (tieEvent q n A B) := by
  unfold winEvent tieEvent
  rw [Finset.disjoint_left]
  intro x hx1 hx2
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx1 hx2
  omega

theorem disjoint_lose_tie (n : ℕ) (A B : List (Fin q)) :
    Disjoint (loseEvent q n A B) (tieEvent q n A B) := by
  unfold loseEvent tieEvent
  rw [Finset.disjoint_left]
  intro x hx1 hx2
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx1 hx2
  omega

/-- The three probabilities sum to one. -/
theorem prob_win_lose_tie (n : ℕ) (A B : List (Fin q)) (hq : 1 ≤ q) :
    winProb q n A B + loseProb q n A B + tieProb q n A B = 1 := by
  have hq' : (q : ℚ) ≠ 0 := by exact_mod_cast (by omega : q ≠ 0)
  have hcard : (winEvent q n A B).card + (loseEvent q n A B).card +
      (tieEvent q n A B).card = q ^ n := by
    have hpart := win_lose_tie_partition q n A B
    have d12 := disjoint_win_lose q n A B
    have d13 := disjoint_win_tie q n A B
    have d23 := disjoint_lose_tie q n A B
    have h12 : Disjoint (winEvent q n A B ∪ loseEvent q n A B)
        (tieEvent q n A B) :=
      (Finset.disjoint_union_left).mpr ⟨d13, d23⟩
    have h2 : (winEvent q n A B ∪ loseEvent q n A B ∪
        tieEvent q n A B).card = q ^ n := by
      rw [hpart, card_univ_seq]
    rwa [Finset.card_union_of_disjoint h12,
      Finset.card_union_of_disjoint d12] at h2
  unfold winProb loseProb tieProb eventProb
  rw [← add_div, ← add_div, ← Nat.cast_add, ← Nat.cast_add, hcard,
    Nat.cast_pow, div_self (pow_ne_zero n hq')]

/-- Win probabilities are preserved under letter permutations. -/
theorem winProb_map_perm (σ : Equiv.Perm (Fin q)) (A B : List (Fin q))
    {n : ℕ} :
    winProb q n (A.map σ) (B.map σ) = winProb q n A B := by
  unfold winProb eventProb
  rw [card_winEvent_map_perm]

/-- Lose/tie probabilities are preserved under letter permutations. -/
theorem loseProb_map_perm (σ : Equiv.Perm (Fin q)) (A B : List (Fin q))
    {n : ℕ} :
    loseProb q n (A.map σ) (B.map σ) = loseProb q n A B := by
  unfold loseProb eventProb
  rw [card_loseEvent_map_perm]

theorem tieProb_map_perm (σ : Equiv.Perm (Fin q)) (A B : List (Fin q))
    {n : ℕ} :
    tieProb q n (A.map σ) (B.map σ) = tieProb q n A B := by
  unfold tieProb eventProb
  rw [card_tieEvent_map_perm]

/-! ## Worked examples

Concrete occurrence counts and scores for the M1 words over `Fin 2`:
`A = [0, 0]` ("HH", `θ_AA = 1/2`) and `B = [0, 1]` ("HT", `θ_BB = 0`).
All examples are kernel-checked; the `decide` steps evaluate concrete
`List (Fin 2)` equalities and the `Finset.filter` positions are pinned down
by explicit set-equality lemmas first (kernel `decide` is stuck on filters). -/

/-- `HH` occurs twice (overlapping) in `HHH`. -/
theorem occCount_HH_HHH : occCount 2 [0, 0] [0, 0, 0] = 2 := by
  have hlen1 : ([0, 0, 0] : List (Fin 2)).length = 3 := rfl
  have hlen2 : ([0, 0] : List (Fin 2)).length = 2 := rfl
  have hset : ((Finset.range (3 + 1 - 2)).filter
      (fun i : ℕ => (([0, 0, 0] : List (Fin 2)).drop i).take 2 = [0, 0])) =
      ({0, 1} : Finset ℕ) := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_insert,
      Finset.mem_singleton]
    constructor
    · rintro ⟨h1, -⟩
      omega
    · rintro (rfl | rfl)
      · exact ⟨by norm_num, by decide⟩
      · exact ⟨by norm_num, by decide⟩
  unfold occCount
  rw [hlen1, hlen2, hset, Finset.card_pair (by norm_num)]

/-- `HT` occurs exactly once in `HTH`. -/
theorem occCount_HT_HTH : occCount 2 [0, 1] [0, 1, 0] = 1 := by
  have hlen1 : ([0, 1, 0] : List (Fin 2)).length = 3 := rfl
  have hlen2 : ([0, 1] : List (Fin 2)).length = 2 := rfl
  have hset : ((Finset.range (3 + 1 - 2)).filter
      (fun i : ℕ => (([0, 1, 0] : List (Fin 2)).drop i).take 2 = [0, 1])) =
      ({0} : Finset ℕ) := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton]
    constructor
    · rintro ⟨h1, h2⟩
      by_cases hi : i = 0
      · exact hi
      · have hi1 : i = 1 := by omega
        subst hi1
        have hfalse : ¬ (([0, 1, 0] : List (Fin 2)).drop 1).take 2 =
            ([0, 1] : List (Fin 2)) := by decide
        exact absurd h2 hfalse
    · rintro rfl
      exact ⟨by norm_num, by decide⟩
  unfold occCount
  rw [hlen1, hlen2, hset, Finset.card_singleton]

/-- `HH` does not occur in `HT`. -/
theorem occCount_HH_HT : occCount 2 [0, 0] [0, 1] = 0 := by
  have hlen1 : ([0, 1] : List (Fin 2)).length = 2 := rfl
  have hlen2 : ([0, 0] : List (Fin 2)).length = 2 := rfl
  have hset : ((Finset.range (2 + 1 - 2)).filter
      (fun i : ℕ => (([0, 1] : List (Fin 2)).drop i).take 2 = [0, 0])) = ∅ := by
    rw [Finset.eq_empty_iff_forall_notMem]
    intro i hi
    simp only [Finset.mem_filter, Finset.mem_range] at hi
    obtain ⟨h1, h2⟩ := hi
    have hi0 : i = 0 := by omega
    subst hi0
    have hfalse : ¬ (([0, 1] : List (Fin 2)).drop 0).take 2 =
        ([0, 0] : List (Fin 2)) := by decide
    exact hfalse h2
  unfold occCount
  rw [hlen1, hlen2, hset, Finset.card_empty]

/-- `HT` does not occur in `HHH`. -/
theorem occCount_HT_HHH : occCount 2 [0, 1] [0, 0, 0] = 0 := by
  have hlen1 : ([0, 0, 0] : List (Fin 2)).length = 3 := rfl
  have hlen2 : ([0, 1] : List (Fin 2)).length = 2 := rfl
  have hset : ((Finset.range (3 + 1 - 2)).filter
      (fun i : ℕ => (([0, 0, 0] : List (Fin 2)).drop i).take 2 = [0, 1])) = ∅ := by
    rw [Finset.eq_empty_iff_forall_notMem]
    intro i hi
    simp only [Finset.mem_filter, Finset.mem_range] at hi
    obtain ⟨h1, h2⟩ := hi
    have hfalse0 : ¬ (([0, 0, 0] : List (Fin 2)).drop 0).take 2 =
        ([0, 1] : List (Fin 2)) := by decide
    have hfalse1 : ¬ (([0, 0, 0] : List (Fin 2)).drop 1).take 2 =
        ([0, 1] : List (Fin 2)) := by decide
    by_cases hi0 : i = 0
    · subst hi0
      exact hfalse0 h2
    · have hi1 : i = 1 := by omega
      subst hi1
      exact hfalse1 h2
  unfold occCount
  rw [hlen1, hlen2, hset, Finset.card_empty]

/-- Score of `HH` on the constant sequence `HHH`: 2. -/
theorem scoreOn_HH_ex :
    scoreOn 2 [0, 0] (fun _ : Fin 3 => (0 : Fin 2)) = 2 := by
  unfold scoreOn
  have h : List.ofFn (fun _ : Fin 3 => (0 : Fin 2)) =
      ([0, 0, 0] : List (Fin 2)) := by decide
  rw [h]
  exact occCount_HH_HHH

/-- Score of `HT` on `HTH`: 1. -/
theorem scoreOn_HT_ex :
    scoreOn 2 [0, 1] (fun i : Fin 3 => if i.val = 1 then (1 : Fin 2) else 0) = 1 := by
  unfold scoreOn
  have h : List.ofFn (fun i : Fin 3 => (if i.val = 1 then (1 : Fin 2) else 0)) =
      ([0, 1, 0] : List (Fin 2)) := by decide
  rw [h]
  exact occCount_HT_HTH

/-- Score difference `S_3 = #HH − #HT` on `HHH`: `2 − 0 = 2`. -/
theorem scoreDiff_ex :
    scoreDiff 2 [0, 0] [0, 1] (fun _ : Fin 3 => (0 : Fin 2)) = 2 := by
  have hA : scoreOn 2 [0, 0] (fun _ : Fin 3 => (0 : Fin 2)) = 2 := scoreOn_HH_ex
  have hB : scoreOn 2 [0, 1] (fun _ : Fin 3 => (0 : Fin 2)) = 0 := by
    unfold scoreOn
    have h : List.ofFn (fun _ : Fin 3 => (0 : Fin 2)) =
        ([0, 0, 0] : List (Fin 2)) := by decide
    rw [h]
    exact occCount_HT_HHH
  unfold scoreDiff
  rw [hA, hB]
  norm_num

end FragileProofAudit.LittGame
