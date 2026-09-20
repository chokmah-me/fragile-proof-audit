"""Gate: Lamé supporting ideal witness for Q(√−23) (Phase 3(i)++).

Classical non-principal ideal certificate in O_K = ℤ[(1+√−23)/2]:

  • No α ∈ O_K with |N(α)| = 2  (norm equation a² + 23 b² = 8, a≡b (mod 2))
  • Hence the prime ideal P | (2) of norm 2 is non-principal
  • N(θ − 2) = 8 = 2³ with θ = (1+√−23)/2  (P³ principal classically)
  • Minkowski bound (2/π)√23 < 4 ⇒ every class has an ideal of norm ≤ 3
  • Reduced-form count for disc −23 equals 3 (reuses lame_h23 arithmetic)

PASS = all arithmetic checks hold.
Does **not** claim a Lean Ideal.IsPrincipal proof or cyclotomic classNumber=3.
flt-regular dependency remains deferred.
"""

from __future__ import annotations

import json
import math
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

# Import reduced-form helper from the class-number gate.
import sys

sys.path.insert(0, str(ROOT / "scripts" / "gates"))
from lame_h23 import EXPECTED_QUAD_FORMS, reduced_positive_definite_forms  # noqa: E402


def norm_equation_solutions(target: int = 8) -> list[tuple[int, int]]:
    """Integer solutions of a² + 23 b² = target (no parity filter)."""
    out: list[tuple[int, int]] = []
    b_bound = int(math.isqrt(target // 23)) + 1
    for b in range(-b_bound, b_bound + 1):
        rem = target - 23 * b * b
        if rem < 0:
            continue
        a = int(math.isqrt(rem))
        if a * a == rem:
            out.append((a, b))
            if a != 0:
                out.append((-a, b))
    return out


def audit_no_norm_two() -> dict:
    """No O_K-element of absolute norm 2 ⇔ no a≡b (mod 2) with a²+23b²=8."""
    sols = norm_equation_solutions(8)
    parity_ok = [(a, b) for a, b in sols if (a - b) % 2 == 0]
    return {
        "equation": "a^2 + 23 b^2 = 8",
        "all_integer_solutions": [{"a": a, "b": b} for a, b in sols],
        "even_parity_solutions": [{"a": a, "b": b} for a, b in parity_ok],
        "ok": len(parity_ok) == 0 and len(sols) == 0,
        "note": "empty solution set ⇒ no α∈O_K with |N(α)|=2",
    }


def audit_theta_minus_two() -> dict:
    """θ=(1+√−23)/2; θ−2 = (−3+√−23)/2; N = (9+23)/4 = 8 = 2³."""
    a, b = -3, 1
    num = a * a + 23 * b * b
    ok = num == 32 and num % 4 == 0 and num // 4 == 8
    return {
        "theta": {"a": 1, "b": 1, "formula": "(1+√-23)/2"},
        "theta_minus_two": {"a": a, "b": b, "formula": "(-3+√-23)/2"},
        "norm_numerator": num,
        "norm": num // 4,
        "expected_norm": 8,
        "ok": ok,
        "note": "N(θ−2)=2³; classically P³=(θ−2) for P=(2,θ)",
    }


def audit_minkowski() -> dict:
    """Imaginary-quadratic Minkowski bound (2/π)√|Δ| for Δ=−23."""
    bound = (2 / math.pi) * math.sqrt(23)
    floor_b = math.floor(bound)
    return {
        "discriminant": -23,
        "minkowski_bound": bound,
        "floor_bound": floor_b,
        "ok": bound < 4 and floor_b == 3,
        "note": "every ideal class has a nonzero ideal of absNorm ≤ 3",
    }


def audit_reduced_forms() -> dict:
    forms = reduced_positive_definite_forms(-23)
    ok = forms == list(EXPECTED_QUAD_FORMS) and len(forms) == 3
    return {
        "reduced_forms": [{"a": a, "b": b, "c": c} for a, b, c in forms],
        "class_number_via_forms": len(forms),
        "ok": ok,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    no_norm = audit_no_norm_two()
    theta = audit_theta_minus_two()
    mink = audit_minkowski()
    forms = audit_reduced_forms()
    all_ok = no_norm["ok"] and theta["ok"] and mink["ok"] and forms["ok"]

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": "3i++",
        "gate": "lame_ideal_neg23",
        "source": "classical ideal-class witness for Q(√-23); Lagarias-style exercise",
        "criterion": {
            "norm_obstruction": "no α∈O_K with |N(α)|=2",
            "cube_principal": "N(θ−2)=8 supports P³ principal",
            "minkowski": "(2/π)√23 < 4",
            "forms": "exactly 3 reduced forms of disc -23",
        },
        "no_norm_two": no_norm,
        "theta_minus_two": theta,
        "minkowski": mink,
        "quadratic_forms": forms,
        "verdict": "PASS" if all_ok else "BREAK",
        "lemma": "O_K of Q(√-23) is a PID (would be needed if Lamé-style UFD held after base change)",
        "instance": "P = (2, (1+√-23)/2), N(P)=2",
        "false_instance": None
        if all_ok
        else "norm-2 element exists or form/Minkowski mismatch",
        "ok": all_ok,
        "claims_cyclotomic_class_number": False,
        "flt_regular": "deferred — quadratic ideal arithmetic only",
        "lean": "IdealWitness.lean — norm obstruction by decide/nlinarith",
    }
    out = RESULTS / "lame_ideal_neg23_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{'PASS' if all_ok else 'FAIL'}] lame_ideal_neg23")
    print(f"  no |N|=2: {no_norm['ok']} (sols={no_norm['all_integer_solutions']})")
    print(f"  N(θ−2)=8: {theta['ok']}")
    print(f"  Minkowski floor={mink['floor_bound']}: {mink['ok']}")
    print(f"  forms h={forms['class_number_via_forms']}: {forms['ok']}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
