> **AUDIT NOTE (2026-09-22).** Lead, not a record of verdicts. Inline test-fires were not checked against a pinned PDF when this file was written. Gate only from `incoming/`. COL-FP (Kawasaki 2502.20642v2) closed VACUOUS: `docs/audits/kawasaki-collatz.md`.

# Fragile-Route Harvest Dossier II — Combinatorics & Analysis, Classic-Calibration Mix

**Configuration:** horizon = classic calibration mix (recent preprints as spine, historical parallels as calibration) · domains: combinatorics / analysis · ranked hits: 8.
**Exclusions honored from Dossier I:** TPC-AREA (1707.03265), CAT-G (2609.04176), ES-5 (2508.07367), LEG-NS (2307.08725), GB-SCE (1909.13230), plus the logged near-misses (2407.07121 ζ(5), 2203.01832, 2403.16047, 1605.01722, RH-no-residue claims, 2108.13834, 1912.09290, 2608.24035).
**Sweep date:** 2026-09-22. Trust tags: `verified` = re-checked live this session; `contested` = public criticism located, no formal rebuttal; `calibration` = historical parallel, not a harvest slot.

Gates refute routes, not theorems. Three gates were test-fired on a laptop during this sweep; results inline.

---

## Hit 1 — Collatz via Banach fixed point on (ℕ, |·|)

**ID:** COL-FP · **Title:** *A proof of the Collatz conjecture* · **arXiv:** [2502.20642v1](https://arxiv.org/html/2502.20642v1) (Feb 2025).

**Still-believed statement.** Collatz: every orbit of x ↦ x/2 (even), 3x+1 (odd) reaches 1. Open.

**Claimed route.** (1) Fold odd-step into T(x) = (3x+1)/2 on odds → (2) regard (ℕ, d), d(x,y)=|x−y|, as a complete metric space → (3) Theorem 3.1: build a six-component coefficient vector (α, β, ε, ζ, …) with magic constants ({−2,−1,…,2} tables) to certify a contraction-type inequality → (4) conclude {Tⁿx} converges to a fixed point u → (5) "clearly u = 1."

**Earliest pin.** The contraction premise itself: the whole engine needs orbit convergence to follow from the coefficient tables of Theorem 3.1, whose displayed values ("−2 in the case of (2,2,−2,−2,0,2) … > B") are asserted case-by-case.

**Attack type:** A (scalar: expansion ratio) + G (illicit use of completeness — ℕ is discrete, so convergence = eventuality, which is the theorem restated).

**Gate sketch.** Object: the map T under |·|. Parameters: small odd pairs. Confirm: |T x − T y| ≤ c|x − y| with c < 1 on the relevant regime. Break: any pair with expansion > 1.
**Test-fired this session: BREAK.** T is uniformly expansive on same-parity odd pairs: |T(2k+1) − T(2l+1)| = (3/2)|k − l|·2 → ratio exactly 1.5 on (3,5), (5,7), (7,9), (3,9), (9,11). No contraction exists; every downstream coefficient table is decoration on a false premise. **Control:** the true averaging fact log 2 − ½ log 3 < 0 (heuristic contraction over long orbits) confirms the instrument reads contraction when it is present.

**Scores.** F 9 (one map, one metric, exact integers) · Fr 9 (single load-bearing premise, magic-constant tables) · R 10 (five pairs, one line of Python).

**Prior art.** No formal rebuttal located; genre-standard failure mode. Status: `verified`-live.

**Why our framework fits.** Scalar-gate archetype; the discrete-completeness G-flaw needs no expert prose to pin once the expansion witness is displayed.

**Risks.** None material; HTML rendering garbles the tables but the premise dies upstream of them.

---

## Hit 2 — Frankl's union-closed conjecture (claimed full proof)

**ID:** FRK-UC · **Title:** *The Union-Closed Sets Conjecture* · **arXiv:** [2405.03731](https://arxiv.org/abs/2405.03731) (May 2024) · **Author:** S. Schäge.

**Still-believed statement.** Frankl 1979: every finite union-closed family (≠ {∅}) has an element in ≥ 1/2 of its sets. Open; best general constant is Gilmer's 0.01 (2022), improved by Alweiss–Huang–Sellke ([Gil Kalai blog](https://gilkalai.wordpress.com/2022/11/17/amazing-justin-gilmer-gave-a-constant-lower-bound-for-the-union-closed-sets-conjecture/), [arXiv:2305.19338](https://arxiv.org/abs/2305.19338)).

**Claimed route.** Information-theoretic/separation arguments in the entropy framework opened by Gilmer, pushed from constant fraction to exactly 1/2 (per the paper's abstract and the r/math announcement thread, [r/math](https://www.reddit.com/r/math/comments/1cno75c/unionclosed_set_conjecture_claimed_to_be_proved/)).

**Earliest pin.** The step that upgrades "constant < 1/2" to "exactly 1/2" — historically the entire difficulty; community response on the announcement thread was skeptical and no journal acceptance has followed in 28 months.

**Attack type:** F + A. The lemma layer is universal in the family and finite-searchable: brute-force ALL union-closed families on ground sets n = 3, 4, 5 and test the paper's claimed intermediate inequalities (frequency bounds, separator existence) on each.

**Gate sketch.** Enumerate union-closed families over [n] (n = 4 gives thousands; n = 5 ~ tens of thousands — laptop-scale). For each family, evaluate the paper's load-bearing estimate. Confirm: the claimed bound holds on every family. Break: one family violating it. **Control:** the same enumerator on the true 1/2-conclusion (known to hold for n ≤ 5 by exhaustive verification in the literature) — opposite verdict available.

**Scores.** F 9 (union-closed families are maximally mathlib-native) · Fr 8 (unpublished 28 months, cross-specialty author, decisive step in dense analytic prose) · R 8 (full enumeration at n ≤ 5, minutes).

**Prior art.** Public skepticism thread; no formal rebuttal and no withdrawal located. Status: `contested`.

**Why our framework fits.** Exact enumeration + per-family scalar checks; a Break witness is a 20-set certificate anyone can re-run.

**Risks.** The gate requires extracting the precise intermediate inequalities from the paper (prose-dense); budget half a day for extraction before enumeration. PDF symbol loss risk moderate.

---

## Hit 3 — Graceful / Kotzig–Ringel–Rosa labeling via the "composition lemma"

**ID:** KRR-CL · **Titles:** *A proof of the Kotzig–Ringel–Rosa Conjecture* [2202.03178](https://arxiv.org/abs/2202.03178) (2022), *On graceful labelings of trees* [1811.07614](https://arxiv.org/abs/1811.07614) (2018, pre-horizon but same load-bearer) · **Author:** E. Gnang.

**Still-believed statement.** Graceful tree conjecture (KRR): every tree admits a graceful labeling. Open since 1967; verified only for small n and special classes.

**Claimed route.** (1) Encode labelings as functions f: {0,…,n−1} → {0,…,n−1} with f(0)=0, f(i) < i → (2) "composition lemma" (Lemma 5 / Lemma 24 in the two versions) composes partial labelings into full ones → (3) induction on tree size → (4) all trees graceful. A MathOverflow thread ([MO 482509](https://mathoverflow.net/questions/482509/claimed-proofs-of-graph-labelling-conjectures)) notes both papers "boil down to what the author calls the composition lemma" and asks whether anyone has verified it — unanswered as of the sweep.

**Earliest pin.** The composition lemma: a single combinatorial identity/operation asserted to preserve the bijectivity of induced edge labels — exactly the step where a finite counterexample can live.

**Attack type:** F (the lemma is universal over small trees — enumerate all trees on ≤ 8 vertices, apply the stated composition, check graceful-ness of the output) + E (symbolic manipulation claims).

**Gate sketch.** Object: composition lemma instances. Parameters: all unlabeled trees n = 5…9, all base graceful labelings (known catalogs). Confirm: composed labeling is graceful in every instance. Break: one instance producing a non-bijective edge-label set. **Control:** known-correct composition constructions for caterpillars (graceful since the 1970s) must pass.

**Scores.** F 9 (graph labelings blueprint directly) · Fr 8 (six papers, one lemma, zero independent verification) · R 9 (exhaustive n ≤ 9 in seconds).

**Prior art.** MO question open with no verification either way; no publications beyond arXiv. Status: `contested`.

**Why our framework fits.** Pure finite enumeration with a decisive certificate; if it Confirms, the Lean encoding of the composition lemma is a clean secondary deliverable.

**Risks.** The lemma's statement must be extracted verbatim — the two versions state it differently; mismatched extraction is the main false-Break risk.

---

## Hit 4 — Tree Packing Conjecture via the same composition machinery

**ID:** TPC-GN · **Title:** *A Proof of the Tree Packing Conjecture* · **arXiv:** [2410.13840](https://arxiv.org/abs/2410.13840) (Oct 2024) · **Author:** E. Gnang.

**Still-believed statement.** Gyárfás–Lehel Tree Packing Conjecture: any sequence T₂,…,T_{n+1} of trees, Tᵢ on i vertices, packs into K_{n+1}. Open in general; major cases resolved by Joos–Kim–Kühn–Osthus. Companion claim in the same series: every tree on n edges decomposes K_{n,n} ([2409.01981](https://arxiv.org/abs/2409.01981), listed in the same MO thread).

**Claimed route.** Same composition-lemma spine as Hit 3, applied to edge-decomposition instead of labeling.

**Earliest pin.** The composition step under packing constraints: vertex-disjointness of embedded images is asserted to be preserved by the composition — a finite, enumerable claim.

**Attack type:** F. Enumerate small instances of TPC (n = 4…8), run the paper's construction deterministically, test whether the produced embeddings are pairwise edge-disjoint.

**Gate sketch.** As Hit 3, with edge-disjointness as the checked predicate. **Control:** known packings for n ≤ 5 (classical) must Confirm.

**Scores.** F 9 · Fr 8 (same single load-bearer; unpublished) · R 8.

**Prior art.** Same MO thread; no formal rebuttal. Status: `contested`.

**Why our framework fits.** Identical enumerator infrastructure as Hit 3 — write once, gate both papers.

**Risks.** Correlated with Hit 3: if the composition lemma dies in Hit 3's gate, this route dies with it (efficient — two dossier entries, one kill).

---

## Hit 5 — Non-symmetric Mahler conjecture in dimension 3

**ID:** MAH-3 · **Title:** *The Mahler Conjecture in Three Dimensions* (v1 title: *The Non-Symmetric Mahler Conjecture in Dimension Three*) · **arXiv:** [2605.09334v3](https://arxiv.org/html/2605.09334v3) (May 2026; v3 Jun 2026).

**Still-believed statement.** Mahler's conjecture: vol(K)·vol(K°) ≥ 4ⁿ/n! for convex bodies; open in general, proven in 3D only for the symmetric case (Iriyeh–Shibata, Duke Math. J. 2020). The non-symmetric 3D case claimed here would be a headline result.

**Claimed route.** (1) Minimize the volume product over polytopes with ≤ N vertices (compactness) → (2) shadow-flow calculus: minimizers admit only trivial shadow flows (Section 4) → (3) counting lemma 5.1: dim Aθ(P) ≥ F − V + Δ(P) + 1 for θ parallel to a maximal facet → (4) force Δ = d = 3, V = F → tetrahedron → (5) sublevel-set connectedness (Proposition 6.4) + Kim–Reisner local stability → equality cases.

**Earliest pin.** Two candidate seams: the counting estimate (5.1), and Proposition 6.4's connectedness of the sublevel sets 𝒞̃_{N,a} — the latter is the genuinely load-bearing topological claim.

**Attack type:** A (the counting estimate is exact linear algebra on explicit polytopes) + G (connectedness step; finite anchor weak).

**Gate sketch.** Gate 5a: implement Aθ(P) as an exact linear constraint system; test (5.1) on a battery of polytopes with the prescribed θ. Gate 5b: stress the connectedness claim by constructing explicit paths/near-minimizers.
**Test-fired this session (5a): CONFIRM.** Square pyramid (θ ∥ square facet): dim A = 5 ≥ 5, tight. Octahedron: 6 ≥ 6, tight. Cube: 5 ≥ 3. The counting layer is honest — including the θ-regime the lemma requires (an earlier test with generic θ appeared to violate the bound; that was the instrument's parameter error, corrected by reading the lemma's hypothesis). **Control:** deliberately wrong θ gives a visible false signal, so the instrument is discriminative.

**Scores.** F 6 (polytope linear algebra formalizable; the variational/connectedness layer is not week-scale) · Fr 6 (careful, structured, uses standard tools — lower fragility than typical targets; but unpublished, big claim, single author) · R 6 (5a confirmed live; the remaining kill surface is topological, less gate-friendly).

**Prior art.** No rebuttal located; symmetric-case companion argument included (Section 7). Status: `verified`-live, unrefuted — possibly a real proof; gate 5b decides our interest.

**Why our framework fits.** Exact rational linear algebra on polytopes; the confirmed layer gives a trusted base from which to isolate the topological seam.

**Risks.** This is the least fragile hit in the dossier — may be correct. If 5b resists finitization, demote to watch list.

---

## Hit 6 — Two-dimensional Jacobian conjecture (43 versions)

**ID:** JAC-2D · **Title:** *Proof of two-dimensional Jacobian conjecture* · **arXiv:** [1603.01867v43](https://arxiv.org/html/1603.01867v43) (line originates 2016; v43 dated 2024 — in horizon by version).

**Still-believed statement.** Jacobian conjecture (2D): polynomial map ℂ² → ℂ² with constant nonzero Jacobian determinant is invertible. Open since 1939; famous for repeated failed proofs.

**Claimed route.** (1) Normalize a Jacobian pair (F, G) via automorphisms → (2) expand in the ring ℂ[x^{1/m}]((y⁻¹)) with fractional powers → (3) coefficient-comparison inductions (2.37)–(2.62) producing forced nonzero coefficients c̄ → (4) height/estimate propositions (2.108) → (5) contradiction with non-invertibility; includes an appendix "proof of Theorem 1.3 provided by Claudio Procesi" and Remark 2.7 deferring a key identity to "a symbolic computation."

**Earliest pin.** Remark 2.7 + the coefficient-comparison chain (2.41): the route's skeleton is a claimed family of polynomial identities in the uᵢ — exactly the class a CAS replay refutes or confirms.

**Attack type:** E (CAS-transcript replay of the symbolic-computation remarks) + D (coefficient identities are finite q/Laurent-expansion checks at bounded depth).

**Gate sketch.** Extract the identities asserted in Remark 2.7 and (2.37)–(2.49); instantiate at m = 2, 3 with symbolic uᵢ (SymPy), expand to the asserted depth, compare coefficients. Confirm: identities hold to full claimed depth. Break: first mismatched coefficient. **Control:** the trivially-true special case the paper itself gives ((F,G) = (y^m, yⁿ + cy^k + xy^{−m+1}), Remark after (2.106)) must pass.

**Scores.** F 6 (Laurent-series coefficient arithmetic is blueprintable; the surrounding edifice is not) · Fr 8 (43 versions without acceptance is the loudest fragility signal available; specialty-adjacent machinery) · R 6 (gate is real but requires careful extraction from a long, evolving text).

**Prior art.** Decades of failed 2D-JC claims as backdrop; no specific published rebuttal of this manuscript located. Status: `contested`.

**Why our framework fits.** This is the purest Type-E target in the dossier: the author himself outsources the load-bearing identity to symbolic computation — we replay it independently.

**Risks.** Version drift (v43 vs v44+); gate must pin a version hash. Extraction cost is the highest in the dossier — flag `--deep` if the coefficient chain exceeds two hours of engineering.

---

## Hit 7 (calibration) — Kempe's proof of the four-color theorem, 1879

**ID:** KEM-4C · **Source:** A. B. Kempe, *On the geographical problem of the four colours*, Amer. J. Math. 1879 — accepted, celebrated, and wrong; killed by Heawood's 1890 counter-map.

**Route and pin.** Kempe-chain interchange + the claim that two simultaneous interchanges can always be performed without conflict at a degree-5 vertex. The failure is a single local configuration — Heawood's map — not a philosophical gap.

**Calibration lesson.** This is the historical prototype of our **B/F gates**: the decisive step was finite and checkable (one configuration), and the refutation was a witness, not a counter-argument. It took eleven years because no one ran the configuration. It anchors two rules we apply above: (i) a proof accepted by the community for a decade can still die at one finite residue; (ii) "the local case is clear" is a fragility signature, not a proof. Score pattern it teaches: high R (one map) + high Fr (single load-bearing chain) = gate immediately, don't wait for expert consensus.

**Why our framework fits.** Modern replay: Kempe's algorithm can be implemented in an afternoon and fails on Heawood's map mechanically — the cheapest full Confirm/Break loop in this dossier, ideal for calibrating the enumeration harness before pointing it at Hits 2–4.

---

## Hit 8 (calibration) — de Branges' Riemann hypothesis claims, 2004–2017

**ID:** dB-RH · **Source:** L. de Branges, successive preprints claiming RH via Hilbert spaces of entire functions (2004–2017 series).

**Route and pin.** A genuine mathematical apparatus (de Branges spaces — the author's own celebrated machinery from the Bieberbach proof) carrying a decisive positivity/trace claim that specialists could never verify and the author never reduced to a checkable display.

**Calibration lesson.** The anti-pattern our **E/D gates** exist to prevent: certificate-*shaped* objects (explicit kernels, determinants, positivity forms) that are never instantiated at computable parameters. The route died socially (non-replication) rather than by gate, because no finite residue was ever exhibited. Its lesson cuts both ways in this dossier: it justifies demanding the small-B determinant from CAT-G-type papers, and it warns us off MAH-3's connectedness seam unless a finite anchor can be forced. Note also the asymmetry with Hit 7: a correct big proof (Bieberbach) came from the same author and the same machinery — which is why we gate routes, never authors, and why a Confirm verdict must remain a live outcome in every gate we write.

**Why our framework fits.** Negative calibration: defines the refusal criterion — if after extraction a target's decisive step admits no instantiation at small parameters, it joins this log rather than the harvest.

---

## Next-three (ordered by expected yield per hour)

1. **COL-FP kill note (2 hours).** Break already in hand (expansion ratio exactly 3/2 on five witness pairs, premise dead before Theorem 3.1's tables). Package: map definition, witness table, one paragraph. Highest certainty-per-hour in the dossier.
2. **KRR-CL / TPC-GN enumerator (1–2 days).** Extract the composition lemma verbatim from 2202.03178 (v-latest), implement, run on all trees n ≤ 9 with catalog graceful labelings. One harness gates both Gnang papers; either a Break certificate or the first independent Confirmation of a six-paper claim cluster — high information either way.
3. **JAC-2D symbolic replay (1 day, `--deep` if it overruns).** Pin v43, replay Remark 2.7 and the (2.37)–(2.49) coefficient identities at m = 2, 3 in SymPy. The author outsourced the load-bearer to "symbolic computation"; replaying it is the cheapest decisive audit of a 43-version claim available.

## Exclusion log (this sweep)

Refused, for the record: **Rosenfeld's lonely-runner 8/9-runner papers** ([2509.14111](https://arxiv.org/abs/2509.14111), [2512.01912](https://arxiv.org/pdf/2512.01912)) — honest computer-assisted partial results with published code; proof-of-a-claimed-theorem is not a fragile full-conjecture route; off-target. **Montgomery's Ryser–Brualdi–Stein for large even n** ([2310.19779](https://arxiv.org/abs/2310.19779)) — serious mainstream work by a leading specialist; not fragile, and only an asymptotic case. **Sendov refinement** ([2506.12951](https://arxiv.org/html/2506.12951v2)) — conjectures a refinement and proves subcases; claims no full proof. **Separable-Jacobian counterexample** ([2608.02634](https://arxiv.org/abs/2608.02634)) — a counterexample paper to a char-2 variant; this harvest gates claimed proofs of still-believed statements, not counterexamples. **Euler–Mascheroni irrationality claims** (viXra 1208.0009 lineage) — already publicly dissected as flawed ([r/badmathematics](https://www.reddit.com/r/badmathematics/comments/igshcc/the_irrationality_of_the_eulermascheroni_constant/)); reproduction job, and non-arXiv. **Robin's-inequality RH literature** (Hertlein [1612.05186](https://arxiv.org/html/1612.05186v2), Axler [2110.13478](https://arxiv.org/abs/2110.13478), [2511.02106](https://arxiv.org/abs/2511.02106)) — these prove partial/analogue criteria and claim no proof of RH; the actual RH-claim preprints remain excluded per Dossier I (no finite residue). **Formalization efforts around union-closed** ([2609.20876](https://arxiv.org/html/2609.20876v1)) — proof-of-a-special-case formalization, not a fragile claim. Dossier I's five hits and its full exclusion log remain locked and are not re-gated here.

