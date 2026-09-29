# Audit note — simple symmetric Venn diagrams, 17 and 19 curves (2026-09-28)

**Claim artifact:** Chris Dzoba, *Simple symmetric Venn diagrams with 17
and 19 curves* — first known examples; Grünbaum's 1975 question asked
whether they exist for every prime n (previously known only for 3, 5, 7,
11, 13). Paper: `paper/venn17-19.pdf` in repo.
**Harvest item:** `venn-simple-symmetric-17-19` (recon rank 1, fragility 3:
`single_author`, `disclosed_llm_help`, Lean without toolchain pin at recon
time).
**Campaign objects:** `results/venn_simple_symmetric_gate_meta.json`;
working copies at `~/workspace/venn-audit/` (API tarball of the public
repo at the pinned commit, not committed).

**Repo pin:** https://github.com/dzoba/venn17 @
`5f08c24ed357b87ea8edd870a39abc64d17c3a17` (fetched 2026-09-28 via API
tarball).

**Claim:** 4 simple symmetric 17-Venn diagrams and 9 simple symmetric
19-Venn diagrams exist, published as machine-checkable certificates,
plus 11- and 13-curve non-monotone examples.

## Verdict: PASS (verify/audit)

## What was run

| Check | Result |
|---|---|
| SHA-256 of all 15 certificate files vs `certificates/SHA256SUMS` | **15/15 OK**, zero mismatches |
| Author's standalone checker `verify/verify.py` on all 15 certificates (8 criteria each: all labels, Euler=2, edge multiplicities, rotation symmetry, …) | **15/15 PASS**, exit 0 (6 small + 9× 19-curve at ~1 min each) |
| Independent checker (written for this audit, shares no code with `verify/`): all 2^n labels present, label set closed under cyclic rotation, face count = 2^n−2 | **5/5 OK** (n = 11, 13, 17, 19, 19) |
| Teeth: single-bit label corruption in a certificate | checker **rejects** (exit 1, no PASS) — fail-closed |
| Lean formalization inputs vs verified certificates | `verify/lean/venn17-local-c3-s2.json` byte-identical to the checked certificate; `lean19/INPUT-HASHES.json` pins `venn19-closure-s196002.json` to its verified hash |
| Lean sources: `sorry` scan; toolchain pin | **no sorry**; `lean-toolchain` pins `leanprover/lean4:v4.32.1` (recon's "unpinned" was stale) |
| Lean axiom posture (from shipped `topology-axioms.txt` / `FINAL-THEOREM-AXIOMS.txt`) | 3 standard axioms + 20 input-specific `native_decide` axioms per formalization, openly documented |

## Code-to-paper fidelity

- The headline existence claim is established three ways: the Python
  checker on all 15 certificates, a third auditor written by Codex sharing
  no code with either (per README), and Lean 4 formalizations of one
  17-curve and one 19-curve certificate proving the full geometric
  statement (`supplied_simple_rotational_venn`: 17/19 embedded circles,
  all 2^n regions nonempty and path-connected, no triple points,
  transverse double points, rigid 2π/n rotation).
- The 20 `native_decide` axioms are the standard large-computation
  mechanism: each is a decidable check on the concrete certificate data
  that *must* evaluate to true at build time or elaboration fails. The
  residual trust is in the Lean compiler's native codegen, not the author.
  This is disclosed in the repo's RESULTS.md, not hidden.
- AI disclosure is present: Codex (OpenAI) wrote the third auditor and
  ported the Lean 19 formalization from Justin Grimes's Lean 17
  formalization (Apache-2.0, credited).

## Honest scope

- The Lean formalizations cover **one** 17-curve and **one** 19-curve
  certificate — sufficient for the existence claim; the remaining 13
  certificates rest on the Python checker (plus the Codex third auditor).
- This audit did **not** rebuild the Lean formalizations: they need Lean
  4.32.1 + a different mathlib revision than this VM has staged, and a
  full rebuild was beyond the VM's CPU/reboot budget. The recorded axiom
  reports, input hashes, and theorem statements were verified instead.
- The checker verifies the combinatorial certificate; the step from
  "valid dual map" to "realizable by closed curves in the plane" is what
  the Lean proof supplies for the two formalized certificates. For the
  other 13, realizability rests on the checker's criteria (Euler=2,
  rotation symmetry, single rotation cycle at vertices, both sides of
  every curve connected), which are the standard combinatorial
  sufficiency conditions, human-checked only.
- Monotonicity is tested separately (`monotone_test.py`, not re-run
  here); the README is explicit that the checker does not test novelty
  or distinctness of certificates.

## Verdict lock

Untouched (25 gates: 17 BREAK / 8 PASS). Standalone verify/audit PASS,
recorded like the other harvest targets.
