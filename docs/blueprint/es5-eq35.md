# Blueprint — ES-5: Ghermoul equation (35)

**Status:** BREAK, locked as `es5_eq35`.
**Source:** Bilal Ghermoul, arXiv:2508.07367v1 (10 Aug 2025).
**Local PDF:** `incoming/es5-2508.07367.pdf`
**Gate:** `scripts/gates/es5_eq35.py`
**Control:** `scripts/controls/es5_eq35_break_control.py`

## What the paper claims, and what it leaves open

Theorem 2.1 gives Egyptian decompositions of `5/a` except when
`a = 5q+1` and `q ≡ 0 (mod 252)`. That remaining set is Conjecture 2
(`252 ℕ ⊂ p1(ℕ³)`), with a computer check in Appendix A. The title's
"almost" matches that split. This gate does not touch Conjecture 2, and it
does not touch the locked `es_cover` row for the `4/n` paper `2404.01508`.

## The dead line

Statement (3), `u ≡ 2 (mod 7)`, page 10. The proof defines

```text
p4(x,y) = -97 + 121 y + 84 x (-4 + 5 y)
```

and displays a three-term identity for `5/(5 p4 + 1)`. Setting `y = 1` gives
`q = 12(7x+2)`. The next displayed line, equation (35), is

```text
5 / (5 [12(7x+2)] + 1)
  = 1/(84x+14) + 1/(7(48x+7)(420x+61)) + 1/(14(6x+1)(48x+7)).
```

The right-hand side is equation (34), which belongs to `q = 12(7x+1)`.

At `x = 0`:

```text
left  = 5/121
right = 5/61
```

The same checker accepts (34) on `x = 0..8`, accepts (33) (the dossier's
`q ≡ 7 (mod 12)` line), and accepts `p4` at `y = 1`. So the class
`q = 12(7x+2)` still has a correct decomposition in the previous display.
The sentence that says `y = 1` produces (35) does not.
