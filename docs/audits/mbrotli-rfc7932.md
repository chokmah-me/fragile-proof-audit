# Audit note — mbrotli Level-1 Lean 4 proofs vs RFC 7932 and RFC 9841 (m-compressors/mbrotli)

**Claim artifact:** the public Rust crate
`github.com/m-compressors/mbrotli` and its project
post "Towards formal verification: mbrotli and
mzstd" (M-Compressors, 2026-10-29), which announce
Lean 4 proofs that parts of the crate follow
RFC 7932 (Brotli), with RFC 9841 large-window
items. The Lean project lives in `verification/lean`
(toolchain `leanprover/lean4:v4.35.0`): Charon/Aeneas
translate listed Rust items into Lean, a hand-written
`Mbrotli/Rfc.lean` transcribes the RFC tables, a
hand-written `Mbrotli/Model.lean` restates the
section 4 distance arithmetic, and hand-written
theorems connect the translation to both. The
verification landed in PR #13 (merged `b061a20`,
first checks `6b377ad`, 2026-10-25).
**Feed pick:** second target of the same Feed item
as the mzstd audit (`docs/audits/mzstd-rfc8878.md`,
main@c21ab89); the pick assessment set mzstd first
and mbrotli second, with the same scope: spec
fidelity, a local kernel replay at the pin, and a
trusted-base inventory. Executed 2026-10-29 at the
user's word after the mzstd audit closed. Scope
label: distance, length and command arithmetic and
tables (RFC 7932 sections 4, 5, 7.2, plus the
RFC 9841 large-window distance items) only.
**Campaign objects:** `incoming/mbrotli-rfc7932/PIN.md`.
**Pinned sources:** repository tarball
(`git archive`) at the pinned commit
03eaa75d3444a0d9dfcf2eab595761ef67e18b66, sha256
8066df83aa79f64673dcd7d497a497de7a6dd50c3e3b2d83ac830c4bde25281e;
RFC 7932 text, sha256
394abd1879e016f4eac89512c2acaf92f7b2d67feb8ab58b6b118c213be07146;
RFC 9841 text, sha256
88711e3f33ad7e3e9e7f1c35b60cd8c85095bfe7fab9555dcc9154caa0537042;
project post HTML (staged under the mzstd audit,
fetched 2026-10-29), sha256
d31d74cd4bc50ba91481e53eff6774110eddff82d2164ebb7a4c3442e1e35d14.
Evidence in `~/workspace/mbrotli-recon/`
(`EVIDENCE.md` as the receipt index, sha256
0f6b141ec734d37119e41857afe54ffcdf2b20312d7a56720186fc014916b23c;
`build.log` sha256
e73d82a3e17db971d6a7510929a70a3e26b95a576c3f61a7f473e42d1f1d3115;
`axioms-all.log` sha256
7e1f0edec4baae4c40fe0d7d2e5bf151c9846ee727676e1fc406f0e26beab5f1;
`haiku-doublecheck/`, `argon-check/`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-29` · harness pin via
`scripts/harness_pin.py`. Two independent
double-checks were run and adjudicated in the open
before landing: Haiku 5.5
(`anthropic/claude-haiku-5.5` via OpenRouter, effort
medium, $0.0043638) and Argon
(`google/gemini-4-argon` via OpenRouter, effort
medium, $0.02914) with the local contract-breaker
and contract-certifier skills. Both upheld the
overall verdict; their M1 section 4 and M2 labelling
hits landed as the grade split in section M1, the
corrected trace count in section M2, and the third
fence in the verdict line.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-29T18:16:28Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## 1. The audit object and the fences

The proofs cover the Level-1 items of the authors'
own coverage checklist in
`architecture/formal-verification.md`: explicit
distance codes on both sides including large-window
streams (section 4), the sixteen short codes and
the ring of last distances (section 4), insert and
copy length codes and the 704-symbol command table
(section 5), and command packing. Fenced out, by
the pick scope and the authors' own checklist:
section 6 block counts and types (where the
C decoder's CVE-2026-111497 lived; the authors note
a sibling accept-what-it-should-reject deviation in
mbrotli 0.5.16, fixed in 0.5.17 — outside this
audit's scope either way); the decoder command
loop, which adds the extra fields to the table's
bases and is not translated; the `experimental`
branches for long RFC 9841 transforms; bit order
(Level 2), prefix codes (section 3), the context
map (section 7.3), dictionary transforms
(section 8), and the Level 3 reference decoder.
The Charon/Aeneas drift replay
(`scripts/extract_lean.py --check`) was not run;
it is a GAP fence in section 5.

## 2. Kernel replay at the pin (PASS)

On the auditor's VM (Lean 4.35.0 already installed;
the Mathlib cache is the same one the mzstd audit
used, both repositories pinning the same Aeneas
commit and Mathlib revision, recorded in M4):
`lake exe cache get` exit 0 in 321 s, then
`lake build` exit 0 in 273 s, 1,817 jobs, all
`Mbrotli` modules built locally including
`Mbrotli.Audit`. Axiom audit, independently of the
target's own guards: a scratch file importing
`Mbrotli.Audit` printed `#print axioms` for all 12
theorems `Audit.lean` guards; every one depends on
exactly `[propext, Classical.choice, Quot.sound]`,
matching its `#guard_msgs` expectation (the
expectations are the target's pinned file, committed
before this audit). Escape grep over the whole
`verification/` tree including `lakefile.lean`:
zero hits for `sorry`, `native_decide`,
`implemented_by`, `extern`, `opaque`, `unsafe`, or
axiom declarations outside the Audit prose.

## M1 — statement

Split grade, after the double-checks.
The transcription in `Mbrotli/Rfc.lean` (105 lines)
passes in full. Section 5 insert and copy rows were
diffed programmatically (RFC tables parsed vs the
Lean lists; exact match, 24 + 24 rows). The
704-symbol cell diagram was mapped block by block
against the RFC figure (11 blocks of 64), and the
insert/copy code bit rules (bits 3..5 and 0..2),
implicit distances (symbols 0..127), the sixteen
short codes, the initial ring `[4, 11, 15, 16]`
most-recent-first (the RFC's "16, 15, 11, and 4"
from fourth-to-last to last), and the section 7.2
distance context (IDs 0, 1, 2, 3 for copy lengths
2, 3, 4, more than 4) all match the RFC text. The
composite predicate the command table is proved
against, `Command.Rfc` (`DecoderCommands.lean:44`),
was read in full: it equates every entry field to
one of these checked primitives (row bases and
extra bits via `insertCode`/`copyCode`,
`implicitDistance`, and `distanceContext` for every
length in the copy row's range), so a single-field
mutation falsifies its conjunct by construction;
the `cellValue_insert`/`cellValue_copy` `decide`
theorems tie the Rust `CELLS` packing to the
transcribed cells.
The section 4 explicit-distance arithmetic is not
in `Rfc.lean`: it is `Model.decode` / `Model.width`
in `Model.lean`, a hand-written model. Both were
checked algebraically against the RFC formulas
(`ndistbits = 1 + ((dcode - NDIRECT - 16) >>
(NPOSTFIX + 1))`; `offset = ((2 + (hcode & 1)) <<
ndistbits) - 4`; `distance = ((offset + dextra) <<
NPOSTFIX) + lcode + NDIRECT + 1`) and match, as do
the standard alphabet size `16 + NDIRECT +
(48 << NPOSTFIX)` and the large-window alphabet:
RFC 9841 states it as `(16 + NDIRECT + (124 <<
NPOSTFIX))`, which is exactly the bound
`16 + direct + 2 * 62 * 2^postfix` the large
theorems use (62 is RFC 9841's maximum number of
extra bits). This leg is graded formula-checked,
not transcription-proved: the authors themselves
list `Model.decode`/`Model.width` in their trusted
base, and it is carried in M4 below.

## M2 — argument

Spot scope, as picked, with the count corrected
under the double-checks: 3 of the 12 guarded
theorems were traced, plus one adjacent unguarded
spec. `distance_round_trip`
(`DistanceRoundTrip.lean:55`): header byte below
64, postfix and direct counts tied to that byte,
distance code in range; the encoder's
`prefix_encode_copy_distance` output resolves
through the decoder layout back to
`d + 15 = distance_code` in the crate's internal
representation. `commands.spec`
(`DecoderCommands.lean:166`): no precondition;
every one of the 704 command-table entries
satisfies `Command.Rfc` (section M1).
`DistanceLayout.resolve.spec`
(`DecoderDistanceResolve.lean:242`): postfix at
most 3, direct at most 120, symbol inside the
layout's alphabet, extra field of its width for
explicit symbols; the `Ok` branch is exactly
`rfcDistance` with its range side condition and
the `Err` branch is the distance error with the
exact failure condition, split short vs
large-window, so the statement is not vacuously
satisfiable by an always-error function.
`DistanceLayout.resolve_large.spec` (same file,
line 208, not one of the 12 guarded) has the same
two-branch shape for the large alphabet. The
remaining 9 guarded theorems were not traced, and
all traces rest on the committed translation
files, because the drift replay was not run
(section 5). Within that stated scope, the
statements say what the theorems prove.

## M3 — credit

No overclaim found in the post or in
`architecture/formal-verification.md` at the pin
(the doc is inside the pinned tarball above, whose
hash covers it). The authors fence the unproved
coverage themselves (section 1), name Charon/Aeneas
faithfulness as their largest assumption, list
`Model.decode`/`Model.width` in their own trusted
base, and list four mutation checks (the checks are
the authors' listed checks; this audit did not
re-run them). The post's line counts match the
pinned tree (generated 1,937 + 128 lines).

## M4 — fine print

Trusted base, recorded as trusted, not verified:
Charon/Aeneas MIR translation faithfulness
(mutation-tested by the authors, not proved); the
Aeneas Lean models of the scalar operations used
(`leading_zeros`, shifts, casts, `wrapping_*`);
nightly MIR matching release behaviour; the four
hand-written standard-library models in
`Code/FunsExternal.lean` (`u64::try_from(u128)`,
`u64::checked_add_signed`, `Option::ok_or_else`,
`Option::filter`; inspected, faithful to their
documented semantics on reading); translation
freshness of the committed generated files against
the Rust source (the drift replay was not run);
prebuilt Mathlib and Aeneas-library oleans from the
lake cache, shared with the mzstd audit because
both repositories pin the same Aeneas commit
(74aabd52f77001cf9eaad51b4f4b867a7dc6b111) and
Mathlib revision (common-mode across the two
audits, recorded here; each crate's own modules
were built locally in both); the Lean kernel and
the three standard axioms; and `Model.decode` /
`Model.width` as the section 4 specification layer
(formula-checked in M1, not proved against the
RFC). The interface between the proved distance
arithmetic and the untranslated decoder command
loop (which pushes to the ring, and adds the extra
fields) is part of the Level 2 fence. Residual per
item: if Charon/Aeneas faithfulness failed, every
theorem in scope would weaken to a statement about
the translation alone; if translation freshness
failed, the theorems would describe a stale
snapshot at or before the pin; if the Model leg
failed, the section 4 theorems would describe the
model, not the RFC; the other items are narrow.

## 5. Fences (GAP)

The Charon/Aeneas drift replay
(`scripts/extract_lean.py --check`) was not run: it
downloads the pinned Aeneas bundle and installs its
nightly Rust toolchain, a separate gate from the
kernel replay. The M2 trace coverage (3 of 12
guarded, section M2) is the second fence, and the
section 4 model leg (M1/M4) is the third.
Everything outside the scope label in section 1 is
out of scope, not audited, and carries no verdict
here.

**Verdict: PARTIAL** — the `Rfc.lean`
transcription (M1) and the local kernel replay at
the pin (section 2) both pass in full; the overall
verdict is held at PARTIAL by the three fences
above (the unrun drift replay, the M2 spot scope,
and the formula-checked section 4 model leg), not
by any failure.
