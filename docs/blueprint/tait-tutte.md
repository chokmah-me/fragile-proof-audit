# Blueprint — Tait's 1884 Hamiltonian conjecture (Tutte 1946)

**Corpus source:** `corpus/fragile-formalizable-proofs-report.md` Section 4.3,
harvest rank 7. Tier 2 "historical broken step, pinpoint job" — the break is
80-year-old settled mathematics; the campaign's contribution is an
independently computed, from-scratch verification of the witness, following
the same discipline as `lame_h23` (Lamé's class-number pinpoint).

## The claim

P. G. Tait, 1884: every 3-connected planar cubic (3-regular) graph is
Hamiltonian. Had it held, the four color theorem would have followed as a
corollary (a Hamiltonian cycle on a cubic planar graph 4-colors the faces by
alternating two colors on each side of the cycle plus the two remaining
colors on the chords).

## The break

W. T. Tutte, 1946: the 46-vertex, 69-edge "Tutte graph," built from three
copies of the Tutte fragment glued around a central triangle, is 3-connected,
planar, and cubic — meeting every hypothesis of Tait's conjecture — yet has
no Hamiltonian cycle.
(<https://en.wikipedia.org/wiki/Tutte_graph>,
<https://en.wikipedia.org/wiki/Tait%27s_conjecture>)

## Load-bearing quantity

Two things must both hold for the witness to count:

1. **Hypothesis check** — the graph must actually be 3-connected, planar,
   and 3-regular, or a "non-Hamiltonian" finding is vacuous (compare the
   Petersen graph below, which is cubic and 3-connected but *not* planar,
   and is also non-Hamiltonian — that is not a counterexample to Tait's
   conjecture, because it fails the hypothesis).
2. **Non-existence** — no Hamiltonian cycle exists. This is a decidable
   proposition about a finite (46-vertex) graph, resolvable by exhaustive
   backtracking search.

## Gate

`scripts/gates/tait_tutte.py`. Adjacency: `networkx.tutte_graph()`'s
reference construction (networkx cites the same Wikipedia Tutte-graph page
above), reproduced inline in the gate file as `TUTTE_ADJ` so the exact edge
set is visible and diffable, not imported opaquely from the library at call
time. Structural checks (node/edge count, degree sequence, `node_connectivity`,
`check_planarity`) confirm the hypothesis; the non-existence half is
re-derived from scratch by a plain DFS backtracking search
(`hamiltonian_cycle_exists`), not by any networkx Hamiltonian-cycle routine
— networkx supplies only the graph's edges, never the verdict.

**Confirm** (route survives): a Hamiltonian cycle exists.
**Break** (route refuted): hypothesis holds and no cycle is found.

Result: 46 nodes, 69 edges, degree set `{3}`, node-connectivity 3, planar —
hypothesis holds. Exhaustive search (38,698,468 recursive calls, ~22s)
finds no Hamiltonian cycle. **Verdict: BREAK.**

## Discrimination control

`scripts/controls/tait_tutte_break_control.py`. Runs the gate's own
unmodified search function against three known graphs:

- **Cube graph Q3** (8v/12e) — 3-connected, planar, cubic, Hamiltonian.
  Confirms the search finds cycles when they exist (not just a search that
  always returns "not found").
- **Truncated tetrahedron** (12v/18e) — same hypothesis class, also
  Hamiltonian. A second, structurally different positive instance.
- **Petersen graph** (10v/15e) — cubic and 3-connected, but *not planar*,
  and famously non-Hamiltonian. Matched near-miss: confirms the gate's
  `hypothesis_ok` planarity check is load-bearing (it correctly excludes
  Petersen from Tait's conjecture's scope) rather than decorative, and that
  "cubic 3-connected implies non-Hamiltonian" is not what the search is
  secretly testing.

Verdict: **NO FALSE POSITIVE** — all three match expectation.

## Do not claim

- That this campaign discovered the counterexample (Tutte, 1946).
- That the Tutte graph is the smallest such counterexample (Holton–McKay
  1988 found smaller ones, 38 vertices; not checked here).
- That this refutes the four color theorem's *proof* — 4CT is true
  (Appel–Haken 1976, Gonthier's Coq formalization); Tait's would-be
  shortcut via Hamiltonicity is what fails.
- No Lean scaffold attempted — mathlib's planar-graph and Hamiltonian-cycle
  coverage was not surveyed this session.
