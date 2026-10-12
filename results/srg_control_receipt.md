# Discrimination control receipt — koval-SRG audit instrument

**Instrument:** `incoming/koval-strongly-regular-graphs/data/out/new_srgs_multiorbit/zenodo/verify_srg.py`
(archive's standalone stdlib-only exact SRG verifier; sha256
`a9b22e84cf7e61f7a7b168ae3971653e1f8b17770af4cfd37a3a186934413a77` —
matches the sha256 prefix the author's own `verify_srg.log` header records).

**Purpose:** per the computational-claim-gate "Audit the auditor" rule, show the
instrument returns the *opposite* verdict on matched inputs of independent
origin where the opposite is correct. Control inputs were constructed by the
auditor (Kneser KG(5,2) for Petersen; explicit edge list for P10) and are NOT
from the archive, so this is not an echo control.

**Command:** `python3 scripts/gates/koval_srg_control.py`
**Run date (UTC):** 2026-10-12 (during this audit run)
**Exit code:** 0

## Full output

```
--- Petersen (expect PASS srg(10,3,0,1)) ---
exit: 0
/home/hatch/workspace/fragile-proof-audit/results/srg_control_petersen.g6:1  n=10  OK srg(10,3,0,1) connected; complement srg(10,6,3,4)
--- Path P10 (expect FAIL) ---
exit: 1
/home/hatch/workspace/fragile-proof-audit/results/srg_control_path10.g6:1  n=10  FAIL not regular: deg(0)=1, deg(1)=2
CONTROL VERDICT: DISCRIMINATES (PASS)
```

## Control inputs (committed beside this receipt)

- `results/srg_control_petersen.g6` — Petersen graph as Kneser KG(5,2):
  10 vertices = 2-subsets of {0..4}, edges = disjoint pairs (15 edges).
- `results/srg_control_path10.g6` — path graph P10: edges (i,i+1), i = 0..8.

## Verdict

The instrument **discriminates**: it derives `srg(10,3,0,1)` from an
independently constructed Petersen graph and rejects a non-regular graph with
a specific, correct failure reason. The five PASS verdicts on the shipped
graphs are therefore not vacuous.
