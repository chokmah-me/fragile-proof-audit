# Audit note — tetrahedron Turán upper bound (2026-09-28)

**Claim artifact:** Gyeongwon Jeong, Seonghun Park, Seonghyuk Im, Joonkyung
Lee, Hongseok Yang, *A New Upper Bound for the Turán Density of the
Tetrahedron*, arXiv:2609.27495 (submitted 2026-09-23).
**Harvest item:** `tetrahedron-turan-upper-bound` (2026-09-28 scan, rank 9).
**Campaign objects:** `results/tetrahedron_turan_gate_meta.json`; working
copies at `~/workspace/tetrahedron-turan/` (third-party clone + venv, not
committed).

**Repo pin:** https://github.com/taeyool/tetrahedron-turan @
`f3ef8e6bf57dd36da9e642124b24151c80e8021c` (2026-09-24, HEAD at clone time).
**Certificate pin:** `certificate/K4_turan_order7_certificate.json`,
SHA-256 `c3b0e0b9364f669763bdb8fd1e3914bcd55acdee17fe7a5adbbb2e92da22beb4`
(matches the `CERT_SHA` pin in `scripts/exact_certificate/full_seven_long_common.py`).

## Verdict: PASS (verify/audit)

The exact-integer certificate replay passes end to end on this machine, the
claimed bound equals the independently recomputed maximum exactly, and the
checker demonstrably rejects a weakened claim.

## What was run

| Run | Result |
|---|---|
| `experiments/runtime.py search/exactify_five_root.py --certificate … --cross-check-pricing --threads 2` (the repo's independent integer verifier; deps numpy/scipy/highspy/psutil installed in a venv) | **EXIT 0** — all 13,051,375 labeled seven-vertex extensions scanned by two independent implementations (Python + freshly compiled C++ oracle); max coefficient `11245394264033484/20160000000000000 = 0.5578072551603911` at raw mask `4840262484` |
| Bound arithmetic (exact `Fraction`) | max coefficient **equals** claimed bound `312372062889819/560000000000000` (tight certificate, gap 0); below Baber's 0.5615; above 5/9 |
| Teeth control 1: one factor-vector entry perturbed (+1) | EXIT 0 with unchanged global max — correctly a weak tooth: the bound checks key on the global maximum, which the perturbation did not move |
| Teeth control 2: claimed `bound_fraction` numerator lowered by 1 (`…818/…` instead of `…819/…`) | **EXIT 1**, `ValueError: integer certificate's claimed bound disagrees with the full scan` — the checker rejects a bound weakened by 1/560000000000000 |

The recomputed max numerator, denominator, maximizing mask, 794 factor-vector
count, and 964 six-vertex representatives all agree with the values recorded
in `docs/lean-proof.md` and in the certificate's own `exact_verification`
field. The tampered certificates were restored via `git checkout`; the
working tree's tracked files are unmodified and the certificate hash is back
at the pinned value.

## Code-to-paper fidelity

- The certificate's `bound_fraction` is exactly the paper's Theorem 1.1 bound.
- Factor inventory matches the paper/README: 794 vectors (`2+2` four-root,
  7 one-root, `236+187` three-root, 360 five-root across 18 active types).
- The mathematical framework (Razborov flag algebras + degree-stationarity
  differential method, §2–§3 of the paper) is standard; the novel content is
  the certificate, which is what was replayed.

## Formalization (not rebuilt here — honest scope)

- 355 Lean files, toolchain pinned to `leanprover/lean4:v4.27.0`; no `sorry`
  in the `FullSevenLong` chain (grep-verified); axiom footprint documented as
  `propext`, `Classical.choice`, `Quot.sound` plus `Lean.ofReduceBool`,
  `Lean.trustCompiler` from `native_decide` (standard for this kind of
  computation); `AxiomCheckFullSevenLong.lean` type-checks the literal
  fraction against both headline theorems.
- A full Lean rebuild is out of reach on this VM: the authors' release build
  took 10 h 37 min and peaked at 33 GiB (this VM reboots roughly every 2 h).
  The Lean proof's validity therefore rests on the authors' recorded release
  build (`certificate/verification/release-20260921/`), not on a replay here.
- The Lean definition of the density (`limUnder atTop` of `exTetra n / C(n,3)`)
  is the standard Turán density; convergence is proved in the development
  (`tendsto_tetraTuranDensity`).

## Verdict lock

Standalone verify/audit PASS. The 25-gate verdict lock (17 BREAK / 8 PASS) is
untouched.
