# Audit note — mzstd Level-1 Lean 4 proofs vs RFC 8878 (m-compressors/mzstd)

**Claim artifact:** the public Rust crate
`github.com/m-compressors/mzstd` and its project post
"Towards formal verification: mbrotli and mzstd"
(M-Compressors, 2026-10-29), which announce Lean 4
proofs that parts of the crate follow RFC 8878
(Zstandard). The Lean project lives in
`verification/lean` (toolchain
`leanprover/lean4:v4.35.0`): Charon/Aeneas translate
listed Rust items into Lean, a hand-written
`Mzstd/Rfc.lean` transcribes the RFC, and hand-written
theorems connect the translation to the transcription.
First (and at the pin, only) verification commit:
`27e3028` (2026-10-26).
**Feed pick:** the project post arrived as a Feed
item; the pick assessment (mzstd first, mbrotli
second, scoped to Rfc.lean fidelity, a local kernel
replay, and a trusted-base inventory) was worked
2026-10-29 and the audit proceeded at the user's
word the same day. Scope label, per the double-check
below: Level-1 headers, codes and tables only.
**Campaign objects:** `incoming/mzstd-rfc8878/PIN.md`.
**Pinned sources:** repository tarball
(`git archive`) at the pinned commit
0a4fd87e1c7ea6e7e96771de315022008d77db37, sha256
f5e27c2f7008e4f7623bfd1d1bceabc40ccc790eb9b35d35581ad542a2f5ab18;
RFC 8878 text, sha256
8ee6be03534113f5689cda75b9539a02e0704a2506d420814223e506420aeea4;
Zstandard compression format document (facebook/zstd
dev branch, fetched 2026-10-29), sha256
9ce5315c466d644fb41b54a7dcb707eb6e067bb5f36d79c0728a7ea2050cd8f7;
project post HTML (fetched 2026-10-29), sha256
d31d74cd4bc50ba91481e53eff6774110eddff82d2164ebb7a4c3442e1e35d14.
Evidence in `~/workspace/mzstd-recon/` (`EVIDENCE.md`
as the receipt index, sha256
f0f3a2ff26b0d7c856fb7601ccd8ecb33a5f344e637fc9ce50be3e322779d5b1;
`build.log` sha256
b39376827222a366b6e699b91e6053b05e8c5fea7fdb3cab82b29d018936cd93;
`axioms-all21.log` sha256
95ed8db514d50c6351aa0d8868e4de575a5532b0fab1263495062bc4fa8cc473;
`haiku-doublecheck/`, `argon-check/`).

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` ·
run date `2026-10-29` · harness pin via
`scripts/harness_pin.py`. Two independent
double-checks were run and adjudicated in the open
before landing: Haiku 5.5
(`anthropic/claude-haiku-5.5` via OpenRouter, effort
medium, $0.0032019), which tightened the scope and
the fidelity-target pinning; and Argon
(`google/gemini-4-argon` via OpenRouter, effort
medium, $0.024168) with the local contract-breaker
and contract-certifier skills, whose axiom-sample and
M2-scope hits landed as fixes in section 2 and in
the M2 heading count below.

**Harness pin** (`scripts/harness_pin.py`, run
2026-10-29T17:58:45Z): agent Muse (Meta), model Muse Spark
1.3; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

## 1. The audit object and the fences

The proofs cover the Level-1 items of the authors'
own coverage checklist in
`architecture/formal-verification.md`: frame and
block headers on both sides with round trips,
`Number_of_Sequences`, the literals/match length and
offset code tables, the three default distributions,
the encoder repeat-offset update, and the FSE
Table 21 state pairs. The following are fenced out,
by the pick scope and by the authors' own checklist:
the decoders as a whole; Huffman weights (RFC 8878
section 4.2.1); the literals section header; the
decoder's repeat-offset update; the encoder's offset
code; and all of Level 2 (bit order, FSE distribution
reading and spread, sequence decoding) and Level 3
(a Lean reference decoder and refinement). The
Charon/Aeneas drift replay
(`scripts/extract_lean.py --check`) was not run; it
is recorded as a GAP fence in section 5, not as a
failure.

## 2. Kernel replay at the pin (PASS)

On the auditor's VM (Lean 4.35.0 already installed;
cache partly warm, 9,030 Mathlib files already
cached, recorded so the timing is not misread):
`lake exe cache get` exit 0 in 358 s, then
`lake build` exit 0 in 238 s, 1,813 jobs, all 16
`Mzstd` modules built locally including
`Mzstd.Audit` (the cache supplies Mathlib and the
Aeneas library only, per the lakefile's single
`aeneas` require at
74aabd52f77001cf9eaad51b4f4b867a7dc6b111 and the CI
comment). The authors' "under a minute with cache"
did not reproduce on this VM (238 s); timing only,
no verdict weight. One dependency note: the Aeneas
`extraDep` step warned it was building from source
after a failed GitHub release fetch; the build
still succeeded.

Axiom audit, independently of the target's own
guards: a scratch file importing `Mzstd.Audit`
printed `#print axioms` for all 23 theorems
`Audit.lean` guards (an earlier draft of this audit
said 21; the count was corrected by the Argon
double-check and the full run). Result: 20 theorems
on exactly `[propext, Classical.choice, Quot.sound]`,
`mzstd.numberOfSequences_shortest` on
`[propext, Quot.sound]`, and
`Mzstd.Rfc.updateRepeats_table18` and
`Mzstd.Rfc.fseState_table21` on no axioms. Every
line matches its `#guard_msgs` expectation. Escape
grep over the whole `verification/` tree including
`lakefile.lean`: zero hits for `sorry`,
`native_decide`, `implemented_by`, `extern`,
`opaque`, `unsafe`, or axiom declarations outside
the Audit prose.

## M1 — statement

`Mzstd/Rfc.lean` (407 lines) was read in full
against RFC 8878. Tables 16 and 17 were read row by
row and match exactly, including literals-length
code 25 (baseline 64 with 6 bits, skipping 5, as
printed). Header fields and formulas (Tables 3, 4,
5; the window formula; the two-byte
`Frame_Content_Size` +256 rule), the block header
(Table 9 bit layout, Table 10 types,
`Block_Maximum_Size` = min(Window_Size, 128 KiB)),
the three `Number_of_Sequences` forms including the
0x7F00 offset, and the repeat-offset rules all
match. Coverage method, stated plainly: the three
default distributions were diffed programmatically
(RFC arrays parsed vs Rfc.lean lists parsed; exact
match, lengths 36/53/29, accuracy logs 6/6/5);
contiguity, spans, and the Table 18 and Table 21
worked examples rest on kernel-proved `decide`
theorems inside the replayed build; the remaining
sections rest on a single-auditor read.

Table 18 is the one departure, and it is the RFC's
own: the printed last two rows are inconsistent
with the RFC's prose (an offset value of 1 where
the rule gives `Repeated_Offset1 - 1`, and `3333`
for `1111`). The transcription follows the prose
and the current Zstandard format document, as the
authors disclose in the file. The governing spec
was pinned before the pass (RFC text, its errata
listing, the dated format document above); no
verified erratum covering Table 18 was identified,
and none is needed, since the prose and the format
document agree. One totalization nuance is not a
fidelity failure: `Rfc.offset` is `offsetValue - 3`
by Nat truncated subtraction, and every
theorem-level use has `Offset_Value > 3` in context
(the OF_BASE theorem quantifies over codes >= 2,
`usedOffset` guards, `offsetDefault_max` uses
code 28), which is where the RFC's conditional
applies.

## M2 — argument

Spot scope, as picked: 3 of the 23 guarded theorems
were traced from statement through the committed
generated translation to the Rust source, with a
fourth covered by composition.
`FrameHeader.parse.spec` (`FrameHeader.lean:224`)
has no precondition on the byte string: the result
is `Err(FrameHeader)` exactly when
`Rfc.parseFrameHeader` rejects the bytes, and its
fields otherwise. `transition.spec` (`Fse.lean:95`;
Rust `decompressor/core/fse.rs:329`) assumes
`table_log <= 15`, `1 <= p <= 2^table_log`, `k < p`,
and the counter `next = p + k`, and concludes the
Table 21 pair `fseState table_log p k`.
`update_rep.spec` (`RepeatOffsets.lean:63`; Rust
`compressor/core/seq_store.rs:62`) assumes
`off_base >= 1` and, for the one wrapping case,
`ll0` with `off_base = 3` implies `rep[0] >= 1`.
`frame_header_round_trip` composes the first trace
with its encoder dual. The remaining 19 theorems
were not traced, and all traces rest on the
committed translation files, because the drift
replay was not run (section 5). Within that stated
scope, the statements say what the theorems prove.

## M3 — credit

No overclaim found in the post or in
`architecture/formal-verification.md` at the pin.
The authors fence the unproved coverage themselves
(section 1), name Charon/Aeneas faithfulness as
their largest assumption, disclose the functions
reshaped so they translate, and disclose the
Table 18 departure in the transcription itself.
The post's line counts for the generated and
hand-written code match the pinned tree
(generated 1,060 + 96 lines in mzstd; the audit's
own count of the Audit guards, 23, corrects an
earlier 21 in the pick assessment, which was the
auditor's error, not the authors').

## M4 — fine print

Trusted base, recorded as trusted, not verified:
Charon/Aeneas MIR translation faithfulness
(mutation-tested by the authors, not proved); the
Aeneas Lean models of the scalar and slice
operations used; nightly MIR matching release
behaviour; the one hand-written standard-library
model, `<[T]>::first` in `Code/FunsExternal.lean`
(inspected: `ok s.val.head?`, the documented
head-or-none semantics); translation freshness of
the committed generated files against the Rust
source (the drift replay was not run); prebuilt
Mathlib and Aeneas-library oleans from the lake
cache; the Lean kernel and the three standard
axioms. Precondition, not trusted base: the
theorems hold under `32 <= System.Platform.numBits
<= 64`, satisfied on 32- and 64-bit targets.
Reshaping: the functions reshaped to translate are
the shipped crate source (Charon translates the
ordinary crate), so the proved code is the shipped
code; the residual assumption is that the reshaping
preserved semantics against the pre-refactor code,
which rests on the crate's tests. Residual per
item: if Charon/Aeneas faithfulness failed, every
theorem in the note's scope would weaken to a
statement about the translation alone; if
translation freshness failed, the theorems would
describe a stale snapshot of the crate at or before
the pin; the other items are narrow and would move
only the theorems that use them.

## 5. Fences (GAP)

The Charon/Aeneas drift replay
(`scripts/extract_lean.py --check`) was not run: it
downloads the pinned Aeneas bundle and installs its
nightly Rust toolchain, a separate gate from the
kernel replay. The M2 trace coverage (3 of 23,
section M2) is the second fence. Everything outside
the Level-1 label in section 1 is out of scope, not
audited, and carries no verdict here.

**Verdict: PARTIAL** — Rfc.lean fidelity (M1) and
the local kernel replay at the pin (section 2)
both pass in full; the overall verdict is held at
PARTIAL by the two fences above (the unrun drift
replay and the M2 spot scope), not by any failure.
