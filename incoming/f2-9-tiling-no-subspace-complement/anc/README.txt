ANCILLARY FILES
Samuel J. Ferguson and Joshua Iosevich
Tiling without a subspace complement: a sharp counterexample in dimension nine over the field with two elements
29 October 2026; comparison appendix added 30 October 2026

CONTENTS
verify_example.py      Exact verifier for the principal example.
example.json           Its points, spectrum, complement, and layer bases.
verify_comparison.py   Exact checks for the comparison with Goyal's domain.
comparison_data.json   Goyal's coordinates and the appendix's finite certificates.

RUNNING
Keep these five files together. From this directory, with Python 3.10+:
    python3 verify_example.py
    python3 verify_comparison.py
Both programs use only the Python standard library and also pass under
python3 -O. They write verification_results.json and comparison_results.json
beside themselves. These generated outputs need not be downloaded separately.
From the submission root, use python3 anc/verify_example.py and
python3 anc/verify_comparison.py instead.

CHECKS
The original verifier checks the complete complement and spectrum lists,
exact Wiener norms, and all 788035 three-dimensional subspaces. The comparison
verifier checks the two explicit domains, 512 complements and 64 spectra per
domain, exact integer Gram matrices, Wiener norm 15/8, aperiodicity, the
cross-layer certificates, and the intrinsic layer-direction invariants.
Completeness of spectrum lists and affine inequivalence use the mathematical
arguments proved in the paper, whose finite hypotheses the code checks.
No random choices, cutoffs, external solver, or network access are used.
These programs do not replay the Lean formalization in Goyal's project.

COORDINATES AND SOURCE
The integer sum_i x_i*2^(i-1) encodes (x_1,...,x_n). Addition is XOR; the
dot product is parity of bitwise AND. In F_2^6 x F_2^3, (x,y) is x+64*y.
Goyal's data are transcribed from the cited repository snapshot
0df6158e3818b14d202147a0f31da0f401dd36d8; comparison_data.json gives its URL.
The verification code here checks those data independently.

The single LaTeX source at the submission root includes its bibliography and
all proof tables. It compiles with pdfLaTeX, without external figures or data.
