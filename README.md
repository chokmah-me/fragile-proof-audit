# FragileProofAudit

**Private** Lean 4 / mathlib campaign (Chokmah LLC) that audits mathematically
consequential but structurally fragile proofs.

> **Gates refute routes, not theorems.**  
> ζ(5) is probably irrational; FLT is true. What we kill is a lemma chain:
> *lemma · instance · false instance.*

| | |
|---|---|
| **Pin** | Lean `v4.32.2` · mathlib `v4.32.2` (same as [`catalan-sun-lean`](https://github.com/chokmah-me/catalan-sun-lean)) |
| **Stack** | Laptop · Python `mpmath` / `Fraction` / SymPy · no Sage / Magma / cluster |
| **Resume** | Fresh session → **Phase 3(h) Agoh–Giuga kit** — [`docs/WORKPLAN.md`](docs/WORKPLAN.md) |

---

## Quick start

```powershell
pip install -r requirements.txt
pwsh ./scripts/verify.ps1
```

That runs (1) numeric gates including the Pochhammer harness self-test, then
(2) `lake build` + lean-proof-forge (no `sorry`, no `native_decide`, axioms ⊆
classical three).

---

## Discipline

1. **Routes, not theorems** — public/private notes name the dead chain only.
2. **Audit the auditor** — every failed gate ships with its harness; AI-sourced
   fragility claims (including “Pith”) are leads until a gate confirms them.
3. **A pass escalates** — genuine decay or covering is a breakthrough outcome;
   never force a refutation.
4. **Gate before prove** — [`docs/GATE-BEFORE-PROVE.md`](docs/GATE-BEFORE-PROVE.md).

**Off the target list:** Jana–Karmakar (arXiv:2501.10109) — WZ pair survived
630+96 exact checks. The first harness produced 66 false mismatches by omitting
`(a)_{-n} = (-1)^n/(1-a)_n`; that convention is enforced in
`scripts/harness/pochhammer.py`.

**Not an external kill:** Sun Catalan / Zenodo 22830611 is this shop’s own
`catalan-sun-lean` reference campaign — reuse its pin and gate style; do not
re-attack it.

---

## External kernel check (con-leche)

Beyond `lake build`, every push also runs
[con-leche](https://github.com/leanprover/con-leche) — an independent Lean
kernel that re-checks an NDJSON export of the built library, catching bugs
that exist only in Lean's own kernel and rejecting leftover `sorry`s or
non-standard axioms. Same pins and pipeline as `catalan-sun-lean`. Details:
[`docs/con-leche.md`](docs/con-leche.md).

---

## Layout

| Path | Role |
|---|---|
| `FragileProofAudit/` | Lean modules (`AxiomAudit`, `IrrationalityCriterion`, …) |
| `scripts/harness/` | Exact arithmetic + rising-factorial conventions |
| `scripts/gates/` | Numeric gates (`check.py` = CI entrypoint) |
| `scripts/forge/` | `axiom_audit.py` + lean-proof-forge verify |
| `docs/WORKPLAN.md` | **Resume checklist** (start here) |
| `docs/blueprint/` | Per-target blueprints |
| `docs/audits/` | Bug-report style write-ups |
| `corpus/` | Scout reports (graded trust) |
| `incoming/` | Third-party Lean mirrors (gitignored; pin SHA in `results/`) |
| `results/` | Gate and forge receipts |

### Corpus trust

| File | Trust |
|---|---|
| `corpus/fragile-formalizable-proofs-report.md` | Master harvest / ranking |
| `corpus/harvest-addendum-analysis.md` | **Authoritative** on identifiers & fragility truth |
| `corpus/lean4-attack-harvest.md` | Adopt 7-type taxonomy; Pith verdicts = leads |

---

## Phase status

| Phase | Status |
|---|---|
| **0** Readiness | **done** — pin, harness 6/6, forge VERIFIED, CI |
| **1(a)** γ audit (`AEjonanonymous/Euler-Mascheroni`) | **done** — break: statement non-fidelity. Proves `¬ is_rational_gamma`, not mathlib γ. Brief: [`docs/audits/gamma-aejonanonymous.md`](docs/audits/gamma-aejonanonymous.md) |
| **1(b)** Suman ζ(5) | **done** — Eq. (48) base-case kill; gate + Lean witnesses; brief [`docs/audits/suman-zeta5.md`](docs/audits/suman-zeta5.md) |
| **1(c)** Kim ζ(5) | compressed appendix — not a blocker |
| **2(d)** Odd-zeta 202601.1609 | **BREAK** — `Λ_m` not evaluable (Lemma 3.2 is an LCM, not a sequence). [`docs/audits/odd-zeta-202601.md`](docs/audits/odd-zeta-202601.md) |
| **2(e)** Erdős–Straus | **PASS (escalate)** — Conjecture 1 covers all hard-class primes `< 10^5`; no Lean kill. [`docs/audits/es-covering.md`](docs/audits/es-covering.md) |
| **2(f)** RR / HJO | **PASS** — \(Z=P\) q-expand + Lemma 12; OreReduce capability-limited. [`docs/audits/rr-qexpand.md`](docs/audits/rr-qexpand.md) |
| **2(g)** PDN1 | **PASS** — GF + Thm 1.1/1.2 + (3.13); notebooks capability-limited. [`docs/audits/pdn1.md`](docs/audits/pdn1.md) |
| **3(h)** Agoh–Giuga kit | **PASS** — oracle + Lean `oracle_seven`. [`docs/audits/agoh-giuga.md`](docs/audits/agoh-giuga.md) |
| **3(i)** Lamé 1847 | **PASS (gate)** — \(h^-_{23}=3\); Lean pinpoint next. [`docs/audits/lame-1847.md`](docs/audits/lame-1847.md) |
| **3** Infrastructure | Agoh–Giuga kit · Lamé pinpoint · Sun batch `2603.29973` |

Detail and day-level steps: [`docs/WORKPLAN.md`](docs/WORKPLAN.md).

---

## Attack taxonomy (adopted)

| Type | Name |
|---|---|
| A | Scalar-gate |
| B | Base-case kill |
| C | WZ-certificate audit |
| D | Finite q-expansion |
| E | CAS-transcript replay |
| F | Counterexample search |
| G | Logical-gap exposure |

---

## License / visibility

Private Chokmah LLC artifact. No public deposit until an explicit release
decision. Third-party mirrors under `incoming/` retain their upstream licenses;
we do not republish them in this repo (directories are gitignored; commit SHAs
are recorded under `results/`).
