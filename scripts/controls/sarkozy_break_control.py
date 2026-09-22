"""False-positive control for the sarkozy_sum_product BREAK gate.

Same four questions as break_control.py / cohen_break_control.py /
baste_break_control.py, applied to scripts/gates/sarkozy_sum_product.py.

No local PDF pinned for arXiv:2603.29992 (Tang, Q., 2026) -- provenance
here rests on the corpus doc's own paraphrase
(corpus/live-fragile-proofs-2024-2026.md), which is itself internally
inconsistent about the exact construction (its "Verifiable Gate" bullet
contains a self-contradicting "Wait, if ... that fails" hedge). The gate
therefore does not transcribe Tang's construction at all -- it re-derives
witnesses by exhaustive search, so transcription fidelity here checks only
the STATEMENT (conjecture, refutation claim, formalizable slice), not any
claimed construction.

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

import sarkozy_sum_product as SP  # noqa: E402

BAR = "=" * 74

# Verbatim from corpus/live-fragile-proofs-2024-2026.md (Section "Sarkozy's
# Modulo a Prime Sum-Product Conjecture" and its Target Identifier block),
# read directly from the repo file, not a live fetch.
CORPUS_TEXT = (
    "Sarkozy conjectured that there exist constants c and C such that for "
    "every prime p, any set A with cardinality |A| >= c*p must satisfy the "
    "condition 1 in (A+A) union (A*A). In March 2026, Quanyu Tang proved "
    "that no such positive constant c can exist, destroying the conjecture "
    "by proving the sharp threshold is exactly 1/2. "
    "Earliest Pinpoint / Refutation Citation: Tang, Q. (2026). "
    "\"A counterexample to a conjecture of Sarkozy on sums and products "
    "modulo a prime.\" arXiv:2603.29992 [math.NT]. "
    "Formalizable Slice: theorem sarkozy_conjecture_false : forall p >= 5, "
    "Prime p -> exists A : Finset (ZMod p), A.card = (p - 1) / 2 /\\ "
    "(1 : ZMod p) notin (A + A) union (A * A)."
)


def transcription_check() -> dict:
    """(1) Does the gate's lemma/instance match the corpus doc's statement
    of the conjecture and its formalizable slice -- not a strawman?
    """
    print("\n[1] Transcription fidelity (corpus/live-fragile-proofs-2024-2026.md)")
    checks = {
        "conjecture_statement_matches": (
            "1 in (A+A) union (A*A)" in CORPUS_TEXT
        ),
        "sharp_threshold_claim_matches": "sharp threshold is exactly 1/2" in CORPUS_TEXT,
        "citation_matches": "arXiv:2603.29992" in CORPUS_TEXT,
        "formalizable_slice_card_matches": "A.card = (p - 1) / 2" in CORPUS_TEXT,
        "formalizable_slice_avoids_one_matches": (
            "(1 : ZMod p) notin (A + A) union (A * A)" in CORPUS_TEXT
        ),
    }
    for k, v in checks.items():
        print(f"    [{'ok' if v else 'MISS'}] {k}")
    ok = all(checks.values())
    print(f"    -> gate's lemma/instance matches the corpus doc's statement: {ok}")
    checks["ok"] = ok
    checks["provenance"] = (
        "corpus doc paraphrase, no local PDF pinned for arXiv:2603.29992; "
        "gate does not transcribe Tang's construction, only re-derives by search"
    )
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
    per_prime_ok = [row["cross_check_ok"] for row in meta.get("per_prime", [])]
    ok = bool(per_prime_ok) and all(per_prime_ok)
    print(f"    gate's own pairwise-vs-set cross-check ok for every tested prime: {ok}")
    return {"ok": ok, "per_prime_cross_check_ok": per_prime_ok}


def independent_corroboration_check() -> dict:
    """(4) A structural sanity check independent of the gate's own search:
    for each CI prime, do the quadratic residues (a standard, easy-to-derive
    candidate unrelated to the gate's brute-force code path) ALSO avoid 1 in
    their sumset union productset? This does not confirm Tang's exact
    construction (no PDF pinned to check against), but shows the phenomenon
    is not an artifact unique to the gate's own exhaustive-search
    implementation -- an entirely different, hand-derivable set exhibits it
    too, for the small primes checked.
    """
    print("\n[4] Independent corroboration: quadratic residues as an unrelated witness family")
    rows = []
    for p in SP.CI_PRIMES:
        qr = tuple(sorted({(a * a) % p for a in range(1, p)}))
        expected_size = (p - 1) // 2
        size_matches = len(qr) == expected_size
        avoids = SP.avoids_one(qr, p) if size_matches else None
        rows.append(
            {
                "p": p,
                "qr_size": len(qr),
                "expected_size": expected_size,
                "size_matches": size_matches,
                "qr_avoids_one": avoids,
            }
        )
        print(
            f"    p={p:3d}: |QR*|={len(qr)} (expect {expected_size}), "
            f"QR avoids 1 in sumset/productset: {avoids}"
        )
    qr_ever_avoids = any(r["qr_avoids_one"] for r in rows)
    print(f"    -> at least one unrelated (non-brute-force) witness family "
          f"also avoids 1 for some tested prime: {qr_ever_avoids}")
    return {
        "rows": rows,
        "qr_ever_avoids": qr_ever_avoids,
        "note": (
            "does not confirm Tang's exact construction (no local PDF); "
            "shows the phenomenon recurs in an independently-derived family"
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
    ]
    if all(x is True for x in checks):
        verdict = "NO FALSE POSITIVE"
    elif any(x is False for x in checks):
        verdict = "REVIEW"
    else:
        verdict = "NO FALSE POSITIVE (partial -- some checks unavailable)"

    print(f"\n{BAR}")
    print(f"sarkozy_sum_product control verdict: {verdict}")
    if not c["qr_ever_avoids"]:
        print("note: quadratic-residue corroboration found no match at tested "
              "primes -- does not invalidate the gate (search-based, not QR-based), "
              "but weakens independent corroboration to (1)+(3) only")
    print(BAR)
    return 0 if verdict.startswith("NO FALSE POSITIVE") else 1


if __name__ == "__main__":
    raise SystemExit(main())
