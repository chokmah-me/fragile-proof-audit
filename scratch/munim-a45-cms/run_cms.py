#!/usr/bin/env python3
"""XOR-native SAT/UNSAT driver for (t,d) anisotropic-system instances.

Same validated indep_sat encoding as run_cert.py (flag symmetry break
s_i[r]=0 for r>i; proved sound, validated on the (4,4) SAT control), but
the solver is the standalone cryptominisat5 binary: the encoding's F_2
arithmetic is built from xor2 gates flattened to CNF, and CryptoMiniSat
recovers that parity structure and reasons with Gaussian elimination,
where plain CDCL (Minisat/Cadical/Kissat/MapleChrono all timed out on
(4,5); Cadical 3.0.1 also ate a full 3h on the Dell) cannot.

SAT results are decoded and brute-force verified with indep_sat.is_system:
a SAT on (4,5) would break A(4)=4 (resp. (5,6) breaks A(5)=5), so the model
verification is the receipt. UNSAT keeps the FRAT proof file as the
certificate artifact (checker verification happens back on the VM).

Usage: run_cms.py <td> <cms_bin> [flag] [workdir]
  td: 44, 45, 55, 56 ; flag: 1 = flag symmetry break (default 1)
The hard wall clock is enforced by the caller (external `timeout`), not here.
Writes result-<t>-<d>.txt (one line), inst-<t>-<d>.cnf, cms-<t>-<d>.log,
and proof-<t>-<d>.frat (UNSAT only) into workdir.
Prints the result line + EXIT:0; always exits 0 on a completed verdict.
"""
import hashlib
import os
import subprocess
import sys
import time

import indep_sat

JOBS = {"44": (4, 4), "45": (4, 5), "55": (5, 5), "56": (5, 6)}


def main():
    td = sys.argv[1]
    cms_bin = sys.argv[2]
    flag = (sys.argv[3] if len(sys.argv) > 3 else "1") == "1"
    workdir = sys.argv[4] if len(sys.argv) > 4 else "."
    t, d = JOBS[td]
    os.makedirs(workdir, exist_ok=True)

    E, s, B, A = indep_sat.encode(t, d, assumptions=(), flag=flag)
    cnf_path = os.path.join(workdir, f"inst-{t}-{d}.cnf")
    E.cnf.to_file(cnf_path)
    with open(cnf_path, "rb") as f:
        cnf_sha = hashlib.sha256(f.read()).hexdigest()
    proof_path = os.path.join(workdir, f"proof-{t}-{d}.frat")
    log_path = os.path.join(workdir, f"cms-{t}-{d}.log")
    nvars, ncl = E.nvars, len(E.cnf.clauses)

    t0 = time.time()
    with open(log_path, "w") as log:
        proc = subprocess.run(
            [cms_bin, "--threads=1", "--verb=1", cnf_path, proof_path],
            stdout=log, stderr=subprocess.STDOUT)
    wall = time.time() - t0
    rc = proc.returncode
    proof_size = os.path.getsize(proof_path) if os.path.exists(proof_path) else 0

    verdict = None
    model = None
    with open(log_path) as f:
        for ln in f:
            if ln.startswith("s SATISFIABLE"):
                verdict = "SAT"
            elif ln.startswith("s UNSATISFIABLE"):
                verdict = "UNSAT"
            elif ln.startswith("v ") and verdict == "SAT":
                vals = []
                for tok in ln.split()[1:]:
                    lit = int(tok)
                    if lit == 0:
                        break
                    vals.append(lit)
                if model is None:
                    model = []
                model.extend(vals)

    if verdict == "UNSAT":
        line = (f"({t},{d}) flag={int(flag)} solver=cryptominisat5: UNSAT wall={wall:.1f}s "
                f"vars={nvars} clauses={ncl} cnf_sha256={cnf_sha} proof={proof_size}B")
    elif verdict == "SAT" and model is not None:
        S, BB, AM = indep_sat.decode(t, d, s, B, A, model)
        ok, msg = indep_sat.is_system(t, d, S, BB, AM)
        with open(os.path.join(workdir, f"model-{t}-{d}.txt"), "w") as f:
            f.write(" ".join(str(x) for x in model) + " 0\n")
            f.write(f"brute-force-verify=({ok}, {msg})\n")
        line = (f"({t},{d}) flag={int(flag)} solver=cryptominisat5: SAT wall={wall:.1f}s "
                f"vars={nvars} clauses={ncl} cnf_sha256={cnf_sha} "
                f"brute-force-verify=({ok}, {msg})")
    else:
        line = (f"({t},{d}) flag={int(flag)} solver=cryptominisat5: SOLVER-FAIL rc={rc} "
                f"verdict={verdict} wall={wall:.1f}s vars={nvars} clauses={ncl} "
                f"cnf_sha256={cnf_sha}")

    with open(os.path.join(workdir, f"result-{t}-{d}.txt"), "w") as f:
        f.write(line + "\n")
    print(line, flush=True)
    print("EXIT:0", flush=True)


if __name__ == "__main__":
    main()
