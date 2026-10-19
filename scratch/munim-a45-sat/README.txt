ONE-SHOT scratch payload for .github/workflows/munim-a45-sat-retry.yml.
NOT standing repo content: delete this directory together with the workflow
file once the (4,5)/(5,6) receipts are recorded (precedent: 5d7e402).
Contents:
  indep_sat.py  -- validated Tseitin encoding + brute-force verifier
                 (copied unmodified from ~/workspace/harvest-checks-2026-10-19/munim-a45/)
  run_cert.py   -- certificate driver: DIMACS dump -> cadical --lrat --no-binary;
                 SAT models decoded + brute-force verified; UNSAT keeps .lrat
  cadical       -- cadical 3.0.1 (rel-3.0.1), built from source on Ubuntu 24.04
