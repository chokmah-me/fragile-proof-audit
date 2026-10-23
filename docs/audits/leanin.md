# Audit note — LeanIn (scidonia/leanin)

**Claim artifact:** Gavin Mendel-Gleason, "Beyond Math Proofs:
Building a Concurrency Runtime in Lean 4 that Outperforms Node.js"
(Medium, 2026-10-20, fetched in full). **Claim V-A:** the runtime's
concurrency machinery carries machine-checked proofs for the properties
that matter — "deadlock freedom across resource contention points",
"sound task states", "deterministic invariants" in the message-passing
primitives — built as a Tokio-style multi-threaded work-stealing
runtime. **Claim V-B (secondary):** the Lean runtime outperforms
Node.js "across almost all standard concurrency benchmarks" with
"higher RPS while keeping tail latency significantly flatter" (P99
named as a workload; no numbers anywhere in the article). This audit
verdicts V-A on the repo's theorems at the pin; the article's
performance claims are checked against the repo's own published
material (V-B not independently re-run — a bench from this VM would be
weak evidence, and the repo itself states ±30% run-to-run drift).
**Repo pin:** https://github.com/scidonia/leanin, main @
a7e8e9ca4fef75b6eff665925ff17aaf9ff35029 ("leanio: move the fork out
of the LeanIn tree", 2026-10-20T19:45:31+02:00), toolchain
leanprover/lean4:v4.35.0, lake-manifest carries ZERO external packages
(pure Lean + Std; no Mathlib, no iris-lean). The benchmark commit named
in the README is 554e3b0 = 554e3b00afca4789eafecdd0ffa04b6b28ff6af6.
Local clone ~/workspace/leanin-recon/repo (310 commits). Upstream moved
to ffe3a0af (docs-only) before dispatch; the audit stays at the
queue-prep pin per its own rule.
**Harvest item:** LeanIn (6th at triage 2026-10-22, then head after the
five ahead closed; full audit at the user's word "do leanin"
2026-10-23; Grandmaster's Methods at recon; DEEPEN as the pre-verdict
pass). **Campaign objects:** `incoming/leanin/PIN.md`; working notes
`~/workspace/leanin-recon/` (RECON.md, GM-RECON.md, QUEUE-PREP.md,
M-NOTES.md, DEEPEN.md, forge-evidence-3/).

**Agent provenance:** Muse (Meta), model `Muse Spark 1.3`, audit date
`2026-10-23`. Machine leg: one-shot forge workflow `leanin-forge`
(desktop lane, FPA main@480ca64); run 40013980514 concluded success in
5m11s — see the receipt section for what the verdict step checks and
the two harness bugs found and fixed on the way.
**Harness pin** (`scripts/harness_pin.py`): agent Muse (Meta), model
`Muse Spark 1.3`; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

**Scope of this audit:** M1 statement fidelity (article claims vs
repo theorems, the four sub-claims a/b/c/d), M2 argument (the
two-register operation: model layer and bridge layer, the nine
*_spec axioms and their controls), M3 credit honesty (authorship,
disclosures), M4 fine-print inventory; DEEPEN as the pre-verdict
pass. No author contact (standing policy). The 32-gate verdict lock
is untouched.

**Status:** CLOSED 2026-10-23 — verdict **PASS** on V-A (the repo's
proofs re-prove at the pin as stated), with the qualifications below.
This verdict is about the repo's theorems, not the article's claims:
two article sub-claims do not survive M1, and that is a finding about
the article, not the repo.

## M1 — statement fidelity

The article's four load-bearing proof claims were each checked
against the repo at the pin:

(a) **"Deadlock freedom across resource contention points" — BREAK as
published.** No deadlock predicate or theorem exists anywhere in the
repo (`grep -rni deadlock` hits only an HTTP handler comment and a
lock-ordering remark in decisions.md). The repo never claims a
deadlock theorem; the article's claim has no corresponding artifact.

(b) **"Sound task states, ensuring a task is never simultaneously
queued across multiple threads or dropped prematurely" — supported
within the model's scope.** This maps to Model.Multi
`reachable_consistent` (held + taken = pushed) and `reachable_live`,
proved in the pure model at P carriers (single-carrier corollary via
Multi.toSched), re-proved in the forge (see receipt). What is proved
is the model; the model-to-runtime step is the P8 gap, named in M2.

(c) **"Deterministic invariants in state machines governing
message-passing primitives" — not supported as published.** The
repo's own decisions.md states the semaphore invariant (D14) and
DEFERS it (restated still-deferred at decisions.md:540); the sync
primitives (W6) run on one Std.Mutex critical section each.

(d) **V-B performance — not independently verified, and the repo's
own numbers contradict the article.** The repo's table (README at
554e3b0, single screen.sh run, host load 2.5 → 8.1 disclosed in the
README itself): pipe16 wins 2.59/3.05/2.31x, depth1 ~parity
0.98/1.06/0.88x, churn LOSES at every level 0.62/0.91/0.82x. The repo
calls the table "an illustration", names `bench/paired.sh` the
claim-grade instrument, and states ±30% drift. PERFORMANCE.md's only
defended figure is 2.2x vs Std.Async (equal-thread), not vs Node.
P99: `bench/load.mjs` reports RPS only — no latency instrument
exists in bench/, so the flat-tail claim is UNVERIFIED by any repo
artifact. The measured server is a single-threaded carrier (README:
"Our current focus is a single threaded carrier"; completions resume
on the loop thread); the multi-carrier artifact is the MODEL
(Multi.lean), not the measured server. The article inherits none of
these caveats.

## M2 — argument (two registers)

**Model layer:** plain-Lean theorems with self-audited `#print
axioms` blocks per file. World: A1 structural mutex, A5
no-notification-memory (proved), A4 spurious wakeups (proved),
waiter-nodup. Multi: reachable_live / reachable_consistent /
reachable_bound plus breaking controls. Service: partition
invariants plus breaking controls. NOT proved: P3/P4/P5 scheduling
bounds (never attempted; strategy §3 Gap C), P2 completion + P9
fairness (conditional on the A6 fairness hypothesis, "not
discharged"), P7 cancellation (D23 abort correspondence "tested,
not proved"), P0 deque linearizability (no Iris route taken;
iris-lean was never even a dependency). All of this is the repo's
own published gap map (docs/proof-strategy.md §1/§6).

**Bridge layer:** nine axioms in LeanIn/Theory/Bridge.lean
(newMutex_spec, newCondvar_spec, lock_spec, tryLock_spec,
unlock_spec, wait_spec, notifyOne_spec, notifyAll_spec, clock_spec)
over two OPAQUE relations (`Runs`, `CallExec`); `Rep.NonAliasing`
is a definition carried as a hypothesis, invisible to `#print
axioms` (the repo discloses this itself, incl. its AGENTS.md: "an
axiom-free line means 'nothing was assumed as an axiom', never
'nothing was assumed'"). wait's trace↔model-path correspondence is
explicitly "still owed". The forge re-classified all 69 axiom lines
independently: every span is inside the classical three plus the
bridge *_spec axioms (printed bare, e.g. `lock_spec`, because the
audit `#print` blocks sit inside `namespace LeanIn`). The audited
bridge theorems rest on SIX of the nine axioms: `newMutex_spec`,
`newCondvar_spec` and `tryLock_spec` have no `#print axioms`
record and no consumer anywhere in LeanIn/ incl. tests/ at the pin
— contracts without downstream theorems (DEEPEN finding, not a
correctness issue). README's "nine primitive contracts, each with
a control" overstates slightly: A3 has no executable control by
design (UB), A4's is a tolerance test, and the seven-claims count
in Test/Control.lean reconciles with the nine axioms, not a
discrepancy.

**P8 refinement** (Sched.Pool states per-op refinement for the
queue half; composition refinement Impl.op ⊑ Model.op) is "argued,
not proved", gated on the unproved serializability lemma
(primitive-theory.md §4); the repo's AGENTS.md states: "No
source-level end-to-end IO theorem exists." The runtime↔model
connection is argument plus executable controls (SC1..SC27,
BT1..BT3) — and the controls were not run on the forge runner
(receipt: libuv_absent).

## M3 — credit honesty

310 commits at the pin: Gavin Mendel-Gleason 303, Maren van
Otterdijk 7. Zero Co-Authored-By trailers; no LLM-use disclosure
found in commits, the repo AGENTS.md, or the article. Exactly that
is claimed — no inference about whether assistance happened. The
repo side is otherwise exemplary: published gap map, axioms with
C++/ISO citations, the old count-form notify axiom kept as a
control (`counted_notify_admits_replacement`), the superseded
axiom shapes kept as proven-unsound countermodels in
Test/BridgeControls.lean (outside the default lib target).
Grandmaster's Methods framing: a two-register operation — rigor
where peers look, slogans where customers look; the artifact is
rated by its weakest public surface.

## M4 — fine-print inventory (survives)

- Gap A (no Lean concurrency semantics) SURVIVES; authored-not-adopted model SURVIVES; iris-lean Gap B MOOT at the pin (never became a dependency).
- Bridge axioms + opaque `Runs`/`CallExec` + `Rep.NonAliasing` hypothesis = real TCB beyond the kernel, and `#print axioms` under-reports it (disclosed by the repo) SURVIVES.
- A6 (dedicated Task = new OS thread) has a control but NO axiom — trusted substrate (D13) SURVIVES.
- Weak memory is SC-scoped SURVIVES.
- P2/P9 fairness-conditional SURVIVES.
- Bench fine print SURVIVES, and the article inherits none of the caveats (M1(d)).

## Receipt

- Forge: one-shot workflow `leanin-forge`, FPA main@480ca64,
  `[self-hosted, desktop]` lane. Run 40013980514, completed
  success 2026-10-23 ~15:51 EDT (5m11s). Evidence artifact
  `leanin-forge-evidence`, 4,993 bytes, sha256
  f558b530ca143b6048d51929f9ef0dbcf1508338666c6843a09f67ab0b4c6282
  (local copy ~/workspace/leanin-recon/forge-evidence-3/).
- Verdict step (fail-closed): pin ok (target a7e8e9ca checked out
  explicitly; tip-at-dispatch ffe3a0af recorded as context only) +
  build exit 0 (32 jobs) + source scans 0/0/0/0 over
  LeanIn/+tests/ (55 files; .lake is at repo root, outside scope) +
  ≥10 axiom lines, all classified (69: 65 spans + 4 clean) +
  dynamics/bridgecontrols/BT1 recorded libuv_absent (the desktop
  runner has no uv.h; every exe target builds the package's netuv
  C shim, so the legs were not runnable — a disclosed GAP, not a
  repo failure; the Lean modules for all four compiled) +
  SC1 libuv_absent.
- The axiom classification was re-run independently from
  build.log: zero bad spans, no sorryAx, no ofReduceBool; the six
  *_spec axioms actually used are exactly the six consumed by the
  audited bridge theorems.
- Local pin corroboration: Bridge.lean sha256
  f939b5eabb13673173629c120c610261d916ebcfb194c03046f9f0bbfa47e520,
  World.lean sha256
  a3afd5d26a6fe89f326160fc427df82112dfe5db18c59199bcdf937f7125c056,
  identical to the evidence pins; manifest has zero packages.
- Two earlier attempts failed on the audit's own harness, both
  disclosed: run 40003053223 died at minute zero comparing the
  moving tip to the pin (post-mortem in AGENTS.md: assert the pin,
  never the tip); run 40007897516's verdict failed on qualified
  vs bare axiom names and ungated exe legs (post-mortems in
  AGENTS.md: build allowlists from captured #print output; an
  extern_lib is package-scoped).

## Verdict

**PASS on V-A**, qualified: the model theorems (no-lost-wakeup,
task conservation at P carriers) and the bridge contracts
re-prove at the pin exactly as the repo states them; the model
itself is the proved object, and the model-to-runtime step (P8)
is argued, not proved. The article's deadlock-freedom claim is a
BREAK as published (no such theorem exists), the message-passing
invariant claim is unsupported as published (D14 deferred), and
the performance claims are not independently verified and are
partially contradicted by the repo's own published table.
