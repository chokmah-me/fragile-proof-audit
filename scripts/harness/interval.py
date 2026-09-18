"""Outward-rounded interval arithmetic for decay gates (Phase 2(d)).

Uses mpmath.mpi when available. Every bound is treated as closed.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Union

try:
    from mpmath import mp, mpi
except ImportError:  # pragma: no cover
    mp = None
    mpi = None

Number = Union[int, float, Fraction]


@dataclass(frozen=True)
class Interval:
    """Closed real interval [lo, hi] with lo ≤ hi, stored as mpf endpoints."""

    lo: object
    hi: object

    def __post_init__(self):
        if self.lo > self.hi:
            raise ValueError(f"empty interval: [{self.lo}, {self.hi}]")

    @property
    def width(self):
        return self.hi - self.lo

    def contains(self, x: Number) -> bool:
        if mp is None:
            raise ImportError("mpmath required")
        xv = mp.mpf(x) if not isinstance(x, Fraction) else mp.mpf(x.numerator) / mp.mpf(x.denominator)
        return self.lo <= xv <= self.hi

    def __abs__(self) -> "Interval":
        # Image of [lo,hi] under abs, outward.
        candidates = [abs(self.lo), abs(self.hi)]
        if self.lo < 0 < self.hi:
            candidates.append(mp.mpf(0))
        return Interval(min(candidates), max(candidates))


def interval(lo: Number, hi: Number, *, dps: int = 50) -> Interval:
    if mp is None or mpi is None:
        raise ImportError("mpmath is required for interval; pip install -r requirements.txt")
    mp.dps = dps
    # mpi does outward rounding for operations; construct from endpoints.
    box = mpi(lo, hi)
    return Interval(box.a, box.b)


def from_mpf(x, *, rad: Number = 0, dps: int = 50) -> Interval:
    """Point interval, optionally fattened by rad (outward)."""
    if mp is None:
        raise ImportError("mpmath required")
    mp.dps = dps
    r = mp.mpf(rad)
    return Interval(mp.mpf(x) - r, mp.mpf(x) + r)
