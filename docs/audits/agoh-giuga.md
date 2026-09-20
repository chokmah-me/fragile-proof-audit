# Audit note — Agoh–Giuga oracle (Phase 3(h) first milestone)

**Claim artifact:** genre — “\(n\) prime ⟺ Agoh / Giuga congruence”
(recurring claimed proofs; conjecture open).  
**Campaign objects:** `docs/blueprint/agoh-giuga.md`,
`scripts/gates/giuga_oracle.py`, `results/giuga_oracle_gate_meta.json`.  
**Citations:** OEIS A007850; harvest
`corpus/fragile-formalizable-proofs-report.md` §3.4; CARMA Giuga survey.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Standing oracle: known Giuga composites are Giuga and fail Korselt |
| **Instance** | OEIS A007850 terms 1–7 with pinned factorizations (incl. seventh \(432749205173838\)) |
| **False instance** | **None.** All seven are Giuga ∧ ¬Carmichael under exact integer checks |

**Verdict: PASS (escalate)** — oracle ready for per-claim audits. Does **not**
decide the Agoh–Giuga conjecture.

## What was gated

- Giuga criterion \(p \mid (g/p - 1)\) for every prime \(p \mid g\).
- Korselt / Carmichael \((p-1) \mid (g-1)\) — expect failure on each \(g\).
- Factorization integrity (product, primality of factors, squarefree).
- Seventh term confirmed from OEIS A007850 (not invented).

## Sample witness (\(g=30\))

| \(p\) | \(g/p-1\) | \(p \mid\)? | \((p-1)\mid(g-1)\)? |
|---|---|---|---|
| 2 | 14 | yes | yes |
| 3 | 9 | yes | **no** (\(2 \nmid 29\)) |
| 5 | 5 | yes | **no** (\(4 \nmid 29\)) |

## Lean

Landed after the green gate:

- `FragileProofAudit/AgohGiuga/Criteria.lean` — `GiugaOnFactors`,
  `KorseltOnFactors`, `OracleWitness`
- `FragileProofAudit/AgohGiuga/Oracle.lean` — seven `oracle_*` theorems +
  `oracle_seven` (explicit / `norm_num` / `decide`; no `native_decide`)

Does **not** claim the Agoh–Giuga conjecture.

## Not done, on purpose

- Did not gate the full modern OEIS table (terms 8+); harvest named the
  classical seven-term oracle.
- Did not formalize von Staudt–Clausen / Agoh–Bernoulli bridge yet.
- Did not attack a specific claimed Agoh–Giuga “proof” this milestone —
  the kit infrastructure is the deliverable.
