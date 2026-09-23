# Pólya's counterexample — certificate canonization (not a refutation)

**Corpus source:** `corpus/fragile-formalizable-proofs-report.md` §4.4, harvest rank 9.
Ranking table: L(906150257) = +1 | F=6, Fr=7*, R=8 | est. effort 4–8 wk.
Corpus verdict: **"Canonize the certificate."**

**Status:** v1 complete 2026-09-23 — sieve + 91 chunk certs + manifest +
independent verifier + **second independent implementation**, all
cross-validated. This is a trust-anchor artifact in the Gomila mold
(audit PASS); it is **not a BREAK** and does not extend the 23/23 verdict lock.

## 1. The claim and its history

Pólya conjectured in 1919 that the summatory Liouville function

    L(n) = Σ_{k=1}^{n} λ(k),   λ(k) = (−1)^Ω(k)

satisfies **L(n) ≤ 0 for all n ≥ 2**. Had it been true, it would have
implied the Riemann Hypothesis *and* the simplicity of all zeta zeros
(Humphries survey, arXiv:1108.1524).

The conjecture is long dead:

- **Haselgrove (1958)** — non-constructive disproof via Ingham's method;
  first counterexample estimated near 1.845×10³⁶¹.
- **Lehman (1960)** — first *explicit* counterexample: L(906,180,359) = +1.
- **Tanaka (1980)** — the *smallest* counterexample: **L(906,150,257) = +1**.

(Note: 906,180,359 is Lehman's, not Tanaka's — the two are easy to confuse;
the corpus report has this right.) The conjecture fails for most n in
[906,150,257, 906,488,079]; L attains its maximum **829 at n = 906,316,571**
(Wikipedia, MathWorld).

This project canonizes Tanaka's smallest counterexample as a pinned,
independently re-verifiable computational artifact — the corpus's
"machine-checked corpse" / permanent warning that small-case evidence is
not a proof.

## 2. What is being certified (success criterion)

A pinned certificate establishing, for the Liouville summatory function:

- **(a)** L(n) ≤ 0 for every 2 ≤ n < 906,150,257, and
- **(b)** L(906,150,257) = +1,

i.e. Tanaka's counterexample recomputed independently of Tanaka/Lehman-era
code, with chunk certificates any third party can spot-verify in seconds.

**Domain scoping.** Every statement is for **n ≥ 2**: L(1) = λ(1) = +1
trivially since Ω(1) = 0. The certificates use the convention
L(n) = Σ_{k=1}^{n} λ(k) with the L(1) = +1 offset carried explicitly
(`L_before` chains from 1). **Minimality requires the full prefix**
[2, 906150257], not just the crossing point — "L(906150257) = +1" alone
does not prove smallest.

## 3. Certificate design

The range [2, 906150257] is split into **91 chunks of 10⁷** (last chunk
short: [900000002, 906150257]). Each `cert_XXXX.json` records:

| field | meaning |
|---|---|
| `lo`, `hi`, `count`, `chunk` | chunk range and index |
| `L_before` | L(lo−1) under the L(1)=+1 convention; must chain across chunks |
| `sum_lambda` | Σ_{k=lo}^{hi} λ(k) |
| `max_prefix` / `argmax_prefix` | max and argmax of the *relative* prefix L(n)−L_before inside the chunk |
| `first_cross` / `L_at_first_cross` / `max_prefix_before_first` | set only in the crossing chunk (90): the first n with L(n)>0, its L value (+1), and the max relative prefix strictly before it |

`certs/manifest.json` pins every cert file by SHA-256
(manifest SHA-256: `a899bfe9959a1e48444ec016517e977e29fa19b73fdcca43071165bc067c0ba7`).

`src/verify_certs.py` proves (a) and (b) **from the certs alone** (no sieve
re-run): manifest checksum pins → chunk contiguity/coverage of [2, N] →
boundary-sum chaining → per-chunk max-prefix gates (no positive L before the
crossing chunk; none inside it before `first_cross`) → the crossing gate
(`first_cross = 906150257`, `L = +1`). **370 checks, all PASS.**

## 4. Implementation 1 — segmented cofactor sieve (C)

`polya/src/liouville_sieve.c` (v1, 2026-09-22/23): clean-room segmented
λ-sieve, integer-only. Number-driven: per-number cofactor array divided down
by small primes, parity flipped per division, p⁻¹ mod 2⁶⁴ division trick for
odd p. `polya/build.sh` runs the full pipeline (compile → anchor validation
→ chunk certs → manifest → verifier).

A real bug was caught here: the 2-adic inverse trick does not exist for p=2,
so factors of 2 were never divided out (L(100000) came out −2074 vs the
brute-force −288). Fixed via ctz-stripping for p=2; re-validated. This is
exactly the class of silent sieve defect the two-implementation rule exists
to catch.

## 5. Implementation 2 — prime-power parity-flip sieve (Python/numba)

`polya/src/liouville_sieve2.py` (2026-09-23): derived **from the recon
brief's mathematics, not from the C source** — the C file was deliberately
not consulted.

It rests on the identity **Ω(n) = #{ (p,k) : k ≥ 1, p^k | n }**: every prime
power dividing n contributes exactly one to the prime-factor count with
multiplicity (e.g. n = 12 = 2²·3 has prime-power divisors 2, 4, 3 → 3 =
Ω(12)). So λ(n) = (−1)^Ω(n) is computed by starting from parity 0 and
flipping one bit for every multiple of every prime power q = p^k ≤ N
(50,847,534 primes + 3,689 higher prime powers at N = 10⁹).

**Independence argument (one line):** implementation 1 is number-driven
(per-n cofactors divided down, parity per division); implementation 2 is
prime-driven (parity flips over multiples of prime powers) with **no
division of n and no cofactors anywhere** — a defect in one's
division/parity bookkeeping cannot manifest in the other.

Environment: Python 3.12.3, numpy 1.26.4, numba 0.67.0. Full 10⁹ run in
**22.7 s** single-core (prime sieve 5.1 s, flips 13.6 s, analysis 3.9 s),
~1.6 GB peak RAM. `--selftest` validates against brute-force trial division
(L(100) = −2, L(1000) = −14, L(10000) = −94, L(100000) = −288, plus
per-λ agreement for all n ≤ 2000).

## 6. Verification results (exact numbers)

Published anchors — reproduced **exactly by both implementations**:

| anchor | impl 1 (C) | impl 2 (Python/numba) | source |
|---|---|---|---|
| L(10⁹) | −25216 | −25216 | OEIS A090410 |
| first n ≥ 2 with L(n) > 0 | 906150257 | 906150257 | Tanaka 1980 |
| max L over [2, 10⁹] | 829 at 906316571 | 829 at 906316571 | Wikipedia/MathWorld |

Chunk-certificate cross-validation (impl 2 vs the v1 certs):
**91/91 chunks agree on all of** `sum_lambda`, `max_prefix`,
`argmax_prefix`; crossing-chunk fields `first_cross = 906150257`,
`L_at_first_cross = +1`, `max_prefix_before_first = 4629` all match.
`verify_certs.py` re-run: **PASS, 370 checks.**

## 7. Reproduction

```bash
cd polya
./build.sh                                   # impl 1: compile, anchors, certs, manifest, verify
python3 src/verify_certs.py                  # cert-only verification (370 checks)
python3 src/liouville_sieve2.py --selftest   # impl 2 small-N validation
python3 src/liouville_sieve2.py --N 1000000000  # impl 2 full run: anchors + chunk stats
```

Pinned inputs: `certs/manifest.json`
(SHA-256 `a899bfe9…0ba7`); all cert files pinned therein.

## 8. Deferred (stretch goals, clearly out of v1 scope)

- **Lean formally-checked sieve slice.** The corpus's long pole (its 4–8 wk
  estimate bundles this); the certificate artifact stands without it.
- **Extended positive-region certs.** Sieve to 906,488,079 to certify the
  full positive interval and the max 829 at 906,316,571 as pinned chunks
  (adds seconds of compute; anchors already confirm the values).

## 9. What this is not

Not a refutation and not a BREAK: the conjecture died in 1958. The 23/23
verdict lock is untouched. Value is the trust anchor — a machine-checked
record of exactly where and how badly "it holds for all small cases"
failed.
