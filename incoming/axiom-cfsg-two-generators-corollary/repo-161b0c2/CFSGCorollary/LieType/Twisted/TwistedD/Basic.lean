module

public import CFSG.LieType.Universal.Spin.Twisted.Datum

/-!
# Setup for the two-generation of `²D_r(q)`

Fix `r ≥ 4`, a field `K` and `b c : K` such that `X² + b X + c` has no root in `K`, and let
`L = ShortField b c` be the corresponding quadratic extension of `K`. We work in the group
`Spin⁻_{2r}(K) = spinGroup (quadMinus r K b c)` of CFSG and define the elements used to generate
it, following Steinberg: the short root elements `xᵢₛ(t)` (`t ∈ L`) and short root groups `Xᵢₛ`,
the twisted Coxeter element `g = ω₀ ⋯ ω_ℓ`, the torus element `d` attached to a unit `α` of `L`,
and `u = x_{ℓ,true}(1)`. The generating pair is `(d, u g)`.

We also express the plane reflections in the field coordinates `fieldCoord : L → (Fin 2 → K)`
and show that the trace form `p ↦ -polarPlane b c p planeOne` is onto `K` when `K` is finite.

## Main definitions

* `CFSGCorollary.TwistedD.shortRootElement`, `CFSGCorollary.TwistedD.shortRootGroup`: the short
  root elements and groups.
* `CFSGCorollary.TwistedD.coxeterElement`: the twisted Coxeter element `g`.
* `CFSGCorollary.TwistedD.torusElement`: the torus element `d`.
* `CFSGCorollary.TwistedD.generatingPair`: the pair `(d, u g)`.

## Main results

* `CFSGCorollary.TwistedD.planeRefl_planeOne_fieldCoord`: `planeRefl planeOne` is `-star`.
* `CFSGCorollary.TwistedD.planeNorm_smul_planeRefl_planeRefl_fieldCoord`: the product of two
  plane reflections, rescaled by `planeNorm a`, is multiplication by `a ^ 2`.
* `CFSGCorollary.TwistedD.exists_neg_polarPlane_planeOne_eq`: the trace form is onto.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

open CFSG.LieType.Universal.Spin CFSG.LieType.Universal.Spin.Twisted

namespace CFSGCorollary

/-- `L = ShortField b c` is finite when `K` is. -/
instance instFiniteShortField {K : Type} [Field K] {b c : K} [Finite K] :
    Finite (ShortField b c) :=
  finite_shortField

namespace TwistedD

section Setup

variable (r : ℕ) {K : Type} [Field K] {b c : K} (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0)

/-- The short root element `xᵢₛ(t) = twShortRoot r hirr i s (ofAdd (fieldCoord t))`. -/
noncomputable def shortRootElement (i : Fin (r - 1)) (s : Bool) (t : ShortField b c) :
    spinGroup (quadMinus r K b c) :=
  twShortRoot r hirr i s (.ofAdd (fieldCoord t))

/-- The short root group `Xᵢₛ`. -/
noncomputable def shortRootGroup (i : Fin (r - 1)) (s : Bool) :
    Subgroup (spinGroup (quadMinus r K b c)) :=
  (twShortRoot r hirr i s).range

/-- The twisted Coxeter element `g = ω₀ ω₁ ⋯ ω_ℓ`. -/
noncomputable def coxeterElement : spinGroup (quadMinus r K b c) :=
  (List.ofFn fun k : Fin (r - 1) ↦ minusWeyl r hirr k).prod

/-- The short simple root index `ℓ = r - 2`. -/
def lastIndex (hr : 4 ≤ r) : Fin (r - 1) := ⟨r - 2, by omega⟩

/-- The index `ℓ' = r - 3`. -/
def secondLastIndex (hr : 4 ≤ r) : Fin (r - 1) := ⟨r - 3, by omega⟩

/-- The index `ℓ'' = r - 4`. -/
def thirdLastIndex (hr : 4 ≤ r) : Fin (r - 1) := ⟨r - 4, by omega⟩

/-- The torus element `d = h_s(fieldCoord α) · longTorus_{ℓ'',ℓ'}(N(α)⁻¹)`; the second index of
the long torus is `⟨ℓ''.val + 1, _⟩`, which is `ℓ'` (see `thirdLastIndex_succ`). -/
noncomputable def torusElement (hr : 4 ≤ r) (α : (ShortField b c)ˣ) :
    spinGroup (quadMinus r K b c) :=
  shortTorusElt r hirr (lastIndex r hr) (fieldCoord (α : ShortField b c)) *
    (minusFrame r b c).longTorus
      (succ_ne_of_lt (n := r) (k := thirdLastIndex r hr) (by simp [thirdLastIndex]; omega))
      true false (Units.map (QuadraticAlgebra.norm : ShortField b c →* K) α)⁻¹

/-- The unipotent element `u = x_{ℓ,true}(1)`. -/
noncomputable def unipotent (hr : 4 ≤ r) : spinGroup (quadMinus r K b c) :=
  twShortRoot r hirr (lastIndex r hr) true (.ofAdd planeOne)

/-- The generating pair `(d, u * g)`. -/
noncomputable def generatingPair (hr : 4 ≤ r) (α : (ShortField b c)ˣ) :
    spinGroup (quadMinus r K b c) × spinGroup (quadMinus r K b c) :=
  (torusElement r hirr hr α, unipotent r hirr hr * coxeterElement r hirr)

theorem thirdLastIndex_succ (hr : 4 ≤ r) :
    (⟨(thirdLastIndex r hr).val + 1, by simp [thirdLastIndex]; omega⟩ : Fin (r - 1)) =
      secondLastIndex r hr := by
  ext
  simp [thirdLastIndex, secondLastIndex]
  omega

theorem mem_shortRootGroup_iff (i : Fin (r - 1)) (s : Bool) (x : spinGroup (quadMinus r K b c)) :
    x ∈ shortRootGroup r hirr i s ↔ ∃ p : Fin 2 → K, x = twShortRoot r hirr i s (.ofAdd p) := by
  unfold shortRootGroup
  constructor
  · rintro ⟨y, rfl⟩
    exact ⟨y.toAdd, rfl⟩
  · rintro ⟨p, rfl⟩
    exact ⟨.ofAdd p, rfl⟩

end Setup

/-! ### The plane reflections in field coordinates -/

section PlaneAlgebra

variable {K : Type*} [Field K] {b c : K}

theorem fieldCoord_neg (t : ShortField b c) : fieldCoord (-t) = -fieldCoord t := by
  ext k
  fin_cases k <;> simp [fieldCoord]

theorem fieldCoord_injective : Function.Injective (fieldCoord : ShortField b c → Fin 2 → K) :=
  fun _ _ h ↦ QuadraticAlgebra.ext (by simpa [fieldCoord] using congrFun h 0)
    (by simpa [fieldCoord] using congrFun h 1)

theorem fieldCoord_bijective : Function.Bijective (fieldCoord : ShortField b c → Fin 2 → K) :=
  ⟨fieldCoord_injective, exists_fieldCoord_eq⟩

/-- `fieldCoord` as an additive equivalence `L ≃+ (Fin 2 → K)`. -/
noncomputable def fieldCoordAddEquiv : ShortField b c ≃+ (Fin 2 → K) :=
  AddEquiv.ofBijective (AddMonoidHom.mk' (fieldCoord : ShortField b c → Fin 2 → K) fieldCoord_add)
    fieldCoord_bijective

theorem fieldCoordAddEquiv_apply (t : ShortField b c) : fieldCoordAddEquiv t = fieldCoord t :=
  rfl

theorem planeRefl_smul (a' p : Fin 2 → K) (s : K) :
    planeRefl b c a' (s • p) = s • planeRefl b c a' p := by
  unfold planeRefl
  rw [polarPlane_smul_left b c s p a']
  ext k
  simp only [Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
  ring

/-- `planeRefl planeOne` is `-star` in field coordinates. -/
theorem planeRefl_planeOne_fieldCoord (t : ShortField b c) :
    planeRefl b c planeOne (fieldCoord t) = -fieldCoord (star t) := by
  ext k
  fin_cases k <;>
  · simp [planeRefl, planeOne, polarPlane, planeNorm, fieldCoord, QuadraticAlgebra.re_star,
      QuadraticAlgebra.im_star]
    <;> ring

/-- `planeNorm a • planeRefl a (planeRefl planeOne ·)` is multiplication by `a ^ 2` in field
coordinates. -/
theorem planeNorm_smul_planeRefl_planeRefl_fieldCoord [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)]
    {a : ShortField b c} (ha : a ≠ 0) (t : ShortField b c) :
    planeNorm b c (fieldCoord a) • planeRefl b c (fieldCoord a)
        (planeRefl b c planeOne (fieldCoord t)) = fieldCoord (a ^ 2 * t) := by
  have hn : planeNorm b c (fieldCoord a) ≠ 0 := by
    rw [planeNorm_fieldCoord]
    exact fun h ↦ ha (QuadraticAlgebra.norm_eq_zero_iff_eq_zero.1 h)
  have hn' : a.re * (a.re + b * a.im) + a.im ^ 2 * c ≠ 0 := by
    intro h
    apply hn
    simp only [planeNorm, fieldCoord]
    simp
    linear_combination h
  ext k
  fin_cases k <;>
  · simp [planeRefl, planeOne, polarPlane, planeNorm, fieldCoord, pow_two]
    field_simp
    ring

end PlaneAlgebra

/-! ### The trace form is onto -/

/-- For a finite field `K` and `b c : K` with `s² + b s + c ≠ 0` for all `s`, the map
`p ↦ -polarPlane b c p planeOne` is onto `K`. -/
theorem exists_neg_polarPlane_planeOne_eq {K : Type*} [Field K] [Finite K] {b c : K}
    (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0) (a : K) :
    ∃ p : Fin 2 → K, -polarPlane b c p planeOne = a := by
  have key (p : Fin 2 → K) : polarPlane b c p planeOne = 2 * p 0 + b * p 1 := by
    simp [polarPlane, planeOne]
  by_cases h2 : (2 : K) = 0
  · have hb : b ≠ 0 := by
      intro hb
      have : CharP K 2 := CharTwo.of_one_ne_zero_of_two_eq_zero one_ne_zero h2
      obtain ⟨e, he⟩ := FiniteField.isSquare_of_char_two (ringChar.eq K 2) c
      apply hirr e
      have h2' : e ^ 2 + b * e + c = 2 * e ^ 2 := by rw [hb, he]; ring
      rw [h2', h2]
      ring
    refine ⟨![0, -a / b], ?_⟩
    rw [key]
    simp
    field_simp
  · refine ⟨![-a / 2, 0], ?_⟩
    rw [key]
    simp
    field_simp

end TwistedD

end CFSGCorollary
