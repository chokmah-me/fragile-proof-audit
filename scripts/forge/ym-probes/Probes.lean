/-
  Yang-Mills forge: ST statement-test probes (M1 add-on, docs/harvest-loop.md).
  Compiled in-job in the prepared review project against the pinned
  endpoints themselves (never a re-typed copy): each probe is the
  endpoint applied at the concrete SU(2) instance the artifact itself
  ships (YangMills.su2, YangMills.su2Simple in ConcreteSU2.lean).

  What these probes establish (ST-1 / ST-2 evidence):
  - Each endpoint's conclusion is inhabited at a named, non-trivial
    instance (the SU(2) gauge group), by the pinned theorem itself.
  - The three conclusions are jointly inhabited at that one instance
    (probe_joint_inhabitation_su2).

  What they do NOT establish: M1 seam 1 (PIN, yang-mills-openai-
  20261028). No theorem in the artifact identifies the existential
  Wilson-family witness of YMReview.OPE.constructed with the witness
  of YMReview.Acceptance.combined_acceptance (which is extracted
  from YangMills.constructed, a different construction entry point
  than jointExistence). Joint inhabitation at SU(2) shows the three
  conclusions are simultaneously satisfiable; it does not show the
  witnesses coincide, and these probes do not claim it. That seam
  is graded in the audit note, not here.

  Every probe is axiom-audited at the end of the file: a probe proved
  with sorryAx or an added axiom is a failed probe.
-/

import Solution
import ConcreteSU2
import CombinedAcceptance
import OPECheck

namespace YMProbes

/-- ST-1/ST-2 for the submitted endpoint: `YangMills.jointExistence`
at SU(2), the statement shape copied from ChallengeSpec.lean's
`JointExistence` definition. -/
theorem probe_joint_su2 :
    ∃ C : YangMills.WilsonFamily YangMills.su2, YangMills.WilsonRegularity C ∧
      ∀ p : ℕ → ℕ, StrictMono p → ∃ q : ℕ → ℕ, StrictMono q ∧
        ∃ T : YangMills.Hierarchy C, T.Properties (p ∘ q) :=
  YangMills.jointExistence YangMills.su2 YangMills.su2Simple

/-- ST-1/ST-2 for the combined acceptance endpoint (A1-A7) at SU(2),
b = 1. -/
theorem probe_acceptance_su2 :
    YMReview.Acceptance.CombinedAcceptance YangMills.su2 YangMills.su2Simple 1 :=
  YMReview.Acceptance.combined_acceptance YangMills.su2 YangMills.su2Simple 1 one_pos

/-- ST-1/ST-2 for the OPE endpoint (A8) at SU(2), the statement shape
copied from OPECheck.lean's `constructed`. -/
theorem probe_ope_su2 :
    ∃ C : YangMills.WilsonFamily YangMills.su2, YangMills.WilsonRegularity C ∧
      ∀ p : ℕ → ℕ, StrictMono p → ∃ q : ℕ → ℕ, StrictMono q ∧
        ∃ T : YangMills.Hierarchy C, T.Properties (p ∘ q) ∧
          YMReview.OPE.CommonOPE T :=
  YMReview.OPE.constructed YangMills.su2 YangMills.su2Simple

/-- Joint inhabitation: the three endpoints' conclusions hold
simultaneously at the SU(2) instance. This is satisfiability
evidence for the conjunction, NOT witness identity (M1 seam 1). -/
theorem probe_joint_inhabitation_su2 :
    (∃ C : YangMills.WilsonFamily YangMills.su2, YangMills.WilsonRegularity C ∧
      ∀ p : ℕ → ℕ, StrictMono p → ∃ q : ℕ → ℕ, StrictMono q ∧
        ∃ T : YangMills.Hierarchy C, T.Properties (p ∘ q)) ∧
    YMReview.Acceptance.CombinedAcceptance YangMills.su2 YangMills.su2Simple 1 ∧
    (∃ C : YangMills.WilsonFamily YangMills.su2, YangMills.WilsonRegularity C ∧
      ∀ p : ℕ → ℕ, StrictMono p → ∃ q : ℕ → ℕ, StrictMono q ∧
        ∃ T : YangMills.Hierarchy C, T.Properties (p ∘ q) ∧
          YMReview.OPE.CommonOPE T) :=
  ⟨probe_joint_su2, probe_acceptance_su2, probe_ope_su2⟩

end YMProbes

-- Axiom audit of every probe (expected: exactly the standard three).
#print axioms YMProbes.probe_joint_su2
#print axioms YMProbes.probe_acceptance_su2
#print axioms YMProbes.probe_ope_su2
#print axioms YMProbes.probe_joint_inhabitation_su2
