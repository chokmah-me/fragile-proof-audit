# Audit note — Kopis KEM (rozbb/kopis-rs)

**Claim artifact:** Michael Rosenberg, *Can You Slop Out
High-Assurance Cryptography?* (blog, 2026-10,
https://mrosenberg.pub/blog/cryptoslop/); the Kopis design
paper: *Kopis: A KEM for Obfuscation*, Andrea Basso (IBM
Research Europe – Zurich) and Michael Rosenberg, IACR
ePrint 2026/2268, received 2026-09-29, approved 2026-09-30,
PDF v1.0 dated Sep 29, 2026, 52 pages (verified at the
landing page; the user's copy is on his own machine — the
VM's browser could not pull it past the site's human check).
**Claim V-A:** for all three backends (serial / AVX2 / NEON)
and all three parameter sets (kopis512 / 768 / 1024, the
LightSaber/Saber/FireSaber parameters), the Aeneas-extracted
Rust public KEM API matches the Lean spec, panic-free, with
the top-level theorems' axiom footprint exactly the audited
list in lean/AxiomCheck.lean. **Claim V-B (secondary):** the
LLM-optimized crate reaches the hoped-for speed against
competing schemes. This audit verdicts V-A; V-B was not
independently verified (bench not re-run — a bench verdict
from this VM would be weak evidence; scope statement, not a
verdict).
**Repo pin:** https://github.com/rozbb/kopis-rs @
c368dee666cd1f0b6235907f40089e4ab53ed724 ("Make clippy
happy", 2026-10-21T04:05Z). Toolchain leanprover/lean4:v4.35.0;
aeneas @ nightly-2026.10.18-e62dd83; Wychelean @ 6024573d;
Mathlib v4.35.0. Local clone ~/workspace/kopis-recon/repo.
**Harvest item:** Kopis KEM (5th at triage 2026-10-22; head
after Kerr closed; full audit at the user's word
2026-10-23; Grandmaster's Methods at recon; DEEPEN as the
pre-verdict pass). **Campaign objects:**
`incoming/kopis-kem/PIN.md`; working notes
`~/workspace/kopis-recon/` (RECON.md, GM-RECON.md,
QUEUE-PREP.md, M1-NOTES.md, M2M3-NOTES.md, DEEPEN.md).

**Agent provenance:** Muse (Meta), model `Muse Spark 1.3`,
audit date `2026-10-23`. Machine leg: one-shot forge
workflow `kopis-forge` (desktop lane, FPA main@2e44f28);
run 39986698670 concluded failure — see the verdict section
for why that failure is not the verdict.
**Harness pin** (`scripts/harness_pin.py`,
2026-10-23T15:37:06Z): agent Muse (Meta), model `Muse Spark
1.3`; skills dir `~/workspace/skills` (mtime
2026-10-09T20:02:43Z), 11 skills.

**Scope of this audit:** M1 statement fidelity (the six
top-level theorems; the three spec layers; the
structural→behavioral diff against git history), M2 argument
(the Aeneas bridge, the twin generators, the intrinsic
_spec axioms — spot-checked against the manuals, systematic
leg the silicon-vector replays), M3 credit honesty (blog
retrospective vs the three-month commit record; the two
prior in-repo audits), M4 fine-print inventory; DEEPEN as
the pre-verdict pass. No author contact (standing policy).
The 32-gate verdict lock is untouched.

**Status:** CLOSED 2026-10-23 — verdict **PASS** on V-A,
with the qualifications below.

## M1 — statement fidelity

The six theorems in lean/TopLevelTheoremsSerial.lean (and
their generated AVX2/NEON twins) were read in full at the
pin. Each is size-polymorphic over all three parameter sets
and proved by cases to per-size Properties theorems; the
⦃ p ⦄ postcondition carries success (panic-freedom) via
`triple_means_success`. Four pin Rust API outputs to the
Lean spec (keygen→to_bytes = SkToPk; keygen→encapsulate =
KemEncap; from_bytes→encapsulate = KemEncap;
keygen→decapsulate over arbitrary ciphertexts = KemDecap);
two are byte-identity theorems with no spec reference, and
the file says so itself, with the reason (the spec only
represents keys as byte strings). Spec layers: the English
spec (lean/kopis-spec.md) and the C2SP Lean spec
(lean/KopisSpec.lean, 24,484 bytes) carry the same
pseudocode (sampled KemEncap/KemDecap line-for-line);
Kopis/Explicit.lean restates it in BitVec; Kopis/Equiv.lean
(72 theorems) proves the two Lean layers agree per
operation per parameter set.

**Seam 1 — no spec-level roundtrip theorem.** No theorem
anywhere in the repo composes KemDecap after KemEncap; the
only "roundtrip" results are serialization inverses, and
SpecLemmas.lean carries only low-level Poly/serialization
lemmas. End-to-end KEM correctness (decap returns encap's
shared secret) is therefore KAT-supported, not proved. This
is the audit's main qualification: a scope fact about the
theorem set, not an error in any proof.

**Seam 2 — the structural→behavioral diff.** Git history
preserves both generations. The August theorems asserted
the expanded secret key's internal fields separately
(ksk.z = the implicit-rejection seed, pk struct bytes, pk
hash) and a PKE-layer serialization statement
(`pk_serialize_matches_translation`). The October set
dropped those top-level claims; what remains pinned is
every externally observable KEM output (pk bytes, ct, ss,
decap result for arbitrary ct). The October 14 commit
itself changed one line: the keygen postcondition now
uses the spec's public `SkToPk` instead of destructuring
the internal `ExpandSecretKey`. The author's stated open
question — which equivalence theorems suffice to call two
KEMs identical — is exactly this diff.

## M2 — argument (the trusted bridge)

1. **Aeneas extraction** is pinned (manifest revision
   equals AENEAS_VERSION.txt, verified by the forge's
   pins step) and upstream CI re-runs extraction and diffs
   the committed files for staleness. The forge did not
   re-run extraction itself; recorded as trusted, not
   reproduced.
2. **Twin generators** are in the TCB for two of three
   backends; the forge regenerated and the tree was clean
   (TWINS_DIRTY:0).
3. **Axiom gate:** all three prove steps exited 0, each
   building AxiomCheck, which throws on any deviation from
   the audited list exactly — the footprint of the
   top-level theorems is the audited list at the pin
   (AxiomCheck.lean sha256
   0ceae6c7e465657973e88cb1fa412648aa1c2870c4ba129256d55dfa42cd87a2,
   recorded by the forge). Scans: zero sorry/admit in the
   kopis sources (the workflow's raw scan numbers include
   dependency sources under `.lake/packages`, an audit-
   harness scope bug, disclosed below and corrected).
4. **Intrinsic _spec axioms:** sampled 4 against Intel's
   documented semantics — mulhi_epi16 (signed high half
   via sign-extend and extractLsb' 16 16), srlv_epi32
   (per-lane shift, overshift-to-zero via BitVec >>>),
   packs_epi32 satS/satU (per-128-half layout, correct
   saturation clamps), srl_epi16 (64-bit count lane) — all
   correct. Systematic leg: the forge re-ran both silicon
   replays: AVX2 54,279 vectors over 50 ops, all 50 agree;
   NEON 50,176 vectors over 46 ops, all 46 agree.
   The author's conceded residual (a missed edge case in
   an unsampled axiom) stands as the known limit.

## M3 — credit honesty

The July 23 – Aug 1 gate tolerance was visible in the repo
at the time: commit 0348950 sorried the three keygen_encap
capstones "for reliably-green build" ("documented perf
sorries"), the sorry countdown ran in commit messages, and
0c59695 (Aug 1) flipped the gate back to throwing on
sorryAx ("Do not re-add an exemption for sorryAx"). The
blog's retrospective matches the record. Of the prior
in-repo audits' findings at the pin: the July CI gaps
(Lean unverified, NEON unexercised) are CLOSED; Oct audit
015.2 (memory axioms unlinked from models) and 015.3
(big-endian exclusion) are FIXED (commit 3a2c6e7 and
build.rs); 015.1 (hash axioms over-general) is WEAKENED
(`hasher_default_spec` now carries the crate's
RATE/DS const-assertion preconditions; the update/
finalize/read axioms remain stated for all RATE/DS,
vacuous outside the instantiable pairs) and stands as the
single most important trusted correspondence; 015.4 (doc
drift) is cleaned. **KAT provenance:** the pqm4 set was
deleted 2026-09-30 because its origin could not be
established (preserved on the ec-submission branch); the
successor jsonl set's own origin is NOT recorded in the
repo at the pin ("Copy over new test vectors", no source).
The KATs are not load-bearing for V-A, but they are the
support under the unproved roundtrip (M1 seam 1), so the
open provenance lands exactly there. LLM authorship is
disclosed throughout (blog, commit Co-Authored-By lines,
lean/AGENTS.md), and the author prints his own caveat that
the LLM's prior knowledge of Saber weakened the
spec-transcription test.

## M4 — fine-print assumption inventory

1. **Constant-time is not proved** (Valgrind taint +
   DOIT/DIT binary scan with a hand-extended allowlist;
   DOITM/PSTATE.DIT noted in the README as not enabled —
   all author-disclosed). SURVIVES.
2. **turboshake/subtle/zeroize axiomatized** (28 audited
   serial entries incl. the five hash axioms; over-
   generality weakened, not removed — M3 015.1). SURVIVES
   as the disclosed trust base.
3. **Aeneas fmt Formatter stand-in axiom** (common 4th).
   SURVIVES as disclosed.
4. **Keccak/TurboSHAKE lineage** (Wychelean + the MSR
   ML-KEM Lean line). SURVIVES as inherited.
5. **SIMD axioms are axioms** — the models + silicon
   replays are the evidence, not proofs of the
   instructions. SURVIVES.
6. **IND-CCA security of the design** is out of scope of
   the proofs (the Oct in-repo audit states this plainly).
   SURVIVES as scoped.
7. **Twin generators in the TCB** for AVX2/NEON; the
   currency check is the instrument. SURVIVES.

Nothing WEAKENS; nothing EVAPORATES.

## The forge receipt and its verdict-step failure

Run 39986698670 (desktop lane), one-shot workflow
`kopis-forge` (FPA main@2e44f28), completed with run
conclusion **failure**. The evidence artifact
(`kopis-forge-evidence`, 34.3 KB, sha256
6d8c73fe5316d08eb058cba46e7eadc20d57800e05cb207018324f245c2a0507;
local copy ~/workspace/kopis-recon/forge-evidence/)
shows every substantive check green:

- pin_ok (HEAD c368dee, toolchain v4.35.0, aeneas pin =
  AENEAS_VERSION.txt), cache_get ok, twins clean.
- `make prove-kopis-serial` exit 0 ("Build completed
  successfully", 2100 jobs), `prove-kopis-avx2` exit 0
  (2103), `prove-kopis-neon` exit 0 (2101) — each
  building AxiomCheck, i.e. the exact-footprint gate
  passed for all three backends.
- `make test-avx2-model` exit 0 (54,279 vectors / 50
  ops, all agree); `make test-neon-model` exit 0
  (50,176 / 46, all agree).
- Total wall time ~74 min (16:35 → 17:49 UTC).

The workflow's verdict step failed **only** on its source
scans: the scan covered `lean/` recursively, and by the
time it ran, `lake exe cache get` had populated
`lean/.lake/packages/` with dependency sources — all 68
HIT lines are in `.lake/` (Aeneas's own tactic code,
LeanSearchClient/Qq tests), zero in the kopis sources.
That is a scope bug in the audit's own harness, not a
defect in the repo: the corrected-scope result is 0
sorry/admit in the kopis sources, directly computable
from the same artifact, and the AxiomCheck builds already
enforce sorryAx absence at the theorem level. The run was
not re-dispatched; re-running ~74 minutes to reproduce
the same facts was not justified. The harness bug gets
its own post-mortem (AGENTS.md): forge source scans must
exclude the dependency tree.

## DEEPEN — pre-verdict pass

Run 2026-10-23 (`~/workspace/kopis-recon/DEEPEN.md`).
Alternatives rejected: FAIL by the run's letter (the
failure is the harness's scan-scope bug, corrected in the
same artifact); PARTIAL over the roundtrip (the repo
never asserts the roundtrip as a theorem — downgrading
for an unmade claim misdescribes both claim and proof);
re-running extraction (covered by upstream CI's
currency diff; recorded as trusted-not-reproduced).
Nothing moved the verdict.

## Verdict lock

Untouched (17 BREAK / 15 PASS).

**Verdict: PASS on V-A.** The six API theorems are proved
at the pin and independently reproduced on all three
backends, the axiom footprint is exactly the audited list,
and the intrinsic models agree with silicon. V-B is not
independently verified (scope statement). Qualifications:
no spec-level roundtrip theorem (M1 seam 1); the October
theorem set drops the secret key's internal-field claims
(M1 seam 2); the successor KAT set's provenance is
unrecorded (M3); constant-time unproved and IND-CCA out of
scope (M4).
