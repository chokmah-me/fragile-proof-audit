# PIN — aaronson-ambainis-psi-20261106 (registered 2026-11-13)

Pinned 2026-11-13 at the user's tap (register as CLAIM now;
Argon run for the registration form the same day). No verdict
at pin time. Recon: registration draft prepared 2026-11-08
(announcement page and repo README read in full), re-verified
firsthand 2026-11-13 (HEAD unchanged, key files fetched at
the pinned commit and hashed, theorem statements read at
source). Argon Arbiter adjudication 2026-11-13
(google/gemini-4-argon, adjudicated by the main agent):
register standalone now, audit NOT queued; the queue
decision is taken at CFSG run 10 close-out, gated on an AA
forge design sized against the runner's memory cap. Record:
~/workspace/aa-registration-2026-11-13/.

This registration supersedes the 2026-11-08 02:04 ET
briefing's WATCH-only, artifact-less grade. That premise was
wrong: the repository was created 2026-11-06, two days
before the briefing. Correct grade: registrable CLAIM with
a public artifact.

## Claim

PSI (Physical Superintelligence), "A proof of the
Aaronson-Ambainis conjecture", published 2026-11-06
(https://psi.inc/research/aaronson-ambainis/). In PSI's
framing: an internal research system running a non-public
Anthropic model produced a complete Lean proof of the
Aaronson-Ambainis conjecture, improving the bound twice;
the proof follows the Lovett-Zhang plan and replaces their
conjectured inequality with a new one proved by a
determinant pairing argument extending Reimer's Butterfly
Lemma. Statements, the first paper draft, and the Lean
formalization were produced by AI models; a named PSI
staff member (David Turturean) built the system, scoped
the problem, and is responsible for correctness. No peer
review yet. The claim as scoped by the artifact's four
theorems below is the registered claim.

## Canonical artifact

github.com/physical-superintelligence/aaronson-ambainis,
public, Apache-2.0, created 2026-11-06T03:19:45Z, single
commit `2a6ceaef872ae993708950f951989134084b851a` (HEAD
re-verified unchanged 2026-11-13), 95 Lean files.

- Toolchain: `leanprover/lean4:v4.33.0` (lean-toolchain
  sha256
  `302cd63c54178885b89e669f33b38f12f4dd7ae7e5cac537b3203e3768d8fb2b`).
  Mathlib v4.33.0 (lake-manifest.json sha256
  `d970b7ed85c5db3df473e322c20572a40b3a554bfbc021e9cf4b575d4e56e3c4`).
- Endpoints (`AaronsonAmbainis/Main.lean`, read at source
  at the pinned commit):
  - `aaronson_ambainis : PrintedConjecture` — the
    conjecture in Aaronson-Ambainis normalisation, bound
    (eps/d)^7.
  - `aaronson_ambainis_explicit : ExplicitBound` — bound
    (8*sqrt(15)/(125*pi^4)) * eps^(5/2) / d^6, the constant
    about 0.0025. (The PSI page renders the constant as
    "815/(125 pi^4)"; that is a rendering of 8*sqrt(15).
    The repo's 8*sqrt(15) is authoritative.)
  - `aaronson_ambainis_pm : ExplicitBoundPM` — Theorem 1.1
    form on the {-1,1}^n cube.
  - `aaronson_ambainis_of_fbsDegreeBound :
    FbsDegreeBound -> ExplicitBoundImproved` —
    CONDITIONAL: `FbsDegreeBound` is Theorem 1.7 of
    Agarwal and Ben-David (arXiv:2410.19062), not
    formalized in this repo. Conclusion constant
    32*sqrt(15)/(125*pi^4).
- The statement file `AaronsonAmbainis/Conjecture.lean`
  imports only Mathlib and uses no project definition, so
  the statements are independently readable.

Key files (sha256, fetched at the pinned commit):

- `AaronsonAmbainis/Conjecture.lean` —
  `dd63776b831d110f41278692400653fac3001b166548e5c2a8971dd0dabd3a52`
- `AaronsonAmbainis/Main.lean` —
  `a34f2591efc9142a3d607e15fbcec38d7942ba6986afad6045fdcc9439330f58`
- `AaronsonAmbainis/Comparator/Challenge.lean` —
  `edd52b53250ec4081f43321354d4c44fb905e1dd38dae1d30a670a9a4c407abd`
  (carries the only sorries in the repo: the four open
  comparator-challenge proofs; no library file imports it)
- `AaronsonAmbainis/Comparator/Solution.lean` —
  `25cfc13bf70b1efd51205c442d72ed76e0b8ad0b9dcdbd412c349c2385252031`
- `README.md` —
  `b870e814f20c9a1ad00c3935c09b1344be0183af4322b74572b2f6fbc8f416ad`

## Their checks, and what they do not cover

Per the repo README: static audit found no sorry, axiom,
native_decide, unsafe, partial, implemented_by, extern,
set_option, or new syntax/macro/notation/elaborator in the
library; each of the four theorems `#print axioms` exactly
[propext, Classical.choice, Quot.sound]; leanchecker
replays every declaration through the kernel, plus
replay-fresh from an empty environment, with the same two
replays under lean4lean; a negative control (false
statement added with the kernel switched off) is accepted
by `lake build` but rejected by both checkers; the
comparator (nanoda plus a Lean kernel, sandboxed
GitHub-hosted run) compared all four theorems against a
challenge importing only Conjecture.lean, and a second
machine accepted one small correct solution and rejected
four deliberately wrong ones.

Not covered by their checks, in their own framing: whether
PrintedConjecture faithfully states the conjecture (a
reader's confirmation); the paper (not machine-checked;
PAPER_TO_LEAN.md lists paper sections 1.3, 1.4, 1.5, 9 and
the examples as having no formal counterpart); the
foundations (Lean kernel/compiler, Mathlib definitions,
machines).

Our doctrine applies unchanged: their replays are strong,
but a receipt here still requires our own comparator run
from an empty environment, and statement fidelity is ours
to check (M1, plus the ST-1 to ST-5 statement tests, for
which this claim is the named first full application).

## M1 seams recorded at pin time

1. Influence conventions: {0,1} cube,
   Inf_i = E[(p(X) - p(X^i))^2], vs {-1,1} cube,
   Inf_j = E[((f(x) - f(x^j))/2)^2]. Check each theorem
   against Aaronson-Ambainis Conjecture 1.7 / Conjecture 6
   (arXiv:0911.0996v3).
2. Variance: PrintedConjecture states variance as
   (sum_X (eval - mean)^2)/2^N >= eps with the uniform
   mean; check it, and totalDegree <= d, against the
   conjecture's definitions.
3. The explicit bound must imply the (eps/d)^7 form on the
   claimed range (eps in (0,1], d >= 1); check the
   implication, not just the headline.
4. Conditional leg: under ST-5, the fourth theorem grades
   only through comparator coverage, the trusted base, or
   a sibling claim's passed kernel tier at the exact
   commit, because FbsDegreeBound is unformalized.
5. Paper sections 1.3, 1.4, 1.5, 9 and the examples have
   no Lean counterpart; any claim resting only on them is
   outside the formalization.

## Resource envelope (forge design constraint)

README figures: `make replay` used 173 GB with Lean's
default parallelism on 8 cores (one task about 7 GB);
`LEAN_NUM_THREADS=1 make replay` used 7.4 GB and took 11
minutes; `make replay-fresh` needs about 9 GB. Our heavy
lane is a desktop WSL guest capped at 27 GiB; the CFSG
comparator build OOM-killed its runner on 2026-11-12 at
about 24 GB RSS, and the box now runs at 2 processors to
bound build memory. The authors' low-memory figures cover
their replay only. Our forge (own build, empty-environment
comparator, axiom closure, ST-1 to ST-5 probes) is not yet
designed or budgeted; that design is the gate for the
audit-queue decision at CFSG close-out.

## Queue status

Registered as CLAIM 2026-11-13. Audit NOT queued. The
queue decision (this claim vs subexponential factoring,
per the 2026-11-06 execution order) is taken at CFSG
run 10 close-out. The Yang-Mills registration of
2026-11-12 (incoming/yang-mills-openai-20261028) stands
queued behind this claim wherever it lands. No forge at
registration; no verdict.
