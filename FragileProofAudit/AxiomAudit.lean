/-
Copyright (c) 2026 Chokmah LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chokmah LLC
-/

/-!
# AxiomAudit

Reusable axiom / hole audit scaffolding for third-party Lean claims.

The executable scanner lives at `scripts/forge/axiom_audit.py`.
First use: `incoming/Euler-Mascheroni` (commit cacf87dd…); see
`docs/audits/gamma-aejonanonymous.md`.
-/

namespace FragileProofAudit.AxiomAudit

/-- Marker that the AxiomAudit module is present in the campaign library. -/
theorem module_present : True := trivial

/-- Documentation anchor: a “clean” build is not enough.

A Lean file may contain zero `sorry` and still fail to prove the advertised
claim (wrong statement). The γ audit is the specimen: `gamma_irrational`
proves `¬ is_rational_gamma`, not `Irrational` of mathlib’s Euler–Mascheroni
constant. -/
theorem clean_build_is_not_statement_fidelity : True := trivial

end FragileProofAudit.AxiomAudit
