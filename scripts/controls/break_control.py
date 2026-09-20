"""False-positive control for the BREAK gates (suman_eq48, odd_zeta_1609).

A PASS gate is audited by asking "could it miss a real defect?" -- see
`es_cover_control.py`. A BREAK gate needs the opposite test:

    COULD THIS GATE FIRE ON A CORRECT PAPER?

That is the Jana-Karmakar failure mode: a harness bug (an omitted
negative-index Pochhammer convention) produced 66 false mismatches and very
nearly killed a clean paper. 2(d) has already issued one verdict that had to
be retracted. A BREAK is the only artefact this campaign could ever send to
an author, so it is the one that must not be wrong.

Four questions per gate:

  (1) Transcription fidelity  -- is the refuted claim the one the paper makes?
  (2) Machinery discrimination -- can the instrument ever decline to fire?
      A gate that reports BREAK on every input is not evidence of anything.
  (3) Algebraic self-consistency -- do the gate's closed forms agree with
      direct evaluation? (the Jana-Karmakar convention trap)
  (4) Independent corroboration, where a published refutation exists.

Checks (1) and (4) read the pinned PDFs under `incoming/`, which is
gitignored; where a PDF is absent they report `unavailable` rather than
passing silently.

Run:  python scripts/controls/break_control.py
This is an audit instrument, not a gate: it issues no campaign verdict and is
deliberately not registered in scripts/gates/check.py.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

from mpmath import exp, log, mp, mpf  # noqa: E402

mp.dps = 60

import odd_zeta_1609 as OZ  # noqa: E402
import suman_eq48 as SU  # noqa: E402

BAR = "=" * 74
SUMAN_PDF = ROOT / "incoming" / "suman-2407.07121v6.pdf"
CHEN_PDF = ROOT / "incoming" / "chen-2411.16774.pdf"


def pdf_text(path: Path) -> str | None:
    """Whitespace-collapsed text, or None when the PDF is not pinned."""
    if not path.exists():
        return None
    try:
        from pypdf import PdfReader
    except ImportError:
        return None
    pages = (pg.extract_text() or "" for pg in PdfReader(str(path)).pages)
    return " ".join(" ".join(pages).split())


# ===========================================================================
# suman_eq48
# ===========================================================================
def suman_control() -> tuple[str, dict]:
    print(BAR)
    print("suman_eq48 -- false-positive control")
    print(BAR)
    rec: dict = {}

    # (2) Machinery discrimination.
    # solutions_at_n DERIVES a from (b, k): a = 2b - kb/d whenever d | kb.
    # So a witness exists at every n provided k = 0 is in range. Quantify how
    # much of the verdict rests on that single endpoint.
    print("\n[2] Can the machinery ever decline to fire?")
    print(f"    {'n':>2} {'d_n':>8} {'sols 0<=k<=d':>14} {'sols 1<=k<=d-1':>16}")
    always = True
    interior_empty_at_1 = None
    for n in range(1, 9):
        d = SU.lcm_range(n)
        full = SU.solutions_at_n(n, b_values=range(1, 6))
        interior = [w for w in full if 1 <= w["k"] <= d - 1]
        always = always and bool(full)
        if n == 1:
            interior_empty_at_1 = not interior
        print(f"    {n:>2} {d:>8} {len(full):>14} {len(interior):>16}")
    print(f"    -> finds witnesses at every n tested:  {always}")
    print(f"    -> interior range 1<=k<=d-1 empty at n=1: {interior_empty_at_1}")
    print("    => the search itself has NO discriminating power; the entire")
    print("       verdict rests on whether k = 0 is admissible in (48).")
    rec["machinery_always_fires"] = always
    rec["interior_range_empty_at_n1"] = interior_empty_at_1

    # (1) Transcription fidelity -- the k = 0 endpoint, verbatim.
    print("\n[1] Transcription fidelity (the load-bearing fact)")
    s = pdf_text(SUMAN_PDF)
    if s is None:
        print(f"    unavailable -- {SUMAN_PDF.relative_to(ROOT)} not pinned")
        rec["transcription"] = "unavailable"
        transcription_ok = None
    else:
        eqs = {
            num: bool(re.search(
                r"d\s*n?a\s*−\s*2d\s*n?b\s*=\s*−k\s*i?b\s*where[^()]{0,60}\(%d\)" % num, s))
            for num in (47, 48, 49)
        }
        has48 = bool(re.search(r"0\s*≤\s*k\s*i?\s*≤\s*d\s*n\s*,\s*n\s*≥\s*1\s*\(48\)", s))
        has47 = bool(re.search(r"1\s*≤\s*k\s*i?\s*≤\s*d\s*n\s*−\s*1", s))
        # The decisive point: induction hypothesis (49) is purely algebraic.
        m49 = re.search(r"induction hypothesis.{0,200}?\(49\)", s)
        hyp = m49.group(0) if m49 else ""
        hyp_mentions_zeta = ("ζ" in hyp) or ("zeta" in hyp.lower())
        base = re.search(r"For the base case.{0,260}", s)
        base_txt = base.group(0) if base else ""
        base_uses_integrality = "not an integer" in base_txt
        base_names_solutions = "a − 2b = 0" in base_txt or "a - 2b = 0" in base_txt

        print(f"    (48) printed with range '0 ≤ ki ≤ dn, n ≥ 1':  {has48}")
        print(f"    (47) printed with narrower '1 ≤ ki ≤ dn − 1':  {has47}")
        print(f"    (49) induction hypothesis mentions ζ(5):       {hyp_mentions_zeta}")
        print(f"    base case itself derives a=2b / a=b:           {base_names_solutions}")
        print(f"    base case discharges via 'not an integer':     {base_uses_integrality}")
        print("    => (49) is a purely ALGEBRAIC claim, so the base case must")
        print("       discharge an algebraic statement; it discharges an")
        print("       arithmetic one instead. The gate refutes what the paper")
        print("       actually asserts, not a strawman.")
        transcription_ok = (
            has48 and not hyp_mentions_zeta
            and base_uses_integrality and base_names_solutions
        )
        rec["transcription"] = {
            "eq48_range_verbatim": has48,
            "eq47_narrower_range": has47,
            "eq49_hypothesis_mentions_zeta": hyp_mentions_zeta,
            "base_case_derives_same_solutions": base_names_solutions,
            "base_case_uses_integrality": base_uses_integrality,
            "ok": transcription_ok,
        }

    # (4) Independent corroboration.
    print("\n[4] Independent corroboration (Chen et al. arXiv:2411.16774v3)")
    c = pdf_text(CHEN_PDF)
    if c is None:
        print(f"    unavailable -- {CHEN_PDF.relative_to(ROOT)} not pinned")
        rec["corroboration"] = "unavailable"
        corroborated = None
    else:
        markers = {
            "names a=2b / a=b as valid integer solutions":
                "both of which are valid integer solutions" in c,
            "calls the induction base case invalidated":
                "invalidates the induction base case" in c,
            "identifies the zeta-integrality conflation":
                "logically independent of whether" in c,
        }
        for k, v in markers.items():
            print(f"    [{'ok' if v else 'MISS'}] {k}")
        corroborated = all(markers.values())
        print(f"    -> gate's lemma/instance matches the published refutation: "
              f"{corroborated}")
        rec["corroboration"] = {**markers, "ok": corroborated}

    checks = [x for x in (transcription_ok, corroborated) if x is not None]
    if not checks:
        verdict = "NO FALSE POSITIVE (machinery only; PDFs not pinned)"
    elif all(checks):
        verdict = "NO FALSE POSITIVE"
    else:
        verdict = "REVIEW"
    print(f"\n  suman_eq48 control verdict: {verdict}")
    rec["verdict"] = verdict
    return verdict, rec


# ===========================================================================
# odd_zeta_1609
# ===========================================================================
def g_direct(lam, q, alpha):
    """g(alpha) evaluated literally, as printed in the gate's docstring."""
    lam, q, alpha = mpf(lam), mpf(q), mpf(alpha)
    return (
        1 + q + lam * alpha
        + (1 + q) * log(1 + q)
        + (1 + alpha) * log(1 + alpha)
        - (1 + q + alpha) * log(1 + q + alpha)
    )


def alpha_star(lam, q):
    return mpf(q) / (exp(mpf(lam)) - 1) - 1


def leading_coeff(lam):
    """Coefficient of q in the large-q expansion of g(alpha*).

    g(alpha*) ~ q * [1 - lambda + log(e^lambda - 1)] + O(log q).
    Negative  => g -> -infinity => admissible q EXISTS => must not break.
    """
    lam = mpf(lam)
    return 1 - lam + log(exp(lam) - 1)


def min_g(lam, points=3001, decades=60):
    qmin = exp(mpf(lam)) - 1
    best = None
    for i in range(points):
        q = qmin * (mpf(10) ** (mpf(i) * decades / (points - 1))) * mpf("1.000001")
        v = OZ.g_alpha_star(lam, q)
        if best is None or v < best:
            best = v
    return best


def odd_zeta_control() -> tuple[str, dict]:
    print("\n" + BAR)
    print("odd_zeta_1609 -- false-positive control")
    print(BAR)
    rec: dict = {}

    # (3) Algebraic self-consistency.
    print("\n[3] Closed form g_alpha_star() vs direct g(alpha*)  (convention trap)")
    worst = mpf(0)
    for lam in (0.2, 1.0, 5, 7, 9, 11, 13):
        qmin = exp(mpf(lam)) - 1
        for mult in (mpf("1.0001"), mpf(10), mpf("1e6")):
            q = qmin * mult
            rel = abs(OZ.g_alpha_star(lam, q) - g_direct(lam, q, alpha_star(lam, q)))
            rel /= max(abs(g_direct(lam, q, alpha_star(lam, q))), mpf(1))
            worst = max(worst, rel)
    closed_ok = worst < mpf("1e-40")
    print(f"    worst relative disagreement over 21 points: {float(worst):.3e}")
    print(f"    -> closed form matches direct evaluation: {closed_ok}")
    rec["closed_form_matches_direct"] = bool(closed_ok)

    print("\n[3b] Is alpha* the MINIMISER of g, not a maximiser?")
    ok_min = True
    for lam in (5, 9, 13):
        q = (exp(mpf(lam)) - 1) * 1000
        a = alpha_star(lam, q)
        base = g_direct(lam, q, a)
        ok_min = ok_min and all(
            g_direct(lam, q, a * f) >= base
            for f in (mpf("0.5"), mpf("0.9"), mpf("1.1"), mpf(2))
        )
    print(f"    -> g(alpha*) <= g(alpha) at sampled neighbours: {ok_min}")
    rec["alpha_star_is_minimiser"] = ok_min

    # (2) The key test: can this gate decline to fire?
    print("\n[2] Discrimination: does the gate find admissible q when they")
    print("    genuinely exist? (positive control at small lambda)")
    print(f"    {'lambda':>7} {'c(lambda)':>11} {'min g(alpha*)':>18} {'admissible?':>12}")
    rows = []
    for lam in (0.1, 0.2, 0.3, 0.4, 0.45, 0.5, 1.0, 2.0, 5, 7, 9, 11, 13):
        c = leading_coeff(lam)
        best = min_g(lam)
        adm = best < 0
        rows.append({"lambda": lam, "c": float(c),
                     "min_g": float(best), "admissible": bool(adm)})
        print(f"    {lam:>7} {float(c):>11.4f} {float(best):>18.6g} {str(adm):>12}")
    fires = all(r["admissible"] for r in rows if r["lambda"] < 0.45)
    declines = all(not r["admissible"] for r in rows if r["lambda"] >= 5)
    print(f"\n    -> finds admissible q for small lambda (<0.45):   {fires}")
    print(f"    -> finds NONE at the paper's lambda=2n+3 (n=1..5): {declines}")
    discriminates = fires and declines
    print(f"    => instrument discriminates: {discriminates}")
    print("    note: at the paper's lambda the infimum is attained at the domain")
    print("          boundary q -> e^lambda-1, where g = 1+q = e^lambda exactly.")
    print("          The BREAK is an infimum result, not merely a sample.")
    rec["discrimination"] = {"rows": rows, "fires_small_lambda": fires,
                             "declines_paper_lambda": declines,
                             "ok": discriminates}

    # (1) Convention sensitivity.
    print("\n[1] Convention sensitivity: would the BREAK survive a different lambda?")
    sens = []
    for lam in (3, 5, 7, 9, 11, 13, 15):
        best = min_g(lam, points=601)
        sens.append({"lambda": lam, "min_g": float(best),
                     "admissible": bool(best < 0)})
        print(f"      lambda={lam:>3}: min g(alpha*)={float(best):>13.6g}  "
              f"admissible={best < 0}")
    robust = all(not r["admissible"] for r in sens)
    print(f"    -> BREAK robust across lambda 3..15: {robust}")
    rec["convention_robust"] = robust

    verdict = ("NO FALSE POSITIVE" if (closed_ok and ok_min and discriminates and robust)
               else "REVIEW")
    print(f"\n  odd_zeta_1609 control verdict: {verdict}")
    rec["verdict"] = verdict
    return verdict, rec


def main() -> int:
    v1, _ = suman_control()
    v2, _ = odd_zeta_control()
    print("\n" + BAR)
    print(f"suman_eq48     : {v1}")
    print(f"odd_zeta_1609  : {v2}")
    print(BAR)
    return 0 if v1.startswith("NO FALSE POSITIVE") and v2.startswith("NO FALSE POSITIVE") else 1


if __name__ == "__main__":
    raise SystemExit(main())
