"""Numeric gate: Cohen's Conjecture 66 (subadditivity of Sophie Germain
cyclic numbers) is FALSE.

Source claim (corpus/live-fragile-proofs-2024-2026.md, Target Identifier
"Cohen's Subadditivity Conjecture"; refutation Ibarra, arXiv:2607.09793):

    n is cyclic  iff  gcd(n, phi(n)) == 1
    n is Sophie Germain cyclic  iff  n and 2n+1 are both cyclic
    C_sigma(N) = #{ n in [1, N] : n is Sophie Germain cyclic }

    Cohen's Conjecture 66: C_sigma(m + n) <= C_sigma(m) + C_sigma(n)
    for all 1 <= m <= n.

Claimed counterexample (per the arXiv abstract, independently re-derived
here, not copied from the corpus doc's narrative numbers): m = 31,
n = 3928, C_sigma(3959) = 697 > 696 = C_sigma(31) + C_sigma(3928).

Gates refute routes, not theorems: this does not claim anything about
Cohen's Conjecture 66 beyond the single counterexample computed below.
"""

from __future__ import annotations

import json
import math
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"


def totient_sympy(n: int) -> int:
    from sympy import totient

    return int(totient(n))


def totient_trial_division(n: int) -> int:
    """Independent, non-sympy Euler totient via trial-division factorization.

    Implementation-equivalence check against sympy.totient, per the
    "ceremony" verdict discipline (docs/GATE-BEFORE-PROVE.md): exact
    counting, so what needs auditing is that the two totient paths agree,
    not discrimination power.
    """
    result = n
    m = n
    p = 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1 if p == 2 else 2
    if m > 1:
        result -= result // m
    return result


def is_cyclic(n: int, totient=totient_sympy) -> bool:
    if n < 1:
        return False
    return math.gcd(n, totient(n)) == 1


def is_sophie_germain_cyclic(n: int, totient=totient_sympy) -> bool:
    return is_cyclic(n, totient) and is_cyclic(2 * n + 1, totient)


def c_sigma(n_max: int, totient=totient_sympy) -> int:
    return sum(1 for n in range(1, n_max + 1) if is_sophie_germain_cyclic(n, totient))


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    m, n = 31, 3928
    target = m + n  # 3959

    # Implementation-equivalence self-test: both totient paths must agree
    # on every n up to the largest value the gate will touch (2*target+1)
    # before either is trusted for the count.
    check_upper = 2 * target + 1
    mismatches = [
        k
        for k in range(1, check_upper + 1)
        if totient_sympy(k) != totient_trial_division(k)
    ]
    totient_agree = len(mismatches) == 0

    c_m = c_sigma(m)
    c_n = c_sigma(n)
    c_target = c_sigma(target)

    # Cross-check the full counterexample range with the independent
    # trial-division totient path too, not just sympy.
    c_m_td = c_sigma(m, totient_trial_division)
    c_n_td = c_sigma(n, totient_trial_division)
    c_target_td = c_sigma(target, totient_trial_division)
    counts_agree = (c_m, c_n, c_target) == (c_m_td, c_n_td, c_target_td)

    subadditivity_claim_holds = c_target <= c_m + c_n
    ok = totient_agree and counts_agree and not subadditivity_claim_holds

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "cohen_subadditivity",
        "source_claim": "Cohen's Conjecture 66 (subadditivity of C_sigma)",
        "source_refutation": "Ibarra, J. A. (2026), arXiv:2607.09793",
        "corpus_pointer": "corpus/live-fragile-proofs-2024-2026.md",
        "m": m,
        "n": n,
        "target": target,
        "C_sigma_m": c_m,
        "C_sigma_n": c_n,
        "C_sigma_target": c_target,
        "C_sigma_m_plus_n": c_m + c_n,
        "totient_implementation_agreement": {
            "checked_up_to": check_upper,
            "mismatches": mismatches,
            "ok": totient_agree,
        },
        "independent_totient_recount_agrees": counts_agree,
        "subadditivity_claim_holds": subadditivity_claim_holds,
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": "C_sigma(m+n) <= C_sigma(m) + C_sigma(n) for all 1<=m<=n",
        "instance": f"m={m}, n={n}",
        "false_instance": (
            f"C_sigma({target})={c_target} > "
            f"{c_m + c_n}=C_sigma({m})+C_sigma({n})"
        ),
        "ok": ok,
    }
    out = RESULTS / "cohen_subadditivity_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] cohen_subadditivity")
    print(f"  C_sigma({m}) = {c_m}")
    print(f"  C_sigma({n}) = {c_n}")
    print(f"  C_sigma({target}) = {c_target}  (sum = {c_m + c_n})")
    print(f"  totient implementations agree up to {check_upper}: {totient_agree}")
    print(f"  independent recount agrees: {counts_agree}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
