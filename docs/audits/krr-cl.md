# Audit note — KRR-CL composition-lemma congruence — BREAK

**Claim artifact:** the displayed congruence for \(Q^{[1]}_{f,g}\) in the proof of Lemma 25.
**Paper:** Edinah K. Gnang, arXiv:2202.03178v3 (31 Jan 2025), page 27.
**Campaign objects:** `docs/blueprint/krr-cl.md`, `scripts/gates/krr_cl.py`,
`scripts/controls/krr_cl_break_control.py`, `results/krr_cl_gate_meta.json`,
`incoming/gnang-krr-2202.03178.pdf`.
**Lock:** `krr_cl` → BREAK.

## Bug report

| Field | Content |
|---|---|
| **Lemma** | \(Q^{[1]}_{f,g} = c(x_{f^{(2)}(n-1)}-x_{f(n-1)})^m\) equals the sum over \(\Phi(g)\) of that monomial's value times two univariate Lagrange factors |
| **Instance** | \(n=4\), \(f=(0,0,1,2)\), \(g=(0,0,1,1)\), \(\sigma=(0,3,1,2)\), \(m=6\), \(c=1\) |
| **False instance** | Left side \(2^6=64\), right side \(128\) |

**Verdict: BREAK.** \(\Phi(g)\) contains both \((0,3,1,2)\) and \((2,3,1,0)\). Those two permutations agree on coordinates \(1\) and \(2\), which are the only coordinates in the sum. Each contributes \(64\).

## What this does not say

\(f\) is the path of length 3, in the semigroup the proof reduces to, and its diameter is 3, so it sits inside the hypothesis of Lemma 25. The partial iterate \(g\) is graceful, and so is \(f\): both scores equal 4. The inequality in the statement of Lemma 25 is not the witness.

The evaluation formula for \(P_g\) printed on the same page holds for this \(f\): on \(\Phi(g)\) it equals \(\pm\prod_{i<j}(j-i)(j^2-i^2)\), and off \(\Phi(g)\) it equals 0. The telescoping step \(x_{f^{(2)}(v)}-x_v=(x_{f^{(2)}(n-1)}-x_{f(n-1)})+(x_{f(v)}-x_v)\) is an identity.

The Kotzig–Ringel–Rosa conjecture is untouched. This row does not say that a later Gnang manuscript inherits the same display.

## Follow-up (2026-09-22): the "bigger" enumerator turned out to be vacuous

`corpus/Fragile-Route_Harvest_Dossier_II.md`'s own "Next options" list scored
a different, larger deliverable higher than this point-witness BREAK: an
exhaustive check of Lemma 25's *own printed inequality*,
\(\mathrm{score}(f^2)\le\mathrm{score}(f)\), over all trees \(n=5\ldots9\)
(**R=9**, the highest reproducibility score anywhere in that dossier).
Built it (`scripts/controls/krr_cl_composition_scan.py`) and ran it: **zero
counterexamples across 5 902 trees (n=5..8), and it cannot become
informative at any n a brute-force search could reach.** `score(h)`
saturates at the ceiling `n` for every tree this small — every tree with
\(n\le8\) vertices is already known gracefully labelable (the graceful
tree conjecture is independently verified computationally far beyond what
`(n-1)!` enumeration can reach), so the inequality reads `n<=n` regardless
of whether Lemma 25 is correct. This is not a depth limitation to push
past with more compute; it is structural. A prospective session should not
try to extend this scan to n=9 or n=10 expecting a decisive answer — it
cannot become one.

**Correction to the dossier's own scoring, recorded inline there.** The
already-landed Q^[1]-congruence BREAK above — narrower, single-witness,
inside the *proof* rather than the *statement* — was the right target, not
a fallback from a bigger check the campaign failed to build. Governing
discipline #7 ("a check that cannot fail is not evidence") caught this
before it was registered as a gate; it lives in `scripts/controls/` as a
documented negative result, never in `scripts/gates/check.py`.
