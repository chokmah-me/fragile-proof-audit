"""Fraction-first exact arithmetic helpers for campaign gates."""

from __future__ import annotations

from fractions import Fraction
from typing import Iterable, Union

try:
    from mpmath import mp
except ImportError:  # pragma: no cover - declared in requirements.txt
    mp = None

Number = Union[int, Fraction]


def frac(x: Number | str) -> Fraction:
    return x if isinstance(x, Fraction) else Fraction(x)


def abs_frac(x: Number) -> Fraction:
    x = frac(x)
    return x if x >= 0 else -x


def to_mpf(x: Number, *, dps: int = 50):
    """Promote a Fraction to mpmath.mpf at explicit precision."""
    if mp is None:
        raise ImportError("mpmath is required for to_mpf; pip install -r requirements.txt")
    mp.dps = dps
    x = frac(x)
    return mp.mpf(x.numerator) / mp.mpf(x.denominator)


def almost_equal_frac(a: Number, b: Number, *, tol: Fraction = Fraction(0)) -> bool:
    """Exact equality when tol=0; otherwise |a-b| ≤ tol."""
    return abs_frac(frac(a) - frac(b)) <= frac(tol)


def sum_frac(xs: Iterable[Number]) -> Fraction:
    total = Fraction(0)
    for x in xs:
        total += frac(x)
    return total
