# Audit note — Critical SK autocorrelation processes and dynamics across the temperature transition, statement-fidelity audit (openai/math family 227, 2026-10-14)

**Claim artifact:** the openai/math catalogue entry for family 227
("Critical SK autocorrelation processes and dynamics across the
temperature transition"). The entry advertises worst-start cutoff
for fixed $0\le\beta<1$, mixing time $n^{2/3+o(1)}$ at $\beta=1$,
stretched-exponential mixing for $\beta>1$, and universal
autocorrelation limits (Gaussian + Rademacher) with
quench→stationary relaxation. The mathematics below is taken only
from the catalogue entry, the scope doc, and the linked Lean
statements; the papers' mathematics was not re-derived here.
**Harvest item:** statement-drift shortlist (2026-10-14), rank 6,
drift 7 — confirmed on the fast pass with refinement: the
formalization is broader than the truncated inventory copy
suggested (the inventory's scope field is cut mid-word at 1,500
characters), but the sharpest catalogue claims stay outside.
**Campaign objects:** `incoming/sk-mixing-criticality-227/`
(`PIN.md`, pinned sources; the full scope doc — the inventory
copy is truncated).
**Repo pin:** `openai/math` @
`adc7f1241b42e322a6451854ab7e4b4c146bf78a` (2026-10-06, "Initial
commit"); Lean `v4.34.1`, Mathlib
`d13f23b723b8a846827a245b89c10fc7d3f11612`. Full pin table in
`PIN.md`.

**Agent provenance:** Muse (Meta) · model `Muse Spark 1.3` · skills
`lean-proof-forge` (statement reading only; no build) · run date
`2026-10-14`. The inventory entry, the scope doc, all five
challenge files, and the five solution modules were read at the
pinned SHA above; all quotations below are verbatim from those
sources.

**Scope of this audit:** M1–M4 statement correspondence, read-only.
No Lean build, no Comparator run — see Receipt.

## The catalogue claim (verbatim)

> "Critical SK autocorrelation processes and dynamics across the
> temperature transition."

> "For zero-field Gaussian SK heat-bath dynamics with rate-one
> updates per spin, proves worst-start cutoff on the $`\log n`$
> scale for fixed $`0\le\beta\lt 1`$, mixing time
> $`n^{2/3+o(1)}`$ at <i>β</i> = 1, and stretched-exponential
> mixing from a Gibbs-sampled fixed starting configuration for
> <i>β</i> > 1, in probability over disorder. At criticality,
> rescaled stationary and quench autocorrelation processes have
> universal random limits for Gaussian and Rademacher disorder;
> the quench limit relaxes to the stationary limit.
> ([Lean](lean/docs/227.md))"

## The scope note (verbatim; full upstream text — the inventory copy is truncated)

> "For every fixed inverse temperature $0<\beta<1$, the
> formalization proves a dimension-independent Poincaré inequality
> for the zero-field Gaussian Sherrington–Kirkpatrick model with
> probability tending to one over the disorder. Equivalently, the
> unscaled single-site heat-bath spectral gap stays bounded away
> from zero. For dynamics that choose one site uniformly at each
> discrete step, the spectral gap is at least $1/(Cn)$ with
> probability tending to one, for a constant $C$ depending on
> $\beta$."

> "The formalized supporting result proves ratio cutoff for
> discrete single-site heat-bath dynamics in the zero-field
> Gaussian Sherrington–Kirkpatrick model for $0\le\beta<1/2$. For
> every $0<\varepsilon<1/2$ and $\eta>0$, the probability over
> the disorder that
> $t_{\mathrm{mix}}(\varepsilon)/t_{\mathrm{mix}}(1-\varepsilon)>1+\eta$
> tends to zero as $n\to\infty$. The denominator is positive for
> all sufficiently large sizes."

> "The paper's full range $\beta<1$, explicit cutoff location, and
> continuous-time conclusion are outside this selected statement."

> "At criticality in the zero-field Sherrington–Kirkpatrick
> model, the formalization proves that for every fixed
> $\varepsilon>0$, the continuous-time mixing time lies between
> $n^{2/3-\varepsilon}$ and $e^{\varepsilon n}$, and the
> discrete-time mixing count lies between $n^{5/3-\varepsilon}$
> and $e^{\varepsilon n}$, with probability tending to one over
> the Gaussian disorder. The disorder has independent
> off-diagonal entries of variance $1/n$. Continuous updates have
> rate one per site; discrete time counts uniformly chosen
> single-site update attempts. Mixing is worst-start total
> variation at threshold $1/4$, with holding allowed."

> "For deterministic times $t_n=o(n^{2/3})$ or update counts
> $k_n=o(n^{5/3})$, the Gibbs mass of realized starting states
> still farther than $1/4$ from equilibrium tends to one in
> probability. For every deterministic positive sequence
> $M_n\to\infty$, the covariance operator norm and the linear
> Rayleigh supremum, using the unscaled heat-bath Dirichlet form,
> both lie between $n^{2/3}/M_n$ and $M_n n^{2/3}$ with
> probability tending to one. The covariance result does not give
> an upper bound for the full inverse spectral gap."

> "The formalization proves a stretched-exponential mixing
> obstruction for the zero-field Sherrington–Kirkpatrick model
> at every fixed inverse temperature $\beta>1$. At time
> $\exp(n^{1/10000})$, the expected Gibbs mass of initial
> configurations whose total-variation distance from equilibrium
> exceeds $1/4$ tends to one. Since this mass lies in $[0,1]$,
> it also tends to one in probability over the disorder."

> "The result covers both rate-one-per-site continuous-time
> heat-bath dynamics and the same stated number of discrete
> update attempts."

The doc lists four accompanying papers (spectral-gap, cutoff,
critical slowing down, stretched-exponential barriers) and five
comparator results mapped to the five challenges. What the doc
does NOT claim anywhere: universal autocorrelation limits,
Rademacher disorder, quench→stationary relaxation.

## The formalized statements (as pinned)

Challenge files — all catalogue-relevant theorems end in `sorry`
(seven in total):

- `SKHighTemperature.lean`: `theorem sk_main (β : ℝ) (hβ0 : 0 < β) (hβ1 : β < 1) : MainStatement β := by sorry`
  where `MainStatement β` = ∃ C, Poincaré event probability → 1
  and the discrete gap ≥ 1/(C·n) with probability → 1. *One
  sorry theorem.*
- `SKRatio.lean`: `theorem ratio_cutoff (β ε η : ℝ) (hβ0 : 0 ≤ β) (hβhalf : β < 1 / 2) ... : Tendsto (fun n => disorderLaw β n {g | 1 + η < mixingTime g ε / mixingTime g (1 - ε)}) atTop (𝓝 0) ∧ (∀ᶠ n, ∀ g, 0 < mixingTime g (1 - ε)) := by sorry`
  *One sorry theorem.*
- `CriticalSKMixing.lean`: `theorem critical_mixing_bounds (ε : ℝ) (hε : 0 < ε) :` continuous mixing time ∈ [n^(2/3−ε), e^(εn)] and discrete ∈ [n^(5/3−ε), e^(εn)] with probability → 1 `:= by sorry`
  *One sorry theorem.*
- `CriticalSK.lean`: three sorry theorems —
  `realized_equilibrium_initial_states` (Gibbs mass of
  obstructed starts → 1 for t_n = o(n^(2/3)) / k_n = o(n^(5/3)));
  `covariance_and_linear_tests (M : ℕ → ℝ)` (covariance norm and
  linear Rayleigh supremum ∈ [n^(2/3)/M_n, M_n·n^(2/3)] with
  probability → 1);
  `critical_mixing_lower_bounds (ε : ℝ)` (worst-start mixing ≥
  n^(2/3−ε) continuous / n^(5/3−ε) discrete with probability → 1).
- `SKBarriers.lean`: `theorem main (β : ℝ) (hβ : 1 < β) : Tendsto (continuousBadMass β) atTop (𝓝 1) ∧ Tendsto (discreteBadMass β) atTop (𝓝 1) := by sorry`
  *One sorry theorem.*

Solution modules — the decisive structural difference from
families 266/017 (and from 229's sorry-only challenges). Each
sidecar JSON names a `solution_module`, and every one **exists**
in the repo at the pin and is sorry-free **at the top-level
file** (verified by reading; transitive sorry status is a build
question — GAP):

- `OAI.Probability.SKGap.Main` proves `sk_main` via
  `FullMain.quenched_poincare` (120 lines, real proof chaining
  into ~30 imported supporting modules);
- `OAI.Probability.SKRatio.Main` proves `ratio_cutoff`
  (40 lines; splits at β ≤ 7/20 between a small-temperature
  lemma and a planted-certificate path);
- `OAI.MathematicalPhysics.CriticalMixing.Main` proves
  `critical_mixing_bounds` (50 lines, via
  `critical_two_clock_mixing`);
- `OAI.Probability.SKBarriers.Main` proves `SK.main` for β>1
  (61 lines, via analytic Parisi/locking machinery imports);
- `OAI.MathematicalPhysics.CriticalSK`: `Main.lean` is an
  import aggregator over 43 supporting files; the catalog's
  `related_formalizations` names
  `OAI/MathematicalPhysics/CriticalSK/Rayleigh.lean` (626
  lines, 59 theorems/lemmas, 0 sorry at file level), which
  proves `covariance_and_linear_tests` at line 607.

No challenge file mentions universal limits, quench, or
Rademacher; no solution module read does either.

## M1 — Statement correspondence: a gradient, not a cliff

Claim-part by claim-part:

1. **"worst-start cutoff on the log n scale for fixed
   0≤β<1"** — the ratio-cutoff statement covers only
   **0≤β<1/2** (`hβhalf : β < 1 / 2` in the theorem
   hypothesis), and only as a ratio statement (the
   t_mix(ε)/t_mix(1−ε) ratio → 1 in probability), not the
   explicit log-n cutoff location. The doc admits the full
   range, the explicit location, and the continuous-time
   conclusion are outside. **Weakened-and-admitted.**
2. **"mixing time n^{2/3+o(1)} at β=1"** — the formalized
   `critical_mixing_bounds` states a **wide window**:
   n^{2/3−ε} ≤ t_mix ≤ e^{εn} for every fixed ε>0, i.e. the
   precision `n^{2/3+o(1)}` is *not* stated. Lower bounds
   separately (`critical_mixing_lower_bounds`). **Weakened;
   the doc's window matches the stated theorem, so the
   weakening is self-described.**
3. **"stretched-exponential mixing … for β>1"** — the
   formalized `SK.main` states a mixing **obstruction**
   (bad mass → 1 at time exp(n^{1/10000})), i.e. a slowness
   result; the catalogue's bare "stretched-exponential mixing"
   phrasing is clarified by the doc ("mixing obstruction").
   **Corresponds, with the caveat that it is an obstruction
   claim stated as a sorry challenge with a sorry-free
   solution module.**
4. **"universal autocorrelation limits (Gaussian +
   Rademacher); quench relaxes to stationary"** — **no
   statement anywhere.** Not in the doc (which substitutes
   covariance-operator-norm and linear-Rayleigh bounds as the
   formalized criticality content), not in any challenge, not
   in any solution module read. The headline's "Critical SK
   autocorrelation processes" names exactly this program.
   **Absent — and, unlike the β<1/2 admission, unnamed on
   the doc's exclusion path.**

So of the catalogue's four claim-parts: one weakened-and-admitted,
one weakened-but-self-described, one corresponding-as-obstruction,
one absent-and-un-admitted.

## M2 — Argument correspondence: NOT APPLICABLE to the challenge theorems; solution modules exist and are top-level sorry-free

All seven challenge theorems end in `sorry` — no derivation to
compare (the 266/017/229 precedent). The 229 distinction applies
here with more force: **four of the five solution modules are
real, sorry-free-at-top-level files** (SKGap, SKRatio,
CriticalMixing, SKBarriers), and the fifth (CriticalSK) is a
43-file development whose named theorem
(`covariance_and_linear_tests`) is proved in a 626-line,
file-level sorry-free module. What is NOT established here:
whether any imported supporting module contains a `sorry` —
that is a build question, recorded as GAP. Verified content for
the catalogue claims is therefore **unverified-but-structurally-
substantial, not zero** — the first family on the shortlist
with this status. A future build-bearing pick would owe the
full M2, including the transitive sorry scan.

## M3 — Credit honesty: the doc is honest about its scope; the catalogue's last sentence has no home

- **The doc admits its weakenings.** Full-range cutoff,
  explicit location, continuous-time conclusion: named as
  outside. The n^{2/3+o(1)} → wide-window precision drop is
  described exactly as stated. Against the four papers it
  formalizes, the doc is a fair account — the 266-style candor.
- **The catalogue's universal-limits sentence has no home on
  the Lean side.** "Rescaled stationary and quench
  autocorrelation processes have universal random limits for
  Gaussian and Rademacher disorder; the quench limit relaxes
  to the stationary limit" — no doc sentence, no challenge,
  no solution module mentions universal limits, quench, or
  Rademacher. The doc's criticality content is covariance
  bounds, which is adjacent but not the claimed universality.
  The same structural-absence pattern as 229's four-state half,
  narrower (one sentence rather than half a title).
- **The doc's "The formalization proves…" phrasing** applies to
  sorry challenge statements (the 017 finding, recorded here as
  fine print rather than accusation); the solution modules are
  what make the verb defensible for four of the five results.
- **The `n_formalized: 1` flag is reconciled** (see PIN):
  it is the upstream catalog's count of the family's
  accompanying papers carrying a solution-module claim
  ("Critical slowing down…"; its two challenge configs are the
  only ones of 227's five in the catalog's
  `related_formalizations`) — not an independent verification
  of proved content, and not in tension with the all-sorry
  challenges once the solution-module layer is counted.

## M4 — Fine print (adopted 2026-10-13)

Inventory of load-bearing assumptions outside the theorem
statements, with residual lines:

1. **Gaussian disorder only.** Every doc statement and every
   challenge quantifies Gaussian disorder (off-diagonal
   entries independent, variance 1/n — model definition,
   **source-faithful**). The catalogue's universal-limits
   sentence spans Gaussian **and Rademacher**; Rademacher
   appears nowhere in the doc, the challenges, or the solution
   modules read. The two-disorder universality is the sharpest
   part of the headline and the least covered. Dangling check:
   it dangles from the catalogue with no statement, no doc
   sentence, and no module.
2. **"With probability tending to one over the disorder."**
   The whp framing is definitional throughout (both the
   Poincaré/spectral-gap statements and the mixing windows);
   it is the mode of every convergence claimed. Tag:
   **source-faithful** to the catalogue's stated mode.
3. **Rate-one-per-site continuous updates; discrete time as
   uniformly chosen single-site attempts.** Definitional
   conventions stated in the doc ("Continuous updates have rate
   one per site; discrete time counts uniformly chosen
   single-site update attempts"); mixing is worst-start total
   variation at threshold 1/4, with holding allowed. Tag:
   **source-faithful** per the doc; a different clock would
   change the stated constants.
4. **The β<1/2 split is a proof-enabling restriction.**
   `ratio_cutoff` requires `β < 1/2` in the hypothesis while
   the catalogue claims fixed β<1; the solution module
   literally splits the proof at β ≤ 7/20 vs a
   planted-certificate path. Tag: **convenience-only** for the
   formalization, **risk-inducing** for the headline (the full
   high-temperature range is the load-bearing part of "cutoff
   throughout the high-temperature phase").
5. **Challenge-vs-catalog record mismatch for CriticalSK.**
   The sidecar JSON names solution module
   `OAI.MathematicalPhysics.CriticalSK.Main` (an import
   aggregator), while the catalog's `related_formalizations`
   names `OAI/MathematicalPhysics/CriticalSK/Rayleigh.lean` —
   both exist; `Rayleigh.lean` carries the named theorem.
   Minor record inconsistency, fine print; no content impact.
6. **Trusted base and status.** Permitted axioms on all five
   sidecars are exactly `{propext, Quot.sound,
   Classical.choice}` — the forge allowlist. Status: seven
   challenge theorems `sorry`; five solution modules
   top-level sorry-free (transitive status = build GAP). The
   files are labeled `ComparatorChallenges` upstream; the
   catalogue's Lean link does not say so.

## Receipt

- `incoming/sk-mixing-criticality-227/PIN.md` — upstream pin
  (`adc7f1241b42e322a6451854ab7e4b4c146bf78a`), file hashes,
  toolchain/Mathlib pins, the full scope doc (the inventory
  copy is truncated; truncation marked), the
  `n_formalized: 1` reconciliation, and the solution-module
  inventory as read 2026-10-14.
- **GAP (explicit):** no independent forge build and no
  Comparator run were performed — M1–M4 are a statement
  audit. Unlike 266/017/229, a build-bearing pick here could
  genuinely change findings: the transitive sorry status of
  the solution modules is the open question, and this note's
  M2 is conditional on it.

## Verdict lock

Untouched (32 gates: 17 BREAK / 15 PASS). Standalone M1–M4
verify/audit of a drift-shortlist claim: **M1** — four
claim-parts assessed: ratio cutoff weakened to β<1/2
(admitted); criticality as a wide window, not
n^{2/3+o(1)} (self-described); β>1 obstruction corresponds
(as stated, sorry challenge + sorry-free solution); universal
autocorrelation limits absent and un-admitted; **M2** not
applicable to the seven sorry challenge theorems — but the
five solution modules are real and top-level sorry-free, so
verified content is unverified-not-zero (transitive status =
build GAP); **M3** — the doc is honest about its scope, but
the catalogue's universal-limits sentence has no home on the
Lean side; `n_formalized: 1` reconciled as the upstream
catalog's solution-claim count, not proved content;
**M4** inventoried above (Gaussian-only coverage vs the
two-disorder headline; β<1/2 proof split; challenge/catalog
record mismatch for CriticalSK; allowlist axioms).
