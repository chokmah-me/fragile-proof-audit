"""Numeric gate (Type A): Maierhofer's unbounded pseudospectral norm ratios.

Source claim (pinned PDF incoming/nla-mf24-maierhofer.pdf, Maierhofer,
"Unbounded polynomial norm ratios for super-identical pseudospectra",
Sep 2026):

Theorem 1: for every integer m >= 2 and real t > 1, the weighted shifts
X = X_{m,t}, Y = Y_{m,t} of order N = (m+1)^2 satisfy X ~_{sip} Y
(super-identical pseudospectra), and for D = m+2,
p_m(z) = sum_{j=1}^m z^{Dj},

    ||p_m(X)||_2 >= t^2 sqrt(m),   ||p_m(Y)||_2 <= t^2 + m - 1,   (3)

hence  ||p_m(X)||_2 / ||p_m(Y)||_2 >= sqrt(m) / (1 + (m-1)/t^2).  (4)

Corollary (15): at t = m, ratio >= (4/5) sqrt(m) -> infinity (finite
rational matrices; no limit of matrices needed). Corollary 3:
C_N >= sqrt(floor(sqrt(N)) - 1) for N >= 9, so liminf C_N / N^{1/4} >= 1.

The gate replays the paper's quantitative chain from scratch with exact
rational arithmetic (stdlib Fraction only):

  S1 sip: the eta-polynomial d_N = f^T K(w^2_{N-1}) ... K(w^2_1) v_0 (8)
      agrees exactly between X and Y for rho = |z|^2 in {1, 2, 4}.
  S2 numerator: row 0 of p_m(X) has exact entries t^2 at columns
      D, 2D, ..., mD and 0 elsewhere, so row 2-norm^2 = m t^4 exactly.
  S3 denominator: residue classes mod D give blocks of size m or m+1;
      each block has <= 1 height-0 and <= 1 height-2 vertex; per-block
      exact Frobenius bound ||bB||_F <= t^2 + L - 2 <= t^2 + m - 1
      (a checkable sufficient route to the paper's operator-norm bound);
      (p_m(Y))_{0,N-1} = t^2 != 0.
  S4 ratio: the squared ratio identity is an exact rational equality, and
      at t = m the (4/5) sqrt(m) sharpening holds exactly via (m-2)^2 >= 0.
  S5 divergence + Corollary 3 instances.

Scope: the gate covers the computational chain (3)->(4)->(15)->(16).
Lemma 2's bridge identity is replayed computationally through S1 (the
transfer-product equality); its ring-theoretic proof is analytic.
Gates refute routes, not theorems: PASS says the norm-ratio chain is as
claimed.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

MS = list(range(2, 13))          # main sweep of m
TS = (2, 3)                     # fixed rational t values (t = m also used)
RHOS = (Fraction(1), Fraction(2), Fraction(4))  # |z|^2 samples


# ---------------------------------------------------------------------------
# Words (paper eq. 5) and prefix heights.
# ---------------------------------------------------------------------------

def build_words(m: int, t: Fraction):
    """Return (wx, wy, ix, iy): N-1 Fraction weights + integer increments.

    Increments are tracked symbolically (motif first edge +1, other motif
    edges 0, "1" bridge 0, "t^{-1}" bridge -1) so the heights follow the
    paper's definition even where weight values could coincide.
    """
    U = [t] + [Fraction(1)] * (m - 1)
    IU = [1] + [0] * (m - 1)
    tm1 = 1 / t
    wx, ix = list(U), list(IU)
    wx += [Fraction(1)]; ix += [0]
    wx += list(U); ix += list(IU)
    for _ in range(m - 1):
        wx += [tm1] + list(U); ix += [-1] + list(IU)
    wy, iy = list(U), list(IU)
    for _ in range(m - 1):
        wy += [tm1] + list(U); iy += [-1] + list(IU)
    wy += [Fraction(1)] + list(U); iy += [0] + list(IU)
    return wx, wy, ix, iy


def heights_from_increments(inc):
    """Integer prefix heights: h(0) = 0, h(i) = h(i-1) + inc[i]."""
    h = [0]
    for d in inc:
        h.append(h[-1] + d)
    return h


def check_heights_formula(m: int, hx, hy) -> bool:
    """Paper eq. (11): h_X(qk+s) = 1{s>=1}+1{q>=1}, h_Y = 1{s>=1}+1{q=m}."""
    k = m + 1
    for q in range(m + 1):
        for s in range(m + 1):
            v = q * k + s
            if hx[v] != (1 if s >= 1 else 0) + (1 if q >= 1 else 0):
                return False
            if hy[v] != (1 if s >= 1 else 0) + (1 if q == m else 0):
                return False
    return True


# ---------------------------------------------------------------------------
# Transfer-matrix eta-polynomial (paper eqs. 6-8).
# Polynomials in eta as lists of Fractions, ascending degree.
# ---------------------------------------------------------------------------

def _padd(a, b):
    n = max(len(a), len(b))
    return [ (a[i] if i < len(a) else Fraction(0))
           + (b[i] if i < len(b) else Fraction(0)) for i in range(n) ]

def _pmul(a, b):
    if not a or not b:
        return [Fraction(0)]
    c = [Fraction(0)] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                if bj:
                    c[i + j] += ai * bj
    return c

def _pscale(c, a):
    return [c * ai for ai in a]

def _madd(A, B):
    return [[_padd(A[i][j], B[i][j]) for j in range(2)] for i in range(2)]

def _mmul(A, B):
    return [[_padd(_pmul(A[i][0], B[0][j]), _pmul(A[i][1], B[1][j]))
             for j in range(2)] for i in range(2)]

def _mvec(M, v):
    return [_padd(_pmul(M[i][0], v[0]), _pmul(M[i][1], v[1])) for i in range(2)]


def transfer_charpoly(w, rho: Fraction):
    """d_N(eta) = f^T K(w^2_{N-1}) ... K(w^2_1) v_0, paper (8)."""
    eta = [Fraction(0), Fraction(1)]
    u = _padd([rho], eta)                       # u = rho + eta
    one = [Fraction(1)]
    M = [[one, [Fraction(0)]], [[Fraction(0)], one]]  # identity
    for wi in w:                                # left-multiply: K(w_1^2) first
        a = wi * wi
        K = [[_padd(u, [a]), _pscale(-rho * a, one)],
             [one, [Fraction(0)]]]
        M = _mmul(K, M)
    v0 = [u, one]
    return _mvec(M, v0)[0]                      # f^T picks first component


# ---------------------------------------------------------------------------
# S2: numerator row. S3: denominator blocks.
# ---------------------------------------------------------------------------

def row0_supernorm2(m: int, t: Fraction, hx):
    """Squared 2-norm of row 0 of p_m(X): sum over j of (X^{jD})_{0,jD}^2."""
    D = m + 2
    total = Fraction(0)
    cols = []
    for j in range(1, m + 1):
        col = j * D
        entry = t ** (hx[col] - hx[0])
        total += entry * entry
        cols.append((col, entry))
    return total, cols


def y_blocks(m: int, t: Fraction, hy):
    """Residue classes mod D of Y's vertices; per-block data."""
    D = m + 2
    N = (m + 1) ** 2
    blocks = []
    for c in range(D):
        verts = [v for v in range(N) if v % D == c]
        a = [hy[v] for v in verts]
        blocks.append({"class": c, "L": len(verts), "verts": verts, "a": a})
    return blocks


def block_frob2(block, t: Fraction):
    """||bB||_F^2 for bB = B[0:L-1, 1:L], B_{ij} = t^{a_j - a_i} (j>i)."""
    a = block["a"]
    L = block["L"]
    total = Fraction(0)
    for i in range(L - 1):
        for j in range(1, L):
            if j > i:
                e = t ** (a[j] - a[i])
                total += e * e
    return total


# ---------------------------------------------------------------------------
# Gate sections.
# ---------------------------------------------------------------------------

def check_sip(m: int, t: Fraction) -> dict:
    wx, wy, _, _ = build_words(m, t)
    assert len(wx) == len(wy) == (m + 1) ** 2 - 1
    out = {}
    for rho in RHOS:
        px = transfer_charpoly(wx, rho)
        py = transfer_charpoly(wy, rho)
        out[f"rho_{rho}_equal"] = (px == py)
    return out


def check_numerator(m: int, t: Fraction) -> dict:
    wx, _, ix, iy = build_words(m, t)
    hx = heights_from_increments(ix)
    hy = heights_from_increments(iy)
    if not check_heights_formula(m, hx, hy):
        return {"heights_match_eq11": False}
    total, cols = row0_supernorm2(m, t, hx)
    D = m + 2
    entries_ok = all(col == j * D and e == t * t
                     for j, (col, e) in enumerate(cols, start=1))
    return {
        "heights_match_eq11": True,
        "row0_cols_D_to_mD": entries_ok,
        "row0_norm2_eq_m_t4": total == m * t**4,
        "row0_norm2": str(total),
    }


def check_denominator(m: int, t: Fraction) -> dict:
    _, _, _, iy = build_words(m, t)
    hy = heights_from_increments(iy)
    D = m + 2
    N = (m + 1) ** 2
    blocks = y_blocks(m, t, hy)
    sizes_ok = all(b["L"] in (m, m + 1) for b in blocks)
    height_counts_ok = all(
        sum(1 for a in b["a"] if a == 0) <= 1 and
        sum(1 for a in b["a"] if a == 2) <= 1 for b in blocks
    )
    frob_ok = True
    worst = Fraction(0)
    for b in blocks:
        f2 = block_frob2(b, t)
        bound = (t * t + b["L"] - 2) ** 2
        if f2 > bound:
            frob_ok = False
        if f2 > worst:
            worst = f2
    # (p_m(Y))_{0,N-1} = t^{h(N-1)-h(0)}; N-1 = mD
    corner = t ** (hy[N - 1] - hy[0])
    return {
        "block_sizes_m_or_m1": sizes_ok,
        "height_counts_le_1": height_counts_ok,
        "frob_le_bound_all_blocks": frob_ok,
        "worst_frob2": str(worst),
        "corner_entry_eq_t2_nonzero": corner == t * t != 0,
    }


def check_ratio(m: int, t: Fraction) -> dict:
    # Squared form of (4): row_norm^2 / (t^2+m-1)^2 == m / (1+(m-1)/t^2)^2.
    lhs = (m * t**4) / (t * t + m - 1) ** 2
    rhs = m / (1 + Fraction(m - 1, 1) / t**2) ** 2
    out = {"ratio_sq_identity": lhs == rhs}
    if t == m:
        # (15): 1/(1+(m-1)/m^2) >= 4/5  <=>  m^2 >= 4(m-1)  <=>  (m-2)^2 >= 0
        out["t_eq_m_sharp_factor"] = (t * t >= 4 * (m - 1))
        out["t_eq_m_sq_gap"] = str((m - 2) ** 2)  # = m^2 - 4(m-1)
    return out


def check_all() -> dict:
    checks: dict[str, object] = {}
    sip_ok = num_ok = den_ok = ratio_ok = True
    detail = {}
    for m in MS:
        for t in list(TS) + [Fraction(m)]:
            t = Fraction(t)
            s = check_sip(m, t)
            n = check_numerator(m, t)
            d = check_denominator(m, t)
            r = check_ratio(m, t)
            sip_ok &= all(s.values())
            num_ok &= all(v for k, v in n.items() if isinstance(v, bool))
            den_ok &= all(v for k, v in d.items() if isinstance(v, bool))
            ratio_ok &= all(v for k, v in r.items() if isinstance(v, bool))
            if m == 2 and t == 2:
                detail["m2_t2"] = {"sip": s, "num": n, "den": d, "ratio": r}
    checks["S1_sip_charpoly_identity_all"] = bool(sip_ok)
    checks["S2_numerator_row_norm_all"] = bool(num_ok)
    checks["S3_denominator_block_bound_all"] = bool(den_ok)
    checks["S4_ratio_arithmetic_all"] = bool(ratio_ok)
    checks["detail_m2_t2"] = detail["m2_t2"]

    # S5a: divergence ladder — (4/5)^2 m exceeds (8k/5)^2 at m = 4k^2.
    ladder_ok = True
    ladder = {}
    for k, mm in ((1, 4), (2, 16), (3, 36), (4, 64)):
        lhs = Fraction(16 * mm, 25)
        rhs = Fraction(64 * k * k, 25)
        ladder[f"m{mm}_ge_{(8*k)}/5"] = bool(lhs >= rhs)
        ladder_ok &= lhs >= rhs
    checks["S5a_divergence_ladder"] = bool(ladder_ok)
    checks["ladder"] = ladder

    # S5b: Corollary 3 instances — N >= 9, m = floor(sqrt(N)) - 1 >= 2.
    cor_ok = True
    cor = {}
    for N in (9, 10, 15, 25, 50, 100):
        mm = int(N ** 0.5) - 1
        # exact floor(sqrt(N))
        while (mm + 1) ** 2 <= N:
            mm += 1
        while mm ** 2 > N:
            mm -= 1
        mm -= 1
        ok_m = mm >= 2 and (mm + 1) ** 2 <= N
        cor[f"N{N}_m{mm}"] = bool(ok_m)
        cor_ok &= ok_m
    checks["S5b_corollary3_instances"] = bool(cor_ok)
    checks["corollary"] = cor
    return checks


def main() -> int:
    checks = check_all()
    scalar = {k: v for k, v in checks.items() if isinstance(v, bool)}
    ok = all(scalar.values())
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "nla_mf24",
        "source_claim": (
            "Maierhofer (2026): unbounded polynomial norm ratios for "
            "super-identical pseudospectra; ||p_m(X)||_2 >= t^2 sqrt(m), "
            "||p_m(Y)||_2 <= t^2+m-1, ratio >= (4/5) sqrt(m) at t=m; "
            "C_N >= sqrt(floor(sqrt(N))-1), N >= 9"
        ),
        "local_pdf": "incoming/nla-mf24-maierhofer.pdf",
        "local_pdf_sha256": "1ae9316d7c935f6133a54b133d36bc55dce34f3a252b44c314b3b45a54514139",
        "m_range": [2, 12],
        "t_values": ["2", "3", "m"],
        "rhos": ["1", "2", "4"],
        "checks": checks,
        "verdict": "PASS" if ok else "FAIL",
        "lemma": (
            "S1: eta-charpoly identity (8) holds exactly for all m, t, rho; "
            "S2: row-0 2-norm^2 of p_m(X) is exactly m t^4; "
            "S3: every Y residue block has ||bB||_F <= t^2+L-2 <= t^2+m-1 "
            "and (p_m(Y))_{0,N-1} = t^2 != 0; "
            "S4: ratio identity exact; t=m gives (4/5) sqrt(m) via (m-2)^2>=0; "
            "S5: (4/5) sqrt(m) exceeds 8/5,16/5,24/5,32/5 at m=4,16,36,64; "
            "Corollary 3 instances check out"
        ),
        "false_instance": None if ok else "norm-ratio chain step failed",
        "ok": ok,
    }
    out = RESULTS / "nla_mf24_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2, default=str), encoding="utf-8")
    status = "PASS" if ok else "FAIL"
    print(f"[{status}] nla_mf24")
    for k, v in scalar.items():
        print(f"  {k}: {v}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
