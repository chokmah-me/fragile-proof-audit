"""Gate: Agoh–Giuga standing counterexample oracle (Phase 3(h)).

Verify the classical seven known Giuga numbers (OEIS A007850 terms 1–7) are
each Giuga and non-Carmichael (Korselt fails). Exact integer arithmetic only.

PASS  = all listed g satisfy Giuga ∧ ¬Carmichael (oracle ready; escalate).
BREAK = any listed g fails Giuga or satisfies Korselt.
"""

from __future__ import annotations

import json
import math
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

# OEIS A007850 terms 1–7 with pinned prime factorizations
# (Wikipedia / MathWorld / ProofWiki agree on this prefix).
KNOWN_GIUGA: list[tuple[int, tuple[int, ...]]] = [
    (30, (2, 3, 5)),
    (858, (2, 3, 11, 13)),
    (1722, (2, 3, 7, 41)),
    (66198, (2, 3, 11, 17, 59)),
    (2214408306, (2, 3, 11, 23, 31, 47057)),
    (24423128562, (2, 3, 7, 43, 3041, 4447)),
    (432749205173838, (2, 3, 7, 59, 163, 1381, 775807)),
]


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def giuga_checks(g: int, primes: tuple[int, ...]) -> list[dict]:
    """Per-prime witnesses for p | (g/p − 1)."""
    rows: list[dict] = []
    for p in primes:
        q = g // p - 1
        rows.append(
            {
                "p": p,
                "g_over_p_minus_1": q,
                "p_divides": q % p == 0,
            }
        )
    return rows


def korselt_checks(g: int, primes: tuple[int, ...]) -> list[dict]:
    """Per-prime witnesses for (p−1) | (g−1)."""
    rows: list[dict] = []
    for p in primes:
        rows.append(
            {
                "p": p,
                "p_minus_1": p - 1,
                "g_minus_1": g - 1,
                "divides": (g - 1) % (p - 1) == 0,
            }
        )
    return rows


def audit_one(g: int, primes: tuple[int, ...]) -> dict:
    product = math.prod(primes)
    primes_ok = all(is_prime(p) for p in primes)
    squarefree = len(primes) == len(set(primes)) and primes_ok
    factorization_ok = product == g and squarefree and g > 1

    g_rows = giuga_checks(g, primes)
    k_rows = korselt_checks(g, primes)
    is_giuga = factorization_ok and all(r["p_divides"] for r in g_rows)
    is_carmichael = factorization_ok and all(r["divides"] for r in k_rows)
    korselt_failing = [r["p"] for r in k_rows if not r["divides"]]

    ok = is_giuga and not is_carmichael
    return {
        "g": g,
        "primes": list(primes),
        "product": product,
        "factorization_ok": factorization_ok,
        "squarefree": squarefree,
        "giuga_checks": g_rows,
        "is_giuga": is_giuga,
        "korselt_checks": k_rows,
        "is_carmichael": is_carmichael,
        "korselt_failing_primes": korselt_failing,
        "giuga_and_not_carmichael": ok,
        "ok": ok,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    rows = [audit_one(g, primes) for g, primes in KNOWN_GIUGA]
    all_ok = all(r["ok"] for r in rows)
    break_route = not all_ok
    failing = [r["g"] for r in rows if not r["ok"]]

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": "3h",
        "gate": "giuga_oracle",
        "source": "OEIS A007850 terms 1–7; harvest §3.4 Agoh–Giuga genre kit",
        "citations": [
            "https://oeis.org/A007850",
            "corpus/fragile-formalizable-proofs-report.md §3.4",
            "https://carmamaths.org/jon/giuga2013.pdf",
        ],
        "criterion": {
            "giuga": "p | (g/p - 1) for every prime p | g",
            "korselt_carmichael": "(p-1) | (g-1) for every prime p | g",
            "oracle": "Giuga ∧ ¬Carmichael for each listed g",
        },
        "count": len(rows),
        "rows": rows,
        "failing_g": failing,
        "verdict": "PASS" if all_ok else "BREAK",
        "lemma": "known Giuga composites are Giuga and fail Korselt (standing oracle)",
        "instance": "OEIS A007850 terms 1–7 with pinned factorizations",
        "false_instance": None
        if all_ok
        else f"oracle broken at g in {failing}",
        "ok": all_ok,
        "break_route": break_route,
        "lean": "deferred — gate before prove; Lean Giuga/Korselt after green gate",
        "conjecture_claimed": False,
    }
    out = RESULTS / "giuga_oracle_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"[{'PASS' if all_ok else 'FAIL'}] giuga_oracle")
    for r in rows:
        status = "OK" if r["ok"] else "BAD"
        fail_p = r["korselt_failing_primes"]
        print(
            f"  [{status}] g={r['g']} giuga={r['is_giuga']} "
            f"carmichael={r['is_carmichael']} korselt_fail_p={fail_p}"
        )
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
