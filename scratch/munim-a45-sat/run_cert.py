#!/usr/bin/env python3
"""Certificate-producing SAT/UNSAT driver for (t,d) anisotropic-system instances.

Uses the validated indep_sat encoding (flag symmetry break s_i[r]=0 for r>i;
proved sound, validated on the (4,4) SAT control), dumps CNF to DIMACS, and
runs the standalone cadical binary with LRAT proof logging ON.

SAT results are decoded and brute-force verified with indep_sat.is_system:
a SAT on (4,5) would break A(4)=4 (resp. (5,6) breaks A(5)=5), so the model
verification is the receipt. UNSAT keeps the LRAT proof file as the
certificate artifact.

Usage: run_cert.py <td> <cadical_bin> [flag] [workdir]
  td: 44, 45, 55, 56 ; flag: 1 = flag symmetry break (default 1)
The hard wall clock is enforced by the caller (external `timeout`), not here.
Writes result-<t>-<d>.txt (one line), inst-<t>-<d>.cnf, cadical-<t>-<d>.log,
and proof-<t>-<d>.lrat (UNSAT only) into workdir.
Prints the result line + EXIT:0; always exits 0 on a completed verdict.
"""
import os
import subprocess
import sys
import time

import indep_sat

JOBS = {"44": (4, 4), "45": (4, 5), "55": (5, 5), "56": (5, 6)}


def main():
    td = sys.argv[1]
    cadical_bin = sys.argv[2]
    flag = (sys.argv[3] if len(sys.argv) > 3 else "1") == "1"
    workdir = sys.argv[4] if len(sys.argv) > 4 else "."
    t, d = JOBS[td]
    os.makedirs(workdir, exist_ok=True)

    E, s, B, A = indep_sat.encode(t, d, assumptions=(), flag=flag)
    cnf_path = os.path.join(workdir, f"inst-{t}-{d}.cnf")
    E.cnf.to_file(cnf_path)
    proof_path = os.path.join(workdir, f"proof-{t}-{d}.lrat")
    log_path = os.path.join(workdir, f"cadical-{t}-{d}.log")
    nvars, ncl = E.nvars, len(E.cnf.clauses)

    t0 = time.time()
    with open(log_path, "w") as log:
        proc = subprocess.run(
            [cadical_bin, "--lrat", "--no-binary", cnf_path, proof_path],
            stdout=log, stderr=subprocess.STDOUT)
    wall = time.time() - t0
    rc = proc.returncode
    proof_size = os.path.getsize(proof_path) if os.path.exists(proof_path) else 0

    if rc == 20:
        line = (f"({t},{d}) flag={int(flag)}: UNSAT wall={wall:.1f}s "
                f"vars={nvars} clauses={ncl} proof={proof_size}B")
    elif rc == 10:
        val = {}
        with open(log_path) as f:
            for ln in f:
                if ln.startswith("v "):
                    for tok in ln.split()[1:]:
                        lit = int(tok)
                        if lit == 0:
                            break
                        val[abs(lit)] = lit > 0
        model = [v if val.get(v, False) else -v for v in range(1, nvars + 1)]
        S, BB, AM = indep_sat.decode(t, d, s, B, A, model)
        ok, msg = indep_sat.is_system(t, d, S, BB, AM)
        with open(os.path.join(workdir, f"model-{t}-{d}.txt"), "w") as f:
            f.write(" ".join(str(x) for x in model) + " 0\n")
            f.write(f"brute-force-verify=({ok}, {msg})\n")
        line = (f"({t},{d}) flag={int(flag)}: SAT wall={wall:.1f}s "
                f"vars={nvars} clauses={ncl} brute-force-verify=({ok}, {msg})")
    else:
        line = (f"({t},{d}) flag={int(flag)}: SOLVER-FAIL rc={rc} wall={wall:.1f}s "
                f"vars={nvars} clauses={ncl}")

    with open(os.path.join(workdir, f"result-{t}-{d}.txt"), "w") as f:
        f.write(line + "\n")
    print(line, flush=True)
    print("EXIT:0", flush=True)


if __name__ == "__main__":
    main()
