module

public import CFSG.LieType.Universal.Unitary.Basic
public import CFSG.LieType.Universal.SpecialLinearRoots.SignedPerm
import all CFSG.LieType.Universal.Unitary.Basic
import CFSG.LieType.Universal.Unitary.Roots.Monomial

/-!
# Monomial and diagonal elements of `SU`

Let `M ∈ SU σ n` have a signed permutation matrix `signedPerm π ε`, where `π` commutes with
`Fin.rev`. We show that the signs satisfy `σ (ε s) * ε (rev s) = 1`, and compute the conjugates by
`M` of short root elements, Heisenberg root elements and diagonal elements. We also construct
diagonal elements of `SU` and show that they commute.

## Main results

* `TwistedA.conj_rootHom_of_coe_eq_signedPerm`, `TwistedA.map_conj_range_rootHom`: conjugating
  short root elements and short root groups by a monomial element.
* `TwistedA.coe_conj_eq_heisenbergMatrix`, `TwistedA.map_conj_heisenbergSubgroup`: the same for
  Heisenberg root elements and groups.
* `TwistedA.coe_conj_eq_diagonal`: conjugating a diagonal element by a monomial element.
* `TwistedA.exists_su_coe_eq_diagonal`: diagonal elements of `SU`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedA

open CFSG.LieType.Universal.Unitary CFSG.LieType.Universal.SpecialLinear

section

variable {F : Type*} [Field F] {σ : F ≃+* F} (hσ : ∀ c : F, σ (σ c) = c) {n : ℕ}
  {π : Equiv.Perm (Fin n)} {ε : Fin n → F} {M : SU σ n}

private theorem perm_eq_of_rev_eq_self {n : ℕ} {π : Equiv.Perm (Fin n)}
    (hπ : ∀ s, π (Fin.rev s) = Fin.rev (π s)) {k : Fin n} (hk : Fin.rev k = k) : π k = k := by
  have h1 := hπ k
  rw [hk] at h1
  apply Fin.ext
  have h2 := congrArg Fin.val h1
  have h3 := congrArg Fin.val hk
  rw [Fin.val_rev] at h2 h3
  omega

private theorem coe_mul_coe_inv {n : ℕ} (M : SU σ n) :
    ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) *
      (((M : GL (Fin n) F)⁻¹ : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = 1 := by
  rw [← Units.val_mul, mul_inv_cancel]; rfl

private theorem coe_inv_mul_coe {n : ℕ} (M : SU σ n) :
    (((M : GL (Fin n) F)⁻¹ : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) *
      ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = 1 := by
  rw [← Units.val_mul, inv_mul_cancel]; rfl

private theorem coe_conj_eq_of_mul_eq {n : ℕ} (M : SU σ n) {X Y : Matrix (Fin n) (Fin n) F}
    (h : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) * X =
      Y * ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F)) :
    ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) * X *
      (((M : GL (Fin n) F)⁻¹ : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Y := by
  rw [h, Matrix.mul_assoc, coe_mul_coe_inv, Matrix.mul_one]

private theorem conj_eq_of_mul_eq {n : ℕ} (M x y : SU σ n)
    (h : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) * ((y : GL (Fin n) F) : Matrix _ _ F) =
      ((x : GL (Fin n) F) : Matrix _ _ F) * ((M : GL (Fin n) F) : Matrix _ _ F)) :
    M * y * M⁻¹ = x := by
  rw [mul_inv_eq_iff_eq_mul]
  exact Subtype.ext (Units.ext h)

/-- The signs of a monomial element of `SU` are unitary. -/
theorem apply_mul_rev_eq_one_of_coe_eq_signedPerm
    (hM : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm π ε)
    (hπ : ∀ s, π (Fin.rev s) = Fin.rev (π s)) (s : Fin n) :
    σ (ε s) * ε (Fin.rev s) = 1 := by
  have h := M.2.2
  rw [hM] at h
  have h2 := congr_fun (congr_fun h s) (Fin.rev s)
  simp only [Matrix.mul_apply, conjTr, antidiag, signedPerm_apply, Matrix.transpose_apply,
    Matrix.map_apply, Matrix.of_apply] at h2
  rw [Finset.sum_eq_single (π s.rev) (fun j _ hj ↦ by simp [hj]) (by simp),
    Finset.sum_eq_single (π s) (fun j _ hj ↦ by simp [hj]) (by simp), hπ] at h2
  simpa using h2

/-- The signs of a monomial element of `SU` are nonzero. -/
theorem ne_zero_of_coe_eq_signedPerm
    (hM : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm π ε)
    (hπ : ∀ s, π (Fin.rev s) = Fin.rev (π s)) (s : Fin n) : ε s ≠ 0 :=
  ne_zero_of_unitary (apply_mul_rev_eq_one_of_coe_eq_signedPerm hM hπ) s

/-- Conjugating a Heisenberg root element by a monomial element. -/
theorem coe_conj_eq_heisenbergMatrix
    (hM : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm π ε)
    (hπ : ∀ s, π (Fin.rev s) = Fin.rev (π s))
    {i k : Fin n} (hk : Fin.rev k = k) {x : SU σ n} {a b : F}
    (hx : ((x : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = heisenbergMatrix σ i k a b) :
    ((M * x * M⁻¹ : SU σ n) : GL (Fin n) F).val =
      heisenbergMatrix σ (π i) k (ε i * a * (ε k)⁻¹) (ε i * b * (ε (Fin.rev i))⁻¹) := by
  have hd := apply_mul_rev_eq_one_of_coe_eq_signedPerm hM hπ
  have hπk := perm_eq_of_rev_eq_self hπ hk
  have e : ((M * x * M⁻¹ : SU σ n) : GL (Fin n) F).val =
      ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) * ((x : GL (Fin n) F) : Matrix _ _ F) *
        (((M : GL (Fin n) F)⁻¹ : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) := by
    simp [Matrix.mul_assoc]
  have := coe_conj_eq_of_mul_eq M (X := heisenbergMatrix σ i k a b)
    (Y := heisenbergMatrix σ (π i) k (ε i * a * (ε k)⁻¹) (ε i * b * (ε (Fin.rev i))⁻¹)) (by
      rw [hM]; exact signedPerm_mul_heisenbergMatrix hπ hd i hk hπk a b)
  rw [e, hx]; exact this

/-- Conjugating a diagonal element by a monomial element. -/
theorem coe_conj_eq_diagonal
    (hM : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm π ε)
    {D : SU σ n} {t : Fin n → F}
    (hD : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal t) :
    ((M * D * M⁻¹ : SU σ n) : GL (Fin n) F).val = Matrix.diagonal (fun s ↦ t (π.symm s)) := by
  have e : ((M * D * M⁻¹ : SU σ n) : GL (Fin n) F).val =
      ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) * ((D : GL (Fin n) F) : Matrix _ _ F) *
        (((M : GL (Fin n) F)⁻¹ : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) := by
    simp [Matrix.mul_assoc]
  rw [e, hD]
  exact coe_conj_eq_of_mul_eq M (by rw [hM]; exact signedPerm_mul_diagonal π ε t)

include hσ

/-- Conjugating a short root element by a monomial element. -/
theorem conj_rootHom_of_coe_eq_signedPerm
    (hM : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm π ε)
    (hπ : ∀ s, π (Fin.rev s) = Fin.rev (π s))
    {i j : Fin n} (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j) (c : Multiplicative F) :
    M * rootHom σ hσ hij hi hj c * M⁻¹ =
      rootHom σ hσ (fun h ↦ hij (π.injective h))
        (by rw [← hπ]; exact fun h ↦ hi (π.injective h))
        (by rw [← hπ]; exact fun h ↦ hj (π.injective h))
        (Multiplicative.ofAdd (ε i * Multiplicative.toAdd c * (ε j)⁻¹)) := by
  have hd := apply_mul_rev_eq_one_of_coe_eq_signedPerm hM hπ
  apply conj_eq_of_mul_eq
  simp only [coe_rootHom, hM]
  exact signedPerm_mul_rootMatrix hπ hd _ _ _

/-- Conjugating the short root group `S(i, j)` by a monomial element gives `S(π i, π j)`. -/
theorem map_conj_range_rootHom
    (hM : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm π ε)
    (hπ : ∀ s, π (Fin.rev s) = Fin.rev (π s))
    {i j : Fin n} (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j) :
    (rootHom σ hσ hij hi hj).range.map (MulAut.conj M).toMonoidHom =
      (rootHom σ hσ (fun h ↦ hij (π.injective h))
        (by rw [← hπ]; exact fun h ↦ hi (π.injective h))
        (by rw [← hπ]; exact fun h ↦ hj (π.injective h))).range := by
  have h0 := ne_zero_of_coe_eq_signedPerm hM hπ
  ext x
  simp only [Subgroup.mem_map, MonoidHom.mem_range, MulEquiv.coe_toMonoidHom, MulAut.conj_apply]
  constructor
  · rintro ⟨y, ⟨c, rfl⟩, rfl⟩
    exact ⟨_, (conj_rootHom_of_coe_eq_signedPerm hσ hM hπ hij hi hj c).symm⟩
  · rintro ⟨c, rfl⟩
    refine ⟨rootHom σ hσ hij hi hj
      (Multiplicative.ofAdd ((ε i)⁻¹ * Multiplicative.toAdd c * ε j)), ⟨_, rfl⟩, ?_⟩
    rw [conj_rootHom_of_coe_eq_signedPerm hσ hM hπ hij hi hj]
    congr 1
    apply Multiplicative.toAdd.injective
    simp only [toAdd_ofAdd]
    field_simp [h0 i, h0 j]

/-- Conjugating the Heisenberg root group `H(i)` by a monomial element gives `H(π i)`. -/
theorem map_conj_heisenbergSubgroup
    (hM : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm π ε)
    (hπ : ∀ s, π (Fin.rev s) = Fin.rev (π s))
    {i k : Fin n} (hi : i ≠ Fin.rev i) (hik : i ≠ k) (hk : Fin.rev k = k)
    (hπk : π k = k) :
    (heisenbergSubgroup σ hσ hi hik hk).map (MulAut.conj M).toMonoidHom =
      heisenbergSubgroup σ hσ (i := π i) (by rw [← hπ]; exact fun h ↦ hi (π.injective h))
        (by rw [← hπk]; exact fun h ↦ hik (π.injective h)) hk := by
  have h0 := ne_zero_of_coe_eq_signedPerm hM hπ
  have hd := apply_mul_rev_eq_one_of_coe_eq_signedPerm hM hπ
  ext x
  simp only [Subgroup.mem_map, MulEquiv.coe_toMonoidHom, MulAut.conj_apply]
  constructor
  · rintro ⟨y, ⟨a, b, hab, hy⟩, rfl⟩
    refine ⟨ε i * a * (ε k)⁻¹, ε i * b * (ε (Fin.rev i))⁻¹,
      heisenberg_rel_of_unitary hd i hk hab, ?_⟩
    exact coe_conj_eq_heisenbergMatrix hM hπ hk hy
  · rintro ⟨a, b, hab, hx⟩
    refine ⟨M⁻¹ * x * M, ⟨(ε i)⁻¹ * a * ε k, (ε i)⁻¹ * b * ε (Fin.rev i), ?_, ?_⟩, by group⟩
    · have hd' : ∀ s, σ ((ε s)⁻¹) * (ε (Fin.rev s))⁻¹ = 1 := by
        intro s
        rw [map_inv₀, map_eq_inv_of_unitary hd s, inv_inv]
        exact mul_inv_cancel₀ (h0 _)
      have := heisenberg_rel_of_unitary hd' i hk hab
      simpa only [inv_inv] using this
    · have key : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) *
          heisenbergMatrix σ i k ((ε i)⁻¹ * a * ε k) ((ε i)⁻¹ * b * ε (Fin.rev i)) =
          heisenbergMatrix σ (π i) k a b * ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) := by
        rw [hM, signedPerm_mul_heisenbergMatrix hπ hd i hk hπk]
        congr 3
        · field_simp [h0 i, h0 k]
        · field_simp [h0 i, h0 (Fin.rev i)]
      have e : (((M⁻¹ * x * M : SU σ n) : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) =
          (((M : GL (Fin n) F)⁻¹ : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) *
            (((x : GL (Fin n) F) : Matrix _ _ F) * ((M : GL (Fin n) F) : Matrix _ _ F)) := by
        simp [Matrix.mul_assoc]
      rw [e, hx, ← key, ← Matrix.mul_assoc, coe_inv_mul_coe, Matrix.one_mul]

/-- A diagonal element acts on the parameters of `S (i, j)` by `c ↦ t i * c * (t j)⁻¹`. -/
theorem conj_rootHom_of_coe_eq_diagonal {D : SU σ n} {t : Fin n → F}
    (hD : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal t)
    {i j : Fin n} (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j) (c : Multiplicative F) :
    D * rootHom σ hσ hij hi hj c * D⁻¹ =
      rootHom σ hσ hij hi hj (Multiplicative.ofAdd (t i * Multiplicative.toAdd c * (t j)⁻¹)) := by
  have hM : ((D : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm 1 t :=
    hD.trans (signedPerm_one t).symm
  exact conj_rootHom_of_coe_eq_signedPerm hσ hM (fun s ↦ rfl) hij hi hj c

end

section

variable {F : Type*} [Field F] {σ : F ≃+* F} {n : ℕ}

/-- A diagonal matrix `diag t` with `∏ t s = 1` and `σ (t s) * t (rev s) = 1` is the matrix of an
element of `SU` (in particular it is invertible). -/
theorem exists_su_coe_eq_diagonal {t : Fin n → F} (hdet : ∏ s, t s = 1)
    (ht : ∀ s, σ (t s) * t (Fin.rev s) = 1) :
    ∃ d : SU σ n, ((d : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal t := by
  have h0 : ∀ s, t s ≠ 0 := by
    intro s h
    have := ht (Fin.rev s)
    rw [Fin.rev_rev, h, mul_zero] at this
    exact zero_ne_one this
  let u : GL (Fin n) F :=
    ⟨Matrix.diagonal t, Matrix.diagonal t⁻¹, by
      rw [Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
      congr 1; funext s
      exact mul_inv_cancel₀ (h0 s), by
      rw [Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
      congr 1; funext s
      exact inv_mul_cancel₀ (h0 s)⟩
  refine ⟨⟨u, ?_⟩, rfl⟩
  rw [mem_SU]
  refine ⟨by simp [u, Matrix.det_diagonal, hdet], ?_⟩
  change conjTr σ (Matrix.diagonal t) * antidiag n * Matrix.diagonal t = antidiag n
  have hc : conjTr σ (Matrix.diagonal t) = Matrix.diagonal (fun s ↦ σ (t s)) := by
    ext i j
    by_cases h : i = j
    · subst h; simp [conjTr]
    · simp [conjTr, Matrix.diagonal_apply_ne _ h, Matrix.diagonal_apply_ne _ (Ne.symm h)]
  rw [hc]
  ext i j
  simp only [antidiag, Matrix.diagonal_mul, Matrix.mul_diagonal, Matrix.of_apply]
  by_cases h : j = Fin.rev i
  · subst h
    simp only [ite_true]
    have := ht i
    rw [mul_one, mul_comm]; exact (by simpa [mul_comm] using this)
  · simp [h]

/-- Elements of `SU` with diagonal matrices commute. -/
theorem commute_of_coe_eq_diagonal {g h : SU σ n} {a b : Fin n → F}
    (hg : ((g : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal a)
    (hh : ((h : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = Matrix.diagonal b) :
    Commute g h := by
  apply Subtype.ext
  apply Units.ext
  change ((g : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) * ((h : GL (Fin n) F) : Matrix _ _ F) =
    ((h : GL (Fin n) F) : Matrix _ _ F) * ((g : GL (Fin n) F) : Matrix _ _ F)
  rw [hg, hh, Matrix.diagonal_mul_diagonal, Matrix.diagonal_mul_diagonal]
  congr 1
  funext s
  exact mul_comm _ _

end

end CFSGCorollary.TwistedA
