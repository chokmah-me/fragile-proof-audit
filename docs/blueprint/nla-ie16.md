# Blueprint — Harvest 2026-09-24: nla-ie16, GMRES subset-bound counterexample (Holden)

**Status:** Type-A gate landed (PASS) + discrimination control landed (NO FALSE POSITIVE) — no Lean scaffold
**Sources:** Sidney Holden, "IE-16: A counterexample and the failure of every universal subset constant", 12 September 2026, Flatiron Institute (Center for Computational Biology)
**Local PDF pinned:** `incoming/nla-ie16-holden.pdf` (SHA-256 `a28b181ac1eab457bbae3d609eff91d7800a33c8a69dec669ba9e08679964ff4`, 9 pages), fetched 2026-09-24 via `curl -sL https://raw.githubusercontent.com/ajt60gaibb/OpenProblemsInNLA/0689db001ddc4c54f2652ed4b13b753637fef700/linear-systems-and-elimination/IE-16/solution.pdf`
**Attack type:** A (scalar gate, quantitative bound) + G (logical-gap exposure on formalized subset vs headline)

## Claim

For E ⊂ ℂ \ {0} finite, M_k(E) = min{‖p‖_E : p ∈ ℂ[z], deg p ≤ k, p(0) = 1}, B_k(E) = max_{|S|=k+1} M_k(S), R_k(E) = M_k(E)/B_k(E). IE-16 asks whether R_k(E) ≤ 4/π for every admissible set. Holden's paper:

> "Let ω = e^{2πi/3} and L = {ω^a + 10^{−3}ω^b : 0 ≤ a,b ≤ 2}. At degree k = 4, this nine-point set satisfies M_4(L)/max_{S⊂L,|S|=5} M_4(S) > 13/10 > 4/π."

> "M_4(L_ε) = 3003003000/1001003001001 > 299/100000, (1) B_4(L_ε) < 23/10000. (2) Consequently R_4(L_ε) > 13/10 > 4/π."

> "The actual ratio is approximately 1.33299891979475829424."

A second, stronger theorem (no finite universal constant, via a three-cluster amplification lemma giving ratio > (2/√3)^r − η) is analytic and informal-only: "The verification program certifies the finite witness; it is not a formal proof-assistant verification of the general amplification theorem."

## Load-bearing object

An exact-arithmetic nine-point witness, not a numerical optimization. The paper's certificate (`certificates/all_subset_certificate.json`, program `code/verify.py`) checks, exactly: positivity/normalization of nine weights, all nine residual moduli squared, four complex orthogonality identities, and all 126 five-point subsets with rational square-root enclosures. The gate replays all of this in re-derived form (see below) — the paper's analytic proof does not depend on the enumeration, and neither does the gate.

## Break/GAP point

**Type A (load-bearing, PASS):** the finite witness is exactly as claimed — M_4 = 3003003000/1001003001001 > 299/100000 and B_4 < 23/10000, hence R_4 > 13/10 > 4/π (see gate). The mathematical route — explicit nine-point certificate — is sound.

**Harmless slip (expositional, not a gap):** the paper's displayed identity (13), Σ ν_{a,b} p*(z_{a,b}) z_{a,b}^ℓ = 0, omits a conjugation on p*; as printed it is false at ℓ = 3 (off by ~9×10⁻⁶, verified exactly). The conjugated identity Σ ν conj(p*(z)) z^ℓ = 0 holds exactly for ℓ = 1..4, is what the paper's own ℓ = 3 computation verifies (μ_0 U(1+c*U) + (1−μ_0)(V + c*(V²+W²)) = 0, checked exactly in-gate), and is what the optimality identity (14) actually needs. One-word fix; the computation underneath is correct; the conclusion (optimality of p*, M_4 = m) is unaffected.

**Type G (formalized subset vs headline):** the 15-export Lean proof at the pinned commit covers the finite nine-point witness only; the stronger amplification result (Theorem 1.2) is informal-only, and canonical Comparator + default-kernel replay was still pending at the pinned commit. [Tree-page/sorry-scan details below.]

## Numeric gate

`scripts/gates/nla_ie16.py` — verdict **PASS**

All arithmetic exact (Fractions in the Q(ω) basis {1, ω}); the only irrationalities (√3, π) enter through certified rational enclosures:

1. **Full-set value:** m = 3ε(1+ε+ε²)/D equals the paper's exact fraction 3003003000/1001003001001; m > 299/100000; H + 2Q = 3D; nine points distinct and nonzero.
2. **Nine residual moduli:** |p*(z_{a,b})|² = m² for all nine points, exactly, where p*(z) = 1 − ((1+ε)/D)z³.
3. **Optimality certificate:** weights μ_0 = H/(3D), μ_1 = μ_2 = Q/(3D) positive summing to 1; ν_{a,b} = μ_{(b−a) mod 3}/3 positive summing to 1; Σ ν conj(p*(z)) z^ℓ = 0 exactly for ℓ = 1..4 (conjugated form — see slip note above); the paper's ℓ = 3 cancellation verified exactly.
4. **Subset bound:** for each of the 126 five-point subsets, Lemma 2.1's Lagrange sum Σ_j Π_{h≠j} |z_h|/|z_j−z_h| (= 1/M_4(S)) is lower-bounded rigorously — each term is √(A_j/B_j) for positive integers A_j, B_j, floored by isqrt(A_j·B_j)/B_j. All 126 sums exceed 10000/23, so every M_4(S) < 23/10000. Corroboration: cluster-occupancy profile counts are 81/27/18, matching the paper.
5. **Ratio chain:** (299/100000)/(23/10000) = 299/230 = 13/10 exactly; 13/10 > 4/π via certified π > 3.1415 (Machin identity, alternating-series remainder bounds).

Meta: `results/nla_ie16_gate_meta.json`; registered in `scripts/gates/check.py` (`EXPECTED_VERDICT["nla_ie16"] = "PASS"`).

## Type-G scan

`results/nla_ie16_typeg_meta.json` — not a gate, a scan receipt:

- pinned paper: "The verification program certifies the finite witness; it is not a formal proof-assistant verification of the general amplification theorem."
- tree page (`IE-16/lean/README.md` at `697a2a1`): fifteen exports pass bounded Linux development compilation + LeanCert kernel-trust assertions (run 34773404263, at revision 281fc37); "Canonical Comparator, separate default-kernel replay and final compiled-source acceptance remain pending"; "This candidate does not change the canonical problem's verified status"; amplification theorem "outside scope"; toolchain pinned `leanprover/lean4:v4.33.1`.
- `sorry` scan over the 11 Lean files (1,734 lines) at the pinned commit: `sorry` only in `Challenge.lean` (15×, by design as the Comparator boundary); 0 in `Solution.lean` and all 9 proof modules; no `axiom`/`admit`/`native_decide` tokens.
- catalog `RESOLVED.md` (at `0689db0`): "**Lean verified — 2026-09-13**" with "Actual Ubuntu Comparator, permitted-axiom and default-kernel verification passed" (run 34774629327) — while the tree page at the exact linked commit says canonical Comparator + default-kernel replay "remain pending". Different run IDs are cited on each side, so staleness is possible; the Actions run was not click-verified.

Finding: **GAP** — the catalog's verification credit exceeds what the linked tree page supports at the linked commit. Scope boundary (amplification informal-only) and AI-only review status are consistent on both sides — no gap there.

## Discrimination control

`scripts/controls/nla_ie16_control.py` — PASS-verdict gate, so the open question is vacuity ("could it miss a real defect?"):

1. **Wrong claimed m:** shifting the claimed m by 10⁻⁹ (points and p* fixed) → the nine-moduli check rejects.
2. **Too-tight bound:** claiming B_4 < 0.0022 on the same Lagrange sums → rejected, while the paper's 23/10000 claim passes on the identical sums (matched: geometry fixed, only the threshold moves).
3. **Perturbed witness:** moving one point by 1/100 → the nine-moduli check rejects.
4. **Non-vacuity:** the unperturbed witness passes the same code path.

Verdict: **NO FALSE POSITIVE**. Receipt: `results/nla_ie16_control_meta.json`.

## Formalizable slice

Not started. The witness is already exact-rational/algebraic, so a Lean formalization of Theorem 1.1 would be `decide`-friendly in principle (126 subset checks plus the weight identities), but the amplification theorem (Theorem 1.2) is an analytic limit argument, not a finite check. Candidate shape, if ever scaffolded:

```lean
theorem ie16_counterexample : R 4 L > 13/10
```

Needs: the nine-point set definition, M_4/B_4/R_4 definitions, and the exact certificate. Not attempted.

## Fill checklist

- [x] Local PDF pin under `incoming/` (`nla-ie16-holden.pdf`, sha256 `a28b181a…`)
- [x] Type-A gate (`scripts/gates/nla_ie16.py`, verdict PASS)
- [x] Registered in `scripts/gates/check.py` with pinned `EXPECTED_VERDICT`
- [x] Discrimination control (`scripts/controls/nla_ie16_control.py`, NO FALSE POSITIVE)
- [x] Type-G scan (`results/nla_ie16_typeg_meta.json`, GAP on verification credit)
- [x] Audit note (`docs/audits/nla-ie16.md`)
- [ ] Lean scaffold — not attempted
