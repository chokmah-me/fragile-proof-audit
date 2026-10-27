# Input pin — Chen & Gu, minimum-autocorrelation constant (arXiv:2610.18888)

Pinned 2026-10-26. Source: weekly harvest 2026-10-26
(`incoming/harvests/2026-10-26.md`, CLAIM
minimum-autocorrelation-0410377, fragility 1); picked at the
user's tap 2026-10-26 over Schur (Terra 6.1's #1 in the same-day
harvest analysis). Scope of the pick: **M1 statement-fidelity
audit with two verdict objects — V-A, the runner build and axiom
audit of the 41-file Lean project at its own pin; V-B, the
statement fidelity of the witness claims and the finite
certificate against the paper** — with the supremum passage
explicitly outside the formalization, per the Kill Switch
constraints kept from the harvest analysis. The verdict lock is
not touched. No author contact.

## The paper

- Chen & Gu, *An improved lower bound for the
  minimum-autocorrelation constant* (arXiv:2610.18888v1
  [math.GM], 8 Oct 2026). Headline: A >=
  0.4103779774321214877852987..., improving Russell's
  explicitly certified 0.39921356....
- PDF (411,863 bytes): sha256
  `7c28180faabfcc129e404b04fef56fe880d6fb0d4e96708196b5bea6c347947b`
- E-print bundle (291,225 bytes, 95 entries): sha256
  `98aeea11e3a6f6c7bf07497aaaeffca6b763f171104d36d70b3f88be1450df9a`
- Witness integers (paper thm:main and Ratios.lean agree):
  N = 4713977940944586245580976375978623597750000000000000000,
  D = 11486917427785951575611071745219515905862879073559791929,
  D_F = 11486917430134691792906455293684961315501879073559791929;
  N/D = 0.4103779774321214877852987329...,
  N/D_F = 0.4103779773482111379678143...;
  delta0 = 1/10^10, gamma = 99999999/100000000.

## The code

- ArXiv ancillary project `anc/lean`: 41 .lean files, 2,388
  lines; package `autocorrelation_lean`, default target
  `Autocorrelation`; toolchain `leanprover/lean4:v4.19.0`;
  Mathlib rev `c44e0c8ee63ca166450922a373c7409c5d26b00b`;
  lake-manifest.json sha256
  `cb11b5e740979bedd9cad8aa804fb7cff2a5cd2874ae281b9f00fcfffa2a0ef8`.
- Authors' SOURCE_SHA256SUMS.txt: 67/67 OK at the pin (in
  recon and in the forge run).
- certificate.json sha256
  `e9b58a1068baa81723e55ad01640260118ce156ac23c07332cefefc46f552d79`.
- Working copies and evidence: `~/workspace/autocorrelation-recon/`
  (`RECON-BRIEF.md`, `NOTE-SKELETON.md`,
  `evidence-run-40430792374/`,
  `evidence-run-40430792374-early/`).
