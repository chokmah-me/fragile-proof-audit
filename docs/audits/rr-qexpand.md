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

**Verdict: PASS (escalate)** on the Type-D q-expand route. **Type G not attempted.**

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

---

## Gate re-audit (2026-09-20) — audit the auditor

### 1. Is the cone-enumeration bound circular? **In principle yes; empirically slack.**

`Z_series` truncates at `nmax = isqrt(N*|G|) + 2`, justified in its own
docstring by Huang's positivity bound `Q >= ||n||_inf^2 / |G|` — a lemma from
the papers under test. Using a paper's claim to bound the search that validates
that paper is circular reasoning, so it was tested directly: recompute `Z` with
`nmax + 3` and see whether the series moves.

| (a,b) | N | Frobenius | nmax -> nmax+3 | Z moved? | max ‖n‖ among contributing points |
|---|---|---|---|---|---|
| (2,3) | 40 | 1 | 8 -> 11 | no | 6 |
| (3,4) | 30 | 5 | 11 -> 14 | no | 6 |
| (3,5) | 24 | 7 | 11 -> 14 | no | 5 |
| (3,7) | 15 | 11 | 11 -> 14 | no | 4 |
| (3,8) | 12 | 13 | 11 -> 14 | no | 4 |

The largest norm among *contributing* lattice points is 4-6 against a cutoff of
11-14, so the bound is nowhere near binding and the circularity is harmless at
campaign degrees. The `A < 0 or B < 0 or C < 0` leaf prune never fired
(`dropped_neg = 0` in every case). Recorded, not a BREAK.

### 2. Degree budget anti-correlated with difficulty. **Fixed by running deeper.**

The campaign degrees gave the *hardest* case the *shallowest* test — `(3,8)` was
checked to `N=12`, below its own Frobenius number 13, because `CHECKS` is tuned
to keep CI near 15 s. Re-run off the CI path:

| (a,b) | CI degree | re-audit degree | result |
|---|---|---|---|
| (3,5) | 24 | 34 | MATCH |
| (3,7) | 15 | 26 | MATCH |
| (3,8) | 12 | **22** (past Frobenius 13) | MATCH |

`Z = P` survives the deeper check. `(3,8)` at `N=22` costs ~23 s, which is why
it stays off the CI path; run it by hand when the target is revisited.

### 3. Lemma 12 row count is inflated

`LEMMA12_RS = (0,1,2,3,4)` advertises five checks, but `r_1 = 0` reduces both
sides to `1 = 1` and `r_1 = 1` is near-trivial. Roughly three rows carry
content. Cosmetic; recorded so the row count is not over-read.

### Attack types not run

Type **G** (logical-gap), and Type **E** (OreReduce (34)) remains
capability-limited as before. A Type-D pass means the stated identities are
true, which is compatible with a proof that does not close.
