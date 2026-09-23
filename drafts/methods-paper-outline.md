# Companion methods paper — outline (saved 2026-09-23; revised 2026-09-23 after fact-check)

Decision: public repo + companion methods paper. Straight-methods tone (not manifesto).
Named campaign, artifacts released alongside the paper.
Status: §4 drafted (`drafts/methods-paper-section4.md`); remaining sections outline only.

**Working title:** *Trust, but Replay: Auditing Published Mathematical Claims*
(Prior title "Trust Nothing, Replay Everything" dropped as manifesto-toned; keep as a possible subtitle/epigraph only.)

## 1. Abstract
Published mathematics, especially computer-assisted proofs, is trusted far more than it is independently re-run. This paper describes a short audit campaign (first commit 2026-09-18; repo private, to be made public with the paper) that replays published claims from scratch and records each disposition as BREAK, GAP, PASS, SKIP, or UNKNOWN. Every verdict is pinned in a CI verdict lock. The contribution is the playbook: a taxonomy of attack types ("gates refute routes, not theorems"), the evidentiary disciplines that keep the attacks honest, and an open record of where those disciplines failed and what caught the failures.

## 2. Introduction: the verification gap
Peer review checks reasoning, not computation. Computational components of proofs are rarely re-executed; supplementary material rots (dead sites, lost files — q-TSPP certificates survived only on Wayback). The campaign's thesis: every computational claim should survive a hostile, well-resourced replay. Own the short timeline explicitly: the claim is reproducibility of the method, not longevity.

## 3. The disposition taxonomy
- **BREAK** (route refuted by a gated, controlled witness), **GAP** (decisive inference broken by proof reading, but not finitely gateable; route refuted, explicitly *not* a BREAK and not on the lock — FRK-UC Demontis, LEG-NS Ferreira, Erdős–Straus Thm-10), **PASS** (gate's claim independently confirmed; escalates, never forced), **SKIP** (not auditable as stated — e.g. nonconstructive arguments, no witness), **UNKNOWN** (artifacts verified, kernel not re-checkable on our toolchain — e.g. quantum Hedetniemi, their Lean 4.19.0).
- **Polarity rule:** a verdict attaches to the *gate's claim*, not to the paper's conclusion. Lamé: `lame_h23` / `lame_ideal_neg23` are locked **PASS** (h(ℚ(ζ₂₃)) = 3 confirmed); that confirmed fact is what kills the route. §4 must say so explicitly.
- **The verdict lock:** `scripts/gates/check.py` `EXPECTED_VERDICT` pins 25 gates (17 BREAK / 8 PASS as of 2026-09-23); drift in either direction fails CI. It is *not* an all-BREAK lock. Audit confirmations (Gomila) and canonizations (Pólya) sit off the lock.
- **Append-only, precisely stated:** history is append-only in git + WORKPLAN checkpoints; summary tables (README) show the current verdict with a "superseded" note (odd-zeta, corrected 2026-09-20).

## 4. The attack types (A–G) — DRAFTED, see `drafts/methods-paper-section4.md`
Each: what the route attacks, how the gate is built, one worked example. The example's type must match its dossier `type:` field (`corpus/Fragile-Route_Harvest_Dossier*.md`, `corpus/lean4-attack-harvest.md`); combined types (F+A, B+G, D+E) are stated, not collapsed.
- **A — Scalar gate.** Tang–Zhang Schatten constant. BREAK.
- **B — Base-case kill.** Suman ζ(5) Eq. (48). BREAK.
- **C — WZ-certificate audit.** Jana–Karmakar (arXiv:2501.10109): 630 + 630 telescoping checks (Lemmas 2.1, 3.1) + 96 theorem checks. PASS. This also refuted an unverifiable AI-review fragility claim ("gate the meta-claims"). The harness bug here (66 spurious mismatches, negative-index Pochhammer) is now `scripts/harness/pochhammer.py`.
- **D — Finite q-expansion.** PDN1. PASS (escalate); depth lesson 81 → 6,747 points.
- **E — CAS-transcript replay.** q-TSPP q=1. Tooling-limited (also RR/HJO OreReduce, PDN1 notebooks — "capability-limited").
- **F — Counterexample search.** Baste (Δ = 3, 50-vertex witness); also Chung–Graham–Spiro, Cohen subadditivity. BREAK.
- **G — Logical-gap exposure.** Lamé 1847 at p = 23 (route verdict; gates PASS per polarity rule). Newer G instances land as **GAP**, not BREAK: FRK-UC (Demontis union-closed; control probe finds zero finite violations), Erdős–Straus Thm-10 interval gap (repairable), LEG-NS (Legendre via Newman sums, v4). A G-pass that finds nothing is also recorded: JAC-2D type-G PASS.

## 5. The evidentiary disciplines
- *Paper-first gate:* pin and read the actual paper; never gate from a secondary summary.
- *Discrimination control:* "a check that cannot fail is not evidence" — every gate must demonstrate the opposite verdict where the opposite is correct, with matched (single-variable) controls. (Baste control caught a hardcoded `n = NUM_VERTICES` bug.)
- *Gate before prove:* no Lean formalization begins until the claim is numerically gated; formalization targets carry a no-sorry, kernel-checked standard.
- *Fail-closed replay:* sharded recomputation with hash-pinned inputs; any mismatch fails the lane.
- *Independent anchors + dual implementation:* the Pólya p=2 sieve bug (2-adic inverse absent for p=2; L(100000) = −2074 vs −288) was caught by **brute-force anchors**, before implementation 2 existed; implementation 2 (clean-room, source never read) then agreed on 91/91 chunks. Present these as two layers, not one.
- *Durable job discipline:* long jobs log to disk with explicit exit markers, verified by hand.

### 5.x Where the method failed, and what caught it
The paper's credibility backbone. Sources: WORKPLAN.
- Paper-first rule violated four times before it was retrofitted (targets #1–#3 gated from abstract fetches).
- Ghost corpus entries (table rows with no body section) and fabricated/garbled identifiers (Reed/Zenodo γ, Sun/Zenodo Catalan).
- Odd-zeta verdict corrected 2026-09-20 (prior "Λ_m unevaluable" superseded by the Lemma 5.1 BREAK); re-verified 2026-09-23.
- A harvested (third-party LLM) Lean snippet proposed as the Suman gate was itself buggy (empty constraint `1 ≤ k ∧ k ≤ 0`).
- Harness bugs caught by controls/anchors: Pochhammer convention (C), `n = NUM_VERTICES` (F), p=2 sieve (Pólya).

## 6. Case studies
One page each, mapped to §4/§5:
- **Kempe–Fritsch (BREAK).** The 1879 four-color route, gated + controlled; paper-first discipline (Gethner/Involve 2009 pinned). Gives §6 its refutation case.
- **Gomila Λ-bound (audit PASS).** Replay lanes (finite 3,149,013/3,149,013 rows, Dini, barrier, tail) + sealed-log verification at pinned commit `a74738d`.
- **Pólya counterexample (canonization).** 91 SHA-256-pinned chunk certificates, anchors, dual sieves, Lean slice to n = 100.
- *q-TSPP:* short "in progress" note only (milestone 3 blocked on author reply); promote if coefficients arrive before submission.

## 7. Limitations
- Replay cannot catch specification errors on its own. The campaign's first BREAK (γ audit, `docs/audits/gamma-aejonanonymous.md`: proves `¬ is_rational_gamma`, not mathlib γ) shows a separate *statement-fidelity* audit can. That is a partial remedy, not a closed gap.
- Nonconstructive arguments force SKIP.
- GB-scale certificates vs. kernel checking is an unsolved cost curve.
- Type E remains tooling-blocked.
- Short campaign window; the target selection came from harvest dossiers (selection bias toward fragile-looking claims).

## 8. Related work
Proof assistants and formalization efforts, the scientific replication movement, prior proof-audit and verification projects.

## 9. Conclusion
The playbook is the product; every pattern in §4–§5 is reusable against the next claim.

## Appendices
A: verdict-log schema (incl. lock mechanics); B: gate harness conventions; C: the audit catalog with attack type(s) per entry, as in the dossiers.
