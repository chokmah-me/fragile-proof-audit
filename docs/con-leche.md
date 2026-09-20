# External kernel check (con-leche)

This repo is a private Lean 4 / Mathlib proof-audit campaign (Chokmah LLC).
`lake build` is the ordinary check: Lean's C++ kernel accepted the default
target. We also run [con-leche](https://github.com/leanprover/con-leche) on
every push.

## What con-leche is

An **external Lean kernel**, written in Lean, with its own terms (not
`Lean.Expr`). It does not read `.lean` files. The pipeline is:

```text
lake build
lean4export FragileProofAudit > fragile-proof-audit.ndjson   # toolchain tag = lean-toolchain
con-leche --verified fragile-proof-audit.ndjson
```

`--verified` is the mode the consistency proof is about. If `checkDecls`
accepts a stream, the resulting environment has a `Model` in their set-theory
interface: ZF **without Infinity**, plus an **ω-chain of Grothendieck
universes**; Choice is taken from Lean as the meta-logic (not from the object
theory). In that model `False` is empty and `Eq` is set equality, so **no
accepted proof of `False`**.

That statement is **parametric** in `[SetTheory V]`. CI does not build such a
`V` and does not prove ZFC. It is the same extra assumption as Lean's usual
consistency story (Carneiro: ZFC + ω inaccessibles). A separate con-leche
bridge package shows Carneiro's hypothesis implies their interface; this repo
does not run that bridge.

Exit codes: **0** accept, **1** reject (invalid environment), **2** decline
(feature the checker does not support yet), **3** error / OOM. CI fails on
anything but 0.

Pins live in `.github/workflows/con-leche.yml` (`CON_LECHE_REV`,
`LEAN4EXPORT_REF`) — same pins as [`catalan-sun-lean`](https://github.com/chokmah-me/catalan-sun-lean),
matching this repo's own `lean-toolchain` (`v4.32.2`). Bump them on purpose,
not by floating `master`.

## Why we run it

`lake build` and con-leche are different programs. A bug only in the official
kernel would have to be reproduced here to still accept a bad proof. The
checker also **rejects a used `sorry`** and **extra axioms** (the three
standard ones — `propext`, `Classical.choice`, `Quot.sound` — are allowed).
This is a check distinct from, and complementary to, the `lean-proof-forge`
axiom/sorry audit already run in `.github/workflows/verify.yml`'s `lean` job.

It is **not** a replacement for `lake build`, and it does **not** add
mathematical content — it says nothing about which proof-audit targets
(§ Phase status in the README) hold.

## What the runs show for this project

No con-leche run has happened yet. After the first CI run, replace this
section with the export line count and `con-leche: accepted N declarations`
figure, per commit, the way `catalan-sun-lean/docs/con-leche.md` tracks its
own runs.
