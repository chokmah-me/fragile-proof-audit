# Gate before prove

Standing rule of this campaign (ported from `catalan-sun-lean`):

> No scaffolded Lean target gets a proof until it has been gated numerically
> (or, for pure logical-gap audits, until the axiom/sorry catalog exists).

## Why

False statements are cheap to spot with a `Fraction`/`mpmath` script and
expensive to discover after a week of Lean. CatalanSun found multiple
statement-level bugs this way. The Jana–Karmakar episode shows the converse:
a **failed** gate is only as good as its harness — so gate code is part of
the artifact and must be self-tested (see `scripts/harness/selftest.py`).

## Protocol

1. Extract the load-bearing quantity or base case into `docs/blueprint/<target>.md`
   with quotations from the source.
2. Implement `scripts/gates/<target>.py` using `scripts/harness/` conventions
   (including negative-index rising factorials when relevant).
3. Register the gate in `scripts/gates/check.py`.
4. Write `results/<target>_gate_meta.json`.
5. Only then write or complete the Lean module.
6. Run `pwsh ./scripts/verify.ps1` (gates + forge).

## Language

Gates refute **routes**, not theorems. ζ(5) is probably irrational; FLT is
true. Notes name the lemma chain that died: lemma · instance · false instance.
