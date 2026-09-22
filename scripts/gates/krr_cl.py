"""Numeric gate: the Q^{[1]} congruence in the proof of Lemma 25 is false.

Source: Edinah K. Gnang, arXiv:2202.03178v3 (31 Jan 2025), Lemma 25,
the composition lemma, the displayed congruence for Q^{[1]}_{f,g}.
incoming/gnang-krr-2202.03178.pdf, page 27.

Phi(g) is the set of permutations sigma such that the conjugate
sigma g sigma^{-1} is gracefully labeled: the absolute differences
{|sigma g sigma^{-1}(i) - i| : i in Z_n} equal Z_n. On page 27 the
proof sets

    Q^{[1]}_{f,g} = c (x_{f^{(2)}(n-1)} - x_{f(n-1)})^m

and prints

    Q^{[1]}_{f,g}
      ≡ c * sum_{sigma in Phi(g)}
          (sigma(f^{(2)}(n-1)) - sigma(f(n-1)))^m
          * L(x_{f^{(2)}(n-1)}; sigma(f^{(2)}(n-1)))
          * L(x_{f(n-1)}; sigma(f(n-1))).

The witness is the normalized path f = (0, 0, 1, 2) on Z_4. It lies in
the semigroup f(0) = 0, f(i) < i, the vertex 3 is at distance 3 from 0,
and the sibling block of 3 is {3} with parent 2. Diameter is 3, so the
hypothesis of Lemma 25 applies. The partial iterate is g = (0, 0, 1, 1).
Here m = 6 and c = 1, so the left side is (x_1 - x_2)^6.

At sigma = (0, 3, 1, 2), which is in Phi(g),

    left  = (3 - 1)^6 = 64
    right = 128.

Two members of Phi(g), (0, 3, 1, 2) and (2, 3, 1, 0), carry the same
pair (sigma(1), sigma(2)) = (3, 1). The printed sum only constrains
those two coordinates, so both Lagrange factors equal 1 and the sum
double-counts.

The same substitution accepts the evaluation formula printed just above
that congruence: P_g(sigma) equals ± prod_{i<j} (j-i)(j^2-i^2) on
Phi(g) and equals 0 off Phi(g). That line is not the verdict.

Lemma 25's inequality is not the verdict either. For this f both
score(f) and score(g) equal 4. The graceful tree conjecture is untouched.

Gates refute routes, not theorems.
"""

from __future__ import annotations

import hashlib
import json
import sys
from datetime import datetime, timezone
from fractions import Fraction
from itertools import permutations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
PDF = ROOT / "incoming" / "gnang-krr-2202.03178.pdf"
PDF_SHA256 = "72d59ffb72fd8b9baf262212ef66ec6945dc0569066222a27674fd8289adb2ac"

# Normalized path on Z_4. Parent of the unique deepest vertex is n-2.
F = (0, 0, 1, 2)
SIGMA = (0, 3, 1, 2)
N = 4

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
        and pages == 31
        and "GNANG" in head.upper()
        and "2202.03178v3" in head
    )
    return {
        "available": True,
        "ok": ok,
        "sha256": digest,
        "pages": pages,
        "author": "Edinah K. Gnang",
        "title": "A proof of the Kotzig-Ringel-Rosa Conjecture",
        "arxiv": "https://arxiv.org/abs/2202.03178v3",
    }


def partial_iterate(f: tuple[int, ...]) -> tuple[int, ...]:
    """Slide the sibling block of n-1 one step toward the root."""
    n = len(f)
    parent = f[n - 1]
    block = {i for i in range(n) if f[i] == parent}
    return tuple(f[f[i]] if i in block else f[i] for i in range(n))


def normalized_path(f: tuple[int, ...]) -> bool:
    """Semigroup form used before the polynomials in the proof of Lemma 25."""
    n = len(f)
    if f[0] != 0 or any(f[i] >= i for i in range(1, n)):
        return False
    parent = f[n - 1]
    block = [i for i in range(n) if f[i] == parent]
    if block != [n - 1]:
        return False
    if parent != n - 2:
        return False
    # Distance from the root along the functional tree.
    dist = [-1] * n
    dist[0] = 0
    kids: list[list[int]] = [[] for _ in range(n)]
    for i in range(1, n):
        kids[f[i]].append(i)
    queue = [0]
    for u in queue:
        for v in kids[u]:
            dist[v] = dist[u] + 1
            queue.append(v)
    return dist[n - 1] == n - 1 == max(dist)


def diameter(f: tuple[int, ...]) -> int:
    n = len(f)
    adj: list[list[int]] = [[] for _ in range(n)]
    for i, j in enumerate(f):
        if i != j:
            adj[i].append(j)
            adj[j].append(i)

    def far(start: int) -> int:
        dist = [-1] * n
        dist[start] = 0
        queue = [start]
        for u in queue:
            for v in adj[u]:
                if dist[v] < 0:
                    dist[v] = dist[u] + 1
                    queue.append(v)
        return max(dist)

    return max(far(i) for i in range(n))


def exponent_m(f: tuple[int, ...]) -> tuple[int, int]:
    """(m, c) as printed under the monochromatic summand."""
    n = len(f)
    parent = f[n - 1]
    block = [i for i in range(n) if f[i] == parent]
    r_pairs = 0
    for v in block:
        for u in range(parent + 1, v):
            r_pairs += 1
    s_triples = 0
    for _v in block:
        for _u in range(parent + 1):
            s_triples += 2  # t in {0, 1}
    return r_pairs + s_triples, 2**r_pairs


def gracefully_labeled(h: tuple[int, ...], sigma: tuple[int, ...]) -> bool:
    n = len(h)
    inverse = [0] * n
    for i, label in enumerate(sigma):
        inverse[label] = i
    diffs = {
        abs(sigma[h[inverse[i]]] - i) for i in range(n)
    }
    return diffs == set(range(n))


def phi(g: tuple[int, ...]) -> list[tuple[int, ...]]:
    n = len(g)
    return [
        sigma
        for sigma in permutations(range(n))
        if gracefully_labeled(g, sigma)
    ]


def lagrange_at(value: int, node: int, n: int) -> Fraction:
    """The univariate Lagrange factor for Z_n, evaluated at `value`."""
    numerator = 1
    denominator = 1
    for j in range(n):
        if j == node:
            continue
        numerator *= value - j
        denominator *= node - j
    return Fraction(numerator, denominator)


def congruence_sides(
    f: tuple[int, ...], sigma: tuple[int, ...]
) -> tuple[Fraction, Fraction]:
    """Left and right sides of the printed Q^{[1]} congruence at x_i = sigma(i)."""
    n = len(f)
    m, c = exponent_m(f)
    image = f[f[n - 1]]
    parent = f[n - 1]
    left = Fraction(c) * (sigma[image] - sigma[parent]) ** m
    right = Fraction(0)
    for tau in phi(partial_iterate(f)):
        factor = Fraction(c) * (tau[image] - tau[parent]) ** m
        factor *= lagrange_at(sigma[image], tau[image], n)
        factor *= lagrange_at(sigma[parent], tau[parent], n)
        right += factor
    return left, right


def same_pair_count(f: tuple[int, ...], sigma: tuple[int, ...]) -> int:
    """How many Phi members share sigma's pair on the two summed coordinates."""
    n = len(f)
    image = f[f[n - 1]]
    parent = f[n - 1]
    pair = (sigma[image], sigma[parent])
    return sum(
        1
        for tau in phi(partial_iterate(f))
        if (tau[image], tau[parent]) == pair
    )


def score(h: tuple[int, ...]) -> int:
    n = len(h)
    best = 1
    for sigma in permutations(range(n)):
        inverse = [0] * n
        for i, label in enumerate(sigma):
            inverse[label] = i
        diffs = {abs(sigma[h[inverse[i]]] - i) for i in range(n)}
        if len(diffs) > best:
            best = len(diffs)
            if best == n:
                return n
    return best


def universal_constant(n: int) -> int:
    value = 1
    for i in range(n):
        for j in range(i + 1, n):
            value *= (j - i) * (j * j - i * i)
    return value


def pg_at_permutation(f: tuple[int, ...], sigma: tuple[int, ...]) -> int:
    """P_g as printed, evaluated at x_i = sigma(i). Direct product, no expansion."""
    n = len(f)
    parent = f[n - 1]
    block = [i for i in range(n) if f[i] == parent]
    value = 1
    for i in range(n):
        for j in range(i + 1, n):
            value *= sigma[j] - sigma[i]
    v = 0
    while v <= parent:
        u = 0
        while u < v:
            for t in (0, 1):
                value *= sigma[f[v]] - sigma[v] + ((-1) ** t) * (
                    sigma[f[u]] - sigma[u]
                )
            u += 1
        v += 1
    for v in block:
        for u in range(parent + 1):
            for t in (0, 1):
                fv = f[f[v]]
                value *= sigma[fv] - sigma[v] + ((-1) ** t) * (
                    sigma[f[u]] - sigma[u]
                )
    for v in block:
        for u in range(parent + 1, v):
            for t in (0, 1):
                value *= sigma[f[f[v]]] - sigma[v] + ((-1) ** t) * (
                    sigma[f[f[u]]] - sigma[u]
                )
    return value


def evaluation_formula_holds(f: tuple[int, ...]) -> bool:
    """The P_g(h) display on the same page, which this witness does satisfy."""
    n = len(f)
    constant = universal_constant(n)
    g = partial_iterate(f)
    for sigma in permutations(range(n)):
        value = pg_at_permutation(f, sigma)
        if gracefully_labeled(g, sigma):
            if value not in (constant, -constant):
                return False
        elif value != 0:
            return False
    return True


def telescoping_difference(f: tuple[int, ...], anchor: int) -> dict[int, int]:
    """Coefficient of LHS - RHS for the printed telescoping step.

    LHS is x_{f^2(v)} - x_v. RHS uses the anchor vertex in place of n-1:
    (x_{f^2(anchor)} - x_{f(anchor)}) + (x_{f(v)} - x_v). The paper's anchor
    is n-1. A shifted anchor is the negative probe.
    """
    n = len(f)
    parent = f[n - 1]
    total: dict[int, int] = {}

    def add(index: int, weight: int) -> None:
        total[index] = total.get(index, 0) + weight

    for v in range(n):
        if f[v] != parent:
            continue
        add(f[f[v]], 1)
        add(v, -1)
        add(f[f[anchor]], -1)
        add(f[anchor], 1)
        add(f[v], -1)
        add(v, 1)
    return {index: weight for index, weight in total.items() if weight != 0}


def telescoping_holds(f: tuple[int, ...]) -> bool:
    """The paper's anchor n-1 makes the telescoping step an identity."""
    return telescoping_difference(f, len(f) - 1) == {}


def main() -> int:
    identity = pdf_identity()
    g = partial_iterate(F)
    m, c = exponent_m(F)
    left, right = congruence_sides(F, SIGMA)
    members = phi(g)
    pair_count = same_pair_count(F, SIGMA)
    formula_ok = evaluation_formula_holds(F)
    both_graceful = score(F) == N and score(g) == N
    ok = (
        identity.get("ok") is True
        and normalized_path(F)
        and diameter(F) >= 3
        and m == 6
        and c == 1
        and SIGMA in members
        and pair_count == 2
        and left == 64
        and right == 128
        and left != right
        and formula_ok
        and both_graceful
        and telescoping_holds(F)
    )
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "target": "krr_cl",
        "source": "arXiv:2202.03178v3",
        "local_pdf": "incoming/gnang-krr-2202.03178.pdf",
        "pdf_identity": identity,
        "lemma": (
            "Proof of Lemma 25, page 27: Q^{[1]}_{f,g} is congruent to the "
            "sum over Phi(g) of c (sigma(f^2(n-1)) - sigma(f(n-1)))^m times "
            "the two univariate Lagrange factors"
        ),
        "instance": (
            "n=4, f=(0,0,1,2), g=(0,0,1,1), sigma=(0,3,1,2), m=6, c=1"
        ),
        "false_instance": "left = 64, right = 128",
        "left": str(left),
        "right": str(right),
        "phi_size": len(members),
        "same_pair_count": pair_count,
        "diameter": diameter(F),
        "normalized": normalized_path(F),
        "evaluation_formula_on_same_page_holds": formula_ok,
        "score_f": score(F),
        "score_g": score(g),
        "inequality_is_the_verdict": False,
        "graceful_tree_conjecture_is_the_verdict": False,
        "verdict": "BREAK" if ok else "ABORT",
        "ok": ok,
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    out = RESULTS / "krr_cl_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{'PASS' if ok else 'FAIL'}] krr_cl")
    print(
        f"  pdf: {identity.get('author')} / pages {identity.get('pages')} / "
        f"sha {str(identity.get('sha256'))[:12]}"
    )
    print(f"  Q^[1] at sigma: left {left}, right {right}, pairs {pair_count}")
    print(f"  P_g formula holds: {formula_ok}; scores f,g = {score(F)},{score(g)}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
