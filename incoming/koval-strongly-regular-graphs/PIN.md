# Intake pin — koval-strongly-regular-graphs (harvest 2026-10-12, rank 2)

**Claim:** Five new strongly regular graphs with parameters (306,55,4,11),
(400,171,74,72), (576,253,112,110), (784,351,158,156), (1296,595,274,272),
all previously marked "?" (existence unknown) in Brouwer's SRG table, plus
an infinite family srg(LS_{(n/2-1)}(n)).

**Primary source (Zenodo):**
- DOI: `10.5281/zenodo.23296158`
- Record URL: https://doi.org/10.5281/zenodo.23296158
- API record: https://zenodo.org/api/records/23296158
- Title: *Strongly regular graphs on 306, 400, 576, 784 and 1296 vertices
  from multi-orbit coset fusion and Bush-type Hadamard matrices*
- Publication date (per record): 2026-10-11
- Retrieval date (UTC): 2026-10-12T14:52-14:53Z (agent run)
- Access: open

**Files (retrieved via `https://zenodo.org/api/records/23296158/files/<name>/content`):**

| File | Size (bytes) | md5 (Zenodo-declared) | md5 (retrieved) | sha256 (retrieved) |
|---|---|---|---|---|
| `new_srgs_multiorbit.pdf` | 692296 | c21c4c841216381e48130c2416a3ccd2 | c21c4c841216381e48130c2416a3ccd2 MATCH | a6e0e5f8b1f2e9a1830b22cfe1ab6c6c4aa6007f796eb9397e2b1541d26e28df |
| `new_srgs_multiorbit_data.zip` | 4943516 | 230e8b9e6d69bca9bb63d6d5988f4c0c | 230e8b9e6d69bca9bb63d6d5988f4c0c MATCH | d5af7ae69281364f558f05c3cad1518f0bf953e88d8532f68ecbed0dc2832ed4 |

Both retrieved files byte-match the Zenodo-declared md5 checksums.

**Zip contents** (see `unzip -l` output captured during audit):
- extraction target: `incoming/koval-strongly-regular-graphs/data/`
- (listed below after extraction; archive itself is the pinned input)

**Audit scope:** the load-bearing auditable claim is that the five shipped
graphs ARE strongly regular with EXACTLY the claimed parameter tuples.
The SAT-solving search step that found three of the graphs is EXPLICITLY
OUT OF SCOPE (recorded as residual in the audit note); this gate does not
re-derive the graphs, it verifies the shipped objects.
