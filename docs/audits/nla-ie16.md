# Audit note — NLA-IE16 Holden GMRES subset-bound counterexample — Type-A replay: PASS; Type-G verification-credit scan: GAP

**Target:** harvest 2026-09-24, Card 3 (`nla-ie16`), fragility 3.
**Paper:** Sidney Holden, "IE-16: A counterexample and the failure of every universal subset constant", 12 September 2026, Flatiron Institute (Center for Computational Biology).
**Pins:** `incoming/nla-ie16-holden.pdf` (9 pages, SHA-256 `a28b181ac1eab457bbae3d609eff91d7800a33c8a69dec669ba9e08679964ff4`); code tree sgstepaniants/OpenProblemsInNLA at `697a2a1d88337a6747aa5c82fb6e554d3ff1b356`; catalog ajt60gaibb/OpenProblemsInNLA at `0689db001ddc4c54f2652ed4b13b753637fef700`.
**Date:** 2026-09-24. **Scope:** Type-A exact replay of the nine-point witness + Type-G scan of the Lean-verification credit. No Lean build attempted (nothing to build against — see below).

**Verdicts: Type-A PASS. Type-G GAP** (catalog verification credit, not the proof route). The nine-point witness is exactly as claimed: R_4 > 13/10 > 4/π. What fails is RESOLVED.md's "Lean verified" credit for it.

## The claim

IE-16 asks whether R_k(E) = M_k(E)/B_k(E) ≤ 4/π for every admissible set, where M_k is the degree-k residual minimum with p(0) = 1 and B_k the max over (k+1)-point subsets. Holden's Theorem 1.1: the nine-point set L = {ω^a + 10^{−3}ω^b : a,b ∈ {0,1,2}} at degree 4 satisfies M_4(L)/max_{|S|=5} M_4(S) > 13/10 > 4/π, with M_4(L) = 3003003000/1001003001001 and actual ratio ≈ 1.33299891979475829424. Theorem 1.2 (stronger, analytic): no finite dimension-independent constant can replace 4/π.

## Type-A: the witness verifies (PASS)

`scripts/gates/nla_ie16.py` replays the paper's exact-arithmetic certificate (Section 6) in re-derived form — all arithmetic exact (Fractions in the Q(ω) basis {1, ω}); √3 and π enter only through certified rational enclosures:

- m = 3ε(1+ε+ε²)/D equals the paper's exact fraction 3003003000/1001003001001; m > 299/100000; H + 2Q = 3D; nine points distinct and nonzero
- **nine residual moduli:** |p*(z_{a,b})|² = m² at all nine points, exactly, for p*(z) = 1 − ((1+ε)/D)z³
- **optimality certificate:** positive weights μ_0 = H/(3D), μ_1 = μ_2 = Q/(3D) summing to 1, ν_{a,b} = μ_{(b−a) mod 3}/3 summing to 1, and Σ ν conj(p*(z)) z^ℓ = 0 exactly for ℓ = 1..4 — hence M_4(L) = m exactly
- **subset bound:** all 126 five-point subsets replayed through Lemma 2.1's Lagrange identity with rigorous per-term lower bounds (each term √(A/B) floored by isqrt(A·B)/B over positive integers); every Lagrange sum exceeds 10000/23, so every M_4(S) < 23/10000; cluster-occupancy profile counts are 81/27/18, matching the paper
- **ratio chain:** (299/100000)/(23/10000) = 299/230 = 13/10 exactly; 13/10 > 4/π via certified π > 3.1415 (Machin identity, alternating-series remainder bounds)

Discrimination control (`scripts/controls/nla_ie16_control.py`): **NO FALSE POSITIVE** — a 10⁻⁹ shift in the claimed m is rejected, a too-tight B_4 < 0.0022 claim is rejected on the same Lagrange sums that pass the paper's 23/10000, a single moved point is rejected, and the unperturbed witness passes the same path.

## Harmless slip (expositional, not a gap)

The paper's displayed identity (13), Σ ν_{a,b} p*(z_{a,b}) z_{a,b}^ℓ = 0, omits a conjugation on p*. As printed it is false at ℓ = 3 — the residual is a nonzero rational ≈ 9×10⁻⁶, verified exactly. The conjugated identity Σ ν conj(p*(z)) z^ℓ = 0 holds exactly for ℓ = 1..4; it is what the paper's own ℓ = 3 computation verifies (μ_0 U(1+c*U) + (1−μ_0)(V + c*(V²+W²)) = 0, checked exactly in-gate) and what the optimality identity (14) actually needs. One-word fix; the computation underneath is correct; optimality of p* and M_4 = m are unaffected. In the jac-2d-typeg taxonomy this is a genuine-but-harmless slip, not a proof defect.

## Type-G: the "Lean verified" credit does not survive its own sources (GAP)

Two pinned sources, in tension on exactly one point:

1. **Catalog** (`RESOLVED.md` at `0689db0`, IE-16 section): "**Lean verified — 2026-09-13.** ... The immutable fifteen-export proof (.../tree/697a2a1.../IE-16/lean) verifies Holden's exact finite counterexample ... **Actual Ubuntu Comparator, permitted-axiom and default-kernel verification** (actions/runs/34774629327) **passed** with all controls."
2. **Tree page** (`IE-16/lean/README.md` at the *exact commit the catalog links*, `697a2a1`): "All ten project modules and all fifteen public exports pass bounded Linux development compilation and LeanCert kernel-trust assertions at revision `281fc37`..., in run 34773404263. **Canonical Comparator, separate default-kernel replay and final compiled-source acceptance remain pending. This candidate does not change the canonical problem's verified status** or permanent ID."

Honest nuance, unlike the cleaner NR-03 case: the two sides cite different run IDs (34774629327 vs 34773404263, the latter at a different revision, 281fc37), so the discrepancy may be staleness or different harnesses ("Actual Ubuntu Comparator" vs "Canonical Comparator") rather than fabrication; the Actions run was not click-verified here. What is pinned and checkable is that the tree page at the linked commit disavows the canonical-verification reading. The `sorry` scan is consistent with a candidate, not a completed verification: 11 Lean files (1,734 lines); `sorry` only in `Challenge.lean` (15×, by design as the Comparator boundary); 0 in `Solution.lean` and all 9 proof modules; no `axiom`/`admit`/`native_decide`; toolchain pinned `leanprover/lean4:v4.33.1` (the harvest recon's repo-level "not pinned" missed the subdirectory pin).

Consistent on both sides — no gap: the stronger amplification theorem is informal-only per the tree page ("outside scope"), the catalog ("remains an informal source result"), and the paper itself ("not a formal proof-assistant verification of the general amplification theorem"); both describe the reviews as AI-only with addenda pending.

## Distinguishing GAP from BREAK

Per doctrine, gates refute routes, not theorems. No lemma of the paper's proof route was falsified — the Type-A gate PASSES, so this is not BREAK in any case. It is GAP: the catalog's verification-credit claim for IE-16 is genuinely defective as pinned (it asserts a Comparator/default-kernel pass that the linked tree page says is still pending), while the underlying mathematics is untouched. The route that dies is "trust RESOLVED.md's Lean-verified credit for IE-16."

**Theorem untouched.** R_4(L_{1/1000}) > 13/10 > 4/π stands on the verified exact witness. The 26 pre-existing verdict-lock rows are byte-untouched; `nla_ie16` registers as a new 27th gate with verdict PASS.

## Scope and limits

- The GitHub Actions run 34774629327 cited by RESOLVED.md was not independently inspected (no live browser in this audit). A human click-through could determine whether it postdates the tree page text and what harness it ran. This does not affect the finding, which rests on the tree page's own words at the linked commit.
- No Lean build was attempted: with canonical verification described as pending on the tree page itself, a build would test an unclaimed claim, not the catalog's.
- Theorem 1.2 (amplification, no universal finite constant) was not gated: it is an analytic limit argument, explicitly informal-only, and outside the Lean scope by all three sources.
- The audit pins the witness at the tree commit `697a2a1`; later commits on either repo are out of scope.
