"""Numeric gate: Sun's polynomial claim between (2.3) and (2.4) is false.

Source: Zhi-Wei Sun, arXiv:2609.04176v1, Theorem 2.1, pages 4–5.
incoming/sun-catalan-2609.04176.pdf.

This PDF is not Zenodo 22830611. That record is Bilar's numerical note on
Sun's section 9 (catalan-sun-lean). A metadata mismatch aborts; it is not a
BREAK.

Between (2.3) and (2.4) the proof says that, for j in {1,...,S} and B > S,

    Q_j(i) = Pi_i / (2(i+j)+1) * sum_{0 <= k < j} (-1)^{j-1-k} / (2(i+k)+1)^2

is a polynomial in i of degree at most 2B-3, and therefore its forward
difference of order a+2B vanishes. Pi_i = prod_{h=1}^{B} (2(h+i)+1)^2 starts
at h = 1, so the k = 0 denominator (2i+1)^2 is not cancelled.

At B = 2, S = 1, j = 1, a = 0 the order-4 difference is 3596288/99225.

The next displayed formula writes Pi_i T_{i+1} / (2(i+j)+1). Equation (2.3)
has T_i. Those tails differ: T_0 > 8/9 and T_1 = 1 - T_0 < 1/9.

Equation (1.4) is an exact reindexing. It is checked and it is not the
verdict. Equation (2.16), K(-3/2) = 0, is not the witness: D(-3/2) = 0 for
the polynomial D in (2.9). The integer vanishing (2.13) fails later, for the
same off-by-one, and is recorded downstream of the line this gate locks.

Gates refute routes, not theorems. Catalan's constant may still be irrational.
"""

from __future__ import annotations

import hashlib
import json
import sys
from datetime import datetime, timezone
from fractions import Fraction
from math import comb
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
PDF = ROOT / "incoming" / "sun-catalan-2609.04176.pdf"
PDF_SHA256 = "0aa3bc7e80be3658630fa5d82cb773cba7ec8692d9855a70e71e47f235d2819f"
WITNESS_DELTA = Fraction(3596288, 99225)

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass


def rising_product(B: int, i: int) -> Fraction:
    """Pi_i as printed under Theorem 2.1."""
    value = Fraction(1)
    for h in range(1, B + 1):
        value *= (2 * (h + i) + 1) ** 2
    return value


def claimed_polynomial(B: int, j: int, i: int) -> Fraction:
    """The expression the proof says is a polynomial of degree <= 2B-3."""
    total = Fraction(0)
    for k in range(j):
        total += Fraction((-1) ** (j - 1 - k), (2 * (i + k) + 1) ** 2)
    return rising_product(B, i) / (2 * (i + j) + 1) * total


def forward_difference(values: list[Fraction]) -> Fraction:
    """Order-(len-1) forward difference at the start of `values`."""
    order = len(values) - 1
    return sum(
        Fraction((-1) ** i * comb(order, i)) * values[i] for i in range(order + 1)
    )


def paper_difference(B: int, j: int, a: int) -> Fraction:
    """The alternating sum the proof sets to 0 after citing van Lint-Wilson."""
    order = a + 2 * B
    return forward_difference(
        [claimed_polynomial(B, j, i) for i in range(order + 1)]
    )


def pole_numerator_at_half(B: int) -> Fraction:
    """For j = 1, (2i+1)^2 Q(i) is (2i+3) * prod_{h=2}^{B} (2i+2h+1)^2.

    At i = -1/2 every factor is a positive even integer, so the denominator
    (2i+1)^2 is essential.
    """
    i = Fraction(-1, 2)
    value = 2 * i + 3
    for h in range(2, B + 1):
        value *= (2 * i + 2 * h + 1) ** 2
    return value


def partial_tail(m: int, length: int) -> Fraction:
    total = Fraction(0)
    for r in range(length):
        total += Fraction((-1) ** r, (2 * m + 2 * r + 1) ** 2)
    return total


def recurrence_partial_holds(samples: range = range(0, 6)) -> bool:
    """S_N(m) + S_{N-1}(m+1) = 1/(2m+1)^2, the finite form of (1.4)."""
    for m in samples:
        for length in (1, 2, 5, 12):
            left = partial_tail(m, length) + partial_tail(m + 1, length - 1)
            if left != Fraction(1, (2 * m + 1) ** 2):
                return False
    return True


def tails_indexed_apart() -> dict:
    """T_0 > 8/9 > T_1, so the printed T_{i+1} is not the T_i of (2.3).

    The grouped term
        1/(4t+1)^2 - 1/(4t+3)^2 = 8(2t+1) / ((4t+1)^2 (4t+3)^2)
    is an identity of polynomials (the degree-2 difference vanishes at three
    points, hence everywhere). For every integer t >= 0 the right-hand side
    is positive. T_0 is the sum of those groups, so T_0 > 8/9. Equation (1.4)
    at m = 0 says T_1 = 1 - T_0 < 1/9.
    """
    gap = lambda t: (4 * t + 3) ** 2 - (4 * t + 1) ** 2 - 8 * (2 * t + 1)
    identity = all(gap(t) == 0 for t in (0, 1, 2))
    first = partial_tail(0, 2)
    second = Fraction(8 * (2 * 1 + 1), (4 * 1 + 1) ** 2 * (4 * 1 + 3) ** 2)
    apart = identity and first == Fraction(8, 9) and second > 0
    return {
        "group_identity": identity,
        "first_group": str(first),
        "second_group": str(second),
        "T0_exceeds_T1": apart,
    }


def downstream_integer_zero() -> dict:
    """(2.13) at i = 0 for S = 1, B = 2, lambda_1 = 1.

    (2.8) gives A(i) = T_i D(i) with
        D(X) = -(2X+3)(2X+5)^2.
    (2.12) and (1.4) then give
        K(i) = D(i) D(i+1) * ((2i+3)^2 / (2i+1)^2 - 1).
    D(-3/2) = 0, so (2.16) is not this failure.
    """
    def D(x: Fraction) -> Fraction:
        return -(2 * x + 3) * (2 * x + 5) ** 2

    i = 0
    factor = Fraction((2 * i + 3) ** 2, (2 * i + 1) ** 2) - 1
    gap = D(Fraction(i)) * D(Fraction(i + 1)) * factor
    return {
        "D0": str(D(Fraction(0))),
        "D1": str(D(Fraction(1))),
        "D_at_-3/2": str(D(Fraction(-3, 2))),
        "factor_at_0": str(factor),
        "K0": str(gap),
        "integer_zero_fails": gap != 0,
        "extra_zero_of_D": D(Fraction(-3, 2)) == 0,
    }


def pdf_identity() -> dict:
    """Refuse the Zenodo 22830611 manuscript before any arithmetic verdict."""
    if not PDF.exists():
        return {"available": False, "ok": False, "reason": "pdf missing"}
    digest = hashlib.sha256(PDF.read_bytes()).hexdigest()
    try:
        from pypdf import PdfReader
    except ImportError:
        return {"available": False, "ok": False, "reason": "pypdf missing", "sha256": digest}
    reader = PdfReader(str(PDF))
    meta = reader.metadata or {}
    author = str(meta.get("/Author") or "")
    title = str(meta.get("/Title") or "")
    arxiv = str(meta.get("/arXivID") or "")
    pages = len(reader.pages)
    text = " ".join((page.extract_text() or "") for page in reader.pages)
    text = " ".join(text.split())
    own_note = "22830611" in text or "Numerical Test of the Quadratic" in text
    ok = (
        digest == PDF_SHA256
        and author == "Zhi-Wei Sun"
        and title == "Catalan's constant is irrational"
        and arxiv == "https://arxiv.org/abs/2609.04176v1"
        and pages == 20
        and not own_note
        and "is a polynomial iniof degree at most 2B" in text
        and "(2.3)" in text
        and "(2.4)" in text
    )
    return {
        "available": True,
        "ok": ok,
        "sha256": digest,
        "author": author,
        "title": title,
        "arxiv": arxiv,
        "pages": pages,
        "is_zenodo_22830611": own_note,
    }


def main() -> int:
    delta = paper_difference(2, 1, 0)
    also = {
        "B3_j1_a0": str(paper_difference(3, 1, 0)),
        "B3_j2_a0": str(paper_difference(3, 2, 0)),
    }
    pole = pole_numerator_at_half(2)
    tails = tails_indexed_apart()
    recurrence_ok = recurrence_partial_holds()
    later = downstream_integer_zero()
    identity = pdf_identity()
    others_nonzero = all(Fraction(value) != 0 for value in also.values())
    ok = (
        identity.get("ok") is True
        and delta == WITNESS_DELTA
        and delta != 0
        and pole != 0
        and tails["T0_exceeds_T1"]
        and recurrence_ok
        and others_nonzero
        and later["integer_zero_fails"]
        and later["extra_zero_of_D"]
    )
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "target": "cat_g",
        "source": "arXiv:2609.04176v1",
        "local_pdf": "incoming/sun-catalan-2609.04176.pdf",
        "not_this_manuscript": (
            "Zenodo 22830611 is Bilar, A Numerical Test of the Quadratic "
            "Estimate in arXiv:2609.04176v1 (catalan-sun-lean). Section 9 is "
            "not this gate."
        ),
        "pdf_identity": identity,
        "lemma": (
            "Between (2.3) and (2.4): Q_j(i) is a polynomial in i of degree "
            "at most 2B-3, so its forward difference of order a+2B vanishes"
        ),
        "instance": "B=2, S=1, j=1, a=0",
        "false_instance": "order-4 difference = 3596288/99225",
        "delta": str(delta),
        "further_differences": also,
        "pole_numerator_at_-1/2": str(pole),
        "index": {
            "from_equation_2_3": "T_i",
            "displayed_before_2_4": "T_{i+1}",
            **tails,
        },
        "recurrence_1_4_partial_exact": recurrence_ok,
        "recurrence_is_the_verdict": False,
        "downstream_2_13": later,
        "dossier_line_2_16_is_not_the_witness": later["extra_zero_of_D"],
        "verdict": "BREAK" if ok else "ABORT",
        "ok": ok,
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / "cat_g_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{'PASS' if ok else 'FAIL'}] cat_g")
    print(f"  pdf: {identity.get('author')} / {identity.get('title')} / pages {identity.get('pages')}")
    print(f"  Delta(B=2,j=1,a=0) = {delta}")
    print(f"  T_0 > T_1: {tails['T0_exceeds_T1']}; (1.4) partial: {recurrence_ok}")
    print(f"  (2.13) K(0) = {later['K0']}; D(-3/2) = {later['D_at_-3/2']}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
