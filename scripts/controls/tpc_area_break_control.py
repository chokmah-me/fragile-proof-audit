"""Discrimination control for tpc_area.

The gate reports BREAK for a uniform C(l_0). This instrument asks whether
that report is forced:

  * f = 1 has S(x,1) = x and Q = x(x-1)/2, so C = 1 works at every x.
    The gate's own correlation/quadratic must see that.
  * The dossier function 1_{3|n} has S(12,1) = 0. It must stay classified
    as outside Theorem 2.3's hypothesis, not as the break.
  * The pinned PDF states Theorem 2.3 with a constant C(l_0) described as fixed.
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

import tpc_area as TPC  # noqa: E402
from receipt import write_receipt  # noqa: E402

PDF = ROOT / "incoming" / "agama-twin-1707.03265v4.pdf"
NEEDLES = (
    "Theorem 2.3.Let",
    "constantC:=C(l 0)>0fixed",
    "By inverting this inequality, the result follows immediately.",
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
    # f = 1 is a genuine regime of the claimed inequality.
    ones_rows = []
    ones_ok = True
    for x in (2, 12, 100, 1000):
        ess = TPC.correlation(TPC.ones, x, 1)
        queue = TPC.quadratic(TPC.ones, x)
        holds = ess == x and queue == x * (x - 1) // 2 and x * ess >= queue
        ones_ok = ones_ok and holds
        ones_rows.append({"x": x, "S": ess, "Q": queue, "C1_holds": holds})

    dossier_s = TPC.correlation(TPC.multiples_of_3, 12, 1)
    dossier_q = TPC.quadratic(TPC.multiples_of_3, 12)
    dossier_not_the_break = dossier_s == 0 and dossier_q == 6

    # Repaired f really does leave the hypothesis (S = 2) and then escape
    # every fixed C. Recomputed here rather than trusted from the gate module's
    # closed form: at x = 30, Q > x*S; at x = 300 the ratio is larger still.
    rep_30_s = TPC.correlation(TPC.repaired, 30, 1)
    rep_30_q = TPC.quadratic(TPC.repaired, 30)
    rep_300_s = TPC.correlation(TPC.repaired, 300, 1)
    rep_300_q = TPC.quadratic(TPC.repaired, 300)
    repaired_breaks = (
        rep_30_s == 2
        and rep_30_q > 30 * rep_30_s
        and rep_300_q / (300 * rep_300_s) > rep_30_q / (30 * rep_30_s)
    )

    identity_ok = TPC.double_sum(TPC.repaired, 30) == TPC.quadratic(TPC.repaired, 30)

    text = pdf_text()
    if text is None:
        transcription = {"available": False, "ok": False}
    else:
        hits = {needle: needle in text for needle in NEEDLES}
        transcription = {"available": True, "hits": hits, "ok": all(hits.values())}

    ok = (
        ones_ok
        and dossier_not_the_break
        and repaired_breaks
        and identity_ok
        and transcription["ok"]
    )
    verdict = "NO FALSE POSITIVE" if ok else "CONTROL_FAILED"
    write_receipt(
        control="tpc_area_break_control",
        gate="tpc_area",
        verdict=verdict,
        checks={
            "ones_C1_holds": ones_rows,
            "dossier_outside_hypothesis": {
                "S": dossier_s,
                "Q": dossier_q,
                "not_used_as_break": dossier_not_the_break,
            },
            "repaired_breaks_uniform_C": {
                "x30": {"S": rep_30_s, "Q": rep_30_q},
                "x300_ratio": rep_300_q / (300 * rep_300_s),
                "ok": repaired_breaks,
            },
            "corollary_identity_at_30": identity_ok,
            "pdf_transcription": transcription,
        },
        ok=ok,
        extra={"local_pdf": "incoming/agama-twin-1707.03265v4.pdf"},
    )
    print(f"[{verdict}] tpc_area_break_control")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
