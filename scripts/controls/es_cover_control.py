"""Matched negative control for es_cover.py (Phase 2(e)).

The first control was NOT matched: its perturbed search brute-forced n over a
wider range than find_type_A's divisibility rearrangement, so "perturbed also
covers 27/27" could have been an artefact of extra search breadth.

Here every variant -- true and perturbed -- runs through ONE generic, complete
search. Breadth is identical by construction; only the congruence's arithmetic
content changes. Equivalence with the repo gate is verified, not assumed.

Generic Type A:  exists d <= dmax, n >= 1 with
                 m = Mm*d*n + Mo,  m > 0,  m | (p + Am*d + Ao)
     real A: Mm=4, Mo=-1, Am=4, Ao=0   ->  (4dn-1) | (p+4d)

Generic Type B:  exists d <= dmax, n >= 1 with
                 m = Mm*d*n + Mo,  m > 0,  m | (p + Bm*n + Bo)
     real B: Mm=4, Mo=-1, Bm=1, Bo=0   ->  (4dn-1) | (p+n)

Beyond mere coverage the control also asks the question that actually matters:
do the paper's constructive formulas (Theorems 4 and 7) turn a witness into a
genuine Egyptian triple? Coverage is cheap; producing 4/p = 1/x+1/y+1/z is not.
"""
import sys
from statistics import median

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "gates"))
sys.path.insert(0, str(ROOT / "scripts" / "controls"))
import es_cover as ES  # noqa: E402
from receipt import write_receipt  # noqa: E402


def divisors(T):
    if T <= 0:
        return []
    out, i = [], 1
    while i * i <= T:
        if T % i == 0:
            out.append(i)
            if i != T // i:
                out.append(T // i)
        i += 1
    return out


def searchA(p, Mm, Mo, Am, Ao, first_only=False):
    """All (d, n, m) with m = Mm*d*n + Mo dividing p + Am*d + Ao."""
    res = []
    for d in range(1, ES.d_max(p) + 1):
        T = p + Am * d + Ao
        if T <= 0:
            continue
        step = Mm * d
        for m in divisors(T):
            r = m - Mo
            if r <= 0 or r % step:
                continue
            n = r // step
            if n >= 1:
                res.append((d, n, m))
                if first_only:
                    return res
    return res


def searchB(p, Mm, Mo, Bm, Bo, first_only=False):
    """All (d, n, m) with m = Mm*d*n + Mo dividing p + Bm*n + Bo.

    p + Bm*n = q*m  =>  p - q*Mo + Bo = n*(q*Mm*d - Bm).
    """
    res = []
    for d in range(1, ES.d_max(p) + 1):
        denom_step = Mm * d + Mo
        if denom_step <= 0:
            continue
        qmax = (p + Bm + Bo) // denom_step
        for q in range(1, qmax + 1):
            den = q * Mm * d - Bm
            if den <= 0:
                continue
            num = p - q * Mo + Bo
            if num <= 0 or num % den:
                continue
            n = num // den
            if n < 1:
                continue
            m = Mm * d * n + Mo
            if m > 0 and (p + Bm * n + Bo) % m == 0:
                res.append((d, n, m))
                if first_only:
                    return res
    return res


def solA(p, d, n, m):
    """Theorem 7 construction, with the variant's own m."""
    if m <= 0 or (1 + n * p) % m:
        return None
    u = (1 + n * p) // m
    v = n * p
    return d * u, d * v, d * u * v


def solB(p, d, n, m):
    """Theorem 4 construction, with the variant's own m."""
    if m <= 0 or (p + n) % m:
        return None
    u = (p + n) // m
    v = n
    return d * u * v, d * u * p, d * v * p


VARIANTS = [
    # label,                 kind, params
    ("A  real   (4dn-1)|(p+4d)", "A", dict(Mm=4, Mo=-1, Am=4, Ao=0)),
    ("A  m+1    (4dn+1)|(p+4d)", "A", dict(Mm=4, Mo=+1, Am=4, Ao=0)),
    ("A  m-3    (4dn-3)|(p+4d)", "A", dict(Mm=4, Mo=-3, Am=4, Ao=0)),
    ("A  3dn    (3dn-1)|(p+4d)", "A", dict(Mm=3, Mo=-1, Am=4, Ao=0)),
    ("A  tgt+1  (4dn-1)|(p+4d+1)", "A", dict(Mm=4, Mo=-1, Am=4, Ao=1)),
    ("A  tgt3d  (4dn-1)|(p+3d)", "A", dict(Mm=4, Mo=-1, Am=3, Ao=0)),
    ("B  real   (4dn-1)|(p+n)", "B", dict(Mm=4, Mo=-1, Bm=1, Bo=0)),
    ("B  m+1    (4dn+1)|(p+n)", "B", dict(Mm=4, Mo=+1, Bm=1, Bo=0)),
    ("B  tgt2n  (4dn-1)|(p+2n)", "B", dict(Mm=4, Mo=-1, Bm=2, Bo=0)),
    ("B  tgt+1  (4dn-1)|(p+n+1)", "B", dict(Mm=4, Mo=-1, Bm=1, Bo=1)),
]


def run(primes, full=True):
    rows = []
    for label, kind, kw in VARIANTS:
        cov = 0
        wcounts, mind, egypt_ok, egypt_tot = [], [], 0, 0
        for p in primes:
            ws = (searchA if kind == "A" else searchB)(
                p, first_only=not full, **kw)
            if ws:
                cov += 1
                wcounts.append(len(ws))
                mind.append(min(w[0] for w in ws))
                for (d, n, m) in ws:
                    s = (solA if kind == "A" else solB)(p, d, n, m)
                    egypt_tot += 1
                    if s and ES.egyptian3(p, *s):
                        egypt_ok += 1
        rows.append({
            "label": label,
            "cov": cov,
            "n": len(primes),
            "wmean": (sum(wcounts) / len(wcounts)) if wcounts else 0.0,
            "wmed": median(wcounts) if wcounts else 0,
            "dmed": median(mind) if mind else 0,
            "egypt": (100.0 * egypt_ok / egypt_tot) if egypt_tot else 0.0,
            "egypt_tot": egypt_tot,
        })
    return rows


def show(title, rows):
    print(f"\n=== {title} ===")
    print(f"{'variant':<28} {'covered':>9} {'witnesses/p':>22} {'min d':>6} "
          f"{'Egyptian-valid':>16}")
    print(f"{'':<28} {'':>9} {'mean':>10} {'median':>10} {'med':>6} "
          f"{'% of witnesses':>16}")
    for r in rows:
        print(f"{r['label']:<28} {r['cov']:>4}/{r['n']:<4} "
              f"{r['wmean']:>10.1f} {r['wmed']:>10} {r['dmed']:>6} "
              f"{r['egypt']:>13.1f} %")


if __name__ == "__main__":
    LIM = int(sys.argv[1]) if len(sys.argv) > 1 else 10 ** 4
    primes = ES.hard_primes_below(LIM)
    print(f"hard-class primes < {LIM}: {len(primes)}")

    # ---- equivalence check: generic search vs the repo's own q-loop ----
    print("\n=== equivalence: generic search == repo find_type_A/B ===")
    bad = []
    for p in primes:
        mine_A = bool(searchA(p, Mm=4, Mo=-1, Am=4, Ao=0, first_only=True))
        mine_B = bool(searchB(p, Mm=4, Mo=-1, Bm=1, Bo=0, first_only=True))
        repo_A = ES.find_type_A(p) is not None
        repo_B = ES.find_type_B(p) is not None
        if mine_A != repo_A or mine_B != repo_B:
            bad.append((p, mine_A, repo_A, mine_B, repo_B))
    print(f"  disagreements over {len(primes)} primes: {len(bad)}")
    if bad:
        print("  ", bad[:5])
        print("EQUIVALENCE FAILED - control is not matched")
        write_receipt(
            control="es_cover_control",
            gate="es_cover",
            verdict="CONTROL NOT MATCHED",
            checks={"equivalence": {"primes": len(primes),
                                    "disagreements": len(bad),
                                    "sample": bad[:5], "ok": False}},
            ok=False,
            extra={"limit": LIM},
        )
        raise SystemExit(1)
    print("  generic search reproduces the gate exactly -> breadth is matched")

    variant_rows = run(primes, full=True)
    show(f"matched control, hard-class primes < {LIM}", variant_rows)

    # union coverage, real vs each perturbed pairing
    print("\n=== union coverage (Type A or Type B), matched search ===")
    pairs = [
        ("real A or real B", dict(Mm=4, Mo=-1, Am=4, Ao=0), dict(Mm=4, Mo=-1, Bm=1, Bo=0)),
        ("m+1 A or m+1 B", dict(Mm=4, Mo=+1, Am=4, Ao=0), dict(Mm=4, Mo=+1, Bm=1, Bo=0)),
        ("tgt+1 A or tgt+1 B", dict(Mm=4, Mo=-1, Am=4, Ao=1), dict(Mm=4, Mo=-1, Bm=1, Bo=1)),
        ("3dn A or tgt2n B", dict(Mm=3, Mo=-1, Am=4, Ao=0), dict(Mm=4, Mo=-1, Bm=2, Bo=0)),
    ]
    union_rows = []
    for label, ka, kb in pairs:
        c = sum(
            1 for p in primes
            if searchA(p, first_only=True, **ka) or searchB(p, first_only=True, **kb)
        )
        print(f"  {label:<22} {c:>4}/{len(primes)}")
        union_rows.append({"pairing": label, "covered": c, "of": len(primes)})

    # Which signal decides. Established 2026-09-20 (commit 3f8a78f) and
    # recorded in docs/GATE-BEFORE-PROVE.md: COVERAGE IS UNINFORMATIVE here --
    # every perturbed congruence also finds witnesses for every hard-class
    # prime, so a coverage comparison cannot discriminate and must not be
    # dressed up as though it could. What discriminates is `egyptian3`: the
    # real congruence's witnesses are Egyptian-valid, the perturbed ones' are
    # not. The receipt records both so the distinction stays visible.
    real_rows = [r for r in variant_rows if r["label"].split()[1] == "real"]
    perturbed_rows = [r for r in variant_rows if r["label"].split()[1] != "real"]
    real_egypt_full = all(r["egypt"] == 100.0 for r in real_rows)
    perturbed_egypt_zero = all(r["egypt"] == 0.0 for r in perturbed_rows)
    coverage_uninformative = all(
        r["covered"] == len(primes) for r in union_rows
    )
    ok = real_egypt_full and perturbed_egypt_zero
    print(f"\n  decisive signal (egyptian3): real variants 100% valid = "
          f"{real_egypt_full}; perturbed variants 0% valid = "
          f"{perturbed_egypt_zero}")
    print(f"  coverage comparison uninformative, as previously established: "
          f"{coverage_uninformative}")
    write_receipt(
        control="es_cover_control",
        gate="es_cover",
        verdict="NO FALSE NEGATIVE" if ok else "REVIEW",
        checks={
            "equivalence": {"primes": len(primes), "disagreements": 0,
                            "ok": True},
            "union_coverage": {"rows": union_rows,
                               "coverage_uninformative": coverage_uninformative,
                               "decides_nothing": True},
            "egyptian3_discrimination": {
                "real_variants_100_percent_valid": real_egypt_full,
                "perturbed_variants_0_percent_valid": perturbed_egypt_zero,
                "variant_rows": variant_rows,
                "ok": ok,
            },
        },
        ok=ok,
        extra={"limit": LIM},
    )
