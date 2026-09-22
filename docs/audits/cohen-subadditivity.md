# Audit note — Cohen's subadditivity conjecture (Track D#1)

**Claim artifact:** Cohen, Conjecture 66 (subadditivity of `C_σ`).
**Refutation artifact:** Ibarra, J. A., arXiv:2607.09793v1, Theorem 1.
**Campaign objects:** `docs/blueprint/cohen-subadditivity.md`,
`scripts/gates/cohen_subadditivity.py`,
`scripts/controls/cohen_break_control.py`,
`results/cohen_subadditivity_gate_meta.json`,
`results/cohen_break_control_meta.json`,
`incoming/cohen-ibarra-2607.09793.pdf`.

## Bug report (lemma · instance · false instance)

| Field | Content |
|---|---|
| **Lemma** | Conjecture 66: `C_σ(m+n) ≤ C_σ(m) + C_σ(n)` for all `1 ≤ m ≤ n` |
| **Instance** | `m = 31`, `n = 3928` |
| **False instance** | `C_σ(3959) = 697 > 696 = C_σ(31) + C_σ(3928)` |

**Verdict: BREAK.** Attack type **F** (counterexample).

## Definitions the verdict rests on

`n` is *cyclic* iff `gcd(n, φ(n)) = 1` (equivalently, every group of order `n`
is cyclic). `n` is *Sophie Germain cyclic* iff `n` and `2n+1` are both cyclic.
`C_σ(N) = #{k : 1 ≤ k ≤ N, k Sophie Germain cyclic}` (OEIS A397387).

Everything here is load-bearing. A wrong predicate still yields *a* counting
function — just not Cohen's — and the arithmetic would look equally convincing.
This is why the control tests the definition, not the arithmetic.

## What was gated

- `C_σ` recomputed from scratch at `31`, `3928`, `3959`.
- **Two independent totient paths** — `sympy.totient` and a trial-division
  implementation — required to agree on every integer up to `2·3959+1 = 7919`
  before either is trusted, and the three counts recomputed under both.
- Anchors from the pinned PDF, added in the 2026-09-21 re-audit:
  Cohen's own tabulated `C_σ(598) = 120` (Ibarra §3 uses it for exactly this
  purpose), and the eleven window members `(3928, 3959]` Ibarra lists —
  `3929, 3931, 3935, 3941, 3943, 3945, 3947, 3949, 3953, 3957, 3959`.

The mechanism is simple and worth stating: the length-31 window `(3928, 3959]`
contains **eleven** Sophie Germain cyclic integers, one more than the **ten** in
`[1, 31]`. Subadditivity asks that no window of length `m` be denser than the
initial segment `[1, m]`. Here one is.

## Provenance (re-audited 2026-09-21)

Originally gated from the corpus doc plus a live abstract fetch, with no PDF
pinned. The PDF is now pinned and read. **Cohen's section of the corpus doc is
one of only two that survived contact with its paper** — the definitions and
the witness match character for character. The gate needed no correction.

What did need correction was the control: it had "verified transcription" by
substring-matching a prose summary the campaign had itself written down, a
string compared against itself. It now runs the gate's own predicate against
Ibarra's stated values.

## Control

`scripts/controls/cohen_break_control.py` — **NO FALSE POSITIVE.**

1. Transcription: ten checks of the gate's predicate against the paper's
   values, including the worked example at `3929` (`φ(3929) = 3928`,
   `2·3929+1 = 7859 = 29·271`, `φ(7859) = 7560`, both coprime).
2. Discrimination: 500 random pairs `(m, n)` with `1 ≤ m ≤ n ≤ 500` produce
   **0** violations, so the instrument is not an always-BREAK detector; the
   known witness reproduces.
3. Algebraic self-consistency: the gate's own two-totient agreement.

## Lean

None yet — **and this is the most tractable Lean target in Track D.** Ibarra's
own proof is verified in Lean 4 over mathlib, using `Nat.Coprime n
(Nat.totient n)` for cyclicity and `Nat.count` for `C_σ`, axiom-clean
(`propext`, `Classical.choice`, `Quot.sound`) with no `native_decide`. The
formal argument splits `C_σ(3959)` at `3928` and evaluates only the eleven
window members, never the full count. That is a scaffold this campaign could
reproduce directly.

**Attempted 2026-09-22, blocked, reverted.** Built the scaffold: `cyclic`/
`SGcyclic`/`Csigma` matching the source above, the same `Nat.count_add`
window-splitting cancellation Ibarra describes (so `C_σ(3928)` is never
evaluated — only `Nat.count (fun k => SGcyclic (3929+k)) 31 > Csigma 31`,
i.e. `11 > 10`, needs a `decide`). A standalone `lake env lean` check of
just that one declaration succeeded in ~2 minutes (`maxRecDepth 200000`,
`maxHeartbeats 0`, still kernel-checked, no `native_decide`). Wired into
`FragileProofAudit.lean` and run through the full `lake build` +
axiom-audit pipeline, it timed out past 3600s twice on real hardware (not
a sandbox artifact — reproduced on the operator's own machine). Root
cause: `Nat.totient` in mathlib is defined via `Finset.filter (Finset.range
n)` (list/quotient-heavy), has no `@[implemented_by]` fast-eval path, and
kernel-reducing it at the ~63 values this witness needs (up to `2·3959+1 =
7919`) is far more expensive under the full build+axiom-audit pipeline
than the isolated single-declaration check suggested. Searched for a
cheaper witness first (Python, `m, n ≤ 4000`): only two violations exist
in that range, `(31, 3928)` and `(32, 3927)`, both needing the same
expensive window — no smaller witness to substitute. Reverted rather than
invest in a from-scratch kernel-cheap totient (trial-division Decidable
instance + a correctness lemma against `Nat.totient`) without a clearer
sense it would land. **Do not retry the `decide`-over-`Nat.totient`
approach at this scale** — a future session should build the fast-totient
alternative first and time it standalone before wiring it into the build,
or accept this stays a "confirmed tractable in principle, not built"
target.

## Not done, on purpose

Did not attempt to characterise *how many* counterexamples exist beyond
confirming (via the search above) that none is smaller than Ibarra's own
witness for `m, n ≤ 4000`. Ibarra notes such counterexamples "are not
rare"; what makes this one notable is that it lies inside the range Cohen
reported searching. Refuting the route needs one.
