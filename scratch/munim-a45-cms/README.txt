ONE-SHOT scratch payload for .github/workflows/munim-a45-cms-retry.yml.
NOT standing repo content: delete this directory together with the workflow
file once the (4,5)/(5,6) receipts are recorded (precedent: fd24690).
Contents:
  indep_sat.py    -- validated Tseitin encoding + brute-force verifier
                   (copied unmodified from ~/workspace/harvest-checks-2026-10-19/munim-a45/)
  run_cms.py      -- driver: DIMACS dump -> cryptominisat5 (FRAT proof as
                   second positional arg); SAT models decoded + brute-force
                   verified; UNSAT keeps .frat
  cryptominisat5  -- CryptoMiniSat 5.11.21, built from source on Ubuntu 24.04
                   with STATICCOMPILE=ON (fully static, no shared-lib deps)
