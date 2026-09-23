# §4. The attack types (A--G) -- draft (2026-09-23)

The campaign's gates are classified by *mechanism*, not by subject area. Each
type below names a route a proof can take, the gate built to test it,
and one worked example from the audit catalog
(`docs/audits/`, `docs/blueprint/`). The standing doctrine throughout:

> **Gates refute routes, not theorems.** $\zeta(5)$ is probably irrational; FLT is
> true; the four-color theorem is true. What dies is a specific lemma chain,
> recorded as lemma, instance, false instance.

The taxonomy is append-only: a new mechanism gets a new letter.

## A -- Scalar gate

**Route attacked.** Claims whose decisive content is a numerical statement
about a specific constant -- typically "best constant" conjectures, where the
entire proof stands or falls on one inequality.

**Gate construction.** Compute the constant, or an explicit witness violating
it, by two independent arithmetics (exact rational algebra and high-precision
floating point), with the violation margin far above any arithmetic noise
floor. The discrimination question here is not "does it fire on everything"
but "is the witness typical or extremal" -- answered by sampling the
neighborhood.

**Worked example.** Tang--Zhang Schatten-norm constant
(`docs/audits/tang-zhang-schatten.md`; refutation artifact Zeng--Liu--Ratnavelu,
arXiv:2608.15558, Theorem 1.1). This BREAK independently confirms
Zeng--Liu--Ratnavelu's refutation: the gate re-derives the violation
from scratch along two independent computation paths rather than
replaying their argument. The conjectured best constant
$C^{TZ}_{p,m} = \sqrt{x(x+m-1)} / (x^p + m - 1)^{1/p}$ -- with `x` the unique
`x > 1` solving `x^p - 2x - (m-1) = 0` -- is exceeded by an explicit
rank-one pair at `p = 3/2`, `m = 2`:
$R = 1.03641365870489\ldots > 207/200 > C^{TZ}_{3/2,2} = 1.03465395185143\ldots$.
Two paths -- exact rational Gram-matrix algebra and 60-digit mpmath --
agree to `1e-40`; margins `~1.4e-3` above and `~3.5e-4` below against
a `1e-20` safety floor.
Control: 5,000 random rank-one pairs at the same `(p, m)` -- only ~1% exceed
the conjectured constant and the witness sits near the true extremum,
so the gate is discriminating, not trigger-happy. **Verdict: BREAK.**

## B -- Base-case kill

**Route attacked.** Induction or irrationality arguments whose load-bearing
step is a finiteness / non-existence claim at the base -- the step the rest of
the proof assumes without exhibiting.

**Gate construction.** Instantiate the base case exactly, with all
constraints, and solve it. If solutions exist, the induction never starts and
nothing downstream matters.

**Worked example.** Suman $\zeta(5)$ (`docs/audits/suman-zeta5.md`). Eq. (48) is
claimed to have no integer solutions; it is the induction base for Theorem 1.
At `n = 1`, `d_1 = lcm(1) = 1`, constraints $0 \le k \le d_1$ and $d_1 \mid kb$:
solutions `(a,b,k) = (2,1,0)` (`a = 2b`) and `(1,1,1)` (`a = b`) exist.
Suman dismisses these because they "would force $\zeta(5) \in \{1,2\}$" -- but
solvability of Eq. (48) is independent of whether $\zeta(5)$ is an integer.
**Verdict: BREAK.**

## C -- WZ-certificate audit (WZ = Wilf--Zeilberger)

**Route attacked.** Claims resting on a Wilf--Zeilberger certificate pair -- the
"a rational function proves the identity" genre, where the decisive object is
a machine-produced certificate the reader is expected to trust.

**Gate construction.** Independently re-verify the certificate pair by exact
evaluation on a dense grid. The known trap is Pochhammer conventions at
negative indices: `(a)_{-n} = (-1)^n/(1-a)_n` must be enforced, not assumed.

**Worked example.** Jana--Karmakar (arXiv:2501.10109). The claimed WZ pair
survived 630 + 630 exact telescoping checks (Lemmas 2.1 and 3.1) and 96
checks of the summed theorems -- the audit produced a PASS. The audit
still proved its worth: the first harness produced 66 false mismatches
by omitting the `(a)_{-n}` convention above; that convention is now
enforced in `scripts/harness/pochhammer.py`. A type-C gate that
declines to fire is the discipline working as designed.

## D -- Finite q-expansion

**Route attacked.** Partition congruences and modular-equation claims whose
decisive content is exact identities between q-series -- checkable term by
term, but only to the depth actually computed.

**Gate construction.** Compute the generating function exactly to a fixed
depth, verify the congruence predictions on their arithmetic progressions and
the modular equation coefficient-by-coefficient. Depth is the open question
for D-gates: 81 points carried no information; 6,747 did
(`docs/GATE-BEFORE-PROVE.md`).

**Worked example.** PDN1 congruences, Du--Yao, arXiv:2503.00004
(`docs/audits/pdn1.md`). Exact series of `J_2^2/J_1^5` through `q^500`
(`PDN1(2) = 18`); Theorems 1.1--1.2 congruence predictions on stated APs mod
$5^\alpha$, $7^\alpha$; modular equation (3.13) with the paper's $\sigma_i$ polynomials
through degree 80 -- maximum absolute difference 0 across 6,747 divisibility
points. **Verdict: PASS (escalate)** on the type-D route; type G not
attempted.

## E -- CAS-transcript replay (CAS = computer algebra system)

**Route attacked.** Computer-assisted proofs whose decisive steps live inside
a CAS session: guessed recurrences, Ore-algebra Gröbner bases, creative
telescoping certificates. The transcript *is* the proof, and it is usually
unpublished.

**Gate construction.** Replay the transcript. When the tooling is not
available on the campaign stack, record blocked -- do not invent operators.

**Worked example.** q-TSPP, the q=1 case of Koutschan's proof
(arXiv:0906.1018; `docs/blueprint/qtspp-q1.md`). The paper's §5.3 prints only
a factorization of the order-7 recurrence's leading coefficient, not
the operator; the $\partial$-finite description (65 guessed recurrences, 5 MB)
was never published, and the recovered notebook's 13 MB diagonal
operator needs 3 GB RAM plus the HolonomicFunctions package --
unavailable. The campaign's answer is a parametric Lean formalization
of the closing argument (`DiagonalCertificate`, kernel-checked,
sorry-free) modulo coefficient recovery, plus author contact for the
true coefficients. Type E is the attack type the campaign documents
as tooling-limited: the route exists before the infrastructure does.

## F -- Counterexample search

**Route attacked.** Universal claims over finite combinatorial objects. The
classic BREAK engine: one witness ends the argument.

**Gate construction.** Exhibit the witness explicitly; close both sides --
the upper bound by construction, the lower bound by exact (branch-and-bound
or exhaustive) search. The control runs the same solver on graphs where the
answer is known both ways, proving it is not an always-fire detector.

**Worked example.** Baste domination (`docs/audits/baste-domination.md`).
Claim: every finite regular graph of positive degree satisfies
$\gamma(G) \le \gamma_e(G)$. False already at $\Delta = 3$: a 50-vertex witness with
$\gamma(G) = 16 > 15 = \gamma_e(G)$, both sides closed by exact search.
Control: the solver finds small dominating sets when they exist (K4
at budget 1; Petersen at budget 3) and declines when they don't
(Petersen at budget 2) -- and the control caught a real bug (`n =
NUM_VERTICES` hardcoded) the moment it tried a non-target graph.
**Verdict: BREAK.** (Same mechanism: Chung--Graham--Spiro; Cohen
subadditivity, witness `(31, 3928)` with 500 random pairs showing zero
violations elsewhere.)

## G -- Logical-gap exposure

**Route attacked.** Proofs whose key step is a structural premise about an
algebraic object -- the exact lemma the route needs, falsified at the
precise failure point.

**Gate construction.** Isolate the premise; exhibit the smallest instance
where it fails; name the failure point. The blueprint header for G-audits
reads "Claim (route, not the theorem)."

**Worked example.** Lamé 1847 (`docs/blueprint/lame-1847.md`). The route
needs $\mathbb{Z}[\zeta_p]$ to be a unique factorization domain for the prime at hand.
The first prime conductor with class number `> 1` is `p = 23`, where
$h(\mathbb{Q}(\zeta_{23})) = 3$. The gate checks the minus part: $h^{-}_p = 1$ for every
prime `p < 23` by the Maillet/OEIS determinant formula, and $h^{-}_{23} = 3$
(`scripts/gates/lame_h23.py`); the plus parts $h^{+}_p = 1$ for `p < 23`
are cited as external input from classical tables, not recomputed by
the gate -- the gate's meta records `"h_plus_cited": 1` at `p = 23` and
sets $h = h^{-}\cdot h^{+}$. So 23 is exactly the point of failure. FLT itself
stands; the route dies at `p = 23`. **Verdict:** locked **PASS** on
$h(\mathbb{Q}(\zeta_{23})) = 3$ -- the confirmed fact that refutes the route
(§3 polarity rule).
