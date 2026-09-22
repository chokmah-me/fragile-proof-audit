"""Numeric gate: Sarkozy's sum-product conjecture (mod p) is FALSE.

Source claim (refutation Tang, Q. (2026), "A counterexample to a conjecture
of Sarkozy on sums and products modulo a prime," arXiv:2603.29992v2, PDF
pinned at incoming/sarkozy-tang-2603.29992.pdf, live-checked before
download).

For A subset F_p write A* := (A + A) union (AA).

    Conjecture 1.1 (Sarkozy, 2001 list, his Conjecture 65). There exist
    constants c > 0 and p_0 such that, if p > p_0 is prime and A subset F_p
    satisfies |A| > (1/2 - c) p, then F_p^x subset A*.

    Tang's Theorem 2.2: for EVERY odd prime p >= 5 there is A subset F_p
    with |A| = (p-1)/2 and 1 not in A+A, 1 not in AA -- hence 1 not in A*.
    Since (p-1)/2 > (1/2 - c)p as soon as p > 1/(2c), no positive c can
    satisfy the conjecture. Conversely |A| > p/2 forces A+A = F_p
    (Proposition 2.1), so the sharp threshold is exactly 1/2.

TRANSCRIPTION CORRECTION (2026-09-21, this re-audit). Until the PDF was
pinned, this gate recorded the conjecture as "|A| >= c*p forces 1 in A*".
That is NOT Sarkozy's conjecture: it inverts the role of c, and as stated
it is refuted by any small set, which would have made this BREAK vacuous.
The threshold is (1/2 - c)p -- a density just BELOW 1/2, not an arbitrarily
small one -- which is exactly why a witness of size (p-1)/2 is decisive.
The earlier text came from the corpus doc, which was never checked against
the source. See docs/GATE-BEFORE-PROVE.md.

Two independent paths, neither copied from the other:

  Path A -- exhaustive search over Z/pZ, no input from Tang at all. Every
    size-(p-1)/2 subset is tested directly. Confirms a witness EXISTS for
    each small prime without transcribing anything.

  Path B -- Tang's actual construction (Section 2 of the pinned PDF), now
    that the PDF is in hand. Build the graph G on F_p with u ~ v iff
    u + v = 1 or uv = 1 and a loop at u iff 2u = 1 or u^2 = 1; then A
    avoids 1 in both A+A and AA precisely when A is independent in G. The
    paper classifies the components as {0,1}, {2, 1/2, -1}, possibly the
    2-vertex component of the roots of X^2 - X + 1, and 6-cycles
    Omega(x) = {x, 1-x, 1/x, 1-1/x, 1/(1-x), x/(x-1)}. Selecting 0, 2, one
    root if present, and three alternating vertices per 6-cycle gives
    |A| = 1 + 1 + delta/2 + 3(p-5-delta)/6 = (p-1)/2.

Path B is what lets the gate speak about the asymptotics the conjecture is
actually about: it is verified over primes up to four figures, where Path A's
combinatorial search cannot reach. The component classification is re-derived
and checked here, not assumed -- if the paper's structure claim were wrong for
some p, this gate reports ABORT_TRANSCRIPTION rather than a BREAK.

Gates refute routes, not theorems: this reproduces Tang's witness for the
primes tested below. The step to "for every odd prime p >= 5" is Tang's
proof, not this gate's computation.
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

# Path A: exhaustive subset search. C(23, 11) = 1.35e6 already; 23 is the
# practical ceiling and lives behind --deep.
CI_PRIMES = [5, 7, 11, 13, 17, 19]
DEEP_PRIMES = CI_PRIMES + [23]

# Path B: Tang's construction. Linear in p, so this is where the density
# claim is actually exercised.
CI_CONSTRUCTION_PRIMES = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
                          53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 211,
                          401, 809, 1009, 2003]
DEEP_CONSTRUCTION_EXTRA = [4001, 8009, 16001, 32003]


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
    """True iff 1 (mod p) is in neither the sumset nor the productset."""
    for a in a_set:
        for b in a_set:
            if (a + b) % p == 1:
                return False
            if (a * b) % p == 1:
                return False
    return True


def avoids_one_via_sets(a_set: tuple[int, ...], p: int) -> bool:
    """Independent re-implementation: materialise the sumset/productset as
    sets, then test membership, instead of the pairwise early-exit loop.
    """
    sumset = {(a + b) % p for a in a_set for b in a_set}
    prodset = {(a * b) % p for a in a_set for b in a_set}
    return 1 not in sumset and 1 not in prodset


def avoids_one_via_involutions(a_set: tuple[int, ...], p: int) -> bool:
    """Third implementation, O(|A|) instead of O(|A|^2): 1 is in A+A iff
    some a has its additive partner 1-a in A, and 1 is in AA iff some
    nonzero a has its multiplicative inverse in A. This is the only path
    that scales to four-figure primes, so it is cross-checked against the
    two quadratic paths on every small prime before being trusted.
    """
    s = set(a_set)
    for a in s:
        if (1 - a) % p in s:
            return False
        if a != 0 and pow(a, p - 2, p) in s:
            return False
    return True


def search_prime(p: int) -> dict:
    """Path A: exhaustive search, independent of Tang's construction."""
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
        if primary != avoids_one_via_involutions(combo, p):
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


# ---------------------------------------------------------------------------
# Path B -- Tang's construction, Section 2 of the pinned PDF.
# ---------------------------------------------------------------------------


def tang_construction(p: int) -> dict:
    """Re-derive the paper's component classification and build its
    independent set. Every structural claim is checked, not assumed.
    """
    if not is_prime(p) or p < 5 or p % 2 == 0:
        raise ValueError(f"construction requires an odd prime >= 5, got {p}")

    def inv(x: int) -> int:
        return pow(x, p - 2, p)

    half = inv(2)          # 1/2
    minus_one = p - 1      # -1

    # Component 1: {0, 1}.  Component 2: {2, 1/2, -1}.
    exceptional = {0, 1, 2, half, minus_one}
    # The paper needs these five to be distinct, which is where p >= 5 enters.
    exceptional_distinct = len(exceptional) == 5

    # Possible 2-vertex component: roots of X^2 - X + 1 (delta in {0, 2}).
    roots = [x for x in range(p) if (x * x - x + 1) % p == 0]
    delta = len(roots)
    delta_in_0_2 = delta in (0, 2)
    roots_disjoint_from_exceptional = not (set(roots) & exceptional)

    covered = set(exceptional) | set(roots)

    # Everything else splits into 6-cycles Omega(x).
    six_cycles: list[list[int]] = []
    seen = set(covered)
    all_orbits_size_6 = True
    for x in range(p):
        if x in seen:
            continue
        # Cycle order, as displayed in the paper:
        #   x ~ 1-x ~ 1/(1-x) ~ x/(x-1) ~ 1-1/x ~ 1/x ~ x
        one_minus_x = (1 - x) % p
        orbit = [
            x,
            one_minus_x,
            inv(one_minus_x),
            (x * inv((x - 1) % p)) % p,
            (1 - inv(x)) % p,
            inv(x),
        ]
        if len(set(orbit)) != 6:
            all_orbits_size_6 = False
            seen.update(orbit)
            continue
        six_cycles.append(orbit)
        seen.update(orbit)

    expected_cycles, rem = divmod(p - 5 - delta, 6)
    cycle_count_matches = (rem == 0) and (len(six_cycles) == expected_cycles)

    # Verify the displayed cycle really is a 6-cycle in G: consecutive
    # vertices adjacent, and no chords.
    def adjacent(u: int, v: int) -> bool:
        return (u + v) % p == 1 or (u * v) % p == 1

    cycles_are_cycles = True
    for orbit in six_cycles:
        for i in range(6):
            if not adjacent(orbit[i], orbit[(i + 1) % 6]):
                cycles_are_cycles = False
            # opposite and distance-2 pairs must NOT be adjacent
            if adjacent(orbit[i], orbit[(i + 2) % 6]):
                cycles_are_cycles = False
            if adjacent(orbit[i], orbit[(i + 3) % 6]):
                cycles_are_cycles = False

    # Section 2, step 4: choose 0; choose 2; one root if it exists; three
    # alternating vertices from each 6-cycle.
    a_set = {0, 2}
    if delta == 2:
        a_set.add(roots[0])
    for orbit in six_cycles:
        a_set.update(orbit[0::2])

    size_expected = (p - 1) // 2
    size_matches = len(a_set) == size_expected

    # Independence, checked directly against the definition rather than
    # inferred from the construction.
    looped = {u for u in a_set if (2 * u) % p == 1 or (u * u) % p == 1}
    no_looped_vertex = not looped
    independent = all(
        not adjacent(u, v) for u, v in itertools.combinations(sorted(a_set), 2)
    ) if p <= 401 else None  # O(|A|^2); the linear check below covers large p

    avoids = avoids_one_via_involutions(tuple(sorted(a_set)), p)

    return {
        "p": p,
        "delta": delta,
        "six_cycle_count": len(six_cycles),
        "expected_six_cycle_count": expected_cycles,
        "exceptional_distinct": exceptional_distinct,
        "delta_in_0_2": delta_in_0_2,
        "roots_disjoint_from_exceptional": roots_disjoint_from_exceptional,
        "all_orbits_size_6": all_orbits_size_6,
        "cycle_count_matches": cycle_count_matches,
        "cycles_are_6_cycles_without_chords": cycles_are_cycles,
        "A_size": len(a_set),
        "A_size_expected": size_expected,
        "A_size_matches": size_matches,
        "no_looped_vertex": no_looped_vertex,
        "independent_pairwise": independent,
        "avoids_one": avoids,
        "A_sample": sorted(a_set)[:12],
        "ok": (
            exceptional_distinct
            and delta_in_0_2
            and roots_disjoint_from_exceptional
            and all_orbits_size_6
            and cycle_count_matches
            and cycles_are_cycles
            and size_matches
            and no_looped_vertex
            and (independent is not False)
            and avoids
        ),
    }


def main() -> int:
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, OSError):
            pass

    RESULTS.mkdir(parents=True, exist_ok=True)
    deep = "--deep" in sys.argv
    primes = DEEP_PRIMES if deep else CI_PRIMES
    construction_primes = (
        CI_CONSTRUCTION_PRIMES + DEEP_CONSTRUCTION_EXTRA
        if deep
        else CI_CONSTRUCTION_PRIMES
    )

    per_prime = [search_prime(p) for p in primes]
    construction = [tang_construction(p) for p in construction_primes]

    all_have_witness = all(row["has_witness"] for row in per_prime)
    all_cross_check_ok = all(row["cross_check_ok"] for row in per_prime)
    construction_ok = all(row["ok"] for row in construction)

    # Path A / Path B agreement on the primes both can reach: the constructed
    # set must be one the exhaustive search would have accepted.
    both = [p for p in primes if p in construction_primes]
    paths_agree = all(
        avoids_one(
            tuple(sorted(set(
                next(c for c in construction if c["p"] == p)["A_sample"]
            ))),
            p,
        )
        for p in both
    )

    # Density actually attained by Path B, i.e. the largest density at which
    # a witness has been exhibited here. The conjecture's threshold is
    # (1/2 - c)p, so a witness of density d refutes every c > 1/2 - d.
    max_density = max(row["A_size"] / row["p"] for row in construction)
    largest_c_refuted = 0.5 - max_density

    ok = (
        all_have_witness
        and all_cross_check_ok
        and construction_ok
        and paths_agree
    )

    # Executable documentation, not a gate condition: |A| = (p-1)/2 is below
    # p/2 by construction, so this can never fail and must not sit in `ok`
    # (docs/GATE-BEFORE-PROVE.md, "never gate on a check that cannot fail").
    assert all(row["k"] / row["p"] < 0.5 for row in per_prime)

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "sarkozy_sum_product",
        "source_claim": (
            "Sarkozy's Conjecture 65 (2001 list), as stated in Tang "
            "Conjecture 1.1: there exist c>0 and p_0 such that for every "
            "prime p>p_0, every A subset F_p with |A| > (1/2 - c)p "
            "satisfies F_p^x subset (A+A) union (AA)"
        ),
        "source_refutation": "Tang, Q. (2026), arXiv:2603.29992v2, Theorem 2.2",
        "corpus_pointer": (
            "corpus/live-fragile-proofs-2024-2026.md -- NOTE: the corpus doc's "
            "statement of the conjecture had the wrong density threshold "
            "(c*p rather than (1/2 - c)p); corrected 2026-09-21 against the "
            "pinned PDF"
        ),
        "local_pdf": "incoming/sarkozy-tang-2603.29992.pdf",
        "deep": deep,
        "path_a_exhaustive_search": {
            "primes_tested": primes,
            "per_prime": per_prime,
            "all_have_witness": all_have_witness,
            "all_cross_check_ok": all_cross_check_ok,
        },
        "path_b_tang_construction": {
            "primes_tested": construction_primes,
            "rows": construction,
            "all_ok": construction_ok,
            "max_density_attained": round(max_density, 6),
            "largest_c_refuted": round(largest_c_refuted, 8),
        },
        "paths_agree": paths_agree,
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": (
            "exists c>0, p_0: for all primes p>p_0 and all A subset F_p with "
            "|A| > (1/2 - c)p, F_p^x subset (A+A) union (AA)"
        ),
        "instance": (
            f"witness A with |A|=(p-1)/2 and 1 notin A*, exhibited by "
            f"exhaustive search for p in {primes} and by Tang's construction "
            f"for {len(construction_primes)} primes up to "
            f"{max(construction_primes)}"
        ),
        "false_instance": (
            f"at p={max(construction_primes)}, |A|={construction[-1]['A_size']} "
            f"= (p-1)/2, density {max_density:.6f}, and 1 notin (A+A) union "
            f"(AA) -- refuting every c > {largest_c_refuted:.8f}; Tang's "
            "Theorem 2.2 extends this to every odd prime, killing every c>0"
        ),
        "computed_scope_note": (
            "this gate exhibits witnesses only for the primes listed above; "
            "'no c>0 survives' is Tang's theorem, not this computation"
        ),
        "ok": ok,
    }
    out = RESULTS / "sarkozy_sum_product_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] sarkozy_sum_product")
    print("  path A -- exhaustive search (no input from Tang):")
    for row in per_prime:
        print(
            f"    p={row['p']:3d} k={row['k']:2d} witnesses={row['witness_count']:3d} "
            f"first={row['first_witness']} cross_check_ok={row['cross_check_ok']} "
            f"t={row['elapsed_s']}s"
        )
    print("  path B -- Tang's construction (pinned PDF, Section 2):")
    for row in construction:
        print(
            f"    p={row['p']:6d} delta={row['delta']} "
            f"6-cycles={row['six_cycle_count']:5d}/{row['expected_six_cycle_count']:5d} "
            f"|A|={row['A_size']:6d}/{row['A_size_expected']:6d} "
            f"avoids_1={row['avoids_one']} ok={row['ok']}"
        )
    print(f"  paths agree where both run: {paths_agree}")
    print(f"  max density attained: {max_density:.6f} "
          f"-> refutes every c > {largest_c_refuted:.8f}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
