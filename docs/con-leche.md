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
`LEAN4EXPORT_REF`) — same pins as [`catalan-sun-lean`](https://github.com/chokmah-me/catalan-sun-lean).
`LEAN4EXPORT_REF` must match this repo's `lean-toolchain` (`v4.32.2`);
`CON_LECHE_REV` follows con-leche's own toolchain (v4.33.0 at the current
pin). Bump them on purpose, not by floating `master`.

CI is two jobs so those toolchains never share one runner disk:

1. **`export`** — `lake build` + lean4export on v4.32.2; uploads the NDJSON.
2. **`check`** — builds only con-leche, downloads the NDJSON, runs
   `--verified`.

A red job that dies while *installing* Lean (disk full, unpack error) is
infrastructure, not checker `reject` / `decline`.

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

Measured on GitHub `ubuntu-latest`, commit `0778a34` (two-job export/check
split),
[Actions run 35533962641](https://github.com/chokmah-me/fragile-proof-audit/actions/runs/35533962641):

- export: **48 011 617** NDJSON lines (`FragileProofAudit` plus the Mathlib /
  Batteries / … cone `lean4export` walks from the default target);
- `con-leche: accepted 409239 declarations (--verified)` in ~10 min
  (check job ~15 min after export finished).

So the currently proved default-target material — including the Lamé /
Agoh–Giuga / Suman slices on the forge target — is, after export, a kernel
environment this checker accepts. If the set-theory hypothesis holds, those
statements are true in the model (they are not a proof of `False`).

Later pushes re-export and re-check. A red **check** job means the new commit
is not accepted in this sense. A red job that dies while installing Lean
(disk full) is infrastructure, not a mathematical reject.
