# Audit note — five new strongly regular graphs (Zenodo 23296158, 2026-10-12)

**Claim artifact:** A. Kovaľ, *Strongly regular graphs on 306, 400, 576, 784
and 1296 vertices from multi-orbit coset fusion and Bush-type Hadamard
matrices* (Zenodo doi `10.5281/zenodo.23296158`, published 2026-10-11).
Claims explicit constructions of SRGs with parameters (306,55,4,11),
(400,171,74,72), (576,253,112,110), (784,351,158,156) and (1296,595,274,272)
— asserted previously marked "?" (existence unknown) in Brouwer's online
table — plus an infinite family srg(LS_{(n/2-1)}(n)).
**Harvest item:** `koval-strongly-regular-graphs` (weekly scan 2026-10-12,
recon rank 2, fragility 3: `ai_generated`, `single_author`; opaque
SAT-solving search; Hexagon deposit tagged "Primarily AI-generated text /
Human understanding: some parts").
**Pin:** `incoming/koval-strongly-regular-graphs/PIN.md` — DOI, record URL,
retrieval date, md5+sha256 of both files. Both retrieved files byte-match the
Zenodo-declared md5 checksums; every file inside the zip verifies against the
archive's own `MANIFEST_SHA256.txt` (0 mismatches).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills `computational-claim-gate` · run date `2026-10-12`.

Statement-fidelity checklist (M1–M3): N/A in one line — computational-replay
gate; the audited object is the shipped graph data, not a Lean formalization.

## What was run

The archive's standalone stdlib-only exact verifier
(`out/new_srgs_multiorbit/zenodo/verify_srg.py`, sha256
`a9b22e84cf7e61f7…` — matches the sha256 prefix the author's own
`verify_srg.log` header records) was run as shipped, with `--expect` pinning
each file to its claimed tuple. The verifier decodes graph6 itself, computes
every entry of A² exactly with integer bitsets, checks
A² = kI + λA + μ(J−I−A) entry by entry, and checks connectedness; exit 0 iff
all pass.

| File | Expected | Result | Time |
|---|---|---|---|
| `srg306_55_4_11.g6` | srg(306,55,4,11) | OK, connected; complement srg(306,250,205,200) | 108 ms |
| `srg400_171_74_72.g6` | srg(400,171,74,72) | OK, connected; complement srg(400,228,128,132) | 378 ms |
| `srg576_253_112_110.g6` | srg(576,253,112,110) | OK, connected; complement srg(576,322,178,182) | 766 ms |
| `srg784_351_158_156.g6` | srg(784,351,158,156) | OK, connected; complement srg(784,432,236,240) | 1492 ms |
| `srg1296_595_274_272.g6` | srg(1296,595,274,272) | OK, connected; complement srg(1296,700,376,380) | 8867 ms |

Gate: `python3 scripts/verify_claim_project.py --project . --manifest
scripts/gates/koval_srg_claim_manifest.json` → **exit 0, 5/5 claims ok**
(`results/srg_verify_meta.json`, status `pass`, 2026-10-12T14:54:56Z).
The checker derives k/λ/μ from the data and `--expect` rejects any deviation,
so a wrong tuple in any file would have failed the claim. Complement
parameters are computed by the instrument, not asserted — listed for
completeness only.

## Discrimination control: PASS

Per the skill's "Audit the auditor" rule, the SAME shipped checker was run on
two independently constructed inputs (not from the archive): the Petersen
graph (Kneser KG(5,2), built by the auditor) → **exit 0, OK srg(10,3,0,1)**;
the path graph P10 → **exit 1, FAIL not regular**. The instrument
discriminates — the five PASS verdicts are not vacuous. Separate receipt:
`results/srg_control_receipt.md` (control inputs
`results/srg_control_petersen.g6`, `results/srg_control_path10.g6`).

## Brouwer's table check: GAP on the prior-"?" sub-claim

The live table (https://aeb.win.tue.nl/graphs/srg/srgtab.html, fetched
2026-10-12; the old `www.win.tue.nl` URL 301-redirects here) now marks all
five parameter sets **"+" (exists)** with the comment citing **Kovaľ** —
i.e. the table has been updated to record this paper as the existence
reference. The paper itself dates its "?" observation to 10–11 October 2026
(paper tex, §1 and Table 1 caption). The pre-paper "?" state cannot be
independently observed from this host: the Internet Archive is temporarily
offline / rate-limiting (429), so no pre-2026-10-11 snapshot of the table
pages could be retrieved. Recorded as **GAP**: the existence claim is verified,
the "previously unknown" framing is not independently confirmed.

## Residual math (explicitly out of scope)

- **The SAT-solving search** that found three of the graphs (the 306/576/1296
  "hits", `scripts/find2026_10_11/`) was not re-run or re-derived. The gate
  verifies the shipped objects, not the search that produced them.
- **The infinite family** srg(LS_{(n/2-1)}(n)) for Hadamard orders n=4m≥8 is a
  parametric claim; this finite gate does not cover it (the archive's family
  computations need numpy/nauty/GAP per its README and were not re-run).
- Non-isomorphism, automorphism-group, and clique/coclique-number claims in
  the paper were not checked.
- The alternative 1296 constructions (`_latin`, `_latinS3`, `_paley`,
  `hit1296_…`) and the 127 further graphs in the archive were not gated —
  only the five canonical `srg<V>_<k>_<λ>_<μ>.g6` files named in the claim.

## Verdict: PASS (standalone)

The five shipped graphs ARE strongly regular with EXACTLY the claimed
parameter tuples — independently re-verified with the archive's own exact
checker under `--expect`, with a passing discrimination control on the
instrument.

## Receipt

- `incoming/koval-strongly-regular-graphs/PIN.md`
  (sha256 `e04b24d6…c627524`)
- `results/srg_verify_meta.json` (`106f1865…33726e80`), `results/srg_verify_out.txt`
  (`9fba8909…947f94424`), `results/srg_verify_brief.md` (`ffc3e1c4…5ebcd35a32`)
- `results/srg_control_receipt.md` (`860ddff7…d970b1c`) + control inputs
  `results/srg_control_petersen.g6` (`6cc4ea0f…5db2fa82`),
  `results/srg_control_path10.g6` (`8747ef48…d9bec6b22`)
- Gate manifest `scripts/gates/koval_srg_claim_manifest.json`
  (`62c2d1ca…f822635b`); control harness `scripts/gates/koval_srg_control.py`
  (`09f41b77…a8aa7d42`)
- Primary source: Zenodo record 23296158, `new_srgs_multiorbit.pdf` (sha256
  `a6e0e5f8…1d26e28df`), `new_srgs_multiorbit_data.zip` (sha256
  `d5af7ae6…d2832ed4`), both md5-matching the record.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone verify/audit; not a gate
verdict. The prior-"?" framing sub-claim is recorded GAP above.
