# References - draft (2026-09-23)

Conventional bibliography for the methods paper. Entries added during
the citation fact-check pass were verified against primary sources; a
few pre-existing entries (notably the mathlib documentation guide)
were not. Sec. 7 cites these by name inline.

Code4rena. Audit contest reports. https://code4rena.com/reports.
Competitive, time-boxed audit contests: multiple Wardens review a
code snapshot; findings are judged, deduplicated into unique
vulnerabilities, severity-rated, and collected in a final report.

Du, J. Q. D., and Yao, O. X. M. "Congruences modulo arbitrary powers
of 5 and 7 for Andrews and Paule's partition diamonds."
arXiv:2503.00004. Source of the PDN1 congruences and modular equation
replayed by the type-D gate (Sec. 3).

Gethner, E., Kallichanda, B., Mentis, A. S., et al. "How false is
Kempe's proof of the Four Color Theorem? Part II." *Involve* 2(3)
(2009), 249--265. doi:10.2140/involve.2009.2.249. The modern telling of
Kempe's argument and Heawood's refutation pinned by the Sec. 5.1 gate.

Heawood, P. J. "Map-Colour Theorem." *Quart. J. Pure Appl. Math.* 24
(1890), 332--338. The original refutation of Kempe's 1879 proof: a
single map on which simultaneous Kempe-chain interchanges conflict.

Jana, A., and Karmakar, L. "Generalizations of two hypergeometric
sums related to conjectures of Guo." arXiv:2501.10109 [math.NT].
The WZ-certificate pair audited clean by the type-C gate (Sec. 3).

Koutschan, C. "Eliminating Human Insight: An Algorithmic Proof of
Stembridge's TSPP Theorem." arXiv:0906.1018 (2009). The q=1 case of
the q-TSPP proof formalized in the campaign's Lean shakedown (Sec. 5.4).

Lean Community. "How to contribute to mathlib" and "Reviewing a
mathlib PR." https://github.com/leanprover-community/leanprover-community.github.io
PRs require passing CI to enter the review queue; reviewers comment
and may mark a PR awaiting-author; maintainers give final approval.
Review checks placement, duplication/generality, imports, naming, and
maintainability.

NCC Group. Security and cryptographic review services. Representative
of professional review practice: inspect source against a pinned
commit, publish findings with severity and exploitability.

Ortega, J.-L., and Delgado-Quiros, L. "How do journals deal with
problematic articles. Editorial response of journals to articles
commented in PubPeer." *Profesional de la informacion* 32 (2023).
doi:10.3145/epi.2023.ene.18. Dataset of 17,244 PubPeer-commented
articles; only 21.5% of articles judged to deserve an editorial
notice were corrected by the journal.

Petkovsek, M., Wilf, H. S., and Zeilberger, D. *A = B.* A K Peters,
Wellesley, 1996. The Wilf--Zeilberger certificate method: a rational
function R(n,k) certifying a hypergeometric identity, the object the
type-C gate re-verifies (Sec. 3).

Platt, D., and Trudgian, T. "The Riemann hypothesis is true up to
$3\cdot 10^{12}$." *Bulletin of the London Mathematical Society* 53 (2021),
792--797. doi:10.1112/blms.12460. arXiv:2004.09765. Theorem 1: RH
verified to height 3,000,175,332,800; Sec. 2.4 turns Polymath15's Table 1
into Corollary 2 ($\Lambda \le 0.2$) and declines the $\Lambda < 0.19$ entry: "We have
not pursued this."

Polymath, D. H. J. "Effective approximation of heat flow evolution
of the Riemann $\xi$ function, and a new upper bound for the de
Bruijn--Newman constant." *Research in the Mathematical Sciences* 6
(2019), 31. arXiv:1904.12438. Establishes $\Lambda \le 0.2$2 via effective
estimates and numerical computation; Table 1 converts "RH verified
to height H" into $\Lambda$ upper bounds.

Ringer, T., Porter, R., Yazdani, N., Leo, J., and Grossman, D.
"Proof Repair across Type Equivalences." In *Proc. PLDI 2021*,
112--127. doi:10.1145/3453483.3454033. PUMPKIN Pi: mechanized proof
repair across type equivalences for Coq, with the kernel re-checking
repaired artifacts.

Sherlock. Audit contest documentation and reports.
https://audits.sherlock.xyz. Competitive audit contests with
multi-stage judging, deduplication, and fix review.

Su, Y. "Generalizations of local bijectivity of Keller maps and a
proof of 2-dimensional Jacobian conjecture." arXiv:1603.01867v43
[math.AG]. The 43-version 2D-Jacobian claim that survived the
campaign's type-G logical-gap audit (PASS, Sec. 2).

Sun, Z.-W. "Catalan's constant is irrational." arXiv:2609.04176v1.
The type-E target whose numeric gate refuted the route (Sec. 3).

Tao, T. "Machine-Assisted Proof." *Notices of the American
Mathematical Society* 72 (1) (Jan. 2025).
https://www.ams.org/journals/notices/202501/noti3041/noti3041.html.

Zeng, Z., Liu, H., and Ratnavelu, K. "A Counterexample to the Tang
Zhang Schatten Norm Conjecture and Sharp Positive Results."
arXiv:2608.15558. Theorem 1.1: the exact counterexample (m = n = 2,
p = 3/2) the type-A gate independently re-derives (Sec. 3).

Afrasyab, K. "A 50-Vertex Cubic Counterexample to the
Domination-versus-Edge-Domination Conjecture." arXiv:2609.10783. The
published refutation of Baste et al.'s conjecture (50-vertex cubic
graph, $\gamma = 16 > 15 = \gamma_e$) whose witness the type-F gate
recomputes from the pinned claim (Sec. 3).

Aliabadi, M. "A counterexample to the Chung-Graham-Spiro gap-set
conjecture." arXiv:2609.04473. The published refutation (fails at
l = 4, 9 in U_4 \\ D_4) recomputed by the type-F gate (Sec. 3).

Baste, J., Furst, M., Henning, M. A., Mohr, E., and Rautenbach, D.
Domination-versus-edge-domination conjecture (2019/2020), as stated in
Afrasyab arXiv:2609.10783: every finite regular graph of positive
degree satisfies $\gamma(G) \le \gamma_e(G)$. Refuted by Afrasyab; the
type-F gate recomputes the witness (Sec. 3).

Chalise, P., Clark, A., and Gnang, E. K. arXiv:2410.13840v2. The
displayed evaluation in the proof of Proposition 3.4 broken by the
type-A gate (Sec. 3).

Chen, S., Li, Y., Xi, D., and Xu, Z.-F. "The Mahler Conjecture in
Three Dimensions." arXiv:2605.09334. Target of the MAH-3 gate; the
gate verdict is PASS on the counting lemma, the claim disposition
SKIP (Sec. 6.2).

Chung, F., Graham, R., and Spiro, S. Gap-set conjecture (2020), as
stated in Aliabadi arXiv:2609.04473: the l-step gap sets of the
down-integer/up-integer partition agree for every l >= 1. Refuted by
Aliabadi; the type-F gate recomputes the witness (Sec. 3).

Demontis, R. "The union-closed set conjecture is true."
arXiv:2405.03731v1. Target of the FRK-UC GAP note (Sec. 2).

Fritsch, R., and Fritsch, G. *The Four-Color Theorem.* Springer,
1998. The 9-vertex, 21-edge graph and the switch-order failure
replayed by the Sec. 5.1 gate.

Ghermoul. arXiv:2508.07367v1, equation (35). The Erdos--Straus
target broken by the type-A gate (Sec. 3).

Giraudin, D. N. "A counterexample to a conjecture of Thakur on
Carlitz-Wieferich primes." arXiv:2607.15305. The published
refutation (explicit c-Wieferich prime of degree 5 over F_{19^3})
recomputed by the type-F gate (Sec. 3).

Gnang, E. K. arXiv:2202.03178v3. The displayed congruence in the
proof of Lemma 25 broken by the type-F gate (Sec. 3).

Gomila, J. "Riemann lambda 0.1787854."
https://www.judegomila.com/posts/riemann-lambda-0.1787854. Audit
repository: https://github.com/judegomila/dbn-lambda-01787854-candidate-audit.
The $\Lambda \le 0.1787854$ claim execution-verified in Sec. 5.2.

Haselgrove, C. B. "A disproof of a conjecture of Polya."
*Mathematika* 5 (1958), 141--145. The first disproof of Polya's
conjecture; the canonization target of Sec. 5.3.

Huang, Y., Lau, K., Ono, K., and Paule, P. "Algebraic geometric
framework of Rogers--Ramanujan identities." arXiv:2608.15219. One of
the two type-D PASS targets (Sec. 3).

Ibarra, J. A. "A counterexample to a subadditivity conjecture of
Cohen for Sophie Germain cyclic numbers." arXiv:2607.09793. Cohen's
Conjecture 66 (subadditivity of C_sigma); the type-F gate recomputes
the (m, n) = (31, 3928) witness (Sec. 3).

Kempe, A. B. "On the geographical problem of the four colours."
*Amer. J. Math.* 2 (1879), 193--200. The original flawed proof;
background to the Sec. 5.1 gate.

Koutschan, C. "Eliminating Human Insight: An Algorithmic Proof of
Stembridge's TSPP Theorem." arXiv:0906.1018. The q = 1 shakedown
target of the q-TSPP line (Sec. 5.4).

Koutschan, C., Kauers, M., and Zeilberger, D. "Proof of George
Andrews's and David Robbins's q-TSPP Conjecture." arXiv:1002.4384;
*Proc. Natl. Acad. Sci.* 108(6) (2011), 2196--2199. The q-TSPP line's
target theorem (Sec. 5.4).

Lame, G. Attempted proof of Fermat's Last Theorem by cyclotomic
unique factorization (1847). The route broken at p = 23 by the
type-G gates (Sec. 3).

Lau, K., and Ono, K. "Modularity of Point Counts for the Curves
X^a=Y^b: New Rogers--Ramanujan Identities." arXiv:2608.05480. The
other type-D PASS target (Sec. 3).

Lopez, M. A. "A Complete Congruence System for the Erdos-Straus
Conjecture." arXiv:2404.01508. Target of the es_cover PASS gate
(Sec. 3).

Munch, F. "A counterexample to a conjecture by Salez and Youssef."
arXiv:2504.08055. The published refutation (birth--death chains of
increasing length) recomputed by the type-G gate (Sec. 3).

Okada, S. "On the generating functions for certain classes of plane
partitions." *J. Combin. Theory Ser. A* 51 (1989), 1--23. The
determinant reduction the q-TSPP proof builds on (Sec. 5.4).

Salez, J., and Youssef, P. "Intrinsic regularity in the discrete
log-Sobolev inequality." arXiv:2503.02793. Conjecture 1, refuted by
Munch; the type-G gate's target (Sec. 3).

Suman, S. "A note on the Irrationality of $\zeta(5)$ and Higher Odd Zeta
Values." arXiv:2407.07121. The withdrawn irrationality claim broken
by the type-B gate (Sec. 3).

Tait, P. G. Claimed proof of the four-color theorem (1884), refuted
by Tutte's 46-vertex counterexample (1946); the gate replays Tutte's
counterexample (Sec. 3).

Tanaka, M. Computation of the smallest Polya counterexample,
L(906,150,257) = +1 (1980), per the campaign's Polya blueprint
(Sec. 5.3).

Tang, Q. "A counterexample to a conjecture of Sarkozy on sums and
products modulo a prime." arXiv:2603.29992. The published refutation
recomputed by the type-F gate (Sec. 3).

Zadehgol Mohammadi, A., and Kolahdouz, M. "Introducing and Applying
S.C.E Model Under Dusart's Inequality to Prove Goldbach's Strong
Conjecture for 74 Typical Structures out of All 75 Structural Types
of Even Number." arXiv:1909.13230v5. Target of the gb_sce BREAK
gate (Sec. 4).
