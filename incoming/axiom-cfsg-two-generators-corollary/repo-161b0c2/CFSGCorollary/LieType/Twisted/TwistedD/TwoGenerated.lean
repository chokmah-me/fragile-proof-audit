module

public import CFSGCorollary.TwoGenerated.Basic
public import CFSGCorollary.LieType.Twisted.TwistedD.Basic
import CFSG.Assembly.GL83LieDefs
import CFSG.RankThree.PartTwo.Census.Carrier.SpinTDOdd
import CFSGCorollary.LieType.LambdaRootGroup.ClosurePair
import CFSGCorollary.LieType.Twisted.TwistedD.RootGroup
import CFSGCorollary.LieType.Twisted.TwistedD.Weyl

/-!
# The groups `²D_r(q)` are two-generated

For `r ≥ 4`, a finite field `K` and a generator `α` of `Lˣ` (`L = ShortField b c`), the pair
`(d, u g)` generates `Spin⁻_{2r}(K)`. The short simple root group `X_{ℓ,true}` is a λ-root group
on which `d` and `d₁ = g d g⁻¹` act by the good scalars `α²` and `(star α)²`, so the closure of
the pair contains `X_{ℓ,true}` and `g`; its `g`-conjugates are all the short root groups, which
generate. Passing to the quotient by the centre gives the simple group `²D_r(q)`.

## Main results

* `CFSGCorollary.TwistedD.closure_generatingPair_eq_top`: `(d, u g)` generates `Spin⁻_{2r}(K)`.
* `CFSGCorollary.twoGenerated_twistedD`: the simple group `²D_r(q)` is two-generated.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

open CFSG.LieType.Universal.Spin CFSG.LieType.Universal.Spin.Twisted

namespace CFSGCorollary

namespace TwistedD

/-- The pair `(d, u g)` generates `Spin⁻_{2r}(K)` when `α` generates `Lˣ`. -/
theorem closure_generatingPair_eq_top (r : ℕ) {K : Type} [Field K] [Finite K] {b c : K}
    (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0) [Fact (∀ x : K, x ^ 2 ≠ -c + b * x)] (hr : 4 ≤ r)
    (α : (ShortField b c)ˣ) (hα : Subgroup.zpowers α = ⊤) :
    Subgroup.closure {(generatingPair r hirr hr α).1, (generatingPair r hirr hr α).2} = ⊤ := by
  obtain ⟨rg, hcar, -, ⟨actD⟩, ⟨actD₁⟩, hu, hu1⟩ :=
    exists_lambdaRootGroup_shortRootGroup r hirr hr α
  have hu0 : Multiplicative.toAdd (rg.coordinate ⟨_, hu⟩) ≠ 0 := by
    rw [hu1]
    simp
  obtain ⟨hXF, hgF⟩ := rg.le_closure_pair_mul (torusElement r hirr hr α) (coxeterElement r hirr)
    (α ^ 2) (starUnit α ^ 2) (isGoodScalar_sq_of_zpowers_eq_top α hα)
    (isGoodScalar_starUnit_sq_of_zpowers_eq_top α hα)
    (commute_torusElement_conj_coxeterElement r hirr hr α) actD actD₁ ⟨_, hu⟩ hu0
  set F := Subgroup.closure {(generatingPair r hirr hr α).1, (generatingPair r hirr hr α).2}
  refine eq_top_of_shortRootGroup_le r hirr hr F fun i s ↦ ?_
  obtain ⟨j, hj⟩ := exists_pow_coxeterElement_conj_shortRootGroup r hirr hr i s
  rw [hj]
  rintro _ ⟨x, hx, rfl⟩
  have hxF : x ∈ F := hXF (by rw [hcar]; exact hx)
  have hgj : coxeterElement r hirr ^ j ∈ F := F.pow_mem hgF j
  simp only [MulEquiv.toMonoidHom_eq_coe, MonoidHom.coe_ofClass, MulAut.conj_apply]
  exact F.mul_mem (F.mul_mem hgj hxF) (F.inv_mem hgj)

/-- `Spin⁻_{2r}(K)` is two-generated for `r ≥ 4` and `K` finite. -/
theorem twoGenerated_spinGroup_quadMinus {K : Type} [Field K] [Finite K] {b c : K}
    (hirr : ∀ s : K, s ^ 2 + b * s + c ≠ 0) {r : ℕ} (hr : 4 ≤ r) :
    TwoGenerated (spinGroup (quadMinus r K b c)) := by
  have := fact_shortField hirr
  obtain ⟨α, hα⟩ := IsCyclic.exists_generator (α := (ShortField b c)ˣ)
  exact ⟨_, _, closure_generatingPair_eq_top r hirr hr α ((Subgroup.eq_top_iff' _).2 hα)⟩

end TwistedD

/-- The simple groups `²D_r(q)` are two-generated. -/
theorem twoGenerated_twistedD (r : ℕ) (q : TauCeti.PrimePower)
    (hv : (TauCeti.LieTypeIndex.twistedD r q).Valid)
    [Finite (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.twistedD r q, hv⟩)]
    [IsSimpleGroup (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.twistedD r q, hv⟩)] :
    TwoGenerated (TauCeti.ValidLieTypeIndex.Group ⟨TauCeti.LieTypeIndex.twistedD r q, hv⟩) := by
  have hr : 4 ≤ r := by
    simpa using (TauCeti.LieTypeIndex.inStandardRange_iff _).1
      ((TauCeti.LieTypeIndex.valid_iff _).1 hv).1
  have := CFSG.QuasithinUnique.SQTK.finite_validIndex_fixedField
    ⟨TauCeti.LieTypeIndex.twistedD r q, hv⟩
  obtain ⟨b, c, hirr, ⟨e⟩⟩ :=
    CFSG.RankThree.PartTwo.Census.Carrier.SpinD.exists_typeTwistedDGroupEquivStatedProj_of_valid
      r q hv
  refine twoGenerated_of_mulEquiv e ?_
  refine twoGenerated_of_mulEquiv (spinQuotientCenterEquivQuadMinus hr hirr).symm ?_
  exact twoGenerated_of_surjective _ (QuotientGroup.mk'_surjective _)
    (TwistedD.twoGenerated_spinGroup_quadMinus hirr hr)

end CFSGCorollary
