module

public import CFSGCorollary.LieType.Twisted.TwistedD.Basic
public import CFSGCorollary.LieType.LambdaRootGroup.Basic
import CFSG.LieType.Universal.Spin.Twisted.Torus
import CFSGCorollary.LieType.Steinberg.GeneratingScalar
import CFSG.LieType.Universal.Spin.Twisted.Weyl

/-!
# The torus element of `²D_r`

We study the torus element `d = torusElement r hirr hr α` of `Spin⁻_{2r}(K)`.

* `d` acts on the short root groups `X_{ℓ,true}` and `X_{ℓ',true}` by multiplication by `α²`.
* `d` and its Coxeter conjugate `d₁ = g d g⁻¹` commute: both lie in the abelian torus
  `T = ⨆ k, minusTorus r hirr k`, which the simple Weyl representatives (hence `g`) normalise.
* If `α` generates `Lˣ`, then `α²` and `(star α)²` are nontrivial generating scalars.

## Main results

* `CFSGCorollary.TwistedD.torusElement_conj_shortRootElement_lastIndex`
* `CFSGCorollary.TwistedD.torusElement_conj_shortRootElement_secondLastIndex`
* `CFSGCorollary.TwistedD.commute_torusElement_conj_coxeterElement`
* `CFSGCorollary.TwistedD.isGoodScalar_sq_of_zpowers_eq_top`
* `CFSGCorollary.TwistedD.isGoodScalar_starUnit_sq_of_zpowers_eq_top`
-/

@[expose] public section

open CFSG.LieType.Universal.Spin CFSG.LieType.Universal.Spin.Twisted

namespace CFSGCorollary.TwistedD

/-! ### Action of `d` on two short root groups -/

section Characters

variable (r : ℕ) {K : Type} [Field K] {b c : K} (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0)

private theorem mul_conj_mul_inv_eq {G : Type*} [Group G] (a b y y' z : G)
    (h : b * y * b⁻¹ = y') (h' : a * y' * a⁻¹ = z) : a * b * y * (a * b)⁻¹ = z := by
  rw [← h', ← h]
  simp only [mul_inv_rev, mul_assoc]

/-- `d x_{ℓ,true}(t) d⁻¹ = x_{ℓ,true}(α² t)`. -/
theorem torusElement_conj_shortRootElement_lastIndex [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)]
    (hr : 4 ≤ r) (α : (ShortField b c)ˣ) (t : ShortField b c) :
    torusElement r hirr hr α * shortRootElement r hirr (lastIndex r hr) true t *
        (torusElement r hirr hr α)⁻¹ =
      shortRootElement r hirr (lastIndex r hr) true ((α : ShortField b c) ^ 2 * t) := by
  have hα : (α : ShortField b c) ≠ 0 := α.ne_zero
  have h1 := longTorus_conj_twShortRoot r hirr
    (succ_ne_of_lt (n := r) (k := thirdLastIndex r hr) (by simp [thirdLastIndex]; omega)) true
    false (Units.map (QuadraticAlgebra.norm : ShortField b c →* K) α)⁻¹ (lastIndex r hr) true
    (fieldCoord t)
  have hne1 : lastIndex r hr ≠ thirdLastIndex r hr := by
    intro h
    have : r - 2 = r - 4 := congrArg Fin.val h
    omega
  have hne2 : lastIndex r hr ≠
      (⟨(thirdLastIndex r hr).val + 1, by simp [thirdLastIndex]; omega⟩ : Fin (r - 1)) := by
    intro h
    have : r - 2 = r - 4 + 1 := congrArg Fin.val h
    omega
  have h0 : longCoroot (thirdLastIndex r hr)
      (⟨(thirdLastIndex r hr).val + 1, by simp [thirdLastIndex]; omega⟩ : Fin (r - 1))
      true false (lastIndex r hr) true = 0 := by
    unfold longCoroot
    rw [ite_eq_right hne1, ite_eq_right hne2]
    rfl
  rw [h0, zpow_zero, Units.val_one, one_smul] at h1
  have h2 := shortTorusElt_conj_shortPosHom r hirr (lastIndex r hr) (fieldCoord_ne_zero hα)
    (fieldCoord t)
  have h3 := planeNorm_smul_planeRefl_planeRefl_fieldCoord hα t
  unfold torusElement
  refine mul_conj_mul_inv_eq _ _ _ _ _ h1 ?_
  exact h2.trans
    (congrArg (fun p ↦ twShortRoot r hirr (lastIndex r hr) true (Multiplicative.ofAdd p)) h3)

/-- `d x_{ℓ',true}(t) d⁻¹ = x_{ℓ',true}(α² t)`. -/
theorem torusElement_conj_shortRootElement_secondLastIndex [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)]
    (hr : 4 ≤ r) (α : (ShortField b c)ˣ) (t : ShortField b c) :
    torusElement r hirr hr α * shortRootElement r hirr (secondLastIndex r hr) true t *
        (torusElement r hirr hr α)⁻¹ =
      shortRootElement r hirr (secondLastIndex r hr) true ((α : ShortField b c) ^ 2 * t) := by
  have hα : (α : ShortField b c) ≠ 0 := α.ne_zero
  have h1 := longTorus_conj_twShortRoot r hirr
    (succ_ne_of_lt (n := r) (k := thirdLastIndex r hr) (by simp [thirdLastIndex]; omega)) true
    false (Units.map (QuadraticAlgebra.norm : ShortField b c →* K) α)⁻¹ (secondLastIndex r hr)
    true (fieldCoord t)
  have hne1 : secondLastIndex r hr ≠ thirdLastIndex r hr := by
    intro h
    have : r - 3 = r - 4 := congrArg Fin.val h
    omega
  have hne2 : lastIndex r hr ≠ secondLastIndex r hr := by
    intro h
    have : r - 2 = r - 3 := congrArg Fin.val h
    omega
  have hj : secondLastIndex r hr =
      (⟨(thirdLastIndex r hr).val + 1, by simp [thirdLastIndex]; omega⟩ : Fin (r - 1)) :=
    (thirdLastIndex_succ r hr).symm
  have h0 : longCoroot (thirdLastIndex r hr)
      (⟨(thirdLastIndex r hr).val + 1, by simp [thirdLastIndex]; omega⟩ : Fin (r - 1))
      true false (secondLastIndex r hr) true = -1 := by
    unfold longCoroot
    rw [ite_eq_right hne1, ite_eq_left hj]
    simp
  rw [h0, zpow_neg_one, inv_inv] at h1
  have h2 := shortTorusElt_conj_shortPosHom_of_ne r hirr (i := lastIndex r hr)
    (j := secondLastIndex r hr) (Ne.symm hne2) (fieldCoord_ne_zero hα)
    (((Units.map (QuadraticAlgebra.norm : ShortField b c →* K) α : Kˣ) : K) • fieldCoord t)
  have hN : ((Units.map (QuadraticAlgebra.norm : ShortField b c →* K) α : Kˣ) : K) =
      planeNorm b c (fieldCoord (α : ShortField b c)) :=
    (planeNorm_fieldCoord (b := b) (c := c) (α : ShortField b c)).symm
  have h3 := planeNorm_smul_planeRefl_planeRefl_fieldCoord hα t
  have h4 : planeRefl b c (fieldCoord (α : ShortField b c)) (planeRefl b c planeOne
      (((Units.map (QuadraticAlgebra.norm : ShortField b c →* K) α : Kˣ) : K) • fieldCoord t)) =
      fieldCoord ((α : ShortField b c) ^ 2 * t) := by
    rw [planeRefl_smul, planeRefl_smul, hN]
    exact h3
  unfold torusElement
  refine mul_conj_mul_inv_eq _ _ _ _ _ h1 ?_
  exact h2.trans
    (congrArg (fun p ↦ twShortRoot r hirr (secondLastIndex r hr) true (Multiplicative.ofAdd p)) h4)

end Characters

/-! ### `d` and its Coxeter conjugate commute -/

section Torus

variable (r : ℕ) {K : Type} [Field K] {b c : K} (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0)

/-- The torus `T = ⨆ k, minusTorus r hirr k`. -/
noncomputable def torus : Subgroup (spinGroup (quadMinus r K b c)) :=
  ⨆ k : Fin (r - 1), minusTorus r hirr k

/-- Any two elements of `T` commute. -/
theorem commute_of_mem_torus [Finite K] {x y : spinGroup (quadMinus r K b c)}
    (hx : x ∈ torus r hirr) (hy : y ∈ torus r hirr) : Commute x y := by
  have h1 : ∀ y : spinGroup (quadMinus r K b c), (∃ j, y ∈ minusTorus r hirr j) →
      ∀ z ∈ torus r hirr, Commute y z := by
    rintro y ⟨j, hj⟩ z hz
    have : torus r hirr ≤ Subgroup.centralizer {y} := by
      refine iSup_le fun i w hw ↦ ?_
      rw [Subgroup.mem_centralizer_singleton_iff]
      exact (minusDatum_torus_commute r hirr j i y hj w hw).eq.symm
    exact (Subgroup.mem_centralizer_singleton_iff.1 (this hz)).symm
  have h2 : torus r hirr ≤ Subgroup.centralizer {y} := by
    refine iSup_le fun i w hw ↦ ?_
    rw [Subgroup.mem_centralizer_singleton_iff]
    exact (h1 w ⟨i, hw⟩ y hy).eq
  exact Subgroup.mem_centralizer_singleton_iff.1 (h2 hx)

/-- `ω_k T ω_k⁻¹ ≤ T`. -/
theorem minusWeyl_conj_mem_torus [Finite K] (k : Fin (r - 1)) {x : spinGroup (quadMinus r K b c)}
    (hx : x ∈ torus r hirr) :
    minusWeyl r hirr k * x * (minusWeyl r hirr k)⁻¹ ∈ torus r hirr := by
  unfold torus at hx ⊢
  refine Subgroup.iSup_induction (C := fun x ↦ minusWeyl r hirr k * x * (minusWeyl r hirr k)⁻¹ ∈
    ⨆ k : Fin (r - 1), minusTorus r hirr k) _ hx ?_ ?_ ?_
  · intro j y hy
    refine (sup_le ?_ ?_ : minusTorus r hirr k ⊔ minusTorus r hirr j ≤
      ⨆ k : Fin (r - 1), minusTorus r hirr k) (minusDatum_conj_H_mem r hirr k j y hy)
    · exact le_iSup (fun i ↦ minusTorus r hirr i) k
    · exact le_iSup (fun i ↦ minusTorus r hirr i) j
  · simp
  · intro x y hx hy
    have : minusWeyl r hirr k * (x * y) * (minusWeyl r hirr k)⁻¹ =
        minusWeyl r hirr k * x * (minusWeyl r hirr k)⁻¹ *
          (minusWeyl r hirr k * y * (minusWeyl r hirr k)⁻¹) := by
      group
    rw [this]
    exact Subgroup.mul_mem _ hx hy

/-- `g T g⁻¹ ≤ T`. -/
theorem coxeterElement_conj_mem_torus [Finite K] {x : spinGroup (quadMinus r K b c)}
    (hx : x ∈ torus r hirr) :
    coxeterElement r hirr * x * (coxeterElement r hirr)⁻¹ ∈ torus r hirr := by
  let N : Submonoid (spinGroup (quadMinus r K b c)) :=
    { carrier := {y | ∀ x ∈ torus r hirr, y * x * y⁻¹ ∈ torus r hirr}
      mul_mem' := fun ha hb x hx ↦ by simpa [mul_assoc] using ha _ (hb x hx)
      one_mem' := fun x hx ↦ by simpa using hx }
  have : coxeterElement r hirr ∈ N := by
    unfold coxeterElement
    apply Submonoid.list_prod_mem
    intro y hy
    obtain ⟨k, rfl⟩ := List.mem_ofFn.mp hy
    exact fun x hx ↦ minusWeyl_conj_mem_torus r hirr k hx
  exact this x hx

/-- `d ∈ T` for every unit `α`. -/
theorem torusElement_mem_torus [Finite K] [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)]
    (hr : 4 ≤ r) (α : (ShortField b c)ˣ) : torusElement r hirr hr α ∈ torus r hirr := by
  unfold torusElement
  refine Subgroup.mul_mem _ ?_ ?_
  · refine Subgroup.mem_iSup_of_mem (lastIndex r hr) ?_
    have e : minusTorus r hirr (lastIndex r hr) = shortTorus r hirr (lastIndex r hr) :=
      minusTorus_of_not_lt r hirr (by simp [lastIndex]; omega)
    rw [e]
    exact shortTorusElt_mem r hirr _ (fieldCoord_ne_zero (Units.ne_zero α))
  · refine Subgroup.mem_iSup_of_mem (thirdLastIndex r hr) ?_
    have e : minusTorus r hirr (thirdLastIndex r hr) = ((minusFrame r b c).longTorus
        (succ_ne_of_lt r (k := thirdLastIndex r hr) (by simp [thirdLastIndex]; omega))
          true false).range :=
      minusTorus_of_lt r hirr (by simp [thirdLastIndex]; omega)
    rw [e]
    exact ⟨_, rfl⟩

/-- `d` and `d₁ = g d g⁻¹` commute. -/
theorem commute_torusElement_conj_coxeterElement [Finite K]
    [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)] (hr : 4 ≤ r) (α : (ShortField b c)ˣ) :
    Commute (torusElement r hirr hr α)
      (coxeterElement r hirr * torusElement r hirr hr α * (coxeterElement r hirr)⁻¹) :=
  commute_of_mem_torus r hirr (torusElement_mem_torus r hirr hr α)
    (coxeterElement_conj_mem_torus r hirr (torusElement_mem_torus r hirr hr α))

end Torus

/-! ### The two characters are good -/

/-- Conjugation `star` on the units of `ShortField b c`. -/
noncomputable def starUnit {K : Type} [Field K] {b c : K} [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)]
    (α : (ShortField b c)ˣ) : (ShortField b c)ˣ :=
  Units.map (starRingEnd (ShortField b c)).toMonoidHom α

theorem card_shortField (K : Type) [Field K] [Finite K] (b c : K) :
    Nat.card (ShortField b c) = Nat.card K ^ 2 := by
  rw [Nat.card_congr (Equiv.ofBijective _ (fieldCoord_bijective (K := K) (b := b) (c := c))),
    Nat.card_fun, Nat.card_fin]

/-- If `α` generates `Lˣ`, then `α ^ 2` is a nontrivial generating scalar. -/
theorem isGoodScalar_sq_of_zpowers_eq_top {K : Type} [Field K] [Finite K] {b c : K}
    [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)] (α : (ShortField b c)ˣ)
    (hα : Subgroup.zpowers α = ⊤) : IsNontrivialGeneratingScalar (α ^ 2) :=
  ⟨⟨α, hα, Or.inr rfl⟩, sq_ne_one_of_zpowers_eq_top
    (by rw [card_shortField]; nlinarith [Finite.one_lt_card (α := K)]) hα⟩

theorem zpowers_starUnit_eq_top {K : Type} [Field K] {b c : K}
    [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)] (α : (ShortField b c)ˣ)
    (hα : Subgroup.zpowers α = ⊤) : Subgroup.zpowers (starUnit α) = ⊤ := by
  have hsurj : Function.Surjective (Units.map (starRingEnd (ShortField b c)).toMonoidHom) :=
    fun y ↦ ⟨Units.map (starRingEnd (ShortField b c)).toMonoidHom y,
      Units.ext (by simp [starRingEnd_apply])⟩
  unfold starUnit
  rw [← MonoidHom.map_zpowers, hα, Subgroup.map_top]
  exact MonoidHom.range_eq_top.2 hsurj

/-- If `α` generates `Lˣ`, then `(star α) ^ 2` is a nontrivial generating scalar. -/
theorem isGoodScalar_starUnit_sq_of_zpowers_eq_top {K : Type} [Field K] [Finite K] {b c : K}
    [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)] (α : (ShortField b c)ˣ)
    (hα : Subgroup.zpowers α = ⊤) : IsNontrivialGeneratingScalar (starUnit α ^ 2) :=
  isGoodScalar_sq_of_zpowers_eq_top _ (zpowers_starUnit_eq_top α hα)

end CFSGCorollary.TwistedD
