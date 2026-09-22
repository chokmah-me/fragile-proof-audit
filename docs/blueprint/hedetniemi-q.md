# Blueprint — Track C: quantum Hedetniemi (Zeiss 2609.20690)

**Status:** pinned incoming artifact; **not** on the verdict lock  
**Genre:** claimed Lean 4 disproof of a false conjecture (certificate + forge)  
**Attack type:** Type F (finite certificates) + forge catalog (γ-pattern)  
**Sources:** arXiv:2609.20690v1; GitHub
`JuliusAZeiss/Lean-Verification-and-More-Quantum-Hedetniemi-conjecture`  
**Pin:** clone `95c0ac05e9b7ea50b827ec491661eed2ed0147b4`; PDF sha256
`1b307f781029ab9d6f263857528a7a770b35a968037b387b838a1770e6cad316`  
**Author toolchain:** Lean `v4.19.0` / mathlib `c44e0c8ee63ca166450922a373c7409c5d26b00b`  
**Campaign pin (do not bump):** Lean / mathlib `v4.32.2`

## Claim (quoted from the abstract)

Godsil–Roberson–Šámal–Severini: the quantum chromatic number of a categorical
product equals the min of the factors. Zeiss constructs explicit finite graphs
\(G,H\) with
\[
\chi(G\times H)\le 1538 < 1539=\min\{\chi_q(G),\chi_q(H)\}.
\]
The same gap holds for \(\chi_{C^*}\) and the spatial / approximate /
commuting-operator variants. Smaller examples are certified by exact integers.

## Load-bearing lemmas (paper numbering)

- **Lemma 8.** Cayley graph \(F\) of \(\mathbb{F}_2^{10}\) on connection set
  \(S\), \(|S|=22\): no closed walk of length 3 or 5; \(M=A+10I\succeq 0\);
  \(\mathrm{sum}(M)/\mathrm{tr}(M)=16/5\).
- **Corollary 9.** \(\chi_{C^*}(G)\ge 1639\) for \(G=F[K_{512}]\).
- **Proposition 13.** \(H_t\) has no \(c\)-coloring in a nonzero unital
  \(C^*\)-algebra, \(c=3t+2\).
- **Product coloring.** \(\chi(G\times H)\le c\).

Lean names (author `THEOREM_MAP.md`): `regular_quantum_counterexample`,
`regular_cstar_counterexample`, `regularG_quantumChromaticNumber_lower` in
`Hedetniemi.Expository`.

## What this campaign checks

1. **Python numerics (stdlib, exact).** From the clone:
   `numerics/check_base_graph.py`, `numerics/check_appendix_certificate.py`,
   `numerics/compare_lean_data.py`, `data/verify_regular.py`, `data/verify.py`.
   These are the finite gates. They do not run Lean.
2. **Source forge.** `python scripts/forge/axiom_audit.py incoming/quantum-hedetniemi`
   plus the author’s `python lean/check.py --check-sources`.
3. **Kernel (optional, their tree).** `cd incoming/quantum-hedetniemi/lean` then
   `lake exe cache get` and `python check.py`. Needs Lean 4.19.0 via elan, several
   GB, internet. Failure is `UNKNOWN`, not a BREAK of the conjecture.

Do **not** register a row in `scripts/gates/check.py`. PASS of the numerics
means the published integers match the paper; it does not mean this campaign
proved Hedetniemi false.

## Non-goals

- Do not re-search Shitov/Zhu chromatic numbers on a laptop.
- Do not import their lake project into FragileProofAudit.
- Do not treat the Gemini MD’s “45 s sparse homomorphism” as a gate.
