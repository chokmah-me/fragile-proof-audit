# Audit note — de Bruijn–Newman constant, classical-strip comparison (arXiv:2610.18214, 2026-10-13)

**Claim artifact:** Michel Planat, *A certified classical-strip
comparison for the de Bruijn-Newman constant* (arXiv:2610.18214v1,
submitted 2026-10-13), and its ancillary certificate bundle
(`anc/certificate/` in the e-print: `verify.py`, 12 Python checkers,
inputs, histories, receipts). There is no Lean formalization in
this target; the machine-checked object is an exact-rational
comparison certificate, and the analytic half of the claim is
carried by three explicitly stated premises.
**Harvest item:** issue #6 (weekly scan 2026-10-16), card 4,
fragility 1, signals `single_author`.
**Campaign objects:** `incoming/de-bruijn-newman-planat/PIN.md`.
**Pinned sources:** paper PDF sha256 `bd90329e…d3ab6a8`, e-print
tarball `4599b663…6ed5b` (per PIN); working copies in
`~/workspace/dbn-planat-sources/`, replay copies and receipts in
`~/workspace/debruijn-planat-recon/`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · run date
`2026-10-18`. The paths that could carry or kill this claim were
enumerated before the replay: statement drift between the abstract,
thm:main, and `NUMERICAL_RESULT.json`; certificate replay
(receipt lane); history regeneration (regenerate lane); manifest
integrity of the shipped bundle; premise smuggling (in particular
the fenced 7/8-hypothesis supplement); credit and disclosure.
Each gets a named check below.

**Scope of this audit:** M1 statement correspondence (printed
claim vs the quantities the certificate produces and consumes),
M2 argument correspondence (structural, from the TeX), M3 credit
honesty, M4 fine-print inventory, plus a two-lane replay of the
author's verifier on this VM. The analytic premises (A1)–(A3)
were **not** independently validated — the paper declares the
same of itself (see M2). No Lean build exists to run.

## The claim and its conditional structure

The headline (paper thm:main, §1): under premises (A1)–(A3),

Λ ≤ 148611789321711/10^15 = 0.148611789321711 < 0.148612.

The theorem statement names its own premises, and the two
sentences after it are part of the claim as published: "The
conclusion is an implication under explicit analytic premises.
The rational certificate proves the numerical comparison once
those premises are supplied; it does not prove its own
interpretation as a statement about H_t." And: "A claim that it
is an established unconditional record would require validation
of the complete analytic assembly." The premises (§3,
subsec:ledger):

- **(A1) Complete model-to-function source correspondence.** For
  each provider, cell and shift, Raymond's corrected
  approximation, its labelled correspondence, denominator
  exclusion and physical transfer hold uniformly on the full
  physical domains, with the complete amplitude/moment
  enclosures, exceptional debits, phase credits and physical
  error allowances of the original source assembly.
- **(A2) Finite localisation.** The retained finite-head wall is
  valid for the true function on x = ±X, |Im z| ≤ 1,
  0 ≤ t ≤ 41/250, and the finite-RH input plus a homotopy
  argument exclude nonreal zeros from |Re z| ≤ X in that range.
- **(A3) Uniform global contact reduction.** On each compact
  positive-time interval used, the real-simple tail, confinement
  and local zero-motion framework supply compactness for a
  prospective first contact, and the backward Hermite splitting
  rule applies at a multiple zero.

The audit therefore scores the implication as published, not an
unconditional bound. Baselines: Platt–Trudgian's finite-RH
verification carries the published consequence Λ ≤ 0.2; the
user's Gomila audit (Λ ≤ 0.1787854) closed PASS on 2026-09-23.
Planat's 0.148611789321711 would improve both **if** (A1)–(A3)
validate; the conditionality is a difference in kind, recorded
here rather than smoothed over.

## M1 — Statement correspondence: PASS

Every quantitative component of the printed claim matches the
certificate's own records exactly (receipt lane, this VM; see
Receipt):

| # | Printed claim (source) | Certificate record | Match |
|---|---|---|---|
| 1 | Λ ≤ 148611789321711/10^15 = 0.148611789321711 (abstract; thm:main eq:main) | `NUMERICAL_RESULT.json`: `upper_exact` 148611789321711/1000000000000000, `upper_decimal` 0.148611789321711; auditor line `FULL_JMAA_FINITE_CERTIFICATES_PASS 0.148611789321711` | exact |
| 2 | 57 fixed translated kernels (abstract; thm:main; Appendix app:kernels) | geometry receipt: `kernels` 57, `leaves` 434, `new_kernel_leaves` 393; log line `GEOMETRY_57_PASS 57 434 NEW_KERNEL_LEAVES 393` | exact |
| 3 | "a separate exact-rational auditor accepts all 19,023 comparison steps" (abstract) | `NUMERICAL_RESULT.json`: `comparison_steps` 19023; refined audit provider steps 8512 + 10511 = 19,023 | exact |
| 4 | "The controlled decrease from the complete two-source comparison is 0.000021760452379" (abstract) | receipt field `exact_gain` 21760452379/1000000000000000 = 0.000021760452379; and 0.148633549774090 − 0.000021760452379 = 0.148611789321711 (recomputed) | exact |
| 5 | Two-source comparison is the previous ceiling (intro; §5) | `NUMERICAL_RESULT.json`: `previous_upper_exact` 14863354977409/100000000000000 = 0.148633549774090; comparison record `classical_two_sources` upper 0.148633549774090 | exact |
| 6 | Directed tail enclosures at 192 and 256 bits (abstract; thm:main) | `NUMERICAL_RESULT.json`: `native_precision_bits` [192, 256]; `inputs/DIRECTED_192.json`, `inputs/DIRECTED_256.json` in the manifest | exact |
| 7 | 552 refined provider cells (§7 assembly) | log line `SECTION7_EXACT_AUDIT_PASS 552 [6528, 6528]`; `NUMERICAL_RESULT.json`: `refined_provider_cells` 552, `phase_prefixes_per_lane` 6528, `time_cells` 276 | exact |
| 8 | No zero-free half-plane hypothesis H_α, α < 1, is used (thm:main, closing sentence) | every comparison record carries `seven_eighths_assumed: false`; `NUMERICAL_RESULT.json`: `seven_eighths_used: false` | exact — the §9 supplement (Raymond's ceiling below 0.116398 under the 7/8 hypothesis) is fenced off from thm:main in the records, not only in the prose |

### The encoding points (where M1 usually fails)

- **The conditionality is inside the theorem, not a footnote.**
  thm:main opens "Assume the true-function source, finite
  localisation and uniform first-contact premises (A1)–(A3)".
  An unconditional reading of the headline is a misreading of
  the printed statement; the audit found no place where the
  paper itself drops the premises while keeping the number
  (abstract, §1, §5, §8 checked).
- **The gain arithmetic closes.** The headline is the
  two-source ceiling minus the §7 gain, with both quantities
  printed as exact rationals and reproduced by the replay
  (row 4). There is no rounding step between the certificate
  and the printed bound: `strict_bound` in
  `NUMERICAL_RESULT.json` is the abstract's "< 0.148612".
- **Raymond's classical-strip ceiling** (0.149395073827688,
  intro, citing `raymondclassical`) sits above all four
  certified comparisons in the ladder (M2), consistent with
  the paper's positioning of its own comparisons as
  improvements inside Raymond's framework rather than
  replacements of it.

## M2 — Argument correspondence: qualified (finite half replayed; analytic half is premise, by the paper's own design)

Label: *the implication's finite half is machine-checked and
replayed; the analytic half is carried by (A1)–(A3), whose
validation the paper itself declares incomplete.*

- **Structure.** §2 develops the collective-contraction /
  translated-observation machinery and the rational
  certification of the 57 fixed kernels. §3 states the source
  correspondence and the premises, and imports the
  Platt–Trudgian finite-RH verification (Thm 1 of [pt],
  T* = 3000175332800) for (A2)'s clearance. §4 runs the
  directed classical-strip certificate (strict separation near
  time zero; the terminal step). §5 tabulates the controlled
  comparisons and the verification boundary. §6 proves a
  matched logarithmic tail transfer (a compatible refinement,
  not the headline path). §7's explicit finite Weyl tails and
  centred cone transfer produce the numerical gain. §8 is
  reproducibility and remaining work. The proof of thm:main
  (§4) consumes (A1)–(A3) plus the certificate; nothing else
  is load-bearing for eq:main.
- **The comparison ladder, replayed.** Both verifier lanes on
  this VM reproduce all four certified ceilings:
  `classical_old_kernels` 0.149056792554129 (19,080 steps);
  `classical_new_kernels` 0.148639484094797 (19,026 steps);
  `classical_two_sources` 0.148633549774090 (19,026 steps);
  the §7 refined scalar audit 0.148611789321711 (19,023 steps,
  providers 8512 + 10511). Each record carries
  `physical_source_is_an_external_analytic_premise: true` —
  the certificate itself marks where its inputs stop being
  self-produced.
- **What the replay is, and is not.** The two lanes rerun the
  author's own checkers: the receipt lane re-audits the shipped
  histories and receipts; the regenerate lane rebuilds all four
  classical histories in a temporary directory and compares
  their compressed bytes with the supplied files
  (`RATIONAL_HISTORY_BYTES_MATCH`). Independence in these lanes
  comes from exact-rational arithmetic, the manifest, and the
  negative controls (M3) — not from a second implementation.
  An independent re-derivation of the comparison from the
  paper's definitions remains the stronger audit and was not
  attempted (the harvest recon card said the same).
- **The premises were not validated here.** (A1) rests on
  Raymond's source assembly (three cited works, supplied
  manuscript and data; see M3). (A2)'s finite-RH input is
  imported, not rerun — by the paper ("The finite-RH
  computation is imported, not rerun") and by this audit.
  (A3) is a written analytic argument. The paper states the
  position plainly (§3): "The supplied evidence supports these
  premises, but their complete mathematical validation has not
  been independently completed in this audit." This audit's
  M2 qualification is the same statement from the other side.

## M3 — Credit honesty: PASS, with one packaging finding recorded

- **Prior art is credited at the point of use.** de Bruijn and
  Newman for the existence and strip-contraction results;
  Rodgers–Tao for Λ ≥ 0; Polymath for the normalisation and
  the barrier arguments; Platt–Trudgian both for the finite-RH
  input and for the published consequence Λ ≤ 0.2 that it
  already carries. Raymond's three works are cited for the
  translated-probe construction, the source data, and the
  prior classical-strip ceiling 0.149395073827688.
- **The Raymond acknowledgement is exact about endorsement:**
  "The author acknowledges Dale James Raymond's supplied
  manuscript, source evidence and analytic foundations. Their
  use and independent numerical rechecking do not imply
  Raymond's endorsement of this new classical-strip transfer."
- **AI assistance is disclosed, with the right limit stated:**
  "OpenAI ChatGPT assisted in the derivations, manuscript
  preparation, code reimplementation and recorded arithmetic
  checks. AI assistance, agreement of programs and successful
  replay do not constitute external mathematical refereeing."
  The harvest signal for this card was `single_author` only;
  the disclosure is in the paper, unprompted.
- **The machine records are as honest as the prose.**
  `NUMERICAL_RESULT.json` and both replay receipts carry
  `analytic_premises_independently_completed: false`,
  `native_libraries_independent: false`, `finite_RH_repeated:
  false`, `physical_samples: 0`. The cone-fixture block scopes
  itself: "Abstract exact algebra; physical rectangles are
  enclosed separately." Nothing in the shipped records claims
  a check that was not run.
- **Negative controls bite.** The receipt's negative-control
  suite passes with all 9 tampered cases rejected (missing
  strip cushion; changed source identity; wrong provider;
  wrong physical height; omitted own pair; inflated source
  floor; time gap; downward restart; wrong external-strip
  status). The auditor refuses the inputs it should refuse.
- **Packaging finding (WEAKENS the shipped artifact, not the
  claim).** As shipped in the e-print, `verify.py` fails out of
  the box: `SHA256SUMS.json` names 8 files as `.json.gz`
  (`histories/classical_{new_kernels,old_kernels,section7,
  two_sources}.json.gz`, `inputs/DIRECTED_{192,256}.json.gz`,
  `inputs/EXACT_PARENT_CASES.json.gz`,
  `receipts/SECTION7_SECTION7_SOURCE_AUDIT.json.gz`) that are
  absent; the same 8 payloads ship decompressed as `.json`.
  Deterministic re-gzip (mtime 0, no stored filename) of the
  shipped payloads reproduces all 8 manifest SHA-256s and byte
  counts exactly, and the manifest then verifies 54/54
  (`INTEGRITY_PASS 54`). Content integrity is intact; the
  defect is packaging only, and it is the kind a first
  replicator hits in the first minute.

## M4 — Fine-print inventory (Murray & van Oorschot; load-bearing items)

For each: what it is, the tag, the residual if it fails, and
which downstream claims inherit it. Tags: source-faithful /
convenience-only / risk-inducing.

1. **(A1) complete source correspondence** (premise, §3).
   Risk-inducing (external analytic premise; rests on
   Raymond's source assembly). If it fails: the implication's
   antecedent fails and eq:main says nothing about Λ —
   *evaporates* as a bound, while the certificate arithmetic
   stands untouched. Inherits: the headline bound and every
   comparison in the ladder (each record flags
   `physical_source_is_an_external_analytic_premise: true`).
2. **(A2) finite localisation + imported finite RH** (premise,
   §3). Risk-inducing (external, by Platt–Trudgian). The seam
   arithmetic recomputed here: X = 6000000185827 (main.tex,
   §3), so (X+1)/2 = 3000000092914 and
   T* − (X+1)/2 = 3000175332800 − 3000000092914 = 175239886 > 0,
   exactly the paper's printed clearance. If the imported
   verification failed, the wall's zero-exclusion fails with
   it: *evaporates* for the strip argument. Tag on the import
   itself: source-faithful (declared as imported in both the
   paper and `NUMERICAL_RESULT.json`'s assumption string).
3. **(A3) uniform global contact reduction** (premise, §3).
   Risk-inducing (written analytic argument: compactness for a
   prospective first contact, Hermite splitting at a multiple
   zero). If it fails: the first-contact argument does not
   close, and the comparison bounds a model problem rather
   than H_t — *evaporates*. No machine check bears on it in
   either direction.
4. **Native tail stage not regenerated** (inputs
   `DIRECTED_192/256.json`). The directed enclosures at
   192/256 bits are consumed by both replay lanes, not
   regenerated: both receipts carry
   `native_transcendentals_regenerated: false` and
   `native_libraries_independent: false`. Regeneration needs
   the FLINT/Arb lane (the bundle's `Proof_and_Replay.zip`
   runtime or an installed compatible FLINT library, per the
   paper's reproduction appendix) and was not attempted.
   Tag: convenience-only for the replay as run (the enclosures
   are hash-pinned inputs, verified against the manifest);
   risk-inducing for end-to-end independence — a defect in
   the native production would pass both lanes silently.
   Inherits: the §7 gain and hence the headline's last digits.
5. **Zero physical frequency samples in the fixtures**
   (`physical_samples: 0`; cone fixtures scoped "abstract
   exact algebra", `physical_source_enclosure: false` in the
   matched-tail block). Tag: source-faithful — the fixtures
   certify the algebra of the cone transfer; the physical
   rectangles enter only through item 4's directed inputs.
   A reader who takes the fixture PASSes as physical
   verification overstates the certificate; the records
   themselves do not.
6. **Self-built pipeline, self-attested receipts** (the whole
   bundle). Tag: risk-inducing for independence, mitigated by
   construction: exact-rational auditors, a 54-entry hash
   manifest, byte-identical history regeneration, and 9/9
   negative controls. What is missing is any second
   implementation. The harvest recon's code note stands: an
   independent re-derivation is the real audit; this note's
   replay is the floor, not the ceiling.
7. **The 7/8 supplementary ceiling** (§9: Raymond's ceiling
   below 0.116398 under the distinct H_{7/8} zero-free
   hypothesis, plus a derivative pilot). Tag: convenience-only
   as published (fenced in a supplementary section, excluded
   from thm:main, `seven_eighths_used: false` verified in the
   records); risk-inducing for readers — a summary that merges
   §9 into the headline overstates this paper's claim by
   0.032 in Λ. The pilot's own boundary is stated in its
   subsection title ("and its boundary").
8. **Companion paper, same author** (arXiv:2609.37164,
   "Collective Contraction in the de Bruijn–Newman Heat Flow",
   endpoints Λ ≤ 0.149344833997286 and Λ < 0.157371218).
   Tag: convenience-only. A different route to weaker
   endpoints; not an input to thm:main. Recorded so the two
   Planat numbers in circulation are not conflated with this
   certificate's 0.148611789321711.
9. **Packaging defect** (M3). Tag: convenience-only for trust
   (content hash-verified after a deterministic repair);
   risk-inducing for replication uptake — the bundle as
   shipped does not run its own documented first command.

**Dangling check.** The conjunction is coherent: the ladder is
monotone (0.149056792554129 → 0.148639484094797 →
0.148633549774090 → 0.148611789321711), the gain closes the
last step exactly, the step counts are consistent
(8512 + 10511 = 19,023 for the refined audit; 276 time cells ×
2 providers = 552 refined cells), and the imported clearance
is positive by a wide margin (175,239,886 ordinate units).
No contradiction found between the paper, the records, and
the replay.

## Receipt

- `incoming/de-bruijn-newman-planat/PIN.md` — paper PDF and
  e-print SHA-256s, bundle inventory, packaging note, replay
  environment.
- **Certificate replay (closed 2026-10-18, this VM, Python
  3.12.3, standard library only), run on a copy of the shipped
  bundle after the packaging repair in M3:**
  - Receipt lane: `python3 verify.py --receipt` → EXIT 0
    (20.8 s by the receipt's own timer). Lines:
    `INTEGRITY_PASS 54`; `SECTION7_EXACT_AUDIT_PASS 552
    [6528, 6528]`; `GEOMETRY_57_PASS 57 434 NEW_KERNEL_LEAVES
    393`; `FULL_JMAA_FINITE_CERTIFICATES_PASS
    0.148611789321711`. Receipt saved as
    `~/workspace/debruijn-planat-recon/verify-receipt-run1.json`
    (top-level `PASS: true`).
  - Regenerate lane: `python3 verify.py --regenerate` →
    EXIT 0 (33.1 s), the same four PASS lines plus
    `RATIONAL_HISTORY_BYTES_MATCH` (all four classical
    histories rebuilt in a temporary directory, compressed
    bytes identical to the supplied files). Receipt saved as
    `~/workspace/debruijn-planat-recon/verify-receipt-regen.json`.
  - Both receipts self-report the same scope flags:
    `analytic_premises_independently_completed: false`,
    `native_transcendentals_regenerated: false`,
    `finite_RH_repeated: false`.
- **GAPs (explicit):** (i) premises (A1)–(A3) not
  independently validated — the analytic assembly is outside
  both lanes, as the paper declares; (ii) the native FLINT/Arb
  tail production not regenerated — the directed enclosures
  were consumed as hash-pinned inputs (M4 item 4); (iii) no
  independent re-derivation of the comparison from the paper's
  definitions was attempted — the replay runs the author's own
  checkers (M4 item 6).

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
audit of harvest issue #6's card 4: **M1 PASS** — the printed
claim is the implication under (A1)–(A3), stated inside
thm:main itself, and every quantitative component (the exact
rational bound, 57 kernels, 19,023 steps, the 0.000021760452379
gain over the two-source ceiling, 192/256-bit enclosures, the
7/8 fence) matches the certificate's records exactly;
**M2 qualified** — the finite half of the argument is
machine-checked and replayed in both lanes on this VM, the
analytic half is premise by the paper's own design and
declaration, and this audit did not validate it either;
**M3 PASS** — prior art, the Raymond non-endorsement, the AI
assistance, and the records' own scope flags are all stated
where they belong, with one packaging finding recorded (the
shipped bundle's verifier fails out of the box on 8
decompressed files; deterministic re-gzip restores all 54
manifest hashes exactly, content integrity intact);
**M4 PASS as catalog** — the standing risks are the three
premises and the unregenerated native tail stage, all declared
in the paper and its records.
