"""Numeric gate: Kempe's 1879 "proof" of the four color theorem is FALSE
(Fritsch & Fritsch, via Gethner et al. 2009).

Source claim (Tier 2 historical pinpoint, corpus/fragile-formalizable-
proofs-report.md Section 4.2, harvest rank 6): Alfred Kempe's 1879 argument
colors any plane graph with at most 4 colors by induction, using "Kempe
chain switches" to free a color at each vertex. At a degree-5 vertex whose
five neighbors show a color pattern G_a, R, G_b, B, Y (two G-neighbors
separated by R on one side, by B and Y on the other -- "Configuration 2" /
Gadget 5_2), Kempe's method sometimes needs *two* successive chain
switches (a G_aB switch and a G_bY switch) to free a color. Kempe implicitly
assumed the order of these two switches does not matter. Percy Heawood
(1890) and de la Vallee Poussin (1896) identified the flaw in general;
Rudolf and Gerda Fritsch (1998) exhibited a small, explicit 9-vertex
counterexample making the flaw concrete.

This gate replays Theorem 4 of Gethner, Kallichanda, Mentis et al., "How
false is Kempe's proof of the Four Color Theorem? Part II" (Involve 2:3,
2009), <https://msp.org/involve/2009/2-3/involve-v2-n3-p01-p.pdf>. The
paper's Definitions 1-3 (Kempe chain, Kempe chain switch, irrevocable
Kempe chain tangle) are implemented here verbatim as graph algorithms --
a C1C2-Kempe chain containing v is the maximal connected component (in the
graph restricted to vertices colored C1 or C2) containing v; a switch
swaps C1/C2 on that component. The graph (the Fritsch graph: 9 vertices,
21 edges, skeleton of the triaugmented triangular prism), the initial
9-vertex pre-coloring, and the exact two switch sequences for both branches
are transcribed directly from the paper's Figure 3 (extracted from the
pinned PDF page image, not redrawn from memory or a secondary source) --
see docs/blueprint/kempe-fritsch.md for the transcription record.

Gate values. **Branch A** (G_aY switch on the chain containing vertex 2,
then G_bB switch on the chain containing vertex 3): the paper's Figure 3
shows this succeeds -- no neighbor of vertex 1 is left colored G, so vertex
1 can be colored G. **Branch B** (G_bB switch on the chain containing
vertex 4, then G_aY switch on the chain containing vertex 2): the paper's
Figure 3 shows this tangles -- the second switch recolors vertex 8 (one of
vertex 1's original non-G neighbors) back to G, blocking vertex 1
entirely, exactly Definition 3's irrevocable-tangle criterion.

**Confirm** (route survives): both switch orders leave vertex 1 colorable.
**Break** (route refuted): the two orders disagree -- Gadget 5_2 does not
commute, so Kempe's algorithm's outcome depends on an unspecified choice,
which is not a valid proof.
"""

from __future__ import annotations

import json
from collections import deque
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

# The Fritsch graph, 9 vertices / 21 edges, transcribed from Figure 3's
# rendered page image (docs/blueprint/kempe-fritsch.md records the
# transcription: each edge read off the drawn line segments, cross-checked
# against the graph's known degree sequence -- 3 vertices of degree 4, 6 of
# degree 5 -- which this exact edge list reproduces exactly).
EDGES: list[tuple[int, int]] = [
    (9, 6), (9, 2), (9, 3), (9, 8), (9, 7),
    (6, 2), (6, 1), (6, 8),
    (3, 2), (3, 5), (3, 7),
    (2, 1), (2, 5),
    (1, 5), (1, 8), (1, 4),
    (5, 4), (5, 7),
    (4, 8), (4, 7),
    (8, 7),
]

# The initial pre-coloring in Figure 3's top diagram (vertex 1 uncolored --
# it is the degree-5 vertex Gadget 5_2 must resolve).
BASE_COLORING: dict[int, str] = {
    9: "R", 6: "B", 3: "Y", 2: "G", 5: "R", 4: "G", 8: "Y", 7: "B",
}
UNCOLORED_VERTEX = 1


def build_adjacency(edges: list[tuple[int, int]]) -> dict[int, set[int]]:
    adj: dict[int, set[int]] = {}
    for a, b in edges:
        adj.setdefault(a, set()).add(b)
        adj.setdefault(b, set()).add(a)
    return adj


def kempe_component(
    v: int, c1: str, c2: str, adj: dict[int, set[int]], coloring: dict[int, str]
) -> set[int]:
    """Definition 1: the maximal C1C2-connected component containing v."""
    seen = {v}
    q = deque([v])
    while q:
        u = q.popleft()
        for w in adj[u]:
            if w in coloring and coloring[w] in (c1, c2) and w not in seen:
                seen.add(w)
                q.append(w)
    return seen


def kempe_switch(comp: set[int], c1: str, c2: str, coloring: dict[int, str]) -> None:
    """Definition 2: swap C1/C2 on every vertex of the chain, in place."""
    for v in comp:
        coloring[v] = c2 if coloring[v] == c1 else c1


def is_proper(edges: list[tuple[int, int]], coloring: dict[int, str]) -> bool:
    return all(
        not (a in coloring and b in coloring and coloring[a] == coloring[b])
        for a, b in edges
    )


def run_branch(
    adj: dict[int, set[int]],
    edges: list[tuple[int, int]],
    first: tuple[int, str, str],
    second: tuple[int, str, str],
) -> dict:
    coloring = dict(BASE_COLORING)
    comp1 = kempe_component(*first, adj, coloring)
    kempe_switch(comp1, first[1], first[2], coloring)
    proper_after_1 = is_proper(edges, coloring)
    comp2 = kempe_component(*second, adj, coloring)
    kempe_switch(comp2, second[1], second[2], coloring)
    proper_after_2 = is_proper(edges, coloring)
    neighbor_colors = {n: coloring[n] for n in adj[UNCOLORED_VERTEX]}
    g_reintroduced = "G" in neighbor_colors.values()
    return {
        "chain1_component": sorted(comp1),
        "chain2_component": sorted(comp2),
        "proper_after_switch_1": proper_after_1,
        "proper_after_switch_2": proper_after_2,
        "final_coloring": coloring,
        "v1_neighbor_colors": neighbor_colors,
        "g_reintroduced_at_v1_neighbor": g_reintroduced,
        "tangled": g_reintroduced,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    adj = build_adjacency(EDGES)

    n_nodes = len(adj)
    n_edges = len(EDGES)
    degrees = sorted(len(adj[v]) for v in adj)
    structural_ok = (
        n_nodes == 9
        and n_edges == 21
        and degrees.count(4) == 3
        and degrees.count(5) == 6
    )

    base_proper = is_proper(EDGES, BASE_COLORING)
    v1_neighbor_colors_initial = {n: BASE_COLORING[n] for n in adj[UNCOLORED_VERTEX]}
    config2_ok = sorted(v1_neighbor_colors_initial.values()) == sorted(
        ["G", "G", "R", "B", "Y"]
    )

    # Branch A: G_aY switch on the chain containing v2, then G_bB switch on
    # the chain containing v3. Figure 3's "No Tangle" outcome.
    branch_a = run_branch(adj, EDGES, (2, "G", "Y"), (3, "G", "B"))

    # Branch B: G_bB switch on the chain containing v4, then G_aY switch on
    # the chain containing v2. Figure 3's "Tangled" outcome.
    branch_b = run_branch(adj, EDGES, (4, "G", "B"), (2, "G", "Y"))

    matches_paper = (
        branch_a["chain1_component"] == [2, 3]
        and branch_a["chain2_component"] == [3, 4, 7]
        and not branch_a["tangled"]
        and branch_b["chain1_component"] == [4, 7]
        and branch_b["chain2_component"] == [2, 3, 7, 8]
        and branch_b["tangled"]
    )

    ok = (
        structural_ok
        and base_proper
        and config2_ok
        and branch_a["proper_after_switch_1"]
        and branch_a["proper_after_switch_2"]
        and branch_b["proper_after_switch_1"]
        and branch_b["proper_after_switch_2"]
        and matches_paper
    )

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "kempe_fritsch",
        "source_claim": (
            "Kempe (1879): Algorithm Kempe (including Gadget 5_2's two "
            "successive Kempe chain switches) properly 4-colors any plane graph"
        ),
        "source_refutation": (
            "Fritsch & Fritsch (1998) via Gethner, Kallichanda, Mentis et al. "
            "(2009), Theorem 4: Gadget 5_2 does not commute -- the two switch "
            "orders disagree on the 9-vertex Fritsch graph"
        ),
        "corpus_pointer": (
            "corpus/fragile-formalizable-proofs-report.md Section 4.2, "
            "harvest rank 6 -- Tier 2 historical pinpoint job"
        ),
        "local_pdf": "incoming/kempe-fritsch-gethner-involve-2009.pdf",
        "local_pdf_sha256": (
            "5aee2bc4c64f0bb71272f797f2bb5705e59adaff9d77339e6208755cb237cc0c"
        ),
        "transcription_source": "Figure 3, page 258 (PDF page index 10)",
        "structural_checks": {
            "n_nodes": n_nodes,
            "n_edges": n_edges,
            "degree_sequence": degrees,
            "expected_degree_4_count": 3,
            "expected_degree_5_count": 6,
            "structural_ok": structural_ok,
        },
        "initial_coloring": {
            "coloring": BASE_COLORING,
            "proper": base_proper,
            "v1_neighbor_colors": v1_neighbor_colors_initial,
            "matches_configuration_2_pattern": config2_ok,
        },
        "branch_a_no_tangle": branch_a,
        "branch_b_tangled": branch_b,
        "matches_paper_figure_3": matches_paper,
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": (
            "Gadget 5_2 (two successive Kempe chain switches) commutes -- "
            "the switch order does not affect Algorithm Kempe's outcome"
        ),
        "false_instance": (
            "on the Fritsch graph with the pinned pre-coloring, switch order "
            "A (chain(2,G,Y) then chain(3,G,B)) succeeds while switch order B "
            "(chain(4,G,B) then chain(2,G,Y)) reintroduces G at vertex 8, "
            "tangling vertex 1 irrevocably"
            if ok
            else "n/a"
        ),
        "ok": ok,
    }
    out = RESULTS / "kempe_fritsch_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] kempe_fritsch")
    print(f"  structural: n={n_nodes} e={n_edges} degrees={degrees} ok={structural_ok}")
    print(f"  initial coloring proper={base_proper}, "
          f"v1 neighbors={v1_neighbor_colors_initial}, config2={config2_ok}")
    print(f"  Branch A: chain1={branch_a['chain1_component']} "
          f"chain2={branch_a['chain2_component']} tangled={branch_a['tangled']}")
    print(f"  Branch B: chain1={branch_b['chain1_component']} "
          f"chain2={branch_b['chain2_component']} tangled={branch_b['tangled']}")
    print(f"  matches paper Figure 3: {matches_paper}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
