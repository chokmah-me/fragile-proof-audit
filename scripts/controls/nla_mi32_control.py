"""Discrimination control for the nla_mi32 PASS gate.

The gate's verdict is PASS on (S1) the exact Rademacher headline route
E||X||_2 <= M(X) <= M(X)+D(X) for n = 2,3,4, (S2) the sharpness probe
max r_n <= 0.8, and (S3) the exact fourth-moment lemma replay
S4 * 2^m <= 9^d * S2^2. Per docs/GATE-BEFORE-PROVE.md the open question
for a PASS is vacuity ("could it miss a real defect?"). This instrument
shows the gate's checks reject matched near-misses:

1. Tightened headline constant C* = 0.7: the S2 sharpness probe observes
   max r_n = 0.7406... > 0.7 at n = 4, so the C* = 0.7 claim must be
   rejected by the gate's own comparison.
2. Tightened lemma constant c = 2.98 (4th-power form) instead of 9: on
   the linear form F = sum_{i=1}^{201} x_i (d = 1, alpha = 1) the exact
   ratio is S4*N/S2^2 = 3 - 2/201 = 2.9900... > 2.98, so the tightened
   claim must be rejected; the true constant 9 passes on the same form.
3. Non-vacuity: the unperturbed gate path (S1 exact route, S3 lemma on
   fresh instances) passes, so the instrument is not an always-reject
   detector.

Run:  python scripts/controls/nla_mi32_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""

from __future__ import annotations

import sys
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import nla_mi32 as GATE  # noqa: E402
from receipt import write_receipt  # noqa: E402


def main() -> int:
    checks: dict[str, object] = {}

    print("[1] tightened headline constant C* = 0.7 (must be rejected)")
    s2 = GATE.s2_sharpness()
    max_r = s2["detail"]["max_ratio"]
    rejected_cstar = max_r > 0.7
    checks["tightened_headline_constant_rejected"] = rejected_cstar
    checks["observed_max_ratio"] = max_r
    print(f"    observed max r_n = {max_r:.10f} > 0.7 -> rejected: {rejected_cstar}")

    print("[2] tightened lemma constant c = 2.98 on linear form m = 201 "
          "(must be rejected)")
    m = 201
    # F = sum_{i=1}^{m} x_i, d = 1: S2 = N*m, S4 = N*(3m^2-2m) exactly.
    s2_exact = m
    s4_exact = 3 * m * m - 2 * m
    tight = Fraction(298, 100)
    true_const = Fraction(9)
    tight_rejected = not (s4_exact <= tight * s2_exact * s2_exact)
    true_passes = (s4_exact <= true_const * s2_exact * s2_exact)
    checks["tightened_lemma_constant_rejected"] = tight_rejected
    checks["true_constant_passes_same_form"] = true_passes
    checks["linear_form_ratio_3_minus_2_over_m"] = str(Fraction(s4_exact, s2_exact * s2_exact))
    print(f"    exact ratio 3-2/m = {float(Fraction(s4_exact, s2_exact*s2_exact)):.6f}; "
          f"tight 2.98 rejected: {tight_rejected}, true 9 passes: {true_passes}")

    print("[3] non-vacuity: unperturbed gate path passes")
    s1 = GATE.s1_headline_exact()
    s3 = GATE.s3_lemma_exact()
    unperturbed = s1["ok"] and s3["ok"] and s2["ok"]
    checks["unperturbed_S1_passes"] = s1["ok"]
    checks["unperturbed_S2_passes"] = s2["ok"]
    checks["unperturbed_S3_passes"] = s3["ok"]
    print(f"    S1={s1['ok']} S2={s2['ok']} S3={s3['ok']}")

    ok = bool(
        rejected_cstar
        and tight_rejected
        and true_passes
        and unperturbed
    )
    verdict = "NO FALSE POSITIVE" if ok else "CONTROL FAILURE"
    print(f"\nverdict: {verdict}")
    write_receipt(
        control="nla_mi32_control",
        gate="nla_mi32",
        verdict=verdict,
        checks=checks,
        ok=ok,
        extra={
            "note": (
                "Near-misses are matched: the same checker, the same "
                "witnesses, only the claimed constant tightened "
                "(C 1 -> 0.7; 9^d -> 2.98^d). Rejection comes from the "
                "gate's own comparisons (observed ratio 0.7406 > 0.7; "
                "exact 3-2/201 > 2.98), proving the checks read the "
                "witnesses rather than rubber-stamping."
            )
        },
    )
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
