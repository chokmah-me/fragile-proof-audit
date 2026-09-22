# Audit note — Sárközy's mod-`p` sum-product conjecture (Track D#3)

**Claim artifact:** Sárközy, 2001 list of unsolved problems, **Conjecture 65**.
**Refutation artifact:** Tang, Q., arXiv:2603.29992v2, Theorem 2.2.
**Campaign objects:** `docs/blueprint/sarkozy-sum-product.md`,
`scripts/gates/sarkozy_sum_product.py`,
`scripts/controls/sarkozy_break_control.py`,
`results/sarkozy_sum_product_gate_meta.json`,
`results/sarkozy_break_control_meta.json`,
`incoming/sarkozy-tang-2603.29992.pdf`.

> **This is the one Track D target where the campaign got something wrong and
> had to correct it.** The verdict never changed; the statement being refuted
> did. Read "The transcription failure" below before citing anything here.

## Bug report (lemma · instance · false instance)

For `A ⊆ 𝔽_p` write `A* = (A+A) ∪ (AA)`.

| Field | Content |
|---|---|
| **Lemma** | ∃ `c > 0`, `p₀`: for every prime `p > p₀` and every `A ⊆ 𝔽_p` with `\|A\| > (½ − c)p`, `𝔽_p^× ⊆ A*` |
| **Instance** | `\|A\| = (p−1)/2`, exhibited for every prime tested |
| **False instance** | At `p = 2003`: `\|A\| = 1001`, density `0.499750`, and `1 ∉ A*` — refuting every `c > 0.00025` |

**Verdict: BREAK.** Attack type **F**.

## The transcription failure

Until 2026-09-21 this gate recorded the conjecture as
"`|A| ≥ c·p` forces `1 ∈ A*`". That is not Sárközy's conjecture. The real
threshold is `|A| > (½ − c)p` — a density just *below* one half, not an
arbitrarily small one.

The difference is not cosmetic. Under the misstatement the "conjecture" is
refuted by any small set, so the BREAK was vacuous. Under the true statement a
witness of size `(p−1)/2` is exactly decisive, because `(p−1)/2 > (½ − c)p`
as soon as `p > 1/(2c)`.

Two things let it through:

1. **No PDF was pinned.** The statement came from
   `corpus/live-fragile-proofs-2024-2026.md`, whose Sárközy section has every
   threshold replaced by an `![][imageNN]` placeholder. The corruption was
   resolved the wrong way — and that section contradicts itself about it, since
   its "Core Claimed Theorem" bullet correctly says "density slightly **below**
   ½".
2. **The control checked the gate against the same corpus text.** It passed
   because both said the same wrong thing. *A control that shares its source
   with the gate it audits is not an instrument; it is an echo.* That lesson is
   now doctrine in `docs/GATE-BEFORE-PROVE.md`.

## What is gated now — two independent paths

**Path A — exhaustive search, no input from Tang.** Every size-`(p−1)/2`
subset of `ℤ/pℤ` is tested directly for `p ∈ {5,7,11,13,17,19}` (`--deep` adds
23). Witnesses exist at every prime. Three separate `avoids_one`
implementations (pairwise early-exit, materialised sumset/productset, and an
`O(|A|)` involution test) are cross-checked against each other on every subset
examined.

**Path B — Tang's actual construction**, now that the PDF is in hand. Build the
graph `G` on `𝔽_p` with `u ~ v ⟺ u+v = 1 ∨ uv = 1`, and a loop at `u` iff
`2u = 1 ∨ u² = 1`. Then `A` avoids 1 in both `A+A` and `AA` exactly when `A` is
independent in `G`. The components are `{0,1}`, `{2, ½, −1}`, possibly the
2-vertex component of the roots of `X² − X + 1`, and otherwise 6-cycles
`Ω(x) = {x, 1−x, 1/x, 1−1/x, 1/(1−x), x/(x−1)}` — the classical cross-ratio
orbit. Choosing `0`, `2`, one root if present, and three alternating vertices
per 6-cycle gives `|A| = 1 + 1 + δ/2 + 3(p−5−δ)/6 = (p−1)/2`.

Path B is verified across **29 primes up to 2003**, with every structural claim
re-derived rather than assumed: `δ ∈ {0,2}` matches the Legendre symbol of
`−3`; the 6-cycle count matches `(p−5−δ)/6` exactly; each orbit is confirmed to
be a chordless 6-cycle; `|A| = (p−1)/2` exactly. If the structure failed at any
`p`, the verdict would be `ABORT_TRANSCRIPTION`, not `BREAK`.

Path B is what lets the gate speak about the density the conjecture is actually
about. Path A alone tops out at `p = 19`, i.e. density `9/19 ≈ 0.474`.

## Check that cannot fail — removed

`density_below_half` was a conjunct of the verdict, and the comment three lines
above it *said it could not fail* for `k = (p−1)//2`. Removed from `ok` and
kept as an assertion — the same fix `es_cover` received.

## Control

`scripts/controls/sarkozy_break_control.py` — **NO FALSE POSITIVE**, rebuilt.

1. Transcription: the paper's Section 2 structure re-derived from scratch at 11
   primes (not paraphrase-matched).
2. Discrimination: `avoids_one` correctly rejects the full set `ℤ/pℤ` at every
   prime, and random subsets at the witness density mostly *fail* — it is not a
   tautological accept.
3. Algebraic self-consistency: the gate's three `avoids_one` paths agree.
   (This check earned its keep during the re-audit: it caught a meta-schema
   change the moment the gate was restructured.)
4. Independent corroboration: **replaced.** It had been testing whether
   quadratic residues also avoid 1 — a family Tang never claimed exhibits the
   phenomenon, so its negative result at every prime was uninformative, and
   reporting it as "weakened corroboration" overstated what had gone wrong. It
   is now Tang's **Proposition 2.1** (`|A| > p/2 ⟹ A+A = 𝔽_p`), the sharpness
   half of the paper, which shares no machinery with the counterexample — plus
   the boundary: at `|A| = (p+1)/2` **no** set avoids 1, confirming `(p−1)/2`
   is extremal rather than arbitrary.

## Lean

**Landed 2026-09-22.** Not built from scratch: Tang's own public Lean 4
formalization (`https://github.com/QuanyuTang/Lean-files/blob/main/UPNT65.lean`,
built with Aristotle plus human review by Wouter van Doorn) was fetched,
checked against the pinned PDF's claimed theorem names (`sumset_eq_univ`,
`exists_large_avoiding_set`, `sarkozy_conjecture_false`, `exact_extremal_value`
— all present and matching), and ported verbatim into
`FragileProofAudit/Sarkozy/UPNT65.lean`. Their environment
(`leanprover/lean4:v4.28.0`) is older than this campaign's pin
(`v4.32.2`); it compiled against our mathlib with **zero errors** on the
first attempt and only one deprecation warning (`push_neg` → `push Not`,
fixed). One declaration (`private lemma prime`) had to lose its `private`
modifier — this campaign's `axiom_audit.py` resolves declarations by
fully-qualified name and cannot see through Lean 4's private-declaration
name mangling; everything else needed no changes. `lake build` +
`#print axioms` on all three top-level theorems: **axiom-clean**
(`propext`, `Classical.choice`, `Quot.sound` only), no `sorry`, no
`native_decide`. Registered via `FragileProofAudit.lean`; `verify.ps1`
reports **VERIFIED**, 184 declarations project-wide.

This proves the **full generality** of Sárközy's Conjecture 65/1.1 being
false — `sarkozy_conjecture_false` is quantified over every `c > 0` and
`p₀`, not the finite prime list the Python gate spot-checks — plus the
sharp threshold (`exact_extremal_value`: `(p−1)/2` is the true extremum,
not merely an achievable value). The Python gate above remains the
independent, from-scratch cross-check (two unrelated computational paths,
no shared machinery with this proof); this Lean scaffold is a *third*,
independent confirmation, not a replacement for either.

## Not done, on purpose

The gate exhibits witnesses for the primes listed; "no `c > 0` survives" is
Tang's theorem, quantified over all odd primes, not this computation. The meta
records that distinction explicitly in `computed_scope_note` rather than
letting the `lemma` field imply more than was run — the earlier meta did imply
more, and that is also fixed.
