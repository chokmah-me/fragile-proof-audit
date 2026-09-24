"""IPoly enclosures, hybrid table lookup, and the piece checker for the ab-fluid gate.

From-scratch transcription of euler-blowup/EulerBlowup/Num/{Check,CheckP,
FlatStepTable,FlatStepLookup,OverTiltCert}.lean at
tristanbuckmaster/fluid_lean@d0124689230b58b4f86e7b90ac59de06404b3b6b.

IPoly = List[int] (fixed-point coefficients, Horner form).
PEncl = (e0, e1, r0, r1, r2) polynomial enclosure over an interval.
"""

from ab_fluid_di import DI, ONE, imin, imax
from ab_fluid_expr import evalI, evalD, OT_RHS, NSTATE, NPARAM, NAUX, NPERT


# ---------------------------------------------------------------- IPoly ---
def ipoly_deriv_aux(k, cs):
    if not cs:
        return []
    return [k * cs[0]] + ipoly_deriv_aux(k + 1, cs[1:])


def ipoly_deriv(p):
    if not p:
        return []
    return ipoly_deriv_aux(1, p[1:])


def ipoly_evalI(p, T):
    # Horner: c0 + T*(c1 + T*(...))
    r = DI(0, 0)
    for c in reversed(p):
        r = DI.add(DI(c, c), DI.mul(T, r))
    return r


def ipoly_encl(p, T, M, R):
    """IPoly.encl: Taylor enclosure of p over interval T (midpoint M, radius R)."""
    p1 = ipoly_deriv(p)
    p2 = ipoly_deriv(p1)
    p3 = ipoly_deriv(p2)
    p4 = ipoly_deriv(p3)
    e0 = ipoly_evalI(p, M)
    e1 = ipoly_evalI(p1, M)
    e2 = ipoly_evalI(p2, M)
    e3 = ipoly_evalI(p3, M)
    e4 = ipoly_evalI(p4, T)
    r2 = DI.add(e2, DI.mul(DI.add(e3, DI.mul(e4, R)), R))
    r1 = DI.add(e1, DI.mul(r2, R))
    r0 = DI.add(e0, DI.mul(r1, R))
    return (e0, e1, r0, r1, r2)  # PEncl


# ---------------------------------------------------------- table lookup ---
CW = 9007199254740992  # 2^53
MAX_CELLS = 32


def clampM(m):
    return imax(0, imin(m, ONE))


def cellOf(m):
    return min(m // CW, 127)


def hornerDI(T, ns):
    r = DI(0, 0)
    for n in reversed(ns):
        r = DI.add(DI(n, n), DI.mul(T, r))
    return r


def evalCell(tab, j, k, lo, hi):
    # tab: list of HCell = (p0, p1, p2, e0, e1, e2)
    if k < len(tab):
        c = tab[k]
    else:
        c = ([], [], [], 0, 0, 0)
    pj = (c[0], c[1], c[2])[j]
    ej = (c[3], c[4], c[5])[j]
    b = k * CW
    T = DI(imax(lo, b) - b, imin(hi, b + CW) - b)
    r = hornerDI(T, pj)
    return DI(r.lo - ej, r.hi + ej)


def scanCells(tab, j, lo, hi, fuel, k, acc):
    while fuel > 0:
        acc = DI.hull(acc, evalCell(tab, j, k, lo, hi))
        fuel -= 1
        k += 1
    return acc


def crudeH(j):
    if j == 0:
        return DI(0, ONE)
    if j == 1:
        return DI(0, 3458764513820540928)
    return DI(-13835058055282163712, 13835058055282163712)


def tabH(tab, j, Y):
    lo = clampM(Y.lo)
    hi = clampM(Y.hi)
    k1 = cellOf(lo)
    k2 = cellOf(hi)
    if j == 0:
        A = evalCell(tab, j, k1, lo, lo)
        B = evalCell(tab, j, k2, hi, hi)
        return DI(imax(0, A.lo), imin(ONE, B.hi))
    if k1 + MAX_CELLS <= k2:
        return crudeH(j)
    return scanCells(tab, j, lo, hi, k2 - k1, k1 + 1, evalCell(tab, j, k1, lo, hi))


# ----------------------------------------------------------------- otAux ---
def otAux(tab, U, P):
    """Returns list of (DI, DI) aux pairs, or None."""
    if len(P) != 4:
        return None
    D = P[3]
    five = DI.const_q(5, 1)
    Y1 = DI.mul(five, U)
    Y2 = DI.add(DI.mul(five, DI.sub(U, D)), DI.const_q(1, 1))
    return [(U, DI.const_q(1, 1)),
            (tabH(tab, 0, Y1), DI.mul(five, tabH(tab, 1, Y1))),
            (tabH(tab, 0, Y2), DI.mul(five, tabH(tab, 1, Y2)))]


# ------------------------------------------------------- pLeafOK / check ---
def _pLeafOK(Om, P, pc, t1, t2, tab):
    n = NSTATE
    nparam, naux, npert = NPARAM, NAUX, NPERT
    zero = DI(0, 0)
    zenc = (zero, zero, zero, zero, zero)

    T = DI(t1, t2)
    # M = <(t1+t2)/2, -((-(t1+t2))/2)> ; Lean Int.ediv floors.
    M = DI((t1 + t2) // 2, -((-(t1 + t2)) // 2))
    r = -((-(t2 - t1)) // 2)
    R = DI(-r, r)

    Uabs = DI.add(DI(pc['u0'], pc['u0']), T)
    MUabs = DI.add(DI(pc['u0'], pc['u0']), M)
    auxU = otAux(tab, Uabs, P)
    auxM = otAux(tab, MUabs, P)
    if auxU is None or auxM is None:
        return False

    loE = [ipoly_encl(pc['lo'][j] if j < len(pc['lo']) else [], T, M, R) for j in range(n)]
    hiE = [ipoly_encl(pc['hi'][j] if j < len(pc['hi']) else [], T, M, R) for j in range(n)]

    def envD(i, onHi):
        def env(k):
            if k < n:
                if k == i:
                    e = hiE[k] if onHi else loE[k]
                    return (e[2], e[3])  # (r0, r1)
                le, he = loE[k], hiE[k]
                return (DI.hull(le[2], he[2]), DI.hull(le[3], he[3]))
            elif k - n < nparam:
                kk = k - n
                return (P[kk] if kk < len(P) else zero, zero)
            elif k - n - nparam < naux:
                kk = k - n - nparam
                return auxU[kk] if kk < len(auxU) else (zero, zero)
            else:
                return (zero, zero)
        return env

    def envM(i, onHi):
        def env(k):
            if k < n:
                if k == i:
                    e = hiE[k] if onHi else loE[k]
                    return e[0]  # e0
                le, he = loE[k], hiE[k]
                return DI.hull(le[0], he[0])
            elif k - n < nparam:
                kk = k - n
                return P[kk] if kk < len(P) else zero
            elif k - n - nparam < naux:
                kk = k - n - nparam
                a = auxM[kk] if kk < len(auxM) else (zero, zero)
                return a[0]
            else:
                return zero
        return env

    def envU(i, onHi):
        def env(k):
            if k < n:
                if k == i:
                    e = hiE[k] if onHi else loE[k]
                    return e[2]  # r0
                le, he = loE[k], hiE[k]
                return DI.hull(le[2], he[2])
            elif k - n < nparam:
                kk = k - n
                return P[kk] if kk < len(P) else zero
            elif k - n - nparam < naux:
                kk = k - n - nparam
                a = auxU[kk] if kk < len(auxU) else (zero, zero)
                return a[0]
            elif k - n - nparam - naux < npert:
                kk = k - n - nparam - naux
                om = Om[kk] if kk < len(Om) else zero
                return DI.hull(om, zero)
            else:
                return zero
        return env

    def envS(i, onHi):
        eu = envU(i, onHi)

        def env(k):
            v = eu(k)
            if n + nparam + naux <= k and k - n - nparam - naux < npert:
                kk = k - n - nparam - naux
                d = Om[kk] if kk < len(Om) else zero
            else:
                d = zero
            return (v, d)
        return env

    for i in range(n):
        rDhi = evalD(OT_RHS[i], envD(i, True))
        rMhi = evalI(OT_RHS[i], envM(i, True))
        rDlo = evalD(OT_RHS[i], envD(i, False))
        rMlo = evalI(OT_RHS[i], envM(i, False))
        rShi = evalD(OT_RHS[i], envS(i, True))
        rSlo = evalD(OT_RHS[i], envS(i, False))
        if rDhi is None or rMhi is None or rDlo is None or rMlo is None or rShi is None or rSlo is None:
            return False
        (_, FdHi) = rDhi
        FvHi = rMhi
        (_, FdLo) = rDlo
        FvLo = rMlo
        (_, PertHi) = rShi
        (_, PertLo) = rSlo
        hE = hiE[i]
        lE = loE[i]
        Ahi = DI.sub(hE[1], FvHi)
        Bhi = DI.sub(hE[4], FdHi)
        Alo = DI.sub(FvLo, lE[1])
        Blo = DI.sub(FdLo, lE[4])
        c1 = DI.sub(DI.add(Ahi, DI.mul(Bhi, R)), PertHi)
        c2 = DI.add(DI.add(Alo, DI.mul(Blo, R)), PertLo)
        if not (0 < c1.lo and 0 < c2.lo):
            return False
    return True


def pCheckPiece(Om, P, pc, tab):
    """Full pCheckPiece. pc: dict(u0, len, lo, hi, cuts)."""
    if not (len(pc['lo']) == NSTATE and len(pc['hi']) == NSTATE
            and len(P) == NPARAM and len(Om) == NPERT and 0 < pc['len']):
        return False
    cuts = pc['cuts']
    if not cuts:
        return False
    if cuts[0] != 0:
        return False
    c = cuts[0]
    for c2 in cuts[1:]:
        if not (c < c2):
            return False
        if not _pLeafOK(Om, P, pc, c, c2, tab):
            return False
        c = c2
    return c == pc['len']
