# Scope note — the hAR hypothesis of the 1-extension audit

Companion to the Heaton–Winter 1-extension audit note
([one-extension-lean.md](one-extension-lean.md), verdict PASS,
main@22dc7db, PIN main@c7aacfe). Filed 2026-11-01. This note
changes nothing in that audit: the verdict, its scope, and its
text stand exactly as filed. The audit took hAR as an explicit
hypothesis, matching the paper's own Formalization subsection;
this note records a later check of that hypothesis against its
published source.

**Harness pin** (`scripts/harness_pin.py`, run
2026-11-01T07:04:54Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills: ai-failure-mode-hygiene,
chokmah-research-engine, computational-claim-gate,
contract-breaker, contract-certifier, lean-proof-forge,
manuscript-integrity-gate, paper-robustness-check,
release-sync, testforge, verification-reviewer. Second-opinion
pass: DEEPEN via OpenRouter `google/gemini-4-argon` (effort
medium), adjudicated by the auditor; receipts in the seam
record below.

The hypothesis, as typed, is: for every graph G and every
placement p whose coordinates are algebraically independent
over Q, LocallyFlexible G p iff InfinitesimallyFlexible G p,
where the infinitesimal side is the numeric condition
dim ker R(G,p) = C(d+1,2). It carries no vertex-count guard.

Findings of the check (full record: seam workdir
`~/workspace/asimow-roth-seam/` — RECON.md, ADJUDICATION.md,
STEP1-PRIMARY-CHECK.md, D-POINTS-NOTE.md,
DEEPEN-ADJUDICATION.md; primary texts pinned in its
`sources/`):

1. Asimow–Roth as published (Trans. Amer. Math. Soc. 245
   (1978) 279–289, sha256
   1f24d08487e91dc0496468818b4e659cf5d327c6d21e8728622bb2828cef9a8f;
   J. Math. Anal. Appl. 68 (1979) 171–190, sha256
   4f23847108333d46ef6e04d899439223b0d76c13ae65a4e972ab586f9b18911c;
   both free at their publishers, no supplementary material
   exists) state no theorem in this exact form and no
   |V| ≥ d+1 guard. Their definition is intrinsic
   (T_p = ker df_G(p), 1979 §3), their dimension count is
   (m+1)(2d−m)/2 with m the affine dimension of the placement,
   and the |V| ≥ d+1 guard in the modern secondary statements
   (Sun & Ye Thm 4.2; Frank & Jiang Thm 1; Jackson's slides)
   is a later convention ensuring full affine span. Kitson &
   Power Thm 2.5, the regular-point form, is the secondary
   statement closest to the primary text.
2. The typed statement is nevertheless true for every graph
   when card V ≥ d, by Asimow–Roth's own theorem (1979 §3:
   infinitesimally rigid iff regular point and rigid; generic
   placements are regular, indeed in their general position;
   1978 Prop. 1 bridges their rigidity to the Lean flex
   form; the dimension count equals C(d+1,2) exactly when
   m ≥ d−1). The boundary card V = d is also verified
   directly, without the papers: rows of R(K_d, p) are
   independent at every generic placement (descending block
   induction at the simplex placement, lifted by the
   minor-is-a-polynomial argument), and every proper
   subgraph of K_d has a hinge flex (rotation of a missing
   pair's endpoint about the affine hull of the remaining
   d−2 points) with kernel dimension at least C(d+1,2)+1.
3. The typed statement is false in general when
   card V ≤ d−1: for G = K_v at a generic placement,
   dim ker R(K_v, p) = C(d+1,2) − C(d−v+1, 2) while
   LocallyFlexible is false (e.g. v = d−1 gives
   C(d+1,2) − 1; the single edge in R^3 gives kernel
   dimension 5, not 6). The exact threshold is card V ≥ d,
   one below the secondary literature's guard.
4. Every use site in the archive is in range, and one is
   exactly at the boundary: the headline 1-extension theorem
   applies hAR at card ≥ d+1 (hV′ : d+1 ≤ card Vert′); the
   Maxwell theorem and the characterization corollary
   (Results.lean) carry hV : d ≤ card V, and the corollary's
   bundled hAR ranges over H : SimpleGraph V on the same
   vertex type V, so every instance has card V ≥ d. The
   secondary d+1 form would not have sufficed for
   Results.lean as written; the card V = d case is
   load-bearing there.

Conclusion of the check: hAR is dischargeable from
Asimow–Roth as published at every point where the archive
spends it. The hypothesis's status changes from "assumed" to
"assumed, and verified dischargeable in its used range"; the
audit that assumed it is not reopened and its verdict is not
restated.
