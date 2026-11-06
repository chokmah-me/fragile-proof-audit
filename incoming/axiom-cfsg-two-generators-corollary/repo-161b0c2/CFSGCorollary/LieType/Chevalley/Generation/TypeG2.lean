module

public import CFSGCorollary.LieType.Chevalley.Roots.TypeG2
import CFSGCorollary.LieType.Steinberg.ClosurePair
import CFSGCorollary.LieType.Steinberg.GeneratingScalar
public import CFSGCorollary.LieType.Steinberg.Diagonal

/-!
# Two-generation of Chevalley groups of type `G₂`

Steinberg's theorem for type `G₂`: if `G` has a Steinberg system of type `G₂` over a finite field
`K` with `|K| ≥ 3` and `k` generates `Kˣ`, then `G = ⟨h_μ(k), x_r(1) x_s(1) ω(L)⟩`, with `r`, `s`,
`μ` and `L` as in `Roots.TypeG2`. The commuting root groups `X_r`, `X_s` and `ω(L)` are recovered
from the two generators using the diagonal element `h_μ(k)`, and every root group `X_{±αᵢ}` is
then obtained by conjugating `X_r` or `X_s` by a power of `ω(L)`.

This file also contains a few general lemmas about Weyl words and generators of `Kˣ` that are
reused for other types.

## Main results

* `TypeG2.closure_diagonal_mul_eq_top`: `G = ⟨h_μ(k), x_r(1) x_s(1) ω(L)⟩`.

## References

* [R. Steinberg, *Generators for simple groups*, Canad. J. Math. 14 (1962) 277–283][Steinberg1962]
-/

@[expose] public section

open CFSG.LieType.RootSystem

namespace CFSGCorollary.TypeG2

private theorem word_apply (ρ : Fin 2 → ℤ) :
    coxeterElement ρ = weylWordRoot cartan coxeterList ρ := by
  simp [coxeterElement, reflectionWord, coxeterList, weylWordRoot]

private theorem wordInv_apply (ρ : Fin 2 → ℤ) :
    coxeterElementInv ρ = weylWordRootInv cartan coxeterList ρ := by
  simp [coxeterElementInv, reflectionWord, coxeterList, weylWordRootInv]

private theorem word_pow_apply (k : ℕ) (ρ : Fin 2 → ℤ) :
    (coxeterElement ^ k) ρ = (weylWordRoot cartan coxeterList)^[k] ρ := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', ← ih, pow_succ', Module.End.mul_apply, word_apply]

/-- [Steinberg1962] 3.12 for `G₂`, `|K| ≥ 3`: `G = ⟨h_μ(k), x_r(1) x_s(1) ω(L)⟩` for a generator
`k` of `Kˣ`. -/
theorem closure_diagonal_mul_eq_top {K G : Type*} [Field K] [Finite K] [Group G]
    (system : SteinbergSystem cartan isFiniteType K G) (hK : 3 ≤ Nat.card K)
    {k : Kˣ} (hk : Subgroup.zpowers k = ⊤) :
    Subgroup.closure
      {cocharacterElement system.rootElement cocharacter k,
        system.rootElement rootR 1 * system.rootElement rootS 1 *
          weylWordElement system.rootElement coxeterList} = ⊤ := by
  have hr := rootR_mem
  have hs := rootS_mem
  have hk1 : k ^ (1 : ℤ) ≠ 1 := by simpa using ne_one_of_zpowers_eq_top hK hk
  obtain ⟨h1, h2, h3⟩ := system.rootGroupIn_closure_diagonal_mul_pair coxeterList cocharacter k
    hr hs (system.rootElement_commute rootR hr rootS hs rootR_add_rootS_ne_zero
      noPositiveCombination_rootR_rootS)
    (n₁ := 1) (n₂ := -1) (n₃ := -1) (n₄ := 1) cocharacterPairing_rootR cocharacterPairing_rootS
    (by rw [← wordInv_apply]; exact cocharacterPairing_coxeterElementInv_rootR)
    (by rw [← wordInv_apply]; exact cocharacterPairing_coxeterElementInv_rootS)
    (by rw [← word_apply]; exact cocharacterPairing_coxeterElement_rootR)
    (.zpow_of_zpowers_eq_top hk (.inl rfl)) (.zpow_of_zpowers_eq_top hk (.inl rfl))
    hk1 (by simpa using hk1) (by simpa using hk1) hk1
  refine system.eq_top_of_weylWord_orbit _ coxeterList h3 {rootR, rootS} ?_ ?_ ?_ ?_
  · rintro ρ (rfl | rfl) <;> assumption
  · rintro ρ (rfl | rfl)
    · exact h1.2
    · exact h2.2
  · intro i
    obtain ⟨n, hn⟩ := exists_coxeterElement_pow_eq i 1 (Or.inl rfl)
    rw [one_smul] at hn
    rcases hn with hn | hn
    · exact ⟨rootR, by simp, n, Or.inl (by rw [← word_pow_apply]; exact hn)⟩
    · exact ⟨rootS, by simp, n, Or.inl (by rw [← word_pow_apply]; exact hn)⟩
  · intro i
    obtain ⟨n, hn⟩ := exists_coxeterElement_pow_eq i (-1) (Or.inr rfl)
    rw [neg_one_smul] at hn
    rcases hn with hn | hn
    · exact ⟨rootR, by simp, n, Or.inl (by rw [← word_pow_apply]; exact hn)⟩
    · exact ⟨rootS, by simp, n, Or.inl (by rw [← word_pow_apply]; exact hn)⟩

end CFSGCorollary.TypeG2
