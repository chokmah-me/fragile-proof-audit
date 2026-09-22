"""Numeric gate: the Salez-Youssef Ollivier-curvature log-Sobolev conjecture
is FALSE.

Source claim (corpus/live-fragile-proofs-2024-2026.md, Target Identifier
"Salez-Youssef Log-Sobolev Conjecture, 2025 Refutation, arXiv:2504.08055";
refutation Munch, F. (2025), "A counterexample to a conjecture by Salez and
Youssef," arXiv:2504.08055 [math.DG], PDF pinned at
incoming/salez-youssef-munch-2504.08055.pdf, live-checked via WebFetch before
download).

NOTE ON PROVENANCE: unlike Tang-Zhang/Thakur/Chung-Graham (image-corrupted)
and NCI (fabricated gate -- see docs/blueprint/nci-conjecture.md), this
corpus-doc entry's description turned out to match the real paper closely.
Still fetched and read the actual PDF before writing anything, per this
session's own stated lesson: a corpus-doc entry looking complete is not
evidence it is accurate.

Conjecture 1.2 (Salez-Youssef, cited as their arXiv:2503.02793 Conjecture 1):
a reversible Markov chain (X, p) with Ollivier curvature bounded below by
K > 0 satisfies alpha_LSI >= c * K / log(d) for a UNIVERSAL constant c > 0,
where d = max{1/p(x,y) : p(x,y) > 0} is the sparsity parameter.

Munch's refutation (Section 2): an explicit family of birth-death chains on
{1, ..., 3n} with

    4p(k,k+1) = 1/n^2                    (1 <= k <= n)
                1 - 1/n - k/n^2          (n < k <= 3n-1)
    4p(k,k-1) = 1/n + (k+1)/n^2          (2 <= k <= n)
                1                         (n < k <= 3n)

(p(1,0) = p(3n,3n+1) = 0 by convention) has Ollivier curvature kappa >=
1/(4n^2) everywhere, sparsity d = 4n^2, but the log-Sobolev upper bound from
the capacitary characterization (Theorem 2.1: alpha_LSI <= C * cap(A,B) /
(pi(B)|log pi(B)|) for any A, B with pi(A) >= 1/2) at A={1}, B={2n,...,3n}
decays like 1/(n^3 log n) -- an extra factor of 1/n faster than K/log(d) ~
1/(n^2 log n). No fixed constant c can survive n -> infinity, so the
conjecture is false.

This gate reproduces the chain exactly (Fraction transition probabilities,
mpmath high-precision stationary distribution and capacity -- magnitudes
range down to ~1e-11000 at n=3000, ordinary floats cannot represent this),
confirms the curvature bound with exact rational equality (not an
approximation), and confirms the ratio R(n)/(K/log d) is strictly decreasing
and drops below a fixed threshold as n grows across three orders of
magnitude -- the actual asymptotic mechanism of the refutation, not a single
snapshot.

Gates refute routes, not theorems: this does not compute alpha_LSI itself
(computing an exact log-Sobolev infimum over all functions is not tractable);
it reproduces the paper's own two-sided argument (Theorem 2.1's capacitary
upper bound versus the exact curvature/sparsity ratio) exactly as derived,
which is what actually falsifies the fixed-constant conjecture.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

import mpmath as mp

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

mp.mp.dps = 80


def p_up(k: int, n: int) -> Fraction:
    """p(k, k+1); zero at the right boundary k=3n."""
    if 1 <= k <= n:
        return Fraction(1, 4 * n * n)
    if n < k <= 3 * n - 1:
        return (1 - Fraction(1, n) - Fraction(k, n * n)) / 4
    return Fraction(0)


def p_down(k: int, n: int) -> Fraction:
    """p(k, k-1); zero at the left boundary k=1."""
    if k == 1:
        return Fraction(0)
    if 2 <= k <= n:
        return (Fraction(1, n) + Fraction(k + 1, n * n)) / 4
    if n < k <= 3 * n:
        return Fraction(1, 4)
    return Fraction(0)


def to_mp(fr: Fraction) -> mp.mpf:
    return mp.mpf(fr.numerator) / mp.mpf(fr.denominator)


def build_chain(n: int):
    states = list(range(1, 3 * n + 1))
    up = {k: p_up(k, n) for k in states}
    down = {k: p_down(k, n) for k in states}
    return states, up, down


def stationary(states: list[int], up: dict, down: dict):
    """pi(k) via detailed balance pi(k) p(k,k+1) = pi(k+1) p(k+1,k), high
    precision throughout since the unnormalized weights span ~10^4 orders of
    magnitude by n=3000.
    """
    w = {states[0]: mp.mpf(1)}
    for k in states[:-1]:
        ratio = to_mp(up[k]) / to_mp(down[k + 1])
        w[k + 1] = w[k] * ratio
    z = mp.fsum(w.values())
    pi = {k: w[k] / z for k in w}
    return pi, z


def curvature_edges(states: list[int], up: dict, down: dict) -> dict[int, Fraction]:
    """kappa(k,k+1) = p(k,k+1) - p(k,k-1) - p(k+1,k+2) + p(k+1,k), exact
    Fraction arithmetic, using the boundary convention p(1,0)=p(3n,3n+1)=0.
    """
    kappas = {}
    for k in states[:-1]:
        pk_up = up[k]
        pk_down = down[k] if k > states[0] else Fraction(0)
        pk1_up = up[k + 1] if (k + 1) < states[-1] else Fraction(0)
        pk1_down = down[k + 1]
        kappas[k] = pk_up - pk_down - pk1_up + pk1_down
    return kappas


def capacity_to_tail(states: list[int], pi: dict, up: dict, b: int) -> mp.mpf:
    """cap({1}, {b,...,3n}) via the birth-death effective-resistance
    identity: 1/cap = sum_{k=1}^{b-1} 1/(pi(k) p(k,k+1))."""
    inv_cap = mp.mpf(0)
    for k in range(states[0], b):
        inv_cap += 1 / (pi[k] * to_mp(up[k]))
    return 1 / inv_cap


def break_instance(n: int) -> dict:
    states, up, down = build_chain(n)
    pi, _z = stationary(states, up, down)
    kappas = curvature_edges(states, up, down)
    min_kappa = min(kappas.values())
    target_k = Fraction(1, 4 * n * n)

    b = 2 * n
    cap = capacity_to_tail(states, pi, up, b)
    pi_b = mp.fsum(pi[k] for k in range(b, 3 * n + 1))
    log_pi_b = mp.log(pi_b)
    r_upper = cap / (pi_b * abs(log_pi_b))

    d = 4 * n * n  # max{1/p(x,y): p(x,y)>0} -- attained by p(k,k+1)=1/(4n^2), 1<=k<=n
    k_over_logd = to_mp(target_k) / mp.log(d)
    ratio = r_upper / k_over_logd

    return {
        "n": n,
        "pi_1": pi[states[0]],
        "min_kappa_exact": min_kappa,
        "target_k_exact": target_k,
        "kappa_equals_target": min_kappa == target_k,
        "kappa_at_least_target": min_kappa >= target_k,
        "cap": cap,
        "pi_B": pi_b,
        "R_upper_bound": r_upper,
        "K_over_logd": k_over_logd,
        "ratio_R_over_Klogd": ratio,
    }


def build_control_chain(n: int, eps_den: int):
    """Discrimination-control family: a symmetric, linearly-drifting
    birth-death chain with CONSTANT positive curvature and a log-concave
    (discrete-Gaussian-shaped) invariant measure -- exactly the case the
    source paper itself names as satisfying the conjecture (Section 2,
    second bullet: "If the invariant measure is log-concave, then a lower
    Ollivier curvature bound K implies a lower Bakry-Emery bound K/2 ... and
    the conjecture follows from Theorem 1.1"). If our diagnostic (the same
    Theorem-2.1 capacitary ratio used for the BREAK instance above) showed a
    vanishing ratio here too, that would mean the machinery finds a
    "violation" of a case known to satisfy the conjecture -- a false
    positive. It should instead find a ratio that does NOT decay.
    """
    center = n + 1
    states = list(range(1, 2 * n + 2))
    eps = Fraction(1, eps_den)
    up, down = {}, {}
    for k in states:
        delta = k - center
        pu = Fraction(1, 4) - eps * delta
        pd = Fraction(1, 4) + eps * delta
        up[k] = pu if k < states[-1] else Fraction(0)
        down[k] = pd if k > states[0] else Fraction(0)
    return states, up, down, center


def control_instance(n: int) -> dict:
    eps_den = 8 * n
    states, up, down, center = build_control_chain(n, eps_den)
    pi, _z = stationary(states, up, down)
    kappas = curvature_edges(states, up, down)
    k_min = min(kappas.values())

    ratios = [pi[k] / pi[k + 1] for k in states[:-1]]
    log_concave = all(
        ratios[i] <= ratios[i + 1] + mp.mpf(10) ** -40 for i in range(len(ratios) - 1)
    )

    pi_a = mp.fsum(pi[k] for k in range(states[0], center + 1))
    pi_b = mp.fsum(pi[k] for k in range(center + 1, states[-1] + 1))
    cap = 1 / (1 / (pi[center] * to_mp(up[center])))

    all_probs = [v for v in list(up.values()) + list(down.values()) if v != 0]
    d = max(1 / to_mp(v) for v in all_probs)

    r_upper = cap / (pi_b * abs(mp.log(pi_b)))
    k_over_logd = to_mp(k_min) / mp.log(d)
    ratio = r_upper / k_over_logd

    return {
        "n": n,
        "pi_A": pi_a,
        "log_concave": log_concave,
        "min_kappa": k_min,
        "d": d,
        "R_upper_bound": r_upper,
        "K_over_logd": k_over_logd,
        "ratio_R_over_Klogd": ratio,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    ns = [4, 10, 30, 100, 300, 1000, 3000]
    instances = [break_instance(n) for n in ns]

    all_kappa_ok = all(inst["kappa_equals_target"] for inst in instances)
    all_pi1_over_half = all(inst["pi_1"] > mp.mpf("0.5") for inst in instances)

    ratios = [float(inst["ratio_R_over_Klogd"]) for inst in instances]
    strictly_decreasing = all(ratios[i] > ratios[i + 1] for i in range(len(ratios) - 1))
    final_ratio_small = ratios[-1] < 0.01

    ok = all_kappa_ok and all_pi1_over_half and strictly_decreasing and final_ratio_small

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "salez_youssef_logsobolev",
        "source_claim": (
            "Conjecture 1.2 (Salez-Youssef): Ollivier curvature K>0 implies "
            "alpha_LSI >= c*K/log(d) for a universal constant c"
        ),
        "source_refutation": "Munch (2025), arXiv:2504.08055, Theorem via Section 2",
        "corpus_pointer": "corpus/live-fragile-proofs-2024-2026.md",
        "local_pdf": "incoming/salez-youssef-munch-2504.08055.pdf",
        "instances": [
            {
                "n": inst["n"],
                "pi_1": mp.nstr(inst["pi_1"], 10),
                "min_kappa": str(inst["min_kappa_exact"]),
                "target_1_over_4n2": str(inst["target_k_exact"]),
                "kappa_equals_target_exact": inst["kappa_equals_target"],
                "cap": mp.nstr(inst["cap"], 10),
                "pi_B": mp.nstr(inst["pi_B"], 10),
                "R_upper_bound": mp.nstr(inst["R_upper_bound"], 10),
                "K_over_logd": mp.nstr(inst["K_over_logd"], 10),
                "ratio_R_over_Klogd": mp.nstr(inst["ratio_R_over_Klogd"], 10),
            }
            for inst in instances
        ],
        "all_kappa_matches_1_over_4n2_exactly": all_kappa_ok,
        "all_pi1_over_half": all_pi1_over_half,
        "ratio_strictly_decreasing_over_n": strictly_decreasing,
        "final_ratio_below_0.01": final_ratio_small,
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": (
            "alpha_LSI >= c*K/log(d) for a universal c, on Munch's birth-death family"
        ),
        "false_instance": (
            f"n={ns[-1]}: kappa=1/(4n^2), R(n)/[K/log d]="
            f"{mp.nstr(instances[-1]['ratio_R_over_Klogd'], 6)} and shrinking -- "
            "no fixed c survives n -> infinity"
        ),
        "ok": ok,
    }
    out = RESULTS / "salez_youssef_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] salez_youssef_logsobolev")
    for inst in instances:
        print(
            f"  n={inst['n']:5d} pi(1)={mp.nstr(inst['pi_1'], 6)} "
            f"kappa=1/(4n^2)={inst['kappa_equals_target']} "
            f"R={mp.nstr(inst['R_upper_bound'], 6)} "
            f"K/logd={mp.nstr(inst['K_over_logd'], 6)} "
            f"ratio={mp.nstr(inst['ratio_R_over_Klogd'], 6)}"
        )
    print(f"  ratio strictly decreasing over n: {strictly_decreasing}")
    print(f"  final ratio < 0.01: {final_ratio_small} ({ratios[-1]:.6g})")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
