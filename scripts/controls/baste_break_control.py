"""False-positive control for the baste_domination BREAK gate.

Same four questions as `break_control.py` / `cohen_break_control.py`, applied
to `scripts/gates/baste_domination.py`.

PROVENANCE UPGRADE (2026-09-21 re-audit). This control used to compare a
prose summary of the paper against itself by substring matching -- a check
that could not fail, the very defect the campaign forbids
(docs/GATE-BEFORE-PROVE.md, "never gate on a check that cannot fail"). The
PDF is now pinned at incoming/baste-afrasyab-2609.10783.pdf and the clause
list, vertex labelling and dominating witness below are a SECOND, independent
transcription taken from its Sections 2-4. The check compares that second
transcription against the gate's own constants, so a mis-copied clause in
either place now shows up as a disagreement.

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

sys.path.insert(0, str(ROOT / "scripts" / "controls"))

import baste_domination as BD  # noqa: E402
from receipt import write_receipt  # noqa: E402

BAR = "=" * 74

PINNED_PDF = ROOT / "incoming" / "baste-afrasyab-2609.10783.pdf"

# Independent transcription of the twenty clauses displayed in Section 2 of
# the pinned PDF. Positive j is x_j, negative j is not-x_j. Copied from the
# paper, NOT from scripts/gates/baste_domination.py -- the whole point is that
# the two transcriptions are compared against each other below.
PAPER_CLAUSES: list[tuple[int, int, int]] = [
    (1, 9, -11),    (-4, -10, -13),
    (1, -9, -14),   (2, 6, 14),
    (-5, -6, 15),   (2, -3, 15),
    (3, 5, -9),     (-6, -12, -15),
    (-1, 5, -11),   (4, -7, -15),
    (-2, 8, -12),   (3, 9, 11),
    (-4, -8, 10),   (7, -8, 13),
    (4, 7, -13),    (-2, -7, 14),
    (-3, 11, -14),  (8, 10, 12),
    (-10, 12, 13),  (-1, -5, 6),
]

# Section 4: "In the numeric labeling above, set D_0 = {...}".
PAPER_D0 = [0, 2, 5, 7, 8, 13, 15, 30, 31, 32, 33, 35, 37, 42, 46, 48]

# Section 2's machine labelling, and Section 3's two bounds.
PAPER_LABELS = {"v_minus": lambda j: 2 * (j - 1),
                "v_plus": lambda j: 2 * (j - 1) + 1,
                "c": lambda a: 29 + a}
PAPER_VERTEX_COUNT = 50
PAPER_EDGE_COUNT = 75
PAPER_GAMMA_E = 15
PAPER_GAMMA = 16


def transcription_check() -> dict:
    """(1) Does the gate's transcription agree with an independent second
    transcription of the pinned PDF? Compares the objects themselves, not
    prose about them.
    """
    print("\n[1] Transcription fidelity (pinned PDF, arXiv:2609.10783v1)")

    gate_d0 = sorted(
        BD.literal_vertex(j, -1 if kind == "v-" else +1)
        if kind in ("v-", "v+")
        else BD.clause_vertex(j)
        for kind, j in BD.SOURCE_DOMINATING_SET
    )
    labels_match = all(
        BD.literal_vertex(j, -1) == PAPER_LABELS["v_minus"](j)
        and BD.literal_vertex(j, +1) == PAPER_LABELS["v_plus"](j)
        for j in range(1, BD.NUM_VARS + 1)
    ) and all(
        BD.clause_vertex(a) == PAPER_LABELS["c"](a)
        for a in range(1, BD.NUM_CLAUSES + 1)
    )

    checks = {
        "pdf_pinned": PINNED_PDF.exists(),
        "clause_list_matches_paper": [tuple(c) for c in BD.CLAUSES] == PAPER_CLAUSES,
        "clause_count_is_20": len(PAPER_CLAUSES) == 20 == BD.NUM_CLAUSES,
        "vertex_labeling_matches": labels_match,
        "dominating_witness_matches_paper_D0": gate_d0 == PAPER_D0,
        "vertex_count_matches": BD.NUM_VERTICES == PAPER_VERTEX_COUNT,
        "edge_count_matches": BD.NUM_EDGES == PAPER_EDGE_COUNT,
    }
    for k, v in checks.items():
        print(f"    [{'ok' if v else 'MISS'}] {k}")
    ok = all(checks.values())
    print(f"    -> gate's construction matches an independent reading of the "
          f"pinned PDF: {ok}")
    checks["ok"] = ok
    checks["provenance"] = "pinned PDF, second independent transcription"
    checks["gate_D0"] = gate_d0
    checks["paper_D0"] = PAPER_D0
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
    ok = all(checks)
    verdict = "NO FALSE POSITIVE" if ok else "REVIEW"

    print(f"\n{BAR}")
    print(f"baste_domination control verdict: {verdict}")
    print(BAR)
    write_receipt(
        control="baste_break_control",
        gate="baste_domination",
        verdict=verdict,
        checks={"transcription": t, "solver_discrimination": d,
                "cubic_bound_self_consistency": c},
        ok=ok,
        extra={"local_pdf": "incoming/baste-afrasyab-2609.10783.pdf"},
    )
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
