"""Investigative scan (instrument, NOT a gate) -- exhaustive check of Lemma
25's own printed inequality, not the Q^{[1]} congruence step already locked
BREAK in scripts/gates/krr_cl.py.

Motivation. Fragile-Route_Harvest_Dossier_II.md, Hit 3 ("Next options" item
2) proposes a bigger deliverable than the point-witness BREAK already landed:
extract the composition lemma's own claimed inequality verbatim,

    score(f^2) <= score(f)   for all f in the semigroup {h(0)=0, h(i)<i}
                              with diameter(G_f) >= 3,

where score(h) := max_{sigma in S_n} |{|sigma h sigma^{-1}(i) - i| : i in
Z_n}| (already implemented as `score()` in scripts/gates/krr_cl.py -- reused
here, not reimplemented), and run it exhaustively on all trees n = 5..9,
scored F=9 Fr=8 R=9 -- the highest reproducibility score anywhere in that
dossier.

RESULT OF ACTUALLY BUILDING IT: this check is vacuous at every n this laptop
can reach, and structurally cannot become non-vacuous at any n a brute-force
enumerator could ever reach. score(h) saturates at the ceiling n for EVERY
one of the 24+120+720+5038 = 5902 trees checked (n=5..8) -- i.e. every tree
this small is already known gracefully labelable (the classical graceful
tree conjecture is independently verified computationally for all trees up
to several dozen vertices, long before this campaign). Since score(f) = n =
score(f^2) on every instance, the inequality score(f^2) <= score(f) reads
n <= n and cannot fail regardless of whether Lemma 25's proof is correct.
The REVERSE inequality (score(f) <= score(f^2)) is equally satisfied for the
same reason -- this check cannot discriminate a true composition lemma from
a false one anywhere brute-force enumeration can reach, because (n-1)! trees
at the n where graceful-labeling first becomes genuinely open (well beyond
30 vertices) is astronomically out of reach for this laptop.

This is exactly the check-that-cannot-fail trap
Governing discipline #7 (docs/GATE-BEFORE-PROVE.md) exists to catch. It is
NOT registered in scripts/gates/check.py and carries no verdict: it is a
negative methodological result about the dossier's own R=9 score for this
item, not a finding about the paper. The genuinely decisive, already-landed
check of this lemma's actual load-bearing content remains the Q^{[1]}
congruence proof-step BREAK in scripts/gates/krr_cl.py -- this scan
confirms (does not replace) that the narrower point-witness strategy was
the informative one, not a fallback from a bigger check the campaign failed
to build.
"""

from __future__ import annotations

import json
import sys
import time
from datetime import datetime, timezone
from itertools import permutations, product
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"


def diameter(f: tuple[int, ...]) -> int:
    n = len(f)
    adj: list[list[int]] = [[] for _ in range(n)]
    for i, j in enumerate(f):
        if i != j:
            adj[i].append(j)
            adj[j].append(i)

    def far(start: int) -> int:
        dist = [-1] * n
        dist[start] = 0
        queue = [start]
        for u in queue:
            for v in adj[u]:
                if dist[v] < 0:
                    dist[v] = dist[u] + 1
                    queue.append(v)
        return max(dist)

    return max(far(i) for i in range(n))


def score(h: tuple[int, ...]) -> int:
    """max_sigma |{|sigma h sigma^-1(i) - i| : i}|, identical to
    scripts/gates/krr_cl.py's score() -- duplicated (not imported) to keep
    this instrument standalone and independently auditable."""
    n = len(h)
    best = 1
    for sigma in permutations(range(n)):
        inverse = [0] * n
        for i, label in enumerate(sigma):
            inverse[label] = i
        diffs = {abs(sigma[h[inverse[i]]] - i) for i in range(n)}
        if len(diffs) > best:
            best = len(diffs)
            if best == n:
                return n
    return best


def compose2(f: tuple[int, ...]) -> tuple[int, ...]:
    return tuple(f[f[i]] for i in range(len(f)))


def semigroup(n: int):
    ranges = [range(i) for i in range(1, n)]
    for tail in product(*ranges):
        yield (0,) + tail


def scan(n_max: int) -> dict:
    per_n = []
    for n in range(5, n_max + 1):
        t0 = time.time()
        checked = 0
        score_values: set[int] = set()
        violations = []
        reverse_violations = []
        for f in semigroup(n):
            if diameter(f) < 3:
                continue
            checked += 1
            f2 = compose2(f)
            sf, sf2 = score(f), score(f2)
            score_values.add(sf)
            score_values.add(sf2)
            if sf2 > sf:
                violations.append({"f": f, "f2": f2, "score_f": sf, "score_f2": sf2})
            if sf < sf2:
                reverse_violations.append({"f": f, "f2": f2, "score_f": sf, "score_f2": sf2})
        per_n.append(
            {
                "n": n,
                "trees_checked": checked,
                "elapsed_s": round(time.time() - t0, 3),
                "distinct_score_values_seen": sorted(score_values),
                "always_saturates_at_n": score_values == {n},
                "inequality_violations": len(violations),
                "reverse_inequality_violations": len(reverse_violations),
            }
        )
    return {"per_n": per_n, "n_max": n_max}


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    deep = "--deep" in sys.argv
    n_max = 9 if deep else 8

    result = scan(n_max)
    vacuous_throughout = all(row["always_saturates_at_n"] for row in result["per_n"])
    any_violation = any(row["inequality_violations"] > 0 for row in result["per_n"])

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "instrument": "krr_cl_composition_scan",
        "target_claim": (
            "Lemma 25's printed inequality max_sigma-cardinality(f^2) <= "
            "max_sigma-cardinality(f) for f in the semigroup with diameter>=3"
        ),
        "corpus_pointer": (
            "corpus/Fragile-Route_Harvest_Dossier_II.md, Hit 3 'Next options' item 2 "
            "(scored F=9 Fr=8 R=9 -- the enumerator this dossier rated highest-value)"
        ),
        "per_n": result["per_n"],
        "vacuous_throughout_tested_range": vacuous_throughout,
        "any_counterexample_found": any_violation,
        "conclusion": (
            "CHECK-THAT-CANNOT-FAIL (Governing discipline #7): score(f) saturates at the "
            "ceiling n for every tree n=5..%d, so the inequality reads n<=n regardless of "
            "Lemma 25's correctness. This is structural, not a depth limit -- the graceful "
            "tree conjecture is independently known for far larger n than brute-force "
            "enumeration can ever reach, so this design can never become discriminating. "
            "Does not confirm or refute Lemma 25 or the KRR conjecture. Does not supersede "
            "the already-landed krr_cl Q^[1]-congruence BREAK, which remains the decisive "
            "finding on this target." % n_max
        ),
        "verdict": "NOT_APPLICABLE_TAUTOLOGY",
        "note": "Instrument only. Not registered in scripts/gates/check.py; no lock row.",
    }
    out = RESULTS / "krr_cl_composition_scan_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print("[INFO] krr_cl_composition_scan")
    for row in result["per_n"]:
        print(
            f"  n={row['n']}: trees={row['trees_checked']} "
            f"scores_seen={row['distinct_score_values_seen']} "
            f"saturates_at_n={row['always_saturates_at_n']} "
            f"violations={row['inequality_violations']} time={row['elapsed_s']}s"
        )
    print(f"  conclusion: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
