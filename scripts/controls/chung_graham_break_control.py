"""Discrimination control for the chung_graham_spiro gate (BREAK,
witness-by-construction shape -- see docs/GATE-BEFORE-PROVE.md).

Four questions:

1. Matched claim -- the true, UN-refuted part of the same conjecture (l=1
   and l=2) must PASS: D_1=U_1={1,2,3,5} and D_2=U_2={2,3,4,5,6,8,10} are
   the paper's own reported values (Chung-Graham-Spiro's original theorem,
   quoted in the refutation paper's introduction). This campaign's own Path
   A machinery must reproduce D_1=U_1 and D_2=U_2 exactly, over the same
   range used for l=4 -- if the gate's search machinery had a bug that made
   it always find a "gap set mismatch", this would catch it (a check that
   can only ever say BREAK is not evidence).
2. Negative window -- l=3 is explicitly flagged by the refutation paper
   itself (Section 5) as open/unrefuted ("our numerical computations have
   not revealed any discrepancy... providing some computational evidence
   that D_3=U_3"). This campaign's own D_3/U_3 computation over the same
   range must likewise find no discrepancy -- if the gate's "gap-set
   mismatch" search fired on everything, it would find a fake mismatch here
   too.
3. Transcription -- the gate's Path A output for D cap [2,17] and D cap
   [2,113] already exactly reproduces two independently-sized literal lists
   printed in the pinned PDF (Theorem 1.1's worked example and Lemma 3.1's
   full finite enumeration); re-asserted here as a control input, not
   re-derived.
4. Path B corroboration depth -- report how much of the from-scratch
   slow-walk simulation's [2,220] range is unambiguous (no tie) and
   confirm 100% agreement with Path A there, plus explicitly confirm the
   witness block members are among the unambiguous, agreeing cases (already
   checked by the gate itself; re-asserted here as a control input).
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
sys.path.insert(0, str(ROOT))

from scripts.gates.chung_graham_spiro import (  # noqa: E402
    classify_repr,
    classify_walk,
    du_partition_repr,
    five_consecutive_gap9_blocks,
)


def gap_set(seq: list[int], l: int) -> set[int]:
    return {seq[i + l] - seq[i] for i in range(len(seq) - l)}


def matched_claim_l1_l2():
    """The paper's OWN reported true claims: D_1=U_1={1,2,3,5},
    D_2=U_2={2,3,4,5,6,8,10}. Reproduce from this campaign's own Path A --
    over a range large enough (N=5000, matching the l=3 negative window
    below) that the gap set has stabilized, not the smaller [2,113] range
    used for the l=4 base case, which truncates D_2/U_2 short of their
    largest element (10) simply for lack of room, not disagreement. Must
    PASS (agree with each other, and with the paper's stated values), not
    BREAK -- if the gate's search machinery had a bug that made it always
    report a mismatch, this would catch it."""
    d, u = du_partition_repr(2, 5000)
    d1, u1 = gap_set(d, 1), gap_set(u, 1)
    d2, u2 = gap_set(d, 2), gap_set(u, 2)
    expected_1 = {1, 2, 3, 5}
    expected_2 = {2, 3, 4, 5, 6, 8, 10}
    return {
        "D1": sorted(d1),
        "U1": sorted(u1),
        "D2": sorted(d2),
        "U2": sorted(u2),
        "D1_eq_U1": d1 == u1 == expected_1,
        "D2_eq_U2": d2 == u2 == expected_2,
        "ok": d1 == u1 == expected_1 and d2 == u2 == expected_2,
    }


def negative_window_l3():
    """l=3 is explicitly open per the paper's own Section 5 -- this
    campaign's own computation over the same finite range must likewise
    find no discrepancy (a matched, honest negative window, not assumed)."""
    d, u = du_partition_repr(2, 5000)
    d3, u3 = gap_set(d, 3), gap_set(u, 3)
    return {
        "N": 5000,
        "D3": sorted(d3),
        "U3": sorted(u3),
        "D3_eq_U3_over_range": d3 == u3,
        "ok": d3 == u3,
    }


def path_b_depth_check():
    n_checked, n_unambiguous, disagreements, tie_ns = 0, 0, [], []
    for n in range(2, 221):
        n_checked += 1
        cls_a = classify_repr(n)
        cls_b, tie = classify_walk(n)
        if tie:
            tie_ns.append(n)
            continue
        n_unambiguous += 1
        if cls_a != cls_b:
            disagreements.append(n)
    witness_ok = all(
        (lambda cb, t: (not t) and cb == "U")(*classify_walk(w))
        for w in (8, 11, 14, 16, 17)
    )
    return {
        "n_checked": n_checked,
        "n_unambiguous": n_unambiguous,
        "disagreements": disagreements,
        "witness_block_confirmed_unambiguous": witness_ok,
        "ok": len(disagreements) == 0 and n_unambiguous > 100 and witness_ok,
    }


def transcription_check():
    from scripts.gates.chung_graham_spiro import (
        PAPER_D_2_17,
        PAPER_D_2_113,
        PAPER_U_2_17,
        du_partition_repr as _dup,
    )

    d17, u17 = _dup(2, 17)
    d113, _ = _dup(2, 113)
    return {
        "D_2_17_matches": d17 == PAPER_D_2_17,
        "U_2_17_matches": u17 == PAPER_U_2_17,
        "D_2_113_matches": d113 == PAPER_D_2_113,
        "ok": d17 == PAPER_D_2_17 and u17 == PAPER_U_2_17 and d113 == PAPER_D_2_113,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    matched = matched_claim_l1_l2()
    negwin = negative_window_l3()
    pathb = path_b_depth_check()
    transcription = transcription_check()

    ok = matched["ok"] and negwin["ok"] and pathb["ok"] and transcription["ok"]

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "control": "chung_graham_break_control",
        "gate": "chung_graham_spiro",
        "matched_claim_l1_l2": matched,
        "negative_window_l3": negwin,
        "path_b_depth_check": pathb,
        "transcription_check": transcription,
        "verdict": "NO FALSE POSITIVE" if ok else "INCONCLUSIVE",
        "ok": ok,
    }
    out = RESULTS / "chung_graham_break_control_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"[{'PASS' if ok else 'FAIL'}] chung_graham_break_control")
    print(f"  matched claim (l=1,2 agree, per paper's own true theorem): {matched['ok']}")
    print(f"  negative window (l=3, paper's own flagged-open case, up to N=5000): {negwin['ok']}")
    print(f"  Path B depth: {pathb['n_unambiguous']}/{pathb['n_checked']} unambiguous, "
          f"{len(pathb['disagreements'])} disagreements, witness block confirmed: "
          f"{pathb['witness_block_confirmed_unambiguous']}")
    print(f"  transcription: {transcription['ok']}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
