#!/usr/bin/env python3
"""Illustration probe (NOT a gate): why the contour-deformation in
arXiv:2307.08725v4, Prop. 2.18, cannot analytically continue across
Re(s) = 0.

The paper deforms the inverse-Mellin contour to
    C: z = sigma(t) + i*t,  sigma(t) = -a / (2*log(2+|t|))   (a > 0),
and claims the resulting integral defines a function analytic in an open
neighborhood of {Re(s) >= 0}.  The integrand's size is dominated by
|s^{-z}| * |Gamma(z)| : Stirling gives |Gamma| ~ exp(-pi|t|/2), while
|s^{-z}| = |s|^{-sigma(t)} * exp(t * arg(s)).

Hence along C the integrand behaves like exp(t*(arg(s) - pi/2)) (t>0):
  - Re(s) > 0  => |arg s| < pi/2  => exponential DECAY (integral converges)
  - Re(s) = 0  => |arg s| = pi/2  => EXACT balance, marginal |t|^{-5/2} decay
  - Re(s) < 0  => |arg s| > pi/2  => exponential GROWTH (integral DIVERGES)

The paper itself notes the "exact balance" on the boundary (p.19) but then
concludes analyticity "in an open neighborhood" -- a non sequitur, since any
such neighborhood contains Re(s) < 0 points where the integral diverges.

This script evaluates |s^{-z} * Gamma(z)| / |(z-1)(z-2)| along C for
s = 0.1+i (right), s = i (boundary), s = -0.1+i (left), showing decay /
marginal decay / exponential blowup.  The Omega factor is O(log|t|) and
cannot affect the exponential tradeoff, so it is omitted (noted, not hidden).
"""
import mpmath as mp

mp.mp.dps = 30
A = 1.0  # the paper's 'a' from Thm 2.17; any a>0 shows the same tradeoff


def sigma(t):
    return -A / (2 * mp.log(2 + abs(t)))


def integrand_mag(s, t):
    z = sigma(t) + 1j * t
    # |s^{-z}| * |Gamma(z)| / |(z-1)(z-2)|
    s_m = abs(s) ** (-sigma(t)) * mp.e ** (t * mp.arg(s))
    g_m = abs(mp.gamma(z))
    d_m = abs((z - 1) * (z - 2))
    return s_m * g_m / d_m


def main():
    cases = [
        ("s =  0.1+i  (Re>0)", 0.1 + 1j),
        ("s =  i       (Re=0)", 0.0 + 1j),
        ("s = -0.1+i  (Re<0)", -0.1 + 1j),
    ]
    ts = [10, 20, 40, 80, 160]
    print("integrand magnitude |s^-z * Gamma(z)| / |(z-1)(z-2)| along C")
    print("(Omega factor is O(log|t|); omitted -- cannot change exponential trend)")
    for label, s in cases:
        vals = [float(integrand_mag(s, t)) for t in ts]
        row = "  ".join(f"t={t}: {v:.3e}" for t, v in zip(ts, vals))
        print(f"{label}\n    {row}")
    # verdict-style summary
    m_right = float(integrand_mag(0.1 + 1j, 160))
    m_left = float(integrand_mag(-0.1 + 1j, 160))
    print()
    print(f"at t=160: Re(s)>0 magnitude ~ {m_right:.2e} (decaying)")
    print(f"at t=160: Re(s)<0 magnitude ~ {m_left:.2e} (blowing up)")
    if m_left > 1e10 * m_right:
        print("CONCLUSION: deformed integral DIVERGES for Re(s)<0; "
              "it cannot define an analytic function on any open "
              "neighborhood of {Re(s)>=0}. Prop. 2.18's proof is invalid.")
    else:
        print("CONCLUSION: unexpected -- tradeoff not as analyzed.")


if __name__ == "__main__":
    main()
