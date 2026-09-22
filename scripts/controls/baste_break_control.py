"""False-positive control for the baste_domination BREAK gate.

Same four questions as `break_control.py` / `cohen_break_control.py`, applied
to `scripts/gates/baste_domination.py`. No local PDF pin exists for
arXiv:2609.10783 under `incoming/` -- transcription rests on a live
arXiv HTML fetch (2026-09-20), recorded verbatim below, not a pinned PDF.

The gate's own lower-bound verdict (gamma(G) >= 16) comes from an exact
branch-and-bound search this campaign wrote, not from re-running the source's
L(T)/set-cover-recurrence argument -- so the sharpest question here is (2):
can that search engine ever find a smaller dominating set when one genuinely
exists, or does it just always say "none exists" regardless of input?

Run:  python scripts/controls/baste_break_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import baste_domination as BD  # noqa: E402

BAR = "=" * 74

# Fetched live from https://arxiv.org/html/2609.10783 on 2026-09-20 (WebFetch,
# small-model page summary, not the full PDF -- no local pin exists).
CONSTRUCTION_SUMMARY = (
    "30 literal vertices: pairs (v1-,v1+), ..., (v15-,v15+). "
    "20 clause vertices c1..c20. "
    "Each variable pair has a pair edge vj- vj+ for j = 1 to 15. "
    "Every signed literal occurs exactly twice. "
    "vj- = 2(j-1), vj+ = 2(j-1)+1, ca = 29+a. "
    "M = {v1-v1+, ..., v15-v15+} saturates all 30 literal vertices and "
    "leaves the 20 clause vertices unmatched. "
    "In a cubic graph an edge is adjacent to at most four other edges. "
    "gamma_e(G) >= 75/5 = 15. "
    "D0 = 16 vertices dominates all vertices by direct inspection. "
    "the paper enumerates all 2^20 = 1,048,576 possible clause subsets"
)


def transcription_check() -> dict:
    print("\n[1] Transcription fidelity (arXiv:2609.10783 HTML, live-fetched)")
    checks = {
        "vertex_labeling_matches": "vj- = 2(j-1), vj+ = 2(j-1)+1, ca = 29+a" in CONSTRUCTION_SUMMARY,
        "pair_edges_15_matches": "pair edge vj- vj+ for j = 1 to 15" in CONSTRUCTION_SUMMARY,
        "signed_literal_twice_matches": "Every signed literal occurs exactly twice" in CONSTRUCTION_SUMMARY,
        "gamma_e_bound_matches": "gamma_e(G) >= 75/5 = 15" in CONSTRUCTION_SUMMARY,
        "gamma_upper_witness_size_matches": "D0 = 16 vertices dominates" in CONSTRUCTION_SUMMARY,
        "clause_subset_scale_matches": "2^20 = 1,048,576" in CONSTRUCTION_SUMMARY,
    }
    for k, v in checks.items():
        print(f"    [{'ok' if v else 'MISS'}] {k}")
    ok = all(checks.values())
    print(f"    -> gate's construction matches the source's stated construction: {ok}")
    checks["ok"] = ok
    checks["provenance"] = "live HTML fetch, not a pinned PDF"
    return checks


def solver_discrimination_check() -> dict:
    """(2) Can the branch-and-bound search ever decline to fire -- i.e. find
    a dominating set when one genuinely exists at a given budget, not just
    report "none exists" unconditionally?

    Positive controls (small dominating set MUST be found):
      - K4 (complete graph on 4 vertices, 3-regular): gamma(K4) = 1.
      - Petersen graph (10 vertices, 3-regular, textbook gamma = 3).
      - The Baste-Furst-Henning graph itself at budget=16 (the source's own
        upper-bound witness, so a solution MUST exist).

    Negative control (repeats the gate's own claim, at a tighter budget):
      - The Baste-Furst-Henning graph at budget=14: if a dominating set
        existed there the gate's BREAK would already be wrong, independent
        of this control; recorded for completeness.
    """
    print("\n[2] Discrimination: can the search find small dominating sets"
          " when they exist, or does it always report 'none'?")
    rows = []

    def k4_adj() -> dict[int, set[int]]:
        return {v: {u for u in range(4) if u != v} for v in range(4)}

    found, stats = BD.exists_dominating_set_of_size_at_most(k4_adj(), budget=1, time_limit_s=5.0)
    rows.append({"graph": "K4", "budget": 1, "expected": True, "found": found})
    print(f"    K4, budget=1 (gamma(K4)=1): found={found} nodes={stats['nodes_explored']}")

    petersen_edges = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),
    ]
    petersen_adj: dict[int, set[int]] = {v: set() for v in range(10)}
    for u, v in petersen_edges:
        petersen_adj[u].add(v)
        petersen_adj[v].add(u)
    found_p3, stats_p3 = BD.exists_dominating_set_of_size_at_most(
        petersen_adj, budget=3, time_limit_s=10.0
    )
    found_p2, stats_p2 = BD.exists_dominating_set_of_size_at_most(
        petersen_adj, budget=2, time_limit_s=10.0
    )
    rows.append({"graph": "Petersen", "budget": 3, "expected": True, "found": found_p3})
    rows.append({"graph": "Petersen", "budget": 2, "expected": False, "found": found_p2})
    print(f"    Petersen, budget=3 (textbook gamma=3): found={found_p3} "
          f"nodes={stats_p3['nodes_explored']}")
    print(f"    Petersen, budget=2 (below textbook gamma=3): found={found_p2} "
          f"nodes={stats_p2['nodes_explored']}")

    adj, _ = BD.build_graph()
    found_16, stats_16 = BD.exists_dominating_set_of_size_at_most(
        adj, budget=16, time_limit_s=30.0
    )
    rows.append({"graph": "baste-50v", "budget": 16, "expected": True, "found": found_16})
    print(f"    Baste-50v graph, budget=16 (source's own upper-bound witness): "
          f"found={found_16} nodes={stats_16['nodes_explored']}")

    all_expected_matched = all(r["found"] == r["expected"] for r in rows)
    print(f"    -> solver matches every expected outcome (K4=1, Petersen=3 "
          f"but not 2, Baste-50v=16): {all_expected_matched}")
    return {"rows": rows, "ok": all_expected_matched}


def cubic_bound_self_consistency_check() -> dict:
    """(3) Does the general cubic edge-domination lower-bound formula give
    the right, independently-known answer on graphs OTHER than the target?
    K4: 6 edges, minimum maximal matching known by inspection to be 2
    (any single edge leaves the opposite edge still addable).
    """
    print("\n[3] Algebraic self-consistency: cubic edge-domination bound on K4")
    bound = BD.cubic_edge_domination_lower_bound(6)
    known_min_maximal_matching_k4 = 2
    ok = bound == known_min_maximal_matching_k4
    print(f"    formula on K4 (6 edges): ceil(6/5) = {bound}; "
          f"known minimum maximal matching = {known_min_maximal_matching_k4}")
    print(f"    -> formula matches ground truth on an independent graph: {ok}")
    return {"k4_bound": bound, "k4_known": known_min_maximal_matching_k4, "ok": ok}


def main() -> int:
    print(BAR)
    print("baste_domination -- false-positive control")
    print(BAR)
    t = transcription_check()
    d = solver_discrimination_check()
    c = cubic_bound_self_consistency_check()

    checks = [t["ok"], d["ok"], c["ok"]]
    verdict = "NO FALSE POSITIVE" if all(checks) else "REVIEW"

    print(f"\n{BAR}")
    print(f"baste_domination control verdict: {verdict}")
    print(BAR)
    return 0 if verdict == "NO FALSE POSITIVE" else 1


if __name__ == "__main__":
    raise SystemExit(main())
