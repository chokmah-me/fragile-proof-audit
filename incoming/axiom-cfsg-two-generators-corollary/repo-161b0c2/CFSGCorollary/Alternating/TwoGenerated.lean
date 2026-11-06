module

public import CFSGCorollary.Alternating.Generators
public import CFSGCorollary.TwoGenerated.Basic
import CFSGCorollary.Alternating.Primitive
import Mathlib.GroupTheory.GroupAction.Jordan

/-!
# Alternating groups are two-generated

For `n ≥ 5`, the permutations `a_n` (a 3-cycle) and `b_n` of
`CFSGCorollary.Alternating.Generators` generate the alternating group `Aₙ`: both are even, and
the group they generate is primitive (`CFSGCorollary.Alternating.Primitive`) and contains a
3-cycle, so by Jordan's theorem it contains `Aₙ`.

## Main results

* `CFSGCorollary.closure_alternatingGenerators_eq_alternatingGroup`: `⟨a_n, b_n⟩ = Aₙ`.
* `CFSGCorollary.twoGenerated_alternating`: `Aₙ` is two-generated for `n ≥ 5`.
-/

@[expose] public section

namespace CFSGCorollary

/-- For `n ≥ 5`, `a_n` and `b_n` generate the alternating group. -/
theorem closure_alternatingGenerators_eq_alternatingGroup (n : ℕ) [NeZero n] (h : 5 ≤ n) :
    Subgroup.closure {alternatingGeneratorA n, alternatingGeneratorB n} =
      alternatingGroup (Fin n) := by
  apply le_antisymm
  · rw [Subgroup.closure_le]
    rintro x (rfl | rfl)
    · exact (alternatingGeneratorA_isThreeCycle n h).2
    · exact alternatingGeneratorB_mem_alternatingGroup n h
  · exact Equiv.Perm.alternatingGroup_le_of_isPreprimitive_of_isThreeCycle_mem
      (isPreprimitive_closure_alternatingGenerators n h) (alternatingGeneratorA_isThreeCycle n h).1
      (Subgroup.subset_closure (by simp))

/-- The alternating group `Aₙ` is two-generated for `n ≥ 5`. -/
theorem twoGenerated_alternating (degree : ℕ) (large : 5 ≤ degree) :
    TwoGenerated (alternatingGroup (Fin degree)) := by
  have : NeZero degree := ⟨by omega⟩
  exact twoGenerated_subgroup_of_closure_pair_eq _ _ _
    (alternatingGeneratorA_isThreeCycle degree large).2
    (alternatingGeneratorB_mem_alternatingGroup degree large)
    (closure_alternatingGenerators_eq_alternatingGroup degree large)

end CFSGCorollary
