"""Gate: Du–Yao PDN1 congruences (arXiv:2503.00004).

Type D checks (exact integer q-series, no Sage/Magma/Mathematica):

1. Generating function harness:
       Σ PDN1(n) q^n = J_2² / J_1⁵,  J_k = (q^k; q^k)_∞
   with PDN1(2) = 18 (paper Fig. 1.2).

2. Theorem 1.1 / 1.2 arithmetic-progression congruences for small α
   (samples covering the Andrews–Paule base cases and one higher layer).

3. Fifth-order modular equation (3.13) among the Γ₀(10) functions u,t
   (load-bearing CAS output for the mod-5 induction).

Type E notebook replay of the authors' Mathematica supplements is
capability-limited on this stack (no Mathematica). Supplements are pinned
under incoming/pdn1/; (4.8) seventh-order equation deferred (Appendix B /
105-page mod-7 PDF — same method as (3.13), not required to land 2(g)).

PASS  = all executable checks match (escalate).
BREAK = GF, congruence, or (3.13) mismatch.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from math import comb
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

PDN1_N = 700  # need ≥ 625+599 for Thm 1.1 α=2 sample (625n+599)
MOD_EQ_N = 80


def series_mul(A: list[int], B: list[int], N: int) -> list[int]:
    C = [0] * (N + 1)
    for i, ai in enumerate(A):
        if not ai:
            continue
        for j in range(0, N - i + 1):
            bj = B[j]
            if bj:
                C[i + j] += ai * bj
    return C


def series_add(A: list[int], B: list[int], N: int) -> list[int]:
    return [A[i] + B[i] for i in range(N + 1)]


def series_scale(A: list[int], c: int, N: int) -> list[int]:
    return [c * A[i] for i in range(N + 1)]


def series_pow(A: list[int], e: int, N: int) -> list[int]:
    out = [0] * (N + 1)
    out[0] = 1
    for _ in range(e):
        out = series_mul(out, A, N)
    return out


def series_pow_inv(e: int, r: int, N: int) -> list[int]:
    out = [0] * (N + 1)
    if r == 0:
        out[0] = 1
        return out
    for k in range(0, N // e + 1):
        out[k * e] = comb(k + r - 1, k)
    return out


def shift(A: list[int], s: int, N: int) -> list[int]:
    out = [0] * (N + 1)
    for i, ai in enumerate(A):
        if ai and i + s <= N:
            out[i + s] = ai
    return out


def eta_delta_body(delta: int, N: int) -> list[int]:
    """∏_n (1 − q^{δ n}) truncated (omit q^{δ/24})."""
    out = [0] * (N + 1)
    out[0] = 1
    n = 1
    while delta * n <= N:
        fac = [0] * (N + 1)
        fac[0] = 1
        fac[delta * n] = -1
        out = series_mul(out, fac, N)
        n += 1
    return out


def inv_eta_delta_body(delta: int, N: int) -> list[int]:
    out = [0] * (N + 1)
    out[0] = 1
    n = 1
    while delta * n <= N:
        out = series_mul(out, series_pow_inv(delta * n, 1, N), N)
        n += 1
    return out


def J_k(k: int, N: int) -> list[int]:
    return eta_delta_body(k, N)


def inv_J_k(k: int, N: int) -> list[int]:
    return inv_eta_delta_body(k, N)


def pdn1_series(N: int) -> list[int]:
    """Σ PDN1(n) q^n = J_2² / J_1⁵."""
    j2sq = series_mul(J_k(2, N), J_k(2, N), N)
    inv = inv_J_k(1, N)
    inv5 = inv
    for _ in range(4):
        inv5 = series_mul(inv5, inv, N)
    return series_mul(j2sq, inv5, N)


def build_u_T(N: int) -> tuple[list[int], list[int]]:
    """u(q) and T(q)=q·t(q) for the Γ₀(10) hauptmodul pair in §3."""
    u_body = series_pow(eta_delta_body(10, N), 7, N)
    u_body = series_mul(u_body, inv_eta_delta_body(1, N), N)
    u_body = series_mul(u_body, series_pow(inv_eta_delta_body(2, N), 3, N), N)
    u_body = series_mul(u_body, series_pow(inv_eta_delta_body(5, N), 3, N), N)
    u = shift(u_body, 2, N)  # q-valuation of u is +2

    T = series_mul(series_pow(eta_delta_body(1, N), 3, N), eta_delta_body(5, N), N)
    T = series_mul(T, inv_eta_delta_body(2, N), N)
    T = series_mul(T, series_pow(inv_eta_delta_body(10, N), 3, N), N)
    return u, T


def check_t_relation(u: list[int], T: list[int], N: int) -> dict:
    """Paper (3.6): t² = u⁻¹ − 5t  ⇔  u T² + 5 u T q − q² = 0 with T=qt."""
    lhs = series_mul(u, series_mul(T, T, N), N)
    lhs = series_add(lhs, series_scale(shift(series_mul(u, T, N), 1, N), 5, N), N)
    diff = lhs[:]
    if 2 <= N:
        diff[2] -= 1
    mx = max(abs(x) for x in diff)
    return {"ok": mx == 0, "max_abs_diff": mx}


# σ_i polynomials from Lemma 3.2 (terms: coeff, power of u, whether × t).
SIGMA_TERMS: dict[int, list[tuple[int, int, bool]]] = {
    1: [
        (1125, 1, False),
        (30, 1, True),
        (114625, 2, False),
        (10625, 2, True),
        (3137500, 3, False),
        (435000, 3, True),
        (31015625, 4, False),
        (5359375, 4, True),
        (100000000, 5, False),
        (19921875, 5, True),
    ],
    2: [
        (635, 1, False),
        (5, 1, True),
        (96500, 2, False),
        (8825, 2, True),
        (2925000, 3, False),
        (406875, 3, True),
        (30250000, 4, False),
        (5250000, 4, True),
        (100000000, 5, False),
        (20000000, 5, True),
    ],
    3: [
        (160, 1, False),
        (31125, 2, False),
        (2700, 2, True),
        (1025625, 3, False),
        (140625, 3, True),
        (11062500, 4, False),
        (1912500, 4, True),
        (37500000, 5, False),
        (7500000, 5, True),
    ],
    4: [
        (20, 1, False),
        (4525, 2, False),
        (375, 2, True),
        (160000, 3, False),
        (21625, 3, True),
        (1796875, 4, False),
        (309375, 4, True),
        (6250000, 5, False),
        (1250000, 5, True),
    ],
    5: [
        (1, 1, False),
        (250, 2, False),
        (20, 2, True),
        (9375, 3, False),
        (1250, 3, True),
        (109375, 4, False),
        (18750, 4, True),
        (390625, 5, False),
        (78125, 5, True),
    ],
}


def eval_sigma(terms: list[tuple[int, int, bool]], u: list[int], T: list[int], N: int) -> list[int]:
    up: list[list[int]] = [[0] * (N + 1) for _ in range(6)]
    up[0][0] = 1
    up[1] = u
    for a in range(2, 6):
        up[a] = series_mul(up[a - 1], u, N)
    out = [0] * (N + 1)
    for c, a, has_t in terms:
        term = series_scale(up[a], c, N)
        if has_t:
            prod = series_mul(term, T, N)
            shifted = [0] * (N + 1)
            for i in range(1, N + 1):
                shifted[i - 1] = prod[i]
            term = shifted
        out = series_add(out, term, N)
    return out


def stretch(A: list[int], m: int, N: int) -> list[int]:
    out = [0] * (N + 1)
    for i, ai in enumerate(A):
        if ai and m * i <= N:
            out[m * i] = ai
    return out


def check_modular_eq_313(N: int) -> dict:
    """Lemma 3.2 / (3.13): u⁵ = Σ_{i=1}^5 σ_i(q⁵) u^{5−i}."""
    u, T = build_u_T(N)
    t_rel = check_t_relation(u, T, N)
    powers = {0: [0] * (N + 1)}
    powers[0][0] = 1
    powers[1] = u
    for a in range(2, 6):
        powers[a] = series_mul(powers[a - 1], u, N)
    rhs = [0] * (N + 1)
    for i in range(1, 6):
        sig = eval_sigma(SIGMA_TERMS[i], u, T, N)
        rhs = series_add(rhs, series_mul(stretch(sig, 5, N), powers[5 - i], N), N)
    diff = series_add(powers[5], series_scale(rhs, -1, N), N)
    mx = max(abs(x) for x in diff)
    return {
        "ok": mx == 0 and t_rel["ok"],
        "max_abs_diff": mx,
        "t_relation": t_rel,
        "N": N,
    }


def residue_thm11(alpha: int, kind: str, r: int | None = None) -> tuple[int, int, int]:
    """Return (modulus, residue, power) for Theorem 1.1 instances."""
    if kind == "1.7":
        mod = 5 ** (2 * alpha)
        res = (23 * 5 ** (2 * alpha) + 1) // 24
        power = 5**alpha
        return mod, res, power
    if kind == "1.8":
        assert r is not None
        mod = 5 ** (2 * alpha + 1)
        res = (r * 5 ** (2 * alpha) + 1) // 24
        power = 5 ** (alpha + 1)
        return mod, res, power
    raise ValueError(kind)


def residue_thm12(alpha: int, kind: str) -> tuple[int, int, int]:
    if kind == "1.9":
        mod = 7 ** (2 * alpha - 1)
        res = (17 * 7 ** (2 * alpha - 1) + 1) // 24
        power = 7**alpha
        return mod, res, power
    if kind == "1.10":
        mod = 7 ** (2 * alpha)
        res = (23 * 7 ** (2 * alpha) + 1) // 24
        power = 7 ** (alpha + 1)
        return mod, res, power
    raise ValueError(kind)


def check_progression(
    P: list[int], mod: int, res: int, power: int, *, nmax: int
) -> dict:
    fails: list[dict] = []
    checked = 0
    for n in range(nmax):
        idx = mod * n + res
        if idx >= len(P):
            break
        checked += 1
        if P[idx] % power != 0:
            fails.append({"n": n, "index": idx, "value": P[idx]})
            if len(fails) >= 3:
                break
    return {
        "mod": mod,
        "residue": res,
        "power": power,
        "checked": checked,
        "ok": len(fails) == 0 and checked > 0,
        "failures": fails,
    }


def run_congruences(P: list[int]) -> dict:
    rows = []
    specs = [
        ("1.7", 1, None, 20),
        ("1.8", 1, 71, 4),
        ("1.8", 1, 119, 4),
        ("1.7", 2, None, 1),
        ("1.9", 1, None, 40),
        ("1.10", 1, None, 10),
        ("1.9", 2, None, 2),
    ]
    all_ok = True
    for kind, alpha, r, nmax in specs:
        if kind.startswith("1.7") or kind.startswith("1.8"):
            mod, res, power = residue_thm11(alpha, kind, r)
            label = f"Thm1.1 {kind} α={alpha}" + (f" r={r}" if r else "")
        else:
            mod, res, power = residue_thm12(alpha, kind)
            label = f"Thm1.2 {kind} α={alpha}"
        row = check_progression(P, mod, res, power, nmax=nmax)
        row["label"] = label
        rows.append(row)
        all_ok = all_ok and row["ok"]
    return {"rows": rows, "all_ok": all_ok}


def notebook_status() -> dict:
    mod5 = ROOT / "incoming" / "pdn1" / "mod5"
    mod7 = ROOT / "incoming" / "pdn1" / "mod7"
    return {
        "status": "capability-limited",
        "reason": (
            "Authors' supplements are Mathematica notebooks "
            "(github.com/tztgm1/PDN1-congruences-modulo-5 and -modulo-7). "
            "Campaign stack has no Mathematica; full CAS transcript replay "
            "and seventh-order equation (4.8) are not executed here."
        ),
        "pinned": {
            "mod5_dir": str(mod5.relative_to(ROOT)) if mod5.is_dir() else None,
            "mod7_dir": str(mod7.relative_to(ROOT)) if mod7.is_dir() else None,
            "mod5_nb": (mod5 / "U-values-on-PDN1-congruences-modulo-5.nb").exists(),
            "mod7_nb": (mod7 / "U-values-PDN1-congruences-modulo-7.nb").exists(),
        },
        "note": "Blocked notebook replay is not a BREAK of the congruence route.",
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    P = pdn1_series(PDN1_N)
    gf = {
        "formula": "J_2^2 / J_1^5",
        "PDN1_2": P[2],
        "expected_PDN1_2": 18,
        "ok": P[2] == 18,
        "head": P[:12],
    }
    cong = run_congruences(P)
    mod_eq = check_modular_eq_313(MOD_EQ_N)
    notebooks = notebook_status()

    if not gf["ok"] or not cong["all_ok"] or not mod_eq["ok"]:
        verdict = "BREAK"
    else:
        verdict = "PASS"

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": "2g",
        "source": "arXiv:2503.00004",
        "pdf": "incoming/pdn1-2503.00004.pdf",
        "generating_function": gf,
        "congruences": cong,
        "modular_eq_313": mod_eq,
        "notebook_replay": notebooks,
        "verdict": verdict,
        "note": (
            "PASS escalates the Type-D GF/congruence/(3.13) route. "
            "Does not certify (4.8) or the full Mathematica supplements."
        ),
    }
    out = RESULTS / "pdn1_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print("[PASS] pdn1" if verdict == "PASS" else "[BREAK] pdn1")
    print(f"  GF PDN1(2)={P[2]} (expect 18): {'ok' if gf['ok'] else 'FAIL'}")
    for row in cong["rows"]:
        print(
            f"  {row['label']}: "
            f"{'ok' if row['ok'] else 'FAIL'} "
            f"checked={row['checked']} ≡0 (mod {row['power']}) "
            f"on {row['mod']}n+{row['residue']}"
        )
    print(
        f"  modular eq (3.13) N={MOD_EQ_N}: "
        f"{'ok' if mod_eq['ok'] else 'FAIL'} max_diff={mod_eq['max_abs_diff']}"
    )
    print(f"  notebook replay: {notebooks['status']}")
    print(f"  verdict: {verdict}")
    print(f"Wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
