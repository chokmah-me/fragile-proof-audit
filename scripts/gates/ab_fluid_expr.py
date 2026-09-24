"""Expr DSL + evaluators for the ab-fluid gate.

From-scratch transcription of euler-blowup/EulerBlowup/Num/Expr.lean
at tristanbuckmaster/fluid_lean@d0124689230b58b4f86e7b90ac59de06404b3b6b.

Expr: var | const q | add | sub | mul | neg | sqr | div | sqrt
evalI: interval evaluation -> Option DI
evalD: dual-number (value, derivative) interval evaluation -> Option (DI, DI)
"""

from ab_fluid_di import DI


# Expr constructors: tuples ('var', i), ('const', num, den), ('add', a, b), ...
def var(i):
    return ('var', i)


def const(num, den=1):
    return ('const', num, den)


def add(a, b):
    return ('add', a, b)


def sub(a, b):
    return ('sub', a, b)


def mul(a, b):
    return ('mul', a, b)


def neg(a):
    return ('neg', a)


def sqr(a):
    return ('sqr', a)


def div(a, b):
    return ('div', a, b)


def sqrt(a):
    return ('sqrt', a)


def evalI(e, sigma):
    """sigma: int -> DI.  Returns DI or None."""
    tag = e[0]
    if tag == 'var':
        return sigma(e[1])
    if tag == 'const':
        return DI.const_q(e[1], e[2])
    if tag == 'add':
        a = evalI(e[1], sigma)
        b = evalI(e[2], sigma)
        return DI.add(a, b) if a is not None and b is not None else None
    if tag == 'sub':
        a = evalI(e[1], sigma)
        b = evalI(e[2], sigma)
        return DI.sub(a, b) if a is not None and b is not None else None
    if tag == 'mul':
        a = evalI(e[1], sigma)
        b = evalI(e[2], sigma)
        return DI.mul(a, b) if a is not None and b is not None else None
    if tag == 'neg':
        a = evalI(e[1], sigma)
        return DI.neg(a) if a is not None else None
    if tag == 'sqr':
        a = evalI(e[1], sigma)
        return DI.sqr(a) if a is not None else None
    if tag == 'div':
        a = evalI(e[1], sigma)
        b = evalI(e[2], sigma)
        if a is None or b is None:
            return None
        return DI.div(a, b) if 0 < b.lo else None
    if tag == 'sqrt':
        a = evalI(e[1], sigma)
        if a is None:
            return None
        return DI.sqrt(a) if 0 <= a.lo else None
    raise ValueError(tag)


def evalD(e, sigma):
    """sigma: int -> (DI, DI).  Returns (DI, DI) or None."""
    tag = e[0]
    if tag == 'var':
        return sigma(e[1])
    if tag == 'const':
        return (DI.const_q(e[1], e[2]), DI(0, 0))
    if tag == 'add':
        r = evalD(e[1], sigma)
        s = evalD(e[2], sigma)
        if r is None or s is None:
            return None
        (v1, d1), (v2, d2) = r, s
        return (DI.add(v1, v2), DI.add(d1, d2))
    if tag == 'sub':
        r = evalD(e[1], sigma)
        s = evalD(e[2], sigma)
        if r is None or s is None:
            return None
        (v1, d1), (v2, d2) = r, s
        return (DI.sub(v1, v2), DI.sub(d1, d2))
    if tag == 'mul':
        r = evalD(e[1], sigma)
        s = evalD(e[2], sigma)
        if r is None or s is None:
            return None
        (v1, d1), (v2, d2) = r, s
        return (DI.mul(v1, v2), DI.add(DI.mul(d1, v2), DI.mul(v1, d2)))
    if tag == 'neg':
        r = evalD(e[1], sigma)
        if r is None:
            return None
        v, d = r
        return (DI.neg(v), DI.neg(d))
    if tag == 'sqr':
        r = evalD(e[1], sigma)
        if r is None:
            return None
        v, d = r
        p = DI.mul(v, d)
        return (DI.sqr(v), DI.add(p, p))
    if tag == 'div':
        r = evalD(e[1], sigma)
        s = evalD(e[2], sigma)
        if r is None or s is None:
            return None
        (v1, d1), (v2, d2) = r, s
        if 0 < v2.lo:
            q = DI.div(v1, v2)
            return (q, DI.div(DI.sub(d1, DI.mul(q, d2)), v2))
        return None
    if tag == 'sqrt':
        r = evalD(e[1], sigma)
        if r is None:
            return None
        v, d = r
        if 0 <= v.lo:
            s = DI.sqrt(v)
            if 0 < s.lo:
                return (s, DI.div(d, DI.add(s, s)))
        return None
    raise ValueError(tag)


# ---------------------------------------------------------------------------
# The over-tilt field expressions (OverTiltCertF.lean / OverTiltCertP.lean).
# otBtE = var5 * var7 * (1 - var7/var6)^2 * (1 - var9)
# otGE  = var4*(1 - var8) + ((1 + otBtE)/var0)*var8
# otWE  = 1 / sqrt(1 + var3 * otGE^2)
# otRhs3P[0] = var1 + var10
# otRhs3P[1] = (1 + var11) * otGE * otWE
# otRhs3P[2] = -((1+var13) * ((var0*var4 - 1)*(1 - var8) + otBtE*var8) * otWE)
#              - (1+var12) * (var2^2 / (var3 + var0^2))

def _otBtE():
    return mul(mul(mul(var(5), var(7)),
                   sqr(sub(const(1), div(var(7), var(6))))),
               sub(const(1), var(9)))


def _otGE(bt):
    return add(mul(var(4), sub(const(1), var(8))),
               mul(div(add(const(1), bt), var(0)), var(8)))


def _otWE(ge):
    return div(const(1), sqrt(add(const(1), mul(var(3), sqr(ge)))))


_OTBTE = _otBtE()
_OTGE = _otGE(_OTBTE)
_OTWE = _otWE(_OTGE)

OT_RHS = [
    add(var(1), var(10)),
    mul(add(const(1), var(11)), mul(_OTGE, _OTWE)),
    sub(neg(mul(add(const(1), var(13)),
                mul(add(mul(sub(mul(var(0), var(4)), const(1)),
                            sub(const(1), var(8))),
                        mul(_OTBTE, var(8))),
                    _OTWE))),
        mul(add(const(1), var(12)),
            div(sqr(var(2)), add(var(3), sqr(var(0)))))),
]

# Field dimensions for otField3P: nState=3, nParam=4, nAux=3, nPert=4.
NSTATE, NPARAM, NAUX, NPERT = 3, 4, 3, 4
