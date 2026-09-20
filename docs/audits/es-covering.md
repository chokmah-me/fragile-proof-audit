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

**Verdict: PASS (escalate).** Gates refute routes; a pass does **not** prove ESC
and must not be forced into a kill. No Lean `not_covered` scaffold.

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
