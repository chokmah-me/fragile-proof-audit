# Audit note — Pólya's conjecture counterexample (canonization, not refutation)

**Claim artifact:** G. Pólya (1919), L(n) = Σ_{k≤n} λ(k) ≤ 0 for all n ≥ 2 —
disproved by Haselgrove (1958, non-constructive); first explicit counterexample
Lehman (1960), n = 906,180,359; smallest counterexample Tanaka (1980),
**n = 906,150,257**, L(n) = +1.
**Campaign objects:** `docs/blueprint/polya.md`, `polya/src/liouville_sieve.c`,
`polya/src/liouville_sieve2.py` (independent), `polya/certs/` (91 chunk
certificates + SHA-256 manifest), `polya/src/verify_certs.py`,
`FragileProofAudit/Polya/Liouville.lean`, `FragileProofAudit/Polya/SieveCheck.lean`.

## Certificate (canonization · instance · pinned value)

| Field | Content |
|---|---|
| **Claim** | L(n) ≤ 0 for 2 ≤ n < 906,150,257; L(906,150,257) = +1 (Tanaka's smallest counterexample, independently recomputed) |
| **Instance** | 91 chunk certificates (10M chunks) over [2, 906150257]; each pins chunk Σλ, max internal prefix, first-crossing fields; SHA-256 manifest |
| **Pinned value** | Two independent sieves agree: L(10⁹) = −25216, first crossing 906150257, max 829 at 906316571; verifier 370/370 checks PASS |
| **Lean slice** | `polya_holds_to_100`: kernel-checked L(n) ≤ 0 for 2 ≤ n ≤ 100, axioms only [propext, Classical.choice, Quot.sound] — a checked slice, not the full prefix (chunk certs are the evidence there) |

**Verdict: v1 BANKED (2026-09-23).** Trust-anchor artifact in the Gomila mold
(audit PASS). This is **not a BREAK** and does not extend the 23/23 verdict
lock — the conjecture died in 1958; the campaign's contribution is the
machine-checked corpse. Note L(1) = +1 trivially, so every statement is
explicitly scoped to n ≥ 2.
