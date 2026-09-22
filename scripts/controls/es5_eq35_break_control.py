"""Discrimination control for es5_eq35.

Equation (35) is reported false. The same equality checker must accept the
two neighboring identities the proof actually computes correctly: (34), whose
denominators (35) copies, and p4 at y = 1, which is the specialization (35)
claims to be. A checker that rejects every formula is not evidence.

The pinned PDF must contain the printed line (the 7x+2 left-hand side next
to the 84x+14 denominator) and the author's own skip of q ≡ 0 (mod 252).
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

import es5_eq35 as ES  # noqa: E402
from receipt import write_receipt  # noqa: E402

PDF = ROOT / "incoming" / "es5-2508.07367.pdf"
NEEDLES = (
    "5[12(7x + 2)] + 1 = 1 84x + 14",
    "does not address the case",
)


def pdf_text() -> str | None:
    if not PDF.exists():
        return None
    try:
        from pypdf import PdfReader
    except ImportError:
        return None
    pages = (page.extract_text() or "" for page in PdfReader(str(PDF)).pages)
    return " ".join(" ".join(pages).split())


def main() -> int:
    sample = range(0, 9)
    eq34_ok = ES.holds(ES.eq34, sample)
    p4_ok = ES.holds(ES.p4_y1, sample)
    eq33_ok = ES.holds(ES.eq33, sample)
    eq35_bad = all(left != right for left, right in (ES.eq35(x) for x in sample))
    left0, right0 = ES.eq35(0)
    x0_is_five_over = left0 == ES.Fraction(5, 121) and right0 == ES.Fraction(5, 61)
    text = pdf_text()
    if text is None:
        transcription = {"available": False, "ok": False}
    else:
        hits = {needle: needle in text for needle in NEEDLES}
        transcription = {"available": True, "hits": hits, "ok": all(hits.values())}
    ok = eq34_ok and p4_ok and eq33_ok and eq35_bad and x0_is_five_over and transcription["ok"]
    verdict = "NO FALSE POSITIVE" if ok else "CONTROL_FAILED"
    write_receipt(
        control="es5_eq35_break_control",
        gate="es5_eq35",
        verdict=verdict,
        checks={
            "eq34_holds": eq34_ok,
            "p4_y1_holds": p4_ok,
            "eq33_holds": eq33_ok,
            "eq35_fails": eq35_bad,
            "x0": {"lhs": str(left0), "rhs": str(right0), "is_5_121_vs_5_61": x0_is_five_over},
            "pdf_transcription": transcription,
        },
        ok=ok,
        extra={"local_pdf": "incoming/es5-2508.07367.pdf"},
    )
    print(f"[{verdict}] es5_eq35_break_control")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
