module

public import CFSGCorollary.TwoGenerated.Basic
public import CFSGCorollary.LieType.Chevalley.Roots.TypeB
public import CFSGCorollary.LieType.Steinberg.Diagonal
import CFSGCorollary.LieType.Steinberg.ClosurePair
import CFSGCorollary.LieType.Steinberg.GeneratingScalar

/-!
# Two-generation for type `B_m`, `|K| ≥ 3`

Let `G` carry a Steinberg system `x` of type `B_m` (CFSG's `cartanB m`, `m ≥ 3`) over a finite
field `K` with `|K| ≥ 3`, and let `r`, `s`, `μ`, `L` be as in
`CFSGCorollary.LieType.Chevalley.Roots.TypeB`. Following Steinberg 1962 §3.11, for a generator
`k` of `Kˣ` we show `G = ⟨h_μ(k), x r 1 · x s 1 · ω(L)⟩`: the subgroup generated contains the root
groups `X_r` and `X_s`, hence their `ω(L)`-conjugates, which include every `X_{±αᵢ}`. No unit
single commutator hypothesis is needed.

## Main results

* `CFSGCorollary.TypeB.closure_diagonal_mul_eq_top`
* `CFSGCorollary.TypeB.twoGenerated`

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

namespace TypeB

open CFSG.LieType.Universal.Spin

variable {m : ℕ} {K G : Type*} [Field K] [Finite K] [Group G]

/-- `G = ⟨h_μ(k), x r 1 · x s 1 · ω(L)⟩` for a generator `k` of `Kˣ`, `|K| ≥ 3`. -/
theorem closure_diagonal_mul_eq_top (hm : 3 ≤ m)
    (x : SteinbergSystem (cartanB m) (isFiniteType_cartanB m) K G)
    (hK : 3 ≤ Nat.card K) (k : Kˣ) (hk : Subgroup.zpowers k = ⊤) :
    Subgroup.closure {cocharacterElement x.rootElement (cocharacter m) k,
      x.rootElement (rootR m) 1 * x.rootElement (rootS m (by omega)) 1 *
        weylWordElement x.rootElement (List.finRange m)} = ⊤ := by
  have hm0 : 0 < m := by omega
  have hr := rootR_mem hm
  have hs := rootS_mem hm
  have hk1 : k ^ (1 : ℤ) ≠ 1 := by simpa using ne_one_of_zpowers_eq_top hK hk
  obtain ⟨hXr, hXs, hgF⟩ := x.rootGroupIn_closure_diagonal_mul_pair (List.finRange m)
    (cocharacter m) k hr hs
    (x.rootElement_commute _ hr _ hs (rootR_add_rootS_ne_zero hm)
      (noPositiveCombination_rootR_rootS hm))
    (n₁ := 1) (n₂ := 1) (n₃ := 1) (n₄ := -1) (cocharacterPairing_rootR hm)
    (cocharacterPairing_rootS hm)
    (by rw [← reflectionWord_reverse_apply]
        exact cocharacterPairing_reflectionWord_reverse_rootR hm)
    (by rw [← reflectionWord_reverse_apply]
        exact cocharacterPairing_reflectionWord_reverse_rootS hm)
    (by rw [← reflectionWord_apply]; exact cocharacterPairing_reflectionWord_rootR hm)
    (.zpow_of_zpowers_eq_top hk (.inl rfl)) (.zpow_of_zpowers_eq_top hk (.inr rfl))
    hk1 hk1 hk1 (by simpa using hk1)
  exact x.eq_top_of_rootGroupIn _ _ hgF {rootR m, rootS m hm0}
    (by rintro ρ (rfl | rfl) <;> assumption) (inWeylWordOrbit_rootR_rootS hm)

/-- Type `B`, `|K| ≥ 3`: `G` is two-generated. -/
theorem twoGenerated (hm : 3 ≤ m)
    (x : SteinbergSystem (cartanB m) (isFiniteType_cartanB m) K G)
    (hK : 3 ≤ Nat.card K) : TwoGenerated G := by
  obtain ⟨k, hk⟩ := isCyclic_iff_exists_zpowers_eq_top.1 (inferInstance : IsCyclic Kˣ)
  exact ⟨_, _, closure_diagonal_mul_eq_top hm x hK k hk⟩

end TypeB

end CFSGCorollary
