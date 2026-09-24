"""Numeric gate (Type E): Holden's 127-term exact rational factorization of C7.

Source claim (pinned PDF incoming/nla-nr03-holden.pdf, Sidney Holden,
"The quadratic correlation matrix need not have full nonnegative rank",
September 2026):

    rank+(C7) <= 127 < 128, disproving the universal 2^n full-rank
    conjecture of NR-03.

The load-bearing object is an exact rational certificate, not a numerical
optimization: integer matrices W in Z^{128x127}, V in Z^{127x128} and
positive integer denominators d in Z^128 with

    W V = C7 diag(d),   H = V diag(d)^{-1},   C7 = W H,

where C7(a,b) = (1 - |a cap b|)^2 for a,b subsets of [7], rows/columns
indexed by integer masks 0..127 (bit i = element i+1).

This gate replays the paper's own construction-independent check (Appendix A
of the pinned PDF), re-derived: the target matrix is rebuilt from the mask
definition and never copied from the certificate file. All arithmetic is
exact (Python ints; Fraction for the rational cross-check).

Certificate source: data/factors_n7.json in sgstepaniants/OpenProblemsInNLA
at pinned commit f664d07e82aaa60bc9c78dd1946e763168c5c530, pinned locally at
incoming/nla-nr03-factors_n7.json (sha256 recorded in the meta).

Gates refute routes, not theorems: a PASS here says the exact certificate
verifies -- the factorization route is sound. It says nothing about the
exact nonnegative rank of C7 (the paper itself: "It does not assert that the
exact nonnegative rank of C7 is 127").
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
CERT = ROOT / "incoming" / "nla-nr03-factors_n7.json"

N = 7
DIM = 1 << N          # 128
R = 127               # 64 + 7 + 21 + 35 atoms
DENOM_VALUES = {1, 4, 9, 16, 25, 36}


def build_target() -> list[list[int]]:
    """Rebuild C7 from its definition: C7(a,b) = (1 - |a cap b|)^2,
    a,b integer masks 0..127. Independent of the certificate file."""
    return [
        [(1 - bin(a & b).count("1")) ** 2 for b in range(DIM)]
        for a in range(DIM)
    ]


def verify_certificate(
    W: list[list[int]],
    V: list[list[int]],
    d: list[int],
    target: list[list[int]],
) -> dict:
    """Exact verification of the certificate against an independently
    rebuilt target. Returns a dict of named checks (all must be True)."""
    checks: dict[str, object] = {}

    checks["W_dims_128x127"] = (
        len(W) == DIM and all(len(row) == R for row in W)
    )
    checks["V_dims_127x128"] = (
        len(V) == R and all(len(row) == DIM for row in V)
    )
    checks["d_len_128_positive_int"] = (
        len(d) == DIM and all(type(x) is int and x > 0 for x in d)
    )
    checks["W_entries_nonneg_int"] = all(
        type(x) is int and x >= 0 for row in W for x in row
    )
    checks["V_entries_nonneg_int"] = all(
        type(x) is int and x >= 0 for row in V for x in row
    )
    # Paper's stated entry ranges (corroboration, not load-bearing).
    checks["W_entries_in_0_1_2"] = all(x in (0, 1, 2) for row in W for x in row)
    checks["V_entries_le_36"] = all(x <= 36 for row in V for x in row)
    checks["denominators_in_paper_set"] = set(d) <= DENOM_VALUES

    # Path A: integer check, the paper's own Appendix-A verifier:
    #   sum_k W[a][k] V[k][b] == d[b] * target[a][b]   for all a,b.
    bad_a: list[tuple[int, int, int, int]] = []
    n_checked = 0
    for a in range(DIM):
        Wa = W[a]
        ta = target[a]
        for b in range(DIM):
            n_checked += 1
            s = 0
            for k in range(R):
                s += Wa[k] * V[k][b]
            if s != d[b] * ta[b]:
                bad_a.append((a, b, s, d[b] * ta[b]))
    checks["int_product_all_16384"] = (n_checked == DIM * DIM and not bad_a)
    checks["int_product_entries_checked"] = n_checked
    checks["int_product_bad_entries"] = bad_a[:5]

    # Path B: exact rational check with Fraction: H = V diag(d)^{-1},
    #   sum_k W[a][k] * V[k][b]/d[b] == target[a][b]   for all a,b.
    bad_b: list[tuple[int, int]] = []
    for a in range(DIM):
        Wa = W[a]
        ta = target[a]
        for b in range(DIM):
            db = d[b]
            s = Fraction(0)
            for k in range(R):
                s += Wa[k] * Fraction(V[k][b], db)
            if s != ta[b]:
                bad_b.append((a, b))
    checks["rational_product_all_16384"] = not bad_b
    checks["rational_product_bad_entries"] = bad_b[:5]

    # Corroboration: the paper states the check covers 5,103 zeros and
    # 11,281 positive entries. 5103 = sum_i C(7,i) i 2^{7-i} = 7 * 3^6.
    n_zero = sum(1 for row in target for x in row if x == 0)
    n_pos = DIM * DIM - n_zero
    checks["target_zero_count"] = n_zero
    checks["target_positive_count"] = n_pos
    checks["zero_count_matches_paper_5103"] = n_zero == 5103 == 7 * 3**6
    checks["positive_count_matches_paper_11281"] = n_pos == 11281

    # Term count: the factorization really uses 127 atoms.
    checks["term_count_127"] = len(W[0]) == R == 127

    ok = all(
        v is True
        for k, v in checks.items()
        if k
        not in (
            "int_product_entries_checked",
            "int_product_bad_entries",
            "rational_product_bad_entries",
            "target_zero_count",
            "target_positive_count",
        )
    )
    checks["ok"] = ok
    return checks


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    raw = CERT.read_bytes()
    cert_sha256 = hashlib.sha256(raw).hexdigest()
    cert = json.loads(raw.decode("utf-8"))
    W, V, d = cert["W"], cert["H_scaled"], cert["denominators"]

    meta_ok = cert.get("n") == 7 and cert.get("r") == 127

    target = build_target()
    checks = verify_certificate(W, V, d, target)
    ok = bool(meta_ok and checks["ok"])

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "nla_nr03",
        "source_claim": (
            "Holden (2026): rank+(C7) <= 127 < 128 via exact rational "
            "factorization, disproving the NR-03 universal 2^n conjecture"
        ),
        "local_pdf": "incoming/nla-nr03-holden.pdf",
        "local_pdf_sha256": "249a1c630d2442be22456cc7eaf12f02c80439c00ea08508663cb0742563db02",
        "certificate": "incoming/nla-nr03-factors_n7.json",
        "certificate_sha256": cert_sha256,
        "certificate_source": (
            "data/factors_n7.json in sgstepaniants/OpenProblemsInNLA at "
            "f664d07e82aaa60bc9c78dd1946e763168c5c530"
        ),
        "cert_metadata_n_r": [cert.get("n"), cert.get("r")],
        "cert_metadata_ok": meta_ok,
        "checks": {k: v for k, v in checks.items() if k != "ok"},
        "verdict": "PASS" if ok else "ABORT_TRANSCRIPTION",
        "lemma": (
            "exists nonnegative rational W (128x127), H (127x128) with "
            "W H = C7, i.e. rank+(C7) <= 127"
        ),
        "false_instance": None if ok else "certificate failed exact check",
        "ok": ok,
    }
    out = RESULTS / "nla_nr03_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2, default=str), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] nla_nr03")
    print(f"  cert sha256: {cert_sha256[:16]}...  metadata n,r = {cert.get('n')},{cert.get('r')}")
    print(f"  int path: {checks['int_product_entries_checked']} entries, "
          f"bad={len(checks['int_product_bad_entries'])}")
    print(f"  rational path: bad={len(checks['rational_product_bad_entries'])}")
    print(f"  target split: {checks['target_zero_count']} zeros / "
          f"{checks['target_positive_count']} positive (paper: 5103/11281)")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
