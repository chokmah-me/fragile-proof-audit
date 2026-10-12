# Reproducibility supplement

Shuffle squares in smooth binary words and the Kolakoski sequence
Kory Kilpatrick
Revised 28 September 2026

## Research contributions and AI disclosure

Kory Kilpatrick supervised this project. Apart from the external
contributions credited in the paper, GPT-5.6 Sol and GPT-6-Astra
(OpenAI generative-AI systems) performed the mathematical research and
proof development, wrote and executed the computational code, and
drafted and revised the manuscript. Kilpatrick's contribution was
supervision; he does not claim to have personally derived the proofs or
written the code or text. Verification included exact computational
checks and separate AI-agent reviews; these do not constitute independent
human peer review or proof-assistant formalization. As the submitting
author, Kilpatrick takes responsibility for the content.

## Check the finite certificate

Requires Python 3.10 or later; only the Python standard library is used.
From this ancillary-file directory run:

```bash
python3 verify_smooth_even_certificate.py smooth-even-base-certificate.json --expected-sha256 d04eb188c2529a67ac5ee7161fe83940fe316b3ac54f7d42fbdd59be7936b42f
```

The expected result has status PASS, smooth_words_regenerated 16146,
smooth_tangrams_covered 4204, positive_controls_replayed 4170,
exceptions_directly_exhausted 34, imports_project_code false, and
no_triple_atoms_checked_through 24. On the release-review machine this
finished in about one second and used about 37 MiB of resident memory.

The checker independently regenerates the smooth language through 40,
checks exact certificate coverage, replays all positive FIFO witnesses,
and exhausts all equal-size support partitions for the claimed
exceptions. The human-readable exception table lists all 34 words.
The written parity-atom proof and induction in the paper, rather than
finite testing, establish the infinite theorem. No proof-assistant
formalization is claimed.

## Release review

Separate AI agents reviewed the atom classification, induction boundaries,
Kolakoski characterization and uniform infinite corollary. A further
AI-written implementation using one-letter extension and derivative
filtering reproduced the same word set and directly checked the two
supports of every positive witness and every negative partition.
These reviews found no blocking mathematical error. They are reported
as AI-agent review, not independent human peer review.

## Files and integrity

- smooth-even-base-certificate.json: canonical certificate, 291550 bytes.
  SHA256: d04eb188c2529a67ac5ee7161fe83940fe316b3ac54f7d42fbdd59be7936b42f
- verify_smooth_even_certificate.py: standalone independent verifier.
  SHA256: 05d3fcb4515953e93c916bd66975b4b485055177c3025f1b732db4400ec52f6c
- smooth-even-exceptions.md: complete 34-word exception table.
- SHA256SUMS: checksums of these ancillary files, including this README.

This package supports certificate replay. It does not require the
discovery programs, an external resource limiter, or third-party Python
packages. No collaborator correspondence or private manuscript is included.
