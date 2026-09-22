"""Discrimination control for scripts/gates/jac_2d.py.

Per docs/GATE-BEFORE-PROVE.md protocol step 3: a check that cannot fail is not
evidence. This perturbs the instance-1 Keller pair from jac_2d.py by a single
monomial (F += x*y) that breaks the constant-Jacobian hypothesis, and shows
the SAME triangular coefficient-solve machinery then reports genuine
violations of eq. (2.41): c_alpha stops being a pure constant for alpha >
(-m+1)/m, and the boundary coefficient stops being affine of the predicted
slope. c_{-1} happens to still vanish on this particular perturbation (not
every perturbation breaks every clause), which is itself informative --
recorded, not hidden. Instrument, not a gate: writes a receipt, never
registered in scripts/gates/check.py.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import sympy as sp

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
sys.path.insert(0, str(ROOT))

from scripts.gates.jac_2d import X, Y, check_instance  # noqa: E402


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    order = 10

    # Positive control: the real gate's instance 1, must still pass here.
    g_pos = Y**2 + X
    f_pos = sp.expand(g_pos**2 + Y)
    positive = check_instance(f_pos, g_pos, m=4, n=2, order=order)

    # Negative control: perturb F by +x*y. Jacobian becomes -x+2y^2-1,
    # not constant -- the hypothesis behind eq. (2.41) is broken.
    g_neg = Y**2 + X
    f_neg = sp.expand(g_neg**2 + Y + X * Y)
    negative = check_instance(f_neg, g_neg, m=4, n=2, order=order)

    discriminates = positive["all_pass"] and not negative["all_pass"]

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "control": "jac_2d_break_control",
        "gate": "jac_2d",
        "positive_control": {
            "instance": "F=(y^2+x)^2+y, G=y^2+x (genuine Keller pair, J0=-1)",
            "all_pass": positive["all_pass"],
            "checks": positive["checks"],
        },
        "negative_control": {
            "instance": "F=(y^2+x)^2+y+xy, G=y^2+x (J0=-x+2y^2-1, NOT constant)",
            "J0": negative["J0"],
            "J0_is_constant": negative["J0_is_constant"],
            "all_pass": negative["all_pass"],
            "checks": negative["checks"],
        },
        "verdict": "DISCRIMINATES" if discriminates else "NO_DISCRIMINATION_FOUND",
        "ok": discriminates,
    }
    out = RESULTS / "jac_2d_break_control_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if discriminates else "FAIL"
    print(f"[{status}] jac_2d_break_control")
    print(f"  positive control all_pass: {positive['all_pass']}")
    print(f"  negative control all_pass: {negative['all_pass']} (checks: {negative['checks']})")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if discriminates else 1


if __name__ == "__main__":
    raise SystemExit(main())
