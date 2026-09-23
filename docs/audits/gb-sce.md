# Audit note — Goldbach semi-continuous (S.C.E.) model (arXiv:1909.13230v5)

**Claim artifact:** Aref Zadehgol Mohammadi & Mohsen Kolahdouz,
arXiv:1909.13230**v5** (revised 19 May 2026), pinned at
`incoming/gb-sce-1909.13230v5.pdf`
(SHA-256 `2382574230986728c283eae89cc09285376be2764152c07c5e668f1862069c14`,
912,076 bytes, fetched 2026-09-23).

**Campaign objects:** `scripts/gates/gb_sce.py`
(registered in `scripts/gates/check.py` as `gb_sce`, expected verdict BREAK),
`results/gb_sce_gate_meta.json`. No commit made; this note and the gate are
uncommitted working files.

**Verdict: BREAK (route).** The paper's completion of its "relative proof"
rests on three unproven scalar inequalities; the first is false for every
even E by elementary sign (its right-hand side is negative while the
left-hand side is a nonnegative count), and the third is false for
essentially all E > 55, confirmed numerically to E = 10⁸. The authors'
own admission ("we can see these inequalities hold true numerically") is
numerically false for (i) and (iii). Goldbach's conjecture itself is
untouched: gates refute routes, not theorems.

## What the paper claims (verbatim)

Abstract: *"by relative proof we mean that 74 typical structures out of 75
ones satisfy Goldbach's strong conjecture"* and *"we guess theses three
inequalities can be proved the same as to Dusart's inequality."*

Body (§4, p. 14): *"Unfortunately, the authors did their best to prove
analytically these two inequality, but they did not succeed. On the other
hand, we can see these inequalities hold true numerically."*

Structure of the argument: for even E, odd x,y < E with x+y=E (an
"additive interaction" x∼y), the S.C.E. counts (6)–(8)

- b_E = #{x∼y | x≠y, x nonprime, y prime}
- c_E = #{x∼y | x≠y, x prime, y nonprime}
- d_E = #{x∼y | x≠y, both prime} (+ diagonal term; see below)

72 of the 75 possible orderings of (a_E,b_E,c_E,d_E) are settled directly;
two of the rest allegedly never occur (Lemma 2.3); the remaining dominant
type d_E<b_E<c_E<a_E (Theorem 4.2, citing an inequality numbered (24) that
does not appear as a displayed equation in the text) needs three unproven
inequalities (p. 14):

1. b_E < E/ln E − (E/2)/ln(E/2), ∀ E ≥ 10
2. c_E < (E/2)/ln(E/2) − 1, ∀ E ≥ 4
3. b_E + c_E < (E/2)/ln E − 1, ∀ E ≥ 2

## What was gated

The gate evaluates (i)–(iii) at 1004 even E (10 ≤ E ≤ 2000 plus
10⁴, 3·10⁴, 10⁵, 3·10⁵, 10⁶, 3·10⁶, 10⁷, 10⁸), with b_E, c_E, d_E computed
exactly from a bytearray sieve to 10⁸ (stdlib only).

A transcription subtlety was resolved before gating and is recorded here
rather than silently absorbed: equations (5) and (8) print a 1/2 whose
placement is ambiguous in the PDF. Two readings were tested against the
paper's own anchors. The correct reading puts the 1/2 on the *diagonal*
term #{x∼x}: it is the unique reading under which (a) Example 2.6
(E=20 → (a,b,c,d)=(0,2,1,2)) reproduces exactly, and (b) the model
identities (11) E/4=a+b+c+d, (12) b+c+2d=π(E)−1, (13) b+c+2a=E/2−π(E)+1
hold exactly at all 1004 tested E. Under this reading d_E is the exact
odd-prime Goldbach partition count (plus 1/2 when E/2 is an odd prime).

## Results

| E | d_E (Goldbach partitions) | b_E | c_E | (i) margin | (ii) margin | (iii) margin |
|---|---|---|---|---|---|---|
| 10⁴ | 127 | 433 | 541 | −477.2 | +45.0 | −432.1 |
| 3·10⁴ | 602 | 889 | 1151 | −993.9 | +407.9 | −586.0 |
| 10⁵ | 810 | 3649 | 4322 | −3927.2 | +298.2 | −3629.1 |
| 3·10⁵ | 3915 | 8234 | 9932 | −8925.7 | +2652.6 | −6273.1 |
| 10⁶ | 5402 | 31558 | 36135 | −33469.7 | +1966.9 | −31502.8 |
| 3·10⁶ | 27502 | 75159 | 86652 | −80061.2 | +18825.0 | −61236.2 |
| 10⁷ | 38807 | 277259 | 309705 | −291198.8 | +14444.2 | −276754.7 |
| 10⁸ | 291400 | 2468921 | 2709733 | −2575051.8 | +110737.3 | −2464314.5 |

Margin = RHS − LHS; negative = inequality violated. d_E agrees with the
known Goldbach partition counts (127, 810, 5402 at 10⁴/10⁵/10⁶), an
independent check of the counting code.

- **(i): violated on 1004/1004 E.** Stronger than the numerics: it is false
  *analytically*. For E > 2, E/ln E < (E/2)/ln(E/2) ⟺ 2·ln(E/2) < ln E ⟺
  E < 4, so RHS(i) < 0 for every E ≥ 4, while b_E ≥ 0 by definition (a
  count). The gate confirms RHS(i) < 0 at all 1004 E (worst margin −0.935,
  i.e. the least-negative RHS). This inequality can never hold — not merely
  unproven but disproven by inspection.
- **(ii): violated at 5 small E** (E=398: c=38 vs RHS 36.59; E=632, 992,
  1412, 1718 with margins −0.10 to −1.41); holds for E > 2525 on the tested
  range. The as-stated universal "∀ E ≥ 4" is false, though the large-E
  regime the authors need is numerically intact here.
- **(iii): violated on 925/1004 E, including all large E** (first violation
  E=12: b+c=2 vs RHS 1.41; margin −2,464,314.5 at E=10⁸). Heuristically
  b_E+c_E − [(E/2)/ln E − 1] ≈ (E/4)·(2/ln(E/2))·(1−4/ln E) > 0 for E > 55,
  so the failure is systematic, not a small-E artifact.

## Discrimination control (matched)

The same instrument, on the same E values, returns Confirm on every true
scalar claim in the paper's foundation — it is not a reversal-generator:

- Dusart's inequality x/ln x ≤ π(x) ≤ 1.2251·x/ln x: confirmed at
  17, 10², …, 10⁸ (the tighter printed constant 1.2251, not the 1.2551 used
  downstream).
- Teeter's inequalities (18), (19): confirmed for every even E ≥ 18 tested
  (Lemma 2.7 is stated for E ≥ 17; E=10 is outside its domain and excluded).
- Model identities (11), (12), (13): hold *exactly* at all 1004 E;
  Example 2.6 reproduces.

The instrument therefore discriminates: it Confirms the paper's proved
scalar lemmas and fires only on the three admitted-unproven inequalities.

## Ancillary findings (not load-bearing)

- **Constant typo:** equations (1)/(2) print Dusart's upper constant as
  1.2251, but most downstream inequalities use 1.2551 (Lemma 2.10's proof
  alternates between the two). The printed 1.2251 bound is the tighter one
  and holds where checked; no load-bearing deduction was found to rely on
  the tighter value, so this is recorded as a typo, not a break.
- **Stale dossier discrepancy:** the corpus's v2-era dossier lists only
  *two* unproven inequalities and claims numerical verification to 10⁷.
  v5 has *three* unproven inequalities, and the "hold true numerically"
  claim is false for (i) and (iii) — the dossier must be refreshed from v5.
- **Missing (24):** Theorem 4.2 cites inequality (24), which does not appear
  as a displayed equation in the extracted text; context indicates it is the
  structural ordering d_E<b_E<c_E<a_E itself. Flagged for the dossier, not
  load-bearing for the gate.
- The abstract's "74 of 75" vs the body's "72 of 75": reconciled — 72 are
  investigated directly, 2 allegedly never occur (Lemma 2.3), leaving the
  dominant type, i.e. 74/75 claimed "relatively proved."

## Disposition

**BREAK (route):** the three-inequality completion of the S.C.E. relative
proof is refuted — (i) is false for all E ≥ 4 by sign, (iii) is false
systematically for large E (numerically to 10⁸), and (ii) fails as stated
at small E. Per campaign doctrine this refutes only the paper's route; the
72 directly-settled structures and the Goldbach conjecture itself are
untouched. The 23/23 verdict lock is extended to 24/24.
