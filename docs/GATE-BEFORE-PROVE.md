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
| `rr_qexpand` | PASS — exact series equality | ceremony; the classical `(2,3)` anchor already serves |
| `pdn1` | PASS — exact divisibility, 6 747 points | ceremony; the fast-path/oracle self-test serves |
| `giuga_oracle` | PASS — decidable predicates on explicit integers | ceremony |
| `lame_h23` | PASS — computed class number | ceremony; the OEIS pin over 15 primes already serves |

`lame_ideal_neg23` control landed 2026-09-20: confirms the search *does*
return solutions for targets where they exist (`32` → `(±3, ±1)`, `24` →
`(±1, ±1)`, `4` → `(±2, 0)`); reproduces `norm_equation_solutions` exactly
against a brute force run at 10x the formula's `b_bound` for seven targets
(no truncation); and shows the `(a − b) % 2 == 0` parity filter is capable of
*accepting* (at target=32, not just rejecting at target=8, where it would be
vacuously true). Verdict: NO FALSE POSITIVE.

### Controls are instruments, not gates

A control issues no campaign verdict and is **not** registered in
`scripts/gates/check.py`. The verdict lock stays a lock on findings; controls
are run by the operator when a target is landed or revisited.

### Track C pins are instruments too

`scripts/gates/borsuk63.py` and the Zeiss Hedetniemi numerics / `axiom_audit.py`
scan live next to the locked gates but are **not** in `EXPECTED_VERDICT`. They
write `results/` receipts. A PASS means the pinned third-party certificate still
runs on this laptop, not that this campaign killed a live proof route. Do not
promote them into the eight-row lock. See [`docs/WORKPLAN.md`](WORKPLAN.md)
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
