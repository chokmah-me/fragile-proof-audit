"""Numeric gate: Agama Theorem 2.3 has no fixed C(l_0).

Source: arXiv:1707.03265v4, Theorem 2.3 (incoming/agama-twin-1707.03265v4.pdf).

    Let f: N -> R+. If sum_{n<=x} f(n)f(n+l_0) > 0, then there exists
    C = C(l_0) > 0 fixed such that
        sum_{n<=x} f(n)f(n+l_0)
            >= (1/(C x)) * sum_{2<=n<=x} f(n) * sum_{m<=n-1} f(m).

"Fixed" is the reading Theorem 3.1 uses: one D(2) in an asymptotic as
x -> infinity. A C that may grow with x does not yield that lower bound.

The harvest dossier's witness (f = 1_{3|n}, x=12, l_0=1) has correlation 0,
so it sits outside the hypothesis. It is checked here only to record that.
The break is the repaired f below, for which the correlation is the positive
constant 2 and the ratio still unbounded.

Gates refute routes, not theorems. Twin primes may still be infinite.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass


def repaired(n: int) -> int:
    """1 on {1, 2} and on the positive multiples of 3; 0 elsewhere."""
    if n in (1, 2) or n % 3 == 0:
        return 1
    return 0


def multiples_of_3(n: int) -> int:
    """Dossier witness. Correlation at shift 1 is identically 0."""
    return 1 if n % 3 == 0 else 0


def ones(n: int) -> int:
    return 1


def correlation(f, x: int, shift: int) -> int:
    return sum(f(n) * f(n + shift) for n in range(1, x + 1))


def quadratic(f, x: int) -> int:
    """sum_{2<=n<=x} f(n) * sum_{m<=n-1} f(m)."""
    total = 0
    prefix = 0
    for n in range(1, x + 1):
        if n >= 2:
            total += f(n) * prefix
        prefix += f(n)
    return total


def double_sum(f, x: int) -> int:
    """Corollary 2.2 left-hand side: sum_{n<=x-1} sum_{j<=x-n} f(n)f(n+j)."""
    total = 0
    for n in range(1, x):
        for j in range(1, x - n + 1):
            total += f(n) * f(n + j)
    return total


def closed_quadratic(x: int) -> int:
    """Q(x) = 1 + T(T+3)/2 for the repaired f, T = floor(x/3), x >= 2."""
    tee = x // 3
    return 1 + tee * (tee + 3) // 2


def main() -> int:
    identity_points = (4, 7, 10, 12, 30)
    identity_ok = all(
        double_sum(f, x) == quadratic(f, x)
        for f in (repaired, multiples_of_3, ones)
        for x in identity_points
    )

    dossier_s = correlation(multiples_of_3, 12, 1)
    dossier_q = quadratic(multiples_of_3, 12)
    dossier_outside = dossier_s == 0 and dossier_q == 6

    witness_x = (12, 30, 36, 300, 3000)
    rows = []
    closed_ok = True
    for x in witness_x:
        ess = correlation(repaired, x, 1)
        queue = quadratic(repaired, x)
        closed = closed_quadratic(x)
        if ess != 2 or queue != closed:
            closed_ok = False
        rows.append(
            {
                "x": x,
                "S": ess,
                "Q": queue,
                "Q_closed": closed,
                "ratio_Q_over_xS": queue / (x * ess),
            }
        )

    # C = 1 fails as soon as Q > x * S. Smallest checked x with that is 30.
    fails_c1 = next(row for row in rows if row["x"] == 30)
    c1_fails = fails_c1["Q"] > fails_c1["x"] * fails_c1["S"]
    by_x = {row["x"]: row["ratio_Q_over_xS"] for row in rows}
    grows = by_x[3000] > by_x[300] > by_x[30] > 1

    # f = 1: S = x, Q = x(x-1)/2, so x*S - Q = x(x+1)/2 > 0. C = 1 works.
    ones_x = 1000
    ones_s = correlation(ones, ones_x, 1)
    ones_q = quadratic(ones, ones_x)
    ones_holds = ones_s == ones_x and ones_q == ones_x * (ones_x - 1) // 2
    ones_holds = ones_holds and ones_x * ones_s > ones_q

    ok = (
        identity_ok
        and dossier_outside
        and closed_ok
        and c1_fails
        and grows
        and ones_holds
    )
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "target": "tpc_area",
        "source": "arXiv:1707.03265v4",
        "local_pdf": "incoming/agama-twin-1707.03265v4.pdf",
        "lemma": (
            "Theorem 2.3: for f: N->R+ and l_0 fixed, one C(l_0) independent "
            "of x satisfies S(x,l_0) >= Q(x)/(C x) whenever S(x,l_0)>0"
        ),
        "instance": "f = 1 on {1,2} union 3N, l_0 = 1, S(x,1) = 2 for x >= 2",
        "false_instance": (
            "Q(x) = 1 + T(T+3)/2, T=floor(x/3). At x=30, Q=66 > 60 = x*S, "
            "so C=1 fails; ratio ~ x/36 is unbounded, so no finite fixed C works"
        ),
        "dossier_witness_outside_hypothesis": {
            "f": "1 on multiples of 3",
            "x": 12,
            "l0": 1,
            "S": dossier_s,
            "Q": dossier_q,
            "used_as_break": False,
        },
        "identity_corollary_2_2": {"x": list(identity_points), "matches": identity_ok},
        "repaired_rows": rows,
        "ones_control_embedded": {
            "x": ones_x,
            "S": ones_s,
            "Q": ones_q,
            "C1_holds": ones_holds,
        },
        "verdict": "BREAK" if ok else "ABORT",
        "ok": ok,
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / "tpc_area_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{'PASS' if ok else 'FAIL'}] tpc_area")
    print(f"  dossier S,Q at x=12: {dossier_s}, {dossier_q} (outside hypothesis)")
    print(f"  repaired x=30: S={fails_c1['S']} Q={fails_c1['Q']} (C=1 fails: {c1_fails})")
    print(f"  repaired x=3000 ratio={rows[-1]['ratio_Q_over_xS']}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
