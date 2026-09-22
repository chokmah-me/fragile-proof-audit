"""Discrimination control for kempe_fritsch (instrument, not a gate -- never
registered in scripts/gates/check.py).

The gate's verdict rests on a from-scratch implementation of Kempe chains
and chain switches (Definitions 1-2) finding that two switch orders
disagree on the Fritsch graph. Two things could make that finding spurious
rather than a real replay of Theorem 4:

1. **Implementation bug in the switch machinery itself** -- if
   kempe_component/kempe_switch did not actually implement a Kempe chain
   switch correctly, the resulting "coloring" might not be a proper
   coloring at all, and any apparent tangle would be an artifact, not a
   mathematical fact. Checked directly: after every switch in both
   branches, the coloring must remain proper on all *colored* vertices
   (this is mathematically guaranteed for a genuine Kempe switch -- the
   gate already asserts it, this control re-derives it independently by
   brute-force edge scan rather than trusting the gate's own is_proper()).

2. **The order-dependence might be a generic property of the switch
   machinery** (always reports a tangle, or reports one whenever any two
   switches touch overlapping vertices) rather than a genuine structural
   fact about *this* graph's extra long-range edges (3-7, 4-7, 7-8) that
   let the two chains interfere. Matched near-miss: a plain 5-wheel graph
   (hub + 5-cycle rim, no extra chords) with the SAME Configuration-2 color
   pattern around the hub. In a bare wheel, the G_a and G_b Kempe chains
   are each a single isolated vertex (no chord connects them to anything
   else colored G, B, or Y), so the same machinery, unmodified, must find
   the two switch orders agree (no tangle either way) -- confirming the
   Fritsch graph's tangle comes from its extra edges, not from the search
   itself being order-sensitive by construction.

NO FALSE POSITIVE means: switches stay proper in both real branches, and
the wheel control's two orders agree (both non-tangled).
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
sys.path.insert(0, str(ROOT / "scripts" / "gates"))

from kempe_fritsch import (  # noqa: E402
    BASE_COLORING,
    EDGES,
    build_adjacency,
    kempe_component,
    kempe_switch,
)


def brute_force_proper(edges: list[tuple[int, int]], coloring: dict[int, str]) -> bool:
    """Independent re-check of properness: literal edge-by-edge scan, not
    calling the gate's own is_proper()."""
    for a, b in edges:
        if a in coloring and b in coloring and coloring[a] == coloring[b]:
            return False
    return True


def check_real_branches_stay_proper() -> dict:
    adj = build_adjacency(EDGES)
    results = {}
    for name, first, second in [
        ("branch_a", (2, "G", "Y"), (3, "G", "B")),
        ("branch_b", (4, "G", "B"), (2, "G", "Y")),
    ]:
        coloring = dict(BASE_COLORING)
        comp1 = kempe_component(*first, adj, coloring)
        kempe_switch(comp1, first[1], first[2], coloring)
        ok1 = brute_force_proper(EDGES, coloring)
        comp2 = kempe_component(*second, adj, coloring)
        kempe_switch(comp2, second[1], second[2], coloring)
        ok2 = brute_force_proper(EDGES, coloring)
        results[name] = {"proper_after_switch_1": ok1, "proper_after_switch_2": ok2}
    return results


def wheel_control() -> dict:
    """Hub (uncolored) + 5-cycle rim, Configuration-2 color pattern, no
    chords. Rim vertices 2..6 in cyclic order; hub is vertex 1."""
    edges = [(1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (2, 3), (3, 4), (4, 5), (5, 6), (6, 2)]
    adj = build_adjacency(edges)
    base = {2: "G", 3: "R", 4: "G", 5: "Y", 6: "B"}  # Ga R Gb Y B around the hub

    def run(first, second):
        coloring = dict(base)
        c1 = kempe_component(*first, adj, coloring)
        kempe_switch(c1, first[1], first[2], coloring)
        c2 = kempe_component(*second, adj, coloring)
        kempe_switch(c2, second[1], second[2], coloring)
        neighbor_colors = {n: coloring[n] for n in adj[1]}
        return {
            "chain1": sorted(c1),
            "chain2": sorted(c2),
            "final": coloring,
            "tangled": "G" in neighbor_colors.values(),
        }

    order_1 = run((2, "G", "Y"), (4, "G", "B"))
    order_2 = run((4, "G", "B"), (2, "G", "Y"))
    both_isolated = order_1["chain1"] == [2] and order_2["chain1"] == [4]
    orders_agree = order_1["tangled"] == order_2["tangled"] == False
    return {
        "order_1": order_1,
        "order_2": order_2,
        "chains_isolated_single_vertex": both_isolated,
        "orders_agree_no_tangle": orders_agree,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    properness = check_real_branches_stay_proper()
    properness_ok = all(
        r["proper_after_switch_1"] and r["proper_after_switch_2"]
        for r in properness.values()
    )

    wheel = wheel_control()
    wheel_ok = wheel["chains_isolated_single_vertex"] and wheel["orders_agree_no_tangle"]

    all_ok = properness_ok and wheel_ok
    verdict = "NO FALSE POSITIVE" if all_ok else "CONTROL FAILED"

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "control": "kempe_fritsch_break_control",
        "gate": "kempe_fritsch",
        "properness_recheck": properness,
        "properness_ok": properness_ok,
        "wheel_near_miss": wheel,
        "wheel_ok": wheel_ok,
        "verdict": verdict,
        "ok": all_ok,
    }
    out = RESULTS / "kempe_fritsch_break_control_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"[{'PASS' if all_ok else 'FAIL'}] kempe_fritsch_break_control")
    print(f"  properness re-check (both branches, both switches): {properness_ok}")
    print(f"  wheel near-miss: chains isolated single vertices = "
          f"{wheel['chains_isolated_single_vertex']}, orders agree (no tangle) = "
          f"{wheel['orders_agree_no_tangle']}")
    print(f"  verdict: {verdict}")
    print(f"Wrote {out}")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
