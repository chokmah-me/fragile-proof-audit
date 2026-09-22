# Audit note — Tait's 1884 Hamiltonian conjecture (Tutte 1946)

**Claim artifact:** P. G. Tait (1884), conjecture; W. T. Tutte (1946),
refutation via an explicit 46-vertex graph.
**Campaign objects:** `docs/blueprint/tait-tutte.md`,
`scripts/gates/tait_tutte.py`, `scripts/controls/tait_tutte_break_control.py`,
`results/tait_tutte_gate_meta.json`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Every 3-connected planar cubic graph is Hamiltonian |
| **Instance** | The Tutte graph: 46 vertices, 69 edges, degree set `{3}`, node-connectivity 3, planar |
| **False instance** | Exhaustive backtracking search (38,698,468 recursive calls, ~22s) finds no Hamiltonian cycle |

**Verdict: BREAK.** Tait's conjecture as a route to the four color theorem
is refuted by this witness; this is settled 1946 mathematics, not new to the
campaign.

## What was gated

This is a Tier 2 "historical broken step, pinpoint job"
(`corpus/fragile-formalizable-proofs-report.md` §4.3, harvest rank 7), not a
live-paper refutation like Track D — the closest campaign precedent is
`lame_h23` (also a from-scratch verification of an already-known historical
break), not Track C (`borsuk63`/`hedetniemi_q`, which replay someone else's
already-published verifier script unmodified). Registered in
`scripts/gates/check.py`'s verdict lock (22nd entry) because the campaign
built its own independent verification rather than replaying an external
tool.

- Structural hypothesis check: node/edge count, cubic degree sequence,
  3-connectivity, planarity — all via `networkx`'s graph algorithms
  (connectivity, planarity testing), applied to an adjacency list
  reproduced inline in the gate file from `networkx.tutte_graph()`'s
  reference construction (itself cited by networkx to the Wikipedia Tutte
  graph page).
- Non-Hamiltonicity: a from-scratch DFS backtracking search, independent of
  any networkx Hamiltonian-cycle routine — the library supplies only the
  graph's edges, never the verdict.

## Discrimination control

`scripts/controls/tait_tutte_break_control.py` reuses the gate's own search
function, unmodified, against three matched cases:

- Cube graph Q3 and the truncated tetrahedron (both 3-connected planar
  cubic and Hamiltonian) — confirms the search finds cycles when they
  exist, not just a search that always says "not found."
- The Petersen graph (cubic, 3-connected, non-Hamiltonian, but **not
  planar**) — confirms the gate's planarity hypothesis check is load-bearing:
  Petersen is excluded from Tait's conjecture's scope for failing
  planarity, not credited as a second counterexample.

Verdict: **NO FALSE POSITIVE** — all three cases match expectation.

## Not done, on purpose

- Did not re-derive the Tutte graph from the fragment construction
  (three "Tutte fragments" glued around a central triangle) — used the
  assembled 46-vertex edge list directly, cross-checked only against its
  own cited source (Wikipedia) and against known structural invariants
  (46v/69e/cubic/3-connected/planar all confirmed independently).
- Did not search for the smaller 38-vertex counterexample
  (Holton–McKay 1988).
- No Lean scaffold attempted — mathlib's planar-graph and
  Hamiltonian-cycle coverage was not surveyed this session; would be the
  natural next step per the corpus report's own "2-4 weeks" estimate for
  this target.
