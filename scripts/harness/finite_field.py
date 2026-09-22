"""Minimal exact finite-field engine: F_{p^k} arithmetic and polynomial rings
over F_{p^k}, built from scratch in pure Python (no `galois`/Sage/PARI on this
laptop -- see requirements.txt). Used by the Thakur/Carlitz-Wieferich gate and
its discrimination control.

Field elements of F_{p^k} are represented as length-k tuples of ints mod p
(coefficients of 1, x, ..., x^{k-1} of a fixed monic degree-k modulus
polynomial over F_p, low-degree-first). k=1 is the prime field F_p itself
(modulus [0, 1], trivial reduction).

"F_q-polynomials" (elements of F_q[T] or F_q[T]/(P)) are plain Python lists of
field elements, low-degree-first.

Every operation here is exact modular-integer arithmetic; field inversion
uses Fermat's little theorem (`a^{p^k-2}`) via the same square-and-multiply
used for Frobenius powers, rather than extended-Euclid, since both are needed
anyway for the q-th-power Frobenius maps this gate depends on.
"""

from __future__ import annotations

Elt = tuple[int, ...]
FPoly = list[Elt]


# --- raw F_p[x] arithmetic, used only to define/reduce field elements ------

def _poly_mul_fp(a: list[int], b: list[int], p: int) -> list[int]:
    res = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j, bj in enumerate(b):
            res[i + j] = (res[i + j] + ai * bj) % p
    return res


def _poly_mod_fp(a: list[int], mod: list[int], p: int) -> list[int]:
    a = a[:]
    while a and a[-1] == 0:
        a.pop()
    if not a:
        return [0]
    lead_inv = pow(mod[-1], p - 2, p)
    while len(a) - 1 >= len(mod) - 1:
        if a[-1] == 0:
            a.pop()
            if not a:
                return [0]
            continue
        factor = (a[-1] * lead_inv) % p
        shift = len(a) - len(mod)
        for i, mc in enumerate(mod):
            a[i + shift] = (a[i + shift] - factor * mc) % p
        while a and a[-1] == 0:
            a.pop()
        if not a:
            return [0]
    return a


# --- field element ops -------------------------------------------------

def ff_zero(k: int) -> Elt:
    return tuple([0] * k)


def ff_one(k: int) -> Elt:
    return tuple([1] + [0] * (k - 1))


def ff_add(a: Elt, b: Elt, p: int) -> Elt:
    return tuple((x + y) % p for x, y in zip(a, b))


def ff_sub(a: Elt, b: Elt, p: int) -> Elt:
    return tuple((x - y) % p for x, y in zip(a, b))


def ff_mul(a: Elt, b: Elt, p: int, modulus: list[int]) -> Elt:
    k = len(modulus) - 1
    raw = _poly_mul_fp(list(a), list(b), p)
    r = _poly_mod_fp(raw, modulus, p)
    r = r + [0] * (k - len(r))
    return tuple(r[:k])


def ff_pow(a: Elt, e: int, p: int, modulus: list[int]) -> Elt:
    k = len(modulus) - 1
    result = ff_one(k)
    base = a
    while e > 0:
        if e & 1:
            result = ff_mul(result, base, p, modulus)
        base = ff_mul(base, base, p, modulus)
        e >>= 1
    return result


def ff_inv(a: Elt, p: int, modulus: list[int]) -> Elt:
    k = len(modulus) - 1
    return ff_pow(a, p**k - 2, p, modulus)


def ff_from_int(a: int, k: int, p: int) -> Elt:
    v = [a % p] + [0] * (k - 1)
    return tuple(v)


# --- F_q[T] polynomial ring ops -----------------------------------------

def fpoly_trim(A: FPoly) -> FPoly:
    k = len(A[0])
    zero = ff_zero(k)
    A = A[:]
    while len(A) > 1 and A[-1] == zero:
        A.pop()
    return A


def fpoly_deg(A: FPoly) -> int:
    A = fpoly_trim(A)
    k = len(A[0])
    if len(A) == 1 and A[0] == ff_zero(k):
        return -1
    return len(A) - 1


def fpoly_is_zero(A: FPoly) -> bool:
    return fpoly_deg(A) < 0


def fpoly_add(A: FPoly, B: FPoly, p: int) -> FPoly:
    k = len(A[0])
    n = max(len(A), len(B))
    zero = ff_zero(k)
    A = A + [zero] * (n - len(A))
    B = B + [zero] * (n - len(B))
    return [ff_add(a, b, p) for a, b in zip(A, B)]


def fpoly_sub(A: FPoly, B: FPoly, p: int) -> FPoly:
    k = len(A[0])
    n = max(len(A), len(B))
    zero = ff_zero(k)
    A = A + [zero] * (n - len(A))
    B = B + [zero] * (n - len(B))
    return [ff_sub(a, b, p) for a, b in zip(A, B)]


def fpoly_mul(A: FPoly, B: FPoly, p: int, modulus: list[int]) -> FPoly:
    k = len(modulus) - 1
    zero = ff_zero(k)
    res = [zero] * (len(A) + len(B) - 1)
    for i, ai in enumerate(A):
        if ai == zero:
            continue
        for j, bj in enumerate(B):
            if bj == zero:
                continue
            res[i + j] = ff_add(res[i + j], ff_mul(ai, bj, p, modulus), p)
    return res


def fpoly_divmod(A: FPoly, D: FPoly, p: int, modulus: list[int]) -> tuple[FPoly, FPoly]:
    k = len(modulus) - 1
    zero = ff_zero(k)
    A = fpoly_trim(A)
    D = fpoly_trim(D)
    dD = fpoly_deg(D)
    if dD < 0:
        raise ZeroDivisionError("division by zero fpoly")
    lead_inv = ff_inv(D[-1], p, modulus)
    Q = [zero] * max(1, len(A) - len(D) + 1)
    while fpoly_deg(A) >= dD:
        dA = fpoly_deg(A)
        shift = dA - dD
        factor = ff_mul(A[-1], lead_inv, p, modulus)
        Q[shift] = factor
        for i, dc in enumerate(D):
            A[i + shift] = ff_sub(A[i + shift], ff_mul(factor, dc, p, modulus), p)
        A = fpoly_trim(A)
    return Q, A


def fpoly_mod(A: FPoly, D: FPoly, p: int, modulus: list[int]) -> FPoly:
    _, r = fpoly_divmod(A, D, p, modulus)
    return r


def fpoly_gcd(A: FPoly, B: FPoly, p: int, modulus: list[int]) -> FPoly:
    A, B = fpoly_trim(A), fpoly_trim(B)
    while not fpoly_is_zero(B):
        _, R = fpoly_divmod(A, B, p, modulus)
        A, B = B, R
    return A


def fpoly_pow_mod(A: FPoly, e: int, P: FPoly, p: int, modulus: list[int]) -> FPoly:
    k = len(modulus) - 1
    result: FPoly = [ff_one(k)]
    base = fpoly_mod(A, P, p, modulus)
    while e > 0:
        if e & 1:
            result = fpoly_mod(fpoly_mul(result, base, p, modulus), P, p, modulus)
        base = fpoly_mod(fpoly_mul(base, base, p, modulus), P, p, modulus)
        e >>= 1
    return result
