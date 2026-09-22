"""Numeric gate: Tait's 1884 Hamiltonian conjecture is FALSE (Tutte 1946).

Source claim (Tier 2 historical pinpoint, corpus/fragile-formalizable-proofs-
report.md Section 4.3, harvest rank 7): P. G. Tait conjectured in 1884 that
every 3-connected planar cubic (3-regular) graph is Hamiltonian -- had it
held, the four color theorem would have followed as a corollary. W. T. Tutte
refuted it in 1946 with an explicit 46-vertex, 69-edge counterexample built
from three copies of the "Tutte fragment" glued around a central triangle
(https://en.wikipedia.org/wiki/Tutte_graph, https://en.wikipedia.org/wiki/
Tait%27s_conjecture). This is a genuine campaign build, not a Track C replay
of someone else's verifier: the graph's adjacency is the networkx reference
implementation (networkx.tutte_graph(), itself cited to the Wikipedia Tutte
graph page), and every structural fact plus the non-Hamiltonicity witness is
recomputed here from scratch with an independent backtracking search, not
taken on the library's word.

Gate values. **Hypothesis-check**: the graph must actually be 3-connected,
planar, and 3-regular (cubic) -- otherwise it would not fall under Tait's
conjecture's hypothesis at all, and a "non-Hamiltonian" finding would be
vacuous, not a counterexample. **Confirm** (route survives): a Hamiltonian
cycle exists on this graph. **Break** (route refuted): the graph meets every
hypothesis of Tait's conjecture and exhaustive search over all Hamiltonian
cycles from a fixed start vertex finds none.

Gates refute routes, not theorems: Tait's conjecture as a route is already
known false (this is 80-year-old settled mathematics); the campaign's
contribution is an independently-computed, from-scratch verification of the
witness, not a claim of new mathematics.
"""

from __future__ import annotations

import json
import time
from datetime import datetime, timezone
from pathlib import Path

import networkx as nx

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

# Adjacency: networkx's tutte_graph() reference construction (cites
# https://en.wikipedia.org/wiki/Tutte_graph). Reproduced inline (not imported
# at call time from the library internals) so the exact edge set this gate
# checks is visible and diffable in this file.
TUTTE_ADJ: dict[int, list[int]] = {
    0: [1, 2, 3], 1: [4, 26], 2: [10, 11], 3: [18, 19], 4: [5, 33],
    5: [6, 29], 6: [7, 27], 7: [8, 14], 8: [9, 38], 9: [10, 37],
    10: [39], 11: [12, 39], 12: [13, 35], 13: [14, 15], 14: [34],
    15: [16, 22], 16: [17, 44], 17: [18, 43], 18: [45], 19: [20, 45],
    20: [21, 41], 21: [22, 23], 22: [40], 23: [24, 27], 24: [25, 32],
    25: [26, 31], 26: [33], 27: [28], 28: [29, 32], 29: [30],
    30: [31, 33], 31: [32], 34: [35, 38], 35: [36], 36: [37, 39],
    37: [38], 40: [41, 44], 41: [42], 42: [43, 45], 43: [44],
}


def build_graph() -> nx.Graph:
    return nx.from_dict_of_lists(TUTTE_ADJ)


def cube_graph() -> nx.Graph:
    """3-connected planar cubic and Hamiltonian -- positive sanity graph."""
    return nx.hypercube_graph(3)


def hamiltonian_cycle_exists(g: nx.Graph) -> tuple[bool, list | None, int]:
    """From-scratch exhaustive backtracking search (independent of any
    networkx Hamiltonian-cycle routine -- none is used here). Returns
    (found, cycle_or_None, nodes_visited_in_search) starting from an
    arbitrary fixed vertex; since a Hamiltonian cycle (if any) can be
    rotated/reflected to start anywhere, fixing the start vertex loses no
    generality but does not enumerate all cycles, only decide existence.
    """
    adj = {n: list(g.neighbors(n)) for n in g.nodes()}
    nodes = list(g.nodes())
    n_total = len(nodes)
    start = nodes[0]
    visited = {start}
    path = [start]
    calls = 0

    def rec() -> bool:
        nonlocal calls
        calls += 1
        if len(path) == n_total:
            return start in adj[path[-1]]
        for nb in adj[path[-1]]:
            if nb not in visited:
                visited.add(nb)
                path.append(nb)
                if rec():
                    return True
                visited.remove(nb)
                path.pop()
        return False

    found = rec()
    return found, (list(path) if found else None), calls


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    g = build_graph()

    n_nodes = g.number_of_nodes()
    n_edges = g.number_of_edges()
    degrees = sorted(set(dict(g.degree()).values()))
    is_cubic = degrees == [3]
    connectivity = nx.node_connectivity(g)
    is_3_connected = connectivity >= 3
    is_planar, _cert = nx.check_planarity(g)

    hypothesis_ok = n_nodes == 46 and n_edges == 69 and is_cubic and is_3_connected and is_planar

    t0 = time.perf_counter()
    found, cycle, calls = hamiltonian_cycle_exists(g)
    elapsed = time.perf_counter() - t0

    ok = hypothesis_ok and not found

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "tait_tutte",
        "source_claim": (
            "Tait (1884): every 3-connected planar cubic graph is Hamiltonian"
        ),
        "source_refutation": (
            "Tutte (1946): the 46-vertex, 69-edge Tutte graph is 3-connected, "
            "planar, cubic, and has no Hamiltonian cycle"
        ),
        "corpus_pointer": (
            "corpus/fragile-formalizable-proofs-report.md Section 4.3, "
            "harvest rank 7 -- Tier 2 historical pinpoint job"
        ),
        "adjacency_source": (
            "networkx.tutte_graph() reference construction, cited by "
            "networkx to https://en.wikipedia.org/wiki/Tutte_graph; "
            "reproduced inline in this file as TUTTE_ADJ"
        ),
        "structural_checks": {
            "n_nodes": n_nodes,
            "n_edges": n_edges,
            "expected_n_nodes": 46,
            "expected_n_edges": 69,
            "degree_set": degrees,
            "is_cubic": is_cubic,
            "node_connectivity": connectivity,
            "is_3_connected": is_3_connected,
            "is_planar": is_planar,
            "hypothesis_ok": hypothesis_ok,
        },
        "hamiltonian_search": {
            "method": "from-scratch exhaustive DFS backtracking, fixed start vertex",
            "hamiltonian_cycle_found": found,
            "witness_cycle": cycle,
            "recursive_calls": calls,
            "elapsed_s": round(elapsed, 3),
        },
        "verdict": "BREAK" if ok else "ABORT_HYPOTHESIS" if not hypothesis_ok else "PASS",
        "lemma": "every 3-connected planar cubic graph is Hamiltonian (Tait's conjecture)",
        "false_instance": (
            "the Tutte graph (46 vertices, 69 edges) is 3-connected, planar, "
            "and cubic, yet exhaustive search finds no Hamiltonian cycle"
            if ok
            else "n/a"
        ),
        "ok": ok,
    }
    out = RESULTS / "tait_tutte_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] tait_tutte")
    print(f"  n_nodes={n_nodes} n_edges={n_edges} degrees={degrees} "
          f"connectivity={connectivity} planar={is_planar}")
    print(f"  hypothesis_ok (46v/69e/cubic/3-conn/planar): {hypothesis_ok}")
    print(f"  Hamiltonian cycle found: {found} "
          f"({calls} recursive calls, {elapsed:.2f}s)")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
