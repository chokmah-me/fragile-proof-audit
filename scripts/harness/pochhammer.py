"""Rising factorial (Pochhammer) with Gasper–Rahman negative-index convention.

Convention (mandatory for every WZ / hypergeometric gate in this campaign):

- (a)_0 = 1
- (a)_n = a(a+1)…(a+n-1) for n > 0
- (a)_{-n} = (-1)^n / (1-a)_n for n > 0
- singularity convention used in the Jana–Karmakar audit:
  1/(1)_m := 0 for m ≤ -1

Omitting the negative-index rule produced 66 false mismatches in that audit.
Gate code must itself be refutable: every failed gate ships with this harness.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Union

Number = Union[int, Fraction]


def _as_fraction(a: Number) -> Fraction:
    return a if isinstance(a, Fraction) else Fraction(a)


def rising_factorial(a: Number, n: int) -> Fraction:
    """Exact rising factorial (a)_n for any integer n."""
    if not isinstance(n, int):
        raise TypeError(f"n must be int, got {type(n).__name__}")
    a = _as_fraction(a)
    if n == 0:
        return Fraction(1)
    if n > 0:
        out = Fraction(1)
        for i in range(n):
            out *= a + i
        return out
    # n = -m with m > 0: (a)_{-m} = (-1)^m / (1-a)_m
    m = -n
    denom = rising_factorial(1 - a, m)
    if denom == 0:
        raise ZeroDivisionError(
            f"rising_factorial({a}, {n}) undefined: (1-a)_m = 0 with m={m}"
        )
    return (Fraction(-1) ** m) / denom


def inv_rising_at_one(m: int) -> Fraction:
    """1/(1)_m with singularity convention: 0 for m ≤ -1."""
    if m <= -1:
        return Fraction(0)
    return 1 / rising_factorial(1, m)


def rising_factorial_naive_positive_only(a: Number, n: int) -> Fraction:
    """Broken convention used only as a regression foil (positive n or 0).

    For n < 0 this raises — simulating harnesses that omit the negative-index rule.
    """
    if n < 0:
        raise ValueError(
            "naive harness rejects negative n (this is the bug that caused "
            "66 false mismatches in the Jana–Karmakar audit)"
        )
    return rising_factorial(a, n)
