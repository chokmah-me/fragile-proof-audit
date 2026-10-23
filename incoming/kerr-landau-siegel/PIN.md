# Input pin — Kerr, Landau–Siegel zeros simplification

Pinned 2026-10-23 for the harvest audit (queue 4th at triage
2026-10-20; head of queue after Cryptids closed 2026-10-23).
Picked by the user in chat 2026-10-23 ("do bryce kerr").
Scope of the pick: full paper audit — M1 statement fidelity,
M2 argument check (every lemma re-derived from the LaTeX
source; the three leading constants of the pigeonholing lemma
also cross-checked by enumeration), M3 credit honesty, M4
fine-print inventory; Grandmaster's Methods at recon, DEEPEN
as the pre-verdict pass; no runner leg (paper audit); the
32-gate verdict lock is not touched. No author contact
(standing policy).

- Paper: Bryce Kerr (UNSW Canberra), *A simpler proof that
  there are no Landau--Siegel zeros*, arXiv:2610.21099,
  submitted 15 Oct 2026 (v1; no later version at audit time).
  Abstract: "This paper simplifies the recent OpenAI proof
  that there are no Landau--Siegel zeros."
  Local PDF `~/workspace/kerr-recon/paper-2610.21099.pdf`,
  sha256
  `30dc40c959735eaaddd3609919695f87258ec2807fb615a9a4386702f3536116`.
  LaTeX source read in full: `src/siegel_zero_proof.tex`
  (419 lines) from the arXiv e-print. No supplementary file.
- Objects simplified / cited:
  - OpenAI, *Uniform exclusion of Landau--Siegel zeros*,
    preprint, 1 Oct 2026 (github.com/openai/math) — the proof
    being simplified; NOT an input to Kerr's argument and NOT
    verdicted by this audit.
  - W. D. Banks, arXiv:2610.15483 — exposition of the OpenAI
    proof; thanked in Kerr's acknowledgement.
  - H. Davenport, *Multiplicative Number Theory*, 2nd ed.,
    eq. (2) p. 89 — cited analytic input (Lemma analytic).
  - D. W. Masser, Invent. Math. 63 (1981), 81–95,
    doi:10.1007/BF01389194 — cited zero estimate (Lemma
    masser).
- Triage note (2026-10-20): "Masser 1981 replaces
  interpolation; fragility 2 on disclosed ChatGPT help."
  The fragility count is the two cited inputs; the ChatGPT
  assistance is disclosed in the paper's acknowledgement.
- Working copies: `~/workspace/kerr-recon/` (GM-RECON.md,
  VERIFY.md, DEEPEN.md, paper PDF, e-print source).

## Status

AUDIT CLOSED 2026-10-23 — verdict PASS (note
`docs/audits/kerr-landau-siegel.md` at the close-out commit).
No machine leg; no workflow to delete.
