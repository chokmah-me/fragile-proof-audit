#!/usr/bin/env python3
"""Numeric gate: GB-SCE v5's three "unproven inequalities" for the dominant structure.

Source: arXiv:1909.13230v5 (19 May 2026), A. Z. Mohammadi & M. Kolahdouz,
"Introducing and Applying S.C.E Model Under Dusart's Inequality to Prove
Goldbach's Strong Conjecture for 74 Typical Structures out of All 75
Structural Types of Even Number".
Paper pin: incoming/gb-sce-1909.13230v5.pdf, 912,076 bytes,
SHA-256 2382574230986728c283eae89cc09285376be2764152c07c5e668f1862069c14.

The paper's "relative proof" covers 74 of 75 structural types. The dominant
75th (d_E < b_E < c_E < a_E) is to be knocked out by three inequalities,
"using each of which we can knock out the last typical structure" (p. 13).
The authors admit: "the authors did their best to prove analytically these
two inequality, but they did not succeed" and "we guess" they hold (p. 13-14).

The three inequalities (p. 14, transcribed from the rendered PDF):
  (i)   b_E < (E/2)/ln E - (E/2)/ln(E/2),   for 10 <= E
  (ii)  c_E < (E/2)/ln(E/2) - 1,            for 4 <= E
  (iii) b_E + c_E < (E/2)/ln E - 1,         for 2 <= E
with b_E, c_E from Def (5)-(8), pinned by Example 2.6 (E=20: a=0,b=2,c=1,d=2).

Finding: (i) is FALSE for every E > 2 as printed. b_E >= 0 (a cardinality,
Def (6)), while (E/2)(1/ln E - 1/ln(E/2)) < 0 because ln(E/2) < ln E.
The gate exhibits this numerically across E = 10^4..10^8 (plus exhaustive
even E in [10, 2000]) and checks the sign analytically at every E tested.

Controls (same instrument, same E values; correct verdict = Confirm):
  - Dusart's inequality x/ln x <= pi(x) <= 1.2251 x/ln x holds at 8 scales:
    the paper's cited foundation, a true scalar inequality of the same
    shape; the instrument declines to fire.
  - Teeter (18), (19) hold for every even E >= 18 tested: the paper's
    proved foundation for the 72 structures; the instrument declines.
  - Model identities (11), (12), (13) hold exactly at every E; Example 2.6
    reproduces. The instrument is not a reversal-generator: it Confirms
    true scalar claims and fires only on the three unproven ones.

Further finding: (ii) fails at 5 small E (first E=398) though it holds for
E > 2525 on the tested range; (iii) fails systematically for large E
(925/1004, margin -2.46M at E=10^8): heuristically b_E+c_E exceeds
(E/2)/ln E - 1 by ~(E/4)(2/ln(E/2))(1-4/ln E) > 0 for E > 55.

Gates refute routes, not theorems: Goldbach's conjecture is untouched.
Stdlib only.
"""

from __future__ import annotations

import json
import math
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

PDF_SHA = "2382574230986728c283eae89cc09285376be2764152c07c5e668f1862069c14"


def sieve(n: int) -> bytearray:
    bs = bytearray(b"\x01") * (n + 1)
    bs[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if bs[i]:
            bs[i * i : n + 1 : i] = b"\x00" * ((n - i * i) // i + 1)
    return bs


def sce_quadruple(E: int, ip: bytearray) -> tuple[int, int, int, int]:
    """Def (5)-(8), doubled integer counts (2a,2b,2c,2d).

    The 1/2 in the printed (5),(8) multiplies the DIAGONAL term #{x~x}
    (pinned by Example 2.6: E=20 -> (a,b,c,d)=(0,2,1,2), and by the exact
    identities (11),(12),(13) checked below). Each unordered pair {x,y},
    x<y, contributes 1 to exactly one of a,b,c,d; the x=y=E/2 pair (when
    E/2 is odd) contributes 1/2.
    Returns (a2,b2,c2,d2) = (2a,2b,2c,2d) as exact integers."""
    a2 = b2 = c2 = d2 = 0
    half = E // 2
    # x odd, 1 <= x <= E/2; y = E - x >= x automatically
    for x in range(1, half + 1, 2):
        y = E - x
        px = ip[x]
        py = ip[y]
        if x == y:
            if px:
                d2 += 1  # half of d_E's unit
            else:
                a2 += 1
        elif px and py:
            d2 += 2
        elif px:
            c2 += 2  # x prime, y nonprime
        elif py:
            b2 += 2  # x nonprime, y prime
        else:
            a2 += 2
    return a2, b2, c2, d2


def main() -> int:
    t0 = time.time()
    EMAX = 10 ** 8
    ip = sieve(EMAX)

    def pi_count(x: int) -> int:
        return sum(ip[: x + 1])  # C-speed on the bytearray slice

    # ---- sanity: Example 2.6 and model identities (11),(12),(13) ----
    a20, b20, c20, d20 = sce_quadruple(20, ip)
    example_ok = (a20, b20, c20, d20) == (0, 4, 2, 4)  # doubled: (0,2,1,2)

    E_vals = list(range(10, 2001, 2))
    E_vals += [10 ** 4, 3 * 10 ** 4, 10 ** 5, 3 * 10 ** 5,
               10 ** 6, 3 * 10 ** 6, 10 ** 7, 10 ** 8]

    identities_ok = True
    teeter_ok = True
    n_teeter_tested = 0
    n_i_viol = 0
    n_i_tested = 0
    worst_i_margin = -math.inf  # max over E of (RHS_i - b_E); expect < 0 always
    analytic_sign_ok = True   # RHS_i < 0 at every E tested
    n_ii_viol = 0
    first_ii_viol = None
    min_ii_margin = math.inf  # min over E of (RHS_ii - c_E)
    n_iii_viol = 0
    first_iii_viol = None
    min_iii_margin = math.inf  # min over E of (RHS_iii - (b_E+c_E))
    b_nonneg_ok = True

    for E in E_vals:
        a2, b2, c2, d2 = sce_quadruple(E, ip)
        a, b, c, d = a2 / 2, b2 / 2, c2 / 2, d2 / 2
        pie = pi_count(E)
        if b < 0:
            b_nonneg_ok = False
        # (11): a+b+c+d = E/4 ; (12): b+c+2d = pi(E)-1 ; (13): b+c+2a = E/2-pi(E)+1
        if not (a2 + b2 + c2 + d2 == E // 2
                and b2 + c2 + 2 * d2 == 2 * (pie - 1)
                and b2 + c2 + 2 * a2 == E - 2 * pie + 2):
            identities_ok = False
        lnE = math.log(E)
        lnE2 = math.log(E / 2)
        # Teeter (18),(19): Lemma 2.7 is stated for E >= 17 (even: E >= 18)
        if E >= 18:
            n_teeter_tested += 1
            # (18): E/2 - 1.2551*E/lnE + 1 < b+c+2a < E/2 - E/lnE + 1
            lhs18 = E / 2 - 1.2551 * E / lnE + 1
            rhs18 = E / 2 - E / lnE + 1
            # (19): E/lnE - 1 < b+c+2d < 1.2551*E/lnE - 1
            lhs19 = E / lnE - 1
            rhs19 = 1.2551 * E / lnE - 1
            if not (lhs18 < b + c + 2 * a < rhs18
                    and lhs19 < b + c + 2 * d < rhs19):
                teeter_ok = False
        # unproven (i): b_E < (E/2)/lnE - (E/2)/ln(E/2)
        rhs_i = (E / 2) / lnE - (E / 2) / lnE2
        n_i_tested += 1
        if rhs_i >= 0:
            analytic_sign_ok = False
        worst_i_margin = max(worst_i_margin, rhs_i - b)
        if not (b < rhs_i):
            n_i_viol += 1
        # unproven (ii): c_E < (E/2)/ln(E/2) - 1
        rhs_ii = (E / 2) / lnE2 - 1
        m_ii = rhs_ii - c
        min_ii_margin = min(min_ii_margin, m_ii)
        if not (m_ii > 0):
            n_ii_viol += 1
            if first_ii_viol is None:
                first_ii_viol = (E, c, rhs_ii)
        # unproven (iii): b_E + c_E < (E/2)/lnE - 1
        rhs_iii = (E / 2) / lnE - 1
        m_iii = rhs_iii - (b + c)
        min_iii_margin = min(min_iii_margin, m_iii)
        if not (m_iii > 0):
            n_iii_viol += 1
            if first_iii_viol is None:
                first_iii_viol = (E, b + c, rhs_iii)

    # ---- control: Dusart's inequality on the same scale ----
    dusart_ok = True
    for x in [17, 100, 1000, 10 ** 4, 10 ** 5, 10 ** 6, 10 ** 7, 10 ** 8]:
        lo = x / math.log(x)
        hi = 1.2251 * x / math.log(x)
        if not (lo <= pi_count(x) <= hi):
            dusart_ok = False

    i_false_everywhere = (
        n_i_viol == n_i_tested and analytic_sign_ok and b_nonneg_ok
    )
    # (ii),(iii) are the paper's own numerical claims; report their status
    # honestly: violations are further evidence against the route.
    ii_holds = n_ii_viol == 0
    iii_holds = n_iii_viol == 0
    controls_sane = (
        example_ok and identities_ok and teeter_ok and dusart_ok
    )
    ok = i_false_everywhere and controls_sane
    verdict = "BREAK" if ok else "ABORT"

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "target": "gb_sce",
        "source": "arXiv:1909.13230v5",
        "local_pdf": "incoming/gb-sce-1909.13230v5.pdf",
        "pdf_sha256": PDF_SHA,
        "lemma": (
            "p.14, first 'unproven inequality' for the dominant structure "
            "d_E < b_E < c_E < a_E: b_E < (E/2)/ln E - (E/2)/ln(E/2), 10 <= E"
        ),
        "instance": "E=10: b_10 = 0 (pairs (1,9)->a, (3,7)->d, (5,5)->d)",
        "false_instance": (
            "as printed, RHS = (E/2)(1/ln E - 1/ln(E/2)) < 0 for all E > 2 "
            "while b_E >= 0 (Def (6) is a cardinality); b_E < RHS impossible"
        ),
        "n_i_tested": n_i_tested,
        "n_i_violated": n_i_viol,
        "rhs_i_negative_everywhere": analytic_sign_ok,
        "worst_i_margin_rhs_minus_b": worst_i_margin,
        "n_ii_violated": n_ii_viol,
        "first_ii_violation": first_ii_viol,
        "ii_min_margin": min_ii_margin,
        "n_iii_violated": n_iii_viol,
        "first_iii_violation": first_iii_viol,
        "iii_min_margin": min_iii_margin,
        "example_2_6_ok": example_ok,
        "model_identities_11_12_13_ok": identities_ok,
        "teeter_18_19_ok": teeter_ok,
        "n_teeter_tested": n_teeter_tested,
        "dusart_control_ok": dusart_ok,
        "elapsed_s": round(time.time() - t0, 1),
        "not_this_gate": "Goldbach's conjecture itself; the 74-structure relative claim",
        "verdict": verdict,
        "ok": ok,
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / "gb_sce_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"[{'PASS' if ok else 'FAIL'}] gb_sce")
    print(f"  (i) violated on {n_i_viol}/{n_i_tested} E values "
          f"(RHS<0 everywhere: {analytic_sign_ok}, worst margin {worst_i_margin:.3f})")
    print(f"  (ii) violated on {n_ii_viol} E values "
          f"(first: {first_ii_viol}, min margin {min_ii_margin:.3f})")
    print(f"  (iii) violated on {n_iii_viol} E values "
          f"(first: {first_iii_viol}, min margin {min_iii_margin:.3f})")
    print(f"  controls: example2.6={example_ok} identities={identities_ok} "
          f"teeter={teeter_ok} dusart={dusart_ok}")
    print(f"  verdict: {verdict}  ({meta['elapsed_s']}s)")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
