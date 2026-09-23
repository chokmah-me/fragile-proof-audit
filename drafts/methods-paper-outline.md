# Companion methods paper — outline (saved 2026-09-23)

Decision: public repo + companion methods paper. Straight-methods tone (not manifesto).
Named campaign, artifacts released alongside the paper.
Status: outline only. Writing not started — awaits user go-ahead.
Suggested first section to draft: §4.

**Working title:** *Trust Nothing, Replay Everything: A Methodology for Independent Auditing of Computer-Assisted Proofs*

## 1. Abstract
Published mathematics, especially computer-assisted proofs, is trusted far more than it is independently re-run. This paper describes a multi-year private audit campaign that replays published claims from scratch and dispositions each as BREAK, PASS, or SKIP. The contribution is the playbook: a taxonomy of attack types ("gates refute routes, not theorems") plus the evidentiary disciplines that keep the attacks honest.

## 2. Introduction: the verification gap
Peer review checks reasoning, not computation. Computational components of proofs are rarely re-executed; supplementary material rots (dead sites, lost files). The campaign's thesis: every computational claim should survive a hostile, well-resourced replay.

## 3. The disposition taxonomy
BREAK (refuted with evidence), VERIFY/AUDIT PASS (independently confirmed), SKIP (not auditable as stated — e.g. nonconstructive arguments). Verdicts are append-only: never edited in place, corrections are new entries. The 23/23 BREAK lock as the discipline made concrete.

## 4. The attack types (A–G)
Each: what the route attacks, how the gate is built, one worked example.
- **A — Scalar gate.** The claim reduces to a statement about a specific constant; compute it and check. Ex: Tang–Zhang, broken by an explicit rank-one pair exceeding the conjectured constant.
- **B — Base-case kill.** Falsify the claim's base case directly, or expose a criterion mismatch. Ex: the Suman ζ(5) blueprint.
- **C — Unoccupied.** No type C was ever assigned in the campaign; noted explicitly rather than left mysterious.
- **D — Finite q-expansion.** Verify truncated q-series expansions or congruence predictions computationally. Ex: the pdn1 gate.
- **E — Ore/CAS replay.** Re-run the computer-algebra machinery (Ore algebras, Mathematica) behind a computer-assisted proof. Documented honestly as tooling-limited on a laptop stack — the route exists before the infrastructure does.
- **F — Counterexample search.** Exhibit a concrete finite witness. The classic BREAK engine. Ex: Baste, false already at Δ = 3; Chung–Graham–Spiro; Cohen subadditivity.
- **G — Logical-gap / false-premise pinpoint.** No computation: isolate the exact lemma the route needs and falsify it, naming the precise failure point. Ex: Lamé 1847 — the route needs ℤ[ζ_p] to be a UFD; class number 3 at p = 23 kills the route while FLT itself stands. Blueprint header: "Claim (route, not the theorem)."

## 5. The evidentiary disciplines
- *Paper-first gate:* pin and read the actual paper; never gate from a secondary summary.
- *Discrimination control:* "a check that cannot fail is not evidence" — every gate must demonstrate the opposite verdict where the opposite is correct, with matched (single-variable) controls.
- *Gate before prove:* no Lean formalization begins until the claim is numerically gated; formalization targets carry a no-sorry, kernel-checked standard.
- *Fail-closed replay:* sharded recomputation with hash-pinned inputs; any mismatch fails the lane.
- *Dual implementation:* two clean-room builds, different algorithms, must agree bit-for-bit (disagreement caught a real p=2 bug in the Pólya sieve).
- *Durable job discipline:* long jobs log to disk with explicit exit markers, verified by hand.

## 6. Case studies
One page each, mapped to §4/§5: Gomila Λ-bound (audit PASS via replay lanes + sealed-log verification), Pólya counterexample (trust-anchor canonization: 91 chunk certificates, dual sieves), q-TSPP (certificate rescue + staged formalization, in progress).

## 7. Limitations
Replay cannot catch specification errors (proving the wrong formalization of a claim); nonconstructive arguments force SKIP; GB-scale certificates vs. kernel checking is an unsolved cost curve; type E remains tooling-blocked.

## 8. Related work
Proof assistants and formalization efforts, the scientific replication movement, prior proof-audit and verification projects.

## 9. Conclusion
The playbook is the product; every pattern in §4–§5 is reusable against the next claim.

## Appendices
A: verdict-log schema; B: gate harness conventions; C: the audit catalog with attack type per entry.
