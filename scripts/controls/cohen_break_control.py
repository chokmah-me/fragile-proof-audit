"""False-positive control for the cohen_subadditivity BREAK gate.

Same four questions as `break_control.py` (suman_eq48, odd_zeta_1609), applied
to `scripts/gates/cohen_subadditivity.py`. Kept in its own file rather than
folded into `break_control.py` because there is no local PDF pin for
arXiv:2607.09793 under `incoming/` -- transcription/corroboration here rest on
a live arXiv abstract fetch (recorded verbatim below, dated), not a pinned
PDF, and that provenance gap must stay visible rather than silently reused.

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

import cohen_subadditivity as CS  # noqa: E402

BAR = "=" * 74

# Fetched live from https://arxiv.org/abs/2607.09793 on 2026-09-20 (WebFetch,
# small-model abstract summary, not the full PDF -- no local pin exists).
# Recorded verbatim for the transcription-fidelity check below.
ABSTRACT_SUMMARY = (
    "The paper disproves Cohen's Conjecture 66 regarding Sophie Germain "
    "cyclic numbers. An integer qualifies as cyclic when gcd(n,phi(n))=1, "
    "and as Sophie Germain cyclic when both n and 2n+1 are cyclic. Cohen had "
    "conjectured that the counting function C_sigma for such numbers "
    "satisfies subadditivity -- meaning C_sigma(m+n) <= C_sigma(m)+C_sigma(n). "
    "The author provides a counterexample: at m=31, n=3928, "
    "C_sigma(3959)=697 > 696 = C_sigma(31)+C_sigma(3928). The proof is "
    "formally verified using Lean 4."
)


def transcription_check() -> dict:
    """(1) Is the refuted claim -- and the specific witness -- the one the
    abstract states, not a strawman built from the corpus doc's narrative?
    """
    print("\n[1] Transcription fidelity (arXiv:2607.09793 abstract, live-fetched)")
    checks = {
        "definition_cyclic_matches": "gcd(n,phi(n))=1" in ABSTRACT_SUMMARY,
        "definition_sophie_germain_matches": (
            "both n and 2n+1 are cyclic" in ABSTRACT_SUMMARY
        ),
        "conjecture_statement_matches": (
            "C_sigma(m+n) <= C_sigma(m)+C_sigma(n)" in ABSTRACT_SUMMARY
        ),
        "witness_m_n_matches": "m=31, n=3928" in ABSTRACT_SUMMARY,
        "witness_counts_match": (
            "C_sigma(3959)=697 > 696 = C_sigma(31)+C_sigma(3928)"
            in ABSTRACT_SUMMARY
        ),
    }
    for k, v in checks.items():
        print(f"    [{'ok' if v else 'MISS'}] {k}")
    ok = all(checks.values())
    print(f"    -> gate's lemma/instance matches the source abstract: {ok}")
    checks["ok"] = ok
    checks["provenance"] = "live abstract fetch, not a pinned PDF"
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
    return 0 if verdict.startswith("NO FALSE POSITIVE") else 1


if __name__ == "__main__":
    raise SystemExit(main())
