"""Numeric gate: Ghermoul equation (35) is not an identity.

Source: arXiv:2508.07367v1, Statement (3) of Theorem 2.1, the case
u ≡ 2 (mod 7). incoming/es5-2508.07367.pdf, page 10.

The proof first displays a correct three-term formula for
    q = p4(x, y) = -97 + 121 y + 84 x (-4 + 5 y).
It then sets y = 1, so q = 12(7x+2), and prints equation (35) with the
right-hand side of equation (34). Those denominators belong to
q = 12(7x+1), not to q = 12(7x+2).

At x = 0 the printed line says 5/121 = 5/61.

The same proof's p4 formula at y = 1 is an identity, so this does not say
the residue class is empty of decompositions. It says the displayed
specialization the proof tells the reader to use is false.

q ≡ 0 (mod 252) is the author's own Conjecture 2. It is not this gate.
The locked es_cover row (arXiv:2404.01508, the 4/n paper) is untouched.

Gates refute routes, not theorems.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
SAMPLE = range(0, 9)

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass


def eq33(x: int) -> tuple[Fraction, Fraction]:
    """(33), q ≡ 7 (mod 12). Dossier spot-check; a true identity."""
    left = Fraction(5, 1 + 5 * (7 + 12 * x))
    right = (
        Fraction(1, 8 * (3 + 5 * x))
        + Fraction(1, 24 * (3 + 5 * x))
        + Fraction(1, 4 * (3 + 5 * x))
    )
    return left, right


def rhs34(x: int) -> Fraction:
    return (
        Fraction(1, 84 * x + 14)
        + Fraction(1, 7 * (48 * x + 7) * (420 * x + 61))
        + Fraction(1, 14 * (6 * x + 1) * (48 * x + 7))
    )


def eq34(x: int) -> tuple[Fraction, Fraction]:
    """(34), u ≡ 1 (mod 7). The denominators (35) copies."""
    return Fraction(5, 5 * 12 * (7 * x + 1) + 1), rhs34(x)


def eq35(x: int) -> tuple[Fraction, Fraction]:
    """(35) as printed: new left-hand side, equation (34)'s right-hand side."""
    return Fraction(5, 5 * 12 * (7 * x + 2) + 1), rhs34(x)


def p4_y1(x: int) -> tuple[Fraction, Fraction]:
    """p4 at y = 1, the specialization (35) should have been."""
    left = Fraction(5, 5 * 12 * (7 * x + 2) + 1)
    right = (
        Fraction(1, 2 * (3 * x + 1) * (420 * x + 121))
        + Fraction(1, 6 * (3 * x + 1) * (28 * x + 9) * (420 * x + 121))
        + Fraction(1, 3 * (28 * x + 9))
    )
    return left, right


def holds(pair_fn, xs) -> bool:
    return all(left == right for left, right in (pair_fn(x) for x in xs))


def case_bucket(q: int) -> str:
    """Theorem 2.1's stated split. 'mod252' is the case the theorem skips."""
    if q % 12 != 0:
        return "stmt2"
    unit = q // 12
    if unit % 7 != 0:
        return "stmt3"
    velocity = unit // 7
    if velocity % 3 != 0:
        return "stmt4"
    return "mod252"


def partition_matches_theorem(limit: int = 252 * 4) -> bool:
    for q in range(1, limit + 1):
        bucket = case_bucket(q)
        if q % 252 == 0:
            if bucket != "mod252":
                return False
        elif bucket == "mod252":
            return False
    return True


def main() -> int:
    left0, right0 = eq35(0)
    printed_false = left0 == Fraction(5, 121) and right0 == Fraction(5, 61) and left0 != right0
    fails_on_sample = all(left != right for left, right in (eq35(x) for x in SAMPLE))
    true_neighbors = holds(eq34, SAMPLE) and holds(eq33, SAMPLE) and holds(p4_y1, SAMPLE)
    partition_ok = partition_matches_theorem()
    ok = printed_false and fails_on_sample and true_neighbors and partition_ok
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "target": "es5_eq35",
        "source": "arXiv:2508.07367v1",
        "local_pdf": "incoming/es5-2508.07367.pdf",
        "lemma": (
            "Theorem 2.1(3), u ≡ 2 (mod 7): setting y = 1 in p4 yields "
            "equation (35)"
        ),
        "instance": "x = 0, q = 24, a = 121",
        "false_instance": "printed (35) says 5/121 = 5/61",
        "at_x0": {"lhs": str(left0), "rhs": str(right0)},
        "eq35_fails_on_0_to_8": fails_on_sample,
        "eq34_holds": holds(eq34, SAMPLE),
        "eq33_holds": holds(eq33, SAMPLE),
        "p4_y1_holds": holds(p4_y1, SAMPLE),
        "theorem_split_skips_only_multiples_of_252": partition_ok,
        "not_this_gate": "Conjecture 2 (q ≡ 0 mod 252) and es_cover (2404.01508)",
        "verdict": "BREAK" if ok else "ABORT",
        "ok": ok,
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / "es5_eq35_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{'PASS' if ok else 'FAIL'}] es5_eq35")
    print(f"  (35) at x=0: {left0} vs {right0}")
    print(f"  (34), (33), p4(y=1) hold on 0..8: {true_neighbors}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
