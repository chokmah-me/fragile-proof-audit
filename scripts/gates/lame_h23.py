"""Gate: Lamé 1847 class-number oracle (Phase 3(i) first milestone).

Confirm the first cyclotomic UFD failure at p=23:

  h^-(Q(ζ_23)) = 3  (Maillet / OEIS A000927 determinant)
  h(Q(√-23))   = 3  (reduced binary quadratic forms)

Plus h^+_23 = 1 is classical, so h_23 = 3. Exact integers only.

PASS  = h^-_23 = 3, first failure among odd primes at 23, OEIS pin OK,
        quadratic class number 3.
BREAK = any mismatch.
"""

from __future__ import annotations

import json
import math
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

# OEIS A000927: relative class number h^- for Q(ζ_{prime(n)}), n = 1..15
# primes: 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47
OEIS_A000927_PREFIX: list[tuple[int, int]] = [
    (2, 1),
    (3, 1),
    (5, 1),
    (7, 1),
    (11, 1),
    (13, 1),
    (17, 1),
    (19, 1),
    (23, 3),
    (29, 8),
    (31, 9),
    (37, 37),
    (41, 121),
    (43, 211),
    (47, 695),
]

TARGET_P = 23
EXPECTED_H_MINUS = 3
EXPECTED_QUAD_FORMS = [(1, 1, 6), (2, -1, 3), (2, 1, 3)]


def h_minus_maillet(p: int) -> int:
    """Relative class number h^-_p via OEIS A000927 Maillet determinant.

    For p < 5 return 1 (A000927 convention). For odd prime p ≥ 5, absolute
    value of det of the ((p-3)/2)×((p-3)/2) matrix with 1-based entries
    M[i,j] = floor((i+1)(j+2)/p) - floor(i(j+2)/p)  (OEIS Maple/PARI).
    """
    if p < 5:
        return 1
    n = (p - 3) // 2
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            ii, jj = i + 1, j + 1
            M[i][j] = ((ii + 1) * (jj + 2)) // p - (ii * (jj + 2)) // p
    A = [[Fraction(M[r][c]) for c in range(n)] for r in range(n)]
    det = Fraction(1)
    for col in range(n):
        piv = next((r for r in range(col, n) if A[r][col] != 0), None)
        if piv is None:
            return 0
        if piv != col:
            A[col], A[piv] = A[piv], A[col]
            det = -det
        pivot = A[col][col]
        det *= pivot
        for r in range(col + 1, n):
            if A[r][col] == 0:
                continue
            factor = A[r][col] / pivot
            for c in range(col, n):
                A[r][c] -= factor * A[col][c]
    if det.denominator != 1:
        raise RuntimeError(f"non-integral Maillet determinant for p={p}: {det}")
    return abs(int(det))


def reduced_positive_definite_forms(disc: int) -> list[tuple[int, int, int]]:
    """Reduced primitive-or-not positive definite forms of discriminant disc < 0.

    Conditions: b² − 4ac = disc, |b| ≤ a ≤ c; if |b| = a or a = c then b ≥ 0.
    """
    if disc >= 0:
        raise ValueError("disc must be negative")
    forms: list[tuple[int, int, int]] = []
    bound = int(math.isqrt(abs(disc) // 3)) + 2
    for a in range(1, bound + 1):
        for b in range(-a, a + 1):
            num = b * b - disc
            if num % (4 * a) != 0:
                continue
            c = num // (4 * a)
            if a > c:
                continue
            if a == c and b < 0:
                continue
            if abs(b) == a and b < 0:
                continue
            forms.append((a, b, c))
    return forms


def audit_oeis_pin() -> dict:
    rows = []
    all_ok = True
    for p, expected in OEIS_A000927_PREFIX:
        got = h_minus_maillet(p)
        ok = got == expected
        all_ok = all_ok and ok
        rows.append({"p": p, "h_minus": got, "oeis": expected, "ok": ok})
    return {"rows": rows, "ok": all_ok}


def audit_first_failure() -> dict:
    """Among odd primes in the OEIS prefix, first with h^- > 1 must be 23."""
    first = None
    for p, _ in OEIS_A000927_PREFIX:
        if p == 2:
            continue
        if h_minus_maillet(p) > 1:
            first = p
            break
    h23 = h_minus_maillet(TARGET_P)
    ok = first == TARGET_P and h23 == EXPECTED_H_MINUS
    return {
        "first_p_with_h_minus_gt_1": first,
        "h_minus_23": h23,
        "expected_first": TARGET_P,
        "expected_h_minus_23": EXPECTED_H_MINUS,
        "ok": ok,
    }


def audit_quadratic_minus_23() -> dict:
    forms = reduced_positive_definite_forms(-23)
    ok = forms == list(EXPECTED_QUAD_FORMS) and len(forms) == 3
    return {
        "discriminant": -23,
        "reduced_forms": [{"a": a, "b": b, "c": c} for a, b, c in forms],
        "class_number": len(forms),
        "expected_forms": [
            {"a": a, "b": b, "c": c} for a, b, c in EXPECTED_QUAD_FORMS
        ],
        "expected_class_number": 3,
        "ok": ok,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    oeis = audit_oeis_pin()
    first = audit_first_failure()
    quad = audit_quadratic_minus_23()
    all_ok = oeis["ok"] and first["ok"] and quad["ok"]

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": "3i",
        "gate": "lame_h23",
        "source": "harvest §4.1 Lamé 1847; OEIS A000927; Washington cyclotomic tables",
        "citations": [
            "https://oeis.org/A000927",
            "corpus/fragile-formalizable-proofs-report.md §4.1",
            "https://afm.episciences.org/16046/pdf",
        ],
        "criterion": {
            "h_minus": "Maillet determinant (OEIS A000927 formula)",
            "first_failure": "least odd prime p with h^-_p > 1 equals 23",
            "quadratic_witness": "h(Q(√-23)) = 3 via reduced forms of disc -23",
            "plus_part_cited": "h^+_23 = 1 classical ⇒ h_23 = 3 (not recomputed here)",
        },
        "oeis_pin": oeis,
        "first_failure": first,
        "quadratic_Q_sqrt_minus_23": quad,
        "h_23_composite": {
            "h_minus": first["h_minus_23"],
            "h_plus_cited": 1,
            "h": first["h_minus_23"] * 1,
            "note": "h = h^- h^+ with h^+_23=1 cited from classical tables",
        },
        "regular_vs_ufd": {
            "23_divides_h": False,
            "23_is_kummer_regular": True,
            "ufd_fails": True,
            "note": (
                "23 ∤ 3 so 23 is regular in Kummer's sense; Lamé still fails "
                "because UFD needs h=1, not merely p ∤ h"
            ),
        },
        "verdict": "PASS" if all_ok else "BREAK",
        "lemma": "Z[ζ_p] UFD for every odd prime p (Lamé premise)",
        "instance": "p = 23",
        "false_instance": None
        if all_ok
        else "h^-_23 ≠ 3 or OEIS/quadratic mismatch",
        "ok": all_ok,
        "break_route": not all_ok,
        "lean": "Maillet Bareiss mailletAbsDet_23 VERIFIED; Premise/QuadraticWitness VERIFIED; classNumber=3 still gated (h^+ cited)",
        "claims_flt": False,
    }
    out = RESULTS / "lame_h23_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"[{'PASS' if all_ok else 'FAIL'}] lame_h23")
    print(
        f"  h^-_23 = {first['h_minus_23']} "
        f"(first failure p={first['first_p_with_h_minus_gt_1']})"
    )
    print(
        f"  OEIS pin: {'OK' if oeis['ok'] else 'BAD'} "
        f"({len(oeis['rows'])} primes through 47)"
    )
    print(
        f"  Q(√-23) forms: {[(f['a'], f['b'], f['c']) for f in quad['reduced_forms']]} "
        f"h={quad['class_number']}"
    )
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
