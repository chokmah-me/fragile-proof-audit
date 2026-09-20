# Blueprint — Phase 2(e): Erdős–Straus covering (arXiv:2404.01508)

**Status:** extract + gate complete — **PASS (escalate)**; no Lean kill  
**Claim artifact:** Miguel Angel Lopez, *A Complete Congruence System for the
Erdős–Straus Conjecture*, arXiv:2404.01508 (v3 HTML / PDF pin below)  
**Attack type:** F (counterexample search) on a **live** covering claim  
**Local PDF:** `incoming/erdos-straus-2404.01508.pdf`  
**Gate:** `scripts/gates/es_cover.py` → `results/es_cover_gate_meta.json`

## Claim (quoted)

Erdős–Straus: for every integer `n ≥ 2`,

```text
4/n = 1/x + 1/y + 1/z
```

has positive-integer solutions. Mordell’s classical identities leave only the
hard residue classes

```text
p ≡ r (mod 840),  r ∈ {1, 121, 169, 289, 361, 529}
   = {1², 11², 13², 17², 19², 23²}
```

(Introduction; all six are quadratic residues mod 840, so no single polynomial
identity can cover them.)

The paper defines **Type A** and **Type B** solution shapes and conjectures that
every prime falls into at least one:

> **Conjecture 1.** Let `p ∈ ℕ` be prime. Then there exist `d,n ∈ ℕ` such that
> `p ≡ −4d (mod 4dn−1)` or `p ≡ −n (mod 4dn−1)`. If this is true, then this
> congruence system covers all primes and the Erdős–Straus conjecture is true.

(Optional extension Conjecture 2 adds Type C: `p ≡ −4d² (mod 4dn−1)`. The
campaign gate targets Conjecture 1 only.)

The abstract frames the system as one “for which there are always solutions …
and which we **conjecture** to include all prime numbers.” Title language
(“Complete Congruence System”) is stronger than the body.

## Quoted families

### Type A (Definition 3 + Theorem 7)

Solution shape `(du, dv, duv)`. For prime `p`, equivalent to existence of
`d,n ∈ ℕ` with

```text
p ≡ −4d  (mod 4dn − 1)
```

When `p = 4k+1`, Theorem 1 gives the divisor form: exists `t ≥ 0` and a divisor
`w` of `k+1+t` with `w ≡ −1 (mod 3+4t)`. Bound (Prop. 1): `d ≤ ⌊(p+3)/8⌋`;
`t ∈ [0, ⌊(k−1)/3⌋]` (Prop. 2).

Constructive coordinates (after Theorem 1):

```text
u = (1 + n p) / (4 d n − 1),   v = n p
```

(with the denominator dividing the numerator under the congruence).

### Type B (Definition 4 + Theorem 4)

Solution shape `(duv, du p, dv p)`. Equivalent to existence of `d,n ∈ ℕ` with

```text
p ≡ −n  (mod 4dn − 1)
```

When `p = 4k+1`, Theorem 6: exists `t ≥ 0` and positive `a,b` with
`ab | (k+1+t)` and `a+b = 3+4t`. Same `d`-bound (Prop. 3).

Constructive coordinates (Theorem 4):

```text
u = (p + n) / (4 d n − 1),   v = n
```

### Hard-class note

Every hard residue above is `≡ 1 (mod 8)`, so `k = (p−1)/4` is **even**. The
Appendix II “automatic” odd-`k` fold (take `d = u = 1`, `v = 2` so that
`4d−1 | u+v`) never fires on these classes — that is why Mordell left them open.

### Paper’s experimental claim

Conjecture 1 “has been experimentally verified … for any prime number less than
or equal to 104729” (first 10 000 primes). Known A-only / B-only examples cited
in-text: `193`, `2521`, `66529` (B without A); `23929` (A without B);
`83449` (A, only two Type-II solutions).

## Gate contract

1. Exact integer arithmetic only (no floats).
2. Universe: primes `p < LIMIT` in the six hard classes mod 840.
   First pass `LIMIT = 10^4`; widen to `10^5` if clean.
3. For each such `p`, search Type A and Type B within the paper’s `d`-bound.
4. **BREAK** on the first uncovered prime (log `p`, class, search bounds).
5. **PASS** if every hard-class prime in range is covered — **escalate**, do not
   force a kill. Do not claim ESC.
6. Side check (not the covering gate): verify the odd-`k` automatic fold
   algebraically for a slab of odd `k`.

## Abort

If Type A / Type B cannot be transcribed into an executable checker from the
quoted congruences → **BREAK underspecified** (same treatment as 2(d)). Do not
invent families.

## Lean policy

- BREAK → witness prime + `not_covered` lemma; do **not** claim ESC is false.
- PASS → stop; escalate. No Lean kill scaffold.
