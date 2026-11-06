module

public import CFSGCorollary.LieType.Twisted.TwistedD.Basic
import CFSG.LieType.Universal.Spin.Twisted.Weyl

/-!
# The twisted Coxeter element of `²D_r` permutes the short root groups

We compute how the simple Weyl representatives `ω_k` and the twisted Coxeter element
`g = ω₀ ⋯ ω_ℓ` of `Spin⁻_{2r}(K)` act on the short root elements `xᵢₛ(t)`.

* For `k + 1 < r - 1`, `ω_k xᵢₛ(t) ω_k⁻¹ = x_{σ i, s}(ε t)` with `σ = swap k (k + 1)`, `ε = -1`
  if `i = k` and `ε = 1` otherwise.
* For the last index `k`, `ω_k xᵢₛ(t) ω_k⁻¹` is `x_{k,!s}(star t)` if `i = k` and
  `x_{i,s}(-star t)` otherwise.
* With `σ(i, s) = (i + 1, s)` for `i < ℓ` and `σ(ℓ, s) = (0, !s)`,
  `g xᵢₛ(t) g⁻¹ = x_{σ(i,s)}(star t)`. Since `σ` acts transitively on the labels, every short
  root group is conjugate to `X_{ℓ,true}` by a power of `g`.

## Main results

* `CFSGCorollary.TwistedD.coxeterElement_conj_shortRootElement`
* `CFSGCorollary.TwistedD.exists_pow_coxeterElement_conj_shortRootGroup`
-/

@[expose] public section

open CFSG.LieType.Universal.Spin CFSG.LieType.Universal.Spin.Twisted

namespace CFSGCorollary.TwistedD

variable (r : ℕ) {K : Type} [Field K] {b c : K} (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0)

/-! ### Simple Weyl representatives on short root groups -/

theorem minusWeyl_conj_shortRootElement_of_lt {k : Fin (r - 1)} (hk : k.val + 1 < r - 1)
    (i : Fin (r - 1)) (s : Bool) (t : ShortField b c) :
    minusWeyl r hirr k * shortRootElement r hirr i s t * (minusWeyl r hirr k)⁻¹ =
      shortRootElement r hirr (Equiv.swap k ⟨k.val + 1, hk⟩ i) s (if i = k then -t else t) := by
  have h1 := minusWeyl_of_lt (n := r) (hirr := hirr) hk
  have h2 := longWeyl_conj_twShortRoot (n := r) (hirr := hirr)
    (succ_ne_of_lt (n := r) (k := k) hk) true false i s (fieldCoord t)
  rw [longWeylBool_true_false] at h2
  unfold shortRootElement
  rw [h1]
  refine h2.trans ?_
  congr 2
  by_cases hik : i = k
  · simp [hik, longWeylSign, fieldCoord_neg]
  · simp [hik, longWeylSign]

theorem minusWeyl_conj_shortRootElement_of_not_lt {k : Fin (r - 1)} (hk : ¬k.val + 1 < r - 1)
    (i : Fin (r - 1)) (s : Bool) (t : ShortField b c) :
    minusWeyl r hirr k * shortRootElement r hirr i s t * (minusWeyl r hirr k)⁻¹ =
      if i = k then shortRootElement r hirr i (!s) (star t)
      else shortRootElement r hirr i s (-star t) := by
  have h1 := minusWeyl_of_not_lt (n := r) (hirr := hirr) hk
  have h2 := shortWeyl_conj_twShortRoot (n := r) (hirr := hirr) k i s (fieldCoord t)
  unfold shortRootElement
  rw [h1, h2, planeRefl_planeOne_fieldCoord t]
  by_cases hik : i = k
  · simp only [hik, ↓reduceIte]
    subst hik
    simp [longWeylSign, shortWeylBool]
  · simp only [hik, ↓reduceIte]
    simp [longWeylSign, shortWeylBool, hik, fieldCoord_neg]

/-- Conjugating the range of `φ` by `ω` gives the range of `ψ` once it is known on field
coordinates, with a surjective parameter change. -/
theorem map_conj_range_eq {G : Type*} [Group G] (ω : G)
    (φ ψ : Multiplicative (Fin 2 → K) →* G) (f : ShortField b c → ShortField b c)
    (h1 : ∀ t, ω * φ (.ofAdd (fieldCoord t)) * ω⁻¹ = ψ (.ofAdd (fieldCoord (f t))))
    (h2 : Function.Surjective f) :
    φ.range.map (MulAut.conj ω).toMonoidHom = ψ.range := by
  ext x
  constructor
  · rintro ⟨y, ⟨z, rfl⟩, rfl⟩
    obtain ⟨t, ht⟩ := exists_fieldCoord_eq (b := b) (c := c) z.toAdd
    have : z = .ofAdd (fieldCoord t) := by rw [ht]; rfl
    subst this
    exact ⟨_, (h1 t).symm⟩
  · rintro ⟨z, rfl⟩
    obtain ⟨t, ht⟩ := exists_fieldCoord_eq (b := b) (c := c) z.toAdd
    have : z = .ofAdd (fieldCoord t) := by rw [ht]; rfl
    subst this
    obtain ⟨t', rfl⟩ := h2 t
    exact ⟨_, ⟨_, rfl⟩, h1 t'⟩

/-! ### The twisted Coxeter element permutes the short root groups -/

/-- The permutation `σ` of the labels `(i, s)` induced by the twisted Coxeter element. -/
def coxeterLabel (hr : 4 ≤ r) (i : Fin (r - 1)) (s : Bool) : Fin (r - 1) × Bool :=
  if h : i.val < r - 2 then (⟨i.val + 1, by omega⟩, s) else (⟨0, by omega⟩, !s)

/-- Partial products `ω₀ ⋯ ω_{m-1}`. -/
noncomputable def coxeterPartialProd (m : ℕ) : spinGroup (quadMinus r K b c) :=
  ((List.range m).map fun k ↦ if h : k < r - 1 then minusWeyl r hirr ⟨k, h⟩ else 1).prod

theorem coxeterPartialProd_succ (m : ℕ) (h : m < r - 1) :
    coxeterPartialProd r hirr m.succ = coxeterPartialProd r hirr m * minusWeyl r hirr ⟨m, h⟩ := by
  simp [coxeterPartialProd, List.range_succ, h]

theorem coxeterElement_eq_coxeterPartialProd :
    coxeterElement r hirr = coxeterPartialProd r hirr (r - 1) := by
  unfold coxeterElement coxeterPartialProd
  have hfr : (List.finRange (r - 1)).map Fin.val = List.range (r - 1) :=
    List.ext_getElem (by simp) (by simp)
  rw [List.ofFn_eq_map, ← hfr, List.map_map]
  congr 1
  apply List.map_congr_left
  intro k _
  simp [k.2]

theorem coxeterPartialProd_conj_shortRootElement (m : ℕ) (hm : m < r - 1) (i : Fin (r - 1))
    (s : Bool) (t : ShortField b c) :
    ((h : i.val < m) → coxeterPartialProd r hirr m * shortRootElement r hirr i s t *
        (coxeterPartialProd r hirr m)⁻¹ = shortRootElement r hirr ⟨i.val + 1, by omega⟩ s (-t)) ∧
    (i.val = m → coxeterPartialProd r hirr m * shortRootElement r hirr i s t *
        (coxeterPartialProd r hirr m)⁻¹ = shortRootElement r hirr ⟨0, by omega⟩ s t) ∧
    (m < i.val → coxeterPartialProd r hirr m * shortRootElement r hirr i s t *
        (coxeterPartialProd r hirr m)⁻¹ = shortRootElement r hirr i s t) := by
  induction m generalizing i s t with
  | zero =>
    have : coxeterPartialProd r hirr 0 = 1 := by simp [coxeterPartialProd]
    refine ⟨by omega, fun h ↦ ?_, fun _ ↦ by simp [this]⟩
    have : i = ⟨0, by omega⟩ := Fin.ext h
    subst this
    simp [coxeterPartialProd]
  | succ m ih =>
    have hm' : m < r - 1 := by omega
    have key : ∀ y : spinGroup (quadMinus r K b c),
        coxeterPartialProd r hirr m.succ * y * (coxeterPartialProd r hirr m.succ)⁻¹ =
        coxeterPartialProd r hirr m * (minusWeyl r hirr ⟨m, hm'⟩ * y *
          (minusWeyl r hirr ⟨m, hm'⟩)⁻¹) * (coxeterPartialProd r hirr m)⁻¹ := by
      intro y
      rw [coxeterPartialProd_succ r hirr m hm']
      group
    have hk : (⟨m, hm'⟩ : Fin (r - 1)).val + 1 < r - 1 := by simpa using hm
    have step := minusWeyl_conj_shortRootElement_of_lt r hirr hk i s t
    have hne : ∀ j : Fin (r - 1), j.val ≠ m → j.val ≠ m + 1 →
        Equiv.swap (⟨m, hm'⟩ : Fin (r - 1)) ⟨m + 1, hk⟩ j = j := by
      intro j h1 h2
      apply Equiv.swap_apply_of_ne_of_ne
      · intro h'
        exact h1 (congrArg Fin.val h')
      · intro h'
        exact h2 (congrArg Fin.val h')
    refine ⟨fun h ↦ ?_, fun h ↦ ?_, fun h ↦ ?_⟩
    · rcases Nat.lt_succ_iff_lt_or_eq.1 h with h | h
      · have e2 : ¬ i = ⟨m, hm'⟩ := fun h' ↦ by
          have := congrArg Fin.val h'
          simp at this
          omega
        rw [key, step, hne i (by omega) (by omega), ite_eq_right e2]
        exact (ih hm' i s t).1 h
      · have hi : i = ⟨m, hm'⟩ := Fin.ext h
        subst hi
        rw [key, step, Equiv.swap_apply_left, ite_eq_left rfl]
        rw [(ih hm' ⟨m + 1, hk⟩ s (-t)).2.2 (by simp)]
    · have hi : i = ⟨m + 1, hk⟩ := Fin.ext (by simpa using h)
      subst hi
      have e2 : ¬ (⟨m + 1, hk⟩ : Fin (r - 1)) = ⟨m, hm'⟩ := fun h' ↦ by
        have := congrArg Fin.val h'
        simp at this
      rw [key, step, Equiv.swap_apply_right, ite_eq_right e2]
      exact (ih hm' ⟨m, hm'⟩ s t).2.1 rfl
    · have e2 : ¬ i = ⟨m, hm'⟩ := fun h' ↦ by
        have := congrArg Fin.val h'
        simp at this
        omega
      rw [key, step, hne i (by omega) (by omega), ite_eq_right e2]
      exact (ih hm' i s t).2.2 (by omega)

theorem coxeterElement_eq_coxeterPartialProd_mul (hr : 4 ≤ r) :
    coxeterElement r hirr =
      coxeterPartialProd r hirr (r - 2) * minusWeyl r hirr (lastIndex r hr) := by
  have := coxeterPartialProd_succ r hirr (r - 2) (by omega)
  rw [show (r - 2).succ = r - 1 by omega] at this
  rw [coxeterElement_eq_coxeterPartialProd, this]
  rfl

/-- `g xᵢₛ(t) g⁻¹ = x_{σ(i,s)}(star t)`. -/
theorem coxeterElement_conj_shortRootElement (hr : 4 ≤ r) (i : Fin (r - 1)) (s : Bool)
    (t : ShortField b c) :
    coxeterElement r hirr * shortRootElement r hirr i s t * (coxeterElement r hirr)⁻¹ =
      shortRootElement r hirr (coxeterLabel r hr i s).1 (coxeterLabel r hr i s).2 (star t) := by
  have hk : ¬ (lastIndex r hr).val + 1 < r - 1 := by simp [lastIndex]; omega
  have step := minusWeyl_conj_shortRootElement_of_not_lt r hirr hk i s t
  have key : coxeterElement r hirr * shortRootElement r hirr i s t * (coxeterElement r hirr)⁻¹ =
      coxeterPartialProd r hirr (r - 2) * (minusWeyl r hirr (lastIndex r hr) *
        shortRootElement r hirr i s t * (minusWeyl r hirr (lastIndex r hr))⁻¹) *
        (coxeterPartialProd r hirr (r - 2))⁻¹ := by
    rw [coxeterElement_eq_coxeterPartialProd_mul r hirr hr]
    group
  rw [key, step]
  have hm : r - 2 < r - 1 := by omega
  by_cases hi : i = lastIndex r hr
  · simp only [hi, ↓reduceIte]
    subst hi
    rw [(coxeterPartialProd_conj_shortRootElement r hirr (r - 2) hm (lastIndex r hr) (!s)
      (star t)).2.1 rfl]
    simp [coxeterLabel, lastIndex]
  · have hv : i.val < r - 2 := by
      have : i.val ≠ r - 2 := fun h ↦ hi (Fin.ext h)
      have := i.2
      omega
    simp only [hi, ↓reduceIte]
    rw [(coxeterPartialProd_conj_shortRootElement r hirr (r - 2) hm i s (-star t)).1 hv, neg_neg]
    simp [coxeterLabel, hv]

theorem map_conj_coxeterElement_shortRootGroup (hr : 4 ≤ r) (i : Fin (r - 1)) (s : Bool) :
    (shortRootGroup r hirr i s).map (MulAut.conj (coxeterElement r hirr)).toMonoidHom =
      shortRootGroup r hirr (coxeterLabel r hr i s).1 (coxeterLabel r hr i s).2 := by
  refine map_conj_range_eq (b := b) (c := c) _ _ _ (fun t ↦ star t) (fun t ↦ ?_)
    (fun t ↦ ⟨star t, star_star t⟩)
  exact coxeterElement_conj_shortRootElement r hirr hr i s t

theorem coxeterElement_conj_shortRootElement_secondLastIndex (hr : 4 ≤ r) (t : ShortField b c) :
    coxeterElement r hirr * shortRootElement r hirr (secondLastIndex r hr) true t *
        (coxeterElement r hirr)⁻¹ =
      shortRootElement r hirr (lastIndex r hr) true (star t) := by
  rw [coxeterElement_conj_shortRootElement r hirr hr]
  have hv : (secondLastIndex r hr).val < r - 2 := by simp [secondLastIndex]; omega
  have e : coxeterLabel r hr (secondLastIndex r hr) true = (lastIndex r hr, true) := by
    simp only [coxeterLabel, hv, ↓reduceDIte]
    refine Prod.ext (Fin.ext ?_) rfl
    simp [secondLastIndex, lastIndex]
    omega
  rw [e]

/-- `coxeterLabel` on pairs. -/
def coxeterLabelPair (hr : 4 ≤ r) (p : Fin (r - 1) × Bool) : Fin (r - 1) × Bool :=
  coxeterLabel r hr p.1 p.2

theorem coxeterLabelPair_apply (hr : 4 ≤ r) (p : Fin (r - 1) × Bool) :
    coxeterLabelPair r hr p = coxeterLabel r hr p.1 p.2 := rfl

theorem iterate_coxeterLabelPair_zero (hr : 4 ≤ r) (s : Bool) (k : ℕ) (hk : k ≤ r - 2) :
    (coxeterLabelPair r hr)^[k] (⟨0, by omega⟩, s) = (⟨k, by omega⟩, s) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [Function.iterate_succ_apply', ih (by omega)]
    simp only [coxeterLabelPair, coxeterLabel, show k < r - 2 by omega, ↓reduceDIte]

theorem map_conj_pow_coxeterElement_shortRootGroup (hr : 4 ≤ r) (p : Fin (r - 1) × Bool)
    (j : ℕ) :
    (shortRootGroup r hirr p.1 p.2).map (MulAut.conj (coxeterElement r hirr ^ j)).toMonoidHom =
      shortRootGroup r hirr ((coxeterLabelPair r hr)^[j] p).1
        ((coxeterLabelPair r hr)^[j] p).2 := by
  induction j with
  | zero => ext x; simp
  | succ j ih =>
    rw [Function.iterate_succ_apply', coxeterLabelPair_apply,
      ← map_conj_coxeterElement_shortRootGroup r hirr hr, ← ih, Subgroup.map_map]
    congr 1
    ext x
    simp [pow_succ']

/-- Every short root group is a conjugate `gʲ X_{ℓ,true} g⁻ʲ`. -/
theorem exists_pow_coxeterElement_conj_shortRootGroup (hr : 4 ≤ r) (i : Fin (r - 1))
    (s : Bool) :
    ∃ j : ℕ, shortRootGroup r hirr i s =
      (shortRootGroup r hirr (lastIndex r hr) true).map
        (MulAut.conj (coxeterElement r hirr ^ j)).toMonoidHom := by
  have hi := i.2
  have h1 := iterate_coxeterLabelPair_zero r hr
  have hstart : coxeterLabelPair r hr (lastIndex r hr, true) = (⟨0, by omega⟩, false) := by
    simp [coxeterLabelPair, coxeterLabel, lastIndex]
  have hlast (b : Bool) :
      coxeterLabelPair r hr (⟨r - 2, by omega⟩, b) = (⟨0, by omega⟩, !b) := by
    simp [coxeterLabelPair, coxeterLabel]
  cases s
  · refine ⟨i.val + 1, ?_⟩
    rw [map_conj_pow_coxeterElement_shortRootGroup r hirr hr (lastIndex r hr, true),
      Function.iterate_succ_apply, hstart, h1 false i.val (by omega)]
  · refine ⟨i.val + ((r - 2) + 1) + 1, ?_⟩
    have e : (coxeterLabelPair r hr)^[(r - 2) + 1] (⟨0, by omega⟩, false) =
        (⟨0, by omega⟩, true) := by
      rw [Function.iterate_succ_apply', h1 false (r - 2) le_rfl, hlast]
      rfl
    rw [map_conj_pow_coxeterElement_shortRootGroup r hirr hr (lastIndex r hr, true),
      Function.iterate_add_apply, Function.iterate_succ_apply, hstart,
      Function.iterate_add_apply, Function.iterate_zero, id_eq, e, h1 true i.val (by omega)]

end CFSGCorollary.TwistedD
