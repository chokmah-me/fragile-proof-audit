module

public import CFSGCorollary.TwoGenerated.Basic
public import TauCeti.GroupTheory.SpecificGroups.CFSG.Assembly.LieType
import all TauCeti.GroupTheory.SpecificGroups.CFSG.Index
import CFSG.Adapters.LinearCatalog
import CFSG.Assembly.GL83LieDefs
import CFSG.RankThree.PartTwo.Census.Carrier.SpinBOdd
import CFSGCorollary.LieType.Chevalley.Generation.TypeA
import CFSGCorollary.LieType.Chevalley.Generation.TypeB
import CFSGCorollary.LieType.Chevalley.Generation.TypeCCardLarge
import CFSGCorollary.LieType.Chevalley.Generation.TypeCCardThree
import CFSGCorollary.LieType.Chevalley.Generation.TypeCCardTwo
import CFSGCorollary.LieType.Chevalley.Generation.TypeD
import CFSGCorollary.LieType.Chevalley.SpecialLinear
import CFSGCorollary.LieType.Chevalley.Spin
import CFSGCorollary.LieType.Chevalley.Symplectic
import CFSGCorollary.LieType.Steinberg.Quotient

/-!
# Two-generation of the classical groups of Lie type

Assembles the two-generation theorems for the untwisted classical families `A_r(q)`, `B_r(q)`,
`C_r(q)` and `D_r(q)` of TauCeti's classification. In each case the group is identified, through
CFSG's isomorphisms, with the central quotient of a model group carrying Steinberg data (`SL`,
`Sp` or `Spin`); the data descends to a Steinberg system on the simple group, and the
generation results of Steinberg 1962 §3.11 for the corresponding type apply.

## Main results

* `CFSGCorollary.twoGenerated_A`, `CFSGCorollary.twoGenerated_B`, `CFSGCorollary.twoGenerated_C`,
  `CFSGCorollary.twoGenerated_D`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

open TauCeti (LieTypeIndex ValidLieTypeIndex PrimePower)

/-- A finite field whose cardinality is a power of an odd prime has `2 ≠ 0`. -/
private theorem two_ne_zero_of_card_eq {K : Type} [Field K] [Finite K] (p k : ℕ)
    (hp : p.Prime) (hp2 : p ≠ 2) (hcard : Nat.card K = p ^ k) : (2 : K) ≠ 0 := by
  intro h2
  have : Fintype K := Fintype.ofFinite K
  have : CharP K 2 := CharTwo.of_one_ne_zero_of_two_eq_zero one_ne_zero h2
  obtain ⟨n, -, hn⟩ := FiniteField.card K 2
  rw [Nat.card_eq_fintype_card] at hcard
  have h2dvd : 2 ∣ p ^ k := by
    rw [← hcard, hn]
    exact dvd_pow_self 2 n.ne_zero
  exact hp2 (((Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).1
    (Nat.prime_two.dvd_of_dvd_pow h2dvd)).symm)

/-- A finite field with `2 ≠ 0` does not have two elements. -/
private theorem card_ne_two_of_two_ne_zero {K : Type} [Field K] [Finite K] (h2 : (2 : K) ≠ 0) :
    Nat.card K ≠ 2 := by
  intro h
  have : Fintype K := Fintype.ofFinite K
  have := FiniteField.cast_card_eq_zero K
  rw [← Nat.card_eq_fintype_card, h] at this
  exact h2 (by simpa using this)

/-- The simple groups `A_r(q) = PSL_{r+1}(q)` are two-generated. -/
theorem twoGenerated_A (r : ℕ) (q : PrimePower) (hv : (LieTypeIndex.A r q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.A r q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.A r q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.A r q, hv⟩) := by
  rcases center_eq_bot_or_twoGenerated
    (inferInstance : IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.A r q, hv⟩))
    with ⟨_, hcenter⟩ | ⟨_, h⟩
  swap
  · exact h
  have : Fact q.p.Prime := ⟨q.prime_p⟩
  have : NeZero q.exponent := ⟨q.exponent_pos.ne'⟩
  have hrange := (LieTypeIndex.valid_iff _).1 hv
  have hr : 1 ≤ r := ((LieTypeIndex.inStandardRange_iff _).1 hrange.1).1
  let K := GaloisField q.p q.exponent
  let e := CFSG.ClassicalModels.linearCatalogCandidateEquivPSL r q hv
  let φ : Matrix.SpecialLinearGroup (Fin (r + 1)) K →*
      ValidLieTypeIndex.Group ⟨LieTypeIndex.A r q, hv⟩ :=
    e.symm.toMonoidHom.comp (QuotientGroup.mk' _)
  have hφ : Function.Surjective φ := e.symm.surjective.comp (QuotientGroup.mk'_surjective _)
  rcases Nat.lt_or_ge 1 r with h2 | h2
  · obtain ⟨data, -, hdata⟩ := SL.exists_steinbergData r h2 K
    exact TypeA.twoGenerated hr (data.mapSystem φ hφ hcenter)
      (data.hasUnitCommutatorConstants_mapSystem φ hφ hcenter hdata)
  · obtain rfl : r = 1 := by omega
    obtain ⟨data, -, hdata⟩ := SL2.exists_steinbergData K
    exact TypeA.twoGenerated hr (data.mapSystem φ hφ hcenter)
      (data.hasUnitCommutatorConstants_mapSystem φ hφ hcenter hdata)

section

open CFSG.Open CFSG.LieType.Universal CFSG.LieType.Universal.Spin

/-- The simple groups `B_r(q)` are two-generated. In odd characteristic and rank `≥ 3` they are
quotients of odd spin groups; otherwise (`B₂(q) ≅ C₂(q)`, or `q` even) of symplectic groups. -/
theorem twoGenerated_B (r : ℕ) (q : PrimePower) (hv : (LieTypeIndex.B r q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩) := by
  rcases center_eq_bot_or_twoGenerated
    (inferInstance : IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩))
    with ⟨_, hcenter⟩ | ⟨_, h⟩
  swap
  · exact h
  have hvalid := (LieTypeIndex.valid_iff _).1 hv
  have hrange := (LieTypeIndex.inStandardRange_iff _).1 hvalid.1
  have hr : 2 ≤ r := hrange.1
  have : Finite ↥(ValidLieTypeIndex.fixedField ⟨LieTypeIndex.B r q, hv⟩) :=
    CFSG.QuasithinUnique.SQTK.finite_validIndex_fixedField _
  set K := ↥(ValidLieTypeIndex.fixedField ⟨LieTypeIndex.B r q, hv⟩) with hK
  have hcard : Nat.card K = q.p ^ q.exponent :=
    ValidLieTypeIndex.card_fixedField ⟨LieTypeIndex.B r q, hv⟩
  have hcard1 : 1 < Nat.card K := Finite.one_lt_card
  by_cases hodd : q.p ≠ 2 ∧ 3 ≤ r
  · -- odd characteristic: the spin route
    obtain ⟨hp2, hr3⟩ := hodd
    have h2 : (2 : K) ≠ 0 := two_ne_zero_of_card_eq q.p q.exponent q.prime_p hp2 hcard
    let ψ : spinGroup (quadOdd r K) ⧸ Subgroup.center (spinGroup (quadOdd r K)) ≃*
        ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩ :=
      (spinQuotientCenterEquivQuadOdd h2 hr3).trans
        (CFSG.RankThree.PartTwo.Census.Carrier.SpinB.typeBGroupEquivStatedProj_odd r q hv hp2
          hr3).symm
    let φ : spinGroup (quadOdd r K) →* ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩ :=
      ψ.toMonoidHom.comp (QuotientGroup.mk' _)
    have hφ : Function.Surjective φ := ψ.surjective.comp (QuotientGroup.mk'_surjective _)
    obtain ⟨data, -⟩ := SpinOdd.exists_steinbergData r hr3 K h2
    have h3 : 3 ≤ Nat.card K := by
      have := card_ne_two_of_two_ne_zero h2
      omega
    exact TypeB.twoGenerated hr3 (data.mapSystem φ hφ hcenter) h3
  · -- the symplectic route
    have hbridge : Nonempty (ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩ ≃*
        StatedProj (StatedSp r K)) := by
      by_cases hr2 : r = 2
      · subst hr2
        exact ⟨CFSG.QuasithinUnique.SQTK.typeB2GroupEquivStatedProj q hv⟩
      · have hp : q.p = 2 := by omega
        exact ⟨CFSG.RankThree.PartTwo.Census.Carrier.SpinB.typeBGroupEquivStatedProj r q hv hp
          (by omega)⟩
    obtain ⟨e⟩ := hbridge
    let ψ : StatedSp r K ⧸ Subgroup.center (StatedSp r K) ≃*
        ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩ :=
      (Symplectic.centerQuotientEquiv r K).trans e.symm
    let φ : StatedSp r K →* ValidLieTypeIndex.Group ⟨LieTypeIndex.B r q, hv⟩ :=
      ψ.toMonoidHom.comp (QuotientGroup.mk' _)
    have hφ : Function.Surjective φ := ψ.surjective.comp (QuotientGroup.mk'_surjective _)
    by_cases h4 : 4 ≤ Nat.card K
    · obtain ⟨data, -, -⟩ := Sp.exists_steinbergData r hr K
      exact TypeCCardLarge.twoGenerated hr (data.mapSystem φ hφ hcenter) h4
    · have hq : q.card = q.p ^ q.exponent := rfl
      have hr3 : 3 ≤ r := by
        by_contra hlt
        obtain rfl : r = 2 := by omega
        have hne2 : q.card ≠ 2 := fun h ↦ hrange.2 ⟨rfl, h⟩
        have hdup : ¬(2 = 2 ∧ q.card = 3) := hvalid.2
        have h3 : q.card ≠ 3 := fun h ↦ hdup ⟨rfl, h⟩
        omega
      have hK2 : Nat.card K = 2 := by
        by_contra hne
        have hK3 : Nat.card K = 3 := by omega
        have hp3 : q.p = 3 := by
          rw [hK3] at hcard
          have : q.p ∣ 3 := by
            rw [hcard]; exact dvd_pow_self _ q.exponent_pos.ne'
          exact (Nat.prime_dvd_prime_iff_eq q.prime_p Nat.prime_three).1 this
        exact hodd ⟨by omega, hr3⟩
      exact twoGenerated_of_surjective φ hφ (TypeCCardTwo.twoGenerated_statedSp hr3 hK2)

/-- The simple groups `C_r(q) = PSp_{2r}(q)` (`r ≥ 3`, `q` odd) are two-generated. -/
theorem twoGenerated_C (r : ℕ) (q : PrimePower) (hv : (LieTypeIndex.C r q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.C r q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.C r q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.C r q, hv⟩) := by
  rcases center_eq_bot_or_twoGenerated
    (inferInstance : IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.C r q, hv⟩))
    with ⟨_, hcenter⟩ | ⟨_, h⟩
  swap
  · exact h
  have hrange := (LieTypeIndex.inStandardRange_iff _).1 ((LieTypeIndex.valid_iff _).1 hv).1
  have hr : 3 ≤ r := hrange.1
  have hp2 : q.p ≠ 2 := hrange.2
  have : Finite ↥(ValidLieTypeIndex.fixedField ⟨LieTypeIndex.C r q, hv⟩) :=
    CFSG.QuasithinUnique.SQTK.finite_validIndex_fixedField _
  set K := ↥(ValidLieTypeIndex.fixedField ⟨LieTypeIndex.C r q, hv⟩) with hK
  have hcard : Nat.card K = q.p ^ q.exponent :=
    ValidLieTypeIndex.card_fixedField ⟨LieTypeIndex.C r q, hv⟩
  have h2 : (2 : K) ≠ 0 := two_ne_zero_of_card_eq q.p q.exponent q.prime_p hp2 hcard
  let ψ : StatedSp r K ⧸ Subgroup.center (StatedSp r K) ≃*
      ValidLieTypeIndex.Group ⟨LieTypeIndex.C r q, hv⟩ :=
    (Symplectic.centerQuotientEquiv r K).trans
      (CFSG.QuasithinUnique.SQTK.typeCGroupEquivStatedProj r q hv).symm
  let φ : StatedSp r K →* ValidLieTypeIndex.Group ⟨LieTypeIndex.C r q, hv⟩ :=
    ψ.toMonoidHom.comp (QuotientGroup.mk' _)
  have hφ : Function.Surjective φ := ψ.surjective.comp (QuotientGroup.mk'_surjective _)
  obtain ⟨data, -, hdata⟩ := Sp.exists_steinbergData r (by omega) K
  have hx := data.hasUnitCommutatorConstants_mapSystem φ hφ hcenter (hdata h2)
  have hcardK : 4 ≤ Nat.card K ∨ Nat.card K = 3 := by
    have h1 : 1 < Nat.card K := Finite.one_lt_card
    have := card_ne_two_of_two_ne_zero h2
    omega
  rcases hcardK with h | h
  · exact TypeCCardLarge.twoGenerated (by omega) (data.mapSystem φ hφ hcenter) h
  · exact TypeCCardThree.twoGenerated hr (data.mapSystem φ hφ hcenter) hx h

end

/-- The simple groups `D_r(q) = PΩ⁺_{2r}(q)` are two-generated. -/
theorem twoGenerated_D (r : ℕ) (q : PrimePower) (hv : (LieTypeIndex.D r q).Valid)
    [Finite (ValidLieTypeIndex.Group ⟨LieTypeIndex.D r q, hv⟩)]
    [IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.D r q, hv⟩)] :
    TwoGenerated (ValidLieTypeIndex.Group ⟨LieTypeIndex.D r q, hv⟩) := by
  have hr : 4 ≤ r := hv.1
  set K := ValidLieTypeIndex.fixedField ⟨LieTypeIndex.D r q, hv⟩
  have : Finite K := (inferInstance : ∀ d : ValidLieTypeIndex, Finite d.fixedField) ⟨_, hv⟩
  rcases center_eq_bot_or_twoGenerated
    (inferInstance : IsSimpleGroup (ValidLieTypeIndex.Group ⟨LieTypeIndex.D r q, hv⟩)) with
    ⟨_, hcenter⟩ | ⟨_, h⟩
  · obtain ⟨data, -, hdata⟩ := SpinPlus.exists_steinbergData r hr K
    let e := (CFSG.LieType.Universal.Spin.spinQuotientCenterEquivQuadPlus (n := r) (K := K)
      (by omega)).trans
        (CFSG.RankThree.PartTwo.Census.Carrier.SpinD.typeDGroupEquivStatedProj_of_valid r q
          hv).symm
    let φ := e.toMonoidHom.comp
      (QuotientGroup.mk' (Subgroup.center (spinGroup (CFSG.LieType.Universal.Spin.quadPlus r K))))
    have hφ : Function.Surjective φ := e.surjective.comp (QuotientGroup.mk'_surjective _)
    exact TypeD.twoGenerated hr (data.mapSystem φ hφ hcenter)
      (data.hasUnitCommutatorConstants_mapSystem φ hφ hcenter hdata)
  · exact h

end CFSGCorollary
