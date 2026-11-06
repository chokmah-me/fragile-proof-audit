module

public import CFSGCorollary.LieType.Twisted.ReeF4.RootGroups

/-!
# Torus actions on the λ-root groups of `²F₄(q)`

We compute how the torus elements `d`, `d₁ = g d g⁻¹` and `d₂ = g⁻¹ d g` act on the λ-root
groups `X_r = X_{-S₂}` and `X_s = X_{S₁}`. Writing `θ = 2 ^ m`:

* `d` centralises `X_r`, `d₁` acts on it by `u ^ (2 - 2θ)` and `d₂` by `u ^ (2θ - 2)`;
* `d` acts on `X_s` by `u ^ (3θ - 2)` and `d₁` by `u ^ (1 - θ)`.

## Main results

* `CFSGCorollary.ReeF4.commute_fixedTorusElt_of_mem_rootSubgroupR`
* `CFSGCorollary.ReeF4.nonempty_action_fixedTorusEltConj_lambdaRootGroupR`
* `CFSGCorollary.ReeF4.nonempty_action_fixedTorusEltConjInv_lambdaRootGroupR`
* `CFSGCorollary.ReeF4.nonempty_action_fixedTorusElt_lambdaRootGroupS`
* `CFSGCorollary.ReeF4.nonempty_action_fixedTorusEltConj_lambdaRootGroupS`
-/

@[expose] public section

noncomputable section

namespace CFSGCorollary.ReeF4

open CFSG.Blueprint.Chevalley CFSG.LieType.Chevalley CFSG.LieType.Ree CFSG.LieType.Ree.ReeTag

variable {K : Type} [Field K] [Finite K] [CharP K F4.prime] {m : ℕ}

/-! ### Action on `X_{-S₂}` -/

/-- If `h ∈ Γ` scales the root elements of `-α₀` by `χ` and normalises the root group of
`-α₃`, then `h` conjugates `y c` to `y (χ c)`. -/
theorem conj_rootElemR_of_conj_pinnedX (hK : Nat.card K = 2 ^ (2 * m + 1))
    {h : ModGL F4.tag K} (hh : h ∈ F4.reeGamma K m) (χ : K)
    (h0 : ∀ c : K, h * pinnedX F4.tag K (-(Pi.single largeReeI1 (1 : ℤ))) c * h⁻¹ =
      pinnedX F4.tag K (-(Pi.single largeReeI1 (1 : ℤ))) (χ * c))
    (h3 : ∀ c : K, ∃ e : K, h * pinnedX F4.tag K (-(Pi.single largeReeI4 (1 : ℤ))) c * h⁻¹ =
      pinnedX F4.tag K (-(Pi.single largeReeI4 (1 : ℤ))) e) (c : K) :
    h * rootElemR m c * h⁻¹ = rootElemR m (χ * c) := by
  obtain ⟨e, he⟩ := h3 (c ^ 2 ^ m)
  have hy : rootElemR m c ∈ rootSubgroupR K m := by
    rw [← SetLike.mem_coe, coe_rootSubgroupR hK]; exact ⟨c, rfl⟩
  have hyΓ : rootElemR m c ∈ F4.reeGamma K m := (Subgroup.mem_inf.1 hy).2
  have hconj : h * rootElemR m c * h⁻¹ =
      pinnedX F4.tag K (-(Pi.single largeReeI1 (1 : ℤ))) (χ * c) *
        pinnedX F4.tag K (-(Pi.single largeReeI4 (1 : ℤ))) e := by
    have : rootElemR m c = pinnedX F4.tag K (-(Pi.single largeReeI1 (1 : ℤ))) c *
        pinnedX F4.tag K (-(Pi.single largeReeI4 (1 : ℤ))) (c ^ 2 ^ m) := by
      unfold rootElemR; rw [pinnedX_neg_single, pinnedX_neg_single]
    rw [this, ← h0, ← he]
    group
  have hmem : h * rootElemR m c * h⁻¹ ∈ rootSubgroupR K m := by
    refine Subgroup.mem_inf.2 ⟨?_, mul_mem (mul_mem hh hyΓ) (inv_mem hh)⟩
    rw [hconj, F4_fixedOrbitRoots_zero, Set.image_insert_eq, Set.image_singleton]
    exact mul_mem (pinnedX_mem_rootSpan (by simp) _) (pinnedX_mem_rootSpan (by simp) _)
  rw [← SetLike.mem_coe, coe_rootSubgroupR hK] at hmem
  obtain ⟨c', hc'⟩ := hmem
  rw [← hc']
  congr 1
  rw [hconj] at hc'
  unfold rootElemR at hc'
  rw [pinnedX_neg_single, pinnedX_neg_single] at hc'
  exact (largeRee_y_inj hc').1

theorem exists_rootElemR_eq_of_mem_rootSubgroupR (hK : Nat.card K = 2 ^ (2 * m + 1))
    {x : ModGL F4.tag K} (hx : x ∈ rootSubgroupR K m) : ∃ c : K, rootElemR m c = x := by
  rw [← SetLike.mem_coe, coe_rootSubgroupR hK] at hx
  exact hx

theorem rootElemR_mem_rootSubgroupR (hK : Nat.card K = 2 ^ (2 * m + 1)) (c : K) :
    rootElemR m c ∈ rootSubgroupR K m := by
  rw [← SetLike.mem_coe, coe_rootSubgroupR hK]; exact ⟨c, rfl⟩

/-- An element conjugating `y c` to `y (χ c)` acts on `(X_r, λ_r)` by `χ`. -/
theorem nonempty_action_lambdaRootGroupR_of_conj (hK : Nat.card K = 2 ^ (2 * m + 1))
    {h : ModGL F4.tag K} (χ : Kˣ)
    (hconj : ∀ c : K, h * rootElemR m c * h⁻¹ = rootElemR m ((χ : K) * c)) :
    Nonempty ((lambdaRootGroupR hK).Action h χ) := by
  have hfwd : ∀ x ∈ rootSubgroupR K m, h * x * h⁻¹ ∈ rootSubgroupR K m := by
    intro x hx
    obtain ⟨c, rfl⟩ := exists_rootElemR_eq_of_mem_rootSubgroupR hK hx
    rw [hconj]; exact rootElemR_mem_rootSubgroupR hK _
  have hbwd : ∀ x ∈ rootSubgroupR K m, h⁻¹ * x * h ∈ rootSubgroupR K m := by
    intro x hx
    obtain ⟨c, rfl⟩ := exists_rootElemR_eq_of_mem_rootSubgroupR hK hx
    have : h⁻¹ * rootElemR m c * h = rootElemR m (((χ⁻¹ : Kˣ) : K) * c) := by
      have h2 := hconj (((χ⁻¹ : Kˣ) : K) * c)
      rw [← mul_assoc, ← Units.val_mul, mul_inv_cancel, Units.val_one, one_mul] at h2
      rw [← h2]; group
    rw [this]; exact rootElemR_mem_rootSubgroupR hK _
  let e : (lambdaRootGroupR hK).carrier ≃* (lambdaRootGroupR hK).carrier :=
    { toFun := fun x ↦ ⟨h * x * h⁻¹, hfwd _ x.2⟩
      invFun := fun x ↦ ⟨h⁻¹ * x * h, hbwd _ x.2⟩
      left_inv := fun x ↦ Subtype.ext (by simp [mul_assoc])
      right_inv := fun x ↦ Subtype.ext (by simp [mul_assoc])
      map_mul' := fun x y ↦ Subtype.ext (by simp [mul_assoc]) }
  refine ⟨⟨e, fun x ↦ rfl, ?_⟩⟩
  intro x
  obtain ⟨c, hc⟩ := exists_rootElemR_eq_of_mem_rootSubgroupR hK x.2
  have hx : x = ⟨rootElemR m c, rootElemR_mem_rootSubgroupR hK c⟩ := Subtype.ext hc.symm
  have he : e x = ⟨rootElemR m ((χ : K) * c), rootElemR_mem_rootSubgroupR hK _⟩ :=
    Subtype.ext (by rw [hx]; exact hconj c)
  change Multiplicative.toAdd (coordinateR hK (e x)) = _
  rw [he, hx]
  change Multiplicative.toAdd (coordinateR hK ⟨rootElemR m ((χ : K) * c), _⟩) =
    (χ : K) * Multiplicative.toAdd (coordinateR hK ⟨rootElemR m c, _⟩)
  rw [coordinateR_rootElemR, coordinateR_rootElemR]; rfl

/-- `d` centralises `X_r`. -/
theorem commute_fixedTorusElt_of_mem_rootSubgroupR (hK : Nat.card K = 2 ^ (2 * m + 1))
    (u : Kˣ) {x : ModGL F4.tag K} (hx : x ∈ rootSubgroupR K m) :
    Commute (fixedTorusElt m u) x := by
  obtain ⟨c, rfl⟩ := exists_rootElemR_eq_of_mem_rootSubgroupR hK hx
  have hΓ := (Subgroup.mem_inf.1 (fixedTorusElt_mem_reeFixedTorus hK u)).2
  have := conj_rootElemR_of_conj_pinnedX hK hΓ 1
    (fun c ↦ by
      rw [fixedTorusElt_conj_pinnedX u (isRoot_neg_single _ _), torusExponent_neg_alpha0]
      simp)
    (fun c ↦ ⟨_, fixedTorusElt_conj_pinnedX u (isRoot_neg_single _ _) c⟩) c
  rw [one_mul] at this
  exact (mul_inv_eq_iff_eq_mul.1 this :)

/-- `d₁` acts on `(X_r, λ_r)` by `u ^ (2 - 2θ)`. -/
theorem nonempty_action_fixedTorusEltConj_lambdaRootGroupR (hK : Nat.card K = 2 ^ (2 * m + 1))
    (u : Kˣ) :
    Nonempty ((lambdaRootGroupR hK).Action (fixedTorusEltConj m u)
      (u ^ (2 - 2 * 2 ^ m : ℤ))) := by
  have hΓ := (Subgroup.mem_inf.1 (fixedTorusEltConj_mem_reeFixedTorus hK u)).2
  refine nonempty_action_lambdaRootGroupR_of_conj hK _ fun c ↦ ?_
  refine conj_rootElemR_of_conj_pinnedX hK hΓ _ ?_
    (fun c ↦ ⟨_, fixedTorusEltConj_conj_pinnedX u (isRoot_neg_single _ _) c⟩) c
  intro c
  rw [fixedTorusEltConj_conj_pinnedX u (isRoot_neg_single _ _),
    coxeterWeylElement_inv_smul_neg_alpha0, torusExponent_one_two_two_zero]

/-- `d₂` acts on `(X_r, λ_r)` by `u ^ (2θ - 2)`. -/
theorem nonempty_action_fixedTorusEltConjInv_lambdaRootGroupR
    (hK : Nat.card K = 2 ^ (2 * m + 1)) (u : Kˣ) :
    Nonempty ((lambdaRootGroupR hK).Action (fixedTorusEltConjInv m u)
      (u ^ (2 * 2 ^ m - 2 : ℤ))) := by
  have hΓ := (Subgroup.mem_inf.1 (fixedTorusEltConjInv_mem_reeFixedTorus hK u)).2
  refine nonempty_action_lambdaRootGroupR_of_conj hK _ fun c ↦ ?_
  refine conj_rootElemR_of_conj_pinnedX hK hΓ _ ?_
    (fun c ↦ ⟨_, fixedTorusEltConjInv_conj_pinnedX u (isRoot_neg_single _ _) c⟩) c
  intro c
  rw [fixedTorusEltConjInv_conj_pinnedX u (isRoot_neg_single _ _),
    coxeterWeylElement_smul_neg_alpha0, torusExponent_neg_one_neg_two_neg_two_neg_two]

/-! ### Action on `X_{S₁}` -/

/-- The root element `x_{β_i}(c)` of the `B₂` block, as an element of `ModGL`. -/
def blockX (K : Type) [Field K] (i : Fin 4) (c : K) : ModGL F4.tag K :=
  largeReeX K i c

/-- The product `largeReeP K A B C D` of root elements of the `B₂` block, as an element of
`ModGL`. -/
def blockProd (K : Type) [Field K] (A B C D : K) : ModGL F4.tag K :=
  largeReeP K A B C D

/-- The roots `β_i` of the `B₂` block, typed as vectors in `Fin F4.tag.rank → ℤ` so that the Weyl
group of `F4.tag` acts on them. -/
def blockRoot (i : Fin 4) : Fin F4.tag.rank → ℤ :=
  largeReeRoot i

omit [Finite K] [CharP K F4.prime] in
theorem blockProd_def (A B C D : K) :
    blockProd K A B C D = blockX K 0 A * blockX K 1 B * blockX K 2 C * blockX K 3 D :=
  rfl

omit [Finite K] [CharP K F4.prime] in
/-- The root element `x_s (t, v)` in block coordinates. -/
theorem rootElemS_eq_blockProd (t v : K) :
    rootElemS m t v =
      blockProd K t (t ^ (2 * 2 ^ m)) v (v ^ (2 * 2 ^ m) + t ^ 2 * t ^ (2 * 2 ^ m)) :=
  rfl

/-- If conjugation by `h ∈ Γ` scales the first coordinate of `largeReeP` by `k`, then `h` acts
on `(X_s, λ_s)` by `k`. -/
theorem nonempty_action_lambdaRootGroupS_of_conj (hm : 1 ≤ m)
    (hK : Nat.card K = 2 ^ (2 * m + 1)) (h : ModGL F4.tag K) (hΓ : h ∈ F4.reeGamma K m) (k : Kˣ)
    (hP : ∀ A B C D : K, ∃ B' C' D' : K,
      h * blockProd K A B C D * h⁻¹ = blockProd K ((k : K) * A) B' C' D') :
    Nonempty ((lambdaRootGroupS hm hK).Action h k) := by
  have key : ∀ t v : K, ∃ B' C' D' : K,
      h * rootElemS m t v * h⁻¹ = blockProd K ((k : K) * t) B' C' D' := by
    intro t v
    rw [rootElemS_eq_blockProd]
    exact hP _ _ _ _
  have hmem : ∀ x ∈ rootSubgroupS K m, h * x * h⁻¹ ∈ rootSubgroupS K m := by
    intro x hx
    obtain ⟨t, v, rfl⟩ := exists_rootElemS_eq_of_mem_rootSubgroupS hK hx
    obtain ⟨B', C', D', e⟩ := key t v
    rw [e]
    have hr : blockProd K ((k : K) * t) B' C' D' ∈
        rootSpan F4.tag K (F4.fixedOrbitRoots ⟨1, by decide⟩) := by
      rw [F4_fixedOrbitRoots_one]
      exact largeReeP_mem_rootSpan _ _ _ _
    refine Subgroup.mem_inf.2 ⟨hr, ?_⟩
    rw [← e]
    exact Subgroup.mul_mem _ (Subgroup.mul_mem _ hΓ
      (Subgroup.mem_inf.1 (rootElemS_mem_rootSubgroupS hK t v)).2) (Subgroup.inv_mem _ hΓ)
  let f : rootSubgroupS K m →* rootSubgroupS K m :=
    { toFun := fun x ↦ ⟨h * (x : ModGL F4.tag K) * h⁻¹, hmem _ x.2⟩
      map_one' := by ext; simp
      map_mul' := fun x y ↦ by ext; simp [mul_assoc] }
  have hinj : Function.Injective f := by
    intro x y hxy
    have := congrArg Subtype.val hxy
    simp only [f, MonoidHom.coe_mk, OneHom.coe_mk, mul_left_inj, mul_right_inj] at this
    exact Subtype.ext this
  have : Finite (rootSubgroupS K m) := (lambdaRootGroupS hm hK).finite
  have hbij : Function.Bijective f := Finite.injective_iff_bijective.1 hinj
  refine ⟨⟨MulEquiv.ofBijective f hbij, fun x ↦ rfl, ?_⟩⟩
  intro x
  obtain ⟨x, hx⟩ := x
  obtain ⟨t, v, rfl⟩ := exists_rootElemS_eq_of_mem_rootSubgroupS hK hx
  obtain ⟨B', C', D', e⟩ := key t v
  obtain ⟨t', v', ht'⟩ := exists_rootElemS_eq_of_mem_rootSubgroupS hK (hmem _ hx)
  have hcoord : t' = (k : K) * t := by
    have h1 : blockProd K t' (t' ^ (2 * 2 ^ m)) v' (v' ^ (2 * 2 ^ m) + t' ^ 2 * t' ^ (2 * 2 ^ m)) =
        blockProd K ((k : K) * t) B' C' D' := by
      rw [← rootElemS_eq_blockProd, ht', e]
    exact (largeReeP_injective h1).1
  change Multiplicative.toAdd (coordinateS hK ⟨h * rootElemS m t v * h⁻¹, hmem _ hx⟩) = _
  have : (⟨h * rootElemS m t v * h⁻¹, hmem _ hx⟩ : rootSubgroupS K m) =
      ⟨rootElemS m t' v', rootElemS_mem_rootSubgroupS hK _ _⟩ := Subtype.ext ht'.symm
  rw [this, coordinateS_rootElemS]
  have h2 : (lambdaRootGroupS hm hK).coordinate ⟨rootElemS m t v, hx⟩ =
      Multiplicative.ofAdd t := coordinateS_rootElemS hK t v hx
  rw [h2]
  exact hcoord

omit [Finite K] [CharP K F4.prime] in
/-- A torus element acting on each `x_{β_i}` by a character `c i` scales the first coordinate of
`largeReeP` by `c 0`. -/
theorem exists_conj_blockProd_of_conj_blockX (h : ModGL F4.tag K) (c : Fin 4 → K)
    (hc : ∀ i (x : K), h * blockX K i x * h⁻¹ = blockX K i (c i * x))
    (k : K) (hk : c 0 = k) (A B C D : K) :
    ∃ B' C' D' : K, h * blockProd K A B C D * h⁻¹ = blockProd K (k * A) B' C' D' := by
  refine ⟨c 1 * B, c 2 * C, c 3 * D, ?_⟩
  rw [← hk, blockProd_def, blockProd_def, ← hc, ← hc, ← hc, ← hc]
  group

theorem blockRoot_zero : blockRoot 0 = f4RootVector 0 0 1 0 := rfl

omit [Finite K] [CharP K F4.prime] in
theorem blockX_eq_pinnedX (i : Fin 4) (c : K) :
    blockX K i c = pinnedX F4.tag K (blockRoot i) c := rfl

/-- `d` acts on `(X_s, λ_s)` by `u ^ (3θ - 2)`. -/
theorem nonempty_action_fixedTorusElt_lambdaRootGroupS (hm : 1 ≤ m)
    (hK : Nat.card K = 2 ^ (2 * m + 1)) (u : Kˣ) :
    Nonempty ((lambdaRootGroupS hm hK).Action (fixedTorusElt m u) (u ^ (3 * 2 ^ m - 2 : ℤ))) := by
  refine nonempty_action_lambdaRootGroupS_of_conj hm hK _
    (Subgroup.mem_inf.1 (fixedTorusElt_mem_reeFixedTorus hK u)).2 _ ?_
  intro A B C D
  refine exists_conj_blockProd_of_conj_blockX (fixedTorusElt m u)
    (fun i ↦ ((u ^ torusExponent m (blockRoot i) : Kˣ) : K))
    (fun i x ↦ ?_) _ ?_ A B C D
  · rw [blockX_eq_pinnedX, blockX_eq_pinnedX]
    exact fixedTorusElt_conj_pinnedX u (largeReeRoot_pos i).1 x
  · rw [blockRoot_zero, torusExponent_alpha2]

/-- `d₁` acts on `(X_s, λ_s)` by `u ^ (1 - θ)`. -/
theorem nonempty_action_fixedTorusEltConj_lambdaRootGroupS (hm : 1 ≤ m)
    (hK : Nat.card K = 2 ^ (2 * m + 1)) (u : Kˣ) :
    Nonempty ((lambdaRootGroupS hm hK).Action (fixedTorusEltConj m u) (u ^ (1 - 2 ^ m : ℤ))) := by
  refine nonempty_action_lambdaRootGroupS_of_conj hm hK _
    (Subgroup.mem_inf.1 (fixedTorusEltConj_mem_reeFixedTorus hK u)).2 _ ?_
  intro A B C D
  refine exists_conj_blockProd_of_conj_blockX (fixedTorusEltConj m u)
    (fun i ↦ ((u ^ torusExponent m (coxeterWeylElement⁻¹ • blockRoot i) : Kˣ) : K))
    (fun i x ↦ ?_) _ ?_ A B C D
  · rw [blockX_eq_pinnedX, blockX_eq_pinnedX]
    exact fixedTorusEltConj_conj_pinnedX u (largeReeRoot_pos i).1 x
  · rw [blockRoot_zero, coxeterWeylElement_inv_smul_alpha2, torusExponent_zero_one_one_one]

end CFSGCorollary.ReeF4
