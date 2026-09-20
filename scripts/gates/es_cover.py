"""Gate: Lopez arXiv:2404.01508 Conjecture 1 covering on hard residues mod 840.

For every prime p in {1,121,169,289,361,529} mod 840 below LIMIT, search the
paper's Type A / Type B congruence families:

    Type A:  p ≡ -4d  (mod 4 d n - 1)     (Theorem 7)
    Type B:  p ≡ -n   (mod 4 d n - 1)     (Theorem 4)

with d ≤ ⌊(p+3)/8⌋ (Propositions 1 and 3). Exact integer arithmetic only.

PASS  = every hard-class prime in range is covered (escalate; do not force kill).
BREAK = first uncovered prime (route kill; does not claim ESC is false).
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

HARD_RESIDUES = (1, 121, 169, 289, 361, 529)
DEFAULT_LIMIT = 10**4
WIDE_LIMIT = 10**5


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def d_max(p: int) -> int:
    """Paper Propositions 1 and 3: d ≤ ⌊(p+3)/8⌋."""
    return (p + 3) // 8


def find_type_A(p: int) -> tuple[int, int] | None:
    """Return (d, n) witnessing Type A, or None.

    Search uses p + 4d = q (4 d n - 1) for q ≥ 1, rearranged to
    n = (p + 4d + q) / (4 q d).
    """
    for d in range(1, d_max(p) + 1):
        qmax = (p + 4 * d) // (4 * d - 1)
        for q in range(1, qmax + 1):
            num = p + 4 * d + q
            den = 4 * q * d
            if num % den != 0:
                continue
            n = num // den
            if n < 1:
                continue
            m = 4 * d * n - 1
            if m > 0 and (p + 4 * d) % m == 0:
                return d, n
    return None


def find_type_B(p: int) -> tuple[int, int] | None:
    """Return (d, n) witnessing Type B, or None.

    Search uses p + n = q (4 d n - 1) for q ≥ 1, rearranged to
    n = (p + q) / (4 q d - 1).
    """
    for d in range(1, d_max(p) + 1):
        qmax = (p + 1) // (4 * d - 1)
        for q in range(1, qmax + 1):
            den = 4 * q * d - 1
            if den <= 0 or (p + q) % den != 0:
                continue
            n = (p + q) // den
            if n < 1:
                continue
            m = 4 * d * n - 1
            if m > 0 and (p + n) % m == 0:
                return d, n
    return None


def type_A_solution(p: int, d: int, n: int) -> tuple[int, int, int]:
    """Constructive (du, dv, duv) from the Type A congruence."""
    m = 4 * d * n - 1
    u = (1 + n * p) // m
    v = n * p
    return d * u, d * v, d * u * v


def type_B_solution(p: int, d: int, n: int) -> tuple[int, int, int]:
    """Constructive (duv, du p, dv p) from Theorem 4."""
    m = 4 * d * n - 1
    u = (p + n) // m
    v = n
    return d * u * v, d * u * p, d * v * p


def egyptian3(p: int, x: int, y: int, z: int) -> bool:
    """4/p = 1/x + 1/y + 1/z as an exact integer identity."""
    return x > 0 and y > 0 and z > 0 and 4 * x * y * z == p * (y * z + x * z + x * y)


def hard_primes_below(limit: int) -> list[int]:
    return [
        p
        for p in range(2, limit)
        if p % 840 in HARD_RESIDUES and is_prime(p)
    ]


def odd_k_automatic_fold(sample_k: range | None = None) -> dict:
    """Side check: Appendix II claim that odd k is automatic via d=u=1, v=2.

    For k odd, k+1 is even, so 1 | (k+1), 2 | (k+1), and 4·1−1 = 3 divides
    1+2. Hence (4d−1)/(k+d) is Egyptian of order 2, giving a Type II solution
    of 4/(4k+1). Hard residues are all ≡1 (mod 8), so k is even there — this
    fold never covers the gate universe.
    """
    if sample_k is None:
        sample_k = range(1, 200, 2)
    failures: list[int] = []
    for k in sample_k:
        if k % 2 == 0:
            continue
        d, u, v = 1, 1, 2
        # 4d-1 | u+v and u,v | (k+d)
        if (k + d) % u != 0 or (k + d) % v != 0:
            failures.append(k)
            continue
        if (u + v) % (4 * d - 1) != 0:
            failures.append(k)
            continue
        # Lift to ESC solution: 4/n = 1/x + 1/(n y) + 1/(n z) with n=4k+1, x=k+d
        n = 4 * k + 1
        x = k + d
        # From  (4d-1)/x = 1/y' + 1/z' with y'=y, z'=z in paper notation —
        # identity used in Theorem 10: 4/n = 1/x + 1/(n y) + 1/(n z) where
        # (4d-1)/x = 1/y + 1/z. With u,v | x and 4d-1 | u+v one standard
        # choice is y = x/u * ((u+v)/(4d-1)), z = x/v * ((u+v)/(4d-1)) wait:
        # classical: a/b Egyptian-2 iff ∃u,v|b with a|u+v; then
        # a/b = 1/(b/u · (u+v)/a) + 1/(b/v · (u+v)/a).
        a = 4 * d - 1
        b = x
        y = (b // u) * ((u + v) // a)
        z = (b // v) * ((u + v) // a)
        if a * y * z != b * (y + z):
            failures.append(k)
            continue
        # Full ESC triple
        if not egyptian3(n, x, n * y, n * z):
            failures.append(k)
    return {
        "note": "NOT the covering gate. Appendix II odd-k fold only.",
        "sample_odd_k_count": len([k for k in sample_k if k % 2 == 1]),
        "failures": failures[:10],
        "ok": len(failures) == 0,
        "hard_residues_all_even_k": all(
            ((r - 1) // 4) % 2 == 0 for r in HARD_RESIDUES
        ),
    }


def cover_prime(p: int) -> dict:
    a = find_type_A(p)
    b = find_type_B(p)
    rec: dict = {
        "p": p,
        "residue_mod_840": p % 840,
        "type_A": None if a is None else {"d": a[0], "n": a[1]},
        "type_B": None if b is None else {"d": b[0], "n": b[1]},
        "covered": a is not None or b is not None,
    }
    # Harness: constructive solution must satisfy the Egyptian identity.
    if a is not None:
        sol = type_A_solution(p, a[0], a[1])
        rec["type_A"]["solution"] = list(sol)
        rec["type_A"]["egyptian_ok"] = egyptian3(p, *sol)
        if not rec["type_A"]["egyptian_ok"]:
            rec["covered"] = False
            rec["harness_fail"] = "type_A_solution"
    if b is not None:
        sol = type_B_solution(p, b[0], b[1])
        rec["type_B"]["solution"] = list(sol)
        rec["type_B"]["egyptian_ok"] = egyptian3(p, *sol)
        if not rec["type_B"]["egyptian_ok"]:
            rec["covered"] = False
            rec["harness_fail"] = "type_B_solution"
    return rec


def run_sweep(limit: int) -> dict:
    primes = hard_primes_below(limit)
    uncovered: list[dict] = []
    stats = {"A_only": 0, "B_only": 0, "both": 0, "neither": 0}
    witnesses: list[dict] = []
    for p in primes:
        rec = cover_prime(p)
        a_ok = rec["type_A"] is not None and rec["type_A"].get("egyptian_ok", False)
        b_ok = rec["type_B"] is not None and rec["type_B"].get("egyptian_ok", False)
        if a_ok and b_ok:
            stats["both"] += 1
        elif a_ok:
            stats["A_only"] += 1
        elif b_ok:
            stats["B_only"] += 1
        else:
            stats["neither"] += 1
            uncovered.append(rec)
        if len(witnesses) < 6 and (a_ok or b_ok):
            witnesses.append(rec)
        if uncovered:
            # First uncovered ends the BREAK path; still finish stats? Campaign
            # asks to log the first uncovered prime. Stop early for speed.
            break
    return {
        "limit": limit,
        "hard_prime_count": len(primes),
        "stats": stats,
        "uncovered": uncovered,
        "sample_covered": witnesses,
        "all_covered": len(uncovered) == 0,
    }


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)
    odd_k = odd_k_automatic_fold()
    first = run_sweep(DEFAULT_LIMIT)
    wide = None
    if first["all_covered"]:
        wide = run_sweep(WIDE_LIMIT)

    if not first["all_covered"]:
        verdict = "BREAK"
    elif wide is not None and not wide["all_covered"]:
        verdict = "BREAK"
    elif not odd_k["ok"]:
        # Side-check failure is a harness/transcription alarm, not covering BREAK.
        verdict = "BREAK"
    else:
        verdict = "PASS"

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": "2e",
        "source": "arXiv:2404.01508",
        "pdf": "incoming/erdos-straus-2404.01508.pdf",
        "hard_residues_mod_840": list(HARD_RESIDUES),
        "conjecture": (
            "exists d,n: p ≡ -4d (mod 4dn-1) or p ≡ -n (mod 4dn-1)"
        ),
        "first_pass": first,
        "wide_pass": wide,
        "odd_k_side_check": odd_k,
        "verdict": verdict,
        "note": (
            "PASS escalates — does not prove ESC. "
            "BREAK is a covering-route kill, not a claim that ESC is false."
        ),
    }
    out = RESULTS / "es_cover_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"[PASS] es_cover" if verdict == "PASS" else f"[BREAK] es_cover")
    print(f"  hard residues mod 840: {list(HARD_RESIDUES)}")
    print(
        f"  first pass p<{DEFAULT_LIMIT}: "
        f"primes={first['hard_prime_count']} covered={first['all_covered']} "
        f"stats={first['stats']}"
    )
    if wide is not None:
        print(
            f"  wide pass p<{WIDE_LIMIT}: "
            f"primes={wide['hard_prime_count']} covered={wide['all_covered']} "
            f"stats={wide['stats']}"
        )
    if first["uncovered"] or (wide and wide["uncovered"]):
        u = (first["uncovered"] or (wide["uncovered"] if wide else []))[0]
        print(f"  first uncovered: p={u['p']} ≡{u['residue_mod_840']} (mod 840)")
    print(
        f"  odd-k side check ok={odd_k['ok']} "
        f"(hard classes all even k={odd_k['hard_residues_all_even_k']})"
    )
    print(f"  verdict: {verdict}")
    print(f"Wrote {out}")
    # Gate script exits 0 when the checker itself ran; verdict is in JSON.
    # CI treats a runnable gate as PASS registration; BREAK is a finding.
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
