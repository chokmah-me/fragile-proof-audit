"""Discrimination control for cat_g.

The gate says Sun's forward difference between (2.3) and (2.4) does not
vanish. The same difference, on Apéry's zeta(3) weight

    w_n(k) = C(k, n)^2 * C(k+n, n)^2,

vanishes at order 4n+1 and equals (4n)! / (n!)^4 at order 4n. That is the
zero-count in which vanishing is the true answer. Apéry's recurrence

    (n+1)^3 a_{n+1} = (2n+1)(17n^2+17n+5) a_n - n^3 a_{n-1}

has residual 0 on a_n = sum_k C(n,k)^2 C(n+k,k)^2. Replacing 17 by 18 makes
the residual nonzero, so the checker is not an always-zero instrument.

Sun's tail recurrence (1.4) is not this control. A checker that only
reconfirmed (1.4) would not be evidence about the polynomial claim.
"""

from __future__ import annotations

import sys
from fractions import Fraction
from math import comb, factorial
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import cat_g as G  # noqa: E402
from receipt import write_receipt  # noqa: E402

PDF = ROOT / "incoming" / "sun-catalan-2609.04176.pdf"
NEEDLES = (
    "is a polynomial iniof degree at most 2B",
    "Ti+1",
    "(2.3)",
    "(2.4)",
    "(2.13)",
    "(2.16)",
    "arXiv:2609.04176v1",
)
ABSENT = ("22830611", "Numerical Test of the Quadratic")


def choose_upper(k: int, n: int) -> Fraction:
    """C(k, n) as a polynomial in the upper index."""
    value = Fraction(1)
    for t in range(n):
        value *= k - t
    return value / factorial(n)


def apery_weight(n: int, k: int) -> Fraction:
    return choose_upper(k, n) ** 2 * choose_upper(k + n, n) ** 2


def apery_zero_count(n: int) -> dict:
    degree = 4 * n
    at_degree = G.forward_difference(
        [apery_weight(n, k) for k in range(degree + 1)]
    )
    above = G.forward_difference(
        [apery_weight(n, k) for k in range(degree + 2)]
    )
    leading = Fraction(factorial(degree), factorial(n) ** 4)
    return {
        "degree": degree,
        "difference_at_degree": str(at_degree),
        "difference_above_degree": str(above),
        "matches_leading": at_degree == leading,
        "vanishes_above_degree": above == 0,
        "does_not_vanish_at_degree": at_degree != 0,
    }


def apery_sequence(n: int) -> int:
    return sum(comb(n, k) ** 2 * comb(n + k, k) ** 2 for k in range(n + 1))


def recurrence_residual(n: int, linear: int = 17) -> int:
    return (
        (n + 1) ** 3 * apery_sequence(n + 1)
        - (2 * n + 1) * (linear * n * n + linear * n + 5) * apery_sequence(n)
        + n ** 3 * apery_sequence(n - 1)
    )


def pdf_text() -> str | None:
    if not PDF.exists():
        return None
    try:
        from pypdf import PdfReader
    except ImportError:
        return None
    reader = PdfReader(str(PDF))
    meta = reader.metadata or {}
    body = " ".join((page.extract_text() or "") for page in reader.pages)
    body = " ".join(body.split())
    author = str(meta.get("/Author") or "")
    title = str(meta.get("/Title") or "")
    return f"{author}\n{title}\n{body}"


def main() -> int:
    delta = G.paper_difference(2, 1, 0)
    sun_breaks = delta == G.WITNESS_DELTA and delta != 0
    pole = G.pole_numerator_at_half(2) != 0
    tails = G.tails_indexed_apart()["T0_exceeds_T1"]
    # The Catalan recurrence is true. Confirming it must not flip the control
    # to a pass on Sun's polynomial claim.
    recurrence_survives = G.recurrence_partial_holds()
    counts = [apery_zero_count(n) for n in (1, 2)]
    apery_vanishes = all(
        row["vanishes_above_degree"]
        and row["matches_leading"]
        and row["does_not_vanish_at_degree"]
        for row in counts
    )
    residuals = [recurrence_residual(n) for n in range(1, 13)]
    apery_recurrence = all(item == 0 for item in residuals)
    perturbed = recurrence_residual(3, linear=18) != 0
    text = pdf_text()
    if text is None:
        transcription = {"available": False, "ok": False}
    else:
        hits = {needle: needle in text for needle in NEEDLES}
        absent = {needle: needle not in text for needle in ABSENT}
        author_ok = text.startswith("Zhi-Wei Sun\nCatalan's constant is irrational\n")
        transcription = {
            "available": True,
            "hits": hits,
            "absent": absent,
            "author_title": author_ok,
            "ok": all(hits.values()) and all(absent.values()) and author_ok,
        }
    ok = (
        sun_breaks
        and pole
        and tails
        and recurrence_survives
        and apery_vanishes
        and apery_recurrence
        and perturbed
        and transcription["ok"]
    )
    verdict = "NO FALSE POSITIVE" if ok else "CONTROL_FAILED"
    write_receipt(
        control="cat_g_break_control",
        gate="cat_g",
        verdict=verdict,
        checks={
            "sun_difference_is_3596288_99225": sun_breaks,
            "pole_numerator_nonzero": pole,
            "printed_T_i_plus_1_is_not_T_i": tails,
            "catalan_recurrence_survives_and_is_not_the_verdict": recurrence_survives,
            "apery_zeta3_zero_count": counts,
            "apery_recurrence_residual_zero_n_1_to_12": apery_recurrence,
            "apery_coefficient_18_residual_nonzero": perturbed,
            "pdf_transcription": transcription,
        },
        ok=ok,
        extra={
            "local_pdf": "incoming/sun-catalan-2609.04176.pdf",
            "control_fact": (
                "Apéry weight of degree 4n has forward difference 0 at order "
                "4n+1 and (4n)!/(n!)^4 at order 4n"
            ),
        },
    )
    print(f"[{verdict}] cat_g_break_control")
    print(f"  Sun Delta = {delta}")
    print(f"  Apéry n=1 order 4,5 = {counts[0]['difference_at_degree']}, {counts[0]['difference_above_degree']}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
