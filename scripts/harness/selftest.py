"""Self-tests for the campaign harness.

Includes a regression fixture documenting the Jana–Karmakar lesson:
omitting (a)_{-n} = (-1)^n / (1-a)_n produces false mismatches.
"""

from __future__ import annotations

import sys
from fractions import Fraction
from pathlib import Path

# Allow `python scripts/harness/selftest.py` from repo root or this dir.
_ROOT = Path(__file__).resolve().parents[2]
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from scripts.harness.pochhammer import (  # noqa: E402
    inv_rising_at_one,
    rising_factorial,
    rising_factorial_naive_positive_only,
)
from scripts.harness.exact import abs_frac, almost_equal_frac, frac  # noqa: E402


def _assert(cond: bool, msg: str) -> None:
    if not cond:
        raise AssertionError(msg)


def test_pochhammer_basic() -> None:
    _assert(rising_factorial(3, 0) == 1, "(a)_0 = 1")
    _assert(rising_factorial(3, 1) == 3, "(3)_1 = 3")
    _assert(rising_factorial(3, 2) == 12, "(3)_2 = 3·4 = 12")
    _assert(rising_factorial(Fraction(1, 2), 2) == Fraction(1, 2) * Fraction(3, 2), "(1/2)_2")


def test_negative_index_gasper_rahman() -> None:
    # (a)_{-1} = (-1) / (1-a)_1 = -1 / (1-a)
    a = Fraction(3)
    got = rising_factorial(a, -1)
    expect = Fraction(-1) / (1 - a)
    _assert(got == expect, f"(3)_{{-1}}: got {got}, expect {expect}")

    # (2)_{-2} = (+1) / (1-2)_2 = 1 / ((-1)·0) → undefined; use a=5
    a = Fraction(5)
    got = rising_factorial(a, -2)
    # (-1)^2 / (1-5)_2 = 1 / ((-4)·(-3)) = 1/12
    expect = Fraction(1, 12)
    _assert(got == expect, f"(5)_{{-2}}: got {got}, expect {expect}")


def test_singularity_inv_at_one() -> None:
    _assert(inv_rising_at_one(-3) == 0, "1/(1)_m = 0 for m ≤ -1")
    _assert(inv_rising_at_one(-1) == 0, "1/(1)_{-1} = 0")
    _assert(inv_rising_at_one(0) == 1, "1/(1)_0 = 1")
    _assert(inv_rising_at_one(2) == Fraction(1, 2), "1/(1)_2 = 1/2")


def test_naive_harness_rejects_negative() -> None:
    """Regression foil: the broken harness that caused 66 false mismatches."""
    try:
        rising_factorial_naive_positive_only(5, -1)
    except ValueError as e:
        _assert("66 false mismatches" in str(e) or "negative" in str(e).lower(), str(e))
    else:
        raise AssertionError("naive harness should reject negative n")


def test_identity_survives_negative_slots() -> None:
    """Toy telescoping check that needs negative-index evaluation.

    F(n,k) style sample: compare (k)_{-1} terms that a naive harness cannot see.
    If the negative-index convention is wrong, left ≠ right.
    """
    # Identity: (a)_{-1} * (1-a) = -1 for a ≠ 1
    for a in [Fraction(2), Fraction(3), Fraction(7, 3), Fraction(-1)]:
        left = rising_factorial(a, -1) * (1 - a)
        _assert(left == Fraction(-1), f"identity fail at a={a}: {left}")


def test_exact_helpers() -> None:
    _assert(frac(2) == Fraction(2), "frac int")
    _assert(abs_frac(Fraction(-3, 2)) == Fraction(3, 2), "abs_frac")
    _assert(almost_equal_frac(1, 1), "exact equal")
    _assert(not almost_equal_frac(1, 2), "exact unequal")


def main() -> int:
    tests = [
        test_pochhammer_basic,
        test_negative_index_gasper_rahman,
        test_singularity_inv_at_one,
        test_naive_harness_rejects_negative,
        test_identity_survives_negative_slots,
        test_exact_helpers,
    ]
    failed = 0
    for t in tests:
        try:
            t()
            print(f"PASS  {t.__name__}")
        except Exception as e:  # noqa: BLE001 — report and continue
            failed += 1
            print(f"FAIL  {t.__name__}: {e}")
    if failed:
        print(f"\n{failed}/{len(tests)} failed")
        return 1
    print(f"\n{len(tests)}/{len(tests)} passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
