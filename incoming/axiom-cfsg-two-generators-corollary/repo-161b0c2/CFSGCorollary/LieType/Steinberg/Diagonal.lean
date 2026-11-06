module

public import CFSGCorollary.LieType.Steinberg.WeylWord


/-!
# Diagonal elements of a Steinberg system

An element `d` of a Steinberg system is *diagonal* if it acts on every root group `X_γ` by a unit
scalar. This file shows that diagonal elements commute (using that `G` has trivial center), that
the torus elements `hᵢ(t) = ωᵢ(t) ωᵢ(1)⁻¹` and `h_μ(k) = ∏ᵢ hᵢ(k^{μ i})` are diagonal with
explicit scalars, and how conjugation by an element permuting the root groups moves the scalars.

## Main definitions

* `CFSGCorollary.weylTorusElement x i t = ωᵢ(t) ωᵢ(1)⁻¹`.
* `CFSGCorollary.cocharacterElement x μ k = ∏ᵢ hᵢ(k^{μ i})`.

## Main results

* `CFSGCorollary.SteinbergSystem.IsDiagonal.commute`: diagonal elements commute.
* `CFSGCorollary.SteinbergSystem.weylTorusElement_isDiagonal`: `hᵢ(t)` acts on `X_γ` by
  `t ^ (∑ⱼ Aᵢⱼ γⱼ)`.
* `CFSGCorollary.SteinbergSystem.cocharacterElement_isDiagonal`: `h_μ(k)` acts on `X_γ` by
  `k ^ (∑ᵢ μᵢ ∑ⱼ Aᵢⱼ γⱼ)`.
* `CFSGCorollary.SteinbergSystem.rootScaling_conj_of_signed_perm`.
* `CFSGCorollary.SteinbergSystem.isDiagonal_conj_weylWordElement`: conjugation by `ω(L)^{±1}`
  preserves diagonal elements.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

open CFSG.LieType.RootSystem (roots reflection)
open CFSG.LieType.Steinberg (weylElement)

/-- `hᵢ(t) = ωᵢ(t) ωᵢ(1)⁻¹`. -/
def weylTorusElement {K G : Type*} [Field K] [Group G] {rank : ℕ}
    (x : (Fin rank → ℤ) → K → G) (i : Fin rank) (t : Kˣ) : G :=
  weylElement x i t * (weylElement x i 1)⁻¹

/-- `h_μ(k) = ∏ᵢ hᵢ(k^{μ i})` (the factors commute for a Steinberg system). -/
def cocharacterElement {K G : Type*} [Field K] [Group G] {rank : ℕ}
    (x : (Fin rank → ℤ) → K → G) (μ : Fin rank → ℤ) (k : Kˣ) : G :=
  (List.ofFn fun i ↦ weylTorusElement x i (k ^ μ i)).prod

namespace SteinbergSystem

variable {rank : ℕ} {cartan : Matrix (Fin rank) (Fin rank) ℤ}
  {finiteType : TauCeti.IsFiniteType cartan} {K G : Type*}
  [Field K] [Finite K] [Group G]

/-- `d` is diagonal: it acts on every root group `X_γ`, `γ ∈ Φ`, by some unit. -/
def IsDiagonal (system : SteinbergSystem cartan finiteType K G) (d : G) : Prop :=
  ∀ γ ∈ roots finiteType ∅, ∃ c : Kˣ, RootScaling system.rootElement γ d (c : K)

theorem rootScaling_mul {γ : Fin rank → ℤ} {a b : G} {c c' : K}
    (system : SteinbergSystem cartan finiteType K G)
    (ha : RootScaling system.rootElement γ a c) (hb : RootScaling system.rootElement γ b c') :
    RootScaling system.rootElement γ (a * b) (c * c') := by
  intro p
  calc a * b * system.rootElement γ p * (a * b)⁻¹
      = a * (b * system.rootElement γ p * b⁻¹) * a⁻¹ := by group
    _ = _ := by rw [hb p, ha (c' * p)]; congr 1; ring

/-- Any two diagonal elements commute. -/
theorem IsDiagonal.commute (system : SteinbergSystem cartan finiteType K G) {d d' : G}
    (hd : system.IsDiagonal d) (hd' : system.IsDiagonal d') : Commute d d' := by
  set z : G := (d * d')⁻¹ * (d' * d) with hz
  have hx : ∀ γ ∈ roots finiteType ∅, ∀ p : K,
      system.rootElement γ p * z = z * system.rootElement γ p := by
    intro γ hγ p
    obtain ⟨c, hc⟩ := hd γ hγ
    obtain ⟨c', hc'⟩ := hd' γ hγ
    have h1 := rootScaling_mul system hc hc' p
    have h2 := rootScaling_mul system hc' hc p
    rw [mul_comm (c' : K) c] at h2
    have h3 : (d * d') * system.rootElement γ p * (d * d')⁻¹ =
        (d' * d) * system.rootElement γ p * (d' * d)⁻¹ := h1.trans h2.symm
    rw [hz]
    calc system.rootElement γ p * ((d * d')⁻¹ * (d' * d))
        = (d * d')⁻¹ * ((d * d') * system.rootElement γ p * (d * d')⁻¹) * (d' * d) := by
          group
      _ = _ := by rw [h3]; group
  have hzc : z ∈ Subgroup.center G := by
    have : (⊤ : Subgroup G) ≤ Subgroup.centralizer {z} := by
      rw [← system.closure_rootElement_eq_top, Subgroup.closure_le]
      rintro _ ⟨γ, hγ, p, rfl⟩
      rw [SetLike.mem_coe, Subgroup.mem_centralizer_iff]
      intro h hh
      rw [Set.mem_singleton_iff] at hh
      subst hh
      exact (hx γ hγ p).symm
    rw [Subgroup.mem_center_iff]
    intro g
    have := this (Subgroup.mem_top g)
    rw [Subgroup.mem_centralizer_iff] at this
    exact (this z (Set.mem_singleton z)).symm
  rw [system.center_eq_bot, Subgroup.mem_bot, hz, inv_mul_eq_one] at hzc
  exact hzc

theorem rootScaling_weylTorusElement (system : SteinbergSystem cartan finiteType K G)
    (i : Fin rank) (t : Kˣ) (γ : Fin rank → ℤ) (hγ : γ ∈ roots finiteType ∅) :
    RootScaling system.rootElement γ (weylTorusElement system.rootElement i t)
      ((t ^ (∑ j, cartan i j * γ j) : Kˣ) : K) := by
  have h2 : cartan i i = 2 := finiteType.apply_self i
  set s := reflection cartan i with hs
  have hss : ∀ v, s (s v) = v := fun v ↦ by
    simpa using LinearMap.congr_fun (CFSG.LieType.RootSystem.reflection_mul_self h2) v
  have hm : ∑ j, cartan i j * (s γ) j = -∑ j, cartan i j * γ j := by
    simpa [CFSG.LieType.RootSystem.coroot_apply] using
      CFSG.LieType.RootSystem.coroot_reflection h2 γ
  obtain ⟨ε, hε, hconj⟩ :=
    system.weylElement_conj_rootElement i (s γ) (reflection_mem_roots finiteType i hγ)
  have hsq : (ε : K) * ε = 1 := by rcases hε with h | h <;> simp [h]
  intro p
  set ω := weylElement system.rootElement i
  have h1' : ω (1 : Kˣ) * system.rootElement (s γ) ((ε : K) * p) * (ω (1 : Kˣ))⁻¹ =
      system.rootElement γ p := by
    have h1 := hconj 1 ((ε : K) * p)
    rw [hss] at h1
    rw [h1]
    congr 1
    simp only [one_zpow, Units.val_one]
    linear_combination p * hsq
  have e1 : (ω (1 : Kˣ))⁻¹ * system.rootElement γ p * ω (1 : Kˣ) =
      system.rootElement (s γ) ((ε : K) * p) := by
    rw [← h1']; group
  have e2 := hconj t ((ε : K) * p)
  rw [hss, hm] at e2
  have e3 : (ε : K) * (((t ^ (-(-∑ j, cartan i j * γ j)) : Kˣ)) : K) * ((ε : K) * p) =
      ((t ^ (∑ j, cartan i j * γ j) : Kˣ) : K) * p := by
    rw [neg_neg]
    linear_combination (((t ^ (∑ j, cartan i j * γ j) : Kˣ) : K) * p) * hsq
  unfold weylTorusElement
  calc ω t * (ω 1)⁻¹ * system.rootElement γ p * (ω t * (ω 1)⁻¹)⁻¹
      = ω t * ((ω 1)⁻¹ * system.rootElement γ p * ω 1) * (ω t)⁻¹ := by group
    _ = _ := by rw [e1, e2, ← e3]

/-- `hᵢ(t)` is diagonal and acts on `X_γ` by `t ^ (∑ⱼ Aᵢⱼ γⱼ)`. -/
theorem weylTorusElement_isDiagonal (system : SteinbergSystem cartan finiteType K G)
    (i : Fin rank) (t : Kˣ) :
    system.IsDiagonal (weylTorusElement system.rootElement i t) ∧
      ∀ γ ∈ roots finiteType ∅,
        RootScaling system.rootElement γ (weylTorusElement system.rootElement i t)
          ((t ^ (∑ j, cartan i j * γ j) : Kˣ) : K) :=
  ⟨fun γ hγ ↦ ⟨_, rootScaling_weylTorusElement system i t γ hγ⟩,
    rootScaling_weylTorusElement system i t⟩

/-- Conjugating by an element `g` that permutes the root groups (via `v`, up to signs) moves the
scalar by which `d` acts on `X_{v⁻¹ γ}` to `X_γ`. -/
theorem rootScaling_conj_of_signed_perm (system : SteinbergSystem cartan finiteType K G)
    (g d : G) (v : Equiv.Perm (Fin rank → ℤ))
    (hv : ∀ γ, γ ∈ roots finiteType ∅ ↔ v γ ∈ roots finiteType ∅)
    (ε : (Fin rank → ℤ) → ℤ) (hε : ∀ γ ∈ roots finiteType ∅, ε γ = 1 ∨ ε γ = -1)
    (hg : ∀ γ ∈ roots finiteType ∅, ∀ u : K,
      g * system.rootElement γ u * g⁻¹ = system.rootElement (v γ) ((ε γ : K) * u))
    (γ : Fin rank → ℤ) (hγ : γ ∈ roots finiteType ∅) (c : K)
    (hd : RootScaling system.rootElement (v.symm γ) d c) :
    RootScaling system.rootElement γ (g * d * g⁻¹) c := by
  intro p
  have hρ : v.symm γ ∈ roots finiteType ∅ := by
    rw [hv, Equiv.apply_symm_apply]; exact hγ
  have hsq : ((ε (v.symm γ) : K)) * (ε (v.symm γ) : K) = 1 := by
    rcases hε _ hρ with h | h <;> simp [h]
  have key : g⁻¹ * system.rootElement γ p * g =
      system.rootElement (v.symm γ) ((ε (v.symm γ) : K) * p) := by
    have h1 := hg (v.symm γ) hρ ((ε (v.symm γ) : K) * p)
    rw [Equiv.apply_symm_apply, ← mul_assoc, hsq, one_mul] at h1
    rw [← h1]; group
  have h2 := hg (v.symm γ) hρ (c * ((ε (v.symm γ) : K) * p))
  rw [Equiv.apply_symm_apply] at h2
  have h3 : (ε (v.symm γ) : K) * (c * ((ε (v.symm γ) : K) * p)) = c * p := by
    linear_combination (c * p) * hsq
  rw [h3] at h2
  rw [← h2, ← hd ((ε (v.symm γ) : K) * p), ← key]
  group

/-- If `d` scales `X_{w_L⁻¹ γ}` by `c`, then `ω(L) d ω(L)⁻¹` scales `X_γ` by `c`. -/
theorem rootScaling_conj_weylWordElement (system : SteinbergSystem cartan finiteType K G)
    (L : List (Fin rank)) {γ : Fin rank → ℤ} (hγ : γ ∈ roots finiteType ∅) {d : G} {c : K}
    (hd : RootScaling system.rootElement (weylWordRootInv cartan L γ) d c) :
    RootScaling system.rootElement γ
      (weylWordElement system.rootElement L * d * (weylWordElement system.rootElement L)⁻¹) c := by
  have hγ' := weylWordRootInv_mem_roots finiteType L hγ
  obtain ⟨-, -, ε, ε', hε, hε', h⟩ := system.weylWordElement_conj L _ hγ'
  rw [weylWordRoot_weylWordRootInv finiteType] at h
  have hsq : (ε : K) * ε = 1 := by rcases hε with hh | hh <;> simp [hh]
  intro p
  have h1 := (h ((ε : K) * p)).1
  rw [← mul_assoc, hsq, one_mul] at h1
  have h2 := (h ((ε : K) * (c * p))).1
  have h3 : (ε : K) * (c * p) = c * ((ε : K) * p) := by ring
  rw [h3] at h2
  have h4 := hd ((ε : K) * p)
  have h5 : (ε : K) * (c * ((ε : K) * p)) = c * p := by linear_combination (c * p) * hsq
  rw [h5] at h2
  rw [← h2, ← h4, ← h1]
  group

/-- `ω(L)` and `ω(L)⁻¹` permute the root groups according to `w_L` and `w_L⁻¹`, up to signs. -/
theorem exists_signs_weylWordElement_conj (system : SteinbergSystem cartan finiteType K G)
    (L : List (Fin rank)) :
    ∃ ε ε' : (Fin rank → ℤ) → ℤ,
      (∀ γ ∈ roots finiteType ∅, ε γ = 1 ∨ ε γ = -1) ∧
      (∀ γ ∈ roots finiteType ∅, ε' γ = 1 ∨ ε' γ = -1) ∧
      (∀ γ ∈ roots finiteType ∅, ∀ u : K,
        weylWordElement system.rootElement L * system.rootElement γ u *
            (weylWordElement system.rootElement L)⁻¹ =
          system.rootElement (weylWordPerm finiteType L γ) ((ε γ : K) * u)) ∧
      (∀ γ ∈ roots finiteType ∅, ∀ u : K,
        (weylWordElement system.rootElement L)⁻¹ * system.rootElement γ u *
            (weylWordElement system.rootElement L)⁻¹⁻¹ =
          system.rootElement ((weylWordPerm finiteType L).symm γ) ((ε' γ : K) * u)) := by
  have hsign : ∀ γ : Fin rank → ℤ, ∃ ε ε' : ℤ, γ ∈ roots finiteType ∅ →
      ((ε = 1 ∨ ε = -1) ∧ (ε' = 1 ∨ ε' = -1) ∧ ∀ u : K,
        weylWordElement system.rootElement L * system.rootElement γ u *
            (weylWordElement system.rootElement L)⁻¹ =
          system.rootElement (weylWordRoot cartan L γ) ((ε : K) * u) ∧
        (weylWordElement system.rootElement L)⁻¹ * system.rootElement γ u *
            weylWordElement system.rootElement L =
          system.rootElement (weylWordRootInv cartan L γ) ((ε' : K) * u)) := by
    intro γ
    by_cases h : γ ∈ roots finiteType ∅
    · obtain ⟨_, _, ε, ε', h1, h2, h3⟩ := system.weylWordElement_conj L γ h
      exact ⟨ε, ε', fun _ ↦ ⟨h1, h2, h3⟩⟩
    · exact ⟨1, 1, fun h' ↦ absurd h' h⟩
  choose ε ε' hε using hsign
  refine ⟨ε, ε', fun γ h ↦ (hε γ h).1, fun γ h ↦ (hε γ h).2.1, fun γ h u ↦ ((hε γ h).2.2 u).1,
    fun γ h u ↦ ?_⟩
  rw [inv_inv]
  exact ((hε γ h).2.2 u).2

/-- Conjugation by `ω(L)` and by `ω(L)⁻¹` preserves diagonal elements. -/
theorem isDiagonal_conj_weylWordElement (system : SteinbergSystem cartan finiteType K G)
    (L : List (Fin rank)) {d : G} (hd : system.IsDiagonal d) :
    system.IsDiagonal
        (weylWordElement system.rootElement L * d * (weylWordElement system.rootElement L)⁻¹) ∧
      system.IsDiagonal
        ((weylWordElement system.rootElement L)⁻¹ * d * weylWordElement system.rootElement L) := by
  obtain ⟨ε, ε', hε1, hε1', hg1, hg2⟩ := system.exists_signs_weylWordElement_conj L
  constructor
  · intro γ hγ
    obtain ⟨c, hc⟩ := hd ((weylWordPerm finiteType L).symm γ)
      ((weylWordPerm_symm_mem_iff finiteType L γ).2 hγ)
    exact ⟨c, system.rootScaling_conj_of_signed_perm _ d (weylWordPerm finiteType L)
      (fun γ ↦ (weylWordPerm_mem_iff finiteType L γ).symm) ε hε1 hg1 γ hγ c hc⟩
  · intro γ hγ
    obtain ⟨c, hc⟩ := hd (weylWordPerm finiteType L γ)
      ((weylWordPerm_mem_iff finiteType L γ).2 hγ)
    have := system.rootScaling_conj_of_signed_perm (weylWordElement system.rootElement L)⁻¹ d
      (weylWordPerm finiteType L).symm
      (fun γ ↦ (weylWordPerm_symm_mem_iff finiteType L γ).symm) ε' hε1' hg2 γ hγ c
      (by simpa using hc)
    rw [inv_inv] at this
    exact ⟨c, this⟩

theorem rootScaling_list_prod {γ : Fin rank → ℤ} (system : SteinbergSystem cartan finiteType K G)
    (l : List (G × K)) (hl : ∀ q ∈ l, RootScaling system.rootElement γ q.1 q.2) :
    RootScaling system.rootElement γ (l.map Prod.fst).prod (l.map Prod.snd).prod := by
  induction l with
  | nil =>
    intro p; simp
  | cons q l ih =>
    simp only [List.map_cons, List.prod_cons]
    exact rootScaling_mul system (hl q (by simp)) (ih fun q' hq' ↦ hl q' (by simp [hq']))

/-- `h_μ(k)` is diagonal and acts on `X_γ` by `k ^ (∑ᵢ μᵢ ∑ⱼ Aᵢⱼ γⱼ)`. -/
theorem cocharacterElement_isDiagonal (system : SteinbergSystem cartan finiteType K G)
    (μ : Fin rank → ℤ) (k : Kˣ) :
    system.IsDiagonal (cocharacterElement system.rootElement μ k) ∧
      ∀ γ ∈ roots finiteType ∅,
        RootScaling system.rootElement γ (cocharacterElement system.rootElement μ k)
          ((k ^ (∑ i, μ i * ∑ j, cartan i j * γ j) : Kˣ) : K) := by
  have main : ∀ γ ∈ roots finiteType ∅,
      RootScaling system.rootElement γ (cocharacterElement system.rootElement μ k)
          ((k ^ (∑ i, μ i * ∑ j, cartan i j * γ j) : Kˣ) : K) := by
    intro γ hγ
    have h := rootScaling_list_prod (γ := γ) system
      (List.ofFn fun i ↦ (weylTorusElement system.rootElement i (k ^ μ i),
        (((k ^ μ i) ^ (∑ j, cartan i j * γ j) : Kˣ) : K)))
      (by
        intro q hq
        obtain ⟨i, rfl⟩ := List.mem_ofFn.mp hq
        exact (weylTorusElement_isDiagonal system i (k ^ μ i)).2 γ hγ)
    have e1 : (List.map Prod.fst
        (List.ofFn fun i ↦ (weylTorusElement system.rootElement i (k ^ μ i),
          (((k ^ μ i) ^ (∑ j, cartan i j * γ j) : Kˣ) : K)))) =
        List.ofFn fun i ↦ weylTorusElement system.rootElement i (k ^ μ i) := by
      simp [List.map_ofFn, Function.comp_def]
    have e2 : (List.map Prod.snd
        (List.ofFn fun i ↦ (weylTorusElement system.rootElement i (k ^ μ i),
          (((k ^ μ i) ^ (∑ j, cartan i j * γ j) : Kˣ) : K)))).prod =
        ((k ^ (∑ i, μ i * ∑ j, cartan i j * γ j) : Kˣ) : K) := by
      rw [List.map_ofFn, List.prod_ofFn]
      simp only [Function.comp_def]
      have zs : ∀ (s : Finset (Fin rank)) (f : Fin rank → ℤ),
          k ^ (∑ i ∈ s, f i) = ∏ i ∈ s, k ^ f i := by
        intro s f
        induction s using Finset.induction_on with
        | empty => simp
        | insert a s ha ih => rw [Finset.sum_insert ha, Finset.prod_insert ha, zpow_add, ih]
      rw [zs, Units.coe_prod]
      refine Finset.prod_congr rfl fun i _ ↦ ?_
      rw [← zpow_mul]
    rwa [e1, e2] at h
  exact ⟨fun γ hγ ↦ ⟨_, main γ hγ⟩, main⟩

/-- `h_μ(k)` acts on `X_γ` by `k ^ n` where `n = ⟨μ, γ⟩` is the cocharacter pairing. -/
theorem rootScaling_cocharacterElement (system : SteinbergSystem cartan finiteType K G)
    (μ : Fin rank → ℤ) (k : Kˣ) {γ : Fin rank → ℤ} (hγ : γ ∈ roots finiteType ∅) {n : ℤ}
    (hn : cocharacterPairing cartan μ γ = n) :
    RootScaling system.rootElement γ (cocharacterElement system.rootElement μ k)
      ((k ^ n : Kˣ) : K) := by
  have := (system.cocharacterElement_isDiagonal μ k).2 γ hγ
  have e : (∑ i, μ i * ∑ j, cartan i j * γ j) = n := hn
  rwa [e] at this

end SteinbergSystem

end CFSGCorollary
