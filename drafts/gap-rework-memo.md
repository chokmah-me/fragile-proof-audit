# GAP rework memo — independent re-examination of prose GAP verdicts (2026-09-23)

Branch: `paper`. This memo does NOT edit the paper and is NOT committed.
Standard applied per review: (1) verbatim quotation of the exact failing
sentence/equation/inference with location; (2) independent re-derivation
(not deferring to the existing note); (3) explicit repairability judgment;
(4) evidence relied on, with file/line pointers.

---

## 1. FRK-UC — Demontis union-closed (arXiv:2405.03731v1): GAP REAL, FATAL TO ROUTE

### Verbatim gap

**Location:** Theorem 4, statement (paper p. 6):

> "For all D, it exists i such that if it exists a set Y={Y1;Y2}
> i quasiminimal on D for Y, then 2|(D∪Y)^i|≤|(D∪Y)|+1."

**Location:** Theorem 5, proof, the Theorem-4 invocation (paper p. 7):

> "By Theorem 4, it exists i, not necessarily different from j, such that
> for the set {Xt;Xt+1} i quasiminimal on D_{t−1} for {Xt;Xt+1} and
> 2|(D_{t−1}∪{Xt;Xt+1})^i|≤|D_{t−1}∪{Xt;Xt+1}|+1."

**Location:** Definition 9 (paper p. 6):

> "i is said quasiminimal on D for a set Y={Y1;Y2}⊂F if and only if …"

(All three verified verbatim against https://arxiv.org/html/2405.03731v1,
lines 372–375, 451–452, 350–352 of the rendered text.)

### Independent re-derivation

Two independent defects, both confirmed from the source text:

**(a) Quantifier-scope confusion.** Theorem 4 delivers, at best,
∃i[(∃Y Q(i,D,Y)) → C(i,Y)] — and strictly as written, the Y in the
consequent is not even bound (it is bound only inside the antecedent's
∃Y), so the statement is ill-formed; charitably read with wide ∃Y scope
it is nearly vacuous (satisfied by any (i,Y) with ¬Q(i,D,Y)).
Theorem 5's proof uses it as ∃i[Q(i,D_{t−1},Y₀) ∧ C(i,Y₀)] for the
*specific* Y₀ = {X_t, X_{t+1}}. Nothing licenses this upgrade: the
optimal sequence is built for j (Def 8, Lemma 6), and Theorem 4's i
carries no quasiminimality guarantee for this Y₀. The inference is
invalid as a matter of pure logic, independent of any combinatorics.

**(b) Type error against the paper's own Definition 9.** Quasiminimality
requires Y = {Y1;Y2} ⊂ F. But X_t, X_{t+1} are the last two *deleted*
sets of the optimal sequence A_0…A_{t+1} from A to F (Def 8; Thm 5 proof:
"j belongs to X_{t+1}", "j does not belong to X_t"), hence
{X_t,X_{t+1}} ⊂ D = A−F. "i quasiminimal on D_{t−1} for {X_t;X_{t+1}}"
is ill-typed per Def 9. Confirmed: Def 9's "Y={Y1;Y2}⊂F" vs. the
invocation's Y₀ ⊂ D.

A further unjustified step: "by definition of minimality of j and
quasiminimality of i we have 2|D^j|=2|D^i|" asserts i is minimal on D;
nothing produces such an i (quasiminimality on D_{t−1} for Y₀ ≠
minimality on D).

Theorem 4's proof (Case 1) independently fails: it reasons from the
undischarged hypothesis "If we could choose Y such that i quasiminimal
on D for Y" (paper p. 6: "If we could choose Y … we could do as
follows"), then asserts "By definition i quasiminimal on D_{t−1}" —
false, since quasiminimality is relative to an exhibited Y ⊂ F, none
given — and applies the induction hypothesis (an ∃-statement) as if it
yielded the inequality for *this* i.

### Repairability: FATAL TO THE ROUTE AS WRITTEN

No patch within the paper's machinery works. The type error cannot be
fixed by redefining Def 9 to allow Y ⊂ D: then Def 9(4)'s "optimal
sequence from A to F−Y" degenerates (F−Y = F for Y ⊂ D) and the
inequality collapses toward the conclusion itself. The quantifier defect
cannot be fixed without strengthening Theorem 4 to a uniform statement
(∀D ∀Y₀ ∃i [Q(i,D,Y₀) ∧ C(i,Y₀)]) — which is essentially as hard as
Theorem 5 itself, the theorem it is supposed to serve. A repair would
have to prove the target claim by other means. **Route refuted;
Frankl's conjecture untouched** (Theorem 5's *statement* survives all
checked families: 61/61 on n=3, 2480/2480 on n=4, 300k sampled on n=5 —
`scripts/analysis/frankl_uc_thm5_probe.py`).

### Assessment of the existing note

`docs/audits/frankl-uc-gap.md` is **accurate on all load-bearing points**;
nothing material overstated. (Minor: its Case-2 parenthetical about Def
9(2) is slightly garbled, but the core type-error point it supports is
correct and independently verified above.)

### Evidence relied on

- https://arxiv.org/html/2405.03731v1 (Def 9, Thm 4 statement/proof,
  Thm 5 proof — verified verbatim, line refs above)
- `docs/audits/frankl-uc-gap.md`, `corpus/recon-frankl-uc.md`
- `scripts/analysis/frankl_uc_thm5_probe.py` (exists; statement-scope
  control)

---

## 2. LEG-NS — Ferreira prime gaps (arXiv:2307.08725v4): GAP REAL, NOT PATCH-REPAIRABLE

### Verbatim gap

**Location:** Proposition 2.18 proof, p. 19 (pinned PDF
`incoming/leg-ns-2307.08725v4.pdf`, SHA-256
`4af7b9e1…507f3c64`, verified by `pdftotext` extraction):

> "Since the integral ∫_C Υ(s,z)dz and its derivative (with respect to s)
> converge absolutely and uniformly for s in any compact subset of the
> half-plane ℜ(s) ≥ 0 … it follows from the differentiation theorem under
> the integration sign that the function … is analytic in an open
> neighborhood of the half-plane ℜ(s) ≥ 0."

**Location:** same proof, p. 17 (verbatim):

> "Subtracting 1/s on either side of this equation, we get
> τ(s) − 1/s = (exp(−s)−1)/s − (1−λ)d³/ds³M^{−1}[…]"

from the displayed "τ(s) = 3 − exp(−s)/s − (1−λ)d³/ds³M^{−1}[…]".

**Location:** the paper's own concession, p. 19 (verbatim):

> "On the critical boundary ℜ(s) = 0, the exponential decay of the Gamma
> function exactly balances the growth of the term s^{−z}."

### Independent re-derivation

**Defect A (decisive).** Differentiation under the integral sign
(Morera-based) yields holomorphicity on an *open* set U when convergence
is uniform on compacts of U. Here the compacts are of the *closed*
half-plane {ℜ(s)≥0}, which is not open: the argument gives
holomorphicity on the interior {ℜ(s)>0} only. At a boundary point s₀
(ℜ(s₀)=0), analyticity would require uniform convergence on a
neighborhood of s₀, necessarily containing ℜ(s)<0 points — where the
integral diverges. The conclusion "analytic in an open neighborhood of
the half-plane" is a non sequitur from the premise stated. It is not
merely unproved: along the contour C, |s^{−z}Γ(z)| ∼
|t|^{σ−1/2}exp(t(arg s − π/2)), giving exponential decay for
|arg s|<π/2 (ℜ(s)>0), exact marginal balance for |arg s|=π/2 (ℜ(s)=0),
and exponential *growth* for |arg s|>π/2 (ℜ(s)<0) — the paper's own
"exactly balances" concedes there is no room to cross. Re-ran
`scripts/analysis/leg_ns_contour_probe.py` (exit 0): |s^{−z}Γ(z)| at
t=160 is 5.6e−13 for s=0.1+i, 4.7e−06 for s=i, 3.96e+01 and growing for
s=−0.1+i. The integral representation *cannot* deliver the claimed
extension. Newman's analytic theorem needs the open-neighborhood
extension (its proof shifts contours into ℜ(s)<0), so the defect is
load-bearing.

**Defect B (independently damaging).** From τ(s) = 3 − e^{−s}/s − X,
subtracting 1/s gives τ(s) − 1/s = 3 − (1+e^{−s})/s − X, NOT the paper's
(e^{−s}−1)/s − X (at s=1: 2−1/e vs 1/e−1). False as printed. Moreover,
on the paper's own displayed formula, the corrected algebra gives
τ(s)−1/s = 4 − 2/s − s/2 − ⋯ − X(s) near s=0: a **pole of residue −2 at
the origin** (assuming X analytic at 0, as the paper claims), directly
contradicting the proposition's conclusion that τ(s)−1/s extends
analytically to ℜ(s)≥0 ∋ 0. So Defect B is not a harmless typo — it
breaks the very pole cancellation the proposition needs. (Caveat: this
assumes the "3 − e^{−s}/s" line is otherwise correct; if that line is
also wrong, the formula is unreliable in a deeper way.)

### Repairability: NOT REPAIRABLE BY PATCHING

Defect A: repairing requires a genuinely different analytic argument
crossing ℜ(s)=0 — the hard analytic content of the whole enterprise,
not a fixable slip. Defect B: correcting the algebra destroys the
proposition's conclusion on the paper's own formula. **Route refuted;
Legendre's (and Sierpiński's, Andrica's, Brocard's, Oppermann's)
conjectures untouched** — whether τ(s)−1/s in fact extends remains an
open analytic question, not settled here. Correctly NOT a BREAK.

### Assessment of the existing note

`docs/audits/leg-ns.md` is **accurate**; its scoping (A decisive, B
secondary, statement unfalsified) is fair. My Defect-B strengthening
(the −2/s pole) goes slightly beyond the note but is derived
independently above with its caveat stated.

### Evidence relied on

- `incoming/leg-ns-2307.08725v4.pdf` pp. 15–19 (`pdftotext`
  extraction; both passages verified verbatim)
- `scripts/analysis/leg_ns_contour_probe.py` (re-ran, exit 0,
  trichotomy reproduced)
- `docs/audits/leg-ns.md`, `results/leg_ns_meta.json`

---

## 3. Erdős–Straus Thm-10 interval (arXiv:2404.01508v3): GAP REAL, FULLY REPAIRABLE — note CORRECTION needed

### Verbatim gap

**Location:** Theorem 10 proof (pinned PDF
`incoming/erdos-straus-2404.01508.pdf`; passage at the "Equaling" step):

> "We look for f(n) to be as large as possible, and that is the case if it
> is also u + v, with u ≠ v. We take therefore u + v = n + (n − 1).
> Equaling we have that 4f(n) − 1 = 2n − 1. And therefore these values u, v
> will always be possible and valid if f(n) ≤ ⌊n/2⌋, which implies that all
> values 4k + 1, with k belonging to the interval [n! − ⌊n/2⌋, n! − 1],
> satisfy the Erdos-Straus conjecture."

### Independent re-derivation

The paper fixes (u,v) = (n, n−1) (u+v = 2n−1, both divide n!) and
"Equaling" 4f(n)−1 = 2n−1 pins f(n) = n/2 — a *single* endpoint. The jump
to "all f(n) ≤ ⌊n/2⌋" is unjustified: for the exhibited (u,v), the
needed divisibility 4f(n)−1 | 2n−1 holds only at f(n) = n/2. Concrete
instance: n=6, k=718 = 720−2 (even, so the separate odd-k "automatic"
case does not apply): d=f=2, u=6, v=5, 4d−1 = 7 ∤ 11 = u+v. The proof as
written leaves k=718 uncovered. Re-ran
`scripts/gates/erdos_straus_checker.py` (exit 0): n=6 interval 2/3 pass,
k=718 the sole failure; n=4 2/2 pass. The odd-k members are covered only
by the separate automatic case (d=u=1, v=2), which this paragraph never
invokes.

### Repairability: FULLY REPAIRABLE (confirmed)

Re-ran `scripts/analysis/erdos_straus_salvage.py` (exit 0): every k
failing with the paper's parameters is salvageable within the same
construction family — e.g. the uniform choice d=1, u=1, v | k+1 with
v ≡ 2 (mod 3) (then 4d−1 = 3 | 1+v): k=718 via (d,u,v)=(1,1,719),
k=40318 via (1,1,23). Exhaustive search over d ∈ [1, n!/2] finds no
unsalvageable k for n ∈ {4,6,8}. **Conclusion stands; proof as written
does not establish it.** Textbook repairable GAP (route, not theorem).

### CORRECTION to the existing note

`docs/audits/erdos-straus-gate.md` (Part C / Disposition) states:

> "the exhibited (u,v) = (n, n−1) satisfies 4d−1 | u+v only at the single
> endpoint d = n/2 (2n−1 | 2n−1); **every other even k in the interval
> fails with those parameters**"

The bolded universal is **false**. Counterexample: n=18, f=2
(k = 18!−2, even): with the paper's literal parameters d=2, u=18, v=17,
4d−1 = 7 divides u+v = 35, and 18, 17 | 18! — the construction goes
through (verified: `(35) % 7 == 0`, `18! % 18 == 0`, `18! % 17 == 0`).
So isolated (n,f) pairs with 4f−1 | 2n−1 and f < n/2 exist. The correct
statement: the paper's argument *provides no reason* for the exhibited
(u,v) to work at any f < n/2 — whether it happens to work is luck, not
proof. The gap itself (unjustified endpoint→interval jump) is real and
unaffected; only the universal quantifier needs narrowing to the
checked cases (n=4,6,8) or to "whenever 4f−1 ∤ 2n−1".

### Standard compliance

This GAP already meets the new standard: verbatim quotation ✓,
independent machine re-derivation (two scripts, both re-ran exit 0) ✓,
explicit repairability judgment with a uniform repair family ✓,
evidence pinned (script paths, paper lines) ✓. Only the one sentence
above needs the narrowing correction.

### Evidence relied on

- `incoming/erdos-straus-2404.01508.pdf` ("Equaling" passage, verified
  verbatim via `pdftotext`)
- `scripts/gates/erdos_straus_checker.py` (re-ran, exit 0)
- `scripts/analysis/erdos_straus_salvage.py` (re-ran, exit 0)
- `docs/audits/erdos-straus-gate.md`
- Counterexample n=18, f=2 computed directly (Python `math.factorial`)

---

## Summary table

| GAP | Real? | Repairable? | Note assessment |
|---|---|---|---|
| FRK-UC (Demontis) | **Yes** — quantifier confusion + Def-9 type error, both verbatim-confirmed | **No** — repair needs a uniform strengthening ≈ as hard as the target theorem | Note accurate; no material overstatement |
| LEG-NS (Ferreira) | **Yes** — contour non sequitur (decisive) + false algebra (independently damaging via −2/s pole) | **No** — needs genuinely new analytic input, not a patch | Note accurate; scoping fair |
| ES Thm-10 (Lopez) | **Yes** — endpoint→interval jump unjustified; k=718 fails literally | **Yes** — uniform repair family (d=1,u=1,v≡2 mod 3); salvage script confirms | Note needs **one correction**: "every other even k fails" is false (n=18, f=2 works); narrow to checked cases |

All three GAPs satisfy the new evidentiary standard (verbatim gap +
independent re-derivation + explicit repairability + pinned evidence),
with the single ES-note sentence correction noted above. None touches
any theorem: Frankl's, Legendre's (etc.), and Erdős–Straus remain
exactly as open/closed as before — routes refuted, theorems untouched.
