module

public import CFSG.LieType.Universal.Unitary.Roots.Levels

/-!
# Indices for the unitary groups

Auxiliary facts about the indices of `Fin n` used for the root groups of `SU σ n`: the middle
index `midIdx` (for `n` odd) and the low indices `lowIdx a`, `a < n / 2`.
-/

@[expose] public section

namespace CFSGCorollary.TwistedA

open CFSG.LieType.Universal.Unitary

/-- The middle index `μ = n / 2` for `n` odd. -/
def midIdx {n : ℕ} (hn : n % 2 = 1) : Fin n := ⟨n / 2, by omega⟩

theorem rev_midIdx {n : ℕ} (hn : n % 2 = 1) : Fin.rev (midIdx hn) = midIdx hn :=
  Fin.ext (by simp [midIdx]; omega)

theorem lowIdx_ne_rev_self {n : ℕ} (a : Fin (n / 2)) : lowIdx a ≠ Fin.rev (lowIdx a) :=
  lowIdx_ne_rev a a

theorem lowIdx_ne_midIdx {n : ℕ} (hn : n % 2 = 1) (a : Fin (n / 2)) : lowIdx a ≠ midIdx hn :=
  Fin.ne_of_val_ne (by
    have := a.isLt
    simp only [midIdx, val_lowIdx]
    omega)

end CFSGCorollary.TwistedA
