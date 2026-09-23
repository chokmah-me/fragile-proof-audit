# References — draft (2026-09-23)

Conventional bibliography for the methods paper. All entries verified
against primary sources during the citation fact-check pass; §8 cites
these by name inline.

Code4rena. Audit contest reports. https://code4rena.com/reports.
Competitive, time-boxed audit contests: multiple Wardens review a
code snapshot; findings are judged, deduplicated into unique
vulnerabilities, severity-rated, and collected in a final report.

Du, J. Q. D., and Yao, O. X. M. "Congruences modulo arbitrary powers
of 5 and 7 for Andrews and Paule's partition diamonds."
arXiv:2503.00004. Source of the PDN1 congruences and modular equation
replayed by the type-D gate (§4).

Gethner, E., Kallichanda, B., Mentis, A. S., et al. "How false is
Kempe's proof of the Four Color Theorem? Part II." *Involve* 2(3)
(2009), 249–265. doi:10.2140/involve.2009.2.249. The modern telling of
Kempe's argument and Heawood's refutation pinned by the §6.1 gate.

Heawood, P. J. "Map-Colour Theorem." *Quart. J. Pure Appl. Math.* 24
(1890), 332–338. The original refutation of Kempe's 1879 proof: a
single map on which simultaneous Kempe-chain interchanges conflict.

Jana, A., and Karmakar, L. "Generalizations of two hypergeometric
sums related to conjectures of Guo." arXiv:2501.10109 [math.NT].
The WZ-certificate pair audited clean by the type-C gate (§4).

Koutschan, C. "Eliminating Human Insight: An Algorithmic Proof of
Stembridge's TSPP Theorem." arXiv:0906.1018 (2009). The q=1 case of
the q-TSPP proof formalized in the campaign's Lean shakedown (§6.4).

Lean Community. "How to contribute to mathlib" and "Reviewing a
mathlib PR." https://github.com/leanprover-community/leanprover-community.github.io
PRs require passing CI to enter the review queue; reviewers comment
and may mark a PR awaiting-author; maintainers give final approval.
Review checks placement, duplication/generality, imports, naming, and
maintainability.

NCC Group. Security and cryptographic review services. Representative
of professional review practice: inspect source against a pinned
commit, publish findings with severity and exploitability.

Ortega, J.-L., and Delgado-Quirós, L. "How do journals deal with
problematic articles. Editorial response of journals to articles
commented in PubPeer." *Profesional de la información* 32 (2023).
doi:10.3145/epi.2023.ene.18. Dataset of 17,244 PubPeer-commented
articles; only 21.5% of articles judged to deserve an editorial
notice were corrected by the journal.

Petkovšek, M., Wilf, H. S., and Zeilberger, D. *A = B.* A K Peters,
Wellesley, 1996. The Wilf–Zeilberger certificate method: a rational
function R(n,k) certifying a hypergeometric identity, the object the
type-C gate re-verifies (§4).

Platt, D., and Trudgian, T. "The Riemann hypothesis is true up to
3·10¹²." *Bulletin of the London Mathematical Society* 53 (2021),
792–797. doi:10.1112/blms.12460. arXiv:2004.09765. Theorem 1: RH
verified to height 3,000,175,332,800; §3.4 turns Polymath15's Table 1
into Corollary 2 (Λ ≤ 0.2) and declines the Λ < 0.19 entry: "We have
not pursued this."

Polymath, D. H. J. "Effective approximation of heat flow evolution
of the Riemann ξ function, and a new upper bound for the de
Bruijn–Newman constant." *Research in the Mathematical Sciences* 6
(2019), 31. arXiv:1904.12438. Establishes Λ ≤ 0.22 via effective
estimates and numerical computation; Table 1 converts "RH verified
to height H" into Λ upper bounds.

Ringer, T., Porter, R., Yazdani, N., Leo, J., and Grossman, D.
"Proof Repair across Type Equivalences." In *Proc. PLDI 2021*,
112–127. doi:10.1145/3453483.3454033. PUMPKIN Pi: mechanized proof
repair across type equivalences for Coq, with the kernel re-checking
repaired artifacts.

Sherlock. Audit contest documentation and reports.
https://audits.sherlock.xyz. Competitive audit contests with
multi-stage judging, deduplication, and fix review.

Su, Y. "Generalizations of local bijectivity of Keller maps and a
proof of 2-dimensional Jacobian conjecture." arXiv:1603.01867v43
[math.AG]. The 43-version 2D-Jacobian claim that survived the
campaign's type-G logical-gap audit (PASS, §3).

Sun, Z.-W. "Catalan's constant is irrational." arXiv:2609.04176v1.
The type-E target whose numeric gate refuted the route (§4).

Tao, T. "Machine-Assisted Proof." *Notices of the American
Mathematical Society* 72 (1) (Jan. 2025). Published version of the
Simons Foundation lecture "Machine-Assisted Proof" (Feb. 19, 2025).

Zeng, Z., Liu, H., and Ratnavelu, K. "A Counterexample to the Tang
Zhang Schatten Norm Conjecture and Sharp Positive Results."
arXiv:2608.15558. Theorem 1.1: the exact counterexample (m = n = 2,
p = 3/2) the type-A gate independently re-derives (§4).
