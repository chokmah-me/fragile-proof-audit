module

import CFSGCorollary
import all Solution

/-!
# The conditional theorem does not use the proof of the classification

Fails the build if the `CFSGCorollary` library imports, directly or transitively, the modules of
AxiomMath/CFSG that prove the classification, or if the proof of
`CFSGCorollary.exists_closure_pair_eq_top_of_classification` uses a constant from outside that
library's imports. `Comparator/Solution.lean` imports the proof of the classification, so the
second check is what keeps the conditional theorem separable from it.

Private imports of imported modules are not loaded into the environment, so their imports are read
from their `.olean` files.
-/

open Lean in
run_meta do
  let env ← getEnv
  let mut library : NameSet := {}
  let mut modules := #[`CFSGCorollary]
  while !modules.isEmpty do
    let m := modules.back!
    modules := modules.pop
    if library.contains m then continue
    library := library.insert m
    let imports ← match env.getModuleIdx? m with
      | some i => pure env.header.moduleData[i.toNat]!.imports
      | none => do pure (← readModuleData (← findOLean m)).1.imports
    modules := modules ++ imports.map (·.module)
  for m in [`CFSG.Statement, `CFSG.Certified.Classification] do
    if library.contains m then
      throwError "the CFSGCorollary library imports {m}, the proof of the classification"
  let mut seen : NameSet := {}
  let mut constants := #[``CFSGCorollary.exists_closure_pair_eq_top_of_classification]
  while !constants.isEmpty do
    let c := constants.back!
    constants := constants.pop
    if seen.contains c then continue
    seen := seen.insert c
    let some i := env.getModuleIdxFor? c | throwError "{c} is not imported"
    let m := env.header.moduleNames[i.toNat]!
    if m == `Solution then
      let some ci := env.find? c | throwError "unknown constant {c}"
      let some v := ci.value? (allowOpaque := true) | throwError "the value of {c} is not available"
      constants := constants ++ ci.type.getUsedConstants ++ v.getUsedConstants
    else if !library.contains m then
      throwError "the conditional theorem uses {c}, from {m}, outside the CFSGCorollary library"
