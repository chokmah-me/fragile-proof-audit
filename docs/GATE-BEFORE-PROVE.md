# Gate before prove

Standing rule of this campaign (ported from `catalan-sun-lean`):

> No scaffolded Lean target gets a proof until it has been gated numerically
> (or, for pure logical-gap audits, until the axiom/sorry catalog exists).

## Why

False statements are cheap to spot with a `Fraction`/`mpmath` script and
expensive to discover after a week of Lean. CatalanSun found multiple
statement-level bugs this way. The Jana–Karmakar episode shows the converse:
a **failed** gate is only as good as its harness — so gate code is part of
the artifact and must be self-tested (see `scripts/harness/selftest.py`).

## Protocol

0. **Pin the real paper first.** Live-check the identifier, download the PDF to
   `incoming/`, read it, and record `local_pdf` in the gate's meta. Never gate
   from a corpus doc, an abstract, or an HTML summary. Track D cost this lesson
   four times in one session — three targets whose corpus text was
   image-corrupted, one whose "verifiable gate" was outright fabricated — and
   the three targets gated *before* the lesson had to be retrofitted the next
   day, at which point one of them (`sarkozy_sum_product`) turned out to have
   the conjecture's own threshold wrong.
1. Extract the load-bearing quantity or base case into `docs/blueprint/<target>.md`
   with quotations from the source.
2. Implement `scripts/gates/<target>.py` using `scripts/harness/` conventions
   (including negative-index rising factorials when relevant).
3. **Run the discrimination control** (see below) where one is required. Do not
   record a verdict you have not shown the gate capable of contradicting.
4. Register the gate in `scripts/gates/check.py`, and pin its expected verdict
   in `EXPECTED_VERDICT` so a later flip in either direction fails the run.
5. Write `results/<target>_gate_meta.json`.
6. Only then write or complete the Lean module.
7. Run `pwsh ./scripts/verify.ps1` (gates + forge).

## Language

Gates refute **routes**, not theorems. ζ(5) is probably irrational; FLT is
true. Notes name the lemma chain that died: lemma · instance · false instance.

---

## Discrimination control (required where it bites)

> **A check that cannot fail is not evidence.**
> Before a verdict is recorded, show the gate producing the *opposite* verdict
> on an input where the opposite verdict is the correct one.

This is the third leg of "audit the auditor", alongside shipping the harness
and treating AI-sourced claims as leads. It runs in whichever direction the
gate points:

| gate says | the control asks | instrument |
|---|---|---|
| **PASS** | could it miss a real defect? Perturb the claim and confirm the check rejects the near-miss. | `scripts/controls/es_cover_control.py` |
| **BREAK** | could it fire on a correct paper? Supply a regime where the refuted claim is *true* and confirm the gate declines. | `scripts/controls/break_control.py` |

### Matched, not merely perturbed

The first ES control varied the congruence **and** the search breadth at the
same time, and returned an answer ("weakly discriminating") that a second pass
had to withdraw. A control must hold everything fixed except the single fact
under test, and must **prove** the equivalence rather than assume it:
`es_cover_control.py` verifies that its generic search reproduces the gate's
own `find_type_A`/`find_type_B` with 0 disagreements before drawing any
conclusion. A control that is not matched is worse than none, because it reads
like evidence.

### When it is required

The verdict is an **existence or non-existence claim resolved by search or
sampling**. Such a verdict can be produced by a search that is too narrow, too
broad, or aimed at the wrong object, and none of those failures announce
themselves. Everything the campaign has actually learned this way came from
this class.

### When it is ceremony

The verdict is an **exact equality or divisibility between two independently
computed objects**. Any discrepancy is caught by construction, so discriminating
power is not the open question. What *does* need auditing there is different:
**implementation equivalence** (does a fast path reproduce the exact oracle?
see `pdn1_fastpath_selftest`) and **depth** (is the sample large enough to carry
information? `pdn1` at 81 points was not; at 6 747 it is). Do not spend a
discrimination control to re-prove that exact integer comparison detects
differences.

### Register

| gate | verdict shape | control |
|---|---|---|
| `es_cover` | PASS — existence by parameter search | **required** — `controls/es_cover_control.py` |
| `suman_eq48` | BREAK — witness by construction | **required** — `controls/break_control.py` |
| `odd_zeta_1609` | BREAK — non-existence by sampling | **required** — `controls/break_control.py` |
| `lame_ideal_neg23` | PASS — non-existence by bounded search | **required** — `controls/lame_ideal_control.py` |
| `cohen_subadditivity` | BREAK — witness by construction | **required** — `controls/cohen_break_control.py` |
| `baste_domination` | BREAK — non-existence by exhaustive search (γ≥16) + general bound (γ_e=15) | **required** — `controls/baste_break_control.py` |
| `sarkozy_sum_product` | BREAK — existence by exhaustive search + explicit construction | **required** — `controls/sarkozy_break_control.py` |
| `tang_zhang_schatten` | BREAK — exact rational inequality at one witness | **required** — `controls/tang_zhang_break_control.py` (is the witness typical or extremal?) |
| `thakur_carlitz` | BREAK — witness by construction in F_{19³}[T] | **required** — `controls/thakur_break_control.py` |
| `chung_graham_spiro` | BREAK — non-membership by bounded scan | **required** — `controls/chung_graham_break_control.py` |
| `salez_youssef_logsobolev` | BREAK — asymptotic ratio decay by sampling in `n` | **required** — `controls/salez_youssef_break_control.py` |
| `cat_g` | BREAK — forward difference of a claimed polynomial | **required** — `controls/cat_g_break_control.py` (Apéry ζ(3) zero-count vanishes) |
| `krr_cl` | BREAK — exact integer mismatch of a printed congruence | **required** — `controls/krr_cl_break_control.py` (same-page \(P_g\) formula holds; a shifted telescoping anchor does not) |
| `rr_qexpand` | PASS — exact series equality | ceremony; the classical `(2,3)` anchor already serves |
| `pdn1` | PASS — exact divisibility, 6 747 points | ceremony; the fast-path/oracle self-test serves |
| `giuga_oracle` | PASS — decidable predicates on explicit integers | ceremony |
| `lame_h23` | PASS — computed class number | ceremony; the OEIS pin over 15 primes already serves |

Every control writes `results/<control>_meta.json` via
`scripts/controls/receipt.py`. A receipt is **not** a lock row: nothing fails
CI when one changes. It exists so a "NO FALSE POSITIVE" finding can be re-read
without re-running the instrument — the same standard this campaign demands of
the papers it audits.

`lame_ideal_neg23` control landed 2026-09-20: confirms the search *does*
return solutions for targets where they exist (`32` → `(±3, ±1)`, `24` →
`(±1, ±1)`, `4` → `(±2, 0)`); reproduces `norm_equation_solutions` exactly
against a brute force run at 10x the formula's `b_bound` for seven targets
(no truncation); and shows the `(a − b) % 2 == 0` parity filter is capable of
*accepting* (at target=32, not just rejecting at target=8, where it would be
vacuously true). Verdict: NO FALSE POSITIVE.

`cohen_subadditivity` control landed 2026-09-20: 500 random `(m, n)` pairs
(`1 <= m <= n <= 500`) produced **0** subadditivity violations while the
claimed witness `(31, 3928)` reproduced correctly, so the check is not an
always-BREAK detector; transcription matched a live arXiv-abstract fetch on
all 5 checked markers (no local PDF pinned for arXiv:2607.09793 yet — see
`docs/blueprint/cohen-subadditivity.md`). Verdict: NO FALSE POSITIVE.

`sarkozy_sum_product`, `tang_zhang_schatten`, `thakur_carlitz`,
`chung_graham_spiro` and `salez_youssef_logsobolev` controls landed
2026-09-21, all **NO FALSE POSITIVE**; see each target's blueprint and its
receipt under `results/`.

**Re-audit 2026-09-21 — two controls were echoes, not instruments.** The
`cohen` and `baste` controls "checked transcription" by matching substrings
inside prose the campaign had itself written down: a string compared against
itself, which cannot fail. The `sarkozy` control was worse — it validated the
gate against the corpus doc's paraphrase, and passed, while both said the same
wrong thing (see `sarkozy_sum_product` note below). All three now test the
gate's own objects against an independent second transcription of a pinned
PDF. **A control that shares its source with the gate it audits is not
evidence.**

`sarkozy_sum_product` correction 2026-09-21: the corpus doc stated Sárközy's
conjecture with the threshold `|A| ≥ c·p`. The real Conjecture 1.1 (Sárközy's
Conjecture 65, as quoted in Tang's paper) reads `|A| > (½ − c)p`. Under the
corpus doc's version the claim is refuted by any small set and the BREAK would
have been vacuous; under the true version a witness of size `(p−1)/2` is
exactly decisive. The gate now also implements Tang's actual construction
(Section 2), verified across 29 primes up to 2003 — refuting every
`c > 0.00025` by explicit witness rather than gesturing at an asymptotic.

`baste_domination` control landed 2026-09-20: the gate's own exact
branch-and-bound dominating-set solver was run on K4 (budget=1, found=True),
the Petersen graph (budget=3 → found=True; budget=2 → found=False, correctly
declining below the textbook minimum), and the target graph's own 16-vertex
upper-bound witness (budget=16 → found=True) — so the solver both finds
small dominating sets when they exist and declines when they don't, not an
always-False detector. A real bug (`n = NUM_VERTICES` hardcoded instead of
`n = len(adj)`) was caught the moment the control tried a non-target graph
and is fixed. Verdict: NO FALSE POSITIVE.

### Controls are instruments, not gates

A control issues no campaign verdict and is **not** registered in
`scripts/gates/check.py`. The verdict lock stays a lock on findings; controls
are run by the operator when a target is landed or revisited.

### Track C pins are instruments too

`scripts/gates/borsuk63.py` and the Zeiss Hedetniemi numerics / `axiom_audit.py`
scan live next to the locked gates but are **not** in `EXPECTED_VERDICT`. They
write `results/` receipts. A PASS means the pinned third-party certificate still
runs on this laptop, not that this campaign killed a live proof route. Do not
promote them into the verdict lock. See [`docs/WORKPLAN.md`](WORKPLAN.md)
Track C, [`docs/audits/borsuk-63.md`](audits/borsuk-63.md),
[`docs/audits/hedetniemi-q.md`](audits/hedetniemi-q.md).

### Corollary: never gate on a check that cannot fail

`es_cover`'s `odd_k_automatic_fold` gated the verdict on five branches that are
tautologies in `k` (`u = 1` so `x % 1 == 0`; `v = 2` with `k` odd; `3 % 3`; and
an algebraic identity). It could not have fired under any circumstances. Fixed
2026-09-20: the tautological branches remain as executable documentation, and
the verdict now turns on the failable scope invariant — every hard residue is
`1 (mod 8)`, so the odd-`k` fold never touches the gate universe. When that
invariant fails the verdict is `ABORT_SCOPE`, not `BREAK`: a misconfigured gate
is not a dead route.
