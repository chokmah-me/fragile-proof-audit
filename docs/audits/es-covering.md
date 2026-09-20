# Audit note — Erdős–Straus covering (Phase 2(e))

**Claim artifact:** Miguel Angel Lopez, *A Complete Congruence System for the
Erdős–Straus Conjecture*, arXiv:2404.01508.  
**Campaign objects:** `docs/blueprint/es-covering.md`,
`scripts/gates/es_cover.py`, `results/es_cover_gate_meta.json`,
`incoming/erdos-straus-2404.01508.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Conjecture 1: every prime admits Type A (`p ≡ −4d (mod 4dn−1)`) or Type B (`p ≡ −n (mod 4dn−1)`) |
| **Instance** | Hard Mordell classes `p ≡ r (mod 840)`, `r ∈ {1,121,169,289,361,529}`, primes `< 10^5` |
| **False instance** | **None in this sweep.** All 27 hard-class primes `< 10^4` and all 273 `< 10^5` are covered; constructive `(x,y,z)` satisfy `4/p = 1/x+1/y+1/z` |

**Verdict: PASS (escalate) on the Type-A/B covering route. Type G not attempted.**
Gates refute routes; a pass does **not** prove ESC and must not be forced into
a kill. No Lean `not_covered` scaffold.

Scope note: the paper does not claim to prove ESC. Its abstract states it
*conjectures* that every prime has a Type A or B solution. 2(e) therefore had
no proof-of-ESC claim to kill; what the gate actually certifies is the
**implication** direction (Theorems 4 and 7) on each instance.

## What was gated

- Type A / Type B congruence search within the paper’s `d ≤ ⌊(p+3)/8⌋` bound.
- Harness: every reported witness rebuilds an Egyptian triple and checks the
  integer identity `4xyz = p(yz+xz+xy)`.
- Side check: Appendix II odd-`k` automatic fold (`d=u=1`, `v=2`) holds on a
  slab of odd `k`. All six hard residues are `≡1 (mod 8)`, so `k` is even and
  that fold never covers the gate universe.

## Known A/B split (sanity, matches paper)

- `193`, `2521`: Type B only (no Type A) — recovered.
- `83449`: Type A only in our search — recovered.

## Lean

None. PASS → escalate. Do not claim ESC; do not scaffold a counterexample module.

## Not done, on purpose

Did not invent extra families beyond Conjecture 1. Did not run Type C
(Conjecture 2) as a required cover. Did not widen past `10^5` in this landing
(paper’s own check goes to the 10 000th prime ≈ `104729`; our hard-class
`< 10^5` sweep is the campaign contract).

---

## Gate re-audit (2026-09-20) — audit the auditor

Three false-negative mechanisms were tested against this gate. Harnesses:
`scripts/gates/es_cover.py` (unchanged) plus a negative control run off-tree.

### 1. Does the gate over-search relative to Conjecture 1? **No.**

Conjecture 1 as printed quantifies `exists d, n in N` with **no bound on either**.
The gate's `d <= floor((p+3)/8)` comes from Propositions 1 and 3 (which bound
where solutions can live) and is therefore a *restriction*, not an expansion.
The suspected "gate searches a wider family than the conjecture" defect does
not exist. Resolved in the paper's favour.

### 2. Does the covering check have discriminating power? **Coverage: none. The Egyptian harness: total.**

Matched control: `scripts/controls/es_cover_control.py`.

The first attempt at this control was **not matched** -- its perturbed search
enumerated `n` more broadly than `find_type_A`'s divisibility rearrangement, so
"a perturbed congruence also covers everything" could have been an artefact of
extra search breadth. The control now runs every variant, true and perturbed,
through one generic complete search parameterised by the congruence's own
arithmetic. Equivalence is verified rather than assumed: the generic search
reproduces `find_type_A` / `find_type_B` with **0 disagreements** over the
hard-class primes below both `10^4` (n = 27) and `10^5` (n = 273). Breadth is
therefore identical by construction and only arithmetic content varies.

Hard-class primes `< 10^4`, full witness enumeration:

| variant | covered | mean witnesses/p | median min `d` | Egyptian-valid |
|---|---|---|---|---|
| **A real** `(4dn-1) \| (p+4d)` | **26/27** | **5.3** | **2** | **100.0 %** |
| A `(4dn+1) \| (p+4d)` | 27/27 | 26.1 | 1 | 0.0 % |
| A `(4dn-3) \| (p+4d)` | 27/27 | 9.3 | 1 | 0.0 % |
| A `(3dn-1) \| (p+4d)` | 27/27 | 9.8 | 1 | 0.0 % |
| A `(4dn-1) \| (p+4d+1)` | 27/27 | 9.9 | 1 | 0.0 % |
| A `(4dn-1) \| (p+3d)` | 27/27 | 8.4 | 1 | 0.0 % |
| **B real** `(4dn-1) \| (p+n)` | **25/27** | **7.5** | **2** | **100.0 %** |
| B `(4dn+1) \| (p+n)` | 27/27 | 15.2 | 1 | 0.0 % |
| B `(4dn-1) \| (p+2n)` | 27/27 | 11.8 | 1 | 0.0 % |
| B `(4dn-1) \| (p+n+1)` | 27/27 | 12.1 | 1 | 0.0 % |

Union coverage under the same matched search: `real A or real B` = 27/27, and so
is every perturbed pairing tried (`m+1`, `tgt+1`, `3dn`/`tgt2n`). Repeated at
`10^5` (first witness only): real A 271/273, real B 270/273, **every** perturbed
variant 273/273, Egyptian-valid still 100 % against 0.0 %.

Three conclusions. The first two correct what this note previously said:

1. **Coverage carries no information.** Every perturbed congruence covers *more*
   primes than the real one. "Conjecture 1 holds on all 273 hard-class primes"
   is therefore not evidence about Conjecture 1 -- a two-free-parameter
   divisibility condition of that shape is satisfiable almost regardless of its
   content. The earlier "weakly discriminating" reading was too generous.
2. **The real congruence is the *tighter* condition**, not the looser one --
   fewer witnesses per prime (5.3 / 7.5 against 8.4-26.1) and a larger least
   `d`. That is the opposite of what "it passes because it is easy to satisfy"
   would predict, and it withdraws the earlier suggestion that the shape of the
   condition was doing the work.
3. **The Egyptian harness separates perfectly.** Feeding each witness through
   the paper's own Theorem 4 / Theorem 7 constructions yields a valid
   `4/p = 1/x + 1/y + 1/z` for **100 %** of true witnesses and **exactly 0 %**
   of perturbed witnesses, across every variant and every witness examined.
   Not a low rate -- zero.

The load-bearing content of this gate was never the covering statistic; it is
`egyptian3`, and that part discriminates perfectly. 2(e)'s PASS stands and is
better understood: it certifies **Theorems 4 and 7** (the implication), not
Conjecture 1 (the existential) -- exactly as the scope note above states.

Reproduce with `python scripts/controls/es_cover_control.py 10000` (~3 s) or
`... 100000` (~5 s, first witness only). It is an audit instrument, not a gate:
it issues no verdict and is deliberately not registered in `check.py`.

### 3. Is the odd-k side check real? **No — it is a tautology.**

`odd_k_automatic_fold` hardcodes `d, u, v = 1, 1, 2`. Every one of its branches
holds identically for every odd `k`:

| check | why it can never fail |
|---|---|
| `(k+d) % u` | `u = 1`, so `x % 1 == 0` always |
| `(k+d) % v` | `v = 2`, `k` odd, so `k+1` is even always |
| `(u+v) % (4d-1)` | `3 % 3 == 0` always |
| `a*y*z == b*(y+z)` | `y = k+1`, `z = (k+1)/2` gives `3(k+1)^2/2` on both sides |
| `egyptian3(...)` | follows identically from the line above |

It nevertheless gates the BREAK verdict (`es_cover.py`, the `not odd_k["ok"]`
branch). It contributes false assurance and should either be demoted out of the
verdict or replaced with a check that can fail. **Not changed in this pass** —
flagged for an explicit decision.

### Attack types not run

Type **G** (logical-gap). Nothing here examines whether the paper's own
reduction closes; only Type-D-style instance checking was performed.
