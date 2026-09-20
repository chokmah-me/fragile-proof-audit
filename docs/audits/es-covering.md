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

### 2. Does the covering check have discriminating power? **Weakly.**

Negative control, hard-class primes `< 10^4` (n = 27):

| population / congruence | covered |
|---|---|
| real congruence, primes | 27/27 |
| real congruence, hard-class **composites** (n = 44) | 23/44 |
| perturbed `m := 4dn+1`, primes | 27/27 |
| perturbed target `-4d+1`, primes | 27/27 |

The composite rate shows the condition is **not vacuous**. But two deliberately
wrong congruences cover the prime set just as completely, i.e. much of the work
is done by the *shape* of a two-free-parameter divisibility condition rather
than by its specific content. **Caveat:** the perturbed searches brute-force `n`
over a wider range than `find_type_A`'s divisibility rearrangement, so this is
suggestive, not matched. A matched control is the outstanding item.

Consequence for language: "Conjecture 1 holds for 273 hard-class primes" is
low-information on its own. The load-bearing content of this gate is the
constructive `egyptian3` re-derivation of each witness, which exercises
Theorems 4 and 7 rather than the conjecture.

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
