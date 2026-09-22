"""False-positive control for the salez_youssef_logsobolev BREAK gate.

Two checks, matching this campaign's doctrine (docs/GATE-BEFORE-PROVE.md):

1. Transcription fidelity: does the gate's chain match the pinned PDF
   (incoming/salez-youssef-munch-2504.08055.pdf), spot-checked against
   Section 2's explicit formulas and Theorem 2.1?
2. Discrimination: does the SAME diagnostic (Theorem 2.1's capacitary
   ratio R(n) / [K/log d]) correctly distinguish the BREAK instance from a
   case the source paper itself names as satisfying the conjecture? The
   paper states (Section 2, second bullet): "If the invariant measure is
   log-concave, then a lower Ollivier curvature bound K implies a lower
   Bakry-Emery curvature bound (1/2)K [9, Theorem 3] and the conjecture
   follows from Theorem 1.1." scripts/gates/salez_youssef_logsobolev.py's
   control_instance() builds exactly such a chain (constant curvature,
   log-concave discrete-Gaussian invariant measure) and the same ratio
   diagnostic must NOT show it vanishing -- if it did, the diagnostic itself
   would be worthless (it would "refute" a case known to hold).

Run:  python scripts/controls/salez_youssef_break_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""

from __future__ import annotations

import sys
from fractions import Fraction
from pathlib import Path

import mpmath as mp

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import salez_youssef_logsobolev as SY  # noqa: E402

BAR = "=" * 74


def transcription_check() -> dict:
    """(1) Do the gate's transition-probability formulas match the pinned
    PDF's Section 2 display equations, spot-checked at concrete (n, k)?
    """
    print("\n[1] Transcription fidelity (pinned PDF, arXiv:2504.08055)")
    pdf_path = ROOT / "incoming" / "salez-youssef-munch-2504.08055.pdf"
    n = 10
    checks = {
        "pdf_pinned": pdf_path.exists(),
        # 4p(k,k+1) = 1/n^2 for 1<=k<=n -- spot check k=1 and k=n
        "up_low_branch_k1": SY.p_up(1, n) == Fraction(1, 4 * n * n),
        "up_low_branch_kn": SY.p_up(n, n) == Fraction(1, 4 * n * n),
        # 4p(k,k+1) = 1-1/n-k/n^2 for n<k<=3n-1 -- spot check k=n+1
        "up_high_branch": SY.p_up(n + 1, n)
        == (1 - Fraction(1, n) - Fraction(n + 1, n * n)) / 4,
        # 4p(k,k-1) = 1/n+(k+1)/n^2 for 2<=k<=n -- spot check k=2
        "down_low_branch": SY.p_down(2, n) == (Fraction(1, n) + Fraction(3, n * n)) / 4,
        # 4p(k,k-1) = 1 for n<k<=3n -- spot check k=n+1 and k=3n
        "down_high_branch_low_end": SY.p_down(n + 1, n) == Fraction(1, 4),
        "down_high_branch_high_end": SY.p_down(3 * n, n) == Fraction(1, 4),
        # boundary convention
        "p_down_at_1_is_zero": SY.p_down(1, n) == Fraction(0),
        "p_up_at_3n_is_zero": SY.p_up(3 * n, n) == Fraction(0),
        # detailed-balance ratio pi(k)/pi(k+1) = n+k+2 for 1<=k<=n-1
        # (paper, bottom p.6) -- cross-check via p(k+1,k)/p(k,k+1) directly
        "stationary_ratio_matches_paper_formula": (
            SY.p_down(2, n) / SY.p_up(1, n) == Fraction(n + 1 + 2)
        ),
    }
    for k, v in checks.items():
        print(f"    [{'ok' if v else 'MISS'}] {k}")
    ok = all(checks.values())
    print(f"    -> gate's chain matches the pinned PDF's Section 2 formulas: {ok}")
    return {"ok": ok, "checks": checks}


def discrimination_check() -> dict:
    """(2) On a chain the source paper itself says satisfies the conjecture
    (constant curvature, log-concave invariant measure), does the SAME
    diagnostic avoid a false "vanishing ratio" verdict?
    """
    print("\n[2] Discrimination: log-concave control family (paper's own named exception)")
    ns = [10, 30, 100, 300, 1000, 3000]
    controls = [SY.control_instance(n) for n in ns]

    all_log_concave = all(c["log_concave"] for c in controls)
    ratios = [float(c["ratio_R_over_Klogd"]) for c in controls]
    ratio_grows = all(ratios[i] < ratios[i + 1] for i in range(len(ratios) - 1))
    ratio_stays_above_1 = all(r > 1.0 for r in ratios)

    for c, r in zip(controls, ratios):
        print(
            f"    n={c['n']:5d} log_concave={c['log_concave']} "
            f"kappa={mp.nstr(c['min_kappa'], 6)} d={mp.nstr(c['d'], 6)} "
            f"ratio_R_over_Klogd={r:.6g}"
        )
    print(f"    all instances log-concave: {all_log_concave}")
    print(f"    ratio grows with n (opposite trend from the BREAK instance): {ratio_grows}")
    print(f"    ratio stays > 1 throughout (never looks like a violation): {ratio_stays_above_1}")

    ok = all_log_concave and ratio_grows and ratio_stays_above_1
    print(f"    -> NO FALSE POSITIVE on the paper's own named safe case: {ok}")
    return {"ok": ok, "ratios": ratios}


def main() -> int:
    print(BAR)
    print("salez_youssef_break_control")
    print(BAR)
    t = transcription_check()
    d = discrimination_check()
    ok = t["ok"] and d["ok"]
    print(f"\n{BAR}\nVERDICT: {'NO FALSE POSITIVE' if ok else 'CONTROL FAILED'}\n{BAR}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
