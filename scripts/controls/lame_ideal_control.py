"""Discrimination control for lame_ideal_neg23 (Phase 3(i)++).

The gate's verdict rests on a NON-existence claim from a bounded search:
`norm_equation_solutions(8)` returns no (a, b) with a^2 + 23 b^2 = 8 and
a === b (mod 2). Non-existence-by-bounded-search is exactly the shape that
has misled this campaign twice before (the first ES control, the retracted
2(d) verdict) -- see docs/GATE-BEFORE-PROVE.md, "Discrimination control
(required where it bites)". This control asks the PASS question:

    COULD THE SEARCH MISS A REAL SOLUTION?

Three checks:

  (1) Positive existence -- the search DOES return solutions where they
      genuinely exist: target=32 -> (+-3, +-1); target=24 -> (+-1, +-1).
      A search with no discriminating power (e.g. one that always returns
      empty) would pass the gate's target=8 case vacuously.
  (2) b_bound not truncating -- `b_bound = isqrt(target // 23) + 1` is
      re-derived here as a brute-force sweep over an explicitly larger
      range (10x the formula's bound) for every target checked. Any
      solution the formula's narrower loop would have missed shows up as a
      mismatch.
  (3) Parity filter is not vacuous -- the (a - b) % 2 == 0 filter used at
      target=8 is exercised at target=32, where it must accept some of the
      solutions found in (1) (i.e. there IS an O_K element of norm 8,
      namely a witness for the classical P^3 = (theta - 2) relation), so
      the filter itself is shown capable of accepting, not just rejecting.

Run:  python scripts/controls/lame_ideal_control.py
This is an audit instrument, not a gate: it issues no campaign verdict and
is deliberately not registered in scripts/gates/check.py.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

sys.path.insert(0, str(ROOT / "scripts" / "controls"))

from lame_ideal_neg23 import norm_equation_solutions  # noqa: E402
from receipt import write_receipt  # noqa: E402

BAR = "=" * 74


def brute_force_solutions(target: int, b_bound: int) -> list[tuple[int, int]]:
    """Independent re-implementation: explicit bound, no isqrt shortcut."""
    out: list[tuple[int, int]] = []
    for b in range(-b_bound, b_bound + 1):
        rem = target - 23 * b * b
        if rem < 0:
            continue
        a = math.isqrt(rem)
        if a * a == rem:
            out.append((a, b))
            if a != 0:
                out.append((-a, b))
    return out


def existence_control() -> tuple[bool, dict]:
    print(BAR)
    print("[1] Positive existence: does the search find real solutions?")
    print(BAR)
    cases = {
        32: {(3, 1), (-3, 1), (3, -1), (-3, -1)},
        24: {(1, 1), (-1, 1), (1, -1), (-1, -1)},
        4: {(2, 0), (-2, 0)},
    }
    rec = {}
    ok = True
    for target, expected in cases.items():
        got = set(norm_equation_solutions(target))
        match = got == expected
        ok = ok and match
        print(f"    target={target:>3}: got={sorted(got)}  match expected: {match}")
        rec[str(target)] = {"expected": sorted(expected), "got": sorted(got), "ok": match}
    print(f"    => search finds genuine solutions (not vacuously empty): {ok}")
    return ok, rec


def bound_control() -> tuple[bool, dict]:
    print("\n" + BAR)
    print("[2] Is b_bound = isqrt(target // 23) + 1 truncating the domain?")
    print(BAR)
    rec = {}
    ok = True
    for target in (8, 24, 32, 4, 100, 1000, 8000):
        formula_bound = int(math.isqrt(target // 23)) + 1
        wide_bound = formula_bound * 10 + 50
        wide = set(brute_force_solutions(target, wide_bound))
        narrow = set(norm_equation_solutions(target))
        match = wide == narrow
        ok = ok and match
        print(
            f"    target={target:>5}: formula_bound={formula_bound:>3}  "
            f"wide_bound={wide_bound:>4}  |wide|={len(wide):>2}  |narrow|={len(narrow):>2}  "
            f"match: {match}"
        )
        rec[str(target)] = {
            "formula_bound": formula_bound,
            "wide_bound": wide_bound,
            "wide": sorted(wide),
            "narrow": sorted(narrow),
            "ok": match,
        }
    print(f"    => 10x-wider brute force reproduces the formula's search exactly: {ok}")
    return ok, rec


def parity_control() -> tuple[bool, dict]:
    print("\n" + BAR)
    print("[3] Is the (a - b) % 2 == 0 parity filter capable of accepting?")
    print(BAR)
    sols8 = norm_equation_solutions(8)
    parity8 = [(a, b) for a, b in sols8 if (a - b) % 2 == 0]
    # target=8 has no integer solutions at all, so the filter is vacuous there
    # by construction. Exercise it on target=32, which DOES have integer
    # solutions, to show the filter can pass a non-empty set through.
    sols32 = norm_equation_solutions(32)
    parity32 = [(a, b) for a, b in sols32 if (a - b) % 2 == 0]
    filter_can_accept = len(parity32) > 0
    print(f"    target=8:  raw={sols8}  parity-passing={parity8}")
    print(f"    target=32: raw={sols32}  parity-passing={parity32}")
    print(f"    => filter accepts at least one solution when the target has "
          f"same-parity witnesses: {filter_can_accept}")
    rec = {
        "target8_parity": parity8,
        "target32_raw": sols32,
        "target32_parity": parity32,
        "filter_can_accept": filter_can_accept,
    }
    return filter_can_accept, rec


def main() -> int:
    ok1, rec1 = existence_control()
    ok2, rec2 = bound_control()
    ok3, rec3 = parity_control()
    all_ok = ok1 and ok2 and ok3
    verdict = "NO FALSE POSITIVE" if all_ok else "REVIEW"
    print("\n" + BAR)
    print(f"lame_ideal_neg23 control verdict: {verdict}")
    print(BAR)
    print(f"  [1] positive existence:    {ok1}")
    print(f"  [2] bound not truncating:  {ok2}")
    print(f"  [3] parity filter live:    {ok3}")
    write_receipt(
        control="lame_ideal_control",
        gate="lame_ideal_neg23",
        verdict=verdict,
        checks={"positive_existence": {"ok": ok1, "record": rec1},
                "bound_not_truncating": {"ok": ok2, "record": rec2},
                "parity_filter_live": {"ok": ok3, "record": rec3}},
        ok=all_ok,
    )
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
