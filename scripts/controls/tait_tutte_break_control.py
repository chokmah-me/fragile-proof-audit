"""Discrimination control for tait_tutte (instrument, not a gate -- never
registered in scripts/gates/check.py).

The gate's verdict is a non-existence claim (no Hamiltonian cycle) resolved
by exhaustive search -- exactly the class GATE-BEFORE-PROVE.md flags as
requiring a control, since a search that is aimed wrong or has a latent bug
could silently report "not found" on a graph that does have a cycle.

This control reuses the gate's own from-scratch backtracking search
unmodified (imported, not re-typed) and checks it against graphs where the
correct answer is known and differs from the Tutte graph's:

1. Cube graph Q3 (8v, 12e) -- 3-connected, planar, cubic, and *Hamiltonian*.
   If the search reported "no cycle" here it would prove the search itself
   is broken, not that cube graphs lack Hamiltonian cycles.
2. Truncated tetrahedron (12v, 18e) -- same hypothesis class, also
   Hamiltonian. A second positive instance, different graph family.
3. Petersen graph (10v, 15e) -- 3-connected and cubic but *not planar*, and
   famously non-Hamiltonian. This is the matched near-miss: it fails to be
   a counterexample to Tait's conjecture only because it fails the planarity
   hypothesis, not because "cubic 3-connected graphs are generally
   non-Hamiltonian" -- confirming the gate's hypothesis_ok check (which
   requires planarity) is load-bearing, not decorative.

NO FALSE POSITIVE means: the search correctly finds cycles on 1 and 2, and
the gate's hypothesis_ok filter correctly rejects 3 (Petersen) as out of
scope for Tait's conjecture despite also being non-Hamiltonian.
"""

from __future__ import annotations

import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import networkx as nx

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
sys.path.insert(0, str(ROOT / "scripts" / "gates"))

from tait_tutte import hamiltonian_cycle_exists  # noqa: E402


def hypothesis_ok(g: nx.Graph) -> bool:
    degrees = sorted(set(dict(g.degree()).values()))
    is_cubic = degrees == [3]
    is_3_connected = nx.node_connectivity(g) >= 3
    is_planar, _ = nx.check_planarity(g)
    return is_cubic and is_3_connected and is_planar


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    cases = {}

    for name, g, expect_hypothesis, expect_hamiltonian in [
        ("cube_Q3", nx.hypercube_graph(3), True, True),
        ("truncated_tetrahedron", nx.truncated_tetrahedron_graph(), True, True),
        ("petersen", nx.petersen_graph(), False, False),
    ]:
        t0 = time.perf_counter()
        hyp_ok = hypothesis_ok(g)
        found, cycle, calls = hamiltonian_cycle_exists(g)
        elapsed = time.perf_counter() - t0
        cases[name] = {
            "n_nodes": g.number_of_nodes(),
            "n_edges": g.number_of_edges(),
            "hypothesis_ok": hyp_ok,
            "expect_hypothesis_ok": expect_hypothesis,
            "hamiltonian_found": found,
            "expect_hamiltonian": expect_hamiltonian,
            "matches_expectation": (
                hyp_ok == expect_hypothesis and found == expect_hamiltonian
            ),
            "recursive_calls": calls,
            "elapsed_s": round(elapsed, 3),
        }

    all_match = all(c["matches_expectation"] for c in cases.values())
    verdict = "NO FALSE POSITIVE" if all_match else "CONTROL FAILED"

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "control": "tait_tutte_break_control",
        "gate": "tait_tutte",
        "cases": cases,
        "verdict": verdict,
        "ok": all_match,
    }
    out = RESULTS / "tait_tutte_break_control_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"[{'PASS' if all_match else 'FAIL'}] tait_tutte_break_control")
    for name, c in cases.items():
        print(
            f"  {name}: n={c['n_nodes']} hypothesis_ok={c['hypothesis_ok']} "
            f"(expect {c['expect_hypothesis_ok']}) hamiltonian={c['hamiltonian_found']} "
            f"(expect {c['expect_hamiltonian']}) -> "
            f"{'ok' if c['matches_expectation'] else 'MISMATCH'}"
        )
    print(f"  verdict: {verdict}")
    print(f"Wrote {out}")
    return 0 if all_match else 1


if __name__ == "__main__":
    raise SystemExit(main())
