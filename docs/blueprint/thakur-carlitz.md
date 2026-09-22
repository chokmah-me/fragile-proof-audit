# Blueprint — Track D#5: Thakur's Carlitz-Wieferich conjecture

**Status:** Numeric gate landed + discrimination control landed, verdict BREAK — no Lean scaffold yet
**Sources:** Thakur, D. S. (2015), "Fermat versus Wilson congruences, arithmetic derivatives and zeta values," Finite Fields Appl. 32 (conjecture) · refutation: D. Niedbala Giraudin (2026), "A counterexample to a conjecture of Thakur on Carlitz-Wieferich primes," arXiv:2607.15305v2 [math.NT]
**Corpus pointer:** `corpus/live-fragile-proofs-2024-2026.md` (Section 1, "Thakur's Carlitz-Wieferich Primes Conjecture")
**Local PDF pinned:** `incoming/thakur-carlitz-2607.15305.pdf` (sha256 `a37e5696f40953ef8b77e020a60fe5f38cd4d6b60142540bb17a22c1e9f49591`), fetched 2026-09-21 via `curl -sL https://arxiv.org/pdf/2607.15305`. **This target's corpus-doc narrative was unusable** — the explicit quintic polynomial and field data are referenced only through numbered inline images (`[image67]`, `[image68]`, ...) never transcribed by the AI deep-research export, same failure mode as Tang-Zhang. Gate built directly from the pinned PDF's Theorem 1.1 and Appendix A, not from the corpus doc.
**Attack type:** A (Scalar-Gate) / F (explicit counterexample)

## Claim

Let `A = F_q[T]`, `q` a power of an odd prime `p`, `[n] = T^{q^n} - T`, `rho` the
Carlitz module. A monic prime `P` of `A` is a *c-Wieferich prime* (to base 1)
if `rho_P(1) = 1 (mod P^2)`. Thakur (2015) proved no c-Wieferich prime of
degree 2 or 3 exists in odd characteristic and, from this plus limited data,
suggested that **every c-Wieferich prime of `A` has degree divisible by `p`**
in odd characteristic. Bamunoba–Bergström (2021) computed extensively and
stated belief the conjecture holds; Thakur restated it as open in 2024.

## Load-bearing lemma chain

The implicit inductive extrapolation from proofs at degree 2 and 3 (plus an
exhaustive-search absence of counterexamples at those degrees and some higher
ones over prime fields) to all degrees and all odd characteristics — with no
structural reason offered for the pattern to continue past degree 4.

**Break point:** degree 5, `q = 19^3`. Over `F_{19^3} = F_19[c]`, `c^3 =
8c^2+4c+11`, the explicit quintic (Theorem 1.1 of the pinned PDF)

```text
P(T) = T^5 + (11+17c+9c^2)T^4 + (3+7c+18c^2)T^3 + (2+5c+6c^2)T^2
       + (3+3c+11c^2)T + (6+17c+5c^2)
```

is irreducible and c-Wieferich, and `19` does not divide `5`. The paper
further shows (Theorem 5.1, in the companion paper, not re-derived here)
degree 4 is impossible in any odd characteristic, so 5 is the minimal
counterexample degree. The counterexample was found by a systematic method
(companion paper), not a search — the candidate space (`~3e18` monic
quintics, or `19^12 ≈ 2.2e15` in the reduced parametrization) is far beyond
exhaustion.

## Numeric gate

`scripts/gates/thakur_carlitz.py`, built on a from-scratch pure-Python
finite-field engine `scripts/harness/finite_field.py` (no `galois`/Sage/PARI
available on this laptop — `requirements.txt` pins only `mpmath`/`sympy`).

- Builds `F_{19^3}` (elements as length-3 `F_19`-coefficient tuples reduced
  mod `c^3 - 8c^2 - 4c - 11`) and the polynomial ring `F_{19^3}[T]/(P)` from
  first principles: exact modular polynomial multiply/divide/gcd, field
  inversion via Fermat (`a^{q-2}`), and Frobenius powers via square-and-
  multiply.
- **Irreducibility**: standard distinct-degree test for prime degree 5 —
  `T^{q^5} ≡ T (mod P)` (equivalent to `P | [5]`, Lemma 2.2) and
  `gcd(T^q - T, P)` has degree 0 (no root in `F_q`, so no linear factor).
  Both computed by iterated Frobenius (`T`, `T^q`, `T^{q^2}`, ...,
  `T^{q^5}` mod `P`), not copied from the paper's claim.
- **c-Wieferich condition**: `M_5(theta) = 0` for `theta` a root of `P`
  (Lemma 2.1 of the paper — equivalent to definition (1) via `rho_P(1) ≡ 1
  (mod P^2)`), checked by **two independently coded formulas**: the paper's
  nested form (eq. 2, `M_d(theta) = 1 - y_{d-1}(1 - y_{d-2}(...(1-y_1)...))`)
  and the raw alternating-sum definition (`M_d = sum_k (-1)^k [d-1]...[d-k]`)
  applied directly to `y_j = theta^{q^j} - theta`. Both required to vanish
  and required to agree — a from-scratch cross-check against a coding bug,
  not a re-derivation of the same formula (mirrors the Path A/Path B split
  used for `tang_zhang_schatten`).
- Verdict: **BREAK** — irreducible, both `M_5` paths agree and vanish,
  degree 5, `19 ∤ 5`. Runtime <0.2s.
- Meta: `results/thakur_carlitz_gate_meta.json`; registered in
  `scripts/gates/check.py` (`EXPECTED_VERDICT["thakur_carlitz"] = "BREAK"`).
- **Not gated**: Theorem 4.1's closed form `G = μ(T^q-T)` for the product of
  all `q` translates, Conjecture 4.2 (`gcd([5],M5) = G` exactly), Theorem 5.1
  (degree-4 impossibility, proved in the companion paper), and Proposition
  5.2's prime-field exhaustive table beyond the two positive-control cells
  reused by the discrimination control below. Gates refute routes, not full
  papers.

## Discrimination control

`scripts/controls/thakur_break_control.py` — **required and landed**
(BREAK-verdict, witness-by-construction shape, per the register in
`docs/GATE-BEFORE-PROVE.md`).

1. **Positive controls** — the same generic engine, at *different* `(p,
   degree)` pairs than the target, correctly identifies two independent
   known c-Wieferich primes from the paper's own calibration set: `T^5+4T+1`
   over `F_5[T]` (prime field, `(d,p)=(5,5)`) and Bamunoba–Bergström's
   `T^6+T^4+T^3+T^2+2T+2` over `F_3[T]` (`(d,p)=(6,3)`, a case where the
   conjecture's divisibility *does* hold — `3 | 6`). Both come back
   `is_c_wieferich = True`. If the engine could only ever say "not
   c-Wieferich" — a always-False detector — these would fail.
2. **Negative controls** — 10 random monic irreducible quintics over `F_19`
   (prime field, same characteristic as the target): **0** register as
   c-Wieferich. Demonstrates the `M_5(theta)=0` check does not fire on
   everything.
3. **Lemma 2.3 re-verification** — `[j](a) = a^{p^j} - a = 0` for every
   `a` in the prime field `F_19` and every `j >= 1`, confirmed by direct
   modular exponentiation rather than assumed — this is the operational
   content behind the paper's "`gcd([d],M_d)` has no linear factor" claim.
4. **Transcription** — the gate's hardcoded `P` and extension modulus
   (leading coefficient, constant term, characteristic, `q`) match the
   blueprint's transcription of the pinned PDF's Theorem 1.1.

Verdict: **NO FALSE POSITIVE**.

## Formalizable slice

Not started. Candidate shape, following the corpus doc's suggested (but
unusable, image-corrupted) Lean statement, corrected against the actual PDF:

```lean
theorem thakur_carlitz_false :
    ∃ (P : Polynomial (GaloisField 19 3)),
      Irreducible P ∧ P.natDegree = 5 ∧
      IsCarlitzWieferich P ∧ ¬ (19 ∣ P.natDegree)
```

Needs: a Lean/mathlib formalization of the Carlitz module and the
c-Wieferich condition (likely absent in mathlib v4.32.2 — not checked;
mathlib has `GaloisField` and finite-field polynomial irreducibility
machinery, but the Carlitz-module structure is specialized function-field
number theory), plus either `decide` over the exact finite computation (the
whole gate is fully decidable/finite — `F_{19^3}` and `F_{19^3}[T]/(P)` are
finite rings, so in principle `decide` or `native_decide`-free exhaustive
evaluation could certify this, but `native_decide` is banned by this
campaign's Lean discipline and plain `decide` over a `19^3`-element field's
quintic-polynomial arithmetic is likely far too slow to kernel-check).
Substantially harder than Cohen/Baste/Sárközy, comparable to Tang-Zhang; not
attempted.

## Fill checklist

- [x] Numeric gate (`scripts/gates/thakur_carlitz.py`, verdict BREAK)
- [x] Registered in `scripts/gates/check.py` with pinned `EXPECTED_VERDICT`
- [x] Discrimination control (`scripts/controls/thakur_break_control.py`, NO FALSE POSITIVE)
- [x] Local PDF pin under `incoming/` for arXiv:2607.15305
- [ ] Lean scaffold — likely blocked on mathlib Carlitz-module coverage and/or `decide` performance over `F_{19^3}[T]/(P)`, not attempted
- [ ] Audit note under `docs/audits/thakur-carlitz.md`
