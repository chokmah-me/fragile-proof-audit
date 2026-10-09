"""Sign-convention gate: "Algebraicity of Weil classes on split abelian eightfolds"
(OpenAI, 2026-09-18; withdrawn 2026-10-06 for a sign error).

Source claim (Lemma 3.6 proof): inserting m reverse stabilization traces cancels
the m negative double points, i.e. the total signed double count becomes
I(f_1) + m = 0, meeting the hypothesis of Eliashberg-Murphy's exact
cancellation theorem ([9, Theorem 2.3]).

This gate replays the sign assignment from the paper's own text against its own
cited authority for the trace signs ([6, Lemma 3.2 and proof of Lemma 3.4]:
Ekholm-Eliashberg-Murphy-Smith, arXiv:1303.0588v2).

The paper's inserted traces run "from the m-fold stabilization at the innermost
end to phi_0 outward" -- i.e. each trace goes from a MORE stabilized link to a
LESS stabilized one: the destabilization direction. In [6]'s taxonomy that is
the G_3 trace (lift of the destabilization homotopy), whose double-point sign
is (-1)^{k-1}. The paper instead assigns its inserted traces the sign (-1)^k --
the sign of [6]'s G_2 trace (lift of the *inverse* stabilization homotopy), a
different geometric object. Same direction, different homotopy, opposite sign.

At k = 4 (the paper's source dimension is 8 = 2k): the paper claims each
reverse trace contributes +1; the correct sign per [6]'s G_3 is -1. The replayed
signed count is I_new = -m + m*(-1) = -2m != 0, so the paper's own stated
Eliashberg-Murphy hypothesis ("its signed double count is zero") is not met
and the subsequent oriented-surgery / embedded-brane construction is
unsupported.

**Confirm** (route survives): the paper's sign assignment matches [6]'s table
for the trace direction actually used, and the replayed count is zero.
**Break** (route refuted): the sign assignment contradicts [6] for the used
direction, and the replayed count is nonzero -- the cancellation hypothesis
fails.

Calibration note: this is a TRUE-POSITIVE calibration target. The manuscript
was withdrawn on 2026-10-06 with a notice describing exactly this sign error.
The gate is constructed without using the withdrawal notice: every finding is
derived from the pre-withdrawal PDF and its cited reference [6].
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

# ---------------------------------------------------------------------------
# Pinned claim artifact: pre-withdrawal manuscript (openai/math @ adc7f1241).
# ---------------------------------------------------------------------------
PAPER_PDF = ROOT / "incoming" / "oai-weil-classes-prewithdrawal.pdf"
PAPER_PDF_SHA256 = "7318472a98297321fc61ab89aff328b72c9c8371ab90515e97bec2adb7223787"
PAPER_REPO_REV = "adc7f1241b42e322a6451854ab7e4b4c146bf78a"

# ---------------------------------------------------------------------------
# Pinned cited authority for the trace signs: [6] in the paper's bibliography.
# Ekholm-Eliashberg-Murphy-Smith, arXiv:1303.0588v2, Lemma 3.4 proof.
# G_1 = lift of stabilization homotopy      -> I(G_1) = (-1)^{k-1}
# G_2 = lift of inverse stabilization       -> I(G_2) = (-1)^k
# G_3 = lift of destabilization homotopy    -> I(G_3) = (-1)^{k-1}
# G_4 = lift of inverse destabilization     -> I(G_4) = (-1)^k
# ---------------------------------------------------------------------------
EEMS_ARXIV = "arXiv:1303.0588v2"

K = 4  # source dimension 8 = 2k, Lemma 3.6


def sign_pow(neg_one_exp_parity: int) -> int:
    """(-1)^e for integer e>=0, via parity bit (0=even,1=odd)."""
    return -1 if neg_one_exp_parity % 2 else 1


def main() -> None:
    # --- pin check: the manuscript PDF must be the pre-withdrawal revision ---
    assert PAPER_PDF.exists(), f"missing pinned PDF: {PAPER_PDF}"
    digest = hashlib.sha256(PAPER_PDF.read_bytes()).hexdigest()
    assert digest == PAPER_PDF_SHA256, f"PDF hash drift: {digest}"

    # --- the paper's own statements (Lemma 3.6 proof, pre-withdrawal PDF) ---
    # Direction of the inserted traces:
    paper_trace_direction = "destabilization"  # "from the m-fold stabilization
    #   at the innermost end to phi_0 outward": stabilized -> destabilized
    # Paper's sign formula for the inserted ("reverse") traces:
    paper_reverse_sign_formula = (-1) ** K          # paper: "the reverse trace
    #   has sign (-1)^k"; (3.6): at k=4 the reverse sign is +1
    paper_reverse_sign_claimed = sign_pow(K % 2)    # = +1
    assert paper_reverse_sign_claimed == 1
    # Paper's signed count of the initial immersion:
    m_positive = True  # "Put m = -I(f_1) > 0"
    I_f1 = -1  # in units of m (I(f_1) = -m); use m = 1 w.l.o.g. for the replay
    m = 1
    # Paper's conclusion:
    paper_I_new = I_f1 * m + m * paper_reverse_sign_claimed  # I(f_1) + m = 0
    assert paper_I_new == 0, "paper's internal arithmetic must check out"

    # --- [6]'s sign table (Lemma 3.4 proof, arXiv:1303.0588v2) ---
    # keyed by trace direction as used in the construction
    eems_sign = {
        "stabilization": sign_pow((K - 1) % 2),      # G_1: (-1)^{k-1}
        "inverse_stabilization": sign_pow(K % 2),    # G_2: (-1)^k
        "destabilization": sign_pow((K - 1) % 2),    # G_3: (-1)^{k-1}
        "inverse_destabilization": sign_pow(K % 2),  # G_4: (-1)^k
    }

    # --- direction match: the paper's inserted traces are destabilization
    #     direction, so the applicable [6] sign is G_3's, not G_2's ---
    correct_reverse_sign = eems_sign[paper_trace_direction]
    sign_match = (paper_reverse_sign_claimed == correct_reverse_sign)

    # --- replay the signed count with the corrected sign ---
    replayed_I_new = I_f1 * m + m * correct_reverse_sign

    # --- the paper's own Eliashberg-Murphy hypothesis (stated in the proof):
    #     "its signed double count is zero" ---
    em_hypothesis_met = (replayed_I_new == 0)

    verdict = "BREAK" if (not sign_match and not em_hypothesis_met) else "PASS"

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "oai_weil_sign",
        "source_claim": "OpenAI (2026-09-18): m reverse stabilization traces "
                        "cancel m negative double points; total signed count "
                        "I(f_1)+m = 0, meeting Eliashberg-Murphy [9, Thm 2.3]",
        "source_refutation": "withdrawn 2026-10-06 (sign error); this gate "
                             "replays the sign assignment from the paper's own "
                             "text against its cited [6], without using the "
                             "withdrawal notice",
        "local_pdf": "incoming/oai-weil-classes-prewithdrawal.pdf",
        "local_pdf_sha256": PAPER_PDF_SHA256,
        "repo_revision": PAPER_REPO_REV,
        "cited_authority": EEMS_ARXIV + " Lemma 3.4 proof (ref [6])",
        "k": K,
        "paper_trace_direction": paper_trace_direction,
        "paper_reverse_sign_formula": "(-1)^k",
        "paper_reverse_sign_at_k4": paper_reverse_sign_claimed,
        "eems_sign_table": eems_sign,
        "applicable_eems_trace": "G_3 (destabilization lift)",
        "correct_reverse_sign_at_k4": correct_reverse_sign,
        "sign_assignment_matches_citation": sign_match,
        "paper_internal_arithmetic_consistent": paper_I_new == 0,
        "replayed_signed_count_I_new": replayed_I_new,
        "replayed_I_new_symbolic": "-2m",
        "eliashberg_murphy_zero_count_hypothesis_met": em_hypothesis_met,
        "verdict": verdict,
        "lemma": "each inserted reverse stabilization trace has sign (-1)^k "
                 "(hence +1 at k=4), so m traces cancel I(f_1) = -m",
        "false_instance": "the inserted traces run stabilized->destabilized "
                          "(G_3 direction); [6] gives G_3 sign (-1)^{k-1} = -1 "
                          "at k=4, not (-1)^k = +1; replayed count -2m != 0, "
                          "so the Eliashberg-Murphy zero-count hypothesis "
                          "fails on the paper's own terms",
        "calibration": "TRUE POSITIVE target: manuscript withdrawn 2026-10-06 "
                       "for this sign error; gate uses only pre-withdrawal PDF "
                       "and [6]; NOT on the 32-gate verdict lock",
        "ok": True,
    }
    out = RESULTS / "oai_weil_sign_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2) + "\n")
    print(json.dumps({"verdict": verdict,
                      "sign_match": sign_match,
                      "replayed_I_new": replayed_I_new,
                      "meta": str(out)}, indent=2))


if __name__ == "__main__":
    main()
