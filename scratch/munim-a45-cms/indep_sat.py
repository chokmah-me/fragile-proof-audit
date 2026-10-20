#!/usr/bin/env python3
"""Independent SAT check for A(t) < d: does an anisotropic system with
dim X = t, dim V = d exist?

System: sigma : V -> X quadratic with polar form beta, alpha : V -> End(X),
A_h = alpha(h), satisfying A_(h') sigma(h) = (I + A_h) beta(h, h') for all
h, h' (equation (*)). Anisotropic: sigma(h) != 0 for all h != 0.
A(t) = max dim V of an anisotropic system.

Variables: s_i = sigma(e_i) (t bits), B_ik = beta(e_i, e_k) (t bits, i<k),
A_i = alpha(e_i) (t x t bits). (*) is equivalent to
    A_j s_i = (I + A_i) B_ij          for all i, j            (L)
    A_j B_ik = A_i B_kj + A_k B_ij    for i < k, j not in {i,k}  (Q)
plus sigma(h) != 0 for all nonzero h (anisotropy), with
    sigma(h) = sum_i h_i s_i + sum_{i<k} h_i h_k B_ik.

Implemented from scratch here (own Tseitin encoding, own brute-force
verifier). Uses python-sat Minisat22 with an interrupt-based wall timeout.
"""
import itertools
import sys
import threading
import time

from pysat.formula import CNF
from pysat.solvers import Minisat22, Solver


class Enc:
    def __init__(self):
        self.cnf = CNF()
        self.nvars = 0

    def new(self):
        self.nvars += 1
        return self.nvars

    def land(self, a, b):
        p = self.new()
        self.cnf.append([-p, a])
        self.cnf.append([-p, b])
        self.cnf.append([p, -a, -b])
        return p

    def xor2(self, a, b):
        z = self.new()
        self.cnf.append([-a, -b, -z])
        self.cnf.append([-a, b, z])
        self.cnf.append([a, -b, z])
        self.cnf.append([a, b, -z])
        return z

    def xor_chain(self, terms):
        # parity of terms (list of var ids); returns a var
        acc = None
        for t in terms:
            acc = t if acc is None else self.xor2(acc, t)
        return acc  # terms never empty at call sites

    def eq(self, a, b):
        self.cnf.append([-a, b])
        self.cnf.append([a, -b])

    def mat_vec(self, A, v, t):
        # y_r = sum_c A[r][c] * v[c]; A = t x t var ids, v = t var ids
        y = []
        for r in range(t):
            terms = [self.land(A[r * t + c], v[c]) for c in range(t)]
            y.append(self.xor_chain(terms))
        return y


def encode(t, d, assumptions=(), flag=False):
    # flag=True adds the sound symmetry break s_i[r] = 0 for r > i:
    # span(s_0..s_i) is a flag with dim <= i+1, and some g in GL(X) sends it
    # to span(e_0..e_{r_i-1}), r_i <= i+1, whence s_i in span(e_0..e_i).
    E = Enc()
    s = [[E.new() for _ in range(t)] for _ in range(d)]
    if flag:
        for i in range(d):
            for r in range(i + 1, t):
                E.cnf.append([-s[i][r]])
    B = {}
    for i in range(d):
        for k in range(i + 1, d):
            B[(i, k)] = [E.new() for _ in range(t)]
    A = [[E.new() for _ in range(t * t)] for _ in range(d)]

    def Bvec(i, k):
        return B[(i, k)] if i < k else B[(k, i)]

    # (L): A_j s_i == (I + A_i) B_ij for all i, j (B_ii = 0, so A_i s_i = 0)
    for i in range(d):
        for j in range(d):
            lhs = E.mat_vec(A[j], s[i], t)
            if i == j:
                for r in range(t):
                    E.cnf.append([-lhs[r]])
            else:
                Bij = Bvec(i, j)
                AiBij = E.mat_vec(A[i], Bij, t)
                for r in range(t):
                    rhs = E.xor2(Bij[r], AiBij[r])
                    E.eq(lhs[r], rhs)

    # (Q): A_j B_ik == A_i B_kj + A_k B_ij for i<k, j not in {i,k}
    for i in range(d):
        for k in range(i + 1, d):
            for j in range(d):
                if j in (i, k):
                    continue
                lhs = E.mat_vec(A[j], Bvec(i, k), t)
                t1 = E.mat_vec(A[i], Bvec(k, j), t)
                t2 = E.mat_vec(A[k], Bvec(i, j), t)
                for r in range(t):
                    rhs = E.xor2(t1[r], t2[r])
                    E.eq(lhs[r], rhs)

    # anisotropy: sigma(h) != 0 for every nonzero h
    for h in range(1, 1 << d):
        bits = []
        for r in range(t):
            terms = []
            for i in range(d):
                if (h >> i) & 1:
                    terms.append(s[i][r])
            for i in range(d):
                for k in range(i + 1, d):
                    if ((h >> i) & 1) and ((h >> k) & 1):
                        terms.append(B[(i, k)][r])
            bits.append(E.xor_chain(terms))
        E.cnf.append(bits[:])

    return E, s, B, A


def decode(t, d, s, B, A, model):
    val = {abs(lit): lit > 0 for lit in model}

    def g(v):
        return val.get(v, False)

    S = [[g(s[i][r]) for r in range(t)] for i in range(d)]
    BB = {(i, k): [g(B[(i, k)][r]) for r in range(t)] for i in range(d) for k in range(i + 1, d)}
    AM = [[[g(A[i][r * t + c]) for c in range(t)] for r in range(t)] for i in range(d)]
    return S, BB, AM


def v2i(v):
    n = 0
    for r, b in enumerate(v):
        if b:
            n |= 1 << r
    return n


def mat_vec_i(M, v, t):
    out = 0
    for r in range(t):
        p = 0
        for c in range(t):
            if M[r][c] and (v >> c) & 1:
                p ^= 1
        if p:
            out |= 1 << r
    return out


def mat_add_i(M1, M2, t):
    return [[M1[r][c] ^ M2[r][c] for c in range(t)] for r in range(t)]


def mat_i(t, r, c):
    return [[1 if (rr == r and cc == c) else 0 for cc in range(t)] for rr in range(t)]


def is_system(t, d, S, BB, AM):
    # brute-force check of (*) on all (h, h') and anisotropy, from the definition
    def sigma(h):
        x = [0] * t
        for i in range(d):
            if (h >> i) & 1:
                for r in range(t):
                    x[r] ^= S[i][r]
        for i in range(d):
            for k in range(i + 1, d):
                if ((h >> i) & 1) and ((h >> k) & 1):
                    for r in range(t):
                        x[r] ^= BB[(i, k)][r]
        return v2i(x)

    def beta(h, hp):
        x = [0] * t
        for i in range(d):
            for k in range(i + 1, d):
                # coefficient is (h_i h'_k + h_k h'_i) mod 2: XOR, not OR
                # (for h = h' both products are 1 and cancel, as beta is alternating)
                if (((h >> i) & 1) and ((hp >> k) & 1)) ^ (((h >> k) & 1) and ((hp >> i) & 1)):
                    for r in range(t):
                        x[r] ^= BB[(i, k)][r]
        return v2i(x)

    def Amat(h):
        M = [[0] * t for _ in range(t)]
        for i in range(d):
            if (h >> i) & 1:
                M = mat_add_i(M, AM[i], t)
        return M

    def IplusA(M):
        return [[M[r][c] ^ (1 if r == c else 0) for c in range(t)] for r in range(t)]

    for h in range(1, 1 << d):
        if sigma(h) == 0:
            return False, f"anisotropy fails at h={h}"
    for h in range(1 << d):
        for hp in range(1 << d):
            lhs = mat_vec_i(Amat(hp), sigma(h), t)
            rhs = mat_vec_i(IplusA(Amat(h)), beta(h, hp), t)
            if lhs != rhs:
                return False, f"(*) fails at h={h},h'={hp}"
    return True, "ok"


def s4_assumptions(t, d, k, E_s):
    """Assumptions fixing s_{d-1} = e_k (Borel orbit representative).
    Sound: after the flag break, s_{d-1} is a nonzero vector; the Borel
    (upper-triangular) subgroup preserves the flag and maps any nonzero
    vector to e_k where k = max support index. E_s is the s var table from
    encode()."""
    s = E_s
    asm = []
    for r in range(t):
        asm.append(s[d-1][r] if r == k else -s[d-1][r])
    return asm

def solve_td(t, d, timeout_s=600, assumptions=(), seed=0, flag=False, solver_name="minisat22"):
    E, s, B, A = encode(t, d, assumptions=(), flag=flag)
    # resolve callable assumptions (for s4 split, which needs var ids)
    if callable(assumptions):
        assumptions = assumptions(s)
    solver = Solver(name=solver_name)
    for c in E.cnf.clauses:
        solver.add_clause(c)
    for lit in assumptions:
        solver.add_clause([lit])
    done = {}
    def worker():
        done["sat"] = solver.solve()
        done["model"] = solver.get_model() if done["sat"] else None
    th = threading.Thread(target=worker)
    t0 = time.time()
    th.start()
    th.join(timeout_s)
    if th.is_alive():
        solver.interrupt()
        th.join(10)
        return {"t": t, "d": d, "result": "TIMEOUT", "wall": time.time() - t0}
    wall = time.time() - t0
    if done["sat"]:
        S, BB, AM = decode(t, d, s, B, A, done["model"])
        ok, msg = is_system(t, d, S, BB, AM)
        return {"t": t, "d": d, "result": "SAT", "bruteforce": (ok, msg), "wall": wall,
                "vars": E.nvars, "clauses": len(E.cnf.clauses), "solver": solver_name}
    return {"t": t, "d": d, "result": "UNSAT", "wall": wall,
            "vars": E.nvars, "clauses": len(E.cnf.clauses), "solver": solver_name}


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    timeout_s = int(sys.argv[2]) if len(sys.argv) > 2 else 600
    jobs = {"44": (4, 4), "45": (4, 5), "55": (5, 5), "56": (5, 6)}
    sel = jobs.keys() if which == "all" else [which]
    for name in sel:
        t, d = jobs[name]
        r = solve_td(t, d, timeout_s=timeout_s)
        print(f"({t},{d}): {r['result']} wall={r['wall']:.1f}s", end="")
        if r["result"] == "SAT":
            print(f" brute-force-verify={r['bruteforce']}")
        else:
            print(f" vars={r.get('vars')} clauses={r.get('clauses')}")
        sys.stdout.flush()
