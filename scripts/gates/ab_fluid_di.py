"""DI (dyadic interval) arithmetic for the ab-fluid gate.

From-scratch transcription of euler-blowup/EulerBlowup/Num/Kernel.lean
at tristanbuckmaster/fluid_lean@d0124689230b58b4f86e7b90ac59de06404b3b6b.

A DI is a pair of integers (lo, hi) representing [lo/2^60, hi/2^60].
All operations are exact integer transcriptions of the Lean definitions,
including the kernel's fast paths (which are proven equivalent to the
general case in the Lean sources, but are transcribed verbatim here so
the replay computes bit-identical results).
"""

import math

prec = 60
ONE = 1152921504606846976          # 2^60
ONEm1 = 1152921504606846975        # 2^60 - 1
ONEm1N = 1152921504606846975


def fl(a, d):
    # Lean Int.ediv: floor division. Python // is floor for d > 0.
    return a // d


def cl(a, d):
    # (a + (d-1)) / d with floor division; matches Lean Int.ediv
    return (a + (d - 1)) // d


def ible(a, b):
    return a <= b


def iblt(a, b):
    return a < b


def inonneg(a):
    return a >= 0


def inonpos(a):
    return a <= 0


def iadd(a, b):
    return a + b


def isub(a, b):
    return a - b


def ineg(a):
    return -a


def imin(a, b):
    return a if a <= b else b


def imax(a, b):
    return a if a >= b else b


def shr(a):
    return a >> prec  # arithmetic shift right = floor(a / 2^60)


def shrUp(a):
    return (a + ONEm1) >> prec


def pshr(m, n):
    return (m * n) >> prec


def pshrUp(m, n):
    return (m * n + ONEm1N) >> prec


def nshr(m, n):
    return -((m * n + ONEm1N) >> prec)


def nshrUp(m, n):
    return -((m * n) >> prec)


def nmax(m, n):
    return m if m >= n else n


class DI:
    __slots__ = ("lo", "hi")

    def __init__(self, lo, hi):
        self.lo = lo
        self.hi = hi

    def __repr__(self):
        return f"DI({self.lo}, {self.hi})"

    def __eq__(self, other):
        return isinstance(other, DI) and self.lo == other.lo and self.hi == other.hi

    @staticmethod
    def of_mant(n):
        return DI(n, n)

    @staticmethod
    def const_q(num, den):
        # DI.const q = <fl (q.num * ONE) q.den, cl (q.num * ONE) q.den>
        return DI(fl(num * ONE, den), cl(num * ONE, den))

    @staticmethod
    def add(x, y):
        return DI(iadd(x.lo, y.lo), iadd(x.hi, y.hi))

    @staticmethod
    def sub(x, y):
        return DI(isub(x.lo, y.hi), isub(x.hi, y.lo))

    @staticmethod
    def neg(x):
        return DI(ineg(x.hi), ineg(x.lo))

    @staticmethod
    def mul4(x, y):
        p1 = x.lo * y.lo
        p2 = x.lo * y.hi
        p3 = x.hi * y.lo
        p4 = x.hi * y.hi
        return DI(shr(imin(imin(p1, p2), imin(p3, p4))),
                  shrUp(imax(imax(p1, p2), imax(p3, p4))))

    @staticmethod
    def mul(x, y):
        # Transcription of DI.mul fast paths.  The patterns below mirror the
        # Lean match arms on (x.lo, x.hi, y.lo, y.hi) sign shapes; well-formed
        # intervals take the fast path, anything else falls to mul4.
        # Represent signs as: 'p' = ofNat (nonneg), 'n' = negSucc (negative).
        def shape(v):
            return 'p' if v >= 0 else 'n'

        def nat(v):
            # ofNat a -> a ; negSucc a -> a+1 (the magnitude)
            return v if v >= 0 else -v

        sx = (shape(x.lo), shape(x.hi), nat(x.lo), nat(x.hi))
        sy = (shape(y.lo), shape(y.hi), nat(y.lo), nat(y.hi))
        (sxl, sxh, axl, axh) = sx
        (syl, syh, ayl, ayh) = sy

        def ble(a, b):
            return a <= b

        # arm: p,p,p,p
        if (sxl, sxh, syl, syh) == ('p', 'p', 'p', 'p'):
            if ble(axl, axh) and ble(ayl, ayh):
                return DI(pshr(axl, ayl), pshrUp(axh, ayh))
            return DI.mul4(x, y)
        # arm: p,p,n,p  (y.lo negative: negSucc c -> magnitude c+1)
        if (sxl, sxh, syl, syh) == ('p', 'p', 'n', 'p'):
            if ble(axl, axh):
                return DI(nshr(axh, ayl), pshrUp(axh, ayh))
            return DI.mul4(x, y)
        # arm: p,p,n,n
        if (sxl, sxh, syl, syh) == ('p', 'p', 'n', 'n'):
            if ble(axl, axh) and ble(ayh, ayl):
                return DI(nshr(axh, ayl), nshrUp(axl, ayh))
            return DI.mul4(x, y)
        # arm: n,p,p,p
        if (sxl, sxh, syl, syh) == ('n', 'p', 'p', 'p'):
            if ble(ayl, ayh):
                return DI(nshr(axl, ayh), pshrUp(axh, ayh))
            return DI.mul4(x, y)
        # arm: n,p,n,p
        if (sxl, sxh, syl, syh) == ('n', 'p', 'n', 'p'):
            return DI(-((nmax(axl * ayh, axh * ayl) + ONEm1N) >> prec),
                      (nmax(axl * ayl, axh * ayh) + ONEm1N) >> prec)
        # arm: n,p,n,n
        if (sxl, sxh, syl, syh) == ('n', 'p', 'n', 'n'):
            if ble(ayh, ayl):
                return DI(nshr(axh, ayl), pshrUp(axl, ayl))
            return DI.mul4(x, y)
        # arm: n,n,p,p
        if (sxl, sxh, syl, syh) == ('n', 'n', 'p', 'p'):
            if ble(axh, axl) and ble(ayl, ayh):
                return DI(nshr(axl, ayh), nshrUp(axh, ayl))
            return DI.mul4(x, y)
        # arm: n,n,n,p
        if (sxl, sxh, syl, syh) == ('n', 'n', 'n', 'p'):
            if ble(axh, axl):
                return DI(nshr(axl, ayh), pshrUp(axl, ayl))
            return DI.mul4(x, y)
        # arm: n,n,n,n
        if (sxl, sxh, syl, syh) == ('n', 'n', 'n', 'n'):
            if ble(axh, axl) and ble(ayh, ayl):
                return DI(pshr(axh, ayh), pshrUp(axl, ayl))
            return DI.mul4(x, y)
        return DI.mul4(x, y)

    @staticmethod
    def sqr(x):
        # Transcription of DI.sqr match arms.
        if x.lo >= 0:
            if x.hi >= 0:
                return DI(pshr(x.lo, x.lo), pshrUp(x.hi, x.hi))
            else:
                # lo >= 0, hi negative: empty/malformed; follow arm 2
                b = -x.hi
                return DI(pshr(x.lo, x.lo), pshrUp(b, b))
        else:
            a = -x.lo
            if x.hi == 0:
                return DI(0, pshrUp(a, a))
            elif x.hi > 0:
                b = x.hi
                return DI(0, (nmax(a * a, b * b) + ONEm1N) >> prec)
            else:
                b = -x.hi
                return DI(pshr(b, b), pshrUp(a, a))

    @staticmethod
    def div_old(x, y):
        q1 = fl(x.lo * ONE, y.lo)
        q2 = fl(x.lo * ONE, y.hi)
        q3 = cl(x.hi * ONE, y.lo)
        q4 = cl(x.hi * ONE, y.hi)
        return DI(imin(q1, q2), imax(q3, q4))

    @staticmethod
    def qfl(m, d):
        return (m * ONE) // d

    @staticmethod
    def qcl(m, d):
        return (m * ONE + (d - 1)) // d

    @staticmethod
    def nqfl(m, d):
        return -((m * ONE + (d - 1)) // d)

    @staticmethod
    def nqcl(m, d):
        return -((m * ONE) // d)

    @staticmethod
    def div(x, y):
        # Transcription of DI.div.  Fast path when y.lo, y.hi are ofNat with
        # 0 < y.lo <= y.hi (i.e. y.lo = c+1 > 0).
        if y.lo > 0 and y.hi >= y.lo:
            c1 = y.lo  # = c+1
            d = y.hi
            if x.lo >= 0 and x.hi >= 0:
                return DI(DI.qfl(x.lo, d), DI.qcl(x.hi, c1))
            elif x.lo >= 0:  # x.hi negative (malformed); mirror arm
                b = -x.hi
                return DI(DI.qfl(x.lo, d), DI.nqcl(b, d))
            elif x.hi >= 0:
                a = -x.lo
                return DI(DI.nqfl(a, c1), DI.qcl(x.hi, c1))
            else:
                a = -x.lo
                b = -x.hi
                return DI(DI.nqfl(a, c1), DI.nqcl(b, d))
        return DI.div_old(x, y)

    @staticmethod
    def sqrt(x):
        # DI.sqrt: lo = fsqrt(lo*ONE), hi = s or s+1 where s = fsqrt(hi*ONE).
        # fsqrt = floor integer sqrt (Nat.sqrt.iter converges to floor).
        a = (x.lo * ONE)
        a = a if a >= 0 else 0  # toNat
        b = (x.hi * ONE)
        b = b if b >= 0 else 0
        fa = math.isqrt(a)
        s = math.isqrt(b)
        hi = s if s * s == b else s + 1
        return DI(fa, hi)

    @staticmethod
    def hull(x, y):
        return DI(imin(x.lo, y.lo), imax(x.hi, y.hi))

    @staticmethod
    def pos_lo(x):
        return not inonpos(x.lo)

    @staticmethod
    def nonneg_lo(x):
        return inonneg(x.lo)

    @staticmethod
    def neg_hi(x):
        return not inonneg(x.hi)

    @staticmethod
    def lt_b(x, y):
        return iblt(x.hi, y.lo)

    @staticmethod
    def le_b(x, y):
        return ible(x.hi, y.lo)
