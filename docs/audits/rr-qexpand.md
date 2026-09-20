# Audit note — RR / HJO q-expansion (Phase 2(f))

**Claim artifacts:**
- Lau–Ono, arXiv:2608.05480 (full \(a=3\) layer of HJO).
- Huang–Lau–Ono–Paule, arXiv:2608.15219 (cases \((3,4),(3,5),(3,7),(3,8)\)).  
**Campaign objects:** `docs/blueprint/rr-qexpand.md`,
`scripts/gates/rr_qexpand.py`, `results/rr_qexpand_gate_meta.json`,
`incoming/rr-2608.05480.pdf`, `incoming/rr-2608.15219.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | HJO: \(Z_{a,b}(q)=P_{a,b}(q)\) (charge product), specialized to \(a=3\) and harness \(a=2\) |
| **Instance** | Truncated series for \((a,b)\in\{(2,3),(3,4),(3,5),(3,7),(3,8)\}\) at campaign degrees; plus 15219 Lemma 12 for \(r_1=0..4\) |
| **False instance** | **None.** All coefficient vectors matched; Lemma 12 sides matched |

**Verdict: PASS (escalate)** on the Type-D q-expand route.

## What was gated

- Exact integer power-series comparison of \(Z_{a,b}\) (cone enumeration + q-Pochhammer ratios) against \(P_{a,b}\) (charge product).
- Classical Rogers–Ramanujan harness \((2,3)\).
- Elementary sum-to-sum sample: 15219 Lemma 12 (\(b=4\)).
- Harvest correction: 2608.05480 eq. **(5)** is the published HJO geometric identity, not an unpublished q-series.

## Capability-limited (not a BREAK)

**OreReduce identity (34)** in 2608.15219 (b=8 annihilator step) needs RISC
`HolonomicFunctions` over a q-shift Ore algebra. The campaign stack has no
Mathematica/RISC (and no Sage/Magma). Status recorded as
`capability-limited` in the meta JSON. Authors argue (34) is independently
checkable from printed cofactors; we did not invent those operators.

## Lean

None this landing. PASS → escalate. Optional later: pin AxiomMath/RR_a3
certificate (paper Remark 1.3) as a third-party forge read — out of scope for
the numeric gate.

## Not done, on purpose

Did not fake an OreReduce replay. Did not claim the geometric point-count
identification \(P^{\mathrm{pt}}=Z\) beyond quoting (5). Did not widen to
large \(b\) where cone enumeration is expensive.
