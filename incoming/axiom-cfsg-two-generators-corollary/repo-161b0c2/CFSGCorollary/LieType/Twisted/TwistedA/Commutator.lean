module

public import CFSG.LieType.Universal.Unitary.Basic
import Mathlib.Tactic.LinearCombination

/-!
# Commutator relations in `SU`

Commutator relations between the short root elements `rootHom`, the long root elements
`longRootHom` and the Heisenberg root groups `heisenbergSubgroup` of `SU σ n`, and their
consequences for subgroups: a subgroup containing suitable root groups contains the root groups
obtained as their commutators.

## Main results

* `TwistedA.commutator_rootHom_rootHom`, `TwistedA.range_rootHom_le_of_range_le`:
  `[S(a, b), S(b, c)] = S(a, c)`.
* `TwistedA.commutator_rootHom_rootHom_rev`, `TwistedA.range_longRootHom_le_of_range_rootHom_le`:
  `[S(a, b), S(b, rev a)] = L(a)`.
* `TwistedA.commutator_eq_rootHom_of_coe_eq_heisenbergMatrix`,
  `TwistedA.range_rootHom_le_of_heisenbergSubgroup_le`: `[H(i), H(rev k)] = S(i, k)`.
* `TwistedA.rootHom_rev`, `TwistedA.range_rootHom_rev`: `S(i, j) = S(rev j, rev i)`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedA

open CFSG.LieType.Universal.Unitary
open scoped commutatorElement

variable {F : Type*} [Field F] {σ : F ≃+* F} {n : ℕ}

/-- If `w + σ w = 1` then every trace-zero element is of the form `x y - σ (x y)`. -/
theorem traceZero_eq_sub {w : F} (hw : w + σ w = 1) (c : traceZero σ) :
    (c : F) = 1 * ((c : F) * w) - σ (1 * ((c : F) * w)) := by
  have hc : (c : F) + σ (c : F) = 0 := c.2
  have : σ (c : F) = -(c : F) := eq_neg_of_add_eq_zero_right hc
  rw [one_mul, map_mul, this]
  linear_combination (-(c : F)) * hw

variable (hσ : ∀ c : F, σ (σ c) = c)

include hσ

/-- Commutator of short root elements. -/
theorem commutator_rootHom_rootHom {a b c : Fin n} (hab : a ≠ b) (hbc : b ≠ c) (hac : a ≠ c)
    (ha : a ≠ Fin.rev a) (hb : b ≠ Fin.rev b) (hc : c ≠ Fin.rev c)
    (hba : b ≠ Fin.rev a) (hcb : c ≠ Fin.rev b) (x y : F) :
    ⁅rootHom σ hσ hab ha hb (Multiplicative.ofAdd x),
      rootHom σ hσ hbc hb hc (Multiplicative.ofAdd y)⁆ =
      rootHom σ hσ hac ha hc (Multiplicative.ofAdd (x * y)) := by
  have key : rootHom σ hσ hab ha hb (Multiplicative.ofAdd x) *
      rootHom σ hσ hbc hb hc (Multiplicative.ofAdd y) =
      rootHom σ hσ hac ha hc (Multiplicative.ofAdd (x * y)) *
      (rootHom σ hσ hbc hb hc (Multiplicative.ofAdd y) *
        rootHom σ hσ hab ha hb (Multiplicative.ofAdd x)) := by
    apply Subtype.ext
    apply Units.ext
    simp only [Subgroup.coe_mul, Units.val_mul]
    change rootMatrix σ a b x * rootMatrix σ b c y =
      rootMatrix σ a c (x * y) * (rootMatrix σ b c y * rootMatrix σ a b x)
    simp only [rootMatrix, map_mul]
    simp only [Matrix.add_mul, Matrix.mul_add, Matrix.sub_mul, Matrix.mul_sub, Matrix.one_mul,
      Matrix.mul_one]
    have e1 : a ≠ Fin.rev b := fun h ↦ hba (by rw [← Fin.rev_rev b, ← h])
    have e3 : b ≠ Fin.rev c := fun h ↦ hcb (by rw [← Fin.rev_rev c, ← h])
    have e4 : Fin.rev a ≠ Fin.rev b := fun h ↦ hab (Fin.rev_inj.1 h)
    have e5 : Fin.rev a ≠ Fin.rev c := fun h ↦ hac (Fin.rev_inj.1 h)
    simp only [Matrix.single_mul_single_same, Matrix.single_mul_single_of_ne, hc, hcb, e3, e4, e5,
      hbc.symm, hac.symm, ha.symm, hba.symm, e1.symm, ne_eq, not_false_eq_true, Matrix.mul_zero]
    rw [mul_comm (σ y) (σ x)]
    abel
  rw [commutatorElement_def, key]
  group

/-- `S(a, b), S(b, c) ≤ R` implies `S(a, c) ≤ R`. -/
theorem range_rootHom_le_of_range_le {a b c : Fin n} (hab : a ≠ b) (hbc : b ≠ c) (hac : a ≠ c)
    (ha : a ≠ Fin.rev a) (hb : b ≠ Fin.rev b) (hc : c ≠ Fin.rev c)
    (hba : b ≠ Fin.rev a) (hcb : c ≠ Fin.rev b)
    {R : Subgroup (SU σ n)} (h₁ : (rootHom σ hσ hab ha hb).range ≤ R)
    (h₂ : (rootHom σ hσ hbc hb hc).range ≤ R) :
    (rootHom σ hσ hac ha hc).range ≤ R := by
  rintro _ ⟨z, rfl⟩
  have h := commutator_rootHom_rootHom hσ hab hbc hac ha hb hc hba hcb
    (Multiplicative.toAdd z) 1
  rw [mul_one] at h
  have h' : rootHom σ hσ hac ha hc z =
      ⁅rootHom σ hσ hab ha hb z, rootHom σ hσ hbc hb hc (Multiplicative.ofAdd (1 : F))⁆ :=
    h.symm
  rw [h', commutatorElement_def]
  exact mul_mem (mul_mem (mul_mem (h₁ ⟨_, rfl⟩) (h₂ ⟨_, rfl⟩)) (inv_mem (h₁ ⟨_, rfl⟩)))
    (inv_mem (h₂ ⟨_, rfl⟩))

/-- `z - σ z` has trace zero. -/
theorem sub_apply_mem_traceZero (z : F) : z - σ z ∈ traceZero σ := by
  change z - σ z + σ (z - σ z) = 0
  rw [map_sub, hσ]; ring

/-- Commutator giving long root elements. -/
theorem commutator_rootHom_rootHom_rev {a b : Fin n} (ha : a ≠ Fin.rev a) (hb : b ≠ Fin.rev b)
    (hab : a ≠ b) (hba : b ≠ Fin.rev a) (x y : F) :
    ⁅rootHom σ hσ hab ha hb (Multiplicative.ofAdd x),
      rootHom σ hσ hba hb (by rw [Fin.rev_rev]; exact ha.symm) (Multiplicative.ofAdd y)⁆ =
      longRootHom σ ha (Multiplicative.ofAdd
        ⟨x * y - σ (x * y), sub_apply_mem_traceZero hσ _⟩) := by
  have hra : Fin.rev a ≠ a := fun h ↦ ha h.symm
  have hrb : Fin.rev b ≠ b := fun h ↦ hb h.symm
  have hba' : b ≠ a := fun h ↦ hab h.symm
  have hrab : Fin.rev b ≠ a := fun h ↦ hba (by rw [← h, Fin.rev_rev])
  have hrarb : Fin.rev a ≠ Fin.rev b := fun h ↦ hab (Fin.rev_injective h)
  have hbra : Fin.rev a ≠ b := fun h ↦ hba h.symm
  apply Subtype.ext
  apply Units.ext
  rw [commutatorElement_def]
  simp only [← map_inv, ← ofAdd_neg]
  change rootMatrix σ a b x * rootMatrix σ b (Fin.rev a) y * rootMatrix σ a b (-x) *
    rootMatrix σ b (Fin.rev a) (-y) = longRootMatrix a (x * y - σ (x * y))
  simp only [rootMatrix, longRootMatrix, Fin.rev_rev]
  simp only [Matrix.add_mul, Matrix.mul_add, Matrix.sub_mul, Matrix.mul_sub, Matrix.one_mul,
    Matrix.mul_one, Matrix.single_mul_single_same, Matrix.single_mul_single_of_ne _ _ _ _ hba',
    Matrix.single_mul_single_of_ne _ _ _ _ hrab, Matrix.single_mul_single_of_ne _ _ _ _ hrarb,
    Matrix.single_mul_single_of_ne _ _ _ _ hbra, Matrix.single_mul_single_of_ne _ _ _ _ hb,
    Matrix.single_mul_single_of_ne _ _ _ _ hrb, Matrix.single_mul_single_of_ne _ _ _ _ hra,
    add_zero, sub_zero, mul_neg, neg_mul, map_neg, ← Matrix.single_neg]
  rw [map_mul, sub_eq_add_neg (x * y), Matrix.single_add, ← Matrix.single_neg, mul_comm (σ y)]
  abel

/-- `S(a, b), S(b, rev a) ≤ R` implies `L(a) ≤ R` (when `w + σ w = 1` has a solution). -/
theorem range_longRootHom_le_of_range_rootHom_le {a b : Fin n} (ha : a ≠ Fin.rev a)
    (hb : b ≠ Fin.rev b) (hab : a ≠ b) (hba : b ≠ Fin.rev a) (hw : ∃ w : F, w + σ w = 1)
    {R : Subgroup (SU σ n)} (h₁ : (rootHom σ hσ hab ha hb).range ≤ R)
    (h₂ : (rootHom σ hσ hba hb (by rw [Fin.rev_rev]; exact ha.symm)).range ≤ R) :
    (longRootHom σ ha).range ≤ R := by
  obtain ⟨w, hw⟩ := hw
  rintro _ ⟨z, rfl⟩
  obtain ⟨c, rfl⟩ : ∃ c : traceZero σ, Multiplicative.ofAdd c = z :=
    ⟨Multiplicative.toAdd z, rfl⟩
  have h := commutator_rootHom_rootHom_rev hσ ha hb hab hba 1 ((c : F) * w)
  have e : (⟨1 * ((c : F) * w) - σ (1 * ((c : F) * w)), sub_apply_mem_traceZero hσ _⟩ :
      traceZero σ) = c :=
    Subtype.ext (traceZero_eq_sub hw c).symm
  rw [e] at h
  rw [← h, commutatorElement_def]
  exact mul_mem (mul_mem (mul_mem (h₁ ⟨_, rfl⟩) (h₂ ⟨_, rfl⟩)) (inv_mem (h₁ ⟨_, rfl⟩)))
    (inv_mem (h₂ ⟨_, rfl⟩))

section

open Matrix

private theorem heisenbergMatrix_mul_heisenbergMatrix {i j k : Fin n} (hi : i ≠ Fin.rev i)
    (hj : j ≠ Fin.rev j) (hik : i ≠ k) (hjk : j ≠ k) (hk : Fin.rev k = k) (hji : j ≠ Fin.rev i)
    (a b a' b' : F) :
    heisenbergMatrix σ i k a b * heisenbergMatrix σ j k a' b' =
      rootMatrix σ i (Fin.rev j) (-a * σ a') *
        (heisenbergMatrix σ j k a' b' * heisenbergMatrix σ i k a b) := by
  have h1 : Fin.rev i ≠ k := fun h ↦ hik (by rw [← Fin.rev_rev i, h, hk])
  have h2 : Fin.rev j ≠ k := fun h ↦ hjk (by rw [← Fin.rev_rev j, h, hk])
  have h3 : Fin.rev j ≠ i := fun h ↦ hji (by rw [← h, Fin.rev_rev])
  have h5 : Fin.rev i ≠ j := fun h ↦ hji h.symm
  have h6 : k ≠ i := hik.symm
  have h7 : k ≠ j := hjk.symm
  simp only [heisenbergMatrix, rootMatrix, add_mul, mul_add, sub_mul, mul_sub, one_mul, mul_one,
    single_mul_single_same, Fin.rev_rev, map_neg, map_mul, hσ]
  simp only [ne_eq, not_false_eq_true, single_mul_single_of_ne, add_zero, sub_zero, neg_mul,
    mul_comm, mul_neg, mul_zero, sub_self, h1, h2, h3, h5, h6, h7, hi.symm, hj.symm]
  rw [← single_neg, ← single_neg]
  abel

/-- Every Heisenberg matrix with admissible parameters is the matrix of an element of the
Heisenberg subgroup. -/
theorem exists_mem_heisenbergSubgroup_coe_eq {i k : Fin n} (hi : i ≠ Fin.rev i) (hik : i ≠ k)
    (hk : Fin.rev k = k) {a b : F} (hab : b + σ b + σ a * a = 0) :
    ∃ x : SU σ n, x ∈ heisenbergSubgroup σ hσ hi hik hk ∧
      ((x : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = heisenbergMatrix σ i k a b := by
  have h1 : heisenbergMatrix σ i k a b * heisenbergMatrix σ i k (-a) (-b - a * σ a) = 1 := by
    rw [heisenbergMatrix_mul σ hi hik hk, map_neg]
    have h1 : a + -a = 0 := add_neg_cancel a
    have h2 : b + (-b - a * σ a) - a * -σ a = 0 := by ring
    rw [h1, h2, heisenbergMatrix_zero]
  have h2 : heisenbergMatrix σ i k (-a) (-b - a * σ a) * heisenbergMatrix σ i k a b = 1 := by
    rw [heisenbergMatrix_mul σ hi hik hk]
    have h1 : -a + a = 0 := neg_add_cancel a
    have h2 : -b - a * σ a + b - -a * σ a = 0 := by ring
    rw [h1, h2, heisenbergMatrix_zero]
  let g : GL (Fin n) F := ⟨heisenbergMatrix σ i k a b, heisenbergMatrix σ i k (-a) (-b - a * σ a),
    h1, h2⟩
  have hg : g ∈ SU σ n :=
    ⟨det_heisenbergMatrix σ hi hik hk _ _, heisenbergMatrix_isometry σ hσ hi hik hk hab⟩
  exact ⟨⟨g, hg⟩, ⟨a, b, hab, rfl⟩, rfl⟩

/-- Commutator of Heisenberg root elements. -/
theorem commutator_eq_rootHom_of_coe_eq_heisenbergMatrix {i j k : Fin n} (hi : i ≠ Fin.rev i)
    (hj : j ≠ Fin.rev j) (hik : i ≠ k) (hjk : j ≠ k) (hk : Fin.rev k = k) (hji : j ≠ Fin.rev i)
    {x : SU σ n} {y : SU σ n} {a b a' b' : F}
    (hx : x ∈ heisenbergSubgroup σ hσ hi hik hk ∧
      ((x : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = heisenbergMatrix σ i k a b)
    (hy : y ∈ heisenbergSubgroup σ hσ hj hjk hk ∧
      ((y : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = heisenbergMatrix σ j k a' b') :
    ⁅x, y⁆ = rootHom σ hσ (fun h ↦ hji (by rw [h, Fin.rev_rev]))
      hi (by rw [Fin.rev_rev]; exact hj.symm) (Multiplicative.ofAdd (-a * σ a')) := by
  set r := rootHom σ hσ (fun h ↦ hji (by rw [h, Fin.rev_rev]))
      hi (by rw [Fin.rev_rev]; exact hj.symm) (Multiplicative.ofAdd (-a * σ a')) with hr
  have key : x * y = r * (y * x) := by
    apply Subtype.ext
    apply Units.ext
    change ((x : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) * ((y : GL (Fin n) F) : Matrix _ _ F)
      = rootMatrix σ i (Fin.rev j) (-a * σ a') *
        (((y : GL (Fin n) F) : Matrix _ _ F) * ((x : GL (Fin n) F) : Matrix _ _ F))
    rw [hx.2, hy.2]
    exact heisenbergMatrix_mul_heisenbergMatrix hσ hi hj hik hjk hk hji a b a' b'
  rw [commutatorElement_def, key]
  group

/-- `H(i), H(rev k) ≤ R` implies `S(i, k) ≤ R`. -/
theorem range_rootHom_le_of_heisenbergSubgroup_le {i k m : Fin n} (hi : i ≠ Fin.rev i)
    (hk : k ≠ Fin.rev k) (hik : i ≠ k) (hm : Fin.rev m = m)
    (him : i ≠ m) (hkm : Fin.rev k ≠ m)
    (htr : ∀ t : F, σ t = t → ∃ b : F, b + σ b = t)
    {R : Subgroup (SU σ n)}
    (h₁ : heisenbergSubgroup σ hσ hi him hm ≤ R)
    (h₂ : heisenbergSubgroup σ hσ (by rw [Fin.rev_rev]; exact hk.symm) hkm hm ≤ R) :
    (rootHom σ hσ hik hi hk).range ≤ R := by
  rintro g ⟨c, rfl⟩
  obtain ⟨b, hb⟩ := htr (-(σ (c.toAdd) * c.toAdd)) (by rw [map_neg, map_mul, hσ, mul_comm])
  obtain ⟨b', hb'⟩ := htr (-1) (by rw [map_neg, map_one])
  obtain ⟨x, hx⟩ := exists_mem_heisenbergSubgroup_coe_eq hσ hi him hm (a := -c.toAdd) (b := b)
    (by rw [map_neg, neg_mul_neg]; linear_combination hb)
  obtain ⟨y, hy⟩ := exists_mem_heisenbergSubgroup_coe_eq hσ
    (by rw [Fin.rev_rev]; exact hk.symm : Fin.rev k ≠ Fin.rev (Fin.rev k)) hkm hm
    (a := 1) (b := b') (by rw [map_one]; linear_combination hb')
  have hrk : Fin.rev k ≠ Fin.rev i := fun h ↦ hik (Fin.rev_injective h).symm
  have hc := commutator_eq_rootHom_of_coe_eq_heisenbergMatrix hσ hi
    (by rw [Fin.rev_rev]; exact hk.symm) him hkm hm hrk hx hy
  have e : rootHom σ hσ hik hi hk c = ⁅x, y⁆ := by
    apply Subtype.ext
    apply Units.ext
    rw [coe_rootHom, hc]
    simp only [Fin.rev_rev, neg_neg, map_one, mul_one]
    rfl
  rw [e]
  have hx' := h₁ hx.1
  have hy' := h₂ hy.1
  rw [commutatorElement_def]
  exact R.mul_mem (R.mul_mem (R.mul_mem hx' hy') (R.inv_mem hx')) (R.inv_mem hy')

end

/-- `rootMatrix σ i j c = rootMatrix σ (rev j) (rev i) (-σ c)`. -/
theorem rootMatrix_rev (i j : Fin n) (c : F) :
    rootMatrix σ i j c = rootMatrix σ (Fin.rev j) (Fin.rev i) (-σ c) := by
  simp only [rootMatrix, map_neg, hσ, Fin.rev_rev]
  rw [← Matrix.single_neg, ← Matrix.single_neg]
  abel

/-- `S(i, j)(c) = S(rev j, rev i)(-σ c)`. -/
theorem rootHom_rev {i j : Fin n} (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j)
    (c : Multiplicative F) :
    rootHom σ hσ hij hi hj c =
      rootHom σ hσ (fun h ↦ hij (Fin.rev_injective h).symm)
        (by rw [Fin.rev_rev]; exact hj.symm) (by rw [Fin.rev_rev]; exact hi.symm)
        (Multiplicative.ofAdd (-σ (Multiplicative.toAdd c))) := by
  apply Subtype.ext
  apply Units.ext
  exact rootMatrix_rev hσ i j _

/-- Each short root group has two names: `S(i, j) = S(rev j, rev i)`. -/
theorem range_rootHom_rev {i j : Fin n} (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j) :
    (rootHom σ hσ hij hi hj).range =
      (rootHom σ hσ (fun h ↦ hij (Fin.rev_injective h).symm)
        (by rw [Fin.rev_rev]; exact hj.symm) (by rw [Fin.rev_rev]; exact hi.symm)).range := by
  ext x
  constructor
  · rintro ⟨c, rfl⟩
    exact ⟨_, (rootHom_rev hσ hij hi hj c).symm⟩
  · rintro ⟨c, rfl⟩
    refine ⟨Multiplicative.ofAdd (-σ (Multiplicative.toAdd c)), ?_⟩
    rw [rootHom_rev hσ hij hi hj]
    simp [hσ]

end CFSGCorollary.TwistedA
