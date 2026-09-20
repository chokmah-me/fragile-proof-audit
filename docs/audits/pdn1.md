# Audit note — PDN1 congruences (Phase 2(g))

**Claim artifact:** Du–Yao, arXiv:2503.00004.  
**Campaign objects:** `docs/blueprint/pdn1.md`, `scripts/gates/pdn1.py`,
`results/pdn1_gate_meta.json`, `incoming/pdn1-2503.00004.pdf`,
`incoming/pdn1/mod5/`, `incoming/pdn1/mod7/`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Theorems 1.1–1.2 (PDN1 ≡ 0 on stated APs mod \(5^\alpha\), \(7^\alpha\)) via GF \(J_2^2/J_1^5\) and modular eq. (3.13) |
| **Instance** | Exact series through \(q^{500}\); congruence samples α=1,2; (3.13) through degree 80 |
| **False instance** | **None.** GF harness `PDN1(2)=18`; all sampled congruences hold; (3.13) and (3.6) identities hold with max abs diff 0 |

**Verdict: PASS (escalate)** on the Type-D route. **Type G not attempted.**

## What was gated

- Generating function coefficients from \(J_2^2/J_1^5\).
- Theorem 1.1 / 1.2 residue formulas for small \(\alpha\) (covers Andrews–Paule
  (1.2)–(1.6) as special cases).
- Lemma 3.2 modular equation (3.13) with in-paper \(\sigma_i\) polynomials.
- Authors’ GitHub Mathematica supplements cloned under `incoming/pdn1/` (no nested `.git`).

## Capability-limited (not a BREAK)

Full notebook / HolonomicFunctions-style replay and seventh-order equation **(4.8)**
need Mathematica (105-page mod-7 PDF + `.nb`). Not available on the campaign
laptop stack. Same stance as 2(f) OreReduce: record blocked, do not invent
operators.

## Lean

None this landing. PASS → escalate.

## Not done, on purpose

Did not claim a full independent proof of all \(\alpha\). Did not parse Appendix B
into a second modular-equation checker this session.

---

## Gate re-audit (2026-09-20) — audit the auditor

### Defect found: the alpha=2 layer rested on three integers

The gate capped the exact dense series at `PDN1_N = 700`, which is
`O(N^2 log N)` and cannot go much further. At that depth:

| row | data points (old) |
|---|---|
| Thm 1.1 (1.7) alpha=2 | **1** (index 599 only) |
| Thm 1.2 (1.9) alpha=2 | **2** |
| alpha=3, any family | **0** |

The alpha=1 rows reproduce Andrews-Paule base cases already in the literature,
so the genuinely new content — the induction to higher alpha, exactly where such
a paper would break — was carried by about three integers, each with a ~1/25 or
~1/49 chance of holding by coincidence.

### Fix: mod-arithmetic series

Congruence claims need coefficients only modulo a prime power, so the gate now
also builds the series mod `M` via

    J_2^2 / J_1^5 = (J_2/J_1)^2 * (1/J_1^3)

with `J_1, J_2` sparse (Euler pentagonal), `J_1^3` sparse (Jacobi), sparse
inversions `O(N sqrt N)`, and the two dense products by Kronecker substitution
on Python bigints instead of `O(N^2)` convolution.

**Audit the auditor:** `pdn1_fastpath_selftest` requires the fast path to
reproduce the exact dense oracle coefficient-for-coefficient (degree 150,
modulus `10^50`) before any verdict issues. It caught a real sign bug in the
sparse multiply during development.

| | old (`N=700`) | CI now (`N=30000`) | `--deep` (`N=150000`) |
|---|---|---|---|
| runtime | -- | ~7 s | ~105 s |
| data points | **81** | **6 747** | **33 746** |
| alpha reached | 1, 2 | 1, 2, **3** | 1, 2, **3** on all four families |

All rows hold. Thm 1.1 (1.7) reaches alpha=3 at index 14974; Thm 1.2 (1.9) at
11905 and 28712. At `--deep`, Thm 1.1 (1.8) `r = 71, 119` and Thm 1.2 (1.10)
also reach alpha=3. **The congruences survive an 80x (CI) to 420x
(`--deep`) increase in sample size.** This is an escalation, not a kill.

### Hardening

- `residue_thm11` / `residue_thm12` now `assert num % 24 == 0`. Every instance
  through alpha=3 divides exactly, so nothing changes today — but a future alpha
  or `r` would previously have floored silently and tested a progression the
  paper never stated.
- Rows the depth cannot reach are recorded `out_of_range` and excluded from
  `all_ok`, so the meta always shows which alpha were actually exercised rather
  than quietly reporting fewer rows.
- Console output de-unicoded (`U+2261` crashed a cp1252 terminal).

### Attack types not run

Type **G** (logical-gap): nothing here tests whether the induction *closes*,
only that its output congruences are true. Type **E** (notebook / (4.8) replay)
remains capability-limited. A paper's CAS identities being correct is the
expected case even when the surrounding argument fails.
