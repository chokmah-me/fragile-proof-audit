# Audit note — PDN1 congruences (Phase 2(g))

**Claim artifact:** Du–Yao, arXiv:2503.00004.  
**Campaign objects:** `docs/blueprint/pdn1.md`, `scripts/gates/pdn1.py`,
`results/pdn1_gate_meta.json`, `incoming/pdn1-2503.00004.pdf`,
`incoming/pdn1/mod5/`, `incoming/pdn1/mod7/`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Theorems 1.1–1.2 (PDN1 ≡ 0 on stated APs mod \(5^\alpha\), \(7^\alpha\)) via GF \(J_2^2/J_1^5\) and modular eq. (3.13) |
| **Instance** | Exact series through \(q^{500}\); congruence samples α=1,2; (3.13) through degree 80 |
| **False instance** | **None.** GF harness `PDN1(2)=18`; all sampled congruences hold; (3.13) and (3.6) identities hold with max abs diff 0 |

**Verdict: PASS (escalate)** on the Type-D route.

## What was gated

- Generating function coefficients from \(J_2^2/J_1^5\).
- Theorem 1.1 / 1.2 residue formulas for small \(\alpha\) (covers Andrews–Paule
  (1.2)–(1.6) as special cases).
- Lemma 3.2 modular equation (3.13) with in-paper \(\sigma_i\) polynomials.
- Authors’ GitHub Mathematica supplements cloned under `incoming/pdn1/` (no nested `.git`).

## Capability-limited (not a BREAK)

Full notebook / HolonomicFunctions-style replay and seventh-order equation **(4.8)**
need Mathematica (105-page mod-7 PDF + `.nb`). Not available on the campaign
laptop stack. Same stance as 2(f) OreReduce: record blocked, do not invent
operators.

## Lean

None this landing. PASS → escalate.

## Not done, on purpose

Did not claim a full independent proof of all \(\alpha\). Did not parse Appendix B
into a second modular-equation checker this session.
