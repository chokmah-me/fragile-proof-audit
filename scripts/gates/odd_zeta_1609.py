"""Gate: Chattopadhyay 202601.1609 — can we evaluate Λ_m at ζ(5)?

Lemma 3.2 defines
    A_m^{(q)} := D_m^{(q)}
    B_m^{(q)} := Ω_m^{(q)} D_m^{(q)} L_m^{(q)(≤K)}
    Λ_m^{(q)}  = A_m ζ(2n+1) − B_m
               = Ω_m D_m L_m^{(>K)}

Those symbols are not closed forms. Failure to evaluate Λ_m for ζ(5) is a
BREAK of the displayed-forms route, not a reason to invent a kernel or to
fall back to Kim.

A side check of g(α)<0 is recorded separately and is NOT the Λ_m gate.
"""

from __future__ import annotations

import json
import math
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

# Symbols Lemma 3.2 needs before Λ_m is a number.
REQUIRED_FOR_LAMBDA = {
    "W_m_q": "asymmetric beta kernel",
    "S_m_q": "kernel CDF",
    "Omega_m_q": "prefactor in (11)–(12)",
    "F_m_k": "weights in Σ F_{m,k}/k^{2n+1}",
    "L_m_q": "weighted / truncated polylog moments",
    "K": "truncation cutoff as a function of m",
    "D_m_q": "explicit LCM range for denominators",
}

# What the extract actually recovered as closed expressions.
QUOTED_CLOSED = {
    "g_alpha": (
        "g(α) = 1+q+λα + (1+q)log(1+q) + (1+α)log(1+α) "
        "− (1+q+α)log(1+q+α)"
    ),
    "A_m_definition": "A_m^{(q)} := D_m^{(q)}  (LCM, not a sequence formula)",
    "B_m_definition": "B_m^{(q)} := Ω_m D_m L_m^{(≤K)}",
    "Lambda_m_definition": "Λ_m = A_m ζ(2n+1) − B_m = Ω_m D_m L_m^{(>K)}",
}


def g_alpha(alpha: float, q: float, lam: float) -> float:
    """Paper's g(α). Not Λ_m."""
    return (
        1.0
        + q
        + lam * alpha
        + (1.0 + q) * math.log(1.0 + q)
        + (1.0 + alpha) * math.log(1.0 + alpha)
        - (1.0 + q + alpha) * math.log(1.0 + q + alpha)
    )


def g_side_check() -> dict:
    """Existence of some (q,λ,α) with g<0. Independent of Λ_m evaluability.

    Sample near the paper's critical point α* = (1+q − e^λ)/(e^λ − 1)
    with λ small enough that α* > 0 (λ < log(1+q)).
    """
    samples = []
    found_neg = False
    for q in (1, 2, 5, 10):
        for lam in (0.01, 0.05, 0.1):
            if not (0 < lam < math.log(1.0 + q)):
                continue
            alpha_star = (1.0 + q - math.exp(lam)) / (math.exp(lam) - 1.0)
            if alpha_star <= 0:
                continue
            val = g_alpha(alpha_star, q, lam)
            rec = {
                "q": q,
                "lambda": lam,
                "alpha_star": alpha_star,
                "g_at_alpha_star": val,
            }
            samples.append(rec)
            if val < 0:
                found_neg = True
    return {
        "note": "NOT the Λ_m gate. Parameter existence for (24) only.",
        "found_g_negative": found_neg,
        "samples": samples[:8],
    }


def try_lambda_zeta5() -> dict:
    """The actual gate: produce A,B,Λ at n=2 (ζ(5)) for some (m,q)."""
    missing = list(REQUIRED_FOR_LAMBDA.keys())
    return {
        "target": "zeta(5)",
        "n": 2,
        "requested": {"m": 1, "q": 1},
        "A_m": None,
        "B_m": None,
        "Lambda_m": None,
        "missing_symbols": missing,
        "evaluable": False,
        "reason": (
            "Lemma 3.2 defines A_m as an LCM D_m and B_m via Ω, truncated "
            "moments L(≤K), and unnamed kernel W. No closed (m,q) → (A,B)."
        ),
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    lam = try_lambda_zeta5()
    gcheck = g_side_check()
    # BREAK iff Λ_m cannot be evaluated. g(α) is informational only.
    ok = True  # gate script itself succeeded
    break_route = not lam["evaluable"]
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "odd_zeta_1609",
        "source_claim": "Preprints.org 202601.1609.v1",
        "doi": "10.20944/preprints202601.1609.v1",
        "pdf_pinned": False,
        "quoted_closed_forms": QUOTED_CLOSED,
        "required_for_Lambda": REQUIRED_FOR_LAMBDA,
        "lambda_zeta5": lam,
        "g_alpha_side_check": gcheck,
        "verdict": "BREAK" if break_route else "EVALUABLE",
        "lemma": "displayed integer forms Λ_m^{(q)} = A_m ζ(2n+1) − B_m with evaluable A_m, B_m",
        "instance": "ζ(5), m=1, q=1 (any explicit pair would have sufficed)",
        "false_instance": "A_m, B_m are defined only in terms of ungiven D_m, Ω_m, L_m, K, W_m",
        "ok": ok,
        "break_route": break_route,
    }
    out = RESULTS / "odd_zeta_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{'PASS' if ok else 'FAIL'}] odd_zeta_1609")
    print(f"  evaluable Λ_m at ζ(5): {lam['evaluable']}")
    print(f"  missing: {', '.join(lam['missing_symbols'])}")
    print(f"  g(α)<0 exists (side, not Λ_m): {gcheck['found_g_negative']}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    # Script PASS means the gate ran honestly. BREAK is the mathematical verdict.
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
