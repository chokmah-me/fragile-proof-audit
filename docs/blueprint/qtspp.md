# q-TSPP — Andrews–Robbins product formula (infrastructure build)

**Corpus source:** `corpus/fragile-formalizable-proofs-report.md` §4.4, harvest rank 10.
Ranking table: q-TSPP (PNAS 2011) | F=7, Fr=2, R=8 | est. effort 6–10 wk.
Corpus verdict: **"Infrastructure build (correct proof)."**

**Status:** reconnaissance complete 2026-09-23. Full technical map in
`~/workspace/goals/fragile-proof-audit-repo-collaboration/hidden_files/qtspp_recon.md`.

## 1. What this is

Not a refutation and not a BREAK: the q-TSPP proof is correct. Like the
Pólya canonization, this is a trust-anchor / infrastructure artifact —
here, a *correct-proof* infrastructure build rather than a certificate
canonization. The 23/23 verdict lock is untouched.

The corpus's characterization: the proof reduced the Andrews–Robbins
conjecture to a determinant evaluation and thence to **three identities**,
each closed by a **creative-telescoping certificate** — the final one a
recurrence of order 12 whose leading coefficient never vanishes, so that
checking the identity at n = 1,…,12 completes the proof. "The entire
argument is 'rational-function certificate + finite initial-value check'
— the purest existing model of a Lean gate, and still awaiting a full
formalization."

## 2. Reconnaissance findings (2026-09-23, arXiv:1002.4384v2)

**Theorem (Andrews–Robbins, ~1983).** For T(n) = totally symmetric plane
partitions with largest part ≤ n:
`∑_{π ∈ T(n)} q^{|π/S₃|} = ∏_{1≤i≤j≤k≤n} (1−q^{i+j+k−1})/(1−q^{i+j+k−2})`.

**Okada's determinant reduction** (human lemma, JCTA 1989): the theorem
follows from `det(a_{i,j}) = b_n` with
`a_{i,j} = q^{i+j−1}([i+j−2 choose i−1]_q + q[i+j−1 choose i]_q) + (1+q^i)δ_{i,j} − δ_{i,j+1}`,
`b_n = ∏_{1≤i≤j≤k≤n} ((1−q^{i+j+k−1})/(1−q^{i+j+k−2}))²`.
Holonomic-ansatz induction: guess normalized cofactors `c_{n,j}`, prove three identities:
1. `c_{n,n} = 1` — order-7 diagonal recurrence with `(S_n−1)` right factor; check n=1..7.
2. `Σ_j c_{n,j} a_{i,j} = 0` (i<n) — two creative-telescoping recurrences summed to annihilating operators; finite initial-value agreement.
3. `Σ_j c_{n,j} a_{n,j} = b_n/b_{n−1}` — CT gives an **order-12** recurrence, a left multiple of an explicit order-2 operator annihilating the RHS product; leading coefficient never vanishes; finite check **n=1..12** closes it.

**Blockers found in recon:**
- The **7 GB of certificates live only on a now-dead website** (`risc.jku.at/people/ckoutsch/qtspp/` unreachable); discovery algorithms unpublished. Recovery via Wayback/author contact is the critical path.
- **Mathlib has no Ore-algebra / noncommutative Gröbner / q-Zeilberger infrastructure** — that is the real 6–10 wk build, and optimistic.
- GB-scale terms can't go through Lean's kernel; a verified meta-level checker would be needed.
- No existing formalization attempts (Lean/Coq/Isabelle).

**Recommended staging:** recover certificates → formalize q=1 Stembridge case (arXiv:0906.1018) as shakedown → build CT-checking infrastructure → pilot identity (3).

**Certificate recovery — DONE 2026-09-23.** The "dead website" was recoverable
via the Wayback Machine (snapshot 2026-05-13). `qtspp.zip` (293,417,871 bytes,
SHA-256 pinned in `~/workspace/qtspp-certs/SHA256SUMS`) extracted to 10
Mathematica `.m` files (~936 MB uncompressed): `ansatz1/2/3.m`,
`denom1/2/3.m`, `solution1/2/3.m` (80/368/460 MB), `ann-qTSPP-deg.m` —
`OrePolynomial` expressions from the HolonomicFunctions package, i.e. the
actual creative-telescoping certificates. Critical-path blocker resolved;
note the files live outside the repo (too large to commit).

## 3. Formalization plan

### 3a. Scope (from recon §7, certificates now recovered)

**Machine-checkable** (certificate + finite check):
- (a) Identity (1): order-7 diagonal recurrence, `(S_n−1)` right factor, 7 values, `p_7(q,q^n,q^n) ≠ 0`.
- (b) Identity (2): two CT identities (ideal membership), `P_1,P_2` in RHS-ideal, finite agreement check.
- (c) Identity (3): order-12 recurrence, `L_12 = Q·L_2` factorization, `L_2` kills RHS, leading coefficient ≠ 0, check n=1..12. **Pilot candidate** — most compact certificate, most explicit closing argument.
- (d) Dimension-zero / uniqueness: finite initial values determine the sequence.

**Human-sized reduction lemmas** (formalize as mathematics):
- (e) Okada's reduction: determinant evaluation ⇒ q-TSPP product formula.
- (f) Holonomic-ansatz induction: (1)+(2)+(3) for guessed `c_{n,j}` ⇒ true cofactors ⇒ det = b_n.
- (g) Rewritings (2)→(2′), (3)→(3′) (q-binomial algebra).
- (h) Guessing the `c_{n,j}` system is outside the verified proof (taken as input).

**Infrastructure gaps** (the real 6–10 wk cost):
- Ore algebras `Q(q,q^n,q^j)[S_n,S_j]` + noncommutative Gröbner bases: essentially absent from mathlib.
- q-hypergeometric toolkit: q-Pochhammer, q-binomial, q-Zeilberger (ordinary Zeilberger in mathlib is itself nascent).
- GB-scale terms can't go through Lean's kernel → verified meta-level checker with small trusted certificate format.
- Discovery algorithms undisclosed → certificates can be CHECKED, not regenerated. (Recovery solved the availability half.)

### 3b. Staging

1. ✅ Recover/archive certificates (Wayback 2026-05-13; SHA-256 pinned).
2. **Next:** formalize the q=1 case (Stembridge TSPP, arXiv:0906.1018 — fully written up, smaller certificates) as infrastructure shakedown.
3. Build Ore-algebra + CT checking infrastructure against the small case.
4. Pilot identity (3) in the q-case.
