# PIN - Ginux (Kurtzer, Human-Directed Agentic Engineering kernel)

Audit opened 2026-10-28 at the user's pick (news item
2026-10-27/28, not from the harvest queue). This is a
replay audit of a software claim, in the family of the
OpenAI ETH audit: AI-generated code, executable gates,
a pinned commit. The 32-gate verdict lock is not
touched. No author contact.

## Claim

Gregory M. Kurtzer (CIQ; founder of CentOS and Rocky
Linux), *Ginux: Building an Independent Kernel That
Runs Linux Userspace through Human-Directed Agentic
Engineering*, Zenodo DOI 10.5281/zenodo.23682548,
v1 published 2026-10-27.

- Over eleven days, one persistent OpenAI Codex task
  using GPT-5.6 Sol produced Ginux, an independent
  Rust-first x86-64 kernel with its own memory
  management, scheduler, process model, filesystems,
  networking, devices, and Linux ABI layer. It boots
  through UEFI with no Linux host kernel, runs its
  controller in ring 3, executes selected unmodified
  Alpine musl/BusyBox programs, and boots a Rocky
  Linux 10 userspace with systemd through
  `multi-user.target`.
- Approximately 139,000 retained lines of
  implementation and test code (Table 1: 174,736 LOC
  including generated payload; 138,790 retained
  non-generated; 1,037 commits; 261 tracked files).
- Linux 6.12 x86-64 syscall ledger: all 375 syscall
  numbers classified, 82 complete, 245 partial, 48
  policy-denied.
- Benchmark leg (paper Sec. 5.2): matched single-vCPU
  QEMU TCG sysbench medians against Rocky on stock
  Linux (boot 12.860 s vs 42.579 s; memory 620.580 vs
  679.510 MiB/s; threads 309.732 vs 306.129 events/s).
- The author's own scope: research prototype, narrow
  compatibility and hardware coverage, no independent
  security audit, no matched control or independent
  reproduction, no production claim. The abstract
  states all of this.

## Pinned sources

- Report PDF (the only file in the Zenodo record):
  13 pp, 96,575 bytes, sha256
  `97591c342493b46a6a1f1939c3ac070bb0de2d82c211dda3bf8022c9236344f2`;
  md5 `ed091164b85dfa17e9adbe947396c435` matches the
  Zenodo listing.
- Repo: github.com/gmkurtzer/ginux. Evaluated commit
  (the paper's pin) `d11c126a048a51fe7eb9c4105f31760add1027ea`,
  2026-10-23 20:49:58 -0700, "Optimize Linux vDSO
  timekeeping". Documentation checkpoint commit
  `9afa61762a66a20855ea3a23e3e04221b54a5a22`,
  2026-10-20 20:25:29 -0700. HEAD at recon
  `36503bda2d87465765e1b94e65f9d100f27ed5be`; later
  changes are not part of the evaluated checkpoint.
- File sha256 at the evaluated commit: README.md
  `cb498faca8a959ed5b18bef27d696aaead8fd74fe32c2adb334890d1485f4ec7`;
  Makefile
  `99738d1dc2a6af88cc2f1178ebebc387c5b6981221580930c6879b056265a797`;
  docs/LINUX-COMPATIBILITY.md
  `18975287784ccf56ca667edbd0b3942dad13efcd38b009652ffc0b3c2406c633`;
  docs/paper/ginux-ai-systems-report.tex
  `0fc678316472f610b5b2ff3b5777a889d2987112f1b4ac360ff68064e19b147b`;
  docs/paper/STEERING-PROVENANCE.md
  `7eaa27470568e07de9690356a5ab865f4c168c14f962f45893bfccf9c74e2c8f`;
  docs/PERFORMANCE.md
  `0c171f3ed4cd2e8a7319d6edff9e6ab390d198cddfbce2f8791ab29737ab8c8a`;
  docs/BENCHMARKING.md
  `1fd2cbc8b10e81511afbb9c24d4c64f91ac0d188b9f5f155bd3b5070492e3c5d`.
- Toolchain: `rust-toolchain.toml` pins Rust 1.99.0;
  build also needs Clang (x86_64-none-elf target),
  QEMU x86-64 with OVMF, and GNU Make.
- Working copies and recon: `~/workspace/ginux-recon/`
  (report PDF, extracted text, clone at the pin).

## Recon findings (2026-10-28; read and count only, no upstream code executed)

1. **Syscall ledger EXACT at the pin.** An independent
   parse of the table in docs/LINUX-COMPATIBILITY.md
   gives 375 rows: 82 Complete, 245 Partial, 48
   Policy-denied, matching the document's stated
   totals and the paper.
2. **Table 1 reconciles exactly at the documentation
   checkpoint, not at the stated evaluated commit.**
   At `9afa617`: 1,037 commits, 261 tracked files,
   63 Rust files, 13,074 Markdown LOC, all exact
   matches to Table 1; the development interval
   Oct 10 to Oct 20 is 11 calendar days inclusive.
   At the evaluated commit `d11c126` the same counts
   are 1,063 commits, 282 files, 64 Rust files, and
   the history spans Oct 10 to Oct 23. The paper's
   own docs/paper/README.md names `9afa617` as the
   draft's commit. So Table 1's caption ("at the
   evaluated commit") is stale by 26 commits and
   3 days. Every figure checks at the checkpoint it
   was taken from; this is checkpoint drift, not a
   fabrication signal. It is a correction the note
   should record.
3. **LOC rows reconcile to within 21 lines.** At
   `9afa617`, .rs + .sh + .S lines total 174,757 vs
   the paper's 174,736, and 138,811 retained vs
   138,790, the same 21-line difference on both rows.
   The generated-payload split reconciles exactly:
   174,736 - 138,790 = 35,946 = the line count of
   the single generated file
   `boot/efi/src/generated_boot.rs`. The exact file
   set behind the LOC rows is not documented in the
   repo and no counting script was found; the
   counting rule is an audit question, minor.
4. **Known failure disclosed at the pin.**
   docs/PERFORMANCE.md: `make check` passes, but the
   verification boot "still fails in the post-exec
   system-supervisor lifecycle probe" and "is not
   counted as a successful full `make test` result
   in this checkpoint." The audit must expect that
   failure, not a clean aggregate pass.
5. **Benchmark medians are not replayable from the
   published artifacts.** BENCHMARKING.md puts raw
   logs and generated images under `build/` (not in
   the repo); the Zenodo record holds only the PDF.
   The harness scripts are in the repo
   (tools/benchmarks/). The benchmark leg is
   therefore fenced out of V-A unless the author
   publishes the raw logs.
6. **Provenance is author-reported (M4).**
   STEERING-PROVENANCE.md is curated and says so
   ("not a verbatim transcript"); docs/paper/README.md
   says the ~USD 8,000 API cost and ~99% single-agent
   development share are author estimates, and that
   provider token totals were not instrumented. The
   "one persistent Codex task, GPT-5.6 Sol" claim
   cannot be settled from the repo alone.

## Audit scope

- **V-A (build and boot gates at the evaluated
  commit, on a KVM-capable x86-64 Linux host; host
  choice still open):** `make build`, `make check`,
  `make test-linux-runtime`, `make test-alpine`,
  `make test-rocky-shell`, `make test-multi-domain`,
  `make test-rocky-systemd`, `make test-storage`,
  plus the aggregate `make test` recorded as-is
  (expected: the disclosed supervisor-probe failure).
- **V-B (auditor's own counting, no upstream code):**
  recount the syscall ledger, commits, tracked
  files, and LOC under a stated counting rule at
  both `d11c126` and `9afa617`, formalizing recon
  findings 1 to 3.
- **M1 by read:** abstract and headline claims
  against the evaluated-commit state, including the
  "eleven days" interval definition (finding 2).
- Out of scope: the benchmark medians (finding 5),
  any production or security assessment, HDAE as a
  general method (single case, no control; the
  author says so), and all post-pin HEAD changes.

Expectation recorded at open: PASS_WITH_GAPS is the
likely shape. Gaps already visible: Table 1
checkpoint drift, missing benchmark artifacts,
uninstrumented provenance. Nothing in recon touches
the core boot claim; that leg is simply untested
until V-A runs.
