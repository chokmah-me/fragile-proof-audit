module

public import CFSGCorollary.LieType.LambdaRootGroup.Basic
public import CFSGCorollary.LieType.Twisted.TwistedA.Index
public import CFSG.LieType.BorelTits.UnitaryForm
import CFSG.LieType.Steinberg.CentralExt.UnitaryRootGroups
import CFSGCorollary.LieType.Twisted.TwistedA.Monomial

/-!
# Root groups of the unitary groups

We define the root groups of `SU σ n` used for the two-generation of the unitary groups and
endow them with the structure of `λ`-root groups (`LambdaRootGroup`) with `L = F`:

* for `n ≥ 4`, the short root group `S(0, 1)` with coordinate `x ↦ x 0 1`;
* for `n` odd, the Heisenberg root group `H(0)` of `SU (unitaryInvolution F p f) n` with
  coordinate `x ↦ x 0 μ`, where `μ = n / 2` is the middle index.

We compute the action of diagonal elements on these root groups.

## Main definitions

* `TwistedA.shortRootGroup`: the short root group `S(0, 1)` as a `λ`-root group.
* `TwistedA.heisenbergRootGroup`: the Heisenberg root group `H(0)` as a `λ`-root group.

## Main results

* `TwistedA.nonempty_action_shortRootGroup`, `TwistedA.nonempty_action_heisenbergRootGroup`:
  a diagonal element `diag t` acts on `S(0, 1)` by `t 0 * (t 1)⁻¹` and on `H(0)` by
  `t 0 * (t μ)⁻¹`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedA

open CFSG.LieType.Universal.Unitary CFSG.LieType.BorelTits CFSG.LieType.Universal.SpecialLinear

section

variable {F : Type} [Field F] {σ : F ≃+* F} (hσ : ∀ c : F, σ (σ c) = c) {n : ℕ}

/-- The short root homomorphism for `(0, 1)`. -/
noncomputable def shortRootHom (hn : 4 ≤ n) : Multiplicative F →* SU σ n :=
  rootHom σ hσ
    (lowIdx_ne_succ (n := n) (k := ⟨0, by omega⟩) (by simp; omega))
    (lowIdx_ne_rev_self _) (lowIdx_ne_rev_self _)

/-- The root group `S(0, 1)`. -/
noncomputable def shortRootSubgroup (hn : 4 ≤ n) : Subgroup (SU σ n) :=
  (shortRootHom hσ hn).range

theorem lowIdx_zero_ne_one (hn : 4 ≤ n) :
    lowIdx (n := n) ⟨0, by omega⟩ ≠ lowIdx ⟨1, by omega⟩ :=
  lowIdx_ne_succ (n := n) (k := ⟨0, by omega⟩) (by simp; omega)

/-- The `(0, 1)` entry of `shortRootHom c` is `c`. -/
theorem shortRootHom_apply_entry (hn : 4 ≤ n) (c : Multiplicative F) :
    ((shortRootHom hσ hn c : GL (Fin n) F) : Matrix (Fin n) (Fin n) F)
      (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩) = Multiplicative.toAdd c := by
  unfold shortRootHom
  rw [coe_rootHom]
  have hpq := lowIdx_zero_ne_one (n := n) hn
  have hqp : lowIdx (n := n) ⟨1, by omega⟩ ≠ Fin.rev (lowIdx ⟨0, by omega⟩) :=
    lowIdx_ne_rev _ _
  have h : ¬(Fin.rev (lowIdx (n := n) ⟨1, by omega⟩) = lowIdx ⟨0, by omega⟩ ∧
      Fin.rev (lowIdx (n := n) ⟨0, by omega⟩) = lowIdx ⟨1, by omega⟩) := fun h ↦ hqp h.2.symm
  simp [rootMatrix, Matrix.one_apply_ne hpq, h]

theorem shortRootSubgroup_mul_comm (hn : 4 ≤ n) (x y : shortRootSubgroup hσ hn) :
    x * y = y * x := by
  obtain ⟨x, c, rfl⟩ := x
  obtain ⟨y, d, rfl⟩ := y
  apply Subtype.ext
  change shortRootHom hσ hn c * shortRootHom hσ hn d = shortRootHom hσ hn d * shortRootHom hσ hn c
  rw [← map_mul, ← map_mul, mul_comm]

/-- The short root group `S(0, 1)` is commutative. -/
instance (hn : 4 ≤ n) : IsMulCommutative (shortRootSubgroup hσ hn) :=
  ⟨⟨shortRootSubgroup_mul_comm hσ hn⟩⟩

theorem shortRootSubgroup_entry_mul (hn : 4 ≤ n) (x y : shortRootSubgroup hσ hn) :
    (((x * y : shortRootSubgroup hσ hn) : SU σ n) : GL (Fin n) F).val
      (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩) =
    ((x : SU σ n) : GL (Fin n) F).val (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩) +
    ((y : SU σ n) : GL (Fin n) F).val (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩) := by
  obtain ⟨x, c, rfl⟩ := x
  obtain ⟨y, d, rfl⟩ := y
  change ((shortRootHom hσ hn c * shortRootHom hσ hn d : SU σ n) : GL (Fin n) F).val _ _ = _
  rw [← map_mul]
  simp only [shortRootHom_apply_entry, toAdd_mul]

theorem shortRootSubgroup_eq_one_of_entry_eq_zero (hn : 4 ≤ n) (x : shortRootSubgroup hσ hn)
    (h : ((x : SU σ n) : GL (Fin n) F).val (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩) = 0) :
    x = 1 := by
  obtain ⟨x, c, rfl⟩ := x
  rw [shortRootHom_apply_entry] at h
  have : c = 1 := by simpa using h
  subst this
  apply Subtype.ext
  simp

variable [Finite F]

/-- `S(0, 1)` as a `λ`-root group with `L = F`, `λ x = x 0 1`. -/
noncomputable def shortRootGroup (hn : 4 ≤ n) : LambdaRootGroup (SU σ n) F where
  carrier := shortRootSubgroup hσ hn
  finite := inferInstance
  isNilpotent := inferInstance
  coordinate :=
    { toFun := fun x ↦ Multiplicative.ofAdd
        (((x : SU σ n) : GL (Fin n) F).val (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩))
      map_one' := by
        have := Matrix.one_apply_ne (α := F) (lowIdx_zero_ne_one (n := n) hn)
        simp [this]
      map_mul' := by
        intro x y
        exact congrArg Multiplicative.ofAdd (shortRootSubgroup_entry_mul hσ hn x y) }
  ker_coordinate_le_commutator := by
    intro x hx
    rw [MonoidHom.mem_ker] at hx
    have h0 : ((x : SU σ n) : GL (Fin n) F).val (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩) =
        0 :=
      congrArg Multiplicative.toAdd hx
    rw [shortRootSubgroup_eq_one_of_entry_eq_zero hσ hn x h0]
    exact one_mem _

/-- The coordinate of `shortRootHom c` is `c`. -/
theorem shortRootGroup_coordinate_shortRootHom (hn : 4 ≤ n) (c : Multiplicative F) :
    (shortRootGroup hσ hn).coordinate ⟨shortRootHom hσ hn c, c, rfl⟩ = c :=
  congrArg Multiplicative.ofAdd (shortRootHom_apply_entry hσ hn c)

/-- An element of `SU` with diagonal matrix `t` acts on `(S(0, 1), λ)` by `t 0 * (t 1)⁻¹`. -/
theorem nonempty_action_shortRootGroup (hn : 4 ≤ n) {D : SU σ n} {t : Fin n → F}
    (hD : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal t)
    (u : Fˣ) (hu : (u : F) = t (lowIdx ⟨0, by omega⟩) * (t (lowIdx ⟨1, by omega⟩))⁻¹) :
    Nonempty ((shortRootGroup hσ hn).Action D u) := by
  have key : ∀ c : Multiplicative F, D * shortRootHom hσ hn c * D⁻¹ =
      shortRootHom hσ hn (Multiplicative.ofAdd ((u : F) * Multiplicative.toAdd c)) := by
    intro c
    have := conj_rootHom_of_coe_eq_diagonal hσ hD
      (lowIdx_zero_ne_one (n := n) hn) (lowIdx_ne_rev_self _) (lowIdx_ne_rev_self _) c
    have e : (u : F) * Multiplicative.toAdd c =
        t (lowIdx ⟨0, by omega⟩) * Multiplicative.toAdd c * (t (lowIdx ⟨1, by omega⟩))⁻¹ := by
      rw [hu]; ring
    rw [e]
    exact this
  have hmem : ∀ x : shortRootSubgroup hσ hn,
      D * (x : SU σ n) * D⁻¹ ∈ shortRootSubgroup hσ hn := by
    rintro ⟨x, c, rfl⟩
    change D * shortRootHom hσ hn c * D⁻¹ ∈ shortRootSubgroup hσ hn
    rw [key]
    exact ⟨_, rfl⟩
  let φ : shortRootSubgroup hσ hn →* shortRootSubgroup hσ hn :=
    { toFun := fun x ↦ ⟨D * (x : SU σ n) * D⁻¹, hmem x⟩
      map_one' := by apply Subtype.ext; simp
      map_mul' := by intro x y; apply Subtype.ext; simp [mul_assoc] }
  have hinj : Function.Injective φ := by
    intro x y h
    have h' : D * (x : SU σ n) * D⁻¹ = D * (y : SU σ n) * D⁻¹ := congrArg Subtype.val h
    apply Subtype.ext
    simpa using h'
  refine ⟨⟨MulEquiv.ofBijective φ ⟨hinj, Finite.injective_iff_surjective.mp hinj⟩, ?_, ?_⟩⟩
  · intro x
    rfl
  · rintro ⟨x, c, rfl⟩
    change Multiplicative.toAdd (Multiplicative.ofAdd
      (((D * shortRootHom hσ hn c * D⁻¹ : SU σ n) : GL (Fin n) F).val
        (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩))) = _
    rw [key, shortRootHom_apply_entry]
    change _ = _ * Multiplicative.toAdd (Multiplicative.ofAdd
      (((shortRootHom hσ hn c : SU σ n) : GL (Fin n) F).val
        (lowIdx ⟨0, by omega⟩) (lowIdx ⟨1, by omega⟩)))
    rw [shortRootHom_apply_entry]
    rfl

end

section Generic

variable {K : Type*} [Field K] {σ : K ≃+* K} (hσ : ∀ c : K, σ (σ c) = c) {n : ℕ} {i k : Fin n}
  (hi : i ≠ Fin.rev i) (hik : i ≠ k) (hk : Fin.rev k = k)

include hik hk in
private theorem heisenbergMatrix_apply_ik_of_rev_eq_self (a b : K) :
    heisenbergMatrix σ i k a b i k = a := by
  have h1 : Fin.rev i ≠ k := fun h ↦ hik (by rw [← Fin.rev_rev i, h, hk])
  simp [heisenbergMatrix, Matrix.one_apply_ne hik, Ne.symm hik, h1]

include hi hik hk in
/-- A power of a Heisenberg matrix: `(1 + N) ^ (p ^ 2) = 1` since `N ^ 3 = 0`. -/
theorem heisenbergMatrix_pow_char_sq {p : ℕ} [Fact p.Prime] [CharP K p] (a b : K) :
    (heisenbergMatrix σ i k a b) ^ (p ^ 2) = 1 := by
  have hki : k ≠ Fin.rev i := fun h ↦ hik (by rw [← Fin.rev_rev i, ← h, hk])
  set N : Matrix (Fin n) (Fin n) K :=
    Matrix.single i k a - Matrix.single k (Fin.rev i) (σ a) + Matrix.single i (Fin.rev i) b
    with hN
  have h1 : heisenbergMatrix σ i k a b = 1 + N := by
    rw [heisenbergMatrix, hN]; abel
  have h3 : N ^ 3 = 0 := by
    simp [hN, pow_succ, mul_add, add_mul, mul_sub, sub_mul, Matrix.single_mul_single_of_ne,
      Matrix.single_mul_single_same, hi.symm, hik.symm, hki.symm]
  have : Nonempty (Fin n) := ⟨i⟩
  rw [h1]
  exact CFSG.LieType.Steinberg.one_add_pow_char_sq_eq_one h3

include hσ hi hik hk in
/-- The element of the Heisenberg root group with parameters `(a, b)`. -/
noncomputable def heisenbergElement (a b : K) (hab : b + σ b + σ a * a = 0) :
    heisenbergSubgroup σ hσ hi hik hk :=
  ⟨⟨⟨heisenbergMatrix σ i k a b, heisenbergMatrix σ i k (-a) (-b - a * σ a),
    by
      rw [heisenbergMatrix_mul σ hi hik hk, map_neg, add_neg_cancel,
        show b + (-b - a * σ a) - a * -σ a = 0 by ring, heisenbergMatrix_zero],
    by
      rw [heisenbergMatrix_mul σ hi hik hk, neg_add_cancel,
        show -b - a * σ a + b - -a * σ a = 0 by ring, heisenbergMatrix_zero]⟩,
    det_heisenbergMatrix σ hi hik hk a b, heisenbergMatrix_isometry σ hσ hi hik hk hab⟩,
    a, b, hab, rfl⟩

end Generic

section

variable {F : Type} [Field F] [Finite F] {p f : ℕ} [Fact p.Prime] [CharP F p]
  (hF : Nat.card F = (p ^ f) ^ 2) {n : ℕ}

/-- The Heisenberg root group `H(0)` (`n` odd, `n ≥ 3`). -/
noncomputable def heisenbergRootSubgroup (hodd : n % 2 = 1) (hn : 3 ≤ n) :
    Subgroup (SU (unitaryInvolution F p f) n) :=
  heisenbergSubgroup (unitaryInvolution F p f) (unitaryInvolution_involutive hF)
    (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩) (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)
    (rev_midIdx hodd)

open scoped commutatorElement

/-- `H(0)` is a `p`-group. -/
theorem isPGroup_heisenbergRootSubgroup (hodd : n % 2 = 1) (hn : 3 ≤ n) :
    IsPGroup p (heisenbergRootSubgroup hF hodd hn) := by
  intro x
  refine ⟨2, ?_⟩
  obtain ⟨a, b, hab, hx⟩ := x.2
  apply Subtype.ext
  apply Subtype.ext
  apply Units.ext
  have := heisenbergMatrix_pow_char_sq (σ := unitaryInvolution F p f)
    (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩) (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)
    (rev_midIdx hodd) (p := p) a b
  rw [← hx] at this
  simpa [Units.val_pow_eq_pow_val] using this

private theorem exists_coe_eq_heisenbergMatrix (hodd : n % 2 = 1) (hn : 3 ≤ n)
    (x : heisenbergRootSubgroup hF hodd hn) :
    ∃ a b : F, b + unitaryInvolution F p f b + unitaryInvolution F p f a * a = 0 ∧
      (((x : SU (unitaryInvolution F p f) n) : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) =
      heisenbergMatrix (unitaryInvolution F p f)
        (lowIdx ⟨0, by omega⟩) (midIdx hodd) a b ∧
      ((x : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val (lowIdx ⟨0, by omega⟩)
          (midIdx hodd) = a := by
  obtain ⟨a, b, hab, hx⟩ := x.2
  refine ⟨a, b, hab, hx, ?_⟩
  rw [hx]
  exact heisenbergMatrix_apply_ik_of_rev_eq_self (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)
    (rev_midIdx hodd) a b

private theorem exists_heisenbergRootSubgroup_coe_eq_heisenbergMatrix (hodd : n % 2 = 1)
    (hn : 3 ≤ n) (c : F) :
    ∃ (d : F) (x : heisenbergRootSubgroup hF hodd hn),
      d + unitaryInvolution F p f d + unitaryInvolution F p f c * c = 0 ∧
      (((x : SU (unitaryInvolution F p f) n) : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) =
      heisenbergMatrix (unitaryInvolution F p f)
        (lowIdx ⟨0, by omega⟩) (midIdx hodd) c d := by
  have hσ := unitaryInvolution_involutive (p := p) (f := f) hF
  obtain ⟨d, hd⟩ := exists_add_unitaryInvolution_eq hF
    (a := -unitaryInvolution F p f c * c) (by rw [map_mul, map_neg, hσ]; ring)
  have hab : d + unitaryInvolution F p f d + unitaryInvolution F p f c * c = 0 := by
    rw [hd]; ring
  exact ⟨d, heisenbergElement hσ (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩)
    (lowIdx_ne_midIdx hodd ⟨0, by omega⟩) (rev_midIdx hodd) c d hab, hab, rfl⟩

/-- The coordinate `x ↦ x 0 μ` on `H(0)`. -/
noncomputable def heisenbergCoordinate (hodd : n % 2 = 1) (hn : 3 ≤ n) :
    heisenbergRootSubgroup hF hodd hn →* Multiplicative F where
  toFun x := Multiplicative.ofAdd
    ((((x : SU (unitaryInvolution F p f) n)) : GL (Fin n) F).val
      (lowIdx ⟨0, by omega⟩) (midIdx hodd))
  map_one' := by
    change Multiplicative.ofAdd ((1 : Matrix (Fin n) (Fin n) F)
      (lowIdx ⟨0, by omega⟩) (midIdx hodd)) = 1
    rw [Matrix.one_apply_ne (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)]
    rfl
  map_mul' x y := by
    obtain ⟨a, b, -, hx, hxa⟩ := exists_coe_eq_heisenbergMatrix hF hodd hn x
    obtain ⟨a', b', -, hy, hya⟩ := exists_coe_eq_heisenbergMatrix hF hodd hn y
    have hxy : ((((x * y : heisenbergRootSubgroup hF hodd hn) : SU (unitaryInvolution F p f) n)) :
        GL (Fin n) F).val = heisenbergMatrix (unitaryInvolution F p f) (lowIdx ⟨0, by omega⟩)
          (midIdx hodd) (a + a') (b + b' - a * unitaryInvolution F p f a') := by
      change ((x : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val *
        ((y : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val = _
      rw [hx, hy]
      exact heisenbergMatrix_mul (unitaryInvolution F p f)
        (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩) (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)
        (rev_midIdx hodd) _ _ _ _
    have hxy' : ((((x * y : heisenbergRootSubgroup hF hodd hn) : SU (unitaryInvolution F p f) n)) :
        GL (Fin n) F).val (lowIdx ⟨0, by omega⟩) (midIdx hodd) = a + a' := by
      rw [hxy]
      exact heisenbergMatrix_apply_ik_of_rev_eq_self (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)
        (rev_midIdx hodd) _ _
    change Multiplicative.ofAdd (((((x * y : heisenbergRootSubgroup hF hodd hn) :
        SU (unitaryInvolution F p f) n)) : GL (Fin n) F).val
      (lowIdx ⟨0, by omega⟩) (midIdx hodd)) =
      Multiplicative.ofAdd (((x : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val
      (lowIdx ⟨0, by omega⟩) (midIdx hodd)) *
      Multiplicative.ofAdd (((y : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val
      (lowIdx ⟨0, by omega⟩) (midIdx hodd))
    rw [hxy', hxa, hya]
    rfl

/-- `H(0)` as a `λ`-root group with `L = F` and `λ x = x 0 μ`. -/
noncomputable def heisenbergRootGroup (hodd : n % 2 = 1) (hn : 3 ≤ n) :
    LambdaRootGroup (SU (unitaryInvolution F p f) n) F where
  carrier := heisenbergRootSubgroup hF hodd hn
  finite := inferInstance
  isNilpotent := IsPGroup.isNilpotent (isPGroup_heisenbergRootSubgroup hF hodd hn)
  coordinate := heisenbergCoordinate hF hodd hn
  ker_coordinate_le_commutator := by
    intro x hker
    have hσ := unitaryInvolution_involutive (p := p) (f := f) hF
    have h0 : ((x : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val
        (lowIdx ⟨0, by omega⟩) (midIdx hodd) = 0 :=
      congrArg Multiplicative.toAdd (MonoidHom.mem_ker.mp hker)
    obtain ⟨a₀, b, hab, hx, hxa⟩ := exists_coe_eq_heisenbergMatrix hF hodd hn x
    rw [h0] at hxa
    subst hxa
    simp only [map_zero, mul_zero, add_zero] at hab
    have hσb : unitaryInvolution F p f b = -b := eq_neg_of_add_eq_zero_right hab
    obtain ⟨w, hw⟩ := exists_add_unitaryInvolution_eq hF (a := 1) (map_one _)
    obtain ⟨d, g, -, hg⟩ :=
      exists_heisenbergRootSubgroup_coe_eq_heisenbergMatrix hF hodd hn (-b * w)
    obtain ⟨e, h, -, hh⟩ :=
      exists_heisenbergRootSubgroup_coe_eq_heisenbergMatrix hF hodd hn (1 : F)
    have hgh : g * h = x * (h * g) := by
      apply Subtype.ext
      apply Subtype.ext
      apply Units.ext
      change ((g : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val *
        ((h : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val =
        ((x : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val *
        (((h : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val *
        ((g : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val)
      rw [hg, hh, hx, heisenbergMatrix_mul _
        (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩) (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)
        (rev_midIdx hodd), heisenbergMatrix_mul _
        (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩) (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)
        (rev_midIdx hodd), heisenbergMatrix_mul _
        (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩) (lowIdx_ne_midIdx hodd ⟨0, by omega⟩)
        (rev_midIdx hodd)]
      have hsa : unitaryInvolution F p f (-b * w) = b * unitaryInvolution F p f w := by
        rw [map_mul, map_neg, hσb]; ring
      congr 1
      · ring
      · rw [hsa, map_one]
        linear_combination b * hw
    have hcomm : x = ⁅g, h⁆ := by
      rw [commutatorElement_def, hgh]
      group
    rw [hcomm]
    exact Subgroup.commutator_mem_commutator (Subgroup.mem_top _) (Subgroup.mem_top _)

/-- A diagonal element acts on `(H(0), λ)` by `t 0 * (t μ)⁻¹`. -/
theorem nonempty_action_heisenbergRootGroup (hodd : n % 2 = 1) (hn : 3 ≤ n)
    {D : SU (unitaryInvolution F p f) n} {t : Fin n → F}
    (hD : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal t)
    (u : Fˣ) (hu : (u : F) = t (lowIdx ⟨0, by omega⟩) * (t (midIdx hodd))⁻¹) :
    Nonempty ((heisenbergRootGroup hF hodd hn).Action D u) := by
  have hσ := unitaryInvolution_involutive (p := p) (f := f) hF
  have hi := lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩
  have hik := lowIdx_ne_midIdx hodd ⟨0, by omega⟩
  have hk := rev_midIdx hodd
  have hM : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) =
      signedPerm (1 : Equiv.Perm (Fin n)) t :=
    hD.trans (signedPerm_one t).symm
  have hπ : ∀ s : Fin n, (1 : Equiv.Perm (Fin n)) (Fin.rev s) =
      Fin.rev ((1 : Equiv.Perm (Fin n)) s) := fun s ↦ rfl
  have hmap := map_conj_heisenbergSubgroup hσ hM hπ hi hik hk (π := 1) rfl
  have hmem : ∀ x : heisenbergRootSubgroup hF hodd hn,
      D * (x : SU (unitaryInvolution F p f) n) * D⁻¹ ∈ heisenbergRootSubgroup hF hodd hn :=
    fun x ↦ hmap.le ⟨x, x.2, rfl⟩
  have hmap' : (heisenbergRootSubgroup hF hodd hn).map (MulAut.conj D).toMonoidHom =
      heisenbergRootSubgroup hF hodd hn := hmap
  refine ⟨{
    conjugation :=
      (MulEquiv.subgroupMap (MulAut.conj D) (heisenbergRootSubgroup hF hodd hn)).trans
        (MulEquiv.subgroupCongr hmap')
    coe_conjugation := fun x ↦ rfl
    coordinate_conjugation := ?_ }⟩
  intro x
  obtain ⟨a, b, -, hx, hxa⟩ := exists_coe_eq_heisenbergMatrix hF hodd hn x
  have hc := coe_conj_eq_heisenbergMatrix hM hπ hk (x := (x : SU (unitaryInvolution F p f) n)) hx
  change ((((D * (x : SU (unitaryInvolution F p f) n) * D⁻¹ : SU (unitaryInvolution F p f) n)) :
    GL (Fin n) F).val (lowIdx ⟨0, by omega⟩) (midIdx hodd)) = _
  rw [hc]
  erw [heisenbergMatrix_apply_ik_of_rev_eq_self hik hk]
  rw [hu]
  change _ = _ * (((x : SU (unitaryInvolution F p f) n) : GL (Fin n) F).val
    (lowIdx ⟨0, by omega⟩) (midIdx hodd))
  rw [hxa]
  ring

/-- The element `u_β ∈ H(0)` with matrix `heisenbergMatrix 0 μ 1 β`, so that `λ u_β = 1`. -/
theorem exists_mem_heisenbergRootSubgroup_coe_eq (hodd : n % 2 = 1) (hn : 3 ≤ n) {β : F}
    (hβ : β + unitaryInvolution F p f β = -1) :
    ∃ u : heisenbergRootSubgroup hF hodd hn,
      (((u : SU (unitaryInvolution F p f) n) : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) =
        heisenbergMatrix (unitaryInvolution F p f)
          (lowIdx ⟨0, by omega⟩) (midIdx hodd) 1 β ∧
      Multiplicative.toAdd ((heisenbergRootGroup hF hodd hn).coordinate u) = 1 := by
  have hσ := unitaryInvolution_involutive (p := p) (f := f) hF
  have hab : β + unitaryInvolution F p f β + unitaryInvolution F p f 1 * 1 = 0 := by
    rw [hβ, map_one]; ring
  refine ⟨heisenbergElement hσ (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩)
    (lowIdx_ne_midIdx hodd ⟨0, by omega⟩) (rev_midIdx hodd) 1 β hab, rfl, ?_⟩
  change (heisenbergMatrix (unitaryInvolution F p f)
    (lowIdx ⟨0, by omega⟩) (midIdx hodd) 1 β) (lowIdx ⟨0, by omega⟩) (midIdx hodd) = 1
  exact heisenbergMatrix_apply_ik_of_rev_eq_self
    (lowIdx_ne_midIdx hodd ⟨0, by omega⟩) (rev_midIdx hodd) 1 β

end

end CFSGCorollary.TwistedA
