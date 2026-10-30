# Input pin — OpenAI local smoothing formalization (openai/math, LocalSmoothing)

Pinned 2026-10-30. Source: OpenAI 2026-10-26 announcement
(three model-produced claims; ETH disproof audited PASS,
note docs/audits/openai-eth-disproof.md); picked by the
user 2026-10-30 after recon
(~/workspace/local-smoothing-recon/RECON.md). Scope:
V-A, runner build + axiom audit of the solution module
at the repo pin; V-B, statement fidelity of the six
comparator theorems against the challenge statement,
with the twin-definition seam settled by a
challenge-env vs solution-env #print corpus (the ETH
audit method). The accompanying natural-language
manuscript is out of scope, as is the Yang-Mills claim
(no public artifact). The verdict lock is not touched.
No author contact. Shepherds named in the announcement
explicitly do not certify.

## The claim

- Local smoothing for the wave equation in all
  dimensions at the conjectured sharp regularity,
  formalized in Lean, with the consequences drawn in
  the same module: Bochner-Riesz in the full strict
  range (including p = infinity), spherical restriction
  in the full strict range, Kakeya maximal bounds with
  delta^{-eps} loss, Stein's square function in the
  conjectured range, and full Hausdorff dimension of
  every Kakeya set (no measurability assumed).

## The code

- Repo: github.com/openai/math @
  `7ef5c0cc5ca4b0e072b7a050fca09ab24bc6fa3a` (same pin
  as the ETH audit; head == origin head at ETH run
  time; local sparse copy at ~/workspace/eth-recon/math
  is at this commit, challenge file sha256
  58dd1d878cd08f8d32850b1142e451a5efd4b0cdcf538ba80efbd01ea83cd9fd
  verified against a fresh fetch).
- Challenge: `lean/ComparatorChallenges/LocalSmoothing.lean`
  (+ `.json`): solution module
  `OAI.Analysis.Fourier.LocalSmoothing.Comparator`,
  six theorems (euclidean_local_smoothing,
  bochner_riesz, spherical_restriction, kakeya_maximal,
  kakeya, stein_square), permitted axioms = classical
  three.
- Solution module subtree:
  `lean/OAI/Analysis/Fourier/LocalSmoothing/`, 73 .lean
  files, 284,021 bytes. Comparator.lean imports
  OAI.Analysis.Fourier.SquareFunction.Square.Literal;
  Main.lean imports WavePackets.AllScales and
  WavePackets.PositivePacketSolvability, so the build
  closure extends into the Fourier subtree (vendoring:
  the whole lean/OAI/Analysis/Fourier subtree, with an
  in-forge import-closure check).
- Toolchain `leanprover/lean4:v4.34.1`; Mathlib rev
  `d13f23b723b8a846827a245b89c10fc7d3f11612` (same as
  the ETH audit).
