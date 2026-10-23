# Input pin — Kopis KEM (rozbb/kopis-rs)

Pinned 2026-10-23 for the harvest audit (queue 5th at triage
2026-10-22; head after Kerr closed 2026-10-23). Picked by the
user in chat 2026-10-23 ("do kopis").
Scope of the pick: full audit of V-A (all three backends, all
three parameter sets): M1 statement fidelity (the six
top-level theorems, the three spec layers, the
structural→behavioral diff against git history), M2 argument
(the Aeneas bridge, twin generators, intrinsic _spec axioms
spot-checked against the manuals; the silicon-vector replays
re-run in the forge), M3 credit honesty (blog retrospective vs
the three-month commit record; the two prior in-repo audits),
M4 fine-print inventory; Grandmaster's Methods at recon (done
2026-10-22), DEEPEN as the pre-verdict pass. V-B (performance
parity) is secondary and NOT verdictable on this VM (bench not
re-run; scope statement in the note, not a verdict). The
32-gate verdict lock is not touched. No author contact
(standing policy).

- Repo: https://github.com/rozbb/kopis-rs, main @
  c368dee666cd1f0b6235907f40089e4ab53ed724 ("Make clippy
  happy", 2026-10-21T04:05Z), toolchain
  leanprover/lean4:v4.35.0. Local clone
  ~/workspace/kopis-recon/repo.
- Blog (primary claim voice): Michael Rosenberg, "Can You
  Slop Out High-Assurance Cryptography?", 2026-10,
  https://mrosenberg.pub/blog/cryptoslop/
- Design paper: Andrea Basso (IBM Research Europe – Zurich)
  and Michael Rosenberg, *Kopis: A KEM for Obfuscation*,
  IACR ePrint 2026/2268, received 2026-09-29, approved
  2026-09-30, PDF v1.0 dated Sep 29, 2026, 52 pages
  (verified at the landing page 2026-10-23; the user's copy
  is on his own machine — the VM's browser could not pull
  it past the site's human check, so no local copy is on
  file).
- Spec: lean/kopis-spec.md (English) and lean/KopisSpec.lean
  (C2SP copy, 24,484 bytes) in the repo; Kopis/Explicit.lean
  (BitVec restatement); Kopis/Equiv.lean (layer agreement).
- Prior audits (in-repo, read but never rebuilt): audits/
  2026-07-30-fable5.md, audits/2026-10-11-security-audit.md
  (2aec76b).
- Forge: one-shot workflow kopis-forge (FPA main@2e44f28,
  desktop lane), run 39986698670; evidence artifact
  kopis-forge-evidence, 34.3 KB, sha256
  6d8c73fe5316d08eb058cba46e7eadc20d57800e05cb207018324f245c2a0507
  (local copy ~/workspace/kopis-recon/forge-evidence/).
  All substantive checks green; the workflow's verdict step
  failed on a scan-scope bug in the audit's own harness
  (scans covered .lake/packages; zero hits in kopis
  sources), disclosed in the note.
- Working copies: ~/workspace/kopis-recon/ (RECON.md,
  GM-RECON.md, QUEUE-PREP.md, M1-NOTES.md, M2M3-NOTES.md,
  DEEPEN.md, forge-evidence/).

## Status

AUDIT CLOSED 2026-10-23 — verdict PASS on V-A, with the M1
(seams: no spec-level roundtrip; the structural→behavioral
diff) and M3 (successor KAT set provenance unrecorded) and
M4 (constant-time unproved; IND-CCA out of scope)
qualifications in the note. V-B not independently verified.
One-shot workflow kopis-forge deleted after the receipt.
