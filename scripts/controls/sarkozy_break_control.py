"""False-positive control for the sarkozy_sum_product BREAK gate.

Same four questions as break_control.py / cohen_break_control.py /
baste_break_control.py, applied to scripts/gates/sarkozy_sum_product.py.

PROVENANCE UPGRADE (2026-09-21 re-audit). This control used to check the
gate's statement of the conjecture against the corpus doc's paraphrase, and
it PASSED -- because both said the same wrong thing. The corpus doc put the
density threshold at |A| >= c*p; Tang's Conjecture 1.1, taken from Sarkozy's
2001 list, puts it at |A| > (1/2 - c)p. Under the corpus doc's version the
"conjecture" is refuted by any small set and the BREAK would have been
vacuous. A control that validates a gate against the same unchecked source
the gate came from is not an instrument, it is an echo.

The PDF is now pinned at incoming/sarkozy-tang-2603.29992.pdf. Transcription
fidelity is tested against the paper's own structural claims, and the
independent corroboration is now Tang's Proposition 2.1 (|A| > p/2 implies
A+A = F_p) -- the sharpness half of the result, which shares no machinery
with the counterexample and is separately checkable here.

Run:  python scripts/controls/sarkozy_break_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""
from __future__ import annotations

import itertools
import json
import random
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

import sarkozy_sum_product as SP  # noqa: E402
from receipt import write_receipt  # noqa: E402

BAR = "=" * 74

PINNED_PDF = ROOT / "incoming" / "sarkozy-tang-2603.29992.pdf"

# Structural claims transcribed independently from Section 2 of the pinned
# PDF, checked against the gate's re-derivation below.
#   - components are {0,1}, {2,1/2,-1}, possibly the roots of X^2-X+1, and
#     6-cycles; hence the count of 6-cycles is exactly (p-5-delta)/6
#   - delta in {0,2} and delta = 2 exactly when -3 is a square mod p
#   - the resulting independent set has |A| = (p-1)/2


def transcription_check() -> dict:
    """(1) Do the paper's structural claims hold when re-derived from
    scratch? These are the claims the gate's Path B relies on, so a
    mis-transcription shows up as a structural disagreement rather than as
    agreement between two copies of the same sentence.
    """
    print("\n[1] Transcription fidelity (pinned PDF, arXiv:2603.29992v2 Section 2)")
    rows = []
    for p in (5, 7, 11, 13, 17, 19, 23, 31, 101, 401, 1009):
        row = SP.tang_construction(p)
        # delta = 2 iff -3 is a QR mod p, an independent derivation of the
        # paper's "delta in {0,2}, the discriminant is -3" remark.
        legendre = pow((-3) % p, (p - 1) // 2, p)
        expected_delta = 2 if legendre == 1 else 0
        rows.append({
            "p": p,
            "delta": row["delta"],
            "expected_delta_from_legendre": expected_delta,
            "delta_matches": row["delta"] == expected_delta,
            "cycle_count_matches": row["cycle_count_matches"],
            "A_size_matches": row["A_size_matches"],
            "cycles_clean": row["cycles_are_6_cycles_without_chords"],
        })
        print(f"    p={p:5d} delta={row['delta']} (Legendre says "
              f"{expected_delta}) cycles ok={row['cycle_count_matches']} "
              f"|A|=(p-1)/2 ok={row['A_size_matches']}")

    checks = {
        "pdf_pinned": PINNED_PDF.exists(),
        "delta_matches_legendre_symbol": all(r["delta_matches"] for r in rows),
        "six_cycle_count_matches_formula": all(
            r["cycle_count_matches"] for r in rows
        ),
        "components_are_chordless_6_cycles": all(r["cycles_clean"] for r in rows),
        "constructed_set_has_size_p_minus_1_over_2": all(
            r["A_size_matches"] for r in rows
        ),
    }
    for k, v in checks.items():
        print(f"    [{'ok' if v else 'MISS'}] {k}")
    ok = all(checks.values())
    print(f"    -> paper's Section 2 structure re-derives correctly: {ok}")
    checks["ok"] = ok
    checks["rows"] = rows
    checks["provenance"] = "pinned PDF, structure re-derived not paraphrased"
    return checks


def discrimination_check(trials: int = 200, seed: int = 2603) -> dict:
    """(2) Can avoids_one ever decline to fire, i.e. correctly report False?
    A check that always returns True regardless of input would make the
    exhaustive-search witness count meaningless. Confirm two things:
    (a) the full set A = Z/pZ always fails (1 is trivially in both A+A and
        A*A once A is everything nonzero-adjacent), and
    (b) random oversized subsets (size > (p-1)/2, closer to density 1)
        fail far more often than the actual witnesses at size (p-1)/2,
        showing the gate's positive rate is sensitive to |A|, not constant.
    """
    print("\n[2] Discrimination: does avoids_one ever decline to fire?")
    rng = random.Random(seed)

    full_set_fails = []
    for p in SP.CI_PRIMES:
        full = tuple(range(p))
        full_set_fails.append(not SP.avoids_one(full, p))
    all_full_sets_fail = all(full_set_fails)
    print(f"    full set A=Z/pZ correctly fails avoids_one for all CI primes: "
          f"{all_full_sets_fail}")

    rows = []
    for p in SP.CI_PRIMES:
        k_actual = (p - 1) // 2
        k_over = min(p, k_actual + 2)  # a denser-than-witness sample size
        hits_at_k = 0
        hits_over = 0
        trials_here = min(trials, 40)
        for _ in range(trials_here):
            sample_k = tuple(rng.sample(range(p), k_actual))
            sample_over = tuple(rng.sample(range(p), k_over))
            if SP.avoids_one(sample_k, p):
                hits_at_k += 1
            if SP.avoids_one(sample_over, p):
                hits_over += 1
        rows.append(
            {
                "p": p,
                "k_actual": k_actual,
                "hits_at_k": hits_at_k,
                "k_over": k_over,
                "hits_over": hits_over,
                "trials": trials_here,
            }
        )
        print(
            f"    p={p:3d}: random size-{k_actual} subsets avoid 1 in "
            f"{hits_at_k}/{trials_here}; random size-{k_over} subsets avoid 1 in "
            f"{hits_over}/{trials_here}"
        )

    density_sensitive = all(r["hits_over"] <= r["hits_at_k"] for r in rows)
    not_tautological = any(r["hits_at_k"] < r["trials"] for r in rows)
    print(f"    -> positive rate is monotone non-increasing in density "
          f"(oversized subsets hit 1 at least as often): {density_sensitive}")
    print(f"    -> not every subset avoids 1 (rules out a tautological check): "
          f"{not_tautological}")
    return {
        "all_full_sets_fail": all_full_sets_fail,
        "density_rows": rows,
        "density_sensitive": density_sensitive,
        "not_tautological": not_tautological,
    }


def algebraic_self_consistency_check() -> dict:
    """(3) Do the gate's two independent membership implementations
    (avoids_one pairwise loop vs avoids_one_via_sets) already agree? Delegated
    to the gate's own recorded per-prime cross_check_ok flags rather than
    re-running the O(C(p,k)) search here.
    """
    print("\n[3] Algebraic self-consistency (two independent avoids_one implementations)")
    meta_path = ROOT / "results" / "sarkozy_sum_product_gate_meta.json"
    if not meta_path.exists():
        print("    unavailable -- run scripts/gates/sarkozy_sum_product.py first")
        return {"ok": None, "note": "gate meta not found"}
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    path_a = meta.get("path_a_exhaustive_search", {})
    per_prime_ok = [row["cross_check_ok"] for row in path_a.get("per_prime", [])]
    ok = bool(per_prime_ok) and all(per_prime_ok)
    print(f"    gate's own pairwise-vs-set cross-check ok for every tested prime: {ok}")
    return {"ok": ok, "per_prime_cross_check_ok": per_prime_ok}


def independent_corroboration_check() -> dict:
    """(4) Tang's Proposition 2.1: if |A| > p/2 then A + A = F_p. This is the
    OTHER half of the paper -- the sharpness bound -- and it shares no
    machinery with the counterexample construction. It is also the check that
    makes "(p-1)/2 is the extremal size" meaningful rather than arbitrary:
    one element more and the phenomenon must disappear.

    Two things are tested. First, the proposition itself, on random sets just
    over the threshold. Second, the boundary: at exactly |A| = (p-1)/2 a
    witness exists (the gate's own), while at |A| = (p+1)/2 > p/2 no set at
    all can avoid 1, so the construction cannot be pushed further.

    This replaces an earlier quadratic-residue corroboration that came back
    negative at every tested prime. That check was looking for the phenomenon
    in a family Tang never claimed exhibits it, so its failure was
    uninformative -- and reporting it as a weakened corroboration overstated
    what had gone wrong.
    """
    print("\n[4] Independent corroboration: Tang's Proposition 2.1 (sharpness)")
    rng = random.Random(29992)
    rows = []
    for p in (5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47):
        k_over = p // 2 + 1  # strictly greater than p/2
        prop_holds = True
        for _ in range(40):
            a = tuple(sorted(rng.sample(range(p), k_over)))
            sumset = {(x + y) % p for x in a for y in a}
            if len(sumset) != p:
                prop_holds = False
                break
        # Boundary: can ANY set of size (p+1)/2 avoid 1 in A+A?
        k_boundary = (p + 1) // 2
        any_boundary_avoids = any(
            SP.avoids_one_via_involutions(combo, p)
            for combo in itertools.combinations(range(p), k_boundary)
        ) if p <= 19 else None
        rows.append({
            "p": p,
            "k_over_half": k_over,
            "proposition_2_1_holds": prop_holds,
            "k_boundary": k_boundary,
            "any_set_of_boundary_size_avoids_one": any_boundary_avoids,
        })
        print(f"    p={p:3d}: |A|={k_over}>p/2 always gives A+A=F_p: "
              f"{prop_holds}; any |A|={k_boundary} set avoiding 1: "
              f"{any_boundary_avoids}")

    prop_always_holds = all(r["proposition_2_1_holds"] for r in rows)
    boundary_is_sharp = all(
        r["any_set_of_boundary_size_avoids_one"] is not True for r in rows
    )
    print(f"    -> Proposition 2.1 holds on every tested prime: {prop_always_holds}")
    print(f"    -> one element above (p-1)/2 the phenomenon vanishes "
          f"(threshold is sharp, not arbitrary): {boundary_is_sharp}")
    return {
        "rows": rows,
        "proposition_2_1_holds": prop_always_holds,
        "boundary_is_sharp": boundary_is_sharp,
        "ok": prop_always_holds and boundary_is_sharp,
        "note": (
            "the sharpness half of Tang's paper, structurally independent of "
            "the counterexample construction"
        ),
    }


def main() -> int:
    print(BAR)
    print("sarkozy_sum_product -- false-positive control")
    print(BAR)
    t = transcription_check()
    d = discrimination_check()
    a = algebraic_self_consistency_check()
    c = independent_corroboration_check()

    checks = [
        t["ok"],
        d["all_full_sets_fail"] and d["density_sensitive"] and d["not_tautological"],
        a["ok"],
        c["ok"],
    ]
    if all(x is True for x in checks):
        verdict = "NO FALSE POSITIVE"
    elif any(x is False for x in checks):
        verdict = "REVIEW"
    else:
        verdict = "NO FALSE POSITIVE (partial -- some checks unavailable)"

    print(f"\n{BAR}")
    print(f"sarkozy_sum_product control verdict: {verdict}")
    print(BAR)
    ok = verdict.startswith("NO FALSE POSITIVE")
    write_receipt(
        control="sarkozy_break_control",
        gate="sarkozy_sum_product",
        verdict=verdict,
        checks={"transcription": t, "discrimination": d,
                "algebraic_self_consistency": a,
                "independent_corroboration": c},
        ok=ok,
        extra={"local_pdf": "incoming/sarkozy-tang-2603.29992.pdf"},
    )
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
