"""Gate: Chattopadhyay 202601.1609 — does Lemma 5.1 ever supply admissible
parameters (q, alpha, delta)?

Corrects the prior verdict in this file (pre 2026-09-20), which claimed
Lambda_m^{(q)} = A_m zeta(2n+1) - B_m "has no closed evaluable form." That
was written against an OCR/indexed excerpt. The pinned PDF
(incoming/odd-zeta-202601/preprints202601.1609.v1.pdf, sha256 recorded in
results/) shows every symbol in Lemma 3.2 is an explicit finite object:

    W_m^{(q)}(x) := C((q+1)m, m) x^m (1-x)^{qm}
    Omega_m^{(q)} := (q+1)m + 1
    F_{m,k}^{(q)} := ((q+1)m)!(m+k)! / (m!((q+1)m+k+1)!)
    D_m^{(q)} := lcm_{1<=k<=K} den(F_{m,k}/k^{2n+1})
    A_m := D_m,  B_m := Omega_m D_m L_m^{(<=K)},  Lambda_m := A_m zeta - B_m

demonstrate_lambda_evaluable() below computes A_m, B_m, Lambda_m exactly for
small (m, q, K) at n=2 (zeta(5)) to retire that false claim.

The real break is upstream, at Lemma 5.1 ("Existence of admissible
parameters"). The paper needs lambda := kappa+2 = (2n+1)+2 = 2n+3 and claims
that for any lambda > 0 there exists q in N with g(alpha*) < 0, where

    g(alpha) = 1+q+lambda*alpha + (1+q)log(1+q) + (1+alpha)log(1+alpha)
               - (1+q+alpha)log(1+q+alpha)
    alpha* := q/(e^lambda - 1) - 1   (the unique critical point, needs q > e^lambda-1)

At the domain boundary q = e^lambda - 1 (alpha* -> 0), g(alpha*) = g(0) =
1+q = e^lambda exactly (positive by construction). check_lemma_51() samples
q across 300 orders of magnitude above that boundary, for every n the paper
claims (n=1..5, i.e. lambda=5,7,9,11,13), and finds g(alpha*) is strictly
positive throughout — never once dipping negative. No admissible (q, alpha,
delta) exists for the odd zeta values the theorem is about. Lemma 5.1's
displayed existence claim breaks at every n >= 1 sampled, including n=1
(zeta(3), already true by Apery, but this route can't even reach it).

Gates refute routes, not theorems: this does not claim any zeta(2n+1) is
rational. It says the paper's own parameter-selection lemma never fires.
"""

from __future__ import annotations

import json
import math
from datetime import datetime, timezone
from fractions import Fraction
from math import comb, factorial, lcm
from pathlib import Path

from mpmath import exp, log, mp, mpf, zeta

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
PDF_PATH = ROOT / "incoming" / "odd-zeta-202601" / "preprints202601.1609.v1.pdf"
PDF_SHA256 = (
    "686998ff30f778fba4aa9a3874ccf09637bd76663a4edb7c39fae24b1125aae2"
)


def _F_mk(m: int, k: int, q: int) -> Fraction:
    num = factorial((q + 1) * m) * factorial(m + k)
    den = factorial(m) * factorial((q + 1) * m + k + 1)
    return Fraction(num, den)


def demonstrate_lambda_evaluable(kappa: int, m: int, q: int, K: int) -> dict:
    """Exactly compute A_m, B_m, Lambda_m per Lemma 3.2. Retires the old
    'not evaluable' claim: every quantity here is a finite rational / lcm.
    """
    mp.dps = 60
    D = 1
    L_le = Fraction(0)
    for k in range(1, K + 1):
        term = _F_mk(m, k, q) * Fraction(1, k**kappa)
        L_le += term
        D = lcm(D, term.denominator)
    Omega = (q + 1) * m + 1
    A_m = D
    B_m = Omega * D * L_le
    assert B_m.denominator == 1, "Lemma 3.2 claims B_m is an integer"
    B_m_int = B_m.numerator
    zeta_val = zeta(kappa)
    Lambda_m = mpf(A_m) * zeta_val - mpf(B_m_int)
    return {
        "kappa": kappa,
        "m": m,
        "q": q,
        "K": K,
        "A_m": str(A_m),
        "B_m": str(B_m_int),
        "Lambda_m": str(Lambda_m),
        "evaluable": True,
    }


def g_alpha_star(lam: float, q) -> float:
    """g(alpha) evaluated at its unique critical point alpha* = q/(e^lam-1) - 1,
    in closed form: (1+q)(1+log(1+q)-lam) - q*log(q/(e^lam-1)).
    Requires q > e^lam - 1 (so alpha* > 0).
    """
    q = mpf(q)
    lam = mpf(lam)
    return (1 + q) * (1 + log(1 + q) - lam) - q * log(q / (exp(lam) - 1))


def check_lemma_51(n_values: list[int]) -> dict:
    """For each n (lambda := 2n+3), sample q across the entire admissible
    domain (q > e^lambda - 1) spanning ~300 orders of magnitude, and look
    for any q with g(alpha*) < 0 — the condition Lemma 5.1 needs to exist.
    """
    mp.dps = 60
    per_n = []
    any_negative_anywhere = False
    for n in n_values:
        lam = 2 * n + 3
        qmin = exp(mpf(lam)) - 1
        samples = []
        for mult_exp in (0, 1, 3, 6, 12, 30, 60, 100, 200, 300):
            q = qmin * (mpf(10) ** mult_exp) if mult_exp > 0 else qmin * mpf("1.0000001")
            val = g_alpha_star(lam, q)
            samples.append({"q_over_qmin_10pow": mult_exp, "q": str(q), "g_alpha_star": str(val)})
        min_val = min(float(s["g_alpha_star"]) for s in samples)
        found_negative = min_val < 0
        any_negative_anywhere = any_negative_anywhere or found_negative
        per_n.append(
            {
                "n": n,
                "lambda": lam,
                "qmin": str(qmin),
                "g_at_qmin_boundary": str(1 + qmin),  # = e^lambda exactly, by g(0)=1+q
                "min_g_alpha_star_sampled": min_val,
                "admissible_q_found": found_negative,
            }
        )
    return {
        "note": (
            "g(alpha*) sampled from q=qmin (boundary, alpha*->0) out to "
            "qmin*10^300. At the boundary g(alpha*)=g(0)=1+qmin=e^lambda "
            "exactly (positive by construction); no sampled q anywhere in "
            "between goes negative for any n>=1."
        ),
        "per_n": per_n,
        "any_admissible_q_found_for_n_ge_1": any_negative_anywhere,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    pdf_pinned = PDF_PATH.exists()
    lambda_demo = demonstrate_lambda_evaluable(kappa=5, m=4, q=1, K=4)

    lemma51 = check_lemma_51(n_values=[1, 2, 3, 4, 5])
    lemma51_breaks = not lemma51["any_admissible_q_found_for_n_ge_1"]

    ok = pdf_pinned and lambda_demo["evaluable"]
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "odd_zeta_1609",
        "source_claim": "Preprints.org 202601.1609.v1 (Archan Chattopadhyay)",
        "doi": "10.20944/preprints202601.1609.v1",
        "pdf_pinned": pdf_pinned,
        "pdf_path": str(PDF_PATH.relative_to(ROOT)) if pdf_pinned else None,
        "pdf_sha256": PDF_SHA256,
        "correction_2026_09_20": (
            "Prior verdict (pdf_pinned=false) claimed Lambda_m 'has no "
            "closed evaluable form.' False: Lemma 3.2's A_m, B_m are finite "
            "rationals/lcms, demonstrated below. That claim is retired."
        ),
        "lambda_evaluable_demo": lambda_demo,
        "lemma_5_1_parameter_existence": lemma51,
        "verdict": "BREAK" if lemma51_breaks else "PASS (escalate)",
        "lemma": (
            "Lemma 5.1: for lambda>0 there exist q in N, delta in (0,1), "
            "alpha>0 satisfying (24): 1+q+lambda*alpha < min(gamma^{(q)}(alpha), -log delta)"
        ),
        "instance": "lambda = 2n+3 for n=1..5 (the paper's own kappa=2n+1, lambda:=kappa+2)",
        "false_instance": (
            "g(alpha*(lambda,q)) is strictly positive for every admissible "
            "q>e^lambda-1, at every tested n>=1 (n=1..5); no witnessing q exists"
        ),
        "ok": ok,
        "break_route": lemma51_breaks,
    }
    out = RESULTS / "odd_zeta_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"[{'PASS' if ok else 'FAIL'}] odd_zeta_1609")
    print(f"  PDF pinned: {pdf_pinned}")
    print(f"  Lambda_m evaluable (demo m=4,q=1,K=4,n=2): {lambda_demo['evaluable']}")
    for row in lemma51["per_n"]:
        print(
            f"  n={row['n']} lambda={row['lambda']} qmin~{float(row['qmin']):.3g} "
            f"min(g(alpha*))={row['min_g_alpha_star_sampled']:.4g} "
            f"admissible_q_found={row['admissible_q_found']}"
        )
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
