module

public import CFSGCorollary.LieType.Twisted.ReeF4.Basic
public import CFSGCorollary.LieType.LambdaRootGroup.Basic
import CFSGCorollary.LieType.Twisted.ReeF4.Scalars

/-!
# The two λ-root groups of `²F₄(q)`

We show that the root groups `X_r = X_{-S₂}` and `X_s = X_{S₁}` of the large Ree group are
λ-root groups over `K`:

* `X_r ≅ (K, +)` via `c ↦ y c`, with coordinate `λ_r (y c) = c`;
* `X_s` is a Suzuki-type group of order `q²` with elements `x_s (t, v)` and multiplication
  `(t, v) (s, w) = (t + s, v + w + t ^ (2θ) s)`; its coordinate `λ_s (x_s (t, v)) = t` has kernel
  inside the commutator subgroup since the commutator values `t ^ (2θ) s + s ^ (2θ) t`
  additively generate `K`.

## Main definitions

* `CFSGCorollary.ReeF4.lambdaRootGroupR`: `X_r` as a λ-root group.
* `CFSGCorollary.ReeF4.lambdaRootGroupS`: `X_s` as a λ-root group.
-/

@[expose] public section

noncomputable section

namespace CFSGCorollary.ReeF4

open CFSG.Blueprint.Chevalley CFSG.LieType.Chevalley CFSG.LieType.Ree CFSG.LieType.Ree.ReeTag
open scoped commutatorElement

variable {K : Type} [Field K] [Finite K] [CharP K F4.prime] {m : ℕ}

/-! ### The root group `X_r` -/

omit [Finite K] in
theorem rootElemR_add (c d : K) : rootElemR m (c + d) = rootElemR m c * rootElemR m d := by
  have : CharP K 2 := inferInstanceAs (CharP K F4.prime)
  have : ExpChar K 2 := ExpChar.prime Nat.prime_two
  have hpow : (c + d) ^ 2 ^ m = c ^ 2 ^ m + d ^ 2 ^ m :=
    add_pow_char_pow (R := K) (x := c) (y := d) (p := 2) (n := m)
  unfold rootElemR
  rw [hpow, yUnit_add, yUnit_add]
  exact (largeRee_commute_yy (K := K) d (c ^ 2 ^ m)).mul_mul_mul_comm _ _

omit [Finite K] [CharP K F4.prime] in
theorem rootElemR_injective : Function.Injective (rootElemR (K := K) m) :=
  fun _ _ h ↦ (largeRee_y_inj h).1

omit [Finite K] in
theorem rootElemR_zero : rootElemR (K := K) m 0 = 1 := by
  simpa using rootElemR_add (K := K) (m := m) 0 0

/-- The root element map `y` as a monoid homomorphism `Multiplicative K →* ModGL F4.tag K`. -/
def rootElemRHom (K : Type) [Field K] [Finite K] [CharP K F4.prime] (m : ℕ) :
    Multiplicative K →* ModGL F4.tag K where
  toFun c := rootElemR m (Multiplicative.toAdd c)
  map_one' := rootElemR_zero
  map_mul' _ _ := rootElemR_add _ _

theorem rootElemRHom_injective : Function.Injective (rootElemRHom K m) :=
  fun _ _ h ↦ Multiplicative.toAdd.injective (rootElemR_injective h)

theorem coe_rootSubgroupR (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    (rootSubgroupR K m : Set (ModGL F4.tag K)) = Set.range (rootElemR (K := K) m) :=
  coe_largeReeA1Y hK

theorem rootSubgroupR_eq_range (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    rootSubgroupR K m = (rootElemRHom K m).range := by
  ext x
  rw [← SetLike.mem_coe, coe_rootSubgroupR hK]
  constructor
  · rintro ⟨c, rfl⟩; exact ⟨Multiplicative.ofAdd c, rfl⟩
  · rintro ⟨c, rfl⟩; exact ⟨Multiplicative.toAdd c, rfl⟩

/-- The coordinate `λ_r : X_r →* K`, inverse to `y`. -/
def coordinateR (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    rootSubgroupR K m →* Multiplicative K :=
  ((MulEquiv.subgroupCongr (rootSubgroupR_eq_range hK)).trans
    (MonoidHom.ofInjective (f := rootElemRHom K m) rootElemRHom_injective).symm).toMonoidHom

theorem coordinateR_rootElemR (hK : Nat.card K = 2 ^ (2 * m + 1)) (c : K) (h) :
    coordinateR hK ⟨rootElemR m c, h⟩ = Multiplicative.ofAdd c := by
  unfold coordinateR
  simp only [MulEquiv.toMonoidHom_eq_coe, MonoidHom.coe_ofClass, MulEquiv.trans_apply]
  rw [MulEquiv.symm_apply_eq]
  rfl

/-- The root group `X_r` as a λ-root group over `K`. -/
def lambdaRootGroupR (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    LambdaRootGroup (ModGL F4.tag K) K where
  carrier := rootSubgroupR K m
  finite := by
    rw [rootSubgroupR_eq_range hK]
    infer_instance
  isNilpotent := Group.nilpotent_of_mulEquiv
    ((MonoidHom.ofInjective (f := rootElemRHom K m) rootElemRHom_injective).trans
      (MulEquiv.subgroupCongr (rootSubgroupR_eq_range hK)).symm)
  coordinate := coordinateR hK
  ker_coordinate_le_commutator := by
    intro x hx
    rw [MonoidHom.mem_ker] at hx
    obtain ⟨x, hx'⟩ := x
    have hx2 : x ∈ Set.range (rootElemR (K := K) m) := by
      rw [← coe_rootSubgroupR hK]; exact hx'
    obtain ⟨c, rfl⟩ := hx2
    have hc : c = 0 :=
      Multiplicative.ofAdd.injective ((coordinateR_rootElemR hK c hx').symm.trans hx)
    subst hc
    have : (⟨rootElemR m 0, hx'⟩ : rootSubgroupR K m) = 1 := Subtype.ext rootElemR_zero
    rw [this]
    exact Subgroup.one_mem _

/-! ### The root group `X_s` -/

/-- Every element of `X_s` is `largeReeCoord m K t v` for a unique `(t, v)`. -/
theorem bijOn_rootElemS (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    Set.BijOn (fun p : K × K ↦ rootElemS m p.1 p.2) Set.univ
      (rootSubgroupS K m : Set (ModGL F4.tag K)) :=
  large_Ree_B2_fixed_coordinates m K hK |>.1

/-- The multiplication law `(t, v) (s, w) = (t + s, v + w + t ^ (2θ) s)`. -/
theorem rootElemS_mul (hK : Nat.card K = 2 ^ (2 * m + 1)) (t v s w : K) :
    rootElemS m t v * rootElemS m s w = rootElemS m (t + s) (v + w + t ^ (2 * 2 ^ m) * s) :=
  (large_Ree_B2_fixed_coordinates m K hK).2 t v s w

theorem rootElemS_mem_rootSubgroupS (hK : Nat.card K = 2 ^ (2 * m + 1)) (t v : K) :
    rootElemS m t v ∈ rootSubgroupS K m := by
  have h := (bijOn_rootElemS hK).mapsTo (Set.mem_univ (t, v))
  exact SetLike.mem_coe.mp h

theorem rootElemS_injective (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    Function.Injective (fun p : K × K ↦ rootElemS m p.1 p.2) :=
  fun _ _ h ↦ (bijOn_rootElemS hK).injOn (Set.mem_univ _) (Set.mem_univ _) h

theorem exists_rootElemS_eq_of_mem_rootSubgroupS (hK : Nat.card K = 2 ^ (2 * m + 1))
    {x : ModGL F4.tag K} (hx : x ∈ rootSubgroupS K m) : ∃ t v : K, rootElemS m t v = x := by
  obtain ⟨p, -, hp⟩ := (bijOn_rootElemS hK).surjOn (SetLike.mem_coe.mpr hx)
  exact ⟨p.1, p.2, hp⟩

/-- The coordinate `λ_s (largeReeCoord m K t v) = t`, as a total function. -/
def coordinateSFun (m : ℕ) (x : ModGL F4.tag K) : Multiplicative K :=
  Multiplicative.ofAdd (Function.invFun (fun p : K × K ↦ rootElemS m p.1 p.2) x).1

theorem coordinateSFun_rootElemS (hK : Nat.card K = 2 ^ (2 * m + 1)) (t v : K) :
    coordinateSFun m (rootElemS m t v) = Multiplicative.ofAdd t := by
  unfold coordinateSFun
  rw [Function.leftInverse_invFun (rootElemS_injective hK) (t, v)]

theorem rootElemS_zero (hK : Nat.card K = 2 ^ (2 * m + 1)) : rootElemS m (0 : K) 0 = 1 := by
  have h := rootElemS_mul hK (m := m) 0 0 0 0
  simp only [add_zero, mul_zero] at h
  exact mul_eq_left.mp h

/-- The coordinate `λ_s : X_s →* K`. -/
def coordinateS (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    rootSubgroupS K m →* Multiplicative K where
  toFun x := coordinateSFun m x
  map_one' := by
    change coordinateSFun m (1 : ModGL F4.tag K) = 1
    rw [← rootElemS_zero hK, coordinateSFun_rootElemS hK]
    rfl
  map_mul' x y := by
    obtain ⟨x, hx⟩ := x
    obtain ⟨y, hy⟩ := y
    obtain ⟨t, v, rfl⟩ := exists_rootElemS_eq_of_mem_rootSubgroupS hK hx
    obtain ⟨s, w, rfl⟩ := exists_rootElemS_eq_of_mem_rootSubgroupS hK hy
    change coordinateSFun m (rootElemS m t v * rootElemS m s w) =
      coordinateSFun m (rootElemS m t v) * coordinateSFun m (rootElemS m s w)
    rw [rootElemS_mul hK, coordinateSFun_rootElemS hK, coordinateSFun_rootElemS hK,
      coordinateSFun_rootElemS hK]
    rfl

theorem coordinateS_rootElemS (hK : Nat.card K = 2 ^ (2 * m + 1)) (t v : K) (h) :
    coordinateS hK ⟨rootElemS m t v, h⟩ = Multiplicative.ofAdd t :=
  coordinateSFun_rootElemS hK t v

theorem finite_rootSubgroupS (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    Finite (rootSubgroupS K m) := by
  have hfin : (rootSubgroupS K m : Set (ModGL F4.tag K)).Finite := by
    rw [← (bijOn_rootElemS hK).image_eq]; exact Set.toFinite _
  exact hfin.to_subtype

theorem isNilpotent_rootSubgroupS (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    Group.IsNilpotent (rootSubgroupS K m) := by
  have hcard : Nat.card (rootSubgroupS K m) = 2 ^ (2 * (2 * m + 1)) := by
    have e := Nat.card_congr ((bijOn_rootElemS hK).equiv _)
    have h2 : Nat.card (rootSubgroupS K m) = Nat.card (K × K) :=
      e.symm.trans (Nat.card_congr (Equiv.Set.univ (K × K)))
    rw [h2, Nat.card_prod, hK, ← pow_add]
    ring_nf
  have := finite_rootSubgroupS hK
  exact IsPGroup.isNilpotent (IsPGroup.of_card hcard)

theorem rootElemS_mul_inv (hK : Nat.card K = 2 ^ (2 * m + 1)) (u w₁ w₂ : K) :
    rootElemS m u w₁ * (rootElemS m u w₂)⁻¹ = rootElemS m 0 (w₁ - w₂) := by
  rw [mul_inv_eq_iff_eq_mul, rootElemS_mul hK]
  have : (0 : K) ^ (2 * 2 ^ m) = 0 := zero_pow (by positivity)
  simp [this]

theorem commutator_rootElemS_rootElemS (hK : Nat.card K = 2 ^ (2 * m + 1)) (t s : K) :
    ⁅rootElemS m t 0, rootElemS m s 0⁆ =
      rootElemS m 0 (t ^ (2 * 2 ^ m) * s - s ^ (2 * 2 ^ m) * t) := by
  have h1 : ⁅rootElemS m t 0, rootElemS m s 0⁆ =
      (rootElemS m t 0 * rootElemS m s 0) * (rootElemS m s 0 * rootElemS m t 0)⁻¹ := by
    simp [commutatorElement_def, mul_assoc]
  rw [h1, rootElemS_mul hK, rootElemS_mul hK, add_comm s t, rootElemS_mul_inv hK]
  simp

theorem ker_coordinateS_le_commutator (hm : 1 ≤ m) (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    (coordinateS hK).ker ≤
      ⁅(⊤ : Subgroup (rootSubgroupS K m)), (⊤ : Subgroup (rootSubgroupS K m))⁆ := by
  have : CharP K 2 := inferInstanceAs (CharP K F4.prime)
  set C := ⁅(⊤ : Subgroup (rootSubgroupS K m)), (⊤ : Subgroup (rootSubgroupS K m))⁆
  let z : K → rootSubgroupS K m := fun v ↦ ⟨rootElemS m 0 v, rootElemS_mem_rootSubgroupS hK 0 v⟩
  let S : AddSubgroup K :=
    { carrier := {v | z v ∈ C}
      zero_mem' := by
        have : z 0 = 1 := Subtype.ext (rootElemS_zero hK)
        change z 0 ∈ C
        rw [this]; exact C.one_mem
      add_mem' := by
        intro a b ha hb
        have : z (a + b) = z a * z b := by
          apply Subtype.ext
          change rootElemS m 0 (a + b) = rootElemS m 0 a * rootElemS m 0 b
          rw [rootElemS_mul hK]; simp
        change z (a + b) ∈ C
        rw [this]; exact C.mul_mem ha hb
      neg_mem' := by
        intro a ha
        have : z (-a) = (z a)⁻¹ := by
          apply eq_inv_of_mul_eq_one_right
          apply Subtype.ext
          change rootElemS m 0 a * rootElemS m 0 (-a) = 1
          rw [rootElemS_mul hK]; simp [rootElemS_zero hK]
        change z (-a) ∈ C
        rw [this]; exact C.inv_mem ha }
  have hS : S = ⊤ := by
    rw [eq_top_iff, ← addSubgroup_closure_commutator_values_eq_top hm hK,
      AddSubgroup.closure_le]
    rintro x ⟨s, t, rfl⟩
    change z _ ∈ C
    have : z (t ^ (2 * 2 ^ m) * s + s ^ (2 * 2 ^ m) * t) =
        ⁅(⟨rootElemS m t 0, rootElemS_mem_rootSubgroupS hK t 0⟩ : rootSubgroupS K m),
          ⟨rootElemS m s 0, rootElemS_mem_rootSubgroupS hK s 0⟩⁆ := by
      apply Subtype.ext
      change _ = ⁅rootElemS m t 0, rootElemS m s 0⁆
      rw [commutator_rootElemS_rootElemS hK, CharTwo.sub_eq_add]
    rw [this]
    exact Subgroup.commutator_mem_commutator trivial trivial
  intro x hx
  obtain ⟨x, hxm⟩ := x
  obtain ⟨t, v, rfl⟩ := exists_rootElemS_eq_of_mem_rootSubgroupS hK hxm
  have ht : t = 0 := by
    have := MonoidHom.mem_ker.mp hx
    rw [coordinateS_rootElemS hK] at this
    exact Multiplicative.ofAdd.injective this
  subst ht
  have : v ∈ S := by rw [hS]; trivial
  exact this

/-- The root group `X_s` as a λ-root group over `K`. -/
def lambdaRootGroupS (hm : 1 ≤ m) (hK : Nat.card K = 2 ^ (2 * m + 1)) :
    LambdaRootGroup (ModGL F4.tag K) K where
  carrier := rootSubgroupS K m
  finite := finite_rootSubgroupS hK
  isNilpotent := isNilpotent_rootSubgroupS hK
  coordinate := coordinateS hK
  ker_coordinate_le_commutator := ker_coordinateS_le_commutator hm hK

end CFSGCorollary.ReeF4
