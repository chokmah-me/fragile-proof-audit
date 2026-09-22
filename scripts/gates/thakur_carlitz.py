"""Numeric gate: Thakur's 2015 Carlitz-Wieferich degree-divisibility
conjecture is FALSE in odd characteristic.

Source claim (corpus/live-fragile-proofs-2024-2026.md, Target Identifier
"Thakur's Carlitz-Wieferich Primes Conjecture, 2026 Refutation,
arXiv:2607.15305"): every c-Wieferich prime of F_q[T] (q an odd prime power)
has degree divisible by the characteristic p. Refutation: D. Niedbala
Giraudin, "A counterexample to a conjecture of Thakur on Carlitz-Wieferich
primes," arXiv:2607.15305v2 [math.NT].

NOTE ON PROVENANCE: like the Tang-Zhang target, the corpus doc's own bullets
for this item reference numbered inline images (the explicit quintic
polynomial, field data) whose numeric content was never transcribed by the AI
deep-research export -- the corpus doc alone cannot support a gate. This gate
is built directly from the pinned PDF's Theorem 1.1 and Appendix A verification
code, read via this campaign's own PDF tool, not from the corpus doc's
paraphrase. Local PDF: incoming/thakur-carlitz-2607.15305.pdf.

Setup. A = F_q[T], [n] = T^{q^n} - T. The Carlitz module gives rho_P(1); a
monic prime P of degree d is c-Wieferich (to base 1) if rho_P(1) = 1 (mod
P^2). Thakur's M_d = sum_{k=0}^{d-1} (-1)^k [d-1][d-2]...[d-k] (k=0 term 1)
satisfies (Lemma 2.1 of the paper): P is c-Wieferich <=> P | M_d <=> M_d(theta)
= 0 for theta a root of P. Thakur conjectured every c-Wieferich prime has
degree divisible by p in odd characteristic.

Theorem 1.1 (the counterexample): over F_{19^3} = F_19[c], c^3 = 8c^2+4c+11,
the explicit quintic

    P(T) = T^5 + (11+17c+9c^2)T^4 + (3+7c+18c^2)T^3 + (2+5c+6c^2)T^2
           + (3+3c+11c^2)T + (6+17c+5c^2)

is an irreducible c-Wieferich prime of degree 5, and 19 does not divide 5.

This gate reproduces that claim from scratch: it builds F_{19^3} and F_{19^3}
[T]/(P) with its own pure-Python finite-field engine (scripts/harness/
finite_field.py -- no galois/Sage/PARI available on this laptop), checks
irreducibility of P via the standard distinct-degree test (P | [5] and P has
no linear factor), and checks the c-Wieferich condition via two independently
coded formulas for M_5(theta): the paper's nested form (eq. 2) and the raw
alternating-sum definition, both required to vanish and required to agree.

Gates refute routes, not theorems: this gates the single explicit
counterexample of Theorem 1.1, not the companion-paper minimality claim
(Theorem 5.1, degree 4 impossible) or the closed-form/gcd claims of
Theorem 4.1 / Conjecture 4.2, which are not computed here.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
sys.path.insert(0, str(ROOT))

from scripts.harness.finite_field import (  # noqa: E402
    Elt,
    FPoly,
    fpoly_add,
    fpoly_deg,
    fpoly_gcd,
    fpoly_mod,
    fpoly_mul,
    fpoly_pow_mod,
    fpoly_sub,
    fpoly_trim,
    ff_one,
    ff_zero,
)

P_CHAR = 19
K_EXT = 3
# c^3 = 8c^2 + 4c + 11 (mod 19)  <=>  modulus poly x^3 - 8x^2 - 4x - 11, i.e.
# low-to-high coeffs (-11, -4, -8, 1) mod 19 = (8, 15, 11, 1).
MODULUS_EXT = [8, 15, 11, 1]
Q = P_CHAR**K_EXT  # 6859

# Theorem 1.1's quintic, coefficients low-to-high as (a0,a1,a2) meaning
# a0 + a1*c + a2*c^2 in F_{19^3}, transcribed directly from the pinned PDF.
POLY_P: FPoly = [
    (6, 17, 5),
    (3, 3, 11),
    (2, 5, 6),
    (3, 7, 18),
    (11, 17, 9),
    (1, 0, 0),
]


def frobenius_iterates(modulus: list[int], p: int, k: int, q: int, poly: FPoly, count: int) -> list[FPoly]:
    """[T, T^q, T^{q^2}, ..., T^{q^count}] mod `poly`, each obtained by
    raising the previous iterate to the q-th power (Frobenius commutes with
    itself: (X^{q^{j-1}})^q = X^{q^j})."""
    zero, one = ff_zero(k), ff_one(k)
    cur: FPoly = [zero, one]  # T itself
    iterates = [cur]
    for _ in range(count):
        cur = fpoly_pow_mod(cur, q, poly, p, modulus)
        iterates.append(cur)
    return iterates


def m5_nested(y: dict[int, FPoly], p: int, modulus: list[int], poly: FPoly, k: int) -> FPoly:
    """Eq. (2) of the paper: M_d(theta) = 1 - y_{d-1}(1 - y_{d-2}(...(1-y_1)...))."""
    one: FPoly = [ff_one(k)]
    inner = fpoly_sub(one, y[1], p)
    for j in (2, 3, 4):
        inner = fpoly_mod(fpoly_mul(y[j], inner, p, modulus), poly, p, modulus)
        inner = fpoly_sub(one, inner, p)
    return inner


def m5_raw_sum(y: dict[int, FPoly], p: int, modulus: list[int], poly: FPoly, k: int) -> FPoly:
    """Direct alternating-sum definition: M_5 = sum_{j=0}^{4} (-1)^j [4][3]...[4-j+1],
    i.e. k=0 term 1, k=1 term -y4, k=2 term +y4*y3, k=3 term -y4*y3*y2,
    k=4 term +y4*y3*y2*y1. Independently coded from m5_nested (different
    formula, same target quantity -- a from-scratch cross-check, not a
    rearrangement of the same code path)."""
    one: FPoly = [ff_one(k)]
    zero: FPoly = [ff_zero(k)]
    total = one
    term = one
    sign = 1
    for factor_idx in (4, 3, 2, 1):
        term = fpoly_mod(fpoly_mul(term, y[factor_idx], p, modulus), poly, p, modulus)
        sign = -sign
        signed = term if sign == 1 else [tuple((-c) % p for c in coeff) for coeff in term]
        total = fpoly_add(total, signed, p)
    return fpoly_trim(total)


def check_c_wieferich(p: int, modulus: list[int], k: int, q: int, poly: FPoly, degree: int):
    """Generic engine, reused by the discrimination control at other (p,
    modulus, degree) instances. Returns a dict with irreducibility and
    c-Wieferich verdicts plus the two independently-computed M_d values."""
    iterates = frobenius_iterates(modulus, p, k, q, poly, degree)
    zero_pt: FPoly = [ff_zero(k), ff_one(k)]  # X, for the linear-factor gcd test
    linear_gcd = fpoly_gcd(fpoly_sub(iterates[1], zero_pt, p), poly, p, modulus)
    no_linear_factor = fpoly_deg(linear_gcd) == 0
    frobenius_closes = fpoly_trim(iterates[degree]) == fpoly_trim(zero_pt)
    irreducible = no_linear_factor and frobenius_closes

    y = {j: fpoly_sub(iterates[j], zero_pt, p) for j in range(1, degree)}
    m_nested = m5_nested(y, p, modulus, poly, k) if degree == 5 else None
    m_raw = m5_raw_sum(y, p, modulus, poly, k) if degree == 5 else None

    if degree != 5:
        # Generic M_d via the raw alternating-sum definition only (used by
        # the control for non-degree-5 positive controls at (d,p)=(6,3)).
        m_generic = _md_raw_sum_generic(y, p, modulus, poly, k, degree)
        is_wieferich = fpoly_is_zero_local(m_generic, k)
        return {
            "irreducible": irreducible,
            "no_linear_factor": no_linear_factor,
            "frobenius_closes": frobenius_closes,
            "m_generic_zero": is_wieferich,
            "is_c_wieferich": irreducible and is_wieferich,
        }

    both_zero = fpoly_is_zero_local(m_nested, k) and fpoly_is_zero_local(m_raw, k)
    paths_agree = fpoly_trim(m_nested) == fpoly_trim(m_raw)
    return {
        "irreducible": irreducible,
        "no_linear_factor": no_linear_factor,
        "frobenius_closes": frobenius_closes,
        "m5_nested_zero": fpoly_is_zero_local(m_nested, k),
        "m5_raw_sum_zero": fpoly_is_zero_local(m_raw, k),
        "paths_agree": paths_agree,
        "is_c_wieferich": irreducible and both_zero and paths_agree,
    }


def fpoly_is_zero_local(a: FPoly, k: int) -> bool:
    z = ff_zero(k)
    t = fpoly_trim(a)
    return len(t) == 1 and t[0] == z


def _md_raw_sum_generic(y: dict[int, FPoly], p: int, modulus: list[int], poly: FPoly, k: int, d: int) -> FPoly:
    one: FPoly = [ff_one(k)]
    total = one
    term = one
    sign = 1
    for factor_idx in range(d - 1, 0, -1):
        term = fpoly_mod(fpoly_mul(term, y[factor_idx], p, modulus), poly, p, modulus)
        sign = -sign
        signed = term if sign == 1 else [tuple((-c) % p for c in coeff) for coeff in term]
        total = fpoly_add(total, signed, p)
    return fpoly_trim(total)


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    result = check_c_wieferich(P_CHAR, MODULUS_EXT, K_EXT, Q, POLY_P, degree=5)

    degree_is_5 = True  # by construction (6 coefficients, leading term T^5)
    divisibility_fails = (5 % P_CHAR) != 0  # "19 does not divide 5"

    ok = (
        result["irreducible"]
        and result["no_linear_factor"]
        and result["frobenius_closes"]
        and result["m5_nested_zero"]
        and result["m5_raw_sum_zero"]
        and result["paths_agree"]
        and degree_is_5
        and divisibility_fails
    )

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "thakur_carlitz",
        "source_claim": (
            "Thakur (2015): every c-Wieferich prime of F_q[T] (q an odd prime "
            "power) has degree divisible by the characteristic p"
        ),
        "source_refutation": (
            "D. Niedbala Giraudin (2026), arXiv:2607.15305v2, Theorem 1.1"
        ),
        "corpus_pointer": "corpus/live-fragile-proofs-2024-2026.md",
        "local_pdf": "incoming/thakur-carlitz-2607.15305.pdf",
        "instance": "q=19^3=F_19[c]/(c^3-8c^2-4c-11), explicit quintic P(T), degree 5, char 19",
        "field": f"F_{{{P_CHAR}^{K_EXT}}} via pure-Python engine (scripts/harness/finite_field.py)",
        "irreducible": result["irreducible"],
        "no_linear_factor_over_Fq": result["no_linear_factor"],
        "P_divides_bracket_5": result["frobenius_closes"],
        "m5_nested_form_zero": result["m5_nested_zero"],
        "m5_raw_sum_form_zero": result["m5_raw_sum_zero"],
        "two_independent_m5_paths_agree": result["paths_agree"],
        "degree_is_5": degree_is_5,
        "char_does_not_divide_degree": divisibility_fails,
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": "every c-Wieferich prime of F_q[T] (odd char) has degree divisible by p",
        "false_instance": (
            "explicit irreducible degree-5 c-Wieferich prime P over F_{19^3}, "
            "and 19 does not divide 5"
        ),
        "ok": ok,
    }
    out = RESULTS / "thakur_carlitz_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] thakur_carlitz")
    print(f"  irreducible: {result['irreducible']} (no_linear_factor={result['no_linear_factor']}, "
          f"P|[5]={result['frobenius_closes']})")
    print(f"  M5(theta)=0: nested={result['m5_nested_zero']} raw_sum={result['m5_raw_sum_zero']} "
          f"agree={result['paths_agree']}")
    print(f"  degree=5, 19|5: {not divisibility_fails}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
