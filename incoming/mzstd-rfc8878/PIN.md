# PIN — mzstd Level-1 Lean 4 proofs vs RFC 8878 (m-compressors/mzstd)

Audit opened 2026-10-29 from a Feed pick (project post
"Towards formal verification: mbrotli and mzstd",
M-Compressors, 2026-10-29). Pick assessment at the
user's tap: mzstd first, mbrotli second, scoped to
(a) Rfc.lean fidelity against RFC 8878, (b) a local
kernel replay of the Lean proof build at the pin,
(c) the M4 trusted-base inventory recorded as
trusted, not verified. Audit executed at the user's
"Proceed" the same day; scope label: Level-1
headers, codes and tables only. Note:
docs/audits/mzstd-rfc8878.md (verdict PARTIAL, held
by the unrun drift replay and the M2 spot scope).

## Claim

The mzstd crate's Lean 4 project (verification/lean,
toolchain v4.35.0) proves that listed Rust items
follow RFC 8878: frame and block headers on both
sides with round trips, Number_of_Sequences, the
literals/match length and offset code tables, the
default distributions, the encoder repeat-offset
update, and the FSE Table 21 state pairs, against a
hand-written transcription of the RFC (Mzstd/Rfc.lean).

## Pins

- repo m-compressors/mzstd @
  0a4fd87e1c7ea6e7e96771de315022008d77db37
  (verification landed in 27e3028, 2026-10-26):
  git-archive tarball sha256
  f5e27c2f7008e4f7623bfd1d1bceabc40ccc790eb9b35d35581ad542a2f5ab18
- RFC 8878 text: sha256 8ee6be03534113f5689cda75b9539a02e0704a2506d420814223e506420aeea4
- zstd_compression_format.md (facebook/zstd dev,
  fetched 2026-10-29): sha256 9ce5315c466d644fb41b54a7dcb707eb6e067bb5f36d79c0728a7ea2050cd8f7
- project post HTML (fetched 2026-10-29): sha256
  d31d74cd4bc50ba91481e53eff6774110eddff82d2164ebb7a4c3442e1e35d14

Evidence in ~/workspace/mzstd-recon/ (EVIDENCE.md,
build.log, axioms-all21.log, haiku-doublecheck/,
argon-check/).
