module

public import CFSG.LieType.Steinberg.PartB


/-!
# Steinberg systems

This file sets up the axiomatic framework of [Steinberg1962] for groups of Lie type over a finite
field `K`: a family of root elements `x_γ(t)`, indexed by the roots `γ` of a finite-type Cartan
matrix and `t : K`, satisfying

* (S0) `t ↦ x_γ(t)` is additive;
* (S1) the root elements generate `G`;
* (S2) `X_α` and `X_β` commute when no positive combination of `α` and `β` is a root;
* (S3) the Weyl elements `ωᵢ(t)` permute the root groups according to the simple reflections;
* (S4) `G` has trivial center.

## Main definitions

* `CFSGCorollary.RootScaling`: `d` acts on the root group `X_γ` by a scalar.
* `CFSGCorollary.IsGeneratingScalar`: a generator of `Kˣ` or the square of one.
* `CFSGCorollary.SteinbergData`: axioms (S0)–(S3).
* `CFSGCorollary.SteinbergSystem`: Steinberg data satisfying (S4); see `SteinbergData.toSystem`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

open CFSG.LieType.RootSystem (roots reflection)
open CFSG.LieType.Steinberg (weylElement)

/-- `RootScaling x γ d k`: conjugation by `d` acts on the root group `X_γ` by the scalar `k`,
i.e. `d x_γ(t) d⁻¹ = x_γ(k t)` for all `t`. -/
def RootScaling {K G : Type*} [Field K] [Group G] {rank : ℕ}
    (rootElement : (Fin rank → ℤ) → K → G) (root : Fin rank → ℤ)
    (element : G) (scalar : K) : Prop :=
  ∀ parameter : K,
    element * rootElement root parameter * element⁻¹ =
      rootElement root (scalar * parameter)

/-- A unit of `K` is a generating scalar if it generates `Kˣ` or is the square of a generator. -/
def IsGeneratingScalar {K : Type*} [Field K] (scalar : Kˣ) : Prop :=
  ∃ generator : Kˣ, Subgroup.zpowers generator = ⊤ ∧
    (scalar = generator ∨ scalar = generator ^ (2 : ℕ))

/-- Steinberg data: root elements `x_γ(t)` in a group `G` satisfying the axioms (S0)–(S3) of
[Steinberg1962], for the root system of a finite-type Cartan matrix over a finite field `K`. -/
structure SteinbergData {rank : ℕ} (cartan : Matrix (Fin rank) (Fin rank) ℤ)
    (finiteType : TauCeti.IsFiniteType cartan) (K G : Type*)
    [Field K] [Finite K] [Group G] where
  /-- The root element `x_γ(t)`. -/
  rootElement : (Fin rank → ℤ) → K → G
  /-- (S0) Each `t ↦ x_γ(t)` is additive. -/
  rootElement_add : ∀ root ∈ roots finiteType ∅, ∀ first second : K,
    rootElement root (first + second) = rootElement root first * rootElement root second
  /-- (S1) The root elements generate `G`. -/
  closure_rootElement_eq_top : Subgroup.closure
    {element : G | ∃ root ∈ roots finiteType ∅,
      ∃ parameter : K, rootElement root parameter = element} = ⊤
  /-- (S2) `X_α` and `X_β` commute if no positive combination of `α` and `β` is a root. -/
  rootElement_commute : ∀ firstRoot ∈ roots finiteType ∅, ∀ secondRoot ∈ roots finiteType ∅,
    firstRoot + secondRoot ≠ 0 →
    (∀ first second : ℕ, 0 < first → 0 < second →
      first • firstRoot + second • secondRoot ∉ roots finiteType ∅) →
    ∀ firstParameter secondParameter : K,
      Commute (rootElement firstRoot firstParameter) (rootElement secondRoot secondParameter)
  /-- (S3) The Weyl element `ωᵢ(t)` maps `X_γ` to `X_{sᵢ γ}`, up to a sign and a power of `t`. -/
  weylElement_conj_rootElement : ∀ simple : Fin rank, ∀ root ∈ roots finiteType ∅,
    ∃ sign : ℤ, (sign = 1 ∨ sign = -1) ∧
      ∀ (torusParameter : Kˣ) (parameter : K),
        weylElement rootElement simple torusParameter * rootElement root parameter *
            (weylElement rootElement simple torusParameter)⁻¹ =
          rootElement (reflection cartan simple root)
            ((sign : K) *
              ((torusParameter ^ (-(∑ index : Fin rank, cartan simple index * root index)) :
                Kˣ) : K) * parameter)

/-- A Steinberg system: Steinberg data on a group with trivial center, i.e. axioms (S0)–(S4) of
[Steinberg1962]. -/
structure SteinbergSystem {rank : ℕ} (cartan : Matrix (Fin rank) (Fin rank) ℤ)
    (finiteType : TauCeti.IsFiniteType cartan) (K G : Type*)
    [Field K] [Finite K] [Group G] extends SteinbergData cartan finiteType K G where
  /-- (S4) `G` has trivial center. -/
  center_eq_bot : Subgroup.center G = ⊥

section Additive

variable {K G : Type*} [Field K] [Group G] {x : K → G}

/-- An additive family `x (a + b) = x a * x b` sends `0` to `1`. -/
theorem map_zero_eq_one_of_additive (hadd : ∀ a b, x (a + b) = x a * x b) : x 0 = 1 := by
  have h := hadd 0 0
  rw [add_zero] at h
  exact mul_eq_left.mp h.symm

/-- An additive family sends `-a` to the inverse of `x a`. -/
theorem inv_eq_of_additive (hadd : ∀ a b, x (a + b) = x a * x b) (a : K) :
    (x a)⁻¹ = x (-a) := by
  have h := hadd a (-a)
  rw [add_neg_cancel, map_zero_eq_one_of_additive hadd] at h
  exact inv_eq_of_mul_eq_one_right h.symm

end Additive

namespace RootScaling

variable {K G : Type*} [Field K] [Group G] {rank : ℕ} {x : (Fin rank → ℤ) → K → G}

/-- If `g` maps `X_δ` to `X_γ` with sign `ε`, then conjugating by `g` transports a root scaling
of `X_δ` to one of `X_γ`. -/
theorem conj {γ δ : Fin rank → ℤ} {g d : G} {ε k : K} (hε : ε * ε = 1)
    (hg : ∀ u, g * x δ u * g⁻¹ = x γ (ε * u)) (hd : RootScaling x δ d k) :
    RootScaling x γ (g * d * g⁻¹) k := by
  intro p
  have h1 : x γ p = g * x δ (ε * p) * g⁻¹ := by
    rw [hg, ← mul_assoc, hε, one_mul]
  have h2 := hd (ε * p)
  calc g * d * g⁻¹ * x γ p * (g * d * g⁻¹)⁻¹
      = g * (d * x δ (ε * p) * d⁻¹) * g⁻¹ := by rw [h1]; group
    _ = x γ (k * p) := by
      rw [h2, hg]
      congr 1
      linear_combination (k * p) * hε

/-- The version of `RootScaling.conj` for conjugation by `g⁻¹`. -/
theorem conj_inv {γ δ : Fin rank → ℤ} {g d : G} {ε k : K} (hε : ε * ε = 1)
    (hg : ∀ u, g * x δ u * g⁻¹ = x γ (ε * u)) (hd : RootScaling x γ d k) :
    RootScaling x δ (g⁻¹ * d * g) k := by
  have hg' : ∀ u, g⁻¹ * x γ u * g⁻¹⁻¹ = x δ (ε * u) := by
    intro u
    have h := hg (ε * u)
    rw [← mul_assoc, hε, one_mul] at h
    rw [inv_inv, ← h]
    group
  simpa using conj hε hg' hd

end RootScaling

namespace SteinbergData

variable {rank : ℕ} {cartan : Matrix (Fin rank) (Fin rank) ℤ}
  {finiteType : TauCeti.IsFiniteType cartan} {K G : Type*} [Field K] [Finite K] [Group G]

theorem rootElement_zero (data : SteinbergData cartan finiteType K G)
    {γ : Fin rank → ℤ} (hγ : γ ∈ roots finiteType ∅) :
    data.rootElement γ 0 = 1 :=
  map_zero_eq_one_of_additive (data.rootElement_add γ hγ)

theorem rootElement_inv (data : SteinbergData cartan finiteType K G)
    {γ : Fin rank → ℤ} (hγ : γ ∈ roots finiteType ∅) (a : K) :
    (data.rootElement γ a)⁻¹ = data.rootElement γ (-a) :=
  inv_eq_of_additive (data.rootElement_add γ hγ) a

/-- The commutator `[x_α(t), x_β(u)]` is `x_{α+β}(c t u)` for a unit `c`, whenever `α + β` is the
only positive combination of `α` and `β` that is a root. -/
def HasUnitCommutatorConstants (data : SteinbergData cartan finiteType K G) : Prop :=
  ∀ firstRoot ∈ roots finiteType ∅, ∀ secondRoot ∈ roots finiteType ∅,
    firstRoot + secondRoot ∈ roots finiteType ∅ →
    (∀ first second : ℕ, 0 < first → 0 < second →
      first • firstRoot + second • secondRoot ∈ roots finiteType ∅ →
        first = 1 ∧ second = 1) →
    ∃ constant : Kˣ, ∀ firstParameter secondParameter : K,
      data.rootElement firstRoot firstParameter *
          data.rootElement secondRoot secondParameter *
          (data.rootElement firstRoot firstParameter)⁻¹ *
          (data.rootElement secondRoot secondParameter)⁻¹ =
        data.rootElement (firstRoot + secondRoot)
          ((constant : K) * firstParameter * secondParameter)

/-- Adding centerlessness (S4) to Steinberg data gives a Steinberg system. -/
def toSystem (data : SteinbergData cartan finiteType K G)
    (center : Subgroup.center G = ⊥) : SteinbergSystem cartan finiteType K G :=
  { data with center_eq_bot := center }

end SteinbergData

end CFSGCorollary
