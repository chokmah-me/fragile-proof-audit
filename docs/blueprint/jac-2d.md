# Blueprint — JAC-2D: Su's claimed proof of the 2D Jacobian conjecture

**Status:** PASS (escalate), locked as `jac_2d`.
**Source:** Yucai Su, *Generalizations of local bijectivity of Keller maps
and a proof of 2-dimensional Jacobian conjecture*, arXiv:1603.01867v43
(43 versions, submitted 6 Mar 2016, last revised 11 May 2024, marked "FINAL").
**Local PDF:** `incoming/jac2d-su-1603.01867v43.pdf`
**sha256:** `65634fc3a56a8d380b9ecf020e23667f5cb8d798b11ab2c7bfe1df2b83ec4224`
**Pages:** 55
**Gate:** `scripts/gates/jac_2d.py`
**Control:** `scripts/controls/jac_2d_break_control.py`

## What the paper claims

Every polynomial map \(\mathbb{C}^2\to\mathbb{C}^2\) with constant nonzero
Jacobian determinant is invertible (2D Jacobian conjecture, open since
Keller 1939). The proof normalizes a hypothetical non-invertible Keller pair
\((F,G)\) into \(F=y^m(1+\sum f_i(x)y^{-i})\), \(G=y^n(1+\sum g_i(x)y^{-i})\)
with \(n\mid m\), expands \(G=\sum_{\alpha}c_\alpha F^\alpha\) in the ring
\(\mathbb{C}[x]((y^{-1}))\), and runs a long chain of coefficient-comparison
inductions toward a contradiction, including an appendix "proof of Theorem
1.3 provided by Claudio Procesi."

## Provenance correction (the point of reading the real paper)

The harvest dossier (`corpus/Fragile-Route_Harvest_Dossier_II.md`, Hit
JAC-2D) describes Remark 2.7 as "deferring a key identity to 'a symbolic
computation.'" **This is not what the pinned PDF says.** Remark 2.7's proof
reads, in full: "This follows from a symbolic computation. Think first the
\(u_i\) as variables of weight \(i\) then, using formula (2.1) it is enough
to prove that... This is immediate by writing \(u_iy^{-i}=(\lambda^iu_i)(\lambda
y)^{-i}\)..." — an actual weight-counting argument is given on the page, not
outsourced to an unshown computer run. The phrase "symbolic computation" is
the author's one-sentence framing of *why* the claim is CAS-checkable, not a
gap. This gate therefore does not test "does the claimed CAS shortcut exist"
(it doesn't need to — there's a real proof); it replays the actual identities
Remark 2.7 and Lemma 2.8 (eq. 2.41) assert.

## What was gated

**Remark 2.7** (general lemma, decoupled from \(F,G\)): if
\(U=1+\sum u_i(x)y^{-i}\) with \(\deg_x u_i\le i\), then for any real
\(\beta\), \(U^\beta=1+\sum v_i(x)y^{-i}\) has \(\deg_x v_i\le i\) (part (i)),
tightening to \(<i\) when every \(\deg_x u_i<i\) (part (ii)). Tested with
generic, tight-degree symbolic \(u_i\) (the bound is actually attained, not
vacuously satisfied) at \(\beta=1/3\) and \(\beta=2/5\), orders up to \(t^8\).

**Lemma 2.8 / eq. (2.41)**, tied to two genuinely invertible ("Keller")
polynomial pairs — so the constant-Jacobian hypothesis holds
*unconditionally*, no conjecture assumed:

- Instance 1: \(F=(y^2+x)^2+y=y^4+2xy^2+x^2+y\), \(G=y^2+x\) (\(m=4,n=2\));
  inverse \(y=F-G^2\), \(x=G-y^2\). \(J_0=-1\).
- Instance 2: \(F=(y^3+x)^2+y\), \(G=y^3+x\) (\(m=6,n=3\)); same
  construction one level up. \(J_0=-1\).

For each, \(G\) is expanded as \(\sum_i c_i F^{(n-i)/m}\) by the paper's own
triangular coefficient-comparison, and all four clauses of (2.41) are
checked: \(c_\alpha\) constant for \(\alpha>\frac{-m+1}{m}\) (i); \(c_{-1}=0\)
(ii); \(\deg_x c_{(-m+1-j)/m}\le j+1\) (iii); and
\(c_{(-m+1)/m}=-\frac{J_0}{m}(x+a_1)\) (iv) — on instance 1 this comes out
exactly \(x/4\), matching \(-J_0/m=1/4\) with \(a_1=0\); on instance 2,
\(x/6\), matching \(-J_0/m=1/6\).

**All checks pass on both instances and both parts of Remark 2.7.**

## Discrimination control

`scripts/controls/jac_2d_break_control.py` perturbs instance 1's \(F\) by a
single monomial (\(F\mathrel{+}=xy\)), which makes
\(J_0=-x+2y^2-1\) — not constant, breaking the hypothesis behind (2.41).
On the same machinery: \(c_{-1/4}\) (previously a pure constant) becomes
\(-x/2-1/2\); the boundary coefficient becomes \(x^2/4+x/4\), degree 2, not
the predicted affine form. **Verdict: DISCRIMINATES** — the check is not a
tautology; it fails when the hypothesis it depends on fails.

## What is not the witness

This gates the route's earliest checkable skeleton, not the paper end to
end. Per Governing discipline #3 ("a pass escalates, never force a kill"),
this PASS does not clear the 55-page argument — Lemma 2.17's root-of-unity
argument, the Procesi appendix, and the height/estimate propositions (2.108)
are untouched. The dossier's own fragility score (Fr=8: 43 versions across
eight years, still unaccepted by any journal) stands independently of this
gate's outcome. Type G (does the induction actually close) not attempted.
