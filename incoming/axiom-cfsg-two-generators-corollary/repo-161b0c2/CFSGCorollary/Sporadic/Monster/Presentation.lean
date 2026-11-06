module

public import TauCeti.GroupTheory.SpecificGroups.CFSG.Sporadic.Presentation
import all TauCeti.GroupTheory.SpecificGroups.CFSG.Sporadic.Presentation

/-!
# The presentation attached to the Monster

TauCeti attaches a presentation to each sporadic name; this file records that the one attached to
`M` is TauCeti's Monster presentation `TauCeti.Sporadic.Monster.presentation`.

## Implementation notes

The definition of `TauCeti.SporadicName.presentation` is not exposed, hence the `import all`. The
proof is `by rfl` rather than `:= rfl`: a term-mode `rfl` proof of an exported theorem may only
unfold exposed definitions.
-/

public section

namespace CFSGCorollary

/-- The presentation attached to the name `M` is TauCeti's Monster presentation. -/
theorem sporadicName_M_presentation_eq :
    TauCeti.SporadicName.M.presentation = TauCeti.Sporadic.Monster.presentation := by
  rfl

end CFSGCorollary
