module

public import CFSGCorollary.LieType.LambdaRootGroup.Basic
import CFSGCorollary.LieType.Steinberg.GeneratingScalar

@[expose] public section

/-!
# Generation lemmas for λ-root groups

Analogues of Lemmas 3.9, 3.10 and 3.12 of [Steinberg1962] for λ-root groups. Let `(X, λ)` be a
λ-root group over `L` and `d` an element acting on `X` by a generator `k` of `Lˣ` (or its square).
Conjugating `x ∈ X` by powers of `d` gives elements whose coordinates `k ^ j λ(x)` span `L`, so
together with `[X, X]` they generate `X`; since `X` is nilpotent, `[X, X]` lies in the Frattini
subgroup and can be dropped (`eq_top_of_sup_commutator_eq_top`).

## Main results

* `CFSGCorollary.LambdaRootGroup.le_closure_pair`: if `λ(x) ≠ 0` then `X ≤ ⟨d, x⟩`.
* `CFSGCorollary.LambdaRootGroup.le_closure_pair_mul`: with `d₁ = g d g⁻¹` commuting with `d`,
  `⟨d, u g⟩` contains `X` and `g`.
* `CFSGCorollary.LambdaRootGroup.le_closure_pair_mul_mul`: the two-root-group version.
* `CFSGCorollary.LambdaRootGroup.le_closure_pair_of_inverting`: the rank one case, where `g`
  inverts `d`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

namespace CFSGCorollary.LambdaRootGroup

variable {G L : Type*} [Group G] [Field L] [Finite L]

/-- Analogue of [Steinberg1962, Lemma 3.9]: if `d` acts on the λ-root group `(X, λ)` by a
generator of `Lˣ` or the square of one, and `λ(x) ≠ 0`, then `X ≤ ⟨d, x⟩`. -/
theorem le_closure_pair (rootGroup : LambdaRootGroup G L) (d : G) (scalar : Lˣ)
    (hscalar : IsGeneratingScalar scalar) (action : rootGroup.Action d scalar)
    (x : rootGroup.carrier)
    (hx : Multiplicative.toAdd (rootGroup.coordinate x) ≠ 0) :
    rootGroup.carrier ≤ Subgroup.closure {d, (x : G)} := by
  classical
  have := rootGroup.finite
  have := rootGroup.isNilpotent
  let Y : Subgroup rootGroup.carrier :=
    (Subgroup.closure {d, (x : G)}).comap rootGroup.carrier.subtype
  have hiter : ∀ j : ℕ, (⇑action.conjugation)^[j] x ∈ Y ∧
      Multiplicative.toAdd (rootGroup.coordinate ((⇑action.conjugation)^[j] x)) =
        ((scalar ^ j : Lˣ) : L) * Multiplicative.toAdd (rootGroup.coordinate x) := by
    intro j
    induction j with
    | zero => exact ⟨Subgroup.subset_closure (by simp), by simp⟩
    | succ j ih =>
      rw [Function.iterate_succ_apply']
      refine ⟨?_, ?_⟩
      · have h := ih.1
        change ((⇑action.conjugation)^[j] x : G) ∈ Subgroup.closure {d, (x : G)} at h
        change ((action.conjugation ((⇑action.conjugation)^[j] x) : rootGroup.carrier) : G) ∈
          Subgroup.closure {d, (x : G)}
        rw [action.coe_conjugation]
        exact Subgroup.mul_mem _ (Subgroup.mul_mem _
          (Subgroup.subset_closure (by simp)) h)
          (Subgroup.inv_mem _ (Subgroup.subset_closure (by simp)))
      · rw [action.coordinate_conjugation, ih.2, pow_succ]
        push_cast
        ring
  have hspan : AddSubgroup.closure {y : L | ∃ j : ℕ,
      y = Multiplicative.toAdd (rootGroup.coordinate x) * ((scalar ^ j : Lˣ) : L)} = ⊤ :=
    addSubgroup_closure_mul_pow_eq_top _ hx scalar hscalar
  let T : AddSubgroup L :=
    { carrier := {l | ∃ y ∈ Y, Multiplicative.toAdd (rootGroup.coordinate y) = l}
      zero_mem' := ⟨1, Y.one_mem, by simp⟩
      add_mem' := by
        rintro _ _ ⟨a, ha, rfl⟩ ⟨b, hb, rfl⟩
        exact ⟨a * b, Y.mul_mem ha hb, by simp⟩
      neg_mem' := by
        rintro _ ⟨a, ha, rfl⟩
        exact ⟨a⁻¹, Y.inv_mem ha, by simp⟩ }
  have hle : AddSubgroup.closure {y : L | ∃ j : ℕ,
      y = Multiplicative.toAdd (rootGroup.coordinate x) * ((scalar ^ j : Lˣ) : L)} ≤
      T := by
    rw [AddSubgroup.closure_le]
    rintro y ⟨j, rfl⟩
    refine ⟨(⇑action.conjugation)^[j] x, (hiter j).1, ?_⟩
    rw [(hiter j).2, mul_comm]
  rw [hspan] at hle
  have hsup : Y ⊔ ⁅(⊤ : Subgroup rootGroup.carrier), (⊤ : Subgroup rootGroup.carrier)⁆ = ⊤ := by
    rw [eq_top_iff]
    intro z _
    obtain ⟨y, hy, hyz'⟩ : Multiplicative.toAdd (rootGroup.coordinate z) ∈ T := hle trivial
    have hyz : rootGroup.coordinate y = rootGroup.coordinate z :=
      Multiplicative.toAdd.injective hyz'
    have : y⁻¹ * z ∈ ⁅(⊤ : Subgroup rootGroup.carrier), (⊤ : Subgroup rootGroup.carrier)⁆ := by
      apply rootGroup.ker_coordinate_le_commutator
      rw [MonoidHom.mem_ker, map_mul, map_inv, hyz, inv_mul_cancel]
    have h2 : y * (y⁻¹ * z) ∈
        Y ⊔ ⁅(⊤ : Subgroup rootGroup.carrier), (⊤ : Subgroup rootGroup.carrier)⁆ :=
      Subgroup.mul_mem _ (Subgroup.mem_sup_left hy) (Subgroup.mem_sup_right this)
    simpa using h2
  have hYtop : Y = ⊤ := eq_top_of_sup_commutator_eq_top hsup
  intro g hg
  have : (⟨g, hg⟩ : rootGroup.carrier) ∈ Y := hYtop ▸ Subgroup.mem_top _
  exact this

/-- Analogue of [Steinberg1962, Lemma 3.10]: let `d₁ = g d g⁻¹` commute with `d`, where `d` acts
on `X` by `k` and `d₁` by `l`, both nontrivial generating scalars. If `λ(u) ≠ 0`, then
`⟨d, u g⟩` contains `X` and `g`. -/
theorem le_closure_pair_mul (rootGroup : LambdaRootGroup G L) (d g : G) (k l : Lˣ)
    (hk : IsNontrivialGeneratingScalar k) (hl : IsNontrivialGeneratingScalar l)
    (hcommute : Commute d (g * d * g⁻¹))
    (actionD : rootGroup.Action d k) (actionD₁ : rootGroup.Action (g * d * g⁻¹) l)
    (u : rootGroup.carrier)
    (hu : Multiplicative.toAdd (rootGroup.coordinate u) ≠ 0) :
    rootGroup.carrier ≤ Subgroup.closure {d, (u : G) * g} ∧
      g ∈ Subgroup.closure {d, (u : G) * g} := by
  set d₁ := g * d * g⁻¹ with hd₁
  set F := Subgroup.closure {d, (u : G) * g} with hF
  have hdF : d ∈ F := Subgroup.subset_closure (by simp)
  have hxF : (u : G) * g ∈ F := Subgroup.subset_closure (by simp)
  have hyF : (u : G) * d₁ * (u : G)⁻¹ ∈ F := by
    have := F.mul_mem (F.mul_mem hxF hdF) (F.inv_mem hxF)
    convert this using 1
    simp [hd₁, mul_assoc]
  set v₀ : rootGroup.carrier := u * (actionD₁.conjugation u)⁻¹ with hv₀
  have hv₀G : (v₀ : G) = (u : G) * d₁ * (u : G)⁻¹ * d₁⁻¹ := by
    simp [hv₀, actionD₁.coe_conjugation, mul_assoc]
  set z : rootGroup.carrier := v₀ * (actionD.conjugation v₀)⁻¹ with hz
  have hzG : (z : G) =
      ((u : G) * d₁ * (u : G)⁻¹) * d * ((u : G) * d₁ * (u : G)⁻¹)⁻¹ * d⁻¹ := by
    have h1 : (z : G) = (v₀ : G) * (d * (v₀ : G)⁻¹ * d⁻¹) := by
      simp [hz, actionD.coe_conjugation, mul_assoc]
    have hd : d₁⁻¹ * d * d₁ = d := by
      rw [mul_assoc, hcommute.eq]
      group
    rw [h1, hv₀G]
    calc _ = ((u : G) * d₁ * (u : G)⁻¹) * (d₁⁻¹ * d * d₁) *
          ((u : G) * d₁ * (u : G)⁻¹)⁻¹ * d⁻¹ := by group
      _ = _ := by rw [hd]
  have hzF : (z : G) ∈ F := by
    rw [hzG]
    exact F.mul_mem (F.mul_mem (F.mul_mem hyF hdF) (F.inv_mem hyF)) (F.inv_mem hdF)
  have hcoord : Multiplicative.toAdd (rootGroup.coordinate z) =
      (1 - (k : L)) * ((1 - (l : L)) * Multiplicative.toAdd (rootGroup.coordinate u)) := by
    simp only [hz, hv₀, map_mul, map_inv, toAdd_mul, toAdd_inv, actionD.coordinate_conjugation,
      actionD₁.coordinate_conjugation]
    ring
  have hk1 : (k : L) ≠ 1 := fun h ↦ hk.2 (Units.ext h)
  have hl1 : (l : L) ≠ 1 := fun h ↦ hl.2 (Units.ext h)
  have hz0 : Multiplicative.toAdd (rootGroup.coordinate z) ≠ 0 := by
    rw [hcoord]
    exact mul_ne_zero (sub_ne_zero.2 hk1.symm) (mul_ne_zero (sub_ne_zero.2 hl1.symm) hu)
  have hXF : rootGroup.carrier ≤ F := by
    refine (rootGroup.le_closure_pair d k hk.1 actionD z hz0).trans ((Subgroup.closure_le F).2 ?_)
    rintro a (rfl | rfl)
    · exact hdF
    · exact hzF
  refine ⟨hXF, ?_⟩
  have : (u : G)⁻¹ * ((u : G) * g) ∈ F := F.mul_mem (F.inv_mem (hXF u.2)) hxF
  simpa using this

/-- Analogue of [Steinberg1962, Lemma 3.12]: let `X_r`, `X_s` be λ-root groups commuting
elementwise, `d₁ = g d g⁻¹`, `d₂ = g⁻¹ d g` with `d, d₁, d₂` pairwise commuting. Suppose `d`
centralises `X_r` and acts on `X_s` by `k`, `d₁` acts on `X_r` by `l` and on `X_s` by `m`, and `d₂`
acts on `X_r` by `n`, all nontrivial generating scalars. If `λ(u_r) ≠ 0` and `λ(u_s) ≠ 0`, then
`⟨d, u_r u_s g⟩` contains `X_r`, `X_s` and `g`. -/
theorem le_closure_pair_mul_mul (rootGroupR rootGroupS : LambdaRootGroup G L)
    (hcommuteRoot : ∀ a ∈ rootGroupR.carrier, ∀ b ∈ rootGroupS.carrier, Commute a b)
    (d g : G) (k l m n : Lˣ)
    (hk : IsNontrivialGeneratingScalar k) (hl : IsNontrivialGeneratingScalar l)
    (hm : IsNontrivialGeneratingScalar m) (hn : IsNontrivialGeneratingScalar n)
    (hcommuteD₁ : Commute d (g * d * g⁻¹)) (hcommuteD₂ : Commute d (g⁻¹ * d * g))
    (hcommuteD₁D₂ : Commute (g * d * g⁻¹) (g⁻¹ * d * g))
    (hcentralise : ∀ a ∈ rootGroupR.carrier, Commute d a)
    (actionDS : rootGroupS.Action d k)
    (actionD₁R : rootGroupR.Action (g * d * g⁻¹) l)
    (actionD₁S : rootGroupS.Action (g * d * g⁻¹) m)
    (actionD₂R : rootGroupR.Action (g⁻¹ * d * g) n)
    (uR : rootGroupR.carrier) (uS : rootGroupS.carrier)
    (huR : Multiplicative.toAdd (rootGroupR.coordinate uR) ≠ 0)
    (huS : Multiplicative.toAdd (rootGroupS.coordinate uS) ≠ 0) :
    rootGroupR.carrier ≤ Subgroup.closure {d, (uR : G) * (uS : G) * g} ∧
      rootGroupS.carrier ≤ Subgroup.closure {d, (uR : G) * (uS : G) * g} ∧
      g ∈ Subgroup.closure {d, (uR : G) * (uS : G) * g} := by
  classical
  set d₁ := g * d * g⁻¹ with hd₁
  set d₂ := g⁻¹ * d * g with hd₂
  set y : G := (uR : G) * (uS : G) * g with hy
  set F := Subgroup.closure {d, y} with hF
  have hdF : d ∈ F := Subgroup.subset_closure (by simp)
  have hyF : y ∈ F := Subgroup.subset_closure (by simp)
  have hk1 : (k : L) ≠ 1 := fun h ↦ hk.2 (Units.ext h)
  have hl1 : (l : L) ≠ 1 := fun h ↦ hl.2 (Units.ext h)
  have hm1 : (m : L) ≠ 1 := fun h ↦ hm.2 (Units.ext h)
  have hn1 : (n : L) ≠ 1 := fun h ↦ hn.2 (Units.ext h)
  set aR : rootGroupR.carrier := uR * (actionD₁R.conjugation uR)⁻¹ with haR
  set aS : rootGroupS.carrier := uS * (actionD₁S.conjugation uS)⁻¹ with haS
  have haRG : (aR : G) = (uR : G) * d₁ * (uR : G)⁻¹ * d₁⁻¹ := by
    simp [haR, actionD₁R.coe_conjugation, mul_assoc]
  have haSG : (aS : G) = (uS : G) * d₁ * (uS : G)⁻¹ * d₁⁻¹ := by
    simp [haS, actionD₁S.coe_conjugation, mul_assoc]
  have hcomm_uRuS : Commute (uR : G) (uS : G) := hcommuteRoot _ uR.2 _ uS.2
  have hcomm_uRaS : Commute (uR : G) (aS : G) := hcommuteRoot _ uR.2 _ aS.2
  have hyd : y * d * y⁻¹ = (aS : G) * ((aR : G) * d₁) := by
    have h1 : y * d * y⁻¹ = (uR : G) * ((aS : G) * d₁) * (uR : G)⁻¹ := by
      rw [haSG]
      have : y * d * y⁻¹ = (uR : G) * (uS : G) * d₁ * (uS : G)⁻¹ * (uR : G)⁻¹ := by
        simp [hy, hd₁, mul_assoc]
      rw [this]
      group
    rw [h1]
    have h2 : (uR : G) * ((aS : G) * d₁) * (uR : G)⁻¹ =
        ((uR : G) * (aS : G) * (uR : G)⁻¹) * ((uR : G) * d₁ * (uR : G)⁻¹) := by group
    rw [h2, hcomm_uRaS.eq, haRG]
    group
  have hcentR : Commute d (aR : G) := hcentralise _ aR.2
  have hcd₁ : d₁ * d = d * d₁ := hcommuteD₁.eq.symm
  set zS : rootGroupS.carrier := aS * (actionDS.conjugation aS)⁻¹ with hzS
  have hzSG : (zS : G) = (y * d * y⁻¹) * d * (y * d * y⁻¹)⁻¹ * d⁻¹ := by
    have h1 : (zS : G) = (aS : G) * (d * (aS : G)⁻¹ * d⁻¹) := by
      simp [hzS, actionDS.coe_conjugation, mul_assoc]
    rw [h1, hyd]
    have e1 : d₁ * d * d₁⁻¹ = d := by rw [hcd₁]; group
    have e2 : (aR : G) * d * (aR : G)⁻¹ = d := by rw [← hcentR.eq]; group
    symm
    calc _ = (aS : G) * ((aR : G) * (d₁ * d * d₁⁻¹) * (aR : G)⁻¹) * (aS : G)⁻¹ * d⁻¹ := by
          group
      _ = _ := by rw [e1, e2]; group
  have hzSF : (zS : G) ∈ F := by
    rw [hzSG]
    have hT : y * d * y⁻¹ ∈ F := F.mul_mem (F.mul_mem hyF hdF) (F.inv_mem hyF)
    exact F.mul_mem (F.mul_mem (F.mul_mem hT hdF) (F.inv_mem hT)) (F.inv_mem hdF)
  have hzS0 : Multiplicative.toAdd (rootGroupS.coordinate zS) ≠ 0 := by
    have : Multiplicative.toAdd (rootGroupS.coordinate zS) =
        (1 - (k : L)) * ((1 - (m : L)) * Multiplicative.toAdd (rootGroupS.coordinate uS)) := by
      simp only [hzS, haS, map_mul, map_inv, toAdd_mul, toAdd_inv,
        actionDS.coordinate_conjugation, actionD₁S.coordinate_conjugation]
      ring
    rw [this]
    exact mul_ne_zero (sub_ne_zero.2 hk1.symm) (mul_ne_zero (sub_ne_zero.2 hm1.symm) huS)
  have hSF : rootGroupS.carrier ≤ F := by
    refine (rootGroupS.le_closure_pair d k hk.1 actionDS zS hzS0).trans
      ((Subgroup.closure_le F).2 ?_)
    rintro a (rfl | rfl)
    · exact hdF
    · exact hzSF
  have huSF : (uS : G) ∈ F := hSF uS.2
  set t : G := (uR : G) * g with ht
  have htF : t ∈ F := by
    have h4 : (uS : G)⁻¹ * (uR : G) * (uS : G) = uR := by
      rw [mul_assoc, hcomm_uRuS.eq]; group
    have : t = (uS : G)⁻¹ * y := by
      rw [ht, hy, show (uS : G)⁻¹ * ((uR : G) * (uS : G) * g) =
        ((uS : G)⁻¹ * (uR : G) * (uS : G)) * g by group, h4]
    rw [this]
    exact F.mul_mem (F.inv_mem huSF) hyF
  have hd₂F : d₂ ∈ F := by
    have : d₂ = t⁻¹ * d * t := by
      have h3 : (uR : G)⁻¹ * d * (uR : G) = d := by
        rw [mul_assoc, (hcentralise _ uR.2).eq]; group
      simp only [ht, hd₂]
      rw [show ((uR : G) * g)⁻¹ * d * ((uR : G) * g) = g⁻¹ * ((uR : G)⁻¹ * d * (uR : G)) * g by
        group, h3]
    rw [this]
    exact F.mul_mem (F.mul_mem (F.inv_mem htF) hdF) htF
  have htdt : t * d * t⁻¹ = (aR : G) * d₁ := by
    rw [haRG]; simp only [ht, hd₁]; group
  set zR : rootGroupR.carrier := aR * (actionD₂R.conjugation aR)⁻¹ with hzR
  have hzRG : (zR : G) = (t * d * t⁻¹) * d₂ * (t * d * t⁻¹)⁻¹ * d₂⁻¹ := by
    have h1 : (zR : G) = (aR : G) * (d₂ * (aR : G)⁻¹ * d₂⁻¹) := by
      simp [hzR, actionD₂R.coe_conjugation, mul_assoc]
    rw [h1, htdt]
    have e1 : d₁ * d₂ * d₁⁻¹ = d₂ := by rw [hcommuteD₁D₂.eq]; group
    symm
    calc _ = (aR : G) * (d₁ * d₂ * d₁⁻¹) * (aR : G)⁻¹ * d₂⁻¹ := by group
      _ = _ := by rw [e1]; group
  have hzRF : (zR : G) ∈ F := by
    rw [hzRG]
    have hT : t * d * t⁻¹ ∈ F := F.mul_mem (F.mul_mem htF hdF) (F.inv_mem htF)
    exact F.mul_mem (F.mul_mem (F.mul_mem hT hd₂F) (F.inv_mem hT)) (F.inv_mem hd₂F)
  have hzR0 : Multiplicative.toAdd (rootGroupR.coordinate zR) ≠ 0 := by
    have : Multiplicative.toAdd (rootGroupR.coordinate zR) =
        (1 - (n : L)) * ((1 - (l : L)) * Multiplicative.toAdd (rootGroupR.coordinate uR)) := by
      simp only [hzR, haR, map_mul, map_inv, toAdd_mul, toAdd_inv,
        actionD₂R.coordinate_conjugation, actionD₁R.coordinate_conjugation]
      ring
    rw [this]
    exact mul_ne_zero (sub_ne_zero.2 hn1.symm) (mul_ne_zero (sub_ne_zero.2 hl1.symm) huR)
  have hRF : rootGroupR.carrier ≤ F := by
    refine (rootGroupR.le_closure_pair d₂ n hn.1 actionD₂R zR hzR0).trans
      ((Subgroup.closure_le F).2 ?_)
    rintro a (rfl | rfl)
    · exact hd₂F
    · exact hzRF
  refine ⟨hRF, hSF, ?_⟩
  have : (uR : G)⁻¹ * t ∈ F := F.mul_mem (F.inv_mem (hRF uR.2)) htF
  simpa [ht] using this

/-- If `d` acts on `X` by `k`, then `d⁻¹` acts on `X` by `k⁻¹`. -/
def Action.inv {rootGroup : LambdaRootGroup G L} {d : G} {k : Lˣ}
    (action : rootGroup.Action d k) : rootGroup.Action d⁻¹ k⁻¹ where
  conjugation := action.conjugation.symm
  coe_conjugation r := by
    have h := action.coe_conjugation (action.conjugation.symm r)
    rw [MulEquiv.apply_symm_apply] at h
    rw [h]
    group
  coordinate_conjugation r := by
    have h := action.coordinate_conjugation (action.conjugation.symm r)
    rw [MulEquiv.apply_symm_apply] at h
    simp only [Units.val_inv_eq_inv_val]
    rw [h, ← mul_assoc, inv_mul_cancel₀ k.ne_zero, one_mul]

/-- The rank one case of `le_closure_pair_mul`: if `d` acts on `X` by a generator `k ≠ 1` of
`Lˣ`, `g` inverts `d` and `λ(u) ≠ 0`, then `⟨d, u g⟩` contains `X` and `g`. -/
theorem le_closure_pair_of_inverting (rootGroup : LambdaRootGroup G L) (d g : G) (k : Lˣ)
    (hgen : Subgroup.zpowers k = ⊤) (hk : k ≠ 1)
    (action : rootGroup.Action d k) (hinv : g * d * g⁻¹ = d⁻¹)
    (u : rootGroup.carrier) (hu : Multiplicative.toAdd (rootGroup.coordinate u) ≠ 0) :
    rootGroup.carrier ≤ Subgroup.closure {d, (u : G) * g} ∧
      g ∈ Subgroup.closure {d, (u : G) * g} := by
  have hgoodk : IsNontrivialGeneratingScalar k := ⟨⟨k, hgen, Or.inl rfl⟩, hk⟩
  have hgoodl : IsNontrivialGeneratingScalar k⁻¹ :=
    ⟨⟨k⁻¹, by rw [Subgroup.zpowers_inv]; exact hgen, Or.inl rfl⟩, inv_ne_one.mpr hk⟩
  have hcommute : Commute d (g * d * g⁻¹) := by
    rw [hinv]
    exact (Commute.refl d).inv_right
  have hinvAction : rootGroup.Action (g * d * g⁻¹) k⁻¹ := hinv ▸ action.inv
  exact rootGroup.le_closure_pair_mul d g k k⁻¹ hgoodk hgoodl hcommute action hinvAction u hu

end CFSGCorollary.LambdaRootGroup
