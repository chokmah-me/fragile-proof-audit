module

public import CFSGCorollary.LieType.LambdaRootGroup.Basic

@[expose] public section

/-!
# λ-root groups with a spanning scalar

Variants of Lemmas 3.9 and 3.10 of [Steinberg1962] for λ-root groups over `L` in which the torus
element acts by a scalar `k` whose powers span `L` additively (`IsSpanningScalar`), rather than by
a generator of `Lˣ`. This is the situation in the unitary groups, where `L = GF(q²)` and the
available scalars need not generate `Lˣ`.

## Main results

* `CFSGCorollary.isSpanningScalar_of_le_orderOf`: if `|L| = Q²` and `k` has order at least `Q`,
  then the powers of `k` span `L`.
* `CFSGCorollary.LambdaRootGroup.le_closure_pair_of_isSpanningScalar`: if `λ(x) ≠ 0` then
  `X ≤ ⟨d, x⟩`.
* `CFSGCorollary.LambdaRootGroup.le_closure_pair_mul_of_isSpanningScalar`: with `d₁ = g d g⁻¹`
  commuting with `d`, `⟨d, u g⟩` contains `X` and `g`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

namespace CFSGCorollary

/-- The powers of `k` span `L` as an additive group. -/
def IsSpanningScalar {L : Type*} [Field L] (k : L) : Prop :=
  AddSubgroup.closure (Set.range fun j : ℕ ↦ k ^ j) = ⊤

/-- If `|L| = Q²` and `k ≠ 0` has order at least `Q`, then the powers of `k` span `L`: they span
a subfield, which has at most `Q` elements unless it is all of `L`. -/
theorem isSpanningScalar_of_le_orderOf {L : Type*} [Field L] [Finite L] {Q : ℕ} (hQ : 2 ≤ Q)
    (hL : Nat.card L = Q ^ 2) {k : L} (hk : k ≠ 0) (hord : Q ≤ orderOf k) :
    IsSpanningScalar k := by
  classical
  set A := AddSubgroup.closure (Set.range fun j : ℕ ↦ k ^ j) with hA
  have hmul : ∀ a ∈ A, ∀ b ∈ A, a * b ∈ A := by
    intro a ha b hb
    induction ha using AddSubgroup.closure_induction with
    | mem x hx =>
      obtain ⟨i, rfl⟩ := hx
      induction hb using AddSubgroup.closure_induction with
      | mem y hy =>
        obtain ⟨j, rfl⟩ := hy
        exact AddSubgroup.subset_closure ⟨i + j, by simp [pow_add]⟩
      | zero => simp
      | add y z _ _ hy hz => rw [mul_add]; exact add_mem hy hz
      | neg y _ hy => rw [mul_neg]; exact neg_mem hy
    | zero => simp
    | add x y _ _ hx hy => rw [add_mul]; exact add_mem hx hy
    | neg x _ hx => rw [neg_mul]; exact neg_mem hx
  let S : Subring L :=
    { carrier := A
      mul_mem' := fun {a b} ha hb ↦ hmul a ha b hb
      one_mem' := AddSubgroup.subset_closure ⟨0, by simp⟩
      add_mem' := fun {a b} ha hb ↦ add_mem ha hb
      zero_mem' := zero_mem A
      neg_mem' := fun {a} ha ↦ neg_mem ha }
  have : Fintype L := Fintype.ofFinite L
  let K : Subfield L :=
    { S with
      inv_mem' := by
        intro a ha
        by_cases h0 : a = 0
        · simp [h0]
        · have := FiniteField.pow_card_sub_one_eq_one a h0
          have e : a⁻¹ = a ^ (Fintype.card L - 2) := by
            have hc : 2 ≤ Fintype.card L := Fintype.one_lt_card (α := L)
            rw [inv_eq_iff_eq_inv]
            apply eq_inv_of_mul_eq_one_left
            rw [← pow_succ', show Fintype.card L - 2 + 1 = Fintype.card L - 1 by omega]
            exact this
          rw [e]
          exact S.pow_mem ha _ }
  have : Fintype K := Fintype.ofFinite K
  have hcard := Module.card_eq_pow_finrank (K := K) (V := L)
  have hLcard : Fintype.card L = Q ^ 2 := by rw [← hL, Nat.card_eq_fintype_card]
  have hQ2 : 4 ≤ Q ^ 2 := by nlinarith
  have hkK : k ∈ K := AddSubgroup.subset_closure ⟨1, by simp⟩
  rcases Nat.lt_or_ge (Module.finrank K L) 2 with hd | hd
  · have hd1 : Module.finrank K L = 1 := by
      rcases Nat.lt_or_ge 0 (Module.finrank K L) with h | h
      · omega
      · exfalso
        rw [show Module.finrank K L = 0 by omega] at hcard
        simp at hcard
        omega
    rw [hd1, pow_one] at hcard
    have hb : Function.Bijective (Subtype.val : K → L) :=
      (Fintype.bijective_iff_injective_and_card _).2 ⟨Subtype.val_injective, hcard.symm⟩
    rw [IsSpanningScalar, ← hA]
    ext x
    simp only [AddSubgroup.mem_top, iff_true]
    obtain ⟨y, rfl⟩ := hb.2 x
    exact y.2
  · exfalso
    have h2 : Fintype.card K ^ 2 ≤ Q ^ 2 := by
      rw [← hLcard, hcard]; exact Nat.pow_le_pow_right Fintype.card_pos hd
    have h3 : Fintype.card K ≤ Q := by
      by_contra h; push Not at h; nlinarith
    have hne : (⟨k, hkK⟩ : K) ≠ 0 := fun h ↦ hk (congrArg Subtype.val h)
    have hp := FiniteField.pow_card_sub_one_eq_one (⟨k, hkK⟩ : K) hne
    have hp' : k ^ (Fintype.card K - 1) = 1 := by
      have := congrArg Subtype.val hp; simpa using this
    have hpos : 0 < Fintype.card K - 1 := by
      have := Fintype.one_lt_card (α := K); omega
    have := orderOf_le_of_pow_eq_one hpos hp'
    omega

namespace LambdaRootGroup

variable {G L : Type*} [Group G] [Field L] [Finite L]

/-- Variant of `LambdaRootGroup.le_closure_pair`: if `d` acts on the λ-root group `(X, λ)` by a
`k` whose powers span `L` additively, and `λ(x) ≠ 0`, then `X ≤ ⟨d, x⟩`. -/
theorem le_closure_pair_of_isSpanningScalar (rootGroup : LambdaRootGroup G L) (d : G) (k : Lˣ)
    (hk : IsSpanningScalar (k : L)) (action : rootGroup.Action d k) (x : rootGroup.carrier)
    (hx : Multiplicative.toAdd (rootGroup.coordinate x) ≠ 0) :
    rootGroup.carrier ≤ Subgroup.closure {d, (x : G)} := by
  classical
  have : Finite rootGroup.carrier := rootGroup.finite
  have : Group.IsNilpotent rootGroup.carrier := rootGroup.isNilpotent
  let Y : Subgroup rootGroup.carrier :=
    (Subgroup.closure {d, (x : G)}).comap rootGroup.carrier.subtype
  have hconj : ∀ y ∈ Y, action.conjugation y ∈ Y := by
    intro y hy
    change ((action.conjugation y : rootGroup.carrier) : G) ∈ Subgroup.closure {d, (x : G)}
    rw [action.coe_conjugation]
    have hd : d ∈ Subgroup.closure {d, (x : G)} := Subgroup.subset_closure (by simp)
    exact mul_mem (mul_mem hd hy) (inv_mem hd)
  have hxY : x ∈ Y := Subgroup.subset_closure (by simp)
  have hpow : ∀ j : ℕ, ∃ y ∈ Y, Multiplicative.toAdd (rootGroup.coordinate y) =
      (k : L) ^ j * Multiplicative.toAdd (rootGroup.coordinate x) := by
    intro j
    induction j with
    | zero => exact ⟨x, hxY, by simp⟩
    | succ n ih =>
      obtain ⟨y, hy, h⟩ := ih
      refine ⟨action.conjugation y, hconj y hy, ?_⟩
      rw [action.coordinate_conjugation, h, pow_succ]
      ring
  have hall : ∀ a ∈ AddSubgroup.closure (Set.range fun j : ℕ ↦ (k : L) ^ j),
      ∃ y ∈ Y, Multiplicative.toAdd (rootGroup.coordinate y) =
        a * Multiplicative.toAdd (rootGroup.coordinate x) := by
    intro a ha
    induction ha using AddSubgroup.closure_induction with
    | mem a ha => obtain ⟨j, rfl⟩ := ha; exact hpow j
    | zero => exact ⟨1, one_mem _, by simp⟩
    | add a b _ _ ha hb =>
      obtain ⟨y, hy, h⟩ := ha
      obtain ⟨z, hz, h'⟩ := hb
      refine ⟨y * z, mul_mem hy hz, ?_⟩
      rw [map_mul, toAdd_mul, h, h']; ring
    | neg a _ ha =>
      obtain ⟨y, hy, h⟩ := ha
      refine ⟨y⁻¹, inv_mem hy, ?_⟩
      rw [map_inv, toAdd_inv, h]; ring
  have hsurj : ∀ t : L, ∃ y ∈ Y, rootGroup.coordinate y = Multiplicative.ofAdd t := by
    intro t
    have hmem : t * (Multiplicative.toAdd (rootGroup.coordinate x))⁻¹ ∈
        AddSubgroup.closure (Set.range fun j : ℕ ↦ (k : L) ^ j) := by
      rw [hk]; trivial
    obtain ⟨y, hy, h⟩ := hall _ hmem
    refine ⟨y, hy, ?_⟩
    apply Multiplicative.toAdd.injective
    rw [h, toAdd_ofAdd]; field_simp
  have htop : Y ⊔ ⁅(⊤ : Subgroup rootGroup.carrier), (⊤ : Subgroup rootGroup.carrier)⁆ = ⊤ := by
    rw [eq_top_iff]
    intro x' _
    obtain ⟨y, hy, h⟩ := hsurj (Multiplicative.toAdd (rootGroup.coordinate x'))
    have hk' : y⁻¹ * x' ∈ rootGroup.coordinate.ker := by
      rw [MonoidHom.mem_ker, map_mul, map_inv, h]; simp
    have : x' = y * (y⁻¹ * x') := by group
    rw [this]
    exact mul_mem (Subgroup.mem_sup_left hy)
      (Subgroup.mem_sup_right (rootGroup.ker_coordinate_le_commutator hk'))
  have hYtop : Y = ⊤ := eq_top_of_sup_commutator_eq_top htop
  intro g hg
  have : (⟨g, hg⟩ : rootGroup.carrier) ∈ Y := hYtop ▸ Subgroup.mem_top _
  exact this

/-- Variant of `LambdaRootGroup.le_closure_pair_mul`: let `d₁ = g d g⁻¹` commute with `d`, where
`d` acts on `X` by a spanning scalar `k ≠ 1` and `d₁` by `l ≠ 1`. If `λ(u) ≠ 0`, then `⟨d, u g⟩`
contains `X` and `g`. -/
theorem le_closure_pair_mul_of_isSpanningScalar (rootGroup : LambdaRootGroup G L) (d g : G)
    (k l : Lˣ) (hk : IsSpanningScalar (k : L)) (hk1 : k ≠ 1) (hl1 : l ≠ 1)
    (hcommute : Commute d (g * d * g⁻¹))
    (actionD : rootGroup.Action d k) (actionD₁ : rootGroup.Action (g * d * g⁻¹) l)
    (u : rootGroup.carrier) (hu : Multiplicative.toAdd (rootGroup.coordinate u) ≠ 0) :
    rootGroup.carrier ≤ Subgroup.closure {d, (u : G) * g} ∧
      g ∈ Subgroup.closure {d, (u : G) * g} := by
  set d₁ := g * d * g⁻¹ with hd₁
  set v₀ : rootGroup.carrier := u * (actionD₁.conjugation u)⁻¹ with hv₀
  set w : rootGroup.carrier := v₀ * (actionD.conjugation v₀)⁻¹ with hw
  have hcoord₁ : ∀ r : rootGroup.carrier,
      Multiplicative.toAdd (rootGroup.coordinate (r * (actionD₁.conjugation r)⁻¹)) =
        (1 - (l : L)) * Multiplicative.toAdd (rootGroup.coordinate r) := by
    intro r
    rw [map_mul, map_inv, toAdd_mul, toAdd_inv, actionD₁.coordinate_conjugation]
    ring
  have hcoord : ∀ r : rootGroup.carrier,
      Multiplicative.toAdd (rootGroup.coordinate (r * (actionD.conjugation r)⁻¹)) =
        (1 - (k : L)) * Multiplicative.toAdd (rootGroup.coordinate r) := by
    intro r
    rw [map_mul, map_inv, toAdd_mul, toAdd_inv, actionD.coordinate_conjugation]
    ring
  have h1 : (1 - (k : L)) ≠ 0 :=
    sub_ne_zero.2 fun h ↦ hk1 (Units.ext h.symm)
  have h2 : (1 - (l : L)) ≠ 0 :=
    sub_ne_zero.2 fun h ↦ hl1 (Units.ext h.symm)
  have hw0 : Multiplicative.toAdd (rootGroup.coordinate w) ≠ 0 := by
    rw [hw, hcoord, hv₀, hcoord₁]
    exact mul_ne_zero h1 (mul_ne_zero h2 hu)
  have hwG : (w : G) = ((u : G) * g * d * ((u : G) * g)⁻¹) * d *
      ((u : G) * g * d * ((u : G) * g)⁻¹)⁻¹ * d⁻¹ := by
    have e1 : ((actionD₁.conjugation u : rootGroup.carrier) : G) = d₁ * u * d₁⁻¹ :=
      actionD₁.coe_conjugation u
    have e2 : ((actionD.conjugation v₀ : rootGroup.carrier) : G) = d * v₀ * d⁻¹ :=
      actionD.coe_conjugation v₀
    have hv : (v₀ : G) = (u : G) * (d₁ * (u : G)⁻¹ * d₁⁻¹) := by
      rw [hv₀]; simp only [Subgroup.coe_mul, Subgroup.coe_inv, e1]; group
    have hc' : d₁⁻¹ * d * d₁ = d := by rw [mul_assoc, hcommute.eq, inv_mul_cancel_left]
    have hy : (u : G) * g * d * ((u : G) * g)⁻¹ = (u : G) * d₁ * (u : G)⁻¹ := by
      rw [hd₁]; group
    rw [hy, hw]
    simp only [Subgroup.coe_mul, Subgroup.coe_inv, e2, hv]
    calc _ = (u : G) * d₁ * (u : G)⁻¹ * (d₁⁻¹ * d * d₁) * (u : G) * d₁⁻¹ * (u : G)⁻¹ * d⁻¹ := by
          group
      _ = _ := by rw [hc']; group
  set Γ := Subgroup.closure {d, (u : G) * g} with hΓ
  have hdΓ : d ∈ Γ := Subgroup.subset_closure (by simp)
  have hxΓ : (u : G) * g ∈ Γ := Subgroup.subset_closure (by simp)
  have hwΓ : (w : G) ∈ Γ := by
    rw [hwG]
    have hy : (u : G) * g * d * ((u : G) * g)⁻¹ ∈ Γ :=
      Γ.mul_mem (Γ.mul_mem hxΓ hdΓ) (Γ.inv_mem hxΓ)
    exact Γ.mul_mem (Γ.mul_mem (Γ.mul_mem hy hdΓ) (Γ.inv_mem hy)) (Γ.inv_mem hdΓ)
  have hX : rootGroup.carrier ≤ Γ := by
    refine (rootGroup.le_closure_pair_of_isSpanningScalar d k hk actionD w hw0).trans ?_
    rw [Subgroup.closure_le]
    rintro _ (rfl | rfl)
    · exact hdΓ
    · exact hwΓ
  refine ⟨hX, ?_⟩
  have := Γ.mul_mem (Γ.inv_mem (hX u.2)) hxΓ
  simpa using this

end LambdaRootGroup

end CFSGCorollary
