# Audit note — biplanar graphs with independence number two are 9-colorable (2026-09-28)

**Claim artifact:** Stefan Szeider, *Biplanar graphs with independence
number two are 9-colorable* — no biplanar graph on 19 vertices has
independence number ≤ 2 (negative answer to Gethner–Sulanke 2009 Open
Problem 1(a)); with a Gallai–Edmonds counting argument this gives
9-colorability of every biplanar graph with α ≤ 2.
**Harvest item:** `biplanar-alpha2-9-colorable` (recon rank 3, fragility 1:
`single_author`).
**Campaign objects:** `results/biplanar_alpha2_gate_meta.json`; working
copies at `~/workspace/biplanar-audit/` (Zenodo archive, not committed).

**Archive pin:** https://doi.org/10.5281/zenodo.22913639 —
`biplanar-alpha2-supp-c.zip`, **2,239,936,264 bytes** (size matches the
Zenodo record byte-for-byte), 26,637 entries, extracted 2026-09-28.

**Claim:** the machine-checked core is `earth_moon_19'`
(`final/Order19.lean`): every biplanar graph on 19 vertices has an
independent set of size 3; plus `earth_moon_18'` for the order-18 apex
case the counting argument leaves open.

## Verdict: PASS (verify/audit)

## What was run

| Check | Result |
|---|---|
| `MANIFEST.sha256` over the archive | **23,313/23,313 OK**, zero failures (only the manifest itself is not self-hashed) |
| Enumeration LRAT proofs vs `enumeration/combined{18,19}.cnf`, independently checked with `lrat-check` (built from Heule's source; proofs streamed from zstd, never decompressed to disk) | **both VERIFIED** — combined18: 20,041 vars / 157,486 clauses / 15.6 s; combined19: 27,681 vars / 385,088 clauses / 9.2 GB streamed |
| Teeth: single-literal flip in one LRAT proof line | `c NOT VERIFIED`, exit 1 — fail-closed (a malformed clause ID segfaults lrat-check instead, exactly as the README warns; the Lean import is the check that counts) |
| `certificates/instances/*/res.txt` verdicts | **3,275/3,275 VERDICT=OK**; the one FAIL row is the documented failed first attempt of `cand1184` (Lean recursion-depth limit, retried OK) |
| Clean-room replication (`replication/`): independent Python implementation "written without access to the main code" | covers **exactly** the 3,271 candidates of `data/a8.g6` (set-equal both ways), **all UNSAT** |
| Final-theorem axiom posture (`final/Order19.out.gz`) | `propext`, `Classical.choice`, `Quot.sound` + **6,554** `native_decide` axioms, **no sorryAx** — matches the README's claim exactly |
| Type-G: the three assumed planarity facts (`glue/EarthMoonGlue/Planarity.lean`) | explicit hypotheses X1 (hereditary planarity), X2 (extension to sphere triangulation), X3 (K₉ not biplanar — Battle/Harary/Kodama 1962, Tutte 1963) |

## Code-to-paper fidelity

- The README's multi-level reproduction ladder is accurate everywhere
  this audit could reach: manifest, per-instance verdicts, the
  `cand1184_failed1` documentation, the axiom counts, and the lrat-check
  behavior on corrupted proofs (including the segfault caveat, which the
  README discloses verbatim).
- The enumeration completeness argument — "every graph with the filter
  property is isomorphic to a found graph" — rests on the two LRAT proofs
  this audit verified independently, plus the LeanSMS symmetry-clause
  verification (not re-run here; see scope).
- The 3,275 per-instance SAT refutations (754 GB of LRAT, not stored)
  are covered by: the shipped `res.txt` verdicts with formula SHAs, and
  the clean-room replication re-deriving all 3,271 order-19 UNSAT results
  from an independent encoder.

## Honest scope

- This audit did **not** rebuild the four Lean projects (needs ~25 GB
  disk and its own Mathlib copies; beyond this VM's budget alongside the
  running fluid_lean build) and did **not** re-run CaDiCaL/SMS (the full
  certificate regeneration is 74 CPU-hours). The shipped evidence was
  replayed, not regenerated.
- The three planarity facts are assumed as hypotheses, not formalized —
  but they are classical, uncontroversial textbook results with
  literature citations, stated explicitly as the *only* hypotheses. This
  is the honest, documented boundary of the formalization.
- The headline 9-colorability depends on the paper Gallai–Edmonds
  counting argument (`partition_arith` covers its arithmetic core in
  Lean); the machine-checked part is the 19-vertex / 18-apex theorem.

## Verdict lock

Untouched (25 gates: 17 BREAK / 8 PASS). Standalone verify/audit PASS,
recorded like the other harvest targets.
