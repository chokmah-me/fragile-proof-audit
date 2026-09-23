# Search metadata — reference verification (2026-09-23)

How each bibliographic fact added to the references draft was verified.
Queries are reproduced verbatim; all runs were live arXiv API / web
searches performed during the edit pass.

## arXiv API queries (export.arxiv.org/api/query)

Batch 1 (search_query):
`id:2407.07121+OR+id:2607.15305+OR+id:2607.09793+OR+id:2605.09334+OR+id:2609.10783+OR+id:1909.13230+OR+id:2603.29992`

Results returned:
- 2407.07121 — Shekhar Suman, "A note on the Irrationality of ζ(5) and Higher Odd Zeta Values" (v7, marked "Found incorrect")
- 2607.15305 — David Niedbala Giraudin, "A counterexample to a conjecture of Thakur on Carlitz-Wieferich primes" (v2)
- 2607.09793 — Josué Alexander Ibarra, "A counterexample to a subadditivity conjecture of Cohen for Sophie Germain cyclic numbers" (v1; Cohen Conjecture 66; witness m=31, n=3928; Lean-4-verified)
- 2605.09334 — Shibing Chen, Yuanyuan Li, Dongmeng Xi, Zhe-Feng Xu, "The Mahler Conjecture in Three Dimensions" (v1)
- 2609.10783 — Koyar Afrasyab, "A 50-Vertex Cubic Counterexample to the Domination-versus-Edge-Domination Conjecture" (v1; gamma=16 > 15=gamma_e)
- 1909.13230 — Aref Zadehgol Mohammadi, Mohsen Kolahdouz, "Introducing and Applying S.C.E Model Under Dusart's Inequality to Prove Goldbach's Strong Conjecture..." (v5)
- 2603.29992 — Quanyu Tang, "A counterexample to a conjecture of Sárközy on sums and products modulo a prime" (v2)

Batch 2 (search_query):
`id:2503.02793+OR+id:2404.01508+OR+id:2608.05480+OR+id:2608.15219+OR+id:2609.04473+OR+id:2504.08055+OR+id:2609.04176+OR+id:0906.1018`

Results returned:
- 2609.04176 — Zhi-Wei Sun, "Catalan's constant is irrational" (v1)
- 2608.05480 — Kenny Lau, Ken Ono, "Modularity of Point Counts for the Curves X^a=Y^b: New Rogers--Ramanujan Identities" (v1; full a=3 layer)
- 0906.1018 — Christoph Koutschan, "Eliminating Human Insight: An Algorithmic Proof of Stembridge's TSPP Theorem" (v1)
- 2503.02793 — Justin Salez, Pierre Youssef, "Intrinsic regularity in the discrete log-Sobolev inequality" (v1)
- 2504.08055 — Florentin Münch, "A counterexample to a conjecture by Salez and Youssef" (v1; birth--death chains)
- 2608.15219 — Yifeng Huang, Kenny Lau, Ken Ono, Peter Paule, "Algebraic geometric framework of Rogers--Ramanujan identities" (v1; cases (3,4),(3,5),(3,7),(3,8))
- 2609.04473 — Mohsen Aliabadi, "A counterexample to the Chung-Graham-Spiro gap-set conjecture" (v1; fails at l=4, 9 in U_4 \\ D_4)
- 2404.01508 — Miguel Angel Lopez, "A Complete Congruence System for the Erdos-Straus Conjecture" (v3)

## Web searches

- "Koutschan Kauers Zeilberger q-TSPP PNAS 2011 108 2196" — confirmed arXiv:1002.4384v2; PNAS 108(6), 2196–2199 (2011); DOI 10.1073/pnas.1019186108.
- "Okada generating functions plane partitions Journal of Combinatorial Theory Series A 1989" — confirmed S. Okada, "On the Generating Functions for Certain Classes of Plane Partitions," J. Combin. Theory Ser. A (1989), pp. 1–23. Volume number not confirmed — omitted from the reference.
- Tao, "Machine-Assisted Proof" — confirmed Terry Tao, Notices of the AMS 72(1), January 2025; URL https://www.ams.org/journals/notices/202501/noti3041/noti3041.html. The February 19, 2025 lecture claim was dropped as chronologically impossible.
- "NCC Group pinned commit" / "Sherlock judging deduplication fix-review" — flagged in review; not yet externally confirmed. Do not cite without confirmation.
- Gomila — URLs taken from the campaign's own blueprint (docs/blueprint/gomila-lambda.md), not from live search: https://www.judegomila.com/posts/riemann-lambda-0.1787854 and https://github.com/judegomila/dbn-lambda-01787854-candidate-audit.

## Items deliberately minimal

Entries for Ghermoul, Gnang, Chalise–Clark–Gnang, Tait, Tutte, Tanaka, Lamé, Baste et al., Chung–Graham–Spiro, Cohen, and Tang–Zhang were written from the campaign's audit notes and refutation papers, not from independent primary-source verification. Do not upgrade them to full citations without checking the sources.
