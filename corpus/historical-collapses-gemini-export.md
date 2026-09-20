# Lead: Gemini “historical collapses” export (2026-09-20)

**Trust: lead** — same grade as `lean4-attack-harvest.md`. AI-sourced
runtimes, Lean line-counts, and several citations in the source MD are
untrusted. Identifiers below were web-checked 2026-09-20.

**Source file:**
`C:\Users\Elke Shayna\Downloads\Flawed Mathematical Proofs Investigation.md`

On-disk title: *Forensic Audit of Historically Significant Mathematical
Collapses: A Computational and Formal Verification Perspective*
(159 699 bytes, 312 lines). Gemini-style export: formulas are PNG data-URIs;
two images are missing. Not a readable math source.

The MD copies this campaign’s A–G taxonomy and laptop / Python / Lean
`v4.32.2` constraint, then ranks **already-collapsed historical
conjectures**, not live fragile proofs of true theorems. It omits the live
queue (odd-zeta, Suman, ES, PDN1, RR, Agoh–Giuga, Lamé, Kempe, Tait, γ-Lean,
Kim).

## Filter of the MD’s top 10

| Rank in MD | Target | Type | Real? | Campaign verdict |
|---|---|---|---|---|
| 1 | Borsuk / Grinsztajn 2026 dim 63 | F | Yes | **Pinned** — see `docs/blueprint/borsuk-63.md`. Author verifier, not the MD’s 4.2 s clique. |
| 2 | Keller / Mackey dim 8 | F | Yes | **Do not reopen.** ITP 2026 Lean 4 already closed all dimensions. |
| 3 | Hedetniemi / Shitov 2019 + quantum arXiv:2609.20690 | F | Yes | **Pinned** — see `docs/blueprint/hedetniemi-q.md`. Forge + numerics, not a laptop chromatic-number search. |
| 4 | Mertens / Odlyzko–te Riele | A | Yes | Keep harvest rank 11 (partial slice). Do not promote. |
| 5 | Mersenne 67 | A | Yes | Skip (one-line `norm_num`). |
| 6 | Hirsch / Santos 20-dim | F | Polytope exists | Skip unless an H-rep certificate is pinned. “18 s BFS” is not credible. |
| 7 | Cauchy 1821 sum theorem | G | Yes | Skip (textbook). |
| 8 | Little 1900 knots | F | Historical yes | Skip. Jones equality is not isotopy; `SymPy.physics.knots` is almost certainly invented. |
| 9 | Lebesgue Borel projection | G | Yes | Skip (DST not campaign-ready). |
| 10 | Rademacher withdrawn RH | G (MD said D) | Anecdote | Skip. No manuscript. |

Unranked Type C (WZ) in the MD names no false published certificate. Jana–Karmakar
already survived 630+96 checks. Do not reopen.

## Two surviving 2026 identifiers (web-checked)

1. **Borsuk-63.** Max Grinsztajn, GPT-5.5 Pro assisted, May–Aug 2026.
   GitHub `maaxgrin/borsuk-63-counterexample`. Wikipedia / MathWorld 2026:
   321-point three-distance set in dimension 63, smaller-diameter subsets
   size ≤ 5 ⇒ ≥ 65 parts. Duplicate arXiv:2608.12561 **withdrawn**.
   Checkable object is the author’s `verify_borsuk63.py` (G₂(4) over
   `𝔽₁₆`), not a dumped 321×63 numpy matrix.

2. **Quantum Hedetniemi.** Julius A. Zeiss, arXiv:2609.20690v1 (17 Sep 2026).
   Lean companion
   `JuliusAZeiss/Lean-Verification-and-More-Quantum-Hedetniemi-conjecture`,
   Lean **4.19.0** (not the campaign pin). Headline
   `χ(G×H) ≤ 1538 < 1539 = min(χ_q(G), χ_q(H))`.

Neither target joins `EXPECTED_VERDICT`. They are Track C pins, not resume.

## Discard from the MD on sight

Claimed runtimes (4.2 s, 12 s, 45 s, 18 s LLL) and Lean line-counts are
ungrounded. Junk citations include Google Sports Data, Prove2Me, Palomar
BSCAveraging, Scribd “Magic of The Primes.” Scope “1725–2026” then leads with
Mersenne 1644.
