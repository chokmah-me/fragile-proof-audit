# Blueprint — Phase 3(h): Agoh–Giuga genre kit (oracle milestone)

**Status:** oracle extract + gate — **PASS** (Giuga ∧ ¬Carmichael on seven known \(g\))  
**Genre:** claimed proofs that “\(n\) prime ⟺ Agoh / Giuga congruence”  
**Attack type:** finite oracle audit (reusable kit), then per-claim blueprint  
**Gate:** `scripts/gates/giuga_oracle.py` → `results/giuga_oracle_gate_meta.json`  
**Sources:** OEIS [A007850](https://oeis.org/A007850); harvest §3.4
(`corpus/fragile-formalizable-proofs-report.md`); CARMA / Borwein survey;
ProofAtlas Agoh–Giuga collaboration page

## Claim (genre, quoted)

Giuga (1950): \(n\) is prime iff
\(\sum_{a=1}^{n-1} a^{n-1} \equiv -1 \pmod n\).

Agoh reformulation: a Bernoulli congruence characterizes primality
(equivalent to Giuga’s). The conjecture remains open. A composite
counterexample must be simultaneously a **Giuga number** and a
**Carmichael number**.

## Criteria (exact integers)

**Giuga criterion** (composite squarefree \(n\)): for every prime \(p \mid n\),
\[
p \mid \Bigl(\frac{n}{p} - 1\Bigr).
\]
Equivalent form used in literature:
\(\sum_{p\mid n} 1/p - \prod_{p\mid n} 1/p \in \mathbb{N}\)
(all known examples equal \(1\)).

**Korselt / Carmichael:** squarefree composite \(n\) is Carmichael iff for every
prime \(p \mid n\),
\[
(p-1) \mid (n-1).
\]

**Oracle contract:** every listed known Giuga number \(g\) must satisfy
**Giuga ∧ ¬Carmichael**. That is the standing counterexample oracle for the
genre: any claimed proof that “specializes” to a false divisibility at
\(g=30\) or \(g=858\) is located and killed.

Do **not** claim the Agoh–Giuga conjecture. The kit audits *claims*.

## Seventh Giuga number (citation pin)

Harvest spot-check listed six composites. The seventh term of OEIS A007850
(Borwein–Borwein–Borwein–Girgensohn author line; sequence of Giuga numbers) is

\[
432749205173838 = 2 \cdot 3 \cdot 7 \cdot 59 \cdot 163 \cdot 1381 \cdot 775807.
\]

Pinned against OEIS A007850 (terms 1–7) and the Wikipedia / MathWorld lists
that match that prefix. More Giuga numbers are now known (OEIS lists twelve
with ≤8 factors, plus a larger 10-factor example); this milestone gates the
classical seven-term oracle the harvest named, not the full OEIS table.

## Oracle table (pre-gate transcription)

| \(g\) | Prime factorization | Expected |
|---|---|---|
| 30 | \(2\cdot3\cdot5\) | Giuga ∧ ¬Carmichael |
| 858 | \(2\cdot3\cdot11\cdot13\) | Giuga ∧ ¬Carmichael |
| 1722 | \(2\cdot3\cdot7\cdot41\) | Giuga ∧ ¬Carmichael |
| 66198 | \(2\cdot3\cdot11\cdot17\cdot59\) | Giuga ∧ ¬Carmichael |
| 2214408306 | \(2\cdot3\cdot11\cdot23\cdot31\cdot47057\) | Giuga ∧ ¬Carmichael |
| 24423128562 | \(2\cdot3\cdot7\cdot43\cdot3041\cdot4447\) | Giuga ∧ ¬Carmichael |
| 432749205173838 | \(2\cdot3\cdot7\cdot59\cdot163\cdot1381\cdot775807\) | Giuga ∧ ¬Carmichael |

Witness sketch for \(g=30\) (harvest prototype): Giuga checks
\(2\mid14\), \(3\mid9\), \(5\mid5\); Korselt fails because
\((3-1)\nmid 29\) and \((5-1)\nmid 29\).

## Gate contract

1. Exact integer arithmetic only (no floats).
2. For each \(g\): verify product of listed primes equals \(g\), squarefree,
   Giuga criterion holds, Korselt fails (record first failing prime).
3. Emit `results/giuga_oracle_gate_meta.json` with per-\(g\) witnesses.
4. **PASS** = all seven Giuga ∧ ¬Carmichael (oracle ready; escalate to Lean kit).
5. **BREAK** = any listed \(g\) fails Giuga or satisfies Korselt (oracle broken).

## Lean (after green gate; not this landing’s acceptance)

Small `Giuga` / `Korselt` lemmas + finite oracle table as explicit /
`norm_num` witnesses (`decide` / `native_decide`-free preferred). Per new
claimed proof thereafter: blueprint against the kit; instantiate failing
lemma at \(g=30\) or \(g=858\). Optional later: von Staudt–Clausen /
Agoh–Bernoulli bridge.

## Abort

If a “seventh” cannot be sourced with a citable list → gate the six verified
ones, document the gap, do not invent a seventh. (Seventh is sourced: OEIS
A007850.)
