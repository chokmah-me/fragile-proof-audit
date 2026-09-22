"""Numeric gate: Sarkozy's sum-product conjecture (mod p) is FALSE.

Source claim (corpus/live-fragile-proofs-2024-2026.md, Target Identifier
"Sarkozy's Sums/Products Conjecture, 2026 Refutation"; refutation Tang, Q.
(2026), "A counterexample to a conjecture of Sarkozy on sums and products
modulo a prime," arXiv:2603.29992):

    Sarkozy conjectured constants c, C such that for every prime p, any set
    A subset Z/pZ with |A| >= c*p must satisfy 1 in (A+A) union (A*A).
    Tang's refutation: for every odd prime p there is a set A of exact
    size (p-1)/2 with 1 NOT in (A+A) union (A*A), pinning the sharp
    threshold at density 1/2, so no c < 1/2 can work.

Corpus "Formalizable Slice":

    theorem sarkozy_conjecture_false :
        forall p >= 5, Prime p ->
        exists A : Finset (ZMod p), A.card = (p - 1) / 2 /\\
            (1 : ZMod p) notin (A + A) union (A * A)

This gate does NOT copy Tang's explicit construction (the corpus doc's own
description of it is internally inconsistent -- see the "Wait, if ... that
fails" hedge in its "Verifiable Gate" bullet). Instead it independently
re-derives a witness by EXHAUSTIVE subset search over Z/pZ for each tested
prime: every size-(p-1)/2 subset is checked directly against the
(p-1)/2 not in (A+A), (A*A) definitional condition. This is slower than a
constructive witness but has no dependency on transcribing Tang's
quadratic-residue argument correctly.

Gates refute routes, not theorems: this does not claim anything about
Sarkozy's conjecture beyond the explicit witnesses found below.
"""

from __future__ import annotations

import itertools
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

CI_PRIMES = [5, 7, 11, 13, 17, 19]
DEEP_PRIMES = CI_PRIMES + [23]


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    p = 3
    while p * p <= n:
        if n % p == 0:
            return False
        p += 2
    return True


def avoids_one(a_set: tuple[int, ...], p: int) -> bool:
    """True iff 1 (mod p) is in neither the sumset nor the productset of a_set."""
    for a in a_set:
        for b in a_set:
            if (a + b) % p == 1:
                return False
            if (a * b) % p == 1:
                return False
    return True


def avoids_one_via_sets(a_set: tuple[int, ...], p: int) -> bool:
    """Independent re-implementation: build the sumset/productset as Python
    sets first, then test membership, instead of the pairwise early-exit
    loop `avoids_one` uses. Cross-checked below before either is trusted.
    """
    sumset = {(a + b) % p for a in a_set for b in a_set}
    prodset = {(a * b) % p for a in a_set for b in a_set}
    return 1 not in sumset and 1 not in prodset


def search_prime(p: int) -> dict:
    if not is_prime(p) or p < 5 or p % 2 == 0:
        raise ValueError(f"gate requires an odd prime >= 5, got {p}")
    k = (p - 1) // 2
    t0 = time.perf_counter()
    witnesses = 0
    first_witness = None
    cross_check_ok = True
    for combo in itertools.combinations(range(p), k):
        primary = avoids_one(combo, p)
        if primary != avoids_one_via_sets(combo, p):
            cross_check_ok = False
        if primary:
            witnesses += 1
            if first_witness is None:
                first_witness = list(combo)
    elapsed = time.perf_counter() - t0
    return {
        "p": p,
        "k": k,
        "witness_count": witnesses,
        "first_witness": first_witness,
        "cross_check_ok": cross_check_ok,
        "elapsed_s": round(elapsed, 4),
        "has_witness": witnesses > 0,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    deep = "--deep" in sys.argv
    primes = DEEP_PRIMES if deep else CI_PRIMES

    per_prime = [search_prime(p) for p in primes]

    all_have_witness = all(row["has_witness"] for row in per_prime)
    all_cross_check_ok = all(row["cross_check_ok"] for row in per_prime)
    # Density check: (p-1)/2 divided by p is always strictly below 1/2 by
    # construction, and increases toward 1/2 as p grows -- the corpus claim
    # is that this is the sharp threshold, i.e. no fixed c < 1/2 survives as
    # p -> infinity. This is a sanity check on the arithmetic, not a
    # discriminating test (it cannot fail for k = (p-1)//2).
    densities = [row["k"] / row["p"] for row in per_prime]
    density_below_half = all(d < 0.5 for d in densities)
    density_increasing = densities == sorted(densities)

    ok = all_have_witness and all_cross_check_ok and density_below_half

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "sarkozy_sum_product",
        "source_claim": (
            "Sarkozy's sum-product conjecture: exists c>0 s.t. any A subset "
            "Z/pZ with |A| >= c*p forces 1 in (A+A) union (A*A)"
        ),
        "source_refutation": "Tang, Q. (2026), arXiv:2603.29992",
        "corpus_pointer": "corpus/live-fragile-proofs-2024-2026.md",
        "deep": deep,
        "primes_tested": primes,
        "per_prime": per_prime,
        "all_have_witness": all_have_witness,
        "all_cross_check_ok": all_cross_check_ok,
        "densities": [round(d, 4) for d in densities],
        "density_below_half": density_below_half,
        "density_increasing": density_increasing,
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": (
            "for all c < 1/2 there is p and A, |A| >= c*p, "
            "1 notin (A+A) union (A*A)"
        ),
        "instance": f"p in {primes}, |A| = (p-1)/2 for each",
        "false_instance": (
            "explicit witness A found by exhaustive search for every tested "
            "prime, each of density (p-1)/(2p) -> 1/2"
        ),
        "ok": ok,
    }
    out = RESULTS / "sarkozy_sum_product_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] sarkozy_sum_product")
    for row in per_prime:
        print(
            f"  p={row['p']:3d} k={row['k']:2d} witnesses={row['witness_count']:3d} "
            f"first={row['first_witness']} cross_check_ok={row['cross_check_ok']} "
            f"t={row['elapsed_s']}s"
        )
    print(f"  all_have_witness={all_have_witness} "
          f"all_cross_check_ok={all_cross_check_ok} "
          f"density_below_half={density_below_half} "
          f"density_increasing={density_increasing}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
