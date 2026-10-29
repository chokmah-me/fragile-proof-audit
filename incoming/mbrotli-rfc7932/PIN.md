# PIN — mbrotli Level-1 Lean 4 proofs vs RFC 7932 / RFC 9841

Audit note: `docs/audits/mbrotli-rfc7932.md`
Scoped verdict: PARTIAL ((a) Rfc.lean transcription
PASS + section 4 model leg formula-checked,
(b) local kernel replay PASS, (c) M4 inventory
recorded; fences = drift replay not run (GAP),
M2 spot scope 3 of 12 guarded, section 4 model leg).

## Target (pinned 2026-10-29)

- Repo: `github.com/m-compressors/mbrotli` — commit
  `03eaa75d3444a0d9dfcf2eab595761ef67e18b66` (HEAD at
  pick and at audit; verification in PR #13 merged
  `b061a20`, first checks `6b377ad` 2026-10-25).
  git-archive tarball sha256
  `8066df83aa79f64673dcd7d497a497de7a6dd50c3e3b2d83ac830c4bde25281e`.
- Toolchain `leanprover/lean4:v4.35.0`. Aeneas pin
  `74aabd52f77001cf9eaad51b4f4b867a7dc6b111`
  (`AENEAS_RELEASE` nightly-2026.10.24-74aabd5), the
  same pin as mzstd.
- Fidelity sources (fetched 2026-10-29): RFC 7932
  text sha256
  `394abd1879e016f4eac89512c2acaf92f7b2d67feb8ab58b6b118c213be07146`;
  RFC 9841 text sha256
  `88711e3f33ad7e3e9e7f1c35b60cd8c85095bfe7fab9555dcc9154caa0537042`;
  project post HTML sha256
  `d31d74cd4bc50ba91481e53eff6774110eddff82d2164ebb7a4c3442e1e35d14`
  (staged under the mzstd audit's recon dir).

## Local replay (auditor VM, 2026-10-29)

- `lake exe cache get` exit 0, 321 s (Mathlib cache
  shared with the mzstd audit; same pins).
- `lake build` exit 0, 273 s, 1,817 jobs.
- Independent `#print axioms` for all 12 theorems
  guarded in `Mbrotli/Audit.lean`: each exactly
  `[propext, Classical.choice, Quot.sound]`,
  matching its guard.
- Escape grep over `verification/`: zero hits.

## Evidence

Recon dir `~/workspace/mbrotli-recon/`: `EVIDENCE.md`
(receipt index), `AUDIT-DRAFT.md`, `build.log`,
`axioms-all.log`, `haiku-doublecheck/`,
`argon-check/` (incl. `ADJUDICATION.md`).
