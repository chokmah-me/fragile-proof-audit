module

public import CFSG.LieType.Steinberg.OfCartan
public import CFSG.LieType.Steinberg.Statement
import CFSGCorollary.LieType.Steinberg.Basic

/-!
# Commutator computations for Steinberg systems

This file contains the group-theoretic core of Lemmas 3.10 and 3.12 of [Steinberg1962]: for
`y = x(1) h` (resp. `y = x_r(1) x_s(1) h`), the commutator of `y d y⁻¹` with a diagonal element is
an explicit root element. It also extracts from Chevalley's commutator formula the commutation of
root elements and the single-term commutator `[x_α(c), x_β(d)] = x_{α+β}(C c d)`.

## Main results

* `CFSGCorollary.commutator_conj_rootElement_eq`
* `CFSGCorollary.commutator_conj_rootElement_pair_eq`
* `CFSGCorollary.commute_of_commutatorFormula`
* `CFSGCorollary.commutator_eq_of_commutatorFormula`

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

section Conj

variable {K G : Type*} [Field K] [Group G]

/-- Core computation of [Steinberg1962, 3.10]: for `y = x 1 * h` with `h d h⁻¹ = d₁`, the
commutator of `y d y⁻¹` with a diagonal element `d'` commuting with `d₁` is a root element. -/
theorem commutator_conj_rootElement_eq {x : K → G} (hadd : ∀ a b, x (a + b) = x a * x b)
    {h d d₁ d' : G} {l k : K} (hh : h * d * h⁻¹ = d₁) (hc : Commute d₁ d')
    (hd₁ : ∀ p, d₁ * x p * d₁⁻¹ = x (l * p)) (hd' : ∀ p, d' * x p * d'⁻¹ = x (k * p)) :
    (x 1 * h * d * (x 1 * h)⁻¹) * d' * (x 1 * h * d * (x 1 * h)⁻¹)⁻¹ * d'⁻¹ =
      x ((1 - l) * (1 - k)) := by
  have hw : x 1 * h * d * (x 1 * h)⁻¹ = x (1 - l) * d₁ := by
    have e1 : x 1 * h * d * (x 1 * h)⁻¹ = x 1 * (h * d * h⁻¹) * (x 1)⁻¹ := by group
    rw [e1, hh, inv_eq_of_additive hadd]
    calc x 1 * d₁ * x (-1) = x 1 * (d₁ * x (-1) * d₁⁻¹) * d₁ := by group
      _ = x (1 - l) * d₁ := by
        rw [hd₁, ← hadd]
        congr 2
        ring
  rw [hw]
  have e2 : x (1 - l) * d₁ * d' * (x (1 - l) * d₁)⁻¹ * d'⁻¹ =
      x (1 - l) * (d₁ * d' * d₁⁻¹) * (x (1 - l))⁻¹ * d'⁻¹ := by group
  rw [e2, hc.eq]
  have e3 : x (1 - l) * (d' * d₁ * d₁⁻¹) * (x (1 - l))⁻¹ * d'⁻¹ =
      x (1 - l) * (d' * (x (1 - l))⁻¹ * d'⁻¹) := by group
  rw [e3, inv_eq_of_additive hadd, hd', ← hadd]
  congr 1
  ring

/-- Core computation of [Steinberg1962, 3.12]: for `y = x_r 1 * x_s 1 * h` with `h d h⁻¹ = d₁`,
the commutator of `y d y⁻¹` with `d` is the root element `x_s ((1 - m) * (1 - k))`, provided `d`
centralises `X_r` and acts on `X_s` by `k`, `d₁` commutes with `d` and acts on `X_r`, `X_s` by
`l`, `m`, and `X_r`, `X_s` commute. -/
theorem commutator_conj_rootElement_pair_eq {xr xs : K → G}
    (haddr : ∀ a b, xr (a + b) = xr a * xr b) (hadds : ∀ a b, xs (a + b) = xs a * xs b)
    (hcomm : ∀ a b, Commute (xr a) (xs b))
    {h d d₁ : G} {k l m : K} (hh : h * d * h⁻¹ = d₁) (hc : Commute d₁ d)
    (hdr : ∀ p, d * xr p * d⁻¹ = xr p) (hds : ∀ p, d * xs p * d⁻¹ = xs (k * p))
    (hd₁r : ∀ p, d₁ * xr p * d₁⁻¹ = xr (l * p)) (hd₁s : ∀ p, d₁ * xs p * d₁⁻¹ = xs (m * p)) :
    (xr 1 * xs 1 * h * d * (xr 1 * xs 1 * h)⁻¹) * d *
        (xr 1 * xs 1 * h * d * (xr 1 * xs 1 * h)⁻¹)⁻¹ * d⁻¹ =
      xs ((1 - m) * (1 - k)) := by
  have hw : xr 1 * xs 1 * h * d * (xr 1 * xs 1 * h)⁻¹ = xr (1 - l) * xs (1 - m) * d₁ := by
    have e1 : xr 1 * xs 1 * h * d * (xr 1 * xs 1 * h)⁻¹ =
        xr 1 * xs 1 * (h * d * h⁻¹) * (xs 1)⁻¹ * (xr 1)⁻¹ := by group
    rw [e1, hh, inv_eq_of_additive hadds, inv_eq_of_additive haddr]
    have hP : Commute (xr (l * -1)) (xs 1 * xs (m * -1)) :=
      (hcomm _ 1).mul_right (hcomm _ _)
    calc xr 1 * xs 1 * d₁ * xs (-1) * xr (-1)
        = xr 1 * xs 1 * ((d₁ * xs (-1) * d₁⁻¹) * (d₁ * xr (-1) * d₁⁻¹)) * d₁ := by group
      _ = xr 1 * xs 1 * (xs (m * -1) * xr (l * -1)) * d₁ := by rw [hd₁s, hd₁r]
      _ = xr 1 * ((xs 1 * xs (m * -1)) * xr (l * -1)) * d₁ := by group
      _ = xr 1 * (xr (l * -1) * (xs 1 * xs (m * -1))) * d₁ := by rw [hP.eq]
      _ = (xr 1 * xr (l * -1)) * (xs 1 * xs (m * -1)) * d₁ := by group
      _ = xr (1 - l) * xs (1 - m) * d₁ := by
        rw [← haddr, ← hadds]
        congr 3 <;> ring
  rw [hw]
  have hc' : d₁ * d * d₁⁻¹ = d := by rw [hc.eq]; group
  have e2 : xr (1 - l) * xs (1 - m) * d₁ * d * (xr (1 - l) * xs (1 - m) * d₁)⁻¹ * d⁻¹ =
      xr (1 - l) * xs (1 - m) * (d₁ * d * d₁⁻¹) * (xs (1 - m))⁻¹ * (xr (1 - l))⁻¹ * d⁻¹ := by
    group
  have e3 : xr (1 - l) * xs (1 - m) * d * (xs (1 - m))⁻¹ * (xr (1 - l))⁻¹ * d⁻¹ =
      xr (1 - l) * xs (1 - m) * (d * (xs (1 - m))⁻¹ * d⁻¹) * (d * (xr (1 - l))⁻¹ * d⁻¹) := by
    group
  rw [e2, hc', e3, inv_eq_of_additive hadds, inv_eq_of_additive haddr, hds, hdr]
  have hQ : Commute (xr (1 - l)) (xs ((1 - m) + k * -(1 - m))) := hcomm _ _
  calc xr (1 - l) * xs (1 - m) * xs (k * -(1 - m)) * xr (-(1 - l))
      = xr (1 - l) * xs ((1 - m) + k * -(1 - m)) * xr (-(1 - l)) := by rw [hadds]; group
    _ = xs ((1 - m) + k * -(1 - m)) * (xr (1 - l) * xr (-(1 - l))) := by
        rw [hQ.eq]; group
    _ = xs ((1 - m) * (1 - k)) := by
        rw [← haddr, add_neg_cancel, map_zero_eq_one_of_additive haddr, mul_one]
        congr 1
        ring

end Conj

section CommutatorFormula

open scoped commutatorElement
open CFSG.LieType.RootSystem (roots)
open CFSG.LieType.Steinberg (CommOrder CommutatorFormula)

variable {I : Type} [Fintype I] [DecidableEq I] {A : Matrix I I ℤ}
  {hA : TauCeti.IsFiniteType A} {k : Type*} [Field k] {K : Type*} [Group K]
  {x : (I → ℤ) → k → K}
  {O : CommOrder (CFSG.LieType.Steinberg.RootSystem.ofCartan hA ∅)}
  {C : (I → ℤ) → (I → ℤ) → ℕ × ℕ → ℤ}

/-- If no positive combination of `α, β` is a root, the commutator formula makes the root
elements commute. -/
theorem commute_of_commutatorFormula (hx : CommutatorFormula x O C)
    {α β : I → ℤ} (hα : α ∈ roots hA ∅) (hβ : β ∈ roots hA ∅) (hαβ : α + β ≠ 0)
    (hnone : ∀ i j : ℕ, 0 < i → 0 < j → i • α + j • β ∉ roots hA ∅) (c d : k) :
    Commute (x α c) (x β d) := by
  have hl : O.list α β = [] := by
    refine List.eq_nil_iff_forall_not_mem.2 fun p hp ↦ ?_
    have := (O.mem_iff α hα β hβ hαβ p).1 hp
    exact hnone p.1 p.2 this.1 this.2.1 this.2.2
  have := hx α hα β hβ hαβ c d
  rw [hl] at this
  have h1 : ⁅x α c, x β d⁆ = 1 := by simpa using this
  rwa [commutatorElement_def, mul_inv_eq_one, mul_inv_eq_iff_eq_mul] at h1

/-- If `α + β` is the only positive combination of `α, β` that is a root, then the commutator is
`x (α + β) (C α β (1, 1) * c * d)`. -/
theorem commutator_eq_of_commutatorFormula (hx : CommutatorFormula x O C)
    {α β : I → ℤ} (hα : α ∈ roots hA ∅) (hβ : β ∈ roots hA ∅) (hαβ : α + β ≠ 0)
    (hsum : α + β ∈ roots hA ∅)
    (honly : ∀ i j : ℕ, 0 < i → 0 < j → i • α + j • β ∈ roots hA ∅ → i = 1 ∧ j = 1)
    (c d : k) :
    ⁅x α c, x β d⁆ = x (α + β) ((C α β (1, 1) : k) * c * d) := by
  have hl : O.list α β = [(1, 1)] := by
    have hmem : (1, 1) ∈ O.list α β :=
      (O.mem_iff α hα β hβ hαβ _).2 ⟨one_pos, one_pos, by simpa using hsum⟩
    have hsub : ∀ p ∈ O.list α β, p = (1, 1) := fun p hp ↦ by
      have := (O.mem_iff α hα β hβ hαβ p).1 hp
      exact Prod.ext (honly p.1 p.2 this.1 this.2.1 this.2.2).1
        (honly p.1 p.2 this.1 this.2.1 this.2.2).2
    have hnd := O.nodup α β
    generalize O.list α β = l at hmem hsub hnd ⊢
    cases l with
    | nil => simp at hmem
    | cons a t =>
      have ha := hsub a (by simp)
      subst ha
      cases t with
      | nil => rfl
      | cons b t' =>
        have hb := hsub b (by simp)
        subst hb
        simp at hnd
  have := hx α hα β hβ hαβ c d
  rw [hl] at this
  simpa using this

end CommutatorFormula

end CFSGCorollary
