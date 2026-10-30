# Audit note — Ginux, an independent kernel built by one persistent Codex task (Kurtzer, Zenodo 10.5281/zenodo.23682548, 2026-10-27)

**Claim artifact:** Gregory M. Kurtzer (CIQ; founder of CentOS and
Rocky Linux), *Ginux: Building an Independent Kernel That Runs Linux
Userspace through Human-Directed Agentic Engineering*, Zenodo DOI
10.5281/zenodo.23682548, v1 published 2026-10-27. Claim: over eleven
days, one persistent OpenAI Codex task using GPT-5.6 Sol produced an
independent Rust-first x86-64 kernel (own memory management, scheduler,
process model, VFS, networking, devices, Linux ABI layer), booting via
UEFI with no Linux host kernel, running selected unmodified Alpine
musl/BusyBox programs, and booting a Rocky Linux 10 userspace with
systemd through `multi-user.target`. The author scopes it as a research
prototype: narrow compatibility, no independent security audit, no
matched control, no production claim.
**Campaign objects:** `incoming/ginux/` (`PIN.md`, with the
pre-registered conditional expectation and the 2026-10-28
second-opinion addendum).
**Repo pin:** https://github.com/gmkurtzer/ginux @
`d11c126a048a51fe7eb9c4105f31760add1027ea` (2026-10-23, the paper's
evaluated commit). Documentation checkpoint:
`9afa61762a66a20855ea3a23e3e04221b54a5a22` (2026-10-20). Report PDF
sha256 `97591c342493b46a6a1f1939c3ac070bb0de2d82c211dda3bf8022c9236344f2`
(md5 matches the Zenodo listing).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · run
dates `2026-10-28` to `2026-10-30`. Second opinions adjudicated, not
relayed: Haiku 5.5 on the recon (PIN addendum), Argon
(`google/gemini-4-argon`) on this verdict (UPHOLD WITH REPAIRS;
adjudication in the auditor's working papers,
`~/workspace/ginux-recon/argon-check/`).

**Status:** CLOSED 2026-10-30 — verdict **PARTIAL** (standalone
verify/audit; the 32-gate verdict lock is untouched). The headline
Rocky systemd boot claim reproduces at the pin in our hands, twice.
The Alpine leg and the interactive shell gate do not complete in our
hands. Detail below.

## M1 — statement correspondence: PARTIAL

The evaluated pin is the commit the paper names, and the paper's
quantitative content checks at the states it was taken from:

- Syscall ledger EXACT at the pin: an independent parse of
  docs/LINUX-COMPATIBILITY.md gives 375 rows, 82 Complete / 245
  Partial / 48 Policy-denied, matching the paper.
- Table 1 scale figures (1,037 commits, 261 tracked files, 13,074
  Markdown LOC, Oct 10 to Oct 20 = 11 calendar days) reconcile exactly
  at the documentation checkpoint `9afa617`, which docs/paper/README.md
  names as the draft's commit. At the evaluated pin the same counts are
  1,063 commits and 282 files, and the history spans Oct 10 to Oct 23.
  Table 1's caption ("at the evaluated commit") is stale by 26 commits
  and 3 days. No figure was found fabricated; the caption points at
  the wrong commit.
- LOC rows reconcile within 21 lines under the closest counting set
  (.rs + .sh + .S); the generated split is exact (35,946 lines =
  `boot/efi/src/generated_boot.rs`). The exact LOC file set is
  undocumented and no counting script exists in the repo (M4).

## M2 — execution correspondence: PARTIAL

Method: the project's own make targets at the pin, harness as shipped,
on self-hosted runners; per-gate exit codes recorded individually
(a CI step color is not a gate result in this harness). Expected-pass
gates: build, check, test-alpine, test-rocky-shell, test-multi-domain,
test-rocky-systemd, test-storage. The aggregate test-linux-runtime is
record-only by pre-registration, because the repo discloses a failure
there at the pin (M4, item 2).

Environment leg (runs 2 to 4, Dell laptop DESKTOP-Q42R8VL, i7-8650U,
Ubuntu 24.04 WSL guest, QEMU 8.2.2, TCG and KVM): build and check pass;
every boot gate fails with the same kernel panic after "memory manager
ready": "inactive IOMMU translation construction failed". Logged
IOMMU capability 59110346977575430; its SAGAW field encodes 39-bit
addressing only, and `build_inactive_translation` at the pin returns
None without the 48-bit width bit. QEMU's intel-iommu aw-bits default
is 39 through QEMU 9.1 and 48 from QEMU 9.2 (upstream commit). A
wrapper diagnostic through the project's own `QEMU_SYSTEM_X86_64`
hook (run 4) never engaged: QEMU 8.2 exposes no aw-bits property for
the harness probe to set (probe result NONE; the raw help text was
not saved, a recorded caveat).

Modern-QEMU leg (runs 5 and 6, same laptop, Ubuntu 25.10 WSL guest,
QEMU 10.1.0, KVM, harness exactly as shipped): IOMMU capability
59110346978166278, the 48-bit bit set. Exit codes, run 5 / run 6:

| Gate | Run 5 | Run 6 |
|---|---|---|
| build | 0 (115s) | 0 (64s) |
| check | 0 (79s) | 0 (52s) |
| test-rocky-systemd | 0 (178s) | 0 (94s) |
| test-storage | 0 (33s) | 0 (24s) |
| test-alpine | 2 (87s) | 2 (84s) |
| test-rocky-shell | 2 (159s) | 2 (146s) |
| test-multi-domain | 2 (144s) | 2 (136s) |
| test-linux-runtime (record-only) | 2 (66s) | 2 (47s) |

- **test-rocky-systemd passes twice**: "Rocky systemd console login
  target passed", QEMU-start-to-multi-user timings 99042 / 29224 ms
  (run 5) and 45869 / 19425 ms (run 6). The paper's headline boot
  claim is reproduced at the pin.
- **test-alpine fails twice** at the first in-domain marker: the OCI
  image is pulled and verified, the domain enters Linux init, then no
  further shell output appears and the test kills QEMU (signal 15)
  reporting missing `LIBC_RUNTIME_OK`.
- **test-multi-domain fails twice** the same way (missing
  `ALPINE_DOMAIN_OK`) after runtime contracts validate and DHCP
  configures.
- **test-rocky-shell fails twice** later in its sequence: Rocky 10.2
  boots to a working sh-5.2 shell, but the test does not observe a
  clean shell lifecycle.
- The failing waits are upstream's own: 60 one-second polls per
  marker in alpine-shell.sh, 120 in multi-domain.sh. Two identical
  failures on one host do not separate a product gap from an
  upstream test-window timeout on this host class; the note records
  the failures as repeated and the cause as unseparated. What would
  settle it: a rerun of the three gates on a modern bare-metal host,
  not performed.

Verdict rule (pre-registered in the PIN, 2026-10-28 addendum):
PASS_WITH_GAPS required the named boot gates to pass in our hands and
the disclosed supervisor-probe failure to be the sole aggregate
failure. Three named gates fail, so PASS_WITH_GAPS does not trigger.
FAIL is not warranted: build, check, storage, and the headline
systemd gate pass at the pin, twice. Hence PARTIAL.

## M3 — credit honesty: PASS

The author's scoping is candid and matches what we found: research
prototype, narrow compatibility, no independent audit, no production
claim, all stated in the abstract. The one asymmetry is disclosure
placement, recorded in M4: the `make test` failure is disclosed in the
repo (docs/PERFORMANCE.md) and never mentioned in the paper. The
benchmark medians (paper Sec. 5.2) rest on raw logs that are not
published (BENCHMARKING.md places them under `build/`; the Zenodo
record holds only the PDF), so that leg was fenced out rather than
taken on trust.

## M4 — fine-print assumption inventory

1. **Undocumented QEMU >= 9.2 prerequisite.** The kernel hard-requires
   the 48-bit IOMMU width bit; the project's own QEMU invocation
   passes `intel-iommu` without `aw-bits`; QEMU's default was 39-bit
   through 9.1. A repo-wide search at the pin finds no QEMU version
   floor stated anywhere. On QEMU 9.1 and earlier defaults, no boot
   gate can pass. This is a harness/documentation gap in the project,
   recorded as a finding, not as evidence against the boot claims
   where the prerequisite holds.
2. **The aggregate failure is not the disclosed one.** docs/
   PERFORMANCE.md (line 140) discloses a failure in the "post-exec
   system-supervisor lifecycle probe". On QEMU 10.1 the aggregate
   dies earlier: `kernel/src/lib.rs:1967`, "linked Linux ELF64 probe
   invariant failed", a pre-exec check that precedes the PID 1 exec
   and the "supervisor lifecycle validated" line (lib.rs:2074) in
   source order. Runs 5 and 6 logs show the 1967 failure and neither
   later line: the disclosed stage is never reached in our hands.
3. **Interactive-gate failures, cause unseparated** (see M2). The
   Alpine leg of the headline claim (selected unmodified Alpine
   musl/BusyBox programs) therefore did not complete in our hands in
   four attempts across two runs; the Rocky leg did.
4. **Provenance is author-reported.** STEERING-PROVENANCE.md is
   curated and says so; the ~USD 8,000 API cost and ~99% single-agent
   share are author estimates; provider token totals were not
   instrumented. Git metadata is consistent with the story (all
   1,037 checkpoint commits Kurtzer-authored, no agent trailers,
   timestamps across all 24 hours) and proves neither the single
   task nor the model. The "one persistent Codex task" claim is a
   GAP: untestable from the published artifacts.
5. **Table 1 caption drift** (M1): figures exact at `9afa617`,
   caption names the evaluated commit.
6. **LOC counting rule undocumented** (M1): 21-line residue under
   the closest counting set.

## Receipt

- Forge: `.github/workflows/ginux-forge.yml` in this repo (deleted at
  this close-out), gate job ran `scripts/harness/pre_dispatch_checks.py`
  before every forge job. Workflow commits: bd6984e (run 1), 4be881c
  (OVMF fix), 383d20d (KVM node fix), 3e1fdbc (run 4 diagnostic,
  inert), c268274 (run 5/6 lane, harness as shipped).
- Runs: 40770294887 (doctor, OVMF missing, no gates run),
  40780499105 (QEMU 8.2, TCG), 40790454478 (QEMU 8.2, KVM),
  40799359362 (run 4, repeat), 40833805179 (run 5, QEMU 10.1,
  KVM), 40978398655 (run 6, repeat of 5).
- Evidence artifacts (`ginux-forge-evidence`, sha256 of the zip as
  shown on each run page, verified after download): run 2
  `7fdffc499b10fde0bd1b86de5be945a9f3bb91941fa277449ec7856cb8c8d79b`,
  run 3 `c14aac51fe809882798fdd34485224f2bee205e95ccbf23dcd5dec74be284712`,
  run 4 `325dffeb09a3ee4ab3611a90b98d1681cea5a143fe8129352cc1af33c52e221e`,
  run 5 `bce55456b83a17f52fde0ab204cb52b2a2fc5776ac37cc5e59a264f8f2f30b08`,
  run 6 `b13b32c9f9a6b004cf2706493e40b908eb5acfa62872f508ab8be2db6d025f76`.
  Extracted evidence and working papers: `~/workspace/ginux-recon/`.
- Hosts: dell-laptop (DESKTOP-Q42R8VL, i7-8650U, 32 GB) for the
  Ubuntu 24.04 guest (runner dell-laptop) and the Ubuntu 25.10 guest
  (runner dell-laptop-qemu10, registered for this audit).
- Second opinions: Haiku 5.5 on the recon, 2026-10-28 (PIN addendum);
  Argon `google/gemini-4-argon` on the draft verdict, 2026-10-29,
  $0.033918, bottom line UPHOLD WITH REPAIRS. Repairs adopted:
  "deterministic" withdrawn from the interactive-gate finding
  (M2/M4.3), "not a defect" withdrawn from the QEMU finding (M4.1),
  scope caveats stated as dates and counts (M1, M4.3). Its
  aggregate-identity question was settled by the source read in
  M4.2 during adjudication.
