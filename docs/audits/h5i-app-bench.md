# Audit note — h5i-app-bench (Lean 4 verification of Rust Axum projects)

**Claim artifact:** Koukyosyumei (Hideaki Takahashi), *I Tried to
Formally Verify Popular Rust Projects with Lean 4, but Found More
Bugs Than I Expected* (Medium, 2026-10-19), and the bench repo
`h5i-dev/h5i-app-bench`: 101 selected security specifications across
six Rust projects, "accepted a proof for all but two"; three upstream
security findings (RustiCal, RustFS, OxiCloud).
**Harvest item:** h5i-app-bench (queue 2nd; recon 2026-10-23, verdict
YES strong target; Grandmaster's Methods at recon).
**Campaign objects:** `incoming/h5i-app-bench/PIN.md`; working notes
`~/workspace/h5i-recon/` (RECON.md, GM-RECON.md, QUEUE-PREP.md,
M1/M3/M4 notes, `cert_recheck.py`, `forge-evidence/`).
**Repo pin:** `h5i-dev/h5i-app-bench` @
`bebcf72c15d52bde888c49d6ea45b897033175d6` (2026-10-21).
**Toolchain pins:** Lean `v4.31.0` (every port); h5i-app library
`h5i-dev/h5i @d337c3cfffa41aadf155cdf0ca92e24ebe9470cc`
(`crates/h5i-app-core/proofs`); Aeneas backend
`b86120db3183b0107eb5f2637b11c424cd06ef1c`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · run
date `2026-10-23`. Machine legs: one-shot forge workflow
`h5i-forge` (per-port build + full gate-theorem axiom print, Dell
lane) and a VM-local certificate-currency recheck
(`cert_recheck.py`). An adversarial pre-dispatch pass covered the
workflow file (YAML parse, `bash -n` per block, verdict unit tests
on synthetic data, generator output checked name-for-name against a
TOML parse of the six `[check]` lists).

**Scope of this audit:** M1 statement fidelity (all 101 spec
statements + bug-linked areas), M2 argument fidelity (forge build,
gate-theorem axioms, certificate currency), M3 credit honesty, M4
fine-print inventory. No author contact (standing policy). The
32-gate verdict lock is untouched.

**Status:** CLOSED 2026-10-23 — verdict **PARTIAL** (see M2).

## The claim and its three denominators

The project reports its results in three different units, and the
audit keeps them separate (the forge's first verdict failed on
exactly this confusion; see Receipt):

1. **Tasks:** 101 selected specifications (`dataset/tasks.toml`);
   the ledger (`prove/results/verification/coverage.json`) records
   99 `previously_checked`, 2 missing (both totality specs).
2. **Gate theorems:** 356 theorems in the six ports'
   `h5i-app.toml [check]` lists (rustfs alone contributes 268;
   the other five match their task counts). These are the
   project's strict-gate universe (`h5i app check`).
3. **Certificates:** per-task `results/verification/<id>/`
   bundles (`Solution.lean`, `attempts.json`,
   `certificate.json`) with input-hashed certification boundaries.

The article's headline ("accepted a proof for all but two of the
101") is unit 1. The dashboard data (generated 2026-10-19 01:29)
carries units 1 and 2 side by side: `properties 356, accepted
354, proved 59` alongside `benchmark_properties 101,
benchmark_accepted 99`.

## M1 — Statement correspondence: PASS with qualifications

All 101 task properties were read against their Lean statements;
conditions live in the property text itself where they exist
(`nora-middleware-total`: "while no failure counter is at
u32::MAX"; `kanidm-str-contains-spec`: "for haystacks shorter
than Usize.max"; `rustfs-force-delete`: "(for actions upstream
can parse)"). Capacity (`Usize.max`) hypotheses are rare in
statements (1–10 per `Properties.lean`), concentrated in totality
statements. The project's own `props.rs` (kanidm, tuwunel,
oxicloud) checks each statement on random inputs with premises
required to hold at least 300 times — a premise-vacuity guard.

Qualifications (all documented inside the repo itself):
- `rustfs-resolution-terminates` is proved for the **backported**
  resolver (see M4) under a `PlainValues` hypothesis, and its
  property line says so: termination holds "when no substituted
  value contains a variable reference" — exactly the class the
  GHSA's diverging inputs belong to. The fix's protection (depth
  cap 10, resume-after-substitution) is covered by sibling specs
  (`policy_variable_depth_cap_spec`,
  `policy_variable_depth_resolution_spec`).
- `tuwunel-transition_total`: the original unconditional statement
  was unproved; the obstruction is constructed in
  `prove/docs/tuwunel-totality-obstruction.md`; the statement was
  revised to the capacity-bounded form and remains unproved. The
  move is documented at every step.
- OxiCloud's 11 specs cover the ACL engine and grant endpoints;
  the playlist metadata leak (PR #796) lives in adjacent handlers,
  outside the ported scope. No spec claims the playlist property.

## M2 — Argument correspondence: PARTIAL

**Forge (Dell, run 39921571445, 1h16m):** all six port builds
exit 0; all six axiom prints exit 0; all 356 gate theorems have
axiom records. **303 are clean within the classical three;
53 depend on `sorryAx`; 0 depend on any off-allowlist axiom.**
The 53 are the 2 documented missing totality specs
(`kanidm-effective-total`, `tuwunel-total`) plus 51
`Properties.lean` sorries the project's own checkpoint marks as
recoverable candidates (nora 15, artifactkeeper 11, kanidm 13,
tuwunel 11, oxicloud 1, rustfs 0). The project's own gate panel
(Oct-19 snapshot) agrees: `h5i app check` passes only rustfs.
The 51 are the documented work surface, not a hidden break —
but they are why the strict gate does not pass at the pin.

**Certificate currency (VM-local, exact input-hash recheck of
all 99 accepted certificates against the pin):** **86 current,
13 stale.** Every stale certificate is rustfs: five kernel
inputs (`conddata.rs`, `defaults.rs`, `extras.rs`, `varctx.rs`,
generated `RustfsKernel.lean`) changed in `ada9f32` ("Change
scope (#17)", 2026-10-10 21:26 UTC), after the certificates were
minted (2026-10-10 19:21 UTC); no recheck since. Per the
project's own certificate semantics ("so a changed input can be
rechecked", `coverage.py`), these 13 need recheck. The ledger
honestly records them `previously_checked` with
`checked_this_run=0`, and `DEVIATIONS.md` flags that earlier
certificates need a one-time recheck — the staleness is in the
repo's own data model, but the "99/101 accepted" headline does
not carry it. The 2 missing specs have no accepted certificate,
as claimed. All 99 committed `Solution.lean` files are
sorry-free. The h5i-app library inputs verify file-for-file
against the lakefile-pinned rev `d337c3c` (27 files, uniform
across certificates); statement and task-entry hashes were
recomputed with the project's own formulas (cross-validated by
the 86 passes).

**What PARTIAL means here:** nothing false was proved, no axiom
smuggling (0 off-allowlist), the 2 missing are honestly missing.
But the headline "99/101 accepted", read at the pin as a present
accomplishment, is 86-current + 13-stale by the project's own
certificate semantics. The recheck outcome for the 13 (would
they re-pass?) is not established — that is the remaining GAP,
and it is the author's one-command `--check-all` away.

## M3 — Credit honesty: PASS on disclosure, with qualifications

- The proofs were produced with coding agents. The repo says so
  openly (repo description: "Can AI agents formally verify
  real-world Rust source codes with Lean4?"; `prove/README`:
  "Coding agents help produce proofs"; the dashboard names
  models/agents per column). The article does not: it is
  single-author first person throughout ("I was able to prove
  most of the selected security properties"), mentioning AI
  coding agents only as an ecosystem trend. A reader of the
  article alone gets the wrong impression; a reader of the repo
  gets the full picture.
- The three findings at primary sources: RustiCal
  GHSA-9cp5-7crm-9cf7 (2026-10-05, medium; no reporter credit in
  the advisory record; the bench's own case still unpublished, as
  the article says); RustFS GHSA-9wgh-5r68-49p7 (2026-10-18,
  medium; no reporter credit in the record); OxiCloud PR #796
  (merged 2026-10-07; body credits the report explicitly to
  @Koukyosyumei via h5i-dev/h5i).
- Dashboard provenance: the data is a 2026-10-19 snapshot (two
  days before the pin), not a live regeneration; equivalence
  entries are labeled "randomized differential and property
  tests; not formal equivalence" in the data itself.

## M4 — Fine-print inventory (Murray & van Oorschot; load-bearing items)

All six `DEVIATIONS.md` (711 lines) follow one template: covered
map (kernel fn → upstream fn at the pin), difftest design, trusted
inputs, form-difference table with reasons. Classification:

- **Behavior vs the pin (1, disclosed):** the rustfs kernel's
  `resolve_single_pass` follows rustfs `03e77594` (2026-10-09),
  not the pinned `e870a6d` — the port verifies the post-fix
  resolver. Disclosed in `DEVIATIONS.md`, not in the README pin
  table.
- **Semantic narrowings (documented):** Unicode→ASCII case in
  kanidm's Utf8 substring tests and rustfs's older condition
  evaluator (the claims module implements full Unicode case from
  the pinned toolchain's table, checked exhaustively);
  artifactkeeper answers as a cache miss (upstream caches can
  serve stale entries for their TTL); tuwunel's `scanned` flag
  and `state_get_id` error kinds differ in argued-unreachable
  corners.
- **Trusted inputs (declared per port):** crypto/JWT/IP parsing
  as oracle tables (nora, artifactkeeper); hand-evaluated SQL in
  artifactkeeper's difftest shell (the upstream side is itself a
  model at the DB layer); profile parsing and index-aware
  resolution out (kanidm); `PgAclEngine` caches out, `lpath` and
  effective policies fed in from the DB (oxicloud, whose difftest
  runs real PostgreSQL 17 with the 99 upstream migrations);
  parsing/federation/lazy-loading out (tuwunel); JSON decoding,
  IP/CIDR parsing, clock reads in the shell (rustfs).
- **Difftest strength (as documented):** nora 20k middleware
  requests + millions of validator inputs; artifactkeeper real
  axum requests; kanidm 100k cases over all seven trait
  operations + 13 mutations; oxicloud real Postgres;
  tuwunel 240k requests + 7 named mutations; rustfs 400k+400k
  policy cases + exhaustive Unicode. Kernel mutations fail the
  tests in every port.

## Receipt

- **Forge receipt:** one-shot workflow `h5i-forge`
  (fragile-proof-audit main@`e2ea28d`; file deleted after this
  note landed, per the one-shot pattern). Clone asserted at
  `bebcf72c15d52bde888c49d6ea45b897033175d6` before building.
  Run 39921571445 on runner `dell-laptop`
  (DESKTOP-Q42R8VL), concluded **failure** after 1h16m (finished
  2026-10-23 09:16 UTC) — the failure was the auditor's verdict
  step, not the evidence: it applied a per-task-ledger
  expectation ("all 356 gate theorems clean except the 2
  documented") to the per-theorem universe, a category error
  diagnosed from the artifact and corrected in M2 above
  (post-mortem banked in `~/AGENTS.md`: pin every claim to its
  denominator before writing a verdict gate). All build/axiom
  steps were green; the evidence artifact `h5i-forge-evidence`
  (sha256
  `b35446aab07c96f6340a7a6ec58fcecc4abdfe946c4d5ce188cd0feba60e2a44`)
  was verified independently from the downloaded zip (local
  copy `~/workspace/h5i-recon/forge-evidence/`): the verdict
  script reproduces `clean: 303, sorry: 53, off-allowlist: 0,
  records: 356` byte-for-byte.
- **Certificate-currency receipt:** `~/workspace/h5i-recon/
  cert_recheck.py` (read-only; run 2026-10-23 on the pin
  clone): 99 certificates rechecked, 86 fully current, 13
  rustfs stale (output `~/workspace/h5i-recon/
  cert_recheck_out.txt`). The 2 missing specs have no accepted
  certificate.
- **Harness pin** (`scripts/harness_pin.py`,
  2026-10-23T09:41:47Z): agent Muse (Meta), model `Muse Spark
  1.3`; skills dir `~/workspace/skills` (mtime
  2026-10-09T20:02:43Z) with `lean-proof-forge`
  (forge-workflow design) and `computational-claim-gate`
  (currency recheck) among 11 skills.
- **Not applied:** the Stellar BB6 non-vacuity vectors adopted
  2026-10-23 (`docs/harvest-loop.md`); first application is
  scoped to the Cryptids audit.

## Verdict lock

Untouched (17 BREAK / 15 PASS). This audit's verdict is
**PARTIAL**, scoped to the h5i-app-bench claim artifact above.
