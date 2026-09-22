"""Instrument for Kawasaki arXiv:2502.20642v2. Not a lock row.

The harvest dossier (COL-FP) test-fired a Banach contraction of the accelerated
Collatz map T under |x-y| and reported BREAK because odd pairs expand by 3/2.
v2 never claims that contraction. It claims Theorem 3.1: T is an
(alpha,...,zeta)-weighted generalized pseudocontraction, then Remark 3.1
records that the hypotheses of Theorems 2.2 and 2.3 fail for the lambda it
tries. There is no Collatz conclusion to refute.

This script checks three facts and writes results/col_fp_meta.json:

  * dossier object: |T(2k+1)-T(2l+1)| / |(2k+1)-(2l+1)| = 3/2
  * Theorem 3.1 inequality on every pair in 1..SWEEP_N (a finite sweep, not
    a proof of the universal claim)
  * Theorem 2.3(5) at lambda = 1, read off Lemma 2.2, fails at (1, 3)
    because the only live branch has ratio 3/2, so no A in (0, 1) works

Verdict VACUOUS means: do not pin EXPECTED_VERDICT. A positive weighted sum
flips the receipt to THEOREM_31_POSITIVE and exits 1, so a later real
counterexample to Theorem 3.1 cannot hide inside this instrument.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
SWEEP_N = 256
DOSSIER_PAIRS = ((3, 5), (5, 7), (7, 9), (3, 9), (9, 11))

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass


def accelerated(x: int) -> int:
    """T as on PDF p. 7: T(1)=1, T(even)=x/2, T(odd>=3)=(3x+1)/2."""
    if x == 1:
        return 1
    if x % 2 == 0:
        return x // 2
    if x >= 3:
        return (3 * x + 1) // 2
    raise ValueError(x)


def coefficients(x: int, y: int) -> tuple[int, int, int, int, int, int]:
    """(alpha, beta, gamma, delta, epsilon, zeta) from Theorem 3.1, PDF pp. 7-8."""
    if x >= 3 and y >= 3 and x % 2 == 1 and y % 2 == 1:
        k = (x - 1) // 2
        ell = (y - 1) // 2
        gap = k - ell
        if gap <= -2:
            beta0 = -2
        elif abs(gap) <= 1:
            beta0 = gap
        else:
            beta0 = 2
        left = gap <= -2 and (11 * k - 10 * ell + 1) <= 0
        right = gap >= 2 and (-10 * k + 11 * ell + 1) <= 0
        delta0 = -2 if (left or right) else -1
        epsilon0 = 2 if left else 0
        zeta0 = 2 if right else 0
        return (2, beta0, -beta0, delta0, epsilon0, zeta0)

    even_x, even_y = x % 2 == 0, y % 2 == 0
    odd3_x, odd3_y = x % 2 == 1 and x >= 3, y % 2 == 1 and y >= 3
    if x == 1 and y == 1:
        return (1, 0, 0, 0, -1, 1)
    if x == 1 and even_y:
        return (1, 0, 0, -1, 0, 1)
    if x == 1 and odd3_y:
        return (0, 0, 0, -2, 1, 2)
    if even_x and y == 1:
        return (1, 0, 1, -1, 0, 1)
    if even_x and even_y:
        return (1, 0, -1, 0, -1, 1)
    if even_x and odd3_y:
        return (0, 0, -2, 1, -2, 2)
    if odd3_x and y == 1:
        return (1, 0, -1, -1, 0, 1)
    if odd3_x and even_y:
        return (0, -2, 0, 1, 2, -2)
    raise RuntimeError(f"unclassified pair {(x, y)}")


def weighted(x: int, y: int) -> int:
    alpha, beta, gamma, delta, epsilon, zeta = coefficients(x, y)
    tx, ty = accelerated(x), accelerated(y)

    def sq(u: int, v: int) -> int:
        return (u - v) * (u - v)

    return (
        alpha * sq(tx, ty)
        + beta * sq(x, ty)
        + gamma * sq(tx, y)
        + delta * sq(x, y)
        + epsilon * sq(x, tx)
        + zeta * sq(y, ty)
    )


def lambda_one(x: int, y: int) -> tuple[int, int, int, int, int, int]:
    """Lemma 2.2 at lambda(x,y)=1: each coefficient is the swapped partner."""
    alpha, beta, gamma, delta, epsilon, zeta = coefficients(y, x)
    return (alpha, gamma, beta, delta, zeta, epsilon)


def _ratio(num: int, den: int) -> Fraction | None:
    if den <= 0:
        return None
    return Fraction(num, den)


def branch_ratios(x: int, y: int) -> tuple[Fraction | None, Fraction | None]:
    """Theorem 2.3(5) at lambda=1: (first disjunct at (x,y), second at (y,x)).

    A disjunct with non-positive denominator is None. The second disjunct is
    the beta/gamma, epsilon/zeta twin, not the first formula on the swapped pair.
    """
    alpha, beta, _gamma, delta, epsilon, zeta = lambda_one(x, y)
    first = _ratio(
        -delta + epsilon + 2 * min(beta, 0),
        alpha + zeta + 2 * min(beta, 0),
    )
    alpha, beta, gamma, delta, epsilon, zeta = lambda_one(y, x)
    second = _ratio(
        -delta + zeta + 2 * min(gamma, 0),
        alpha + epsilon + 2 * min(gamma, 0),
    )
    return first, second


def main() -> int:
    ratios = []
    for x, y in DOSSIER_PAIRS:
        ratio = Fraction(abs(accelerated(x) - accelerated(y)), abs(x - y))
        ratios.append({"x": x, "y": y, "ratio": str(ratio)})
    dossier_ratio_ok = all(Fraction(row["ratio"]) == Fraction(3, 2) for row in ratios)

    halving = []
    for x, y in DOSSIER_PAIRS:
        # Same pairs, under the map that is a genuine contraction.
        ratio = Fraction(abs(x // 2 - y // 2), abs(x - y))
        halving.append(str(ratio))
    halving_contracts = all(Fraction(r) <= Fraction(1, 2) for r in halving)

    worst = 0
    worst_at = (1, 1)
    positive: list[dict] = []
    for x in range(1, SWEEP_N + 1):
        for y in range(1, SWEEP_N + 1):
            value = weighted(x, y)
            if value > worst:
                worst = value
                worst_at = (x, y)
            if value > 0 and len(positive) < 5:
                positive.append({"x": x, "y": y, "weighted": value})

    pair = (1, 3)
    live, other = branch_ratios(*pair)
    # First disjunct at (1, 3) has denominator -1. The second has ratio 3/2,
    # so no A in (0, 1) accepts this lambda. Author's stated A = 1/2 is one
    # such A; the obstruction is the whole interval.
    no_A_in_unit = live is None and other == Fraction(3, 2)

    if positive:
        verdict = "THEOREM_31_POSITIVE"
        ok = False
    elif dossier_ratio_ok and halving_contracts and worst <= 0 and no_A_in_unit:
        verdict = "VACUOUS"
        ok = True
    else:
        verdict = "INSTRUMENT_INCONSISTENT"
        ok = False

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "target": "col_fp",
        "kind": "vacuous dossier lead",
        "instrument": True,
        "registered_in_check_py": False,
        "verdict": verdict,
        "ok": ok,
        "source": "arXiv:2502.20642v2",
        "local_pdf": "incoming/kawasaki-collatz-2502.20642v2.pdf",
        "dossier_object": {
            "claim_attacked": "Banach contraction of T under |x-y|",
            "paper_claims_it": False,
            "odd_pair_ratios": ratios,
            "halving_map_ratios": halving,
        },
        "theorem_3_1_sweep": {
            "n": SWEEP_N,
            "pairs": SWEEP_N * SWEEP_N,
            "max_weighted": worst,
            "max_at": {"x": worst_at[0], "y": worst_at[1]},
            "positive_samples": positive,
        },
        "theorem_2_3_lambda_one": {
            "pair": {"x": pair[0], "y": pair[1]},
            "branch_at_pair": None if live is None else str(live),
            "branch_at_swap": None if other is None else str(other),
            "no_A_in_(0,1)": no_A_in_unit,
            "author_remark": "Remark 3.1 already says Theorems 2.2 and 2.3 fail",
        },
        "why_no_lock": (
            "v2 does not claim |Tx-Ty| <= c|x-y| with c<1, and Remark 3.1 "
            "does not claim the fixed-point hypotheses. Locking BREAK on the "
            "3/2 ratio would refute a lemma the PDF does not assert."
        ),
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / "col_fp_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{verdict}] sweep_max={worst} at {worst_at}; (1,3) branches={live}, {other}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
