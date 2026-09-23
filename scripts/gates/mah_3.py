#!/usr/bin/env python3
"""Gate 5a for MAH-3 (arXiv:2605.09334v3, Lemma 5.1).

Lemma 5.1: for a 3D convex polytope P, a facet G0 with Delta(P) vertices,
and theta in lin(G0-G0) cap S^2,
    dim A_theta(P) >= F(P) - V(P) + Delta(P) + 1,
where A_theta(P) = ker T, T the facet-affine constraint map.

Implemented with EXACT rational arithmetic (fractions).  Facet lists are
hardcoded per polytope but VERIFIED by the script (supporting-plane check,
Euler formula, vertex-extremality spot checks).

Control: the same computation with a deliberately wrong theta (not parallel
to G0) must visibly break the inequality on at least one polytope --
proving the instrument discriminates and is not a tautology machine.

Verdict convention: PASS = inequality holds on every polytope with margin;
BREAK = inequality reversed anywhere under the lemma's hypotheses.
"""
from fractions import Fraction as Q
import sys

# ----------------------------------------------------------------------------
# exact 3D vector helpers
# ----------------------------------------------------------------------------

def sub(a, b):
    return (a[0]-b[0], a[1]-b[1], a[2]-b[2])

def dot(a, b):
    return a[0]*b[0]+a[1]*b[1]+a[2]*b[2]

def cross(a, b):
    return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])

def rank_of_rows(rows, ncols):
    """Rank over Q by fraction Gaussian elimination."""
    M = [list(r) for r in rows]
    r = 0
    for c in range(ncols):
        piv = None
        for i in range(r, len(M)):
            if M[i][c] != 0:
                piv = i
                break
        if piv is None:
            continue
        M[r], M[piv] = M[piv], M[r]
        inv = M[r][c]
        for i in range(r+1, len(M)):
            if M[i][c] != 0:
                f = M[i][c]/inv
                for j in range(c, ncols):
                    M[i][j] -= f*M[r][j]
        r += 1
    return r

# ----------------------------------------------------------------------------
# polytope definitions: (name, vertices, facets as index lists)
# ----------------------------------------------------------------------------

def sq_pyramid():
    V = [(0,0,2),(1,1,0),(-1,1,0),(-1,-1,0),(1,-1,0)]
    F = [[1,2,3,4],[0,1,2],[0,2,3],[0,3,4],[0,4,1]]
    return "square_pyramid", V, F

def octahedron():
    V = [(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(0,0,1),(0,0,-1)]
    F = []
    for sx in (0,1):
        for sy in (2,3):
            for sz in (4,5):
                F.append([sx,sy,sz])
    return "octahedron", V, F

def cube():
    V = [(x,y,z) for x in (-1,1) for y in (-1,1) for z in (-1,1)]
    idx = {v:i for i,v in enumerate(V)}
    F = [
        [idx[(1,1,1)],idx[(1,1,-1)],idx[(1,-1,-1)],idx[(1,-1,1)]],
        [idx[(-1,1,1)],idx[(-1,-1,1)],idx[(-1,-1,-1)],idx[(-1,1,-1)]],
        [idx[(1,1,1)],idx[(-1,1,1)],idx[(-1,1,-1)],idx[(1,1,-1)]],
        [idx[(1,-1,1)],idx[(1,-1,-1)],idx[(-1,-1,-1)],idx[(-1,-1,1)]],
        [idx[(1,1,1)],idx[(1,-1,1)],idx[(-1,-1,1)],idx[(-1,1,1)]],
        [idx[(1,1,-1)],idx[(-1,1,-1)],idx[(-1,-1,-1)],idx[(1,-1,-1)]],
    ]
    return "cube", V, F

def tri_prism():
    V = [(0,0,0),(2,0,0),(1,1,0),(0,0,2),(2,0,2),(1,1,2)]
    F = [[0,1,2],[3,4,5],[0,1,4,3],[1,2,5,4],[2,0,3,5]]
    return "triangular_prism", V, F

def pent_pyramid():
    V = [(0,0,2),(1,0,0),(0,1,0),(-1,0,0),(-1,-1,0),(1,-1,0)]
    F = [[1,2,3,4,5],[0,1,2],[0,2,3],[0,3,4],[0,4,5],[0,5,1]]
    return "pentagonal_pyramid", V, F

def trunc_cube_corner():
    # cube with vertex (1,1,1) truncated
    V = [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),
         (-1,-1,1),(1,-1,1),(-1,1,1),
         (1,1,0),(1,0,1),(0,1,1)]
    F = [
        [0,1,2,3],          # z=-1
        [0,4,5,1],          # y=-1
        [0,3,6,4],          # x=-1
        [5,4,6,9,8],        # z=1 pentagon
        [9,6,3,2,7],        # y=1 pentagon
        [7,2,1,5,8],        # x=1 pentagon
        [7,8,9],            # cut triangle
    ]
    return "truncated_cube_corner", V, F

def elong_sq_pyramid():
    # Johnson J8: square prism + square pyramid
    V = [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),
         (-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1),(0,0,3)]
    F = [
        [0,1,2,3],
        [0,1,5,4],[1,2,6,5],[2,3,7,6],[3,0,4,7],
        [8,4,5],[8,5,6],[8,6,7],[8,7,4],
    ]
    return "elongated_square_pyramid", V, F

POLYTOPES = [sq_pyramid, octahedron, cube, tri_prism, pent_pyramid,
             trunc_cube_corner, elong_sq_pyramid]

# ----------------------------------------------------------------------------
# verification of the hardcoded combinatorics
# ----------------------------------------------------------------------------

def Qv(v):
    return (Q(v[0]), Q(v[1]), Q(v[2]))

def check_polytope(name, verts, facets):
    verts = [Qv(v) for v in verts]
    n = len(verts)
    # every facet: non-collinear triple, supporting plane, all verts on one side
    for f in facets:
        p0, p1, p2 = verts[f[0]], verts[f[1]], verts[f[2]]
        nn = cross(sub(p1,p0), sub(p2,p0))
        assert nn != (0,0,0), f"{name}: degenerate facet {f}"
        s = { (dot(nn, sub(v,p0)) > 0) - (dot(nn, sub(v,p0)) < 0) for v in verts }
        assert s <= {0, 1} or s <= {0, -1}, f"{name}: facet {f} not supporting"
        # exactly the facet's verts on the plane
        on = [i for i,v in enumerate(verts) if dot(nn, sub(v,p0)) == 0]
        assert set(on) == set(f), f"{name}: facet {f} plane has extra verts {on}"
    # edges: vertex pairs sharing exactly 2 facets
    from collections import defaultdict
    cnt = defaultdict(int)
    for f in facets:
        for a in range(len(f)):
            for b in range(a+1, len(f)):
                cnt[tuple(sorted((f[a],f[b])))] += 1
    edges = [e for e,c in cnt.items() if c == 2]
    E = len(edges)
    V, F = n, len(facets)
    assert V - E + F == 2, f"{name}: Euler fails V={V} E={E} F={F}"
    # every vertex in >= 3 facets (extremality sanity)
    for i in range(n):
        assert sum(i in f for f in facets) >= 3, f"{name}: vertex {i} in <3 facets"
    return V, E, F

# ----------------------------------------------------------------------------
# Lemma 5.1 gate
# ----------------------------------------------------------------------------

def facet_normal(verts, f):
    p0, p1, p2 = verts[f[0]], verts[f[1]], verts[f[2]]
    return cross(sub(p1,p0), sub(p2,p0))

def theta_parallel_to_facet(theta, verts, f):
    return dot(theta, facet_normal(verts, f)) == 0

def constraint_rows(verts, facets, theta):
    """Rows of T: for each facet not parallel to theta, kill the affine
    condition on its vertices. Row j: e_v - sum lambda_k e_k."""
    rows = []
    n = len(verts)
    for f in facets:
        if theta_parallel_to_facet(theta, verts, f):
            continue
        m = len(f)
        # non-collinear triple
        tri = None
        for a in range(m):
            for b in range(a+1, m):
                for c in range(b+1, m):
                    if cross(sub(verts[f[b]],verts[f[a]]),
                             sub(verts[f[c]],verts[f[a]])) != (0,0,0):
                        tri = (a,b,c)
                        break
                if tri: break
            if tri: break
        assert tri, "facet has no non-collinear triple"
        ia, ib, ic = (f[tri[0]], f[tri[1]], f[tri[2]])
        pa, pb, pc = verts[ia], verts[ib], verts[ic]
        u, v = sub(pa,pc), sub(pb,pc)
        # two coords with nonzero 2x2 minor
        solved = False
        for r1, r2 in ((0,1),(0,2),(1,2)):
            det = u[r1]*v[r2]-u[r2]*v[r1]
            if det != 0:
                rows_r = (r1, r2); solved = True
                break
        assert solved
        r1, r2 = rows_r
        det = u[r1]*v[r2]-u[r2]*v[r1]
        others = [f[i] for i in range(m) if i not in tri]
        for iv in others:
            pv = verts[iv]
            w1, w2 = pv[r1]-pc[r1], pv[r2]-pc[r2]
            mua = (w1*v[r2]-w2*v[r1])/det
            mub = (u[r1]*w2-u[r2]*w1)/det
            muc = 1-mua-mub
            # verify coplanarity (exact)
            for r in range(3):
                assert mua*pa[r]+mub*pb[r]+muc*pc[r] == pv[r]
            row = [Q(0)]*n
            row[iv] = Q(1); row[ia] = -mua; row[ib] = -mub; row[ic] = -muc
            rows.append(row)
    return rows

def gate_polytope(name, verts, facets, theta, label):
    verts = [Qv(v) for v in verts]
    V = len(verts)
    F = len(facets)
    Delta = max(len(f) for f in facets)
    rows = constraint_rows(verts, facets, theta)
    rk = rank_of_rows(rows, V)
    dim = V - rk
    bound = F - V + Delta + 1
    ok = dim >= bound
    n_parallel = sum(1 for f in facets if theta_parallel_to_facet(theta, verts, f))
    print(f"[{label}] {name}: V={V} F={F} Delta={Delta} "
          f"facets//theta={n_parallel} rank(T)={rk} dim A_theta={dim} "
          f"bound={bound} margin={dim-bound} {'OK' if ok else 'VIOLATION'}")
    return ok, dim, bound, V, F, Delta

def main():
    import json
    from datetime import datetime, timezone
    from pathlib import Path as P
    print("== MAH-3 gate 5a: Lemma 5.1 (exact rational arithmetic) ==")
    all_ok = True
    control_broken = False
    rows = []
    control_hits = []
    for fn in POLYTOPES:
        name, verts, facets = fn()
        V, E, F = check_polytope(name, verts, facets)
        Qverts = [Qv(v) for v in verts]
        Delta = max(len(f) for f in facets)
        G0 = next(f for f in facets if len(f) == Delta)
        # theta parallel to G0, in its plane
        theta = sub(Qverts[G0[1]], Qverts[G0[0]])
        assert theta_parallel_to_facet(theta, Qverts, G0)
        ok, dim, bound, Vv, Ff, Dd = gate_polytope(name, verts, facets, theta, "LEMMA")
        all_ok &= ok
        rows.append({"polytope": name, "V": Vv, "F": Ff, "Delta": Dd,
                     "dim_A_theta": dim, "bound": bound,
                     "margin": dim - bound, "ok": ok})
        # control: deliberately wrong theta (add the facet normal -> not parallel)
        n0 = facet_normal(Qverts, G0)
        theta_bad = (theta[0]+n0[0], theta[1]+n0[1], theta[2]+n0[2])
        assert not theta_parallel_to_facet(theta_bad, Qverts, G0)
        okb, dimb, boundb, _, _, _ = gate_polytope(name, verts, facets, theta_bad, "CONTROL")
        if dimb < boundb:
            control_broken = True
            control_hits.append(name)
    print()
    print(f"lemma-hypothesis runs: {'ALL OK' if all_ok else 'VIOLATION FOUND'}")
    print(f"control (wrong theta) breaks the bound somewhere: {control_broken}")
    verdict = "PASS" if all_ok and control_broken else \
              ("PASS-no-discrimination" if all_ok else "BREAK")
    print(f"verdict: {verdict}")
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "mah_3",
        "verdict": verdict,
        "source_claim": "Shibing Chen, Yuanyuan Li, Dongmeng Xi, Zhe-Feng Xu, "
                        "'The Mahler Conjecture in Three Dimensions', "
                        "arXiv:2605.09334v3 (15 June 2026)",
        "corpus_pointer": "corpus/Fragile-Route_Harvest_Dossier_II.md, Hit MAH-3",
        "local_pdf": "incoming/mah-3-2605.09334v3.pdf",
        "local_pdf_sha256": "cd2b5f801f3015e3b7bfc883103f9fa33e8e20817729ed8072ec50af1ad4405f",
        "lemma": "Lemma 5.1: dim A_theta(P) >= F(P) - V(P) + Delta(P) + 1",
        "arithmetic": "exact rational (fractions.Fraction); facet lists hardcoded "
                      "but verified by the script (supporting-plane check, Euler, "
                      "vertex-extremality spot checks)",
        "polytopes": rows,
        "control": {
            "description": "same computation with deliberately wrong theta "
                           "(not parallel to G0); must break the bound somewhere",
            "discriminates": control_broken,
            "broken_on": control_hits,
        },
        "scope_note": "Gates Lemma 5.1 (the finite counting layer) only. "
                      "Proposition 6.4 (connectedness) is topological and was "
                      "audited by prose + floating-point stress probes in "
                      "scripts/analysis/mah_3_stress_5b.py; see docs/audits/mah-3.md. "
                      "Overall audit disposition: WATCH, not full PASS.",
    }
    out = P(__file__).resolve().parents[2] / "results" / "mah_3_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"Wrote {out}")
    return 0 if all_ok else 1

if __name__ == "__main__":
    sys.exit(main())
