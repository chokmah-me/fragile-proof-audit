# PIN — block-anderson-localization-2611-09776 (harvest 2026-11-09)

Pinned 2026-11-09 at the user's tap (register both probed claims
and run both forges on the desktop runner). No verdict at pin
time. Probe: ~/workspace/block-anderson-probe-2026-11-09/PROBE.md
(definitions and statements read in full, PAPER-VS-LEAN graded,
static hygiene scan; no build).

## Claim

Jun Yin, "Block Anderson model localization scale in 1D"
(arXiv:2611.09776, 189 pp.). Headline (Theorem 1.4, (1.17)): the
bulk localization length is

  ell_{W,g,L} = min{WL, max{W, W^2 g^2}}

up to an arbitrarily small power of W: for 0 < kappa < 1/2 and
D, tau > 0, for all large W, uniformly over L >= 3 and g >= 0,

  E[ #{k : lambda_k in J, W^{-tau} ell* <= ell(psi_k) <= W^tau ell*} /
     #{k : lambda_k in J} ] >= 1 - W^{-D},

with 0/0 = 0 (the paper's own convention, in the theorem text).
Corollary 1.5 (1.18) is the simultaneous form in polynomial
volume (L <= W^{B_L}, B_L fixed). The Lean formalization is by
the author with Claude Opus 5.5 and Claude Sonnet 5.5 (README
disclosure). The repo's own docs/PAPER-VS-LEAN.md documents every
statement difference between the paper and the Lean code; the
probe graded all of them (below).

Headline Lean declarations (namespace LSBA):

- `main_ratio_endpoint` — Theorem 1.4 both halves
  (LSBA/Main/UpperEndpoints.lean)
- `lower_ratio_endpoint` — Theorem 1.4 lower half
  (LSBA/Main/Endpoints.lean)
- `simultaneous_endpoint`, `lower_simultaneous_endpoint` —
  Corollary 1.5 both / lower halves
- `lower_count_endpoint` (2.12), `upper_count_endpoint` (3.11)
- `rough_density_endpoint` — Lemma 1.3 (1.15)
- `distribution_lemma` — Lemma 1.2 (i)-(iii)
  (LSBA/Dyson/DistributionLemma.lean)
- `strong_upper`, `sharp_small_upper`, `compact_upper`,
  `large_upper` — Theorems 3.1-3.4, proving the predicates
  StrongUpper / SharpSmallUpper / CompactUpper / LargeUpper
  (predicates in LSBA/Upper/Interface.lean; proofs in
  LSBA/Upper/StrongUpper.lean, SharpSmall.lean, CompactUpper.lean,
  LargeUpper.lean)

## Canonical artifact

`JYin80/Lean-LSBA1d` @ `6faccdc2d8dd1fae2c622ec697c1c2e747e389ac`
(single commit; HEAD verified by local clone 2026-11-09; repo
created 2026-11-06, Apache-2.0). Tree: 478 `.lean` files
(477 under `LSBA/` plus the root module), 285,871 lines,
11,703 theorem/lemma declarations (measured at
probe; the harvest note's "~7 files" was the endpoint files
only). Import reachability: all 478 modules are reachable from
the root module `LSBA`, so `lake build` compiles the whole
library (computed at probe).

- codeload tarball of the pinned commit — 5,413,283 bytes,
  sha256 `12cd339f3ae01aafcb80889ea7519cde22860fa8fa971544bb514c62c6d38fd3`
- Toolchain: `leanprover/lean4:v4.36.0-rc1` (lean-toolchain
  sha256 `d581a24b57a4ae9e0b2132ca8ac7cc3ac336a9fc2751fe6b29414e2d434d54c4`).
  A release candidate.
- Dependency: Mathlib `v4.36.0-rc1` only (lakefile.toml sha256
  `86ea313d5cbbb3d235812890e2b25c29493b1e6b5574946c9ed86bb579eb0f72`;
  lake-manifest.json sha256
  `8560758c1c956a66752d29bc01835acc8f084d4a551b98cc64e32e5c4e4f33ab`).

Key files (sha256):

- `LSBA/Main/Endpoints.lean` —
  `a064da5a2ffaeba5ae8484469b0a8fdcc25f9248086c92d03aca607836bebddf`
- `LSBA/Main/UpperEndpoints.lean` —
  `bfe44725a45604ae9f1c677e49072a54d11f155cd70cda8df69d4046433db627`
- `LSBA/Dyson/DistributionLemma.lean` —
  `635a9cf54394a3e7f41815a3c898286c20332119575670f102e9104f097bf338`
- `LSBA/Upper/Interface.lean` —
  `669367a9f1b713cf5631848da0e7ad62b5df47758c3b8b26acf840d4944f8d1b`
- `README.md` —
  `6cc4782a712d3becf2533bacc73243e5ae7210ce891d54e064ca35c4f8400ca0`
- `docs/PAPER-VS-LEAN.md` —
  `3924d31a4b407fc69d6da882a65976b79a3646f51a1e9d58b50e705b1a91470a`

## M1 first read (probe 2026-11-09, statement level)

- The scale is verbatim: `ellScale W g = max W (W^2 g^2)`,
  `ellStar W L g = min (W*L) (ellScale W g)` (Model/Scales.lean
  19-22) = (1.7). The model `Hmat` is (1.3) with (1.2) GUE
  blocks; `bulkSet` is (1.16) in its own two-case form with the
  Lemma 1.3 threshold as a parameter; `main_ratio_endpoint`
  carries Theorem 1.4's quantifier structure (kappa, threshold,
  D and tau, then W_0 uniform in L >= 3, g >= 0).
- 32 divergences between the printed paper and the Lean
  statements were graded COSMETIC / SCOPE / LOAD-BEARING from
  PAPER-VS-LEAN.md against the LaTeX: ZERO load-bearing at
  headline level. The SCOPE items are intermediate: Lemma 9.3's
  ||K||^2_HS <= 32 weakened to an existential C (the doc admits
  the Lean statement does not imply the printed final one);
  fixed-time forms for the eight Section 5/7 results whose print
  has a supremum over time inside the probability; Lemma G.1's
  averaged local-law rate (W eta)^{-1/2} for (W eta)^{-1};
  weaker uniformity in Theorem 5.12 and Lemma A.7; a stronger
  hypothesis in Lemma B.4 (supplied by its callers); Lemma
  11.3's last sentence dropped (unused); nine paper results
  with no Lean statement, each argued bypassed; the arcsine
  limit law and weak continuity prose near Lemma 1.2 not
  formalized (not items of the lemma, unused).
- Static hygiene at probe (whole tree): `sorry`/`admit` word
  hits 0, declared `axiom` 0, `native_decide` 0, no
  unsafe/extern/opaque; imports only Mathlib and LSBA. The
  endpoints' files end with compiled examples instantiating
  E1-E4 and U1 at concrete parameters (kappa = 1/4, D = 1,
  tau = 1/2, L_0 = 5; g = 1 and g = W^{-1}; L = W and L = W^3),
  the author's own non-vacuity witnesses.

## Pin seams (forge questions, recorded at pin)

1. **No comparator config.** Unlike CFSG/RiemannJensen this
   artifact ships no comparator.json and no challenge module.
   The kernel receipt is the full `lake build` plus an
   independent `#print axioms` pass over the twelve headline
   declarations (D1 note: no author cache is used, the build is
   from source over the Mathlib cache, so build + axioms is the
   honest tier here; the Mathlib cache is a dependency cache,
   not the author's artifact cache).
2. **Build size.** 285,871 lines of Mathlib-heavy Lean at an rc
   toolchain. The forge allows a 720-minute job; if the build
   time-boxes, the verdict records PARTIAL/FAIL with the
   progress evidence rather than extending silently.
3. **Release candidate toolchain.** v4.36.0-rc1; Mathlib cache
   for v4.36.0-rc1 is expected from the Mathlib cache service;
   the route taken (cache vs source for Mathlib) is recorded in
   the evidence.

Next step: forge (this pin's companion workflow,
.github/workflows/block-anderson-forge.yml), desktop runner,
dispatched 2026-11-09 at the user's word.
