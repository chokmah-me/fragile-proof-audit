#!/usr/bin/env python3
"""5b stress for MAH-3 (arXiv:2605.09334v3): finite anchors on the dependency
chain of Proposition 6.4 (connectedness of the sublevel sets).

Prop 6.4 itself is a pure topological argument (no finite falsifiable
residue); what CAN be stressed computationally are its load-bearing lemmas:

  (a) Lemma 6.3: along a NON-TRIVIAL shadow flow, P(P_t) strictly decreases
      on one side of t=0.  We exhibit a concrete polytope + nontrivial
      admissible speed, flow it both ways, and check the strict one-sided
      decrease of the Mahler volume P(P_t) = |P_t| * |P_t^{s(P_t)}|.
  (b) Lemma 6.2: P(K^{z_tau}) <= P(K^{c(K)}) for z_tau on the centroid ->
      Santalo-point segment.  Checked on a grid.

Float arithmetic (numpy/scipy); this is a STRESS/SANITY probe, not the
verdict gate (that is scripts/gates/mah_3.py, exact rationals).
A failure here would downgrade to a full prose audit of Section 6.
"""
import numpy as np
from scipy.spatial import ConvexHull
from scipy.optimize import minimize

# ----------------------------------------------------------------------------
# polytope plumbing (floats)
# ----------------------------------------------------------------------------

class Poly:
    def __init__(self, verts):
        self.verts = np.asarray(verts, float)
        self.hull = ConvexHull(self.verts)
        # equations: n.x + d == 0, n outward unit; dedupe planes
        # (Qhull may repeat one, e.g. a pyramid's square base)
        seen, ueq = set(), []
        for e in self.hull.equations:
            key = tuple(np.round(e, 9))
            if key not in seen:
                seen.add(key)
                ueq.append(e)
        # rebuild facets: group hull simplices (facet triangulation) by plane
        grouped = [(e, set()) for e in ueq]
        for s in self.hull.simplices:
            a = self.verts[s[0]]
            for e, fs in grouped:
                if abs(np.dot(e[:3], a) + e[3]) < 1e-7:
                    b, c = self.verts[s[1]], self.verts[s[2]]
                    nn = np.cross(b-a, c-a); nn /= np.linalg.norm(nn)
                    if abs(abs(np.dot(nn, e[:3]))-1) < 1e-7:
                        fs.update(s.tolist())
                        break
        grouped = [(e, sorted(fs)) for e, fs in grouped if fs]
        assert grouped, "no facets reconstructed"
        self.eq = np.array([e for e, _ in grouped])
        self.facets = [f for _, f in grouped]
        self.n = self.eq[:, :3]
        self.d = self.eq[:, 3]
        # sanity: every vertex used
        assert set().union(*map(set, self.facets)) == set(range(len(self.verts)))

    def interior_point(self):
        return self.verts.mean(axis=0)

    def contains_interior(self, z, tol=1e-9):
        return bool(np.all(self.n @ z + self.d < -tol))

    def volume(self):
        return float(self.hull.volume)

    def centroid(self):
        o = self.interior_point()
        assert self.contains_interior(o)
        num = np.zeros(3); den = 0.0
        for s in self.hull.simplices:
            a, b, c = self.verts[s]
            v = abs(np.dot(a-o, np.cross(b-o, c-o)))/6.0
            num += v*(o+a+b+c)/4.0; den += v
        return num/den

    def polar(self, z):
        """Vertices of K^z (z interior). Facet plane n.x+d=0 (n outward unit):
        polar vertex w = z + n / ((p0-z).n), p0 any point on the plane."""
        assert self.contains_interior(z)
        w = []
        for i in range(len(self.n)):
            n, d = self.n[i], self.d[i]
            p0 = self.verts[self.facets[i][0]]
            denom = np.dot(p0-z, n)
            assert denom > 1e-12
            w.append(z + n/denom)
        return np.array(w)

    def polar_volume(self, z):
        return float(ConvexHull(self.polar(z)).volume)

    def santalo_point(self, z0=None):
        z0 = self.centroid() if z0 is None else np.asarray(z0, float)
        def f(z):
            if not self.contains_interior(z, tol=1e-7):
                return 1e30
            try:
                return self.polar_volume(z)
            except Exception:
                return 1e30
        r = minimize(f, z0, method="Nelder-Mead",
                     options=dict(maxiter=400, xatol=1e-7, fatol=1e-9))
        assert self.contains_interior(r.x), "santalo search left interior"
        return r.x

    def mahler(self, z0=None):
        s = self.santalo_point(z0)
        return self.volume()*self.polar_volume(s), s

# ----------------------------------------------------------------------------
# (a) Lemma 6.3 stress
# ----------------------------------------------------------------------------

def null_speed(verts, facets_idx, theta):
    """A non-affine theta-admissible speed via null space of the constraint
    matrix (float version of the exact gate)."""
    V = len(verts)
    rows = []
    for f in facets_idx:
        pts = verts[f]
        # parallel?
        n = np.cross(pts[1]-pts[0], pts[2]-pts[0]); n /= np.linalg.norm(n)
        if abs(np.dot(theta, n)) < 1e-12:
            continue
        # affine basis: three non-collinear
        ia, ib, ic = f[0], f[1], f[2]
        A = np.array([verts[ib]-verts[ia], verts[ic]-verts[ia]])
        # express others: alpha_v = la*alpha_a + lb*alpha_b + lc*alpha_c
        M = np.stack([verts[ib]-verts[ic], verts[ia]-verts[ic]], axis=1)[:, :2]
        # solve in the dominant 2 coords
        cr = np.cross(verts[ib]-verts[ia], verts[ic]-verts[ia])
        r = int(np.argmax(np.abs(cr))); rs = [i for i in range(3) if i != r]
        M2 = np.column_stack([ (verts[ib]-verts[ic])[rs], (verts[ia]-verts[ic])[rs] ])
        Minv = np.linalg.inv(M2)
        for iv in f[3:]:
            w = (verts[iv]-verts[ic])[rs]
            la_lb = Minv @ w
            la, lb = la_lb; lc = 1-la-lb
            row = np.zeros(V); row[iv]=1.0; row[ia]-=la; row[ib]-=lb; row[ic]-=lc
            rows.append(row)
    T = np.array(rows) if rows else np.zeros((0, V))
    # nontrivial part: ker(T) orthogonal to the 4-dim affine speed space
    aff = np.column_stack([verts, np.ones(V)])   # V x 4, columns span T(P)
    M = np.vstack([T, aff.T])
    u, sv, vh = np.linalg.svd(M)
    tol = 1e-8
    r = M.shape[0]
    if r < V:
        mask = np.zeros(V, dtype=bool)
        mask[:r] = sv < tol
        mask[r:] = True          # trailing vh rows are always in the kernel
        ns = vh[mask]
    else:
        ns = vh[sv < tol]
    out = [w/np.linalg.norm(w) for w in ns if np.linalg.norm(w) > 1e-6]
    return out

def stress_lemma_63():
    print("== stress (a): Lemma 6.3 -- strict one-sided decrease along a")
    print("   non-trivial shadow flow ==")
    verts = np.array([(0,0,2),(1,1,0),(-1,1,0),(-1,-1,0),(1,-1,0)], float)
    P0 = Poly(verts)
    facets = P0.facets
    # G0 = base (4 vertices); theta in its plane
    G0 = max(facets, key=len)
    assert len(G0) == 4
    theta = verts[G0[1]]-verts[G0[0]]; theta /= np.linalg.norm(theta)
    speeds = null_speed(verts, facets, theta)
    print(f"   nontrivial admissible speeds found: {len(speeds)}")
    assert speeds, "no nontrivial speed -- cannot stress 6.3 on this body"
    alpha = speeds[0]
    ts = np.linspace(-0.25, 0.25, 41)
    Ps, okc = [], True
    s_prev = P0.centroid()
    for t in ts:
        vt = verts + t*np.outer(alpha, theta)
        try:
            Pt = Poly(vt)
        except Exception:
            okc = False; Ps.append(np.nan); continue
        if len(Pt.verts) != 5 or len(Pt.facets) != 5:
            okc = False; Ps.append(np.nan); continue  # combinatorics changed
        val, s_prev = Pt.mahler(s_prev)
        Ps.append(val)
    Ps = np.array(Ps)
    P_mid = Ps[len(ts)//2]
    left = Ps[:len(ts)//2]; right = Ps[len(ts)//2+1:]
    dec_left = np.all(np.diff(left) > 1e-9)    # strictly increasing toward 0?
    dec_right = np.all(np.diff(right) < -1e-9) # strictly decreasing away?
    # Lemma 6.3: P strictly smaller on (at least) one side.
    # Both sides decreasing is consistent (the statement is a disjunction).
    side_neg = bool(np.all(left < P_mid - 1e-9))
    side_pos = bool(np.all(right < P_mid - 1e-9))
    print(f"   P(0)={P_mid:.6f}  min(left)={np.nanmin(left):.6f} "
          f"min(right)={np.nanmin(right):.6f}  combinatorics kept: {okc}")
    print(f"   strictly below on t<0 side: {side_neg}, on t>0 side: {side_pos}")
    ok = okc and (side_neg or side_pos)
    print(f"   Lemma 6.3 phenomenon reproduced: {ok}")
    return ok

# ----------------------------------------------------------------------------
# (b) Lemma 6.2 sanity
# ----------------------------------------------------------------------------

def stress_lemma_62():
    print("== stress (b): Lemma 6.2 -- P(K^{z_tau}) <= P(K^{c(K)}) ==")
    # truncated cube corner: c(K) != s(K), so the segment is non-vacuous
    V = [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),
         (-1,-1,1),(1,-1,1),(-1,1,1),
         (1,1,0),(1,0,1),(0,1,1)]
    K = Poly(np.array(V, float))
    c = K.centroid(); s = K.santalo_point(c)
    # Lemma 6.2 baseline: P(K^{z_0}) with z_0 = c(K).
    # By (2.1), s(K^{z_0}) = z_0, so P(K^{z_0}) = |K^{z_0}| * |(K^{z_0})^{z_0}|
    #                                    = |K^{c(K)}| * |K|   (biduality).
    # NOTE: this is NOT P(K) = |K||K^{s(K)}|; comparing against P(K) is wrong.
    P0 = K.polar_volume(c) * K.volume()
    print(f"   centroid={np.round(c,4)} santalo={np.round(s,4)} "
          f"P(K^c)={P0:.6f}  (P(K)={K.volume()*K.polar_volume(s):.6f} for reference)")
    assert np.linalg.norm(c-s) > 1e-4, "test body has c==s; segment vacuous"
    worst = 0.0; ok = True
    for tau in np.linspace(0, 1, 11):
        z = (1-tau)*c + tau*s
        Kz = Poly(K.polar(z))
        Pv, _ = Kz.mahler()
        worst = max(worst, Pv - P0)
        if Pv > P0 + 1e-6:
            ok = False
            print(f"   VIOLATION at tau={tau}: {Pv:.6f} > {P0:.6f}")
    print(f"   max excess over P(K): {worst:.3e} -> {'OK' if ok else 'FAIL'}")
    return ok

if __name__ == "__main__":
    a = stress_lemma_63()
    print()
    b = stress_lemma_62()
    print()
    print(f"5b stress: Lemma 6.3 {'PASS' if a else 'FAIL'}, "
          f"Lemma 6.2 {'PASS' if b else 'FAIL'}")
    raise SystemExit(0 if (a and b) else 1)
