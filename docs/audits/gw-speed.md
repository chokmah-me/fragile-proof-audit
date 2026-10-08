# Audit note — GW biased-random-walk speed monotonicity (2026-09-28)

**Claim artifact:** Madhulatha Mandarapu, Sandeep Kunkunuru, *A
Computer-Assisted Proof of Speed Monotonicity for the Biased Random Walk on a
Galton-Watson Tree Beyond the Known Range*, arXiv:2609.29894 (submitted
2026-09-24).
**Harvest item:** `gw-speed-biased-random-walk` (2026-09-28 scan).
**Campaign objects:** `results/gw_speed_gate_meta.json`; working copies at
`~/workspace/gw-speed-audit/` (tarball of the public repo, not committed).

**Repo pin:** https://github.com/samyama-ai/gw-speed-certificate @ `d8b9a57`
(fetched 2026-09-28 via API tarball; SSH clone was unavailable — the egress
proxy kept resetting the SSH tunnel, HTTPS worked).

**Claim:** the λ-biased random walk speed v(λ) on a Galton–Watson tree with
offspring uniform on {2,3} is strictly decreasing on [0, 1.755], extending
the published range (Song–Wang–Xiang: λ ≤ 2/(1+√(1/2)) ≈ 1.1716). The repo
certifies [1.17, 1.755]; [0, 1.17] is the published result.

**Agent provenance (reconstructed):** Muse (Meta) · model `Muse Spark 1.3` · run date `2026-09-28` · added before the harness-pinning policy (2026-10-08); the verdict rests on pinned artifacts, independent of the agent transcript.

## Verdict: PASS (verify/audit)

## What was run

| Check | Result |
|---|---|
| Independent checker re-run (`src/independent_check.py 150 90`, mpmath interval arithmetic, shares no code with the generator) on the three spot cells | **3/3 CERTIFIED**, margins +0.41463 / +0.24416 / +0.10837 — byte-for-byte equal to the recorded `results/independent_check_K150.log`; EXIT 0 (~8 min) |
| Certificate reproduction: imported the generator's `certify()` and re-ran cells [1.60,1.61] and [1.73,1.74] from scratch | margins match recorded `rigorous_crude.json` to 12 decimals (0.113975568788, 0.009163715656); certified flags agree |
| Precomputed-certificate audit (`rigorous_crude.json`, `rigorous_crude_edge_K2000.json`, `certificate_summary.json`) | main K=1000: 57/63 cells certified, contiguous 1.17 → 1.74 = 87/50; edge K=2000 (width 0.005): contiguous 1.73 → 1.755 = 351/200; combined [1.17, 1.755] contiguous with overlap; summary numbers (57 cells, 308 exact index decisions) match the JSONs exactly; thinnest certified margins 0.0092 (main), 0.0048 (edge) — positive with room |
| Teeth control: independent checker on [1.79,1.80], where the main certifier reports margin −0.05994 ("no") | **"no"** (margin −0.07048) — the checker is not vacuously passing |

## Code-to-paper fidelity

- The paper's abstract states exactly what the repo certifies; the hand-proved
  part (Aïdékon's speed formula v=(R−λ)/(R+λ), the difference-quotient
  criterion, the pathwise Lipschitz bound on the conductance, the stochastic-
  order sandwich) lives in the paper, while the code checks the per-cell
  inequalities — the standard computer-assisted division of labor. The
  docstrings reference `../PROOF.md`, which is not in the repo (it is the
  paper itself); not a defect, but the reduction is human-checked only.
- Error accounting is explicit and conservative: λ/geometry in exact
  `Fraction`s, float images widened by relative EPS=1e-10 (far above the
  ~1e-12 accumulated float error) plus absolute EPS for underflow; near-integer
  index decisions re-done in exact arithmetic (308 of them at K=1000).

## Honest scope

- The full `./run.sh` was not re-run end to end: the K=2000 edge independent
  check is documented at ~3 h per cell-pair and this VM reboots roughly every
  2 h. The precomputed edge certificates were audited (contiguity, margins,
  summary consistency) and the generator reproduces recorded values, but the
  edge JSONs themselves were not regenerated here.
- The [0, 1.17] portion rests on the published Song–Wang–Xiang bound, not on
  this repo.

## Verdict lock

Standalone verify/audit PASS. The 25-gate verdict lock (17 BREAK / 8 PASS) is
untouched.
