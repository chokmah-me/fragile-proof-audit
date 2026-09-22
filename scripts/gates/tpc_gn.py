"""Numeric gate: the evaluation display in Proposition 3.4 is not an identity.

Source: Parikshit Chalise, Antwan Clark, and Edinah K. Gnang,
arXiv:2410.13840v2 (23 Oct 2024), Proposition 3.4, page 7.
incoming/gnang-tpc-2410.13840v2.pdf.

The proposition says that for every complete labeling sigma in Phi(g),

    P_g(sigma, y)
      = ∓ prod_{k in Z_n} (k!)^n
        * prod_{0 <= i < j < n}
            prod_{u in Z_{i+1}, v in Z_{j+1}}
              ((y - k)(y - v) - (y - j)(y - u))
      ≠ 0.

The right-hand side does not depend on sigma except for the written sign.
The left-hand side is V(sigma) times the product of cross-tree edge
differences. On the augmented stars

    g = ((0, 1, 2), (0, 0, 2), (0, 0, 0))

both

    sigma_A = ((0, 1, 2), (1, 0, 2), (2, 0, 1))
    sigma_B = ((0, 1, 2), (2, 0, 1), (1, 0, 2))

lie in Phi(g). Each has Vandermonde factor -8, and
prod_k (k!)^3 = 8, so that factor of the display is right up to sign.
The coefficient of y^3 in P_g is -3072 at sigma_A and 6144 at sigma_B.
Those polynomials are not negatives of each other, and neither is zero.

The index k in the printed edge factor is not one of i, j, u, v. The
mismatch above does not depend on reading that letter as i or as j:
either repair is still independent of sigma.

Lemma 3.10 is not the witness. The Gyárfás–Lehel conjecture is not the
witness. The 1 Sep 2026 withdrawal names Lemma 3.10 and is not this
calculation.

Gates refute routes, not theorems.
"""

from __future__ import annotations

import hashlib
import json
import sys
from datetime import datetime, timezone
from itertools import combinations
from math import factorial
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
PDF = ROOT / "incoming" / "gnang-tpc-2410.13840v2.pdf"
PDF_SHA256 = "943968bc54e737bb10b79f2bbafa97a0866733960d1fbfe732b0357d13eaf378"

N = 3
# Augmented stars: g_k fixes every vertex outside Z_{k+1} and sends Z_{k+1} to k.
G = ((0, 1, 2), (0, 0, 2), (0, 0, 0))
SIGMA_A = ((0, 1, 2), (1, 0, 2), (2, 0, 1))
SIGMA_B = ((0, 1, 2), (2, 0, 1), (1, 0, 2))

for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass


def pdf_identity() -> dict:
    if not PDF.exists():
        return {"available": False, "ok": False, "reason": "pdf missing"}
    digest = hashlib.sha256(PDF.read_bytes()).hexdigest()
    pages = None
    head = ""
    try:
        import pypdf

        reader = pypdf.PdfReader(str(PDF))
        pages = len(reader.pages)
        head = reader.pages[0].extract_text() or ""
    except Exception as exc:  # noqa: BLE001 — identity is recorded either way
        head = f"unreadable: {exc}"
    ok = (
        digest == PDF_SHA256
        and pages == 15
        and "2410.13840v2" in head
        and "CHALISE" in head.upper()
        and "GNANG" in head.upper()
    )
    return {
        "available": True,
        "ok": ok,
        "sha256": digest,
        "pages": pages,
        "authors": "Parikshit Chalise, Antwan Clark, Edinah K. Gnang",
        "title": "A Proof of the Tree Packing Conjecture",
        "arxiv": "https://arxiv.org/abs/2410.13840v2",
    }


def endpoint_sets(gs: tuple[tuple[int, ...], ...], sigmas: tuple[tuple[int, ...], ...]) -> set[tuple[int, int]]:
    """Unordered endpoint pairs, loops included, of the labeled tree edges."""
    found: set[tuple[int, int]] = set()
    for k, (g, sigma) in enumerate(zip(gs, sigmas)):
        for v in range(k + 1):
            a, b = sigma[v], sigma[g[v]]
            found.add((a, b) if a <= b else (b, a))
    return found


def looped_complete(n: int) -> set[tuple[int, int]]:
    return {(a, b) for a in range(n) for b in range(a, n)}


def in_phi(gs: tuple[tuple[int, ...], ...], sigmas: tuple[tuple[int, ...], ...]) -> bool:
    """Definition 3.3: the endpoint sets are exactly the edges of looped K_n."""
    n = len(gs)
    found = endpoint_sets(gs, sigmas)
    return found == looped_complete(n) and len(found) == n * (n + 1) // 2


def vandermonde(sigmas: tuple[tuple[int, ...], ...]) -> int:
    """V(sigma) = prod_k prod_{u < v} (sigma_k(v) - sigma_k(u))."""
    n = len(sigmas)
    value = 1
    for sigma in sigmas:
        for u in range(n):
            for v in range(u + 1, n):
                value *= sigma[v] - sigma[u]
    return value


def factorial_product(n: int) -> int:
    """The absolute Vandermonde factor printed in Proposition 3.4."""
    value = 1
    for k in range(n):
        value *= factorial(k) ** n
    return value


def edge_quadratic(head: int, tail: int) -> tuple[int, int, int]:
    """(y - head)(y - tail) as coefficients of (1, y, y^2), low degree first."""
    return (head * tail, -(head + tail), 1)


def mul(left: tuple[int, ...], right: tuple[int, ...]) -> tuple[int, ...]:
    out = [0] * (len(left) + len(right) - 1)
    for i, a in enumerate(left):
        for j, b in enumerate(right):
            out[i + j] += a * b
    return tuple(out)


def scale(poly: tuple[int, ...], factor: int) -> tuple[int, ...]:
    return tuple(factor * c for c in poly)


def cross_edge_product(
    gs: tuple[tuple[int, ...], ...], sigmas: tuple[tuple[int, ...], ...]
) -> tuple[int, ...]:
    """E_g(sigma, y): product of differences of edge polynomials on distinct trees."""
    n = len(gs)
    acc: tuple[int, ...] = (1,)
    for i in range(n):
        for j in range(i + 1, n):
            for u in range(i + 1):
                for v in range(j + 1):
                    sj, gj = sigmas[j], gs[j]
                    si, gi = sigmas[i], gs[i]
                    pj = edge_quadratic(sj[gj[v]], sj[v])
                    pi = edge_quadratic(si[gi[u]], si[u])
                    diff = (pj[0] - pi[0], pj[1] - pi[1], pj[2] - pi[2])
                    acc = mul(acc, diff)
    return acc


def packing_polynomial(
    gs: tuple[tuple[int, ...], ...], sigmas: tuple[tuple[int, ...], ...]
) -> tuple[int, ...]:
    """P_g(sigma, y) = V(sigma) * E_g(sigma, y), low degree first."""
    return scale(cross_edge_product(gs, sigmas), vandermonde(sigmas))


def edge_polynomials(
    gs: tuple[tuple[int, ...], ...], sigmas: tuple[tuple[int, ...], ...]
) -> tuple[tuple[int, int, int], ...]:
    polys: list[tuple[int, int, int]] = []
    for k, (g, sigma) in enumerate(zip(gs, sigmas)):
        for v in range(k + 1):
            polys.append(edge_quadratic(sigma[g[v]], sigma[v]))
    return tuple(sorted(polys))


def all_pairs_difference(polys: tuple[tuple[int, int, int], ...]) -> tuple[int, ...]:
    """Product of (p - q) over unordered pairs of distinct edge polynomials.

    This product sees only the set of edges of looped K_n. It does not see
    which tree owns which edge, so it is the same for every complete labeling.
    """
    acc: tuple[int, ...] = (1,)
    for left, right in combinations(polys, 2):
        diff = (left[0] - right[0], left[1] - right[1], left[2] - right[2])
        acc = mul(acc, diff)
    return acc


def coeff(poly: tuple[int, ...], degree: int) -> int:
    if degree < 0 or degree >= len(poly):
        return 0
    return poly[degree]


def main() -> int:
    identity = pdf_identity()
    poly_a = packing_polynomial(G, SIGMA_A)
    poly_b = packing_polynomial(G, SIGMA_B)
    coeff_a = coeff(poly_a, 3)
    coeff_b = coeff(poly_b, 3)
    both_in_phi = in_phi(G, SIGMA_A) and in_phi(G, SIGMA_B)
    vandermonde_matches = (
        vandermonde(SIGMA_A) == -factorial_product(N)
        and vandermonde(SIGMA_B) == -factorial_product(N)
        and factorial_product(N) == 8
    )
    not_negatives = poly_a != poly_b and poly_a != scale(poly_b, -1)
    both_nonzero = any(poly_a) and any(poly_b)
    same_edge_set = edge_polynomials(G, SIGMA_A) == edge_polynomials(G, SIGMA_B)
    ok = (
        identity.get("ok") is True
        and both_in_phi
        and vandermonde_matches
        and coeff_a == -3072
        and coeff_b == 6144
        and not_negatives
        and both_nonzero
        and same_edge_set
    )
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "target": "tpc_gn",
        "source": "arXiv:2410.13840v2",
        "local_pdf": "incoming/gnang-tpc-2410.13840v2.pdf",
        "pdf_identity": identity,
        "lemma": (
            "Proposition 3.4, page 7: for every sigma in Phi(g), "
            "P_g(sigma, y) equals one displayed polynomial in y, up to sign"
        ),
        "instance": (
            "n=3, g=((0,1,2),(0,0,2),(0,0,0)), "
            "sigma_A=((0,1,2),(1,0,2),(2,0,1)), "
            "sigma_B=((0,1,2),(2,0,1),(1,0,2))"
        ),
        "false_instance": "coefficient of y^3 is -3072 at sigma_A and 6144 at sigma_B",
        "coeff_y3_sigma_a": coeff_a,
        "coeff_y3_sigma_b": coeff_b,
        "vandermonde_a": vandermonde(SIGMA_A),
        "vandermonde_b": vandermonde(SIGMA_B),
        "factorial_product": factorial_product(N),
        "both_in_phi": both_in_phi,
        "polynomials_differ_by_more_than_sign": not_negatives,
        "both_nonzero": both_nonzero,
        "same_undirected_edges": same_edge_set,
        "lemma_3_10_is_the_verdict": False,
        "tree_packing_conjecture_is_the_verdict": False,
        "verdict": "BREAK" if ok else "ABORT",
        "ok": ok,
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / "tpc_gn_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{'PASS' if ok else 'FAIL'}] tpc_gn")
    print(
        f"  pdf: pages {identity.get('pages')} / "
        f"sha {str(identity.get('sha256'))[:12]}"
    )
    print(f"  y^3 coefficients: sigma_A {coeff_a}, sigma_B {coeff_b}")
    print(f"  both in Phi: {both_in_phi}; |V| matches 8: {vandermonde_matches}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
