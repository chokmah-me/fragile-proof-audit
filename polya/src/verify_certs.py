#!/usr/bin/env python3
"""Independent verifier for the Polya chunk certificates.

Checks, from certs + manifest alone (no sieve re-run):
  (a) L(n) <= 0 for every 2 <= n < FIRST_CROSS, via per-chunk max prefixes;
  (b) the first n >= 2 with L(n) > 0 is exactly FIRST_CROSS with L = +1.

Also verifies manifest SHA-256 pins, chunk contiguity/coverage of [2, N],
and internal consistency of boundary sums. Exit 0 iff everything passes.

Usage: verify_certs.py [certs_dir] [first_cross_expected]
"""
import hashlib
import json
import sys
from pathlib import Path

DEFAULT_FIRST_CROSS = 906150257


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def fail(msg: str) -> int:
    print(f"FAIL: {msg}")
    return 1


def main() -> int:
    certdir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "certs"
    expected_cross = int(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_FIRST_CROSS

    manifest = json.loads((certdir / "manifest.json").read_text())
    N = manifest["N"]
    n_checks = 0

    # 1. SHA-256 pins
    for entry in manifest["files"]:
        p = certdir / entry["file"]
        if sha256_file(p) != entry["sha256"]:
            return fail(f"checksum mismatch: {entry['file']}")
        n_checks += 1

    certs = [json.loads((certdir / e["file"]).read_text()) for e in manifest["files"]]
    certs.sort(key=lambda c: c["chunk"])

    # 2. Contiguity and coverage of [2, N]
    if [c["chunk"] for c in certs] != list(range(len(certs))):
        return fail("chunk indices not 0..k-1")
    n_checks += 1
    lo_expect = 2
    for c in certs:
        if c["lo"] != lo_expect:
            return fail(f"chunk {c['chunk']}: lo={c['lo']} != expected {lo_expect}")
        if c["count"] != c["hi"] - c["lo"] + 1:
            return fail(f"chunk {c['chunk']}: count mismatch")
        lo_expect = c["hi"] + 1
        n_checks += 1
    if lo_expect - 1 != N:
        return fail(f"certs cover [2, {lo_expect - 1}], expected N={N}")
    n_checks += 1

    # 3. Boundary sums: L_before must chain (L(1) = +1 initial offset)
    L = 1
    for c in certs:
        if c["L_before"] != L:
            return fail(f"chunk {c['chunk']}: L_before={c['L_before']} != chained {L}")
        L += c["sum_lambda"]
        n_checks += 1
    if L != manifest["anchors"]["L_N"]:
        return fail(f"final L={L} != manifest L_N={manifest['anchors']['L_N']}")
    n_checks += 1

    # 4a. No positive L(n) before the crossing chunk
    cross_chunks = [c for c in certs if c["first_cross"]]
    if len(cross_chunks) != 1:
        return fail(f"expected exactly 1 crossing chunk, found {len(cross_chunks)}")
    n_checks += 1
    xc = cross_chunks[0]
    for c in certs:
        if c["chunk"] < xc["chunk"]:
            if c["L_before"] + c["max_prefix"] > 0:
                return fail(f"chunk {c['chunk']}: positive L before crossing")
            n_checks += 1
    if xc["max_prefix_before_first"] is None:
        return fail("crossing chunk missing max_prefix_before_first")
    if xc["L_before"] + xc["max_prefix_before_first"] > 0:
        return fail("positive L inside crossing chunk before first_cross")
    n_checks += 1

    # 4b. The crossing itself
    if xc["first_cross"] != expected_cross:
        return fail(f"first_cross={xc['first_cross']} != expected {expected_cross}")
    n_checks += 1
    if xc["L_at_first_cross"] != 1:
        return fail(f"L at first crossing = {xc['L_at_first_cross']} != +1")
    n_checks += 1

    print(f"PASS: {n_checks} checks; L(n)<=0 for 2<=n<{expected_cross}; "
          f"L({expected_cross})=+1 (Tanaka's smallest counterexample certified)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
