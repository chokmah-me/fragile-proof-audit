# Grandmaster's Methods at recon — Harvest 2026-10-20 (Emergent Mind batch)

Companion pass per the standing harvest pairing (Stunspot Prompt of the Day,
2025-08-16; adopted in docs/harvest-loop.md at b169e15). Method: reconstruct
how the authors in this batch actually work, from primary sources (the arXiv
records and abstracts), weighted unvarnished over polished, with the skeptic
filters (survivorship, success-myth reconstruction, ghosted authorship) run
throughout. This batch has no single expert; it has two recurring author
methods, and those methods are where the fragility lives.

## Method 1: Validation-then-compression of an AI proof drop

Papers: Brennan / integral means (Binder, Ivrii, Prause et al.,
arXiv:2610.23853); Banks on the OpenAI Landau-Siegel proof
(arXiv:2610.15483); Kerr, a simpler Landau-Siegel proof (arXiv:2610.21099);
Frei–Sofos–Widmer (arXiv:2610.18491, provenance only, audit closed at
ef465a7) is the batch's earlier instance of the same ecosystem.

- Problem framing: the OpenAI October 2026 preprints are treated as raw
  ore, not as results. Success is defined as a shorter argument a human can
  check, with explicit constants where the original left them implicit.
- Inputs and filters: the source argument's skeleton is kept; redundancy is
  the target. Banks keeps the whole argument and re-arranges it as a direct
  proof with constants q_0 = 10^10, delta_0 = 3.0 x 10^-3, then closes the
  remaining range with a cited computation (Lu–Zaman–Zhao). Binder et al.
  report the opposite filter at work: validating the Brennan/Kraetzer
  argument showed "much of their argument is redundant," and the compression
  yielded a stronger statement, not just a shorter one.
- Decision rule (inferred, labeled as such): if a step in the source proof
  does no work for the stated conclusion, cut it and re-check the headline;
  the headline is allowed to move (Brennan: the bounded spectrum bound on
  the full interval, Kraetzer equality killed in the interior) when the
  stronger statement is what the shortened argument actually proves.
- Trade-off: brevity and checkability against fidelity risk. Every cut is a
  place where a side condition can be silently dropped (M1) or the argument
  replaced rather than compressed (M2). The deferred parts are stated in
  the Brennan abstract itself (strictness and extremal maps "deferred or
  remain open"), which is the unvarnished detail to weight over the
  "drastically shorter, significantly stronger" headline.
- Failure mode / early warning: a simplification whose abstract carries no
  constants, no range and no preservation statement (Kerr: the abstract is
  one sentence) gives a reader nothing to check without a full proof read.
  That is not evidence of a defect; it is why Kerr triages as a proof-read
  pick, not a gate pick.
- Peer vector: Cureton–Thorner in the FSW chain did the same job in the
  other direction (one paper, v1 Re s > 1−1/6000 revised to v2 Re s > 31/32
  within two days): the ecosystem's norm is fast revision of the analytic
  input, with downstream papers citing whichever version they consumed.
  Version pinning is therefore part of any pick from this method family
  (the FSW audit's central finding).

## Method 2: LLM as proposer, program as judge

Papers: quantum circuits (Gu et al., arXiv:2610.22367); DiscoveryRSI
(arXiv:2610.23839, code public); Gemini 4 Argon Minecraft agents
(arXiv:2610.22319); Jev-as-a-Judge (arXiv:2610.23346) is the judge-only
variant.

- Problem framing: generation is cheap and unreliable; verification is the
  scarce step, so the architecture spends its credibility budget on an
  evaluator (circuit scorer, Harbor task harness, official IR judgments)
  and lets the LLM propose freely inside it.
- Signature move: keep the evaluator independent of the proposer and say
  so in the abstract (quantum circuits: "an independent evaluator verifies
  and scores"). Where the loop is recursive (DiscoveryRSI learns from the
  investigations it compiled into tasks), the evaluator is no longer fully
  external, and that is the exact point a pick should press (M4).
- Case rebuild, Minecraft (the batch's clearest success-myth risk): one
  run, Easy difficulty, privileged symbolic state, 2,783 programs, 605
  deaths, 22% program-error rate, Ender Dragon killed in 27 h 14 min. The
  paper's own framing, as carried in the digest, discloses every one of
  those qualifiers; the myth risk sits in downstream coverage that keeps
  "agents beat Minecraft" and drops the qualifiers. Hinge moment: the
  qualifiers were published with the result, so an audit can hold the
  headline to them without new evidence.
- Boundary: the method produces exactly as much trust as its evaluator.
  A pick from this family starts with the evaluator, not the results.

## Portable principles (carry to any future harvest)

1. When a paper's method is compression of someone else's proof, audit the
   cuts, not the prose: M2 first, then M1 on the moved headline.
2. When the claim is "X made unconditional / for all q," find the join:
   the point where the analytic argument stops and a cited computation
   starts (Banks at q = 10^10; FSW at the consumed zero-free region).
3. When an LLM proposes and a program judges, the judge is the trusted
   base; inventory it as an M4 assumption before looking at any score.
4. A one-sentence abstract on a simplification is a triage fact, not a
   defect: it moves the pick cost from gates to a full proof read.

## What this pass changed in the recon

Nothing in the scores (the rubric is fixed), and no verdicts. It sets the
pick order rationale: the three Landau-Siegel / Brennan compressions are
one method family sharing one source ecosystem, so picking any one of
them buys information about all three; the quantum-circuits paper is the
cleanest Method-2 pick because its evaluator is stated to be independent.
