# Input pin — LeanIn (scidonia/leanin)

Pinned 2026-10-23 for the harvest audit (6th at triage 2026-10-22;
head after Turing, h5i-app-bench, Cryptids, Kerr and Kopis closed).
Picked by the user in chat 2026-10-23 ("do leanin").
Scope of the pick: full audit of V-A (the repo's proof claims at
the pin) plus M1 statement fidelity against the Medium article's
four load-bearing claims (deadlock freedom, task-state soundness,
message-passing invariants, benchmarks), M2 argument (model layer,
bridge layer, the nine *_spec axioms), M3 credit honesty
(authorship, disclosures), M4 fine-print inventory; Grandmaster's
Methods at recon, DEEPEN as the pre-verdict pass. V-B
(performance) is secondary and NOT independently verified (bench
not re-run on this VM; the repo itself states ±30% drift; scope
statement in the note, not a verdict). The 32-gate verdict lock is
not touched. No author contact (standing policy).

- Repo: https://github.com/scidonia/leanin, main @
  a7e8e9ca4fef75b6eff665925ff17aaf9ff35029 ("leanio: move the fork
  out of the LeanIn tree", 2026-10-20T19:45:31+02:00), toolchain
  leanprover/lean4:v4.35.0, lake-manifest ZERO external packages
  (pure Lean + Std). Local clone ~/workspace/leanin-recon/repo
  (310 commits).
- Article (primary claim voice): Gavin Mendel-Gleason, "Beyond
  Math Proofs: Building a Concurrency Runtime in Lean 4 that
  Outperforms Node.js", Medium, 2026-10-20 (fetched in full).
- Benchmark commit named in the README: 554e3b0 =
  554e3b00afca4789eafecdd0ffa04b6b28ff6af6.
- Forge: one-shot workflow leanin-forge (FPA main@480ca64,
  desktop lane), run 40013980514, concluded success 2026-10-23
  ~15:51 EDT (5m11s); evidence artifact leanin-forge-evidence,
  4,993 bytes, sha256
  f558b530ca143b6048d51929f9ef0dbcf1508338666c6843a09f67ab0b4c6282
  (local copy ~/workspace/leanin-recon/forge-evidence-3/). Two
  earlier attempts failed on the audit's own harness (pin-vs-tip
  assertion; qualified-vs-bare axiom names; ungated exe legs),
  all disclosed in the note with post-mortems in ~/AGENTS.md.
- Working copies: ~/workspace/leanin-recon/ (RECON.md,
  GM-RECON.md, QUEUE-PREP.md, M-NOTES.md, DEEPEN.md,
  forge-evidence-3/).

## Status

AUDIT CLOSED 2026-10-23 — verdict PASS on V-A, with the M1
(article's deadlock-freedom claim BREAK as published; the
message-passing invariant claim unsupported as published; V-B
not independently verified), M2 (P8 refinement argued not
proved; the audited bridge theorems rest on six of the nine
*_spec axioms; exe legs GAP on the runner's missing libuv) and
M4 (nine-axiom + opaque relations + NonAliasing + A6 Task
substrate TCB; fairness-conditional P2/P9) qualifications in
the note. Deadlock-freedom and message-passing findings are
about the article, not the repo.
