module

public import CFSGCorollary.TwoGenerated.Basic
public import TauCeti.GroupTheory.SpecificGroups.CFSG.Assembly.LieType
import CFSGCorollary.LieType.Chevalley.Classical
import CFSGCorollary.LieType.Chevalley.Exceptional
import CFSGCorollary.LieType.Tits
import CFSGCorollary.LieType.Twisted.ReeF4.TwoGenerated
import CFSGCorollary.LieType.Twisted.ReeG2.TwoGenerated
import CFSGCorollary.LieType.Twisted.Suzuki.TwoGenerated
import CFSGCorollary.LieType.Twisted.TrialityD4.TwoGenerated
import CFSGCorollary.LieType.Twisted.TwistedA.TwoGenerated
import CFSGCorollary.LieType.Twisted.TwistedD.TwoGenerated
import CFSGCorollary.LieType.Twisted.TwistedE6.TwoGenerated

/-!
# Finite simple groups of Lie type are two-generated

A case split over TauCeti's index `TauCeti.ValidLieTypeIndex` of the finite simple groups of Lie
type, collecting the results for the untwisted Chevalley groups
(`CFSGCorollary.LieType.Chevalley.Classical`, `CFSGCorollary.LieType.Chevalley.Exceptional`), the
twisted groups (`CFSGCorollary.LieType.Twisted.*.TwoGenerated`) and the Tits group
(`CFSGCorollary.LieType.Tits`). Apart from the Tits group, the generators are those constructed by
Steinberg.

## Main results

* `CFSGCorollary.twoGenerated_lie`: every finite simple group of Lie type is two-generated.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

namespace CFSGCorollary

/-- Every finite simple group of Lie type is two-generated. -/
theorem twoGenerated_lie (index : TauCeti.ValidLieTypeIndex)
    [Finite index.Group] [IsSimpleGroup index.Group] : TwoGenerated index.Group := by
  obtain ⟨d, hv⟩ := index
  cases d with
  | A r q => exact twoGenerated_A r q hv
  | B r q => exact twoGenerated_B r q hv
  | C r q => exact twoGenerated_C r q hv
  | D r q => exact twoGenerated_D r q hv
  | E6 q => exact twoGenerated_E6 q hv
  | E7 q => exact twoGenerated_E7 q hv
  | E8 q => exact twoGenerated_E8 q hv
  | F4 q => exact twoGenerated_F4 q hv
  | G2 q => exact twoGenerated_G2 q hv
  | twistedA r q => exact twoGenerated_twistedA r q hv
  | twistedD r q => exact twoGenerated_twistedD r q hv
  | trialityD4 q => exact twoGenerated_trialityD4 q hv
  | twistedE6 q => exact twoGenerated_twistedE6 q hv
  | suzuki m => exact twoGenerated_suzuki m hv
  | reeG2 m => exact twoGenerated_reeG2 m hv
  | reeF4 m => exact twoGenerated_reeF4 m hv
  | tits => exact twoGenerated_tits hv

end CFSGCorollary
