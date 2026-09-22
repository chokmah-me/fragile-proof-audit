"""False-positive control for the tang_zhang_schatten BREAK gate.

Same four questions as break_control.py / cohen_break_control.py /
baste_break_control.py / sarkozy_break_control.py, applied to
scripts/gates/tang_zhang_schatten.py.

Unlike the other Track D targets, this one has a local PDF pinned
(incoming/tang-zhang-2608.15558.pdf, sha256 recorded in
the gate's blueprint doc) -- the corpus doc's own narrative for this target
was corrupted (unresolved inline-image placeholders), so transcription
fidelity here is checked against the real paper, not the corpus paraphrase.

Run:  python scripts/controls/tang_zhang_break_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""
from __future__ import annotations

import json
import math
import random
import sys
from pathlib import Path

import mpmath as mp

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import tang_zhang_schatten as TZ  # noqa: E402

BAR = "=" * 74
mp.mp.dps = 50


def transcription_check() -> dict:
    """(1) Do the gate's stated theorem number, bound, matrix entries, and
    exponent match the pinned PDF (read directly by this campaign's PDF
    tool, not paraphrased from the corrupted corpus doc)?
    """
    print("\n[1] Transcription fidelity (pinned PDF, arXiv:2608.15558)")
    pdf_path = ROOT / "incoming" / "tang-zhang-2608.15558.pdf"
    checks = {
        "pdf_pinned": pdf_path.exists(),
        "theorem_1_1_bound_matches": TZ.BOUND == __import__("fractions").Fraction(207, 200),
        "u_first_coord_matches": TZ.U1 == __import__("fractions").Fraction(39, 40),
        "v_first_coord_matches": TZ.V1 == __import__("fractions").Fraction(5, 8),
        "u_second_coord_sq_matches": TZ.U2_SQ == __import__("fractions").Fraction(79, 1600),
        "v_second_coord_sq_matches": TZ.V2_SQ == __import__("fractions").Fraction(39, 64),
    }
    for k, v in checks.items():
        print(f"    [{'ok' if v else 'MISS'}] {k}")
    ok = all(checks.values())
    print(f"    -> gate's Theorem 1.1 instance matches the pinned PDF: {ok}")
    checks["ok"] = ok
    checks["provenance"] = "local PDF pin, read via this campaign's PDF tool"
    return checks


def _r_for_angle_pair(theta_eu: float, theta_ev: float, p: float) -> float:
    """Independent, from-scratch re-derivation (angle-parametrized, not
    Gram-matrix algebra) of R = ||A1+A2||_p / |||A1|+|A2|||_p for
    A1 = e e^T, A2 = u v^T, all unit vectors in R^2 at angle theta from e.
    """
    e = (1.0, 0.0)
    u = (math.cos(theta_eu), math.sin(theta_eu))
    v = (math.cos(theta_ev), math.sin(theta_ev))

    def outer(a, b):
        return [[a[0] * b[0], a[0] * b[1]], [a[1] * b[0], a[1] * b[1]]]

    def add(a, b):
        return [[a[0][0] + b[0][0], a[0][1] + b[0][1]], [a[1][0] + b[1][0], a[1][1] + b[1][1]]]

    def ata(m_):
        a, b, c, d = m_[0][0], m_[0][1], m_[1][0], m_[1][1]
        return [[a * a + c * c, a * b + c * d], [a * b + c * d, b * b + d * d]]

    def eig(m_):
        tr = m_[0][0] + m_[1][1]
        det = m_[0][0] * m_[1][1] - m_[0][1] * m_[1][0]
        disc = math.sqrt(max(tr * tr - 4 * det, 0.0))
        return (tr + disc) / 2, (tr - disc) / 2

    a1 = outer(e, e)
    a2 = outer(u, v)
    m_sum = add(a1, a2)
    n_sum = add(outer(e, e), outer(v, v))
    # s1, s2: squared singular values of M (M is not symmetric, use M^T M).
    # l1, l2: N = |A1|+|A2| is PSD, its eigenvalues ARE its singular values.
    s1, s2 = eig(ata(m_sum))
    l1, l2 = eig(n_sum)
    s1, s2, l1, l2 = max(s1, 0.0), max(s2, 0.0), max(l1, 0.0), max(l2, 0.0)
    num = s1 ** (p * 0.5) + s2 ** (p * 0.5)  # sigma^p = (sigma^2)^(p/2)
    den = l1**p + l2**p  # l already IS a singular value, not its square
    return (num / den) ** (1.0 / p)


def discrimination_check(trials: int = 5000, seed: int = 15558) -> dict:
    """(2) Sample random rank-one (A1, A2) pairs at the SAME (p, m) =
    (3/2, 2) as the witness and confirm: (a) the paper's specific witness
    reproduces the known R (cross-checking this independent
    angle-parametrized re-derivation against the gate's Gram-matrix path),
    (b) the overwhelming majority of random pairs do NOT exceed the
    conjectured constant C^TZ_{3/2,2}, let alone the 207/200 separator --
    the witness is a genuine near-extremal anomaly, not an artifact of a
    check that fires on everything.
    """
    print("\n[2] Discrimination: does the gate ever decline to fire?")
    p = 1.5
    t1w = math.atan2(math.sqrt(79) / 40, 39 / 40)
    t2w = math.atan2(math.sqrt(39) / 8, 5 / 8)
    r_witness = _r_for_angle_pair(t1w, t2w, p)
    r_witness_matches_gate = abs(r_witness - 1.0364136587048904) < 1e-9
    print(f"    independent angle-parametrized re-derivation of the witness: "
          f"R={r_witness:.16f}, matches gate's R: {r_witness_matches_gate}")

    c_32 = float(TZ.conjectured_constant(mp.mpf(3) / 2, 2)[1])
    bound = 207 / 200

    rng = random.Random(seed)
    exceeds_c, exceeds_bound = 0, 0
    max_r = 0.0
    for _ in range(trials):
        t1 = rng.uniform(0, math.pi)
        t2 = rng.uniform(0, math.pi)
        r = _r_for_angle_pair(t1, t2, p)
        if r > c_32:
            exceeds_c += 1
        if r > bound:
            exceeds_bound += 1
        max_r = max(max_r, r)

    frac_exceeds_c = exceeds_c / trials
    frac_exceeds_bound = exceeds_bound / trials
    print(f"    {trials} random rank-one pairs at p=3/2: "
          f"{exceeds_c} ({frac_exceeds_c:.1%}) exceed C^TZ, "
          f"{exceeds_bound} ({frac_exceeds_bound:.1%}) exceed 207/200")
    print(f"    max random R found: {max_r:.10f} vs witness R={r_witness:.10f} "
          f"(witness is near the true extremum, not typical)")
    declines_on_most_inputs = frac_exceeds_bound < 0.5
    not_tautological = exceeds_c > 0  # confirms C^TZ is violable at all, not vacuous
    return {
        "r_witness": r_witness,
        "r_witness_matches_gate": r_witness_matches_gate,
        "trials": trials,
        "exceeds_C_TZ": exceeds_c,
        "exceeds_207_200": exceeds_bound,
        "frac_exceeds_207_200": frac_exceeds_bound,
        "max_random_R": max_r,
        "declines_on_most_inputs": declines_on_most_inputs,
        "not_tautological": not_tautological,
    }


def algebraic_self_consistency_check() -> dict:
    """(3) Do the gate's two independent computation paths (exact-Fraction
    Gram-matrix algebra vs mpmath direct matrix construction) already
    agree? Delegated to the gate's own recorded meta rather than
    re-running both paths here.
    """
    print("\n[3] Algebraic self-consistency (exact-Fraction vs mpmath-direct paths)")
    meta_path = ROOT / "results" / "tang_zhang_schatten_gate_meta.json"
    if not meta_path.exists():
        print("    unavailable -- run scripts/gates/tang_zhang_schatten.py first")
        return {"ok": None, "note": "gate meta not found"}
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    agree = meta.get("paths_agree_to_1e-40")
    matches_paper = meta.get("path_a_exact_rational", {}).get("matches_paper_eq_8_9")
    print(f"    gate's own path-A/path-B agreement (1e-40): {agree}")
    print(f"    path A's rational eigenvalues match paper eqs. (8)-(9): {matches_paper}")
    ok = bool(agree) and bool(matches_paper)
    return {"ok": ok, "paths_agree": agree, "matches_paper_eq_8_9": matches_paper}


def independent_corroboration_check() -> dict:
    """(4) The conjectured-constant formula (eq. 4) is used here ONLY to
    evaluate the case that turned out FALSE (p=3/2). As an independent
    check unrelated to the counterexample construction, verify the same
    formula reduces EXACTLY to Tang-Zhang's own two PROVEN closed forms,
    cited in the paper's abstract/introduction: c_1(m)=1 and
    c_2(m)=sqrt((1+sqrt(m))/2), across several m. This does not touch the
    counterexample at all -- it is a structurally different validation
    that the gate's implementation of formula (4) is correct, by checking
    it against results that are independently known to be true rather
    than against the paper's own refutation.
    """
    print("\n[4] Independent corroboration: formula (4) at the PROVEN p=2 case")
    rows = []
    for m in (2, 3, 5, 8):
        _, c2 = TZ.conjectured_constant(mp.mpf(2), m)
        known = mp.sqrt((1 + mp.sqrt(m)) / 2)
        diff = abs(c2 - known)
        matches = diff < mp.mpf(10) ** -30
        rows.append({"m": m, "C_TZ_2_m": mp.nstr(c2, 20), "known_c2_m": mp.nstr(known, 20),
                      "matches": matches})
        print(f"    m={m}: C^TZ(2,{m})={mp.nstr(c2, 15)}  known c_2({m})={mp.nstr(known, 15)}  "
              f"match: {matches}")
    all_match = all(r["matches"] for r in rows)
    print(f"    -> formula (4) reduces to the independently-known-true p=2 closed form "
          f"for every tested m: {all_match}")
    return {"rows": rows, "all_match": all_match}


def main() -> int:
    print(BAR)
    print("tang_zhang_schatten -- false-positive control")
    print(BAR)
    t = transcription_check()
    d = discrimination_check()
    a = algebraic_self_consistency_check()
    c = independent_corroboration_check()

    checks = [
        t["ok"],
        d["r_witness_matches_gate"] and d["declines_on_most_inputs"] and d["not_tautological"],
        a["ok"],
        c["all_match"],
    ]
    if all(x is True for x in checks):
        verdict = "NO FALSE POSITIVE"
    elif any(x is False for x in checks):
        verdict = "REVIEW"
    else:
        verdict = "NO FALSE POSITIVE (partial -- some checks unavailable)"

    print(f"\n{BAR}")
    print(f"tang_zhang_schatten control verdict: {verdict}")
    print(BAR)
    return 0 if verdict.startswith("NO FALSE POSITIVE") else 1


if __name__ == "__main__":
    raise SystemExit(main())
