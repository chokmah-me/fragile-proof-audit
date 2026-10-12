#!/usr/bin/env python3
"""Discrimination control for the koval-SRG audit instrument.

Runs the SAME shipped checker (archive's out/new_srgs_multiorbit/zenodo/verify_srg.py)
on two inputs of independent origin (constructed here, not from the archive):
  (a) the Petersen graph  -> MUST PASS as srg(10,3,0,1)
  (b) the path graph P10   -> MUST FAIL (not regular, hence not an SRG)

Exit 0 iff the instrument returns the correct opposite verdicts (it discriminates);
exit 1 otherwise. Control inputs are written to results/ alongside this receipt.
Python 3 standard library only.
"""
import itertools
import subprocess
import sys
from pathlib import Path

PROJECT = Path(__file__).resolve().parent.parent.parent
CHECKER = PROJECT / "incoming/koval-strongly-regular-graphs/data/out/new_srgs_multiorbit/zenodo/verify_srg.py"
RESULTS = PROJECT / "results"


def to_graph6(n, edges):
    adj = [[False] * n for _ in range(n)]
    for i, j in edges:
        adj[i][j] = adj[j][i] = True
    bits = []
    for j in range(1, n):
        for i in range(j):
            bits.append(1 if adj[i][j] else 0)
    out = [chr(n + 63)]
    for k in range(0, len(bits), 6):
        piece = bits[k:k + 6]
        piece = piece + [0] * (6 - len(piece))
        v = 0
        for b in piece:
            v = (v << 1) | b
        out.append(chr(v + 63))
    return "".join(out) + "\n"


def petersen():
    verts = list(itertools.combinations(range(5), 2))  # Kneser KG(5,2)
    idx = {v: i for i, v in enumerate(verts)}
    edges = []
    for a, b in itertools.combinations(verts, 2):
        if set(a).isdisjoint(b):
            edges.append((idx[a], idx[b]))
    return len(verts), edges


def path10():
    return 10, [(i, i + 1) for i in range(9)]


def run_checker(args):
    p = subprocess.run([sys.executable, str(CHECKER)] + args,
                       capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr


def main():
    RESULTS.mkdir(parents=True, exist_ok=True)
    n_p, e_p = petersen()
    n_q, e_q = path10()
    assert n_p == 10 and len(e_p) == 15, "petersen construction broken"
    assert n_q == 10 and len(e_q) == 9, "path construction broken"
    f_pet = RESULTS / "srg_control_petersen.g6"
    f_path = RESULTS / "srg_control_path10.g6"
    f_pet.write_text(to_graph6(n_p, e_p))
    f_path.write_text(to_graph6(n_q, e_q))

    ok = True
    rc, out = run_checker(["--expect", "10,3,0,1", str(f_pet)])
    print("--- Petersen (expect PASS srg(10,3,0,1)) ---")
    print("exit:", rc)
    print(out.strip())
    if rc != 0 or "OK srg(10,3,0,1)" not in out:
        print("CONTROL FAILURE: Petersen did not verify as srg(10,3,0,1)")
        ok = False

    rc2, out2 = run_checker([str(f_path)])
    print("--- Path P10 (expect FAIL) ---")
    print("exit:", rc2)
    print(out2.strip())
    if rc2 == 0 or "FAIL" not in out2:
        print("CONTROL FAILURE: path graph was not rejected")
        ok = False

    print("CONTROL VERDICT:", "DISCRIMINATES (PASS)" if ok else "DOES NOT DISCRIMINATE (FAIL)")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
