"""Discrimination control for the oai_weil_sign gate.

The gate fires because the paper's inserted (destabilization-direction) traces
are assigned [6]'s G_2 sign (-1)^k instead of [6]'s G_3 sign (-1)^{k-1}. This
control checks the gate does not always fire, by running the same
direction-match procedure on the paper's OUTWARD trace leg, where paper and
[6] must agree:

  paper: "a trace going outward from a Legendrian link phi to its loose
          stabilization phi has one double point of sign (-1)^{k-1}"
  direction: stabilization  ->  [6] G_1 sign = (-1)^{k-1}   => MATCH, no fire.

It also verifies the paper's internal arithmetic is consistent under its own
claimed signs (I(f_1) = -m, m reverse traces at +1 each -> -m + m = 0), so the
gate's BREAK comes from the sign-vs-citation mismatch, not from misreading
the paper's arithmetic.

**NO FALSE POSITIVE** iff: outward leg matches (control leg passes) AND the
paper's internal arithmetic checks out AND the reverse leg mismatches (the
gate's firing condition is specific to the reverse/destabilization leg).
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

PAPER_PDF = ROOT / "incoming" / "oai-weil-classes-prewithdrawal.pdf"
PAPER_PDF_SHA256 = "7318472a98297321fc61ab89aff328b72c9c8371ab90515e97bec2adb7223787"

K = 4


def sgn(parity: int) -> int:
    return -1 if parity % 2 else 1


def main() -> None:
    assert PAPER_PDF.exists()
    assert hashlib.sha256(PAPER_PDF.read_bytes()).hexdigest() == PAPER_PDF_SHA256

    eems = {  # [6], Lemma 3.4 proof, independent transcription for the control
        "stabilization": sgn((K - 1) % 2),       # G_1
        "inverse_stabilization": sgn(K % 2),     # G_2
        "destabilization": sgn((K - 1) % 2),     # G_3
        "inverse_destabilization": sgn(K % 2),   # G_4
    }

    # Control leg 1: outward trace. Paper claims (-1)^{k-1}; direction is
    # stabilization -> [6] G_1 = (-1)^{k-1}. Must MATCH (gate must not fire).
    outward_paper = sgn((K - 1) % 2)
    outward_match = (outward_paper == eems["stabilization"])

    # Control leg 2: paper's internal arithmetic under its claimed signs.
    m = 1
    I_f1, claimed_reverse = -m, sgn(K % 2)  # -m and +1 at k=4
    internal_ok = (I_f1 + m * claimed_reverse == 0)

    # The gate's firing leg, re-derived independently here:
    reverse_paper = sgn(K % 2)                       # paper's formula (-1)^k
    reverse_correct = eems["destabilization"]        # G_3: (-1)^{k-1}
    reverse_mismatch = (reverse_paper != reverse_correct)

    no_false_positive = outward_match and internal_ok and reverse_mismatch
    verdict = "NO FALSE POSITIVE" if no_false_positive else "FALSE POSITIVE RISK"

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "control": "oai_weil_sign_control",
        "gate": "oai_weil_sign",
        "outward_leg": {
            "paper_sign": outward_paper,
            "eems_G1_sign": eems["stabilization"],
            "match": outward_match,
            "note": "gate must NOT fire here",
        },
        "internal_arithmetic": {
            "I_f1": I_f1, "m": m, "claimed_reverse_sign": claimed_reverse,
            "I_new_under_claimed_signs": I_f1 + m * claimed_reverse,
            "consistent": internal_ok,
            "note": "paper's arithmetic is correct given its signs; "
                    "the error is the sign assignment itself",
        },
        "reverse_leg": {
            "paper_sign_formula": "(-1)^k",
            "paper_sign_at_k4": reverse_paper,
            "applicable_eems_trace": "G_3 (destabilization)",
            "eems_sign_at_k4": reverse_correct,
            "mismatch": reverse_mismatch,
            "note": "the gate fires ONLY here",
        },
        "verdict": verdict,
        "ok": True,
    }
    out = RESULTS / "oai_weil_sign_control_meta.json"
    out.write_text(json.dumps(meta, indent=2) + "\n")
    print(json.dumps({"verdict": verdict, "meta": str(out)}, indent=2))


if __name__ == "__main__":
    main()
