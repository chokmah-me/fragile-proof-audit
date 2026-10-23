# Input pin — h5i-app-bench (Lean 4 verification of Rust Axum projects)

Pinned 2026-10-23 for the harvest audit (queue 2nd, recon verdict YES
strong target 2026-10-23). Picked by the user in chat 2026-10-23
("Run the full h5i audit as scoped"). Scope of the pick: **full audit
as scoped in `~/workspace/h5i-recon/QUEUE-PREP.md`** — M1 statement
fidelity (all 101 spec statements + bug-linked areas), M2 argument
fidelity (per-port build + full gate-theorem axiom print + certificate
currency recheck on the Dell/VM), M3 credit honesty, M4 fine-print
inventory; the 32-gate verdict lock is not touched. No author contact
(standing policy).

- Article: Koukyosyumei (Hideaki Takahashi), *I Tried to Formally
  Verify Popular Rust Projects with Lean 4, but Found More Bugs Than
  I Expected*, Medium, 2026-10-19T17:04:59Z.
  Headline claims: 101 selected security specifications across six
  Rust projects, "accepted a proof for all but two"; three upstream
  security findings (RustiCal, RustFS, OxiCloud).
- Dashboard: https://benchmark.h5i.dev/prove/ (in-repo data snapshot
  `docs/prove/data/`, generated 2026-10-19 01:29).
- Bench repo: https://github.com/h5i-dev/h5i-app-bench
  - Pinned commit: `bebcf72c15d52bde888c49d6ea45b897033175d6`
    ("Add django cart (#36)", 2026-10-21). Local clone
    `~/workspace/h5i-recon/repo` verified at this SHA.
  - Upstream pins (per the repo README pin table): nora
    `getnora-io/nora @f864a9a`; artifactkeeper
    `artifact-keeper/artifact-keeper @7c42891`; kanidm
    `kanidm/kanidm @f608c4f`; rustfs `rustfs/rustfs @e870a6d`;
    tuwunel `matrix-construct/tuwunel @7801b8e`; oxicloud
    `AtalayaLabs/OxiCloud @8c0dd33`.
  - Toolchain: Lean `v4.31.0` in every port (`lean-toolchain`).
    h5i-app library: `h5i-dev/h5i @d337c3cfffa41aadf155cdf0ca92e24ebe9470cc`
    (`crates/h5i-app-core/proofs`, lakefile requires `v0.5.0`).
    Aeneas backend: `b86120db3183b0107eb5f2637b11c424cd06ef1c`.
- Working copies: `~/workspace/h5i-recon/` (RECON.md, GM-RECON.md,
  QUEUE-PREP.md, M1/M3/M4 notes, cert_recheck.py, forge-evidence/
  from the Dell run). Nothing under `incoming/h5i-app-bench/`
  besides this file; the evidence lives in the workspace dir.
