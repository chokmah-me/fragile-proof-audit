#!/usr/bin/env python3
"""Effectivity screen for "unconditional via QRH(delta)" claims.

Origin: check A6 of the Frei-Sofos-Widmer audit (arXiv:2610.18491v2,
docs/audits/frei-sofos-widmer.md). Generalized 2026-10-20 into a
triage gate for the harvest loop; see docs/harvest-loop.md,
"Effectivity screen for QRH-instantiated claims".

The pattern it screens: a proof makes a bound unconditional by citing
a zero-free region QRH(delta) (Dedekind zeta, Re s > 1 - delta) and
consuming it through an effective Chebotarev / prime-splitting step
whose prime supply is only delivered above a threshold of the shape

    x >= c * (log D)^(a/delta) * (log log D)^(b/delta)

while the consuming argument needs primes at norm <= D^eta. The
instantiated bound then has effective content only for discriminants
D large enough that the threshold drops below D^eta. This script
computes that crossover: the smallest log10(D) from which

    log c + (a/delta) * ln t + (b/delta) * ln ln t  <=  eta * t,
    t = ln D,

holds for every larger t. Domain is t >= e (ln ln t >= 0); below that
the threshold shape is degenerate and no claim lives there.

The screen measures effective content, not truth: an asymptotic
statement can be true with an astronomically large implied constant.
A NIL flag caps what the instantiation can mean in practice and
belongs on the recon card; it is not a verdict on the claim.

Defaults (a=1, b=2, c=1) are the FSW shape with the constant set to
its most favorable possible value: c=1 is a best case the screened
paper usually does not supply, so every crossover reported is a
lower bound on the true one.

Usage:
    qrh_effectivity_screen.py --delta 1/6000 --eta 0.125
    qrh_effectivity_screen.py --delta 0.96875 --eta 0.125 --c 10
    qrh_effectivity_screen.py --fsw-grid     # regression self-test
"""

from __future__ import annotations

import argparse
import math
import sys

LN10 = math.log(10.0)
T_MIN = math.e  # ln ln t >= 0


def f(t: float, delta: float, eta: float, a: float, b: float, log_c: float) -> float:
    """eta*t minus log-threshold. Positive means the threshold is met."""
    return eta * t - (a / delta) * math.log(t) - (b / delta) * math.log(math.log(t)) - log_c


def crossover_log10(delta: float, eta: float, a: float = 1.0, b: float = 2.0,
                    c: float = 1.0) -> float | None:
    """Smallest log10(D) such that the threshold is met for all larger D.

    Returns None if the threshold is not met even at the scan cap.
    On t >= e the derivative of f increases toward eta > 0, so f dips
    at most once; scan multiplicatively, bisect the LAST sign change
    from - to +. If f is already >= 0 at the domain floor and never
    dips, the crossover is the floor.
    """
    log_c = math.log(c)
    cap = 1e13
    last_cross: tuple[float, float] | None = None
    prev_t = T_MIN
    prev_f = f(prev_t, delta, eta, a, b, log_c)
    t = T_MIN
    while t < cap:
        nxt = t * 1.5 + 1.0
        nf = f(nxt, delta, eta, a, b, log_c)
        if prev_f < 0 <= nf:
            last_cross = (prev_t, nxt)
        prev_t, prev_f = nxt, nf
        t = nxt
    if last_cross is None:
        return T_MIN / LN10 if prev_f >= 0 and f(T_MIN, delta, eta, a, b, log_c) >= 0 else None
    lo, hi = last_cross
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if f(mid, delta, eta, a, b, log_c) < 0:
            lo = mid
        else:
            hi = mid
    return hi / LN10


def classify(log10_d: float | None) -> str:
    """Bands are in digits of D: the crossover log10 D IS the digit count."""
    if log10_d is None:
        return "NIL (no crossover below the scan cap; no effective content at any writable size)"
    if log10_d <= 100:
        return "EFFECTIVE at realistic sizes (crossover within 100-digit discriminants)"
    if log10_d <= 10000:
        return "LARGE-ONLY (crossover between 100-digit and 10,000-digit discriminants)"
    return "NIL at realistic sizes (crossover past a 10,000-digit discriminant)"


def parse_number(s: str) -> float:
    if "/" in s:
        num, den = s.split("/", 1)
        return float(num) / float(den)
    return float(s)


# Expected crossovers (log10 D) from the FSW audit, delta = 1/6000,
# c = 1, a = 1, b = 2; eta = 1/(2*l*(d-1)). audit-work/paper-math.md.
FSW_GRID = {
    (2, 3): 395225, (2, 4): 608253, (2, 5): 825518, (2, 6): 1045923,
    (3, 3): 608253, (3, 4): 935375, (3, 5): 1268823, (3, 6): 1606958,
    (4, 3): 825518, (4, 4): 1268823, (4, 5): 1720535, (4, 6): 2178480,
    (5, 3): 1045923, (5, 4): 1606958, (5, 5): 2178480, (5, 6): 2757773,
}


def fsw_grid() -> int:
    worst = 0.0
    bad = 0
    for (ell, d), expected in sorted(FSW_GRID.items()):
        eta = 1.0 / (2 * ell * (d - 1))
        got = crossover_log10(1.0 / 6000.0, eta)
        diff = abs(got - expected)
        worst = max(worst, diff)
        status = "ok" if diff <= 2 else "MISMATCH"
        if diff > 2:
            bad += 1
        print(f"l={ell} d={d} eta={eta:.4f}  crossover log10 D = {got:,.0f} "
              f"(audit: {expected:,}, diff {diff:.1f})  {status}")
    print(f"\nworst diff: {worst:.1f} log10 units (tolerance 2)")
    if bad:
        print(f"SELF-TEST FAIL: {bad} cells mismatch")
        return 1
    print("SELF-TEST PASS: grid reproduces the FSW audit (A6)")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--delta", type=parse_number,
                    help="cited zero-free width, e.g. 1/6000 or 0.03125")
    ap.add_argument("--eta", type=parse_number,
                    help="exponent at which primes are needed (norm <= D^eta)")
    ap.add_argument("--a", type=float, default=1.0,
                    help="threshold exponent numerator on log D (default 1)")
    ap.add_argument("--b", type=float, default=2.0,
                    help="threshold exponent numerator on log log D (default 2)")
    ap.add_argument("--c", type=float, default=1.0,
                    help="threshold constant (default 1, a best case)")
    ap.add_argument("--fsw-grid", action="store_true",
                    help="regression self-test against the FSW audit grid")
    args = ap.parse_args()

    if args.fsw_grid:
        return fsw_grid()
    if args.delta is None or args.eta is None:
        ap.error("--delta and --eta are required (or pass --fsw-grid)")
    if not (0 < args.delta <= 0.5):
        print("warning: delta outside (0, 1/2]; QRH(delta) is stated for delta <= 1/2",
              file=sys.stderr)
    if args.eta <= 0:
        ap.error("--eta must be positive")
    if args.c <= 0:
        ap.error("--c must be positive")

    got = crossover_log10(args.delta, args.eta, args.a, args.b, args.c)
    print(f"delta = {args.delta:g}  eta = {args.eta:g}  a = {args.a:g}  "
          f"b = {args.b:g}  c = {args.c:g} (c=1 is a best case)")
    if got is None:
        print("crossover log10 D: none below scan cap")
    else:
        print(f"crossover log10 D = {got:,.1f}")
    print(f"classification: {classify(got)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
