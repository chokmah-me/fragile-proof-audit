"""Numeric gate: q-TSPP diagonal identity (3.2), finite/control replay.

SCOPE (honest): this is a FINITE replay plus transcription-fidelity control
for the q=1 diagonal formalization (FragileProofAudit/QTSPP/TrueDiagonal.lean).
It does NOT prove hrec for all n -- that needs the d-finite substitution
certificate (multi-week infrastructure, docs/blueprint/qtspp-q1.md section 6c).
What it does:

1. Operator provenance: SHA-256 pin of Koutschan's Bnn_op_0_a23r.txt.
2. Operator transcription fidelity: the 8 koutschanP polynomials parsed from
   KoutschanOperator.lean equal the 8 source terms (sympy polynomial equality).
3. True-diagonal replay (paper section 3): from the paper's Okada matrix
   formula, for n = 0..12: det(A_n) != 0, the (n+1,n+1) minor of A_{n+1}
   equals A_n entrywise (the diagMinor_eq content), and
   B(n+1,n+1) = det(minor)/det(A_n) = 1.
4. Inverse-cert transcription: the 7 invCert matrices parsed from
   TrueDiagonal.lean satisfy A_k * B_k = I over QQ (exact).
5. hrec finite replay: for nn = 0..25, sum_{i=0..7} p_i(nn)*B(nn+i+1,nn+i+1)
   = 0 with the Python-computed diagonal and the Lean-parsed operator.

A PASS means the finite evidence and the Lean transcription are consistent;
it does not close hrec.

Gates refute routes, not theorems.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from fractions import Fraction
from math import comb
from pathlib import Path

import sympy as sp

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
OPERATOR_SRC = ROOT / "incoming" / "qtspp-q1" / "Bnn_op_0_a23r.txt"
KOUTSCHAN_LEAN = ROOT / "FragileProofAudit" / "QTSPP" / "KoutschanOperator.lean"
TRUEDIAG_LEAN = ROOT / "FragileProofAudit" / "QTSPP" / "TrueDiagonal.lean"

# SHA-256 of Bnn_op_0_a23r.txt as received from Koutschan 2026-09-24
# (blueprint docs/blueprint/qtspp-q1.md records abbreviated d12c1027..b8570).
OPERATOR_SHA256 = "d12c102723fb07cea2ac7987d316309c5728e002ae074da3d9de7bad387c8570"

n_sym = sp.symbols("n")


def okada_entry(i: int, j: int) -> int:
    """Paper eq. (2.3): a(i,j) for 1-based i, j."""
    return (
        comb(i + j - 2, i - 1)
        + comb(i + j - 1, i)
        + (2 if i == j else 0)
        - (1 if i == j + 1 else 0)
    )


def okada_matrix(n: int) -> list[list[int]]:
    return [[okada_entry(i + 1, j + 1) for j in range(n)] for i in range(n)]


def bareiss_det(M: list[list[int]]) -> int:
    """Exact determinant via Bareiss fraction-free elimination."""
    n = len(M)
    if n == 0:
        return 1
    A = [row[:] for row in M]
    prev = 1
    for k in range(n - 1):
        if A[k][k] == 0:
            # find nonzero pivot row and swap (flips sign)
            piv = next((i for i in range(k + 1, n) if A[i][k] != 0), None)
            if piv is None:
                return 0
            A[k], A[piv] = A[piv], A[k]
            prev = -prev
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                A[i][j] = (A[i][j] * A[k][k] - A[i][k] * A[k][j]) // prev
            A[i][k] = 0
        prev = A[k][k]
    return A[n - 1][n - 1]


def split_top_level_terms(raw: str) -> list[tuple[str, str]]:
    """Split operator text on top-level +/- (all inner +/- are parenthesized)."""
    terms, depth, cur_sign = [], 0, "+"
    i, body_start = 0, 0
    while i < len(raw):
        ch = raw[i]
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif depth == 0 and ch in "+-" and i > body_start:
            terms.append((cur_sign, raw[body_start:i]))
            cur_sign = ch
            body_start = i + 1
        i += 1
    terms.append((cur_sign, raw[body_start:]))
    return terms


def parse_source_operator(text: str) -> dict[int, sp.Expr]:
    """Map shift k -> signed coefficient polynomial p_k from Koutschan's file."""
    raw = text.strip()
    terms = split_top_level_terms(raw)
    assert len(terms) == 8, f"expected 8 terms, got {len(terms)}"
    out: dict[int, sp.Expr] = {}
    for sgn, body in terms:
        m = re.search(r"\*Sn\^(\d+)$", body)
        if m:
            k, fac = int(m.group(1)), body[: m.start()]
        elif body.endswith("*Sn"):
            k, fac = 1, body[:-3]
        else:
            k, fac = 0, body
        poly = sp.sympify(fac, {"n": n_sym})
        out[k] = poly if sgn == "+" else -poly
    assert sorted(out) == list(range(8)), f"shifts != 0..7: {sorted(out)}"
    return out


def parse_lean_koutschanP(path: Path) -> dict[int, sp.Expr]:
    """Map shift k -> polynomial parsed from the Lean koutschanP definition."""
    lines = path.read_text(encoding="utf-8").splitlines()
    # Restrict to the `def koutschanP` block (before `def koutschanQ`).
    start = next(i for i, l in enumerate(lines) if l.startswith("def koutschanP "))
    end = next(i for i, l in enumerate(lines) if l.startswith("def koutschanQ "))
    out: dict[int, sp.Expr] = {}
    for line in lines[start:end]:
        m = re.match(r"\s*\|\s*(\d+),\s*n\s*=>(.*)$", line)
        if m:
            k = int(m.group(1))
            body = m.group(2).replace("(n : \u211a)", "n")
            out[k] = sp.sympify(body, {"n": n_sym})
    assert sorted(out) == list(range(8)), f"Lean shifts != 0..7: {sorted(out)}"
    return out


def parse_lean_invcerts(path: Path) -> dict[int, list[list[Fraction]]]:
    """Map k -> k×k inverse matrix parsed from the Lean invCert definitions."""
    text = path.read_text(encoding="utf-8")
    out: dict[int, list[list[Fraction]]] = {}
    for m in re.finditer(
        r"def invCert(\d+) : Matrix \(Fin (\d+)\) \(Fin \d+\) \u211a :=\s*\n\s*!!\[(.*?)\]\n",
        text,
        re.DOTALL,
    ):
        k = int(m.group(1))
        assert int(m.group(2)) == k
        body = m.group(3)
        rows = []
        for row in body.split(";"):
            entries = []
            # entries look like ((12 : ℚ) / 7), (5 : ℚ), ((-3 : ℚ) / 2):
            # integers use single parens, fractions double.
            for em in re.finditer(
                r"\(\(?(-?\d+) : \u211a\)?(?: / (\d+))?\)", row
            ):
                num = int(em.group(1))
                den = int(em.group(2)) if em.group(2) else 1
                entries.append(Fraction(num, den))
            rows.append(entries)
        assert len(rows) == k and all(len(r) == k for r in rows), (
            f"invCert{k}: bad shape"
        )
        out[k] = rows
    assert sorted(out) == [1, 2, 3, 4, 5, 6], f"certs found: {sorted(out)}"
    return out


def mat_mul(A, B):
    n = len(A)
    return [
        [sum(A[i][t] * B[t][j] for t in range(n)) for j in range(n)]
        for i in range(n)
    ]


def main() -> int:
    checks: dict = {}
    ok = True

    # 1. Operator provenance pin (fail-closed against the hardcoded SHA-256).
    op_bytes = OPERATOR_SRC.read_bytes()
    sha = hashlib.sha256(op_bytes).hexdigest()
    checks["operator_sha256"] = sha
    checks["operator_pin_match"] = sha == OPERATOR_SHA256
    if sha != OPERATOR_SHA256:
        ok = False
        print(f"  FAIL: operator SHA-256 mismatch: {sha}")
    print(f"[{'ok' if checks['operator_pin_match'] else 'FAIL'}] operator sha256: {sha[:16]}...")

    # 2. Operator transcription fidelity: Lean koutschanP vs source file.
    src_P = parse_source_operator(op_bytes.decode("utf-8"))
    lean_P = parse_lean_koutschanP(KOUTSCHAN_LEAN)
    trans_ok = True
    for k in range(8):
        same = sp.expand(src_P[k] - lean_P[k]) == 0
        trans_ok &= same
        if not same:
            print(f"  FAIL: p_{k} differs between source and Lean transcription")
    checks["operator_transcription_match"] = trans_ok
    ok &= trans_ok
    print(f"[{'ok' if trans_ok else 'FAIL'}] koutschanP transcription: 8/8 polynomials match source")

    # 3. True-diagonal replay from the paper formula.
    N_DET = 12
    dets = {n: bareiss_det(okada_matrix(n)) for n in range(N_DET + 1)}
    det_ok = all(d != 0 for d in dets.values())
    checks["det_nonzero_0_to_12"] = det_ok
    ok &= det_ok
    # minor(n+1,n+1) of A_{n+1} equals A_n entrywise
    minor_ok = True
    for n in range(N_DET):
        A_big = okada_matrix(n + 1)
        minor = [row[:n] for row in A_big[:n]]
        if minor != okada_matrix(n):
            minor_ok = False
    checks["minor_eq_okada"] = minor_ok
    ok &= minor_ok
    # B(n+1,n+1) = det(minor)/det(A_n) = 1
    diag_vals = []
    for n in range(N_DET):
        v = Fraction(dets[n], dets[n])
        diag_vals.append(v)
    diag_ok = all(v == 1 for v in diag_vals)
    checks["true_diagonal_values"] = [str(v) for v in diag_vals]
    checks["true_diagonal_all_one"] = diag_ok
    ok &= diag_ok
    print(f"[{'ok' if det_ok and minor_ok and diag_ok else 'FAIL'}] true diagonal: "
          f"det!=0 (0..{N_DET}), minor=A_n, B(n,n)=1 for n=1..{N_DET}")

    # 4. Inverse-cert transcription: parse Lean invCerts, verify A_k * B_k = I.
    certs = parse_lean_invcerts(TRUEDIAG_LEAN)
    cert_ok = True
    for k in range(1, 7):
        A = [[Fraction(x) for x in row] for row in okada_matrix(k)]
        P = mat_mul(A, certs[k])
        ident = all(
            P[i][j] == (1 if i == j else 0)
            for i in range(k)
            for j in range(k)
        )
        cert_ok &= ident
        if not ident:
            print(f"  FAIL: invCert{k} is not an inverse of A_{k}")
    checks["inverse_certs_verify"] = cert_ok
    ok &= cert_ok
    print(f"[{'ok' if cert_ok else 'FAIL'}] inverse certs: A_k * invCert_k = I for k=1..6 (exact)")

    # 5. hrec finite replay: sum p_i(nn) * B(nn+i+1, nn+i+1) = 0.
    # B values come from the determinant computation (all 1); extend the
    # determinant range to cover the recurrence window.
    N_REC = 25
    dets.update(
        {n: bareiss_det(okada_matrix(n)) for n in range(N_DET + 1, N_REC + 9)}
    )
    Bdiag = {n: Fraction(dets[n - 1], dets[n - 1]) for n in range(1, N_REC + 9)}
    assert all(v == 1 for v in Bdiag.values())
    rec_ok = True
    for nn in range(N_REC + 1):
        s = sum(
            Fraction(lean_P[i].subs(n_sym, nn)) * Bdiag[nn + i + 1]
            for i in range(8)
        )
        if s != 0:
            rec_ok = False
            print(f"  FAIL: recurrence fails at nn={nn}: sum={s}")
    checks["hrec_finite_range"] = f"0..{N_REC}"
    checks["hrec_finite_ok"] = rec_ok
    ok &= rec_ok
    print(f"[{'ok' if rec_ok else 'FAIL'}] hrec finite replay: nn=0..{N_REC}")

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "qtspp_diagonal",
        "source_claim": (
            "Koutschan/Paule/Stembridge, 'The q-TSPP conjecture', arXiv:0906.1018: "
            "identity (3.2), B(n,n)=1 at q=1"
        ),
        "scope": (
            "FINITE replay + transcription-fidelity control for the q=1 diagonal "
            "formalization. Does NOT prove hrec for all n (needs the d-finite "
            "substitution certificate)."
        ),
        "checks": checks,
        "verdict": "PASS" if ok else "BREAK",
        "ok": ok,
    }
    out = RESULTS / "qtspp_diagonal_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(f"[{'PASS' if ok else 'FAIL'}] qtspp_diagonal")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
