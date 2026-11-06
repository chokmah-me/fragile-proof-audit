module

public import CFSGCorollary.LieType.Steinberg.Basic

/-!
# Steinberg data under surjective homomorphisms

Steinberg data (axioms (S0)–(S3) of [Steinberg1962]) on a group `U` pass to any surjective image
`G` of `U`, and give a Steinberg system there when `G` has trivial center. The property of having
unit commutator constants is preserved.

## Main definitions

* `CFSGCorollary.SteinbergData.map`: the image of Steinberg data under a surjection.
* `CFSGCorollary.SteinbergData.mapSystem`: the resulting Steinberg system on a centerless image.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

open CFSG.LieType.RootSystem (roots)
open CFSG.LieType.Steinberg (weylElement)

variable {rank : ℕ} {cartan : Matrix (Fin rank) (Fin rank) ℤ}
  {finiteType : TauCeti.IsFiniteType cartan} {K : Type*} [Field K] [Finite K]
  {U G : Type*} [Group U] [Group G]

omit [Finite K] in
/-- A homomorphism carries Weyl elements of `x` to Weyl elements of `φ ∘ x`. -/
theorem weylElement_map (φ : U →* G) (x : (Fin rank → ℤ) → K → U) (i : Fin rank) (t : Kˣ) :
    weylElement (fun root parameter ↦ φ (x root parameter)) i t = φ (weylElement x i t) := by
  simp [weylElement, map_mul]

namespace SteinbergData

/-- Steinberg data pass to surjective images. -/
def map (data : SteinbergData cartan finiteType K U) (φ : U →* G)
    (hφ : Function.Surjective φ) : SteinbergData cartan finiteType K G where
  rootElement root parameter := φ (data.rootElement root parameter)
  rootElement_add root hroot first second := by
    simp [data.rootElement_add root hroot first second]
  closure_rootElement_eq_top := by
    have himage : {element : G | ∃ root ∈ roots finiteType ∅,
        ∃ parameter : K, φ (data.rootElement root parameter) = element} =
        φ '' {element : U | ∃ root ∈ roots finiteType ∅,
          ∃ parameter : K, data.rootElement root parameter = element} := by
      ext g
      constructor
      · rintro ⟨root, hroot, parameter, rfl⟩
        exact ⟨_, ⟨root, hroot, parameter, rfl⟩, rfl⟩
      · rintro ⟨_, ⟨root, hroot, parameter, rfl⟩, rfl⟩
        exact ⟨root, hroot, parameter, rfl⟩
    rw [himage, ← MonoidHom.map_closure, data.closure_rootElement_eq_top,
      ← MonoidHom.range_eq_map, MonoidHom.range_eq_top.2 hφ]
  rootElement_commute a ha b hb hab hnone p q :=
    (data.rootElement_commute a ha b hb hab hnone p q).map φ
  weylElement_conj_rootElement simple root hroot := by
    obtain ⟨sign, hsign, h⟩ := data.weylElement_conj_rootElement simple root hroot
    refine ⟨sign, hsign, fun t parameter ↦ ?_⟩
    simpa [weylElement_map, map_mul, map_inv] using congrArg φ (h t parameter)

theorem hasUnitCommutatorConstants_map (data : SteinbergData cartan finiteType K U)
    (φ : U →* G) (hφ : Function.Surjective φ) (h : data.HasUnitCommutatorConstants) :
    (data.map φ hφ).HasUnitCommutatorConstants := by
  intro a ha b hb hab honly
  obtain ⟨constant, hconstant⟩ := h a ha b hb hab honly
  refine ⟨constant, fun p q ↦ ?_⟩
  simpa [map_mul, map_inv, SteinbergData.map] using congrArg φ (hconstant p q)

/-- Steinberg data on a group `U` give a Steinberg system on any surjective image with trivial
center. -/
def mapSystem (data : SteinbergData cartan finiteType K U) (φ : U →* G)
    (hφ : Function.Surjective φ) (center : Subgroup.center G = ⊥) :
    SteinbergSystem cartan finiteType K G :=
  (data.map φ hφ).toSystem center

theorem hasUnitCommutatorConstants_mapSystem
    (data : SteinbergData cartan finiteType K U) (φ : U →* G) (hφ : Function.Surjective φ)
    (center : Subgroup.center G = ⊥) (h : data.HasUnitCommutatorConstants) :
    (data.mapSystem φ hφ center).HasUnitCommutatorConstants :=
  data.hasUnitCommutatorConstants_map φ hφ h

end SteinbergData

end CFSGCorollary
