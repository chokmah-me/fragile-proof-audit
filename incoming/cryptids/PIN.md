# Input pin — Cryptids (DeepMind Busy Beaver formalizations)

Pinned 2026-10-23 for the harvest audit (queue 3rd at recon,
head of queue after h5i-app-bench closed; recon verdict YES strong
target 2026-10-23). Picked by the user in chat 2026-10-23
("proceed audit cryptids"). Scope of the pick: **full audit as
scoped in `~/workspace/cryptids-recon/QUEUE-PREP.md`** — three
verdicts kept separate (V-A paper, V-B repo Busy Beaver library,
V-C conjecture machines), M1 statement fidelity (App. A diff for
the 11 seeded machines; 12-machine V-B sample with the Stellar
BB6 non-vacuity vectors A–E, first application of the vectors
adopted 2026-10-23 in `docs/harvest-loop.md`; all 22 V-C headline
statements against formalization.yaml), M2 argument fidelity
(cold builds + comparator + axiom prints on the desktop runner),
M3 credit honesty, M4 fine-print inventory; DEEPEN as the
pre-verdict pass; the 32-gate verdict lock is not touched. No
author contact (standing policy).

- Paper: Dos Santos, Veeriah, Havrilla, Bolt, Zuzic, Singh,
  Zahavy (Google DeepMind; Dos Santos also Cambridge), *At the
  Limits of Computability: Steps Towards Autonomous AI Discovery
  on the Busy Beaver Frontier*, arXiv:2610.22603, v1 15 Oct
  2026, v2 19 Oct 2026. Local PDF
  `~/workspace/cryptids-recon/paper-2610.22603v2.pdf`, sha256
  `ed1954a91f6ff352e021d5c2c400b4f2c2c54a7ee5ddc1318924a04fc5dfec59`.
  No supplementary file on arXiv; appendices carry the rule
  systems (App. A), candidate list (App. C), compression
  algorithms (App. D), pipeline prompts incl. the Stellar BB6
  protocol (App. E).
- Repo: https://github.com/google-deepmind/cryptids
  - Pinned commit: `664cd03904a870e9a8796476dbf9dbc13a72a37b`
    (2026-10-22, "Add high-level Collatz accelerations and
    recurrence equations for all 21 novel BB(6) discoveries
    (#12)"). Local clone `~/workspace/cryptids-recon/repo`
    verified at this SHA.
  - Toolchain: Lean `v4.35.0-rc4` (`lean-toolchain`). Deps
    (lake-manifest.json): mathlib v4.35.0-rc4 @ `1f414401`,
    verso v4.35.0-rc4 @ `01a09f32`.
  - Scale at the pin: 149 .lean files, 153,759 lines; two
    libraries (BusyBeaver/ landed 2026-10-15, Cryptids/
    initial release 2026-10-09 by Faldor & Firsching).
  - Claims: V-B 59 holdout machines (53 BB(6) + 6 BB(3,3)),
    299 comparator theorems (comparator/busy_beaver.json);
    V-C 22 headline theorems (comparator/all.json), 10
    constructive-only (comparator/constructive.json).
- Working copies: `~/workspace/cryptids-recon/` (RECON.md,
  GM-RECON.md, QUEUE-PREP.md, M1-VA.md, M1-VB.md, M1-VC.md,
  M3-M4.md, verify-py-run.log, forge-evidence/ from the desktop
  run). Nothing under `incoming/cryptids/` besides this file;
  the evidence lives in the workspace dir.

## Status

AUDIT CLOSED 2026-10-23 — verdict PASS with qualifications
(note `docs/audits/cryptids.md` at the close-out commit).
One-shot workflow `cryptids-forge` (FPA main@765b752)
dispatched 2026-10-23T13:21:50Z; run 39960565475 concluded
success the same day. The close-out deleted the workflow file.
