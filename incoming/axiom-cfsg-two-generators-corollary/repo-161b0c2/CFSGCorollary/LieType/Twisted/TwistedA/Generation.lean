module

public import CFSGCorollary.LieType.Twisted.TwistedA.Torus
import CFSG.LieType.Universal.Unitary.Roots
import CFSGCorollary.LieType.Twisted.TwistedA.Commutator
import CFSGCorollary.LieType.Twisted.TwistedA.Monomial

/-!
# Generation of the unitary groups by root groups

Let `g` be the twisted Coxeter element of `SU σ n`. We show that a subgroup `R` containing `g`
and the short root group `S(0, 1)` (for `n` even) or the Heisenberg root group `H(0)` (for `n`
odd) contains every root group, hence is all of `SU σ n` when `σ = unitaryInvolution F p f`. This
is done by transporting the root group along the orbit of `0` under the Coxeter permutation and
using the commutator relations. We also show that, for suitable `d` and `u`, the subgroup
`⟨d, u g⟩` contains `g` and `S(0, 1)` or `H(0)`.

## Main results

* `TwistedA.eq_top_of_rootElements_mem`: the root elements generate `SU`.
* `TwistedA.rootGroups_le_of_coxeterElement_mem_of_range_le`,
  `TwistedA.rootGroups_le_of_coxeterElement_mem_of_heisenbergSubgroup_le`: `g` together with
  `S(0, 1)` (`n` even) or `H(0)` (`n` odd) give every root group.
* `TwistedA.shortRootSubgroup_le_closure_and_coxeterElement_mem_of_even`,
  `TwistedA.heisenbergRootSubgroup_le_closure_and_coxeterElement_mem_of_odd`,
  `TwistedA.heisenbergRootSubgroup_le_closure_and_coxeterElement_mem_three`: the first step,
  `⟨d, u g⟩` contains the root group and `g`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedA

open CFSG.LieType.Universal.Unitary CFSG.LieType.BorelTits CFSG.LieType.Universal.SpecialLinear

section

variable {F : Type} [Field F] [Finite F] {p f : ℕ} [Fact p.Prime] [CharP F p]
  (hF : Nat.card F = (p ^ f) ^ 2) {n : ℕ}

/-- Root elements generate `SU`. -/
theorem eq_top_of_rootElements_mem (hn : 2 ≤ n) (R : Subgroup (SU (unitaryInvolution F p f) n))
    (hR₁ : ∀ (i j : Fin n) (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j),
      j ≠ Fin.rev i → ∀ c, rootHom (unitaryInvolution F p f) (unitaryInvolution_involutive hF)
        hij hi hj c ∈ R)
    (hR₂ : ∀ (i : Fin n) (hi : i ≠ Fin.rev i) c, longRootHom (unitaryInvolution F p f) hi c ∈ R)
    (hR₃ : ∀ (i k : Fin n) (hi : i ≠ Fin.rev i) (hik : i ≠ k) (hk : Fin.rev k = k),
      heisenbergSubgroup (unitaryInvolution F p f) (unitaryInvolution_involutive hF) hi hik hk
        ≤ R) :
    R = ⊤ := by
  obtain ⟨ζ, hζ⟩ := exists_traceZero_ne_zero hF
  have hD := isCTGroupDatum hF n hn ζ hζ
  refine eq_top_iff.2 ?_
  rw [← hD.iSup_eq_top]
  refine iSup₂_le fun γ _ ↦ ?_
  unfold rootGroup
  refine sup_le (sup_le ?_ ?_) ?_
  · refine iSup_le fun i ↦ iSup_le fun j ↦ iSup_le fun hij ↦ iSup_le fun hi ↦
      iSup_le fun hj ↦ iSup_le fun hji ↦ iSup_le fun _ ↦ ?_
    rintro _ ⟨c, rfl⟩
    exact hR₁ i j hij hi hj hji c
  · refine iSup_le fun i ↦ iSup_le fun hi ↦ iSup_le fun _ ↦ ?_
    rintro _ ⟨c, rfl⟩
    exact hR₂ i hi c
  · exact iSup_le fun i ↦ iSup_le fun k ↦ iSup_le fun hi ↦ iSup_le fun hik ↦
      iSup_le fun hk ↦ iSup_le fun _ ↦ hR₃ i k hi hik hk

/-- First step, `n` even, `n ≥ 4`: `⟨d, u g⟩` contains `S(0, 1)` and `g`. -/
theorem shortRootSubgroup_le_closure_and_coxeterElement_mem_of_even (hn : 4 ≤ n) (hev : n % 2 = 0)
    (κ : Fˣ) (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0) :
    (shortRootSubgroup (σ := unitaryInvolution F p f) (unitaryInvolution_involutive hF) hn) ≤
        Subgroup.closure {torusElement hF hn (κ : F),
          shortRootHom (unitaryInvolution_involutive hF) hn (Multiplicative.ofAdd (1 : F)) *
            coxeterElement (unitaryInvolution_involutive hF) ζ n} ∧
      coxeterElement (unitaryInvolution_involutive hF) ζ n ∈
        Subgroup.closure {torusElement hF hn (κ : F),
          shortRootHom (unitaryInvolution_involutive hF) hn (Multiplicative.ofAdd (1 : F)) *
            coxeterElement (unitaryInvolution_involutive hF) ζ n} := by
  have H : ∃ k l : Fˣ, k ≠ 1 ∧ l ≠ 1 ∧ IsSpanningScalar (k : F) ∧
      Nonempty ((shortRootGroup (σ := unitaryInvolution F p f)
        (unitaryInvolution_involutive hF) (n := n) (by omega)).Action
        (torusElement hF (by omega) (κ : F)) k) ∧
      Nonempty ((shortRootGroup (σ := unitaryInvolution F p f)
        (unitaryInvolution_involutive hF) (n := n) (by omega)).Action
        (coxeterElement (unitaryInvolution_involutive hF) ζ n *
          torusElement hF (by omega) (κ : F) *
          (coxeterElement (unitaryInvolution_involutive hF) ζ n)⁻¹) l) := by
    by_cases h4 : n = 4
    · obtain ⟨k, l, -, -, hk, hl, hs, a, b⟩ :=
        exists_shortRootGroup_actions_of_eq_four hF h4 κ hκ hζ
      exact ⟨k, l, hk, hl, hs, a, b⟩
    · obtain ⟨k, l, -, -, hk, hl, hs, a, b⟩ :=
        exists_shortRootGroup_actions_of_even hF (by omega) hev κ hκ hζ
      exact ⟨k, l, hk, hl, hs, a, b⟩
  obtain ⟨k, l, hk, hl, hs, ⟨a⟩, ⟨b⟩⟩ := H
  exact LambdaRootGroup.le_closure_pair_mul_of_isSpanningScalar _ _ _ k l hs hk hl
    (commute_torusElement_conj_coxeterElement_of_ne_zero hF hn _ κ.ne_zero hζ) a b
    ⟨shortRootHom (unitaryInvolution_involutive hF) hn (Multiplicative.ofAdd (1 : F)), _, rfl⟩
    (by rw [shortRootGroup_coordinate_shortRootHom]; simp)

/-- First step, `n` odd, `n ≥ 5`: `⟨d, u_β g⟩` contains `H(0)` and `g`. -/
theorem heisenbergRootSubgroup_le_closure_and_coxeterElement_mem_of_odd (hodd : n % 2 = 1)
    (hn : 5 ≤ n) (κ : Fˣ) (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0)
    {β : F} (hβ : β + unitaryInvolution F p f β = -1)
    {u : SU (unitaryInvolution F p f) n}
    (hu : ((u : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) =
      heisenbergMatrix (unitaryInvolution F p f)
        (lowIdx ⟨0, by omega⟩) (midIdx hodd) 1 β) :
    heisenbergRootSubgroup hF hodd (by omega) ≤
        Subgroup.closure {torusElement hF (by omega) (κ : F),
          u * coxeterElement (unitaryInvolution_involutive hF) ζ n} ∧
      coxeterElement (unitaryInvolution_involutive hF) ζ n ∈
        Subgroup.closure {torusElement hF (by omega) (κ : F),
          u * coxeterElement (unitaryInvolution_involutive hF) ζ n} := by
  obtain ⟨k, l, -, -, hk, hl, hs, ⟨a⟩, ⟨b⟩⟩ :=
    exists_heisenbergRootGroup_actions_of_odd hF hodd hn κ hκ hζ
  obtain ⟨v, hv, hv1⟩ := exists_mem_heisenbergRootSubgroup_coe_eq hF hodd (by omega) hβ
  have huv : u = ((v : SU (unitaryInvolution F p f) n)) := by
    apply Subtype.ext; apply Units.ext; rw [hu, hv]
  subst huv
  exact LambdaRootGroup.le_closure_pair_mul_of_isSpanningScalar _ _ _ k l hs hk hl
    (commute_torusElement_conj_coxeterElement_of_ne_zero hF (by omega) _ κ.ne_zero hζ) a b v
    (by rw [hv1]; simp)

/-- First step, `n = 3`, `q ≠ 2`: `⟨D, u_β g⟩` contains `H(0)` and `g`. -/
theorem heisenbergRootSubgroup_le_closure_and_coxeterElement_mem_three (hnq : p ^ f ≠ 2) (κ : Fˣ)
    (hκ : ∀ x : Fˣ, x ∈ Subgroup.zpowers κ)
    {ζ : traceZero (unitaryInvolution F p f)} (hζ : (ζ : F) ≠ 0)
    {D : SU (unitaryInvolution F p f) 3} {t : Fin 3 → F}
    (hD : ((D : GL (Fin 3) F) : Matrix (Fin 3) (Fin 3) F) = Matrix.diagonal t)
    (ht : t = ![(κ : F), (κ : F) ^ (p ^ f - 1), ((κ ^ (p ^ f))⁻¹ : Fˣ)])
    {β : F} (hβ : β + unitaryInvolution F p f β = -1)
    {u : SU (unitaryInvolution F p f) 3}
    (hu : ((u : GL (Fin 3) F) : Matrix (Fin 3) (Fin 3) F) =
      heisenbergMatrix (unitaryInvolution F p f)
        (lowIdx ⟨0, by omega⟩) (midIdx (n := 3) (by omega)) 1 β) :
    heisenbergRootSubgroup hF (n := 3) (by omega) (by omega) ≤
        Subgroup.closure {D, u * coxeterElement (unitaryInvolution_involutive hF) ζ 3} ∧
      coxeterElement (unitaryInvolution_involutive hF) ζ 3 ∈
        Subgroup.closure {D, u * coxeterElement (unitaryInvolution_involutive hF) ζ 3} := by
  have ht' : ∀ s : Fin 3, t s = ![(κ : F), (κ : F) ^ (p ^ f - 1), ((κ ^ (p ^ f))⁻¹ : Fˣ)]
      (Fin.cast rfl s) := by
    intro s; rw [ht]; rfl
  obtain ⟨k, l, -, -, hk, hl, hs, ⟨a⟩, ⟨b⟩⟩ :=
    exists_heisenbergRootGroup_actions_of_eq_three hF hnq rfl κ hκ hζ hD ht'
  obtain ⟨v, hv, hv1⟩ := exists_mem_heisenbergRootSubgroup_coe_eq hF (n := 3) (by omega)
    (by omega) hβ
  have huv : u = ((v : SU (unitaryInvolution F p f) 3)) := by
    apply Subtype.ext; apply Units.ext; rw [hu, hv]
  subst huv
  exact LambdaRootGroup.le_closure_pair_mul_of_isSpanningScalar _ _ _ k l hs hk hl
    (commute_conj_coxeterElement_of_coe_eq_diagonal hF hζ hD) a b v (by rw [hv1]; simp)

end

section

variable {F : Type*} [Field F] {σ : F ≃+* F} (hσ : ∀ c : F, σ (σ c) = c) {n : ℕ}

/-- `S(i, j) ≤ R` (vacuous when `(i, j)` is not an admissible pair). -/
def ShortRootGroupLE (R : Subgroup (SU σ n)) (i j : Fin n) : Prop :=
  ∀ (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j), j ≠ Fin.rev i →
    (rootHom σ hσ hij hi hj).range ≤ R

private theorem ShortRootGroupLE.perm {π : Equiv.Perm (Fin n)} {ε : Fin n → F} {M : SU σ n}
    (hM : ((M : GL (Fin n) F) : Matrix (Fin n) (Fin n) F) = signedPerm π ε)
    (hπ : ∀ s, π (Fin.rev s) = Fin.rev (π s)) {R : Subgroup (SU σ n)} (hMR : M ∈ R)
    {i j : Fin n} (h : ShortRootGroupLE hσ R i j) : ShortRootGroupLE hσ R (π i) (π j) := by
  intro hij' hi' hj' hji'
  have hij : i ≠ j := fun e ↦ hij' (e ▸ rfl)
  have hi : i ≠ Fin.rev i := fun e ↦ hi' (by rw [← hπ, ← e])
  have hj : j ≠ Fin.rev j := fun e ↦ hj' (by rw [← hπ, ← e])
  have hji : j ≠ Fin.rev i := fun e ↦ hji' (by rw [e, hπ])
  have e := map_conj_range_rootHom hσ hM hπ hij hi hj
  refine le_of_eq_of_le e.symm ?_
  rintro _ ⟨x, hx, rfl⟩
  exact mul_mem (mul_mem hMR (h hij hi hj hji hx)) (inv_mem hMR)

private theorem ShortRootGroupLE.trans {a b c : Fin n} (hab : a ≠ b) (hbc : b ≠ c) (hac : a ≠ c)
    (ha : a ≠ Fin.rev a) (hb : b ≠ Fin.rev b) (hc : c ≠ Fin.rev c)
    (hba : b ≠ Fin.rev a) (hcb : c ≠ Fin.rev b)
    {R : Subgroup (SU σ n)} (h₁ : ShortRootGroupLE hσ R a b) (h₂ : ShortRootGroupLE hσ R b c) :
    ShortRootGroupLE hσ R a c :=
  fun _ _ _ _ ↦ range_rootHom_le_of_range_le hσ hab hbc hac ha hb hc hba hcb
    (h₁ hab ha hb hba) (h₂ hbc hb hc hcb)

private theorem ShortRootGroupLE.symm {R : Subgroup (SU σ n)}
    (hrev : ∀ i j, ShortRootGroupLE hσ R i j → ShortRootGroupLE hσ R (Fin.rev i) (Fin.rev j))
    {i j : Fin n} (h : ShortRootGroupLE hσ R i j) : ShortRootGroupLE hσ R j i := by
  intro hji hj hi hij
  rw [range_rootHom_rev hσ hji hj hi]
  exact hrev i j h (fun e ↦ hji (Fin.rev_injective e).symm)
    (by rw [Fin.rev_rev]; exact hi.symm)
    (by rw [Fin.rev_rev]; exact hj.symm)
    (by rw [Fin.rev_rev]; exact hij.symm)

/-- The orbit `π ^ k 0` of the Coxeter permutation. -/
noncomputable def coxeterOrbit (hn : 4 ≤ n) (k : ℕ) : Fin n :=
  (coxeterPerm n ^ k) (lowIdx ⟨0, by omega⟩)

private theorem coxeterOrbit_add (hn : 4 ≤ n) (k l : ℕ) :
    coxeterOrbit hn (k + l) = (coxeterPerm n ^ k) (coxeterOrbit hn l) := by
  simp [coxeterOrbit, pow_add]

private theorem coxeterOrbit_half_add (hn : 4 ≤ n) (k : ℕ) :
    coxeterOrbit hn (n / 2 + k) = Fin.rev (coxeterOrbit hn k) := by
  rw [coxeterOrbit_add, coxeterPerm_pow_half]

private theorem coxeterOrbit_period (hn : 4 ≤ n) (k : ℕ) :
    coxeterOrbit hn (k + 2 * (n / 2)) = coxeterOrbit hn k := by
  have : k + 2 * (n / 2) = n / 2 + (n / 2 + k) := by omega
  rw [this, coxeterOrbit_half_add, coxeterOrbit_half_add, Fin.rev_rev]

private theorem coxeterOrbit_of_lt (hn : 4 ≤ n) {k : ℕ} (hk : k < n / 2) :
    coxeterOrbit hn k = lowIdx ⟨k, hk⟩ :=
  coxeterPerm_pow_zero_of_lt (by omega) k hk

private theorem coxeterOrbit_of_ge (hn : 4 ≤ n) {k : ℕ} (hk : n / 2 ≤ k)
    (hk' : k < 2 * (n / 2)) :
    coxeterOrbit hn k = Fin.rev (lowIdx ⟨k - n / 2, by omega⟩) :=
  coxeterPerm_pow_zero_of_ge (by omega) k hk hk'

private theorem eq_of_coxeterOrbit_eq (hn : 4 ≤ n) {a b : ℕ} (ha : a < 2 * (n / 2))
    (hb : b < 2 * (n / 2)) (h : coxeterOrbit hn a = coxeterOrbit hn b) : a = b := by
  have hv : ∀ (x y : Fin (n / 2)), lowIdx (n := n) x = lowIdx y → x = y := fun x y e ↦
    Fin.ext (show (lowIdx (n := n) x).val = (lowIdx y).val from congrArg Fin.val e)
  rcases lt_or_ge a (n / 2) with h1 | h1 <;> rcases lt_or_ge b (n / 2) with h2 | h2
  · rw [coxeterOrbit_of_lt hn h1, coxeterOrbit_of_lt hn h2] at h
    exact congrArg Fin.val (hv _ _ h)
  · rw [coxeterOrbit_of_lt hn h1, coxeterOrbit_of_ge hn h2 hb] at h
    exact absurd h (lowIdx_ne_rev _ _)
  · rw [coxeterOrbit_of_ge hn h1 ha, coxeterOrbit_of_lt hn h2] at h
    exact absurd h.symm (lowIdx_ne_rev _ _)
  · rw [coxeterOrbit_of_ge hn h1 ha, coxeterOrbit_of_ge hn h2 hb] at h
    have := congrArg Fin.val (hv _ _ (Fin.rev_injective h))
    simp at this
    omega

private theorem coxeterOrbit_ne_rev (hn : 4 ≤ n) (k : ℕ) :
    coxeterOrbit hn k ≠ Fin.rev (coxeterOrbit hn k) := by
  intro e
  rw [coxeterOrbit, ← coxeterPerm_pow_rev] at e
  exact lowIdx_ne_rev_self _ ((Equiv.injective _) e)

private theorem coxeterOrbit_add_left_cancel (hn : 4 ≤ n) {k a b : ℕ}
    (h : coxeterOrbit hn (k + a) = coxeterOrbit hn (k + b)) :
    coxeterOrbit hn a = coxeterOrbit hn b := by
  rw [coxeterOrbit_add, coxeterOrbit_add] at h
  exact Equiv.injective _ h

private theorem exists_coxeterOrbit_eq (hn : 4 ≤ n) {i : Fin n} (hi : i ≠ Fin.rev i) :
    ∃ s, s < 2 * (n / 2) ∧ i = coxeterOrbit hn s := by
  obtain ⟨a, ha | ha⟩ := exists_lowIdx hi
  · exact ⟨a.val, by omega, by rw [coxeterOrbit_of_lt hn a.isLt]; exact ha⟩
  · refine ⟨n / 2 + a.val, by omega, ?_⟩
    rw [coxeterOrbit_half_add, coxeterOrbit_of_lt hn a.isLt]; exact ha

/-- `n` even: the Coxeter element and `S(0, 1)` give every root group. -/
theorem rootGroups_le_of_coxeterElement_mem_of_range_le (hn : 4 ≤ n) (hev : n % 2 = 0)
    {ζ : traceZero σ} (hζ : (ζ : F) ≠ 0)
    {R : Subgroup (SU σ n)} (hg : coxeterElement hσ ζ n ∈ R)
    (hS : (rootHom σ hσ (lowIdx_ne_succ (n := n) (k := ⟨0, by omega⟩) (by simp; omega))
      (lowIdx_ne_rev_self _) (lowIdx_ne_rev_self _)).range ≤ R)
    (hw : ∃ w : F, w + σ w = 1 := by
      first | assumption | exact exists_add_unitaryInvolution_eq (by assumption) (by simp)) :
    (∀ (i j : Fin n) (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j),
      j ≠ Fin.rev i → (rootHom σ hσ hij hi hj).range ≤ R) ∧
    (∀ (i : Fin n) (hi : i ≠ Fin.rev i), (longRootHom σ hi).range ≤ R) := by
  obtain ⟨ε, hM⟩ := exists_coe_coxeterElement_eq_signedPerm hσ hζ
  have hπ := coxeterPerm_rev (n := n)
  have shiftk : ∀ (k : ℕ) (i j : Fin n), ShortRootGroupLE hσ R i j →
      ShortRootGroupLE hσ R ((coxeterPerm n ^ k) i) ((coxeterPerm n ^ k) j) := by
    intro k
    induction k with
    | zero => intro i j h; simpa using h
    | succ k ih =>
      intro i j h
      rw [pow_succ', Equiv.Perm.mul_apply, Equiv.Perm.mul_apply]
      exact ShortRootGroupLE.perm hσ hM hπ hg (ih i j h)
  have hrev : ∀ i j, ShortRootGroupLE hσ R i j →
      ShortRootGroupLE hσ R (Fin.rev i) (Fin.rev j) := by
    intro i j h
    have := shiftk (n / 2) i j h
    simpa [coxeterPerm_pow_half] using this
  have hsymm : ∀ {i j : Fin n}, ShortRootGroupLE hσ R i j → ShortRootGroupLE hσ R j i :=
    fun h ↦ ShortRootGroupLE.symm hσ hrev h
  have hne : ∀ k l, k < l → l < k + 2 * (n / 2) → coxeterOrbit hn k ≠ coxeterOrbit hn l := by
    intro k l h1 h2 e
    obtain ⟨d, rfl⟩ : ∃ d, l = k + d := ⟨l - k, by omega⟩
    have := eq_of_coxeterOrbit_eq hn (a := 0) (b := d) (by omega) (by omega)
      (coxeterOrbit_add_left_cancel hn (k := k) e)
    omega
  have hnr : ∀ k l, k < l → l < k + 2 * (n / 2) → l ≠ k + n / 2 →
      coxeterOrbit hn l ≠ Fin.rev (coxeterOrbit hn k) := by
    intro k l h1 h2 h3 e
    obtain ⟨d, rfl⟩ : ∃ d, l = k + d := ⟨l - k, by omega⟩
    rw [← coxeterOrbit_half_add, add_comm (n / 2) k] at e
    have := eq_of_coxeterOrbit_eq hn (a := d) (b := n / 2) (by omega) (by omega)
      (coxeterOrbit_add_left_cancel hn (k := k) e)
    omega
  have hnm := coxeterOrbit_ne_rev hn
  have base : ShortRootGroupLE hσ R (coxeterOrbit hn 0) (coxeterOrbit hn 1) := by
    have e0 : coxeterOrbit hn 0 = lowIdx ⟨0, by omega⟩ := coxeterOrbit_of_lt hn (by omega)
    have e1 : coxeterOrbit hn 1 = lowIdx ⟨0 + 1, by omega⟩ := coxeterOrbit_of_lt hn (by omega)
    rw [e0, e1]
    exact fun _ _ _ _ ↦ hS
  have adj : ∀ k, ShortRootGroupLE hσ R (coxeterOrbit hn k) (coxeterOrbit hn (k + 1)) := by
    intro k
    have := shiftk k _ _ base
    rwa [← coxeterOrbit_add, ← coxeterOrbit_add] at this
  have Q : ∀ d k, 1 ≤ d → d < n / 2 →
      ShortRootGroupLE hσ R (coxeterOrbit hn k) (coxeterOrbit hn (k + d)) := by
    intro d
    induction d with
    | zero => intro k h; omega
    | succ d ih =>
      intro k h1 h2
      rcases Nat.eq_zero_or_pos d with rfl | hd
      · exact adj k
      · exact ShortRootGroupLE.trans hσ (a := coxeterOrbit hn k) (b := coxeterOrbit hn (k + d))
          (c := coxeterOrbit hn (k + (d + 1)))
          (hne k (k + d) (by omega) (by omega)) (hne (k + d) (k + (d + 1)) (by omega) (by omega))
          (hne k (k + (d + 1)) (by omega) (by omega)) (hnm _) (hnm _) (hnm _)
          (hnr k (k + d) (by omega) (by omega) (by omega))
          (hnr (k + d) (k + (d + 1)) (by omega) (by omega) (by omega))
          (ih k hd (by omega)) (adj (k + d))
  have Q2 : ∀ d k, 0 < d → d < 2 * (n / 2) → d ≠ n / 2 →
      ShortRootGroupLE hσ R (coxeterOrbit hn k) (coxeterOrbit hn (k + d)) := by
    intro d k h1 h2 h3
    rcases lt_or_gt_of_ne h3 with h | h
    · exact Q d k h1 h
    · obtain ⟨e, he⟩ : ∃ e, d + e = 2 * (n / 2) := ⟨2 * (n / 2) - d, by omega⟩
      have := hsymm (Q e (k + d) (by omega) (by omega))
      rw [Nat.add_assoc k d e, he, coxeterOrbit_period] at this
      exact this
  have all : ∀ s t, s < 2 * (n / 2) → t < 2 * (n / 2) → s ≠ t →
      coxeterOrbit hn t ≠ Fin.rev (coxeterOrbit hn s) →
        ShortRootGroupLE hσ R (coxeterOrbit hn s) (coxeterOrbit hn t) := by
    intro s t hs ht hst hts
    rcases lt_or_gt_of_ne hst with h | h
    · obtain ⟨d, rfl⟩ : ∃ d, t = s + d := ⟨t - s, by omega⟩
      refine Q2 d s (by omega) (by omega) ?_
      rintro rfl
      apply hts
      rw [← coxeterOrbit_half_add, add_comm]
    · obtain ⟨d, hd⟩ : ∃ d, d = t + 2 * (n / 2) - s := ⟨_, rfl⟩
      have hd' : s + d = t + 2 * (n / 2) := by omega
      have := Q2 d s (by omega) (by omega) ?_
      · rw [hd', coxeterOrbit_period] at this
        exact this
      · rintro hdm
        apply hts
        have : t + n / 2 = s := by omega
        rw [← this, add_comm, coxeterOrbit_half_add, Fin.rev_rev]
  refine ⟨?_, ?_⟩
  · intro i j hij hi hj hji
    obtain ⟨s, hs, rfl⟩ := exists_coxeterOrbit_eq hn hi
    obtain ⟨t, ht, rfl⟩ := exists_coxeterOrbit_eq hn hj
    have hst : s ≠ t := fun e ↦ hij (by rw [e])
    exact all s t hs ht hst hji hij hi hj hji
  · intro i hi
    obtain ⟨s, hs, rfl⟩ := exists_coxeterOrbit_eq hn hi
    have h1 := adj s
    have h2 := Q2 (n / 2 - 1) (s + 1) (by omega) (by omega) (by omega)
    have e : s + 1 + (n / 2 - 1) = n / 2 + s := by omega
    rw [e, coxeterOrbit_half_add] at h2
    have hb := hnm (s + 1)
    have hab := hne s (s + 1) (by omega) (by omega)
    have hba : coxeterOrbit hn (s + 1) ≠ Fin.rev (coxeterOrbit hn s) :=
      hnr s (s + 1) (by omega) (by omega) (by omega)
    exact range_longRootHom_le_of_range_rootHom_le hσ hi hb hab hba hw
      (h1 hab hi hb hba) (h2 hba hb _ (fun e ↦ hab (Fin.rev_injective e)))

/-- `n` odd: the Coxeter element and `H(0)` give every root group. -/
theorem rootGroups_le_of_coxeterElement_mem_of_heisenbergSubgroup_le (hn : 3 ≤ n)
    (hodd : n % 2 = 1)
    {ζ : traceZero σ} (hζ : (ζ : F) ≠ 0)
    {R : Subgroup (SU σ n)} (hg : coxeterElement hσ ζ n ∈ R)
    (hH : heisenbergSubgroup σ hσ (lowIdx_ne_rev_self (n := n) ⟨0, by omega⟩)
      (lowIdx_ne_midIdx hodd ⟨0, by omega⟩) (rev_midIdx hodd) ≤ R)
    (htr : ∀ t : F, σ t = t → ∃ b, b + σ b = t := by
      first | assumption | exact fun t ht ↦ exists_add_unitaryInvolution_eq (by assumption) ht) :
    (∀ (i k : Fin n) (hi : i ≠ Fin.rev i) (hik : i ≠ k) (hk : Fin.rev k = k),
      heisenbergSubgroup σ hσ hi hik hk ≤ R) ∧
    (∀ (i : Fin n) (hi : i ≠ Fin.rev i), (longRootHom σ hi).range ≤ R) ∧
    (∀ (i j : Fin n) (hij : i ≠ j) (hi : i ≠ Fin.rev i) (hj : j ≠ Fin.rev j),
      j ≠ Fin.rev i → (rootHom σ hσ hij hi hj).range ≤ R) := by
  have hμ := rev_midIdx hodd
  obtain ⟨ε, hε⟩ := exists_coe_coxeterElement_eq_signedPerm hσ hζ
  set g := coxeterElement hσ ζ n with hgdef
  have hπ : ∀ s, coxeterPerm n (Fin.rev s) = Fin.rev (coxeterPerm n s) := coxeterPerm_rev
  have hπk : coxeterPerm n (midIdx hodd) = midIdx hodd := coxeterPerm_midIdx hodd
  let Q : Fin n → Prop := fun i ↦ ∀ (hi : i ≠ Fin.rev i) (hik : i ≠ midIdx hodd),
    heisenbergSubgroup σ hσ hi hik hμ ≤ R
  have hstep : ∀ i, Q i → Q (coxeterPerm n i) := by
    intro i hQ hi' hik'
    have hi : i ≠ Fin.rev i := fun h ↦ hi' (by rw [← hπ, ← h])
    have hik : i ≠ midIdx hodd := fun h ↦ hik' (by rw [h, hπk])
    have key := map_conj_heisenbergSubgroup hσ hε hπ hi hik hμ hπk
    intro x hx
    rw [← key] at hx
    obtain ⟨y, hy, rfl⟩ := hx
    have := hQ hi hik hy
    simpa using R.mul_mem (R.mul_mem hg this) (R.inv_mem hg)
  have hpow : ∀ j : ℕ, Q ((coxeterPerm n ^ j) (lowIdx ⟨0, by omega⟩)) := by
    intro j
    induction j with
    | zero => exact fun hi hik ↦ by simpa using hH
    | succ j ih =>
      rw [pow_succ', Equiv.Perm.mul_apply]
      exact hstep _ ih
  have hall : ∀ (i k : Fin n) (hi : i ≠ Fin.rev i) (hik : i ≠ k) (hk : Fin.rev k = k),
      heisenbergSubgroup σ hσ hi hik hk ≤ R := by
    intro i k hi hik hk
    have hkm : k = midIdx hodd := by
      apply Fin.ext
      have := congrArg Fin.val hk
      simp only [Fin.val_rev, midIdx] at this ⊢
      omega
    subst hkm
    obtain ⟨a, ha | ha⟩ := exists_lowIdx hi
    · have h1 := hpow a.val
      rw [coxeterPerm_pow_zero_of_lt hn a.val a.isLt] at h1
      subst ha
      exact h1 hi hik
    · have h1 := hpow (a.val + n / 2)
      rw [coxeterPerm_pow_zero_of_ge hn (a.val + n / 2) (by omega) (by have := a.isLt; omega)] at h1
      have e : (⟨a.val + n / 2 - n / 2, by have := a.isLt; omega⟩ : Fin (n / 2)) = a :=
        Fin.ext (by simp)
      rw [e] at h1
      subst ha
      exact h1 hi hik
  refine ⟨hall, ?_, ?_⟩
  · intro i hi
    have hik : i ≠ midIdx hodd := fun h ↦ hi (by rw [h, hμ])
    rintro x ⟨c, rfl⟩
    apply hall i _ hi hik hμ
    refine ⟨0, (Multiplicative.toAdd c : traceZero σ).1, ?_, ?_⟩
    · rw [map_zero, zero_mul, add_zero]
      exact (Multiplicative.toAdd c).2
    · rw [coe_longRootHom, longRootMatrix, heisenbergMatrix]
      simp
  · intro i j hij hi hj hji
    have him : i ≠ midIdx hodd := fun h ↦ hi (by rw [h, hμ])
    have hjm : Fin.rev j ≠ midIdx hodd := fun h ↦ hj (by
      have := congrArg Fin.rev h
      rw [Fin.rev_rev, hμ] at this
      rw [this, hμ])
    apply range_rootHom_le_of_heisenbergSubgroup_le hσ hi hj hij hμ him hjm <;>
      first
      | exact htr
      | exact hall i _ hi him hμ
      | exact hall _ _ _ hjm hμ

end

end CFSGCorollary.TwistedA
