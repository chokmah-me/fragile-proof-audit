"""Numeric gate: the Chung-Graham-Spiro gap-set conjecture is FALSE at l=4.

Source claim: the corpus doc's "Chung-Graham Gap-Set" target
(corpus/live-fragile-proofs-2024-2026.md, final ranking table row 6) turned
out, on cross-check, to have NO body section at all -- Sections 1-3 cover
exactly seven targets (Cohen, Baste, Sarkozy, Tang-Zhang, Thakur,
Salez-Youssef, NCI), each with a "Target Identifier" block and a numbered
Works Cited entry; Chung-Graham appears only as a table row with no arXiv ID,
no claimed theorem, no failure mechanism, and no citation -- worse than the
Tang-Zhang/Thakur image-corruption failure (those at least had a claim to
transcribe). Even the name is imprecise: the real conjecture is due to
Chung, Graham, AND Spiro (Chung-Graham-Spiro, J. Number Theory 210 (2020)).
The refutation was located by a live web search (arXiv:2609.04473, Mohsen
Aliabadi) and fetched directly -- this gate is built entirely from that
pinned PDF, with nothing taken from the corpus doc, which supplies no usable
content for this target.

Setup. Let f_1=f_2=1, f_{k+2}=f_{k+1}+f_k be the Fibonacci sequence. Every
integer n>=2 has a unique "Chung-Graham-Spiro representation"
n = a*f_t + b*f_{t-1}, t>=2, 1<=a<=b<=f_t (this is Aliabadi's Lemma, citing
Chung-Graham-Spiro's original paper). n is a down-integer if t is even, an
up-integer if t is odd; D = {down-integers}, U = {up-integers} partition the
integers >=2. For l>=1 the l-step gap sets are D_l = {d_{k+l}-d_k : k>=1},
U_l = {u_{k+l}-u_k : k>=1}. Chung-Graham-Spiro proved D_1=U_1 and D_2=U_2 and
conjectured D_l=U_l for every l>=1.

Theorem 1.1 of the pinned PDF: 9 in U_4 \\ D_4, so D_4 != U_4 -- the
conjecture fails at l=4. The witness: 8,11,14,16,17 are five consecutive
up-integers (17-8=9), so 9 in U_4; the paper further proves 9 is never a
first-to-fifth gap among five consecutive down-integers, for ANY starting
point (a finite base-case computation up to N=113, Lemma 3.1, extended to
all larger N by two algebraic shift lemmas, Lemmas 2.1-2.2, not re-derived
here).

This gate reproduces Theorem 1.1's finite content by two independent paths:
Path A implements the (a,b,t) representation algorithm exactly as given in
the paper's own Appendix (a direct, from-scratch translation, not trusted
blindly -- its output is cross-checked against Path B below and against the
paper's own printed D-list). Path B is a from-scratch simulation of the
ORIGINAL Chung-Graham-Spiro definition (slow Fibonacci walks: among all
walks w_1=a_1,w_2=a_2,w_{k+2}=w_{k+1}+w_k with 1<=a_1<=a_2 that reach n
exactly, take the one reaching n latest; n is down/up according to whether
the walk's next term is floor(phi*n) or ceil(phi*n)) -- an entirely
different algorithm for the same classification, never mentioned in the
refutation paper's own verification code. Path B classifies INTEGERS as
down/up (corroborating the classify_repr() function Path A's D/U sets are
built from); it says nothing directly about "9 in U_4", which is a
statement about 9 as a GAP VALUE and is established purely by Path A's
explicit five-consecutive-up-integer block. The naive brute-force walk
search has a real gap: for some n, several walks tie for "latest arrival"
and disagree on the next term (the original 2020 paper evidently has an
additional tie-breaking rule this campaign does not have access to, having
fetched only the citing refutation paper) -- those n are reported and
excluded rather than force-resolved either way.

Gates refute routes, not theorems: this gates Theorem 1.1's explicit
witness (9 in U_4) and its finite base case (Lemma 3.1, extended well past
the paper's own N=113 for depth), not the general-N algebraic argument of
Lemmas 2.1-2.2 that rules out 9 in D_4 for every N to infinity -- that part
is a proof, not a finite computation, and is not re-derived here (same
"gates refute routes" caveat as RR's Ore step or PDN1's notebooks).
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import mpmath as mp

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"

mp.mp.dps = 60
PHI = (1 + mp.sqrt(5)) / 2

# --- Path A: (a,b,t) representation, verbatim translation of the paper's --
# --- own Appendix (Sage) algorithm, cross-checked below against Path B. --


def fibs_up_to(n: int) -> list[int]:
    f = [0, 1, 1]
    while f[-1] <= n:
        f.append(f[-1] + f[-2])
    return f


def cgs_representation(m: int) -> tuple[int, int, int]:
    f = fibs_up_to(m)
    for t in range(2, len(f)):
        if f[t] + f[t - 1] > m:
            break
        for a in range(1, f[t] + 1):
            for b in range(a, f[t] + 1):
                if a * f[t] + b * f[t - 1] == m:
                    return (a, b, t)
    raise ValueError(f"no CGS representation found for m={m}")


def classify_repr(m: int) -> str:
    _, _, t = cgs_representation(m)
    return "D" if t % 2 == 0 else "U"


def du_partition_repr(lo: int, hi: int) -> tuple[list[int], list[int]]:
    d, u = [], []
    for m in range(lo, hi + 1):
        (d if classify_repr(m) == "D" else u).append(m)
    return d, u


# --- fast_cgs_representation: a performance-only reformulation of the -----
# --- same (a,b,t) search, using modular inverses instead of the brute- ----
# --- force double loop the paper's own Appendix uses (that double loop is
# --- O(f_t^2) per candidate t and becomes impractical for depth scans
# --- beyond a few thousand). Cross-validated below (in main()) against
# --- cgs_representation on a shared range before being trusted for depth.


def fast_cgs_representation(m: int) -> tuple[int, int, int]:
    f = fibs_up_to(m)
    for t in range(2, len(f)):
        ft, ftm1 = f[t], f[t - 1]
        if ft + ftm1 > m:
            break
        if ftm1 == 1:
            for a in range(1, ft + 1):
                b = m - a * ft
                if a <= b <= ft:
                    return (a, b, t)
            continue
        inv = pow(ft % ftm1, -1, ftm1)
        a0 = (m * inv) % ftm1
        for a in (a0, a0 + ftm1):
            if a == 0 or (m - a * ft) % ftm1 != 0:
                continue
            b = (m - a * ft) // ftm1
            if 1 <= a <= b <= ft:
                return (a, b, t)
    raise ValueError(f"no fast CGS representation found for m={m}")


def classify_repr_fast(m: int) -> str:
    _, _, t = fast_cgs_representation(m)
    return "D" if t % 2 == 0 else "U"


def du_partition_repr_fast(lo: int, hi: int) -> tuple[list[int], list[int]]:
    d, u = [], []
    for m in range(lo, hi + 1):
        (d if classify_repr_fast(m) == "D" else u).append(m)
    return d, u


# --- Path B: from-scratch slow-Fibonacci-walk simulation, independent of --
# --- the (a,b,t) representation algorithm entirely. ------------------------


def slow_walk_next_term(n: int) -> tuple[int, int, bool]:
    """Among all Fibonacci walks with 1<=a1<=a2<=n that reach n exactly,
    return (latest reaching index s, next term after n, tie_disagreement)."""
    best_s = -1
    best_next: int | None = None
    tie_disagreement = False
    for a1 in range(1, n + 1):
        for a2 in range(a1, n + 1):
            w = [a1, a2]
            if a1 == n:
                s = 1
            elif a2 == n:
                s = 2
            else:
                s = None
                while w[-1] < n:
                    w.append(w[-1] + w[-2])
                    if w[-1] == n:
                        s = len(w)
                        break
                    if w[-1] > n:
                        break
            if s is None:
                continue
            while len(w) <= s:
                w.append(w[-1] + w[-2])
            nxt = w[s]
            if s > best_s:
                best_s, best_next, tie_disagreement = s, nxt, False
            elif s == best_s and nxt != best_next:
                tie_disagreement = True
    assert best_next is not None, f"no Fibonacci walk reaches n={n}"
    return best_s, best_next, tie_disagreement


def classify_walk(n: int) -> tuple[str, bool]:
    """Classify n as down/up-integer via the from-scratch slow-walk
    simulation. `tie_disagreement=True` means several walks tied for the
    latest arrival at n but disagreed on the next term -- this naive
    brute-force search lacks whatever additional tie-breaking rule the
    original Chung-Graham-Spiro paper uses (not available to this campaign;
    only the citing refutation paper was fetched). Those n are reported as
    inconclusive for Path B, not silently resolved either way -- see the
    'path_b_slow_walk_simulation' block in the gate meta for the count."""
    _, nxt, tie_disagreement = slow_walk_next_term(n)
    flo, cei = int(mp.floor(PHI * n)), int(mp.ceil(PHI * n))
    if nxt == flo:
        return "D", tie_disagreement
    if nxt == cei:
        return "U", tie_disagreement
    return "?", tie_disagreement


# --- paper's own printed data, for transcription cross-checks -------------

PAPER_D_2_17 = [2, 5, 7, 9, 10, 12, 13, 15]
PAPER_U_2_17 = [3, 4, 6, 8, 11, 14, 16, 17]

PAPER_D_2_113 = [
    2, 5, 7, 9, 10, 12, 13, 15, 18, 23, 26, 28, 31, 33, 34, 36, 38, 39, 41, 43,
    44, 46, 47, 48, 49, 51, 52, 54, 56, 57, 59, 60, 62, 64, 65, 67, 68, 70,
    72, 73, 75, 78, 80, 81, 83, 86, 88, 89, 91, 94, 96, 99, 102, 104, 107, 112,
]


def five_consecutive_gap9_blocks(seq: list[int]) -> list[tuple[int, ...]]:
    return [
        tuple(seq[i : i + 5])
        for i in range(len(seq) - 4)
        if seq[i + 4] - seq[i] == 9
    ]


def main() -> int:
    RESULTS.mkdir(parents=True, exist_ok=True)

    # --- Path A over [2,17]: reproduce and cross-check the paper's own ----
    d_17, u_17 = du_partition_repr(2, 17)
    matches_paper_2_17 = d_17 == PAPER_D_2_17 and u_17 == PAPER_U_2_17

    u_blocks_17 = five_consecutive_gap9_blocks(u_17)
    nine_in_U4 = any(True for _ in u_blocks_17)  # non-empty iff found
    witness_block = u_blocks_17[0] if u_blocks_17 else None

    # --- Path A Lemma 3.1 base case: D cap [2,113], no down-block span 9 --
    d_113, _ = du_partition_repr(2, 113)
    matches_paper_2_113 = d_113 == PAPER_D_2_113
    d_blocks_113 = five_consecutive_gap9_blocks(d_113)
    nine_not_in_D4_base_case = len(d_blocks_113) == 0

    # --- fast-path self-test: cross-validate fast_cgs_representation ------
    # against the brute-force cgs_representation (the paper's own Appendix
    # algorithm) before trusting it for the depth scan below. The brute
    # force is O(f_t^2) per query and becomes impractical past a few
    # thousand; the fast path uses modular inverses instead -- same (a,b,t)
    # search, different implementation, so this is an implementation-
    # equivalence check (ceremony category, GATE-BEFORE-PROVE.md), not a
    # discrimination control.
    FASTPATH_SELFTEST_N = 1000
    fastpath_mismatches = [
        m
        for m in range(2, FASTPATH_SELFTEST_N + 1)
        if cgs_representation(m) != fast_cgs_representation(m)
    ]
    fastpath_matches_bruteforce = len(fastpath_mismatches) == 0

    # --- Depth: extend the down-integer scan well past the paper's own ----
    # N=113 base case (which only needed to cover t<8, M<=104). Not a proof
    # for all N (that is Lemmas 2.1-2.2, algebraic, not gated here) -- just
    # additional finite corroboration, matching this campaign's "depth"
    # convention (pdn1 at alpha=3, 6747+ points). Uses the fast path, only
    # after the self-test above confirms it matches the brute force.
    DEPTH_N = 50000
    d_deep, _ = du_partition_repr_fast(2, DEPTH_N)
    d_blocks_deep = five_consecutive_gap9_blocks(d_deep)
    nine_not_in_D4_deep = len(d_blocks_deep) == 0

    # --- Path B: independent slow-walk simulation, cross-check vs Path A --
    # This classifies each INTEGER n as down/up (feeding classify_repr's own
    # role), which is a different question from "is 9 a gap value in U_4" --
    # that is settled by Path A's witness block above. Path B corroborates
    # the classify_repr(m) function itself, by an entirely independent
    # algorithm, over the unambiguous subset of [2, PATH_B_N] (see
    # classify_walk's docstring for why some n are excluded rather than
    # force-resolved).
    PATH_B_N = 220
    disagreements = []
    tie_ns = []
    for n in range(2, PATH_B_N + 1):
        cls_a = classify_repr(n)
        cls_b, tie_disagreement = classify_walk(n)
        if tie_disagreement:
            tie_ns.append(n)
            continue  # inconclusive by this naive simulation -- not a claim either way
        if cls_a != cls_b:
            disagreements.append((n, cls_a, cls_b))
    n_unambiguous = (PATH_B_N - 1) - len(tie_ns)
    path_b_agrees = len(disagreements) == 0 and n_unambiguous > 0

    # The witness integers 8, 11, 14, 16, 17 are the members of the U_4
    # block itself -- these are required to be unambiguous and confirmed by
    # Path B. 9 is reported too (it is a down-integer per both paths and
    # the paper's own D-list -- note this is a DIFFERENT fact from "9 is a
    # gap value", which Path A's witness block alone already established),
    # but Path B happens to hit a tie there, so it is informational only,
    # not gating.
    witness_integers = [8, 11, 14, 16, 17]
    witness_checks = {}
    for w in [8, 9, 11, 14, 16, 17]:
        cls_a = classify_repr(w)
        cls_b, tie = classify_walk(w)
        witness_checks[w] = {"path_a": cls_a, "path_b": cls_b, "tie": tie, "agree": (not tie) and cls_a == cls_b}
    witnesses_confirmed = all(witness_checks[w]["agree"] for w in witness_integers)

    ok = (
        matches_paper_2_17
        and nine_in_U4
        and witness_block == (8, 11, 14, 16, 17)
        and matches_paper_2_113
        and nine_not_in_D4_base_case
        and fastpath_matches_bruteforce
        and nine_not_in_D4_deep
        and path_b_agrees
        and witnesses_confirmed
    )

    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate": "chung_graham_spiro",
        "source_claim": (
            "Chung-Graham-Spiro (2020): the l-step gap sets D_l, U_l of the "
            "down-integer/up-integer partition of Z_{>=2} agree, D_l=U_l, "
            "for every l>=1"
        ),
        "source_refutation": "Mohsen Aliabadi (2026), arXiv:2609.04473, Theorem 1.1",
        "corpus_pointer": (
            "corpus/live-fragile-proofs-2024-2026.md -- NOTE: the corpus doc's "
            "'Chung-Graham Gap-Set' row (final ranking table, row 6) has NO "
            "body section, no arXiv ID, and no Works Cited entry; located via "
            "live web search instead, and the name itself was incomplete "
            "(missing 'Spiro')"
        ),
        "local_pdf": "incoming/chung-graham-spiro-2609.04473.pdf",
        "instance": "l=4, witness 9",
        "path_a_representation": {
            "D_cap_2_17": d_17,
            "U_cap_2_17": u_17,
            "matches_paper_2_17": matches_paper_2_17,
            "five_consecutive_up_blocks_span9": u_blocks_17,
            "nine_in_U4": nine_in_U4,
            "matches_paper_D_2_113": matches_paper_2_113,
            "five_consecutive_down_blocks_span9_in_2_113": d_blocks_113,
            "nine_not_in_D4_base_case_N113": nine_not_in_D4_base_case,
        },
        "fastpath_selftest": {
            "N": FASTPATH_SELFTEST_N,
            "mismatches": fastpath_mismatches,
            "matches_bruteforce": fastpath_matches_bruteforce,
        },
        "depth_extended_down_scan": {
            "N": DEPTH_N,
            "method": "fast_cgs_representation (self-tested above)",
            "five_consecutive_down_blocks_span9": d_blocks_deep,
            "nine_not_in_D4_up_to_N": nine_not_in_D4_deep,
        },
        "path_b_slow_walk_simulation": {
            "N_checked": PATH_B_N,
            "n_unambiguous": n_unambiguous,
            "tie_disagreement_ns_excluded": tie_ns,
            "disagreements_with_path_a_on_unambiguous_subset": disagreements,
            "path_b_agrees_with_path_a": path_b_agrees,
            "witness_integers_checked": witness_checks,
            "witnesses_confirmed": witnesses_confirmed,
        },
        "verdict": "BREAK" if ok else "ABORT_TRANSCRIPTION",
        "lemma": "D_l = U_l for every l >= 1 (Chung-Graham-Spiro gap-set conjecture)",
        # N is read from DEPTH_N rather than written out: the two had drifted
        # apart (the string said 20000 while the scan ran to 50000).
        "false_instance": (
            f"9 in U_4 \\ D_4 (witnessed by 8,11,14,16,17 in U; absent from "
            f"all 5-consecutive down-blocks checked up to N={DEPTH_N})"
        ),
        "ok": ok,
    }
    out = RESULTS / "chung_graham_spiro_gate_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")

    status = "PASS" if ok else "FAIL"
    print(f"[{status}] chung_graham_spiro")
    print(f"  D cap [2,17] = {d_17}  (matches paper: {matches_paper_2_17})")
    print(f"  U cap [2,17] = {u_17}")
    print(f"  five-consecutive-up blocks with span 9: {u_blocks_17}")
    print(f"  D cap [2,113] matches paper's printed list: {matches_paper_2_113}")
    print(f"  down-blocks span 9 in [2,113]: {d_blocks_113} (expect none)")
    print(f"  fast-path self-test vs brute force (N<={FASTPATH_SELFTEST_N}): "
          f"{fastpath_matches_bruteforce} ({len(fastpath_mismatches)} mismatches)")
    print(f"  down-blocks span 9 up to N={DEPTH_N}: {len(d_blocks_deep)} found (expect 0)")
    print(f"  Path B (slow-walk sim, N<={PATH_B_N}) agrees with Path A on "
          f"{n_unambiguous} unambiguous n: {path_b_agrees} "
          f"({len(disagreements)} disagreements, {len(tie_ns)} ties excluded)")
    print(f"  witness integers {witness_integers} confirmed by both paths: {witnesses_confirmed}")
    print(f"  (informational) 9's own D/U class: {witness_checks[9]}")
    print(f"  verdict: {meta['verdict']}")
    print(f"Wrote {out}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
