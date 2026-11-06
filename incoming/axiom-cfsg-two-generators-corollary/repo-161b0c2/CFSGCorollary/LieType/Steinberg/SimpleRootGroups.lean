module

public import CFSGCorollary.LieType.Steinberg.WeylWord

/-!
# Generation by simple root groups

In a Steinberg system, a subgroup containing the root groups `X_{±αᵢ}` of all simple roots is the
whole group, since the Weyl elements `ωᵢ(1)` it contains move these to every root group. As a
consequence, a subgroup containing `ω(L)` and enough root groups to reach every `±αᵢ` along the
orbits of `w_L` and `w_L⁻¹` is the whole group. These statements only use the axioms (S0)–(S3),
so they are stated for `SteinbergData`.

## Main definitions

* `CFSGCorollary.SteinbergData.RootGroupIn`: the root group `X_γ` lies in a subgroup `F`.

## Main results

* `CFSGCorollary.SteinbergData.eq_top_of_simple_root_groups`
* `CFSGCorollary.SteinbergData.eq_top_of_weylWord_orbit`
* `CFSGCorollary.SteinbergData.eq_top_of_rootGroupIn`

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

namespace SteinbergData

open CFSG.LieType.RootSystem (roots reflection weylAction coxeterMatrix)
open CFSG.LieType.Steinberg (weylElement)

variable {rank : ℕ} {cartan : Matrix (Fin rank) (Fin rank) ℤ}
  {finiteType : TauCeti.IsFiniteType cartan} {K G : Type*}
  [Field K] [Finite K] [Group G]

/-- The root group `X_γ` of a root `γ` is contained in `F`. -/
def RootGroupIn (data : SteinbergData cartan finiteType K G) (F : Subgroup G)
    (γ : Fin rank → ℤ) : Prop :=
  γ ∈ roots finiteType ∅ ∧ ∀ u : K, data.rootElement γ u ∈ F

/-- If `ωᵢ(1) ∈ F` and `X_γ ≤ F`, then `X_{sᵢ γ} ≤ F`. -/
theorem rootGroupIn_reflection (data : SteinbergData cartan finiteType K G)
    (F : Subgroup G) (i : Fin rank) (hω : weylElement data.rootElement i (1 : Kˣ) ∈ F)
    {γ : Fin rank → ℤ} (h : data.RootGroupIn F γ) :
    data.RootGroupIn F (reflection cartan i γ) := by
  obtain ⟨hv, hvF⟩ := h
  refine ⟨reflection_mem_roots finiteType i hv, fun u ↦ ?_⟩
  obtain ⟨sign, hs, h⟩ := data.weylElement_conj_rootElement i γ hv
  have hsq : ((sign : ℤ) : K) * (sign : K) = 1 := by
    rcases hs with rfl | rfl <;> simp
  have h1 := h 1 (((sign : ℤ) : K) * u)
  simp only [one_zpow, Units.val_one, mul_one, one_mul, ← mul_assoc, hsq] at h1
  rw [← h1]
  exact F.mul_mem (F.mul_mem hω (hvF _)) (F.inv_mem hω)

/-- If `ω(L) ∈ F` and `X_γ ≤ F`, then `X_{w_L γ}` and `X_{w_L⁻¹ γ}` lie in `F`. -/
theorem rootGroupIn_weylWordRoot (data : SteinbergData cartan finiteType K G)
    (F : Subgroup G) (L : List (Fin rank)) (hL : weylWordElement data.rootElement L ∈ F)
    {γ : Fin rank → ℤ} (h : data.RootGroupIn F γ) :
    data.RootGroupIn F (weylWordRoot cartan L γ) ∧
      data.RootGroupIn F (weylWordRootInv cartan L γ) := by
  obtain ⟨hγ, hF⟩ := h
  obtain ⟨hmem, hinv, ε, ε', hε, hε', h⟩ := data.weylWordElement_conj L γ hγ
  refine ⟨⟨hmem, fun v ↦ ?_⟩, ⟨hinv, fun v ↦ ?_⟩⟩
  · have hsq : (ε : K) * ((ε : K) * v) = v := by
      rcases hε with h' | h' <;> simp [h']
    have := (h ((ε : K) * v)).1
    rw [hsq] at this
    rw [← this]
    exact F.mul_mem (F.mul_mem hL (hF _)) (F.inv_mem hL)
  · have hsq : (ε' : K) * ((ε' : K) * v) = v := by
      rcases hε' with h' | h' <;> simp [h']
    have := (h ((ε' : K) * v)).2
    rw [hsq] at this
    rw [← this]
    exact F.mul_mem (F.mul_mem (F.inv_mem hL) (hF _)) hL

/-- If `ω(L) ∈ F` and `X_γ ≤ F`, then `X_{w_Lⁿ γ}` and `X_{w_L⁻ⁿ γ}` lie in `F`. -/
theorem rootGroupIn_iterate (data : SteinbergData cartan finiteType K G)
    (F : Subgroup G) (L : List (Fin rank)) (hL : weylWordElement data.rootElement L ∈ F)
    {γ : Fin rank → ℤ} (h : data.RootGroupIn F γ) (n : ℕ) :
    data.RootGroupIn F ((weylWordRoot cartan L)^[n] γ) ∧
      data.RootGroupIn F ((weylWordRootInv cartan L)^[n] γ) := by
  induction n with
  | zero => exact ⟨h, h⟩
  | succ n ih =>
    rw [Function.iterate_succ_apply', Function.iterate_succ_apply']
    exact ⟨(data.rootGroupIn_weylWordRoot F L hL ih.1).1,
      (data.rootGroupIn_weylWordRoot F L hL ih.2).2⟩

/-- If `c` is the only positive combination of `a` and `b` and the commutator constants are units,
then `X_a, X_b ≤ F` imply `X_c ≤ F`. -/
theorem rootGroupIn_of_onlyPositiveCombination (data : SteinbergData cartan finiteType K G)
    (hx : data.HasUnitCommutatorConstants) (F : Subgroup G) {a b c : Fin rank → ℤ}
    (ha : data.RootGroupIn F a) (hb : data.RootGroupIn F b)
    (habc : OnlyPositiveCombination (roots finiteType ∅) a b c) :
    data.RootGroupIn F c := by
  obtain ⟨rfl, hc, huniq⟩ := habc
  obtain ⟨κ, hκ⟩ := hx a ha.1 b hb.1 hc huniq
  refine ⟨hc, fun t ↦ ?_⟩
  have := hκ 1 ((κ : K)⁻¹ * t)
  have hκ' : (κ : K) * 1 * ((κ : K)⁻¹ * t) = t := by
    have : (κ : K) ≠ 0 := κ.ne_zero
    field_simp
  rw [hκ'] at this
  rw [← this]
  exact F.mul_mem (F.mul_mem (F.mul_mem (ha.2 1) (hb.2 _)) (F.inv_mem (ha.2 1)))
    (F.inv_mem (hb.2 _))

/-- A subgroup containing the root groups `X_{αᵢ}` and `X_{-αᵢ}` of all simple roots is `⊤`. -/
theorem eq_top_of_simple_root_groups (data : SteinbergData cartan finiteType K G)
    (F : Subgroup G)
    (hpos : ∀ (i : Fin rank) (u : K), data.rootElement (Pi.single i 1) u ∈ F)
    (hneg : ∀ (i : Fin rank) (u : K), data.rootElement (-Pi.single i 1) u ∈ F) :
    F = ⊤ := by
  classical
  let R : Set (Fin rank → ℤ) := {γ | data.RootGroupIn F γ}
  have hω : ∀ i : Fin rank, weylElement data.rootElement i (1 : Kˣ) ∈ F := by
    intro i
    unfold weylElement
    exact mul_mem (mul_mem (hpos _ _) (hneg _ _)) (hpos _ _)
  have hrefl : ∀ i : Fin rank, ∀ v ∈ R, reflection cartan i v ∈ R :=
    fun i _ hv ↦ data.rootGroupIn_reflection F i (hω i) hv
  have hall : ∀ w : (coxeterMatrix finiteType).Group, ∀ v ∈ R, weylAction finiteType w v ∈ R := by
    intro w
    refine (coxeterMatrix finiteType).toCoxeterSystem.simple_induction
      (p := fun w ↦ ∀ v ∈ R, weylAction finiteType w v ∈ R) w ?_ ?_ ?_
    · intro i v hv
      rw [CFSG.LieType.RootSystem.weylAction_simple]
      exact hrefl i v hv
    · intro v hv
      simpa using hv
    · intro w w' h h' v hv
      rw [CFSG.LieType.RootSystem.weylAction_mul_apply]
      exact h _ (h' v hv)
  rw [eq_top_iff, ← data.closure_rootElement_eq_top, Subgroup.closure_le]
  rintro _ ⟨γ, hγ, u, rfl⟩
  rcases hγ with ⟨w, j, rfl⟩ | ⟨w, j, hj, _⟩
  · have hj1 : (Pi.single j 1 : Fin rank → ℤ) ∈ R := ⟨Or.inl ⟨1, j, by simp⟩, hpos j⟩
    exact (hall w _ hj1).2 u
  · exact absurd hj (Set.notMem_empty _)

/-- If `F` contains `ω(L)` and the root groups `X_ρ` for `ρ ∈ S ⊆ Φ`, and every `±αᵢ` is
`w_Lᵏ ρ` for some `ρ ∈ S` and `k ∈ ℤ` (a nonnegative power of `w_L` or of `w_L⁻¹`), then
`F = ⊤`. -/
theorem eq_top_of_weylWord_orbit (data : SteinbergData cartan finiteType K G)
    (F : Subgroup G) (L : List (Fin rank)) (hL : weylWordElement data.rootElement L ∈ F)
    (S : Set (Fin rank → ℤ)) (hS : S ⊆ roots finiteType ∅)
    (hSF : ∀ ρ ∈ S, ∀ u : K, data.rootElement ρ u ∈ F)
    (hpos : ∀ i : Fin rank, ∃ ρ ∈ S, ∃ k : ℕ,
      Pi.single i 1 = (weylWordRoot cartan L)^[k] ρ ∨
        Pi.single i 1 = (weylWordRootInv cartan L)^[k] ρ)
    (hneg : ∀ i : Fin rank, ∃ ρ ∈ S, ∃ k : ℕ,
      -Pi.single i 1 = (weylWordRoot cartan L)^[k] ρ ∨
        -Pi.single i 1 = (weylWordRootInv cartan L)^[k] ρ) :
    F = ⊤ := by
  have iter : ∀ ρ ∈ S, ∀ k : ℕ, data.RootGroupIn F ((weylWordRoot cartan L)^[k] ρ) ∧
      data.RootGroupIn F ((weylWordRootInv cartan L)^[k] ρ) :=
    fun ρ hρ ↦ data.rootGroupIn_iterate F L hL ⟨hS hρ, hSF ρ hρ⟩
  have hall : ∀ σ : Fin rank → ℤ,
      (∃ ρ ∈ S, ∃ k : ℕ, σ = (weylWordRoot cartan L)^[k] ρ ∨
        σ = (weylWordRootInv cartan L)^[k] ρ) → ∀ u : K, data.rootElement σ u ∈ F := by
    rintro σ ⟨ρ, hρ, k, rfl | rfl⟩
    · exact (iter ρ hρ k).1.2
    · exact (iter ρ hρ k).2.2
  exact data.eq_top_of_simple_root_groups F (fun i u ↦ hall _ (hpos i) u)
    (fun i u ↦ hall _ (hneg i) u)

/-- A subgroup containing `ω(L)` and root groups whose `w_L`-orbits contain every `±αᵢ` is
everything. -/
theorem eq_top_of_rootGroupIn (data : SteinbergData cartan finiteType K G) (F : Subgroup G)
    (L : List (Fin rank)) (hL : weylWordElement data.rootElement L ∈ F)
    (S : Set (Fin rank → ℤ)) (hS : ∀ ρ ∈ S, data.RootGroupIn F ρ)
    (horb : ∀ (i : Fin rank) (γ : Fin rank → ℤ), (γ = Pi.single i 1 ∨ γ = -Pi.single i 1) →
      ∃ (k : ℕ) (ρ : Fin rank → ℤ), ρ ∈ S ∧ (reflectionWord cartan L ^ k) ρ = γ) :
    F = ⊤ := by
  refine data.eq_top_of_weylWord_orbit F L hL S (fun ρ hρ ↦ (hS ρ hρ).1)
    (fun ρ hρ ↦ (hS ρ hρ).2) ?_ ?_
  · intro i
    obtain ⟨k, ρ, hρ, h⟩ := horb i _ (Or.inl rfl)
    exact ⟨ρ, hρ, k, Or.inl (by rw [← reflectionWord_pow_apply]; exact h.symm)⟩
  · intro i
    obtain ⟨k, ρ, hρ, h⟩ := horb i _ (Or.inr rfl)
    exact ⟨ρ, hρ, k, Or.inl (by rw [← reflectionWord_pow_apply]; exact h.symm)⟩

end SteinbergData

end CFSGCorollary
