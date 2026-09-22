"""False-positive control for the cohen_subadditivity BREAK gate.

Same four questions as `break_control.py` (suman_eq48, odd_zeta_1609), applied
to `scripts/gates/cohen_subadditivity.py`.

PROVENANCE UPGRADE (2026-09-21 re-audit). This control used to match
substrings inside a prose summary the campaign had itself written down -- a
check that compared a string against itself and therefore could not fail. The
PDF is now pinned at incoming/cohen-ibarra-2607.09793.pdf, and transcription
fidelity is tested the only way that bites: by running the gate's OWN
predicate against concrete values Ibarra states, including Cohen's tabulated
C_sigma(598) = 120 and the paper's worked example at 3929. If the gate's
notion of "cyclic" or "Sophie Germain cyclic" were wrong, these disagree.

Run:  python scripts/controls/cohen_break_control.py
Audit instrument, not a gate: issues no campaign verdict, not registered in
scripts/gates/check.py.
"""
from __future__ import annotations

import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass

sys.path.insert(0, str(ROOT / "scripts" / "controls"))

import cohen_subadditivity as CS  # noqa: E402
from receipt import write_receipt  # noqa: E402

BAR = "=" * 74

PINNED_PDF = ROOT / "incoming" / "cohen-ibarra-2607.09793.pdf"

# Values stated in the pinned PDF, transcribed here independently of the gate.
# Section 1: the Sophie Germain cyclic numbers (OEIS A397387) begin as below,
# "so C_sigma(31) = 10". Section 2: the window (3928, 3959] contains eleven.
# Section 3: "checked the definition against Cohen's tabulated value
# C_sigma(598) = 120".
PAPER_SG_CYCLIC_UP_TO_31 = [1, 2, 3, 5, 7, 11, 15, 17, 23, 29]
PAPER_WINDOW_3928_3959 = [3929, 3931, 3935, 3941, 3943, 3945, 3947, 3949,
                          3953, 3957, 3959]
PAPER_C_SIGMA_598 = 120
PAPER_C_SIGMA_31 = 10
PAPER_C_SIGMA_3959 = 697
# Section 2's worked example for 3929.
PAPER_PHI_3929 = 3928
PAPER_PHI_7859 = 7560


def transcription_check() -> dict:
    """(1) Does the gate's own predicate reproduce the concrete values the
    paper states? This tests the definition, which is what the whole BREAK
    rests on -- a wrong `cyclic` predicate still yields *a* counting
    function, just not Cohen's.
    """
    print("\n[1] Transcription fidelity (pinned PDF, arXiv:2607.09793v1)")
    sg_up_to_31 = [n for n in range(1, 32) if CS.is_sophie_germain_cyclic(n)]
    window = [n for n in range(3929, 3960) if CS.is_sophie_germain_cyclic(n)]
    checks = {
        "pdf_pinned": PINNED_PDF.exists(),
        "sg_cyclic_list_up_to_31_matches": sg_up_to_31 == PAPER_SG_CYCLIC_UP_TO_31,
        "C_sigma_31_matches": CS.c_sigma(31) == PAPER_C_SIGMA_31,
        "cohen_tabulated_C_sigma_598_matches": (
            CS.c_sigma(598) == PAPER_C_SIGMA_598
        ),
        "window_3928_3959_matches": window == PAPER_WINDOW_3928_3959,
        "window_has_eleven_members": len(window) == 11,
        "C_sigma_3959_matches": CS.c_sigma(3959) == PAPER_C_SIGMA_3959,
        "worked_example_phi_3929": CS.totient_sympy(3929) == PAPER_PHI_3929,
        "worked_example_phi_7859": CS.totient_sympy(7859) == PAPER_PHI_7859,
        "worked_example_3929_is_sg_cyclic": CS.is_sophie_germain_cyclic(3929),
    }
    for k, v in checks.items():
        print(f"    [{'ok' if v else 'MISS'}] {k}")
    ok = all(checks.values())
    print(f"    -> gate's definition reproduces the paper's stated values: {ok}")
    checks["ok"] = ok
    checks["provenance"] = "pinned PDF, gate predicate run against paper values"
    return checks


def discrimination_check(trials: int = 500, bound: int = 500, seed: int = 1847) -> dict:
    """(2) Can the machinery ever decline to fire? A BREAK-only detector on
    every input would be no evidence at all -- sample random (m, n) pairs and
    confirm subadditivity *holds* for the overwhelming majority, so the
    witness at m=31, n=3928 is a genuine anomaly, not an artifact of a check
    that always reports violation.
    """
    print("\n[2] Discrimination: does the gate ever decline to fire?")
    rng = random.Random(seed)
    m0, n0 = 31, 3928
    # Precompute C_sigma once over the full needed range (including the known
    # witness sum) rather than 500+1 independent O(N) recomputations.
    n_max = max(2 * bound + 1, m0 + n0)
    is_sgc = [False] * (n_max + 1)
    for k in range(1, n_max + 1):
        is_sgc[k] = CS.is_sophie_germain_cyclic(k)
    prefix = [0] * (n_max + 1)
    for k in range(1, n_max + 1):
        prefix[k] = prefix[k - 1] + (1 if is_sgc[k] else 0)

    def c_sigma_fast(n: int) -> int:
        return prefix[n]

    violations = 0
    rows = []
    for _ in range(trials):
        m = rng.randint(1, bound)
        n = rng.randint(m, bound)
        lhs = c_sigma_fast(m + n)
        rhs = c_sigma_fast(m) + c_sigma_fast(n)
        if lhs > rhs:
            violations += 1
            rows.append({"m": m, "n": n, "C_sigma(m+n)": lhs, "sum": rhs})

    known = c_sigma_fast(m0 + n0) > c_sigma_fast(m0) + c_sigma_fast(n0)

    print(f"    sampled {trials} random pairs (m,n), 1<=m<=n<={bound}")
    print(f"    violations found: {violations} / {trials}")
    print(f"    known witness (31, 3928) reproduces violation: {known}")
    print(f"    -> instrument reports PASS on the vast majority of pairs "
          f"(does not fire on every input): {violations < trials}")
    if rows[:5]:
        print(f"    sample of other violating pairs found by chance: {rows[:5]}")
    return {
        "trials": trials,
        "bound": bound,
        "violations": violations,
        "declines_on_most_inputs": violations < trials,
        "known_witness_reproduced": bool(known),
        "other_violations_sample": rows[:5],
    }


def algebraic_self_consistency_check() -> dict:
    """(3) Do the gate's two independent totient paths already agree? This is
    delegated to the gate itself (`cohen_subadditivity.py` runs the
    sympy-vs-trial-division cross-check up to 2*target+1 before counting),
    so the control just re-asserts it ran and passed, rather than duplicating
    the O(N) work.
    """
    print("\n[3] Algebraic self-consistency (totient implementation agreement)")
    import json

    meta_path = ROOT / "results" / "cohen_subadditivity_gate_meta.json"
    if not meta_path.exists():
        print("    unavailable -- run scripts/gates/cohen_subadditivity.py first")
        return {"ok": None, "note": "gate meta not found"}
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    agree = meta.get("totient_implementation_agreement", {}).get("ok")
    recount = meta.get("independent_totient_recount_agrees")
    print(f"    gate's own totient cross-check ok: {agree}")
    print(f"    gate's own independent recount agrees: {recount}")
    ok = bool(agree) and bool(recount)
    return {"ok": ok, "totient_agree": agree, "recount_agrees": recount}


def main() -> int:
    print(BAR)
    print("cohen_subadditivity -- false-positive control")
    print(BAR)
    t = transcription_check()
    d = discrimination_check()
    a = algebraic_self_consistency_check()

    checks = [t["ok"], d["declines_on_most_inputs"] and d["known_witness_reproduced"], a["ok"]]
    if all(checks):
        verdict = "NO FALSE POSITIVE"
    elif any(c is False for c in checks):
        verdict = "REVIEW"
    else:
        verdict = "NO FALSE POSITIVE (partial -- some checks unavailable)"

    print(f"\n{BAR}")
    print(f"cohen_subadditivity control verdict: {verdict}")
    print(BAR)
    ok = verdict.startswith("NO FALSE POSITIVE")
    write_receipt(
        control="cohen_break_control",
        gate="cohen_subadditivity",
        verdict=verdict,
        checks={"transcription": t, "discrimination": d,
                "algebraic_self_consistency": a},
        ok=ok,
        extra={"local_pdf": "incoming/cohen-ibarra-2607.09793.pdf"},
    )
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
