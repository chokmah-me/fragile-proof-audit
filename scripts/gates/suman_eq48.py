"""Numeric gate: Suman Eq. (48) admits integer solutions at n = 1.

Source range (Suman arXiv:2407.07121v6 Eq. (48)):

    d_n * a - 2 * d_n * b = -k * b
    where d_n | k * b,  0 <= k <= d_n,  n >= 1

with d_n = lcm(1..n). At n = 1, d_1 = 1 and k ∈ {0, 1}, giving families
a = 2b (k=0) and a = b (k=1).

Do NOT use the empty (47)-style range 1 <= k <= d_1 - 1 = 0.
Gates refute routes, not theorems: this does not claim ζ(5) ∈ ℚ.
"""

from __future__ import annotations

import json
import math
import sys
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
sys.path.insert(0, str(ROOT / "scripts"))

from harness.exact import to_mpf  # noqa: E402


def lcm_range(n: int) -> int:
    """d_n = lcm(1, 2, ..., n)."""
    if n < 1:
        raise ValueError("n must be >= 1")
    d = 1
    for i in range(1, n + 1):
        d = math.lcm(d, i)
    return d


def eq48_holds(d: int, a: int, b: int, k: int) -> bool:
    if b == 0:
        return False
    if not (0 <= k <= d):
        return False
    if (k * b) % d != 0:
        return False
    return d * a - 2 * d * b == -k * b


def solutions_at_n(
    n: int,
    *,
    b_values: range | None = None,
) -> list[dict]:
    """Search finite witness slab; return explicit (a,b,k) satisfying Eq. (48)."""
    d = lcm_range(n)
    if b_values is None:
        b_values = range(1, 6)
    found: list[dict] = []
    for b in b_values:
        for k in range(0, d + 1):
            if (k * b) % d != 0:
                continue
            # d(a - 2b) = -k b  ⇒  a - 2b = -(k b)/d  (exact since d | k b)
            rhs = -(k * b) // d
            a = rhs + 2 * b
            assert eq48_holds(d, a, b, k)
            found.append({"n": n, "d_n": d, "a": a, "b": b, "k": k, "a_over_b": f"{a}/{b}"})
    return found


def classify_families(witnesses: list[dict]) -> dict[str, int]:
    counts = {"a_eq_2b": 0, "a_eq_b": 0, "other": 0}
    for w in witnesses:
        a, b = w["a"], w["b"]
        if a == 2 * b:
            counts["a_eq_2b"] += 1
        elif a == b:
            counts["a_eq_b"] += 1
        else:
            counts["other"] += 1
    return counts


def empty_range_trap(d1: int) -> dict:
    """Document why Claude's 1 ≤ k ≤ d1-1 snippet is empty at n=1."""
    lo, hi = 1, d1 - 1
    return {
        "range_label": "Eq.(47)-style 1 <= k <= d_1 - 1",
        "lo": lo,
        "hi": hi,
        "is_empty": lo > hi,
        "note": "Do not use this range for the gate; induction targets Eq. (48).",
    }


def zeta5_gap() -> dict:
    """Show a=b ⇒ ζ(5)=1 is numerically false (~0.037 gap)."""
    try:
        from mpmath import mp

        mp.dps = 50
        z = mp.zeta(5)
        gap = abs(z - 1)
        return {
            "zeta5_approx": str(z),
            "gap_from_1": str(gap),
            "gap_from_1_float": float(gap),
            "expected_gap_gt": 0.03,
            "ok": float(gap) > 0.03,
        }
    except ImportError:
        # Fallback via harness Fraction→mpf path if mp.zeta unavailable oddly
        z = to_mpf(Fraction(0), dps=50)  # force import check
        _ = z
        raise


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    d1 = lcm_range(1)
    assert d1 == 1

    witnesses = solutions_at_n(1, b_values=range(1, 6))
    families = classify_families(witnesses)
    trap = empty_range_trap(d1)
    zgap = zeta5_gap()

    # Acceptance: both classical families appear; empty-range trap documented;
    # ζ(5) not near 1.
    has_2b = any(w["a"] == 2 * w["b"] and w["k"] == 0 for w in witnesses)
    has_b = any(w["a"] == w["b"] and w["k"] == 1 for w in witnesses)
    ok = (
        d1 == 1
        and has_2b
        and has_b
        and families["a_eq_2b"] > 0
        and families["a_eq_b"] > 0
        and trap["is_empty"]
        and zgap["ok"]
    )

    # Canonical small witnesses for Lean / audit note
    canonical = [
        {"a": 2, "b": 1, "k": 0, "family": "a=2b"},
        {"a": 1, "b": 1, "k": 1, "family": "a=b"},
    ]
    for c in canonical:
        assert eq48_holds(d1, c["a"], c["b"], c["k"])

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "suman_eq48",
        "source_claim": "arXiv:2407.07121v6",
        "source_refutation": "arXiv:2411.16774",
        "equation": "d_n*a - 2*d_n*b = -k*b",
        "constraints": "d_n | k*b, 0 <= k <= d_n, n >= 1",
        "n": 1,
        "d_1": d1,
        "canonical_witnesses": canonical,
        "witness_count": len(witnesses),
        "witnesses": witnesses,
        "families": families,
        "empty_range_trap": trap,
        "zeta5_gap": zgap,
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": "Eq. (48) has no integer solutions",
        "instance": "n=1, d_1=1, 0 <= k <= 1",
        "false_instance": "solutions a=2b (k=0) and a=b (k=1) exist",
        "ok": ok,
    }
    out = RESULTS / "suman_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] suman_eq48")
    print(f"  d_1 = {d1}")
    print(f"  canonical: {canonical}")
    print(f"  families: {families}")
    print(f"  empty-range trap empty={trap['is_empty']}")
    print(f"  ζ(5)≈{zgap['zeta5_approx'][:20]}… gap_from_1≈{zgap['gap_from_1_float']:.6f}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
