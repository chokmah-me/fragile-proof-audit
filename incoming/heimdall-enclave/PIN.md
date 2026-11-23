# PIN — heimdall-enclave (registered 2026-11-23)

Registered 2026-11-23 at the user's tap ("Register Heimdall
as a claim"). No verdict at pin time. This claim entered as a
WAITING registered candidate on 2026-11-10 (recon:
~/workspace/heimdall-recon-2026-11-10/RECON.md; repo then
LICENSE-only at 6c59f04, all six claim groups ABSENT) with the
trigger: any non-LICENSE content pushed, then re-recon before
ranking. The trigger fired 2026-11-20. Re-recon ran
2026-11-23 at his tap, before registration
(~/workspace/heimdall-recon-2026-11-23/RECON-2.md): clone,
source scans, full Lean build, kernel axiom audit, and
replication of the author's own checker validations. The
Lean leg therefore arrives at registration already replayed;
what is registered is the claim, with the recon results
recorded below as evidence, not as an audit verdict. No
forge at registration. Verdict lock untouched.

## Claim

w8mej/heimdall-enclave (John Menerick), repo description:
"Hardware-Attested Zero-Trust Sentinel & Post-Quantum
Information Flow Control for Agentic AI on Apple Silicon."
The product claim (native MLX/Rust inference runtime, SEP
attestation, Cedar+Biscuit IFC, MDM fleet distribution,
P2P model distribution) is the author's framing. The
specific checkable sub-claim, and the one this registration
pins, is the formal-methods claim made in the README badge
and docs/FORMAL_METHODS_DEFENSE.md: a Lean 4 suite of 94
Enclave modules with 1,036 kernel-checked theorem types and
0 sorry, at the pinned commit. The author's own
proofs/lean4/ASSURANCE.md scopes the suite to model
definitions: it "does not verify Heimdall-Enclave as a
physical product or running OS environment", and its
correspondence table marks most modules "Model only — not
linked to implementation". The registered claim is read at
that scope; product claims beyond it are not pinned as
checked.

## Canonical artifact

github.com/w8mej/heimdall-enclave, public, Apache-2.0.
HEAD `aaa4a9dffd9ab5c3eafcaa4ea456fce2deb4c8be`
("legal reviewed", 2026-11-20T19:52:54Z). History is 2
commits: root `e5b58607607cdae47535ae4ecf87a1d02d43dbcb`
("legal and c-level approved; IPO priced; ship it",
2026-11-20) carries the whole tree. The 2026-11-09 initial
commit 6c59f04 from the first recon is not in the current
history; history was replaced and there is no incremental
provenance to audit.

- Tree at pin (git ls-files): 1,201 files. crates/ 741
  (Rust), proofs/ 135, scripts/ 85, schemas/ 39, docs/ 33,
  adapters/ 26, launchd/ 23, examples/ 18.
- Lean suite: 128 files under proofs/lean4 (94 Enclave
  modules, 25 Test modules, 9 root files incl. Enclave.lean,
  Test.lean, Audit.lean, Main.lean).
- Toolchain: `leanprover/lean4:v4.14.0` (lean-toolchain
  sha256 `190c6c74963949503698e8e5c3e208b07d14b4863ac0ce82d9664b2087ee8cc7`).
- lake-manifest.json sha256
  `4860f06b2ef71db80b5cd648219155475b8f3eec18686aba9a668d04ccb95be3`:
  Mathlib `4bbdccd9c5f862bf90ff12f0a9e2c8be032b9a84`,
  batteries `8d6c853f11a5172efa0e96b9f2be1a83d861cdd9`,
  aesop `5a0ec8588855265ade536f35bcdcf0fb24fd6030`,
  Qq `303b23fbcea94ac4f96e590c1cad6618fd4f5f41`,
  proofwidgets `68280daef58803f68368eb2e53046dabcd270c9d`,
  importGraph `519e509a28864af5bed98033dd33b95cf08e9aa7`,
  LeanSearchClient `d7caecce0d0f003fd5e9cce9a61f1dd6ba83142b`,
  plausible `42dc02bdbc5d0c2f395718462a76c3d87318f7fa`,
  Cli `726b3c9ad13acca724d4651f14afc4804a7b0e4d`.
- theorem-types.json sha256
  `8fdd83c85bf5a16a2f1beb47fa4b93597c36ccf05c7b8790958833c20213cb23`
  (1,036 entries; the README's theorem count is this
  reviewed manifest, not the raw kernel count).
- Audit.lean sha256
  `8a1c406743e6495c717e9feabfc21358d2f558168c96067e878c4fe06d84a949`;
  transport-contracts.json sha256
  `ec52242fd93b08783a8391d13a7cd53016951dfa8a0e8de79ac10892ddd826d1`.

## Verification in hand at registration (2026-11-23 re-recon)

All runs on this VM, third-party code sandboxed
(run-untrusted.sh), pinned toolchain, Mathlib cache at the
manifest rev. Evidence: ~/workspace/heimdall-recon-2026-11-23/
(build.log, build2.log, compile-rest.log, audit-out.log).

- Source scans over all 128 .lean files: 0 `sorry`,
  0 `admit`, 0 `axiom` declarations, 0 `native_decide`
  uses (3 comment hits, each stating it is not used).
- Build: every project file compiled; an olean exists for
  every Enclave, Test, and root module. The exe targets
  (enclave_verifier, correspondence, protocol_vectors,
  authorization_vectors) were not linked; the proof leg
  does not need them.
- Kernel audit: the repo's own Audit.lean, run unmodified
  (`lake env lean Audit.lean`), exit 0:
  "KERNEL_AUDIT 3016 theorem declarations checked".
  Audit.lean throws on any project axiom and on any theorem
  whose transitive axioms leave {propext, Quot.sound,
  Classical.choice}; nothing threw. No sorryAx, no
  Lean.ofReduceBool in any transitive closure.
- Author's checker (scripts/check-lean.py, read in full;
  its three validations replicated on the audit output
  because its own `lake build` step hits the widgetJsAll
  environment failure in the seam list below):
  REQUIRED_THEOREMS 307/307 present as kernel theorems;
  transport-contracts.json 18/18 source digests match;
  theorem-types.json 1,035/1,036 type digests match.

## Seams

- S1 (digest staleness, the one failing check): one
  theorem-types.json entry does not match the compiled
  kernel type at the pinned commit:
  Enclave.Test.test_pf_raw_depot_blocked
  (Test/FrontierTest.lean:35), pinned sha256
  `33b12c331b9e51b564c63f4c6cecbc0e1339266586c2936c52eea10fd758cd46`,
  actual type `Eq Enclave.Verdict (Enclave.evalPacketFilter
  Enclave.Test.pkt_unauthorized_raw_depot) Enclave.Verdict.Drop`
  sha256 `4e25ef942a8334a5db460f3c11f9bcefae989c9ee27313ddc09479fd496e4a45`.
  Under the author's own check-lean.py this fails the run
  ("reviewed theorem type changed or disappeared"), so the
  author's mandatory gate is not green at HEAD. The entry
  is a packet-filter example test, not a model theorem, and
  is not among the 307 required theorems. Most likely the
  manifest was pinned against a pre-drop variant.
- S2 (build environment, recon-side): the lake target
  proofwidgets/widgetJsAll cannot build on this VM
  (registry.npmjs.org TLS fails on this egress; the
  ProofWidgets cloud release 404s for this WIP rev). The
  16 widget JS files (display assets embedded as string
  literals in widget definitions) were substituted from
  this VM's existing fragile-proof-audit ProofWidgets
  build, same filenames, to let the last 24 modules
  elaborate. No theorem statement or proof depends on JS
  content; the kernel audit is unaffected. A runner-lane
  build with normal npm access would retire this seam.
- S3 (Rust leg unaudited): 741 Rust files, the
  correspondence executables and their claimed 34,599
  vectors, the 9-target differential fuzz harness, the
  source-guard translation checks, and all product claims
  (SEP attestation, MLX inference, MDM adapters) are
  unchecked. The author's stated correspondence evidence
  is bounded translation validation at a revision via a
  "trusted shallow Python translation", not a proof about
  the Rust implementation.
- S4 (history): single-drop history (see artifact note);
  no commit-level provenance, no CI records in the repo
  were audited.
- S5 (scope): per ASSURANCE.md, FRI soundness and
  auxiliary AIR relations "remain open" inside the suite's
  own accounting, and the twenty-area protocol extension
  (COVERAGE.md) does not inherit correspondence from the
  older models. Statement-level review (ST-1 to ST-5) of
  the headline theorems has not been run; the recon
  verified compilation, axioms, and the author's manifest
  checks, not that the statements say what the docs claim.

## Queue

Registered as CLAIM. Any full audit (statement tests on
the headline theorems, Rust correspondence leg) is a
separate decision at the user's tap; the audit queue
(Aaronson-Ambainis ahead of it) is unchanged by this
registration.
