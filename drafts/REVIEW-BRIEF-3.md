# Review brief 3 — methods paper delta review (for Claude)

Target: branch `main` at commit `8d5e152`, file `drafts/complete-paper.md`
(11,610 words; source sections in `drafts/methods-paper-section*.md`,
`drafts/methods-paper-appendices.md`, built by
`drafts/build-complete-paper.sh`).

## Context

You did two prior reviews. Review 1 (Chokmah C1–C8) and review 2
(full-export: 8 MUST-FIX + 7 SHOULD-FIX) have both been fully applied,
committed, and pushed. This is a *delta* review of what changed since
your second review, plus a fresh adversarial pass over the new claims.

## What changed since your second review

1. **Appendix B control architecture — implemented.** You chose
   "record control outcomes in each gate's own meta JSON." This is now
   real code: `scripts/gates/record_controls.py` scans
   `results/*control*meta.json`, matches receipts to gates via the
   receipt's `gate` field, and embeds control name / verdict / ok /
   receipt path / receipt SHA-256 / receipt timestamp into each locked
   gate's meta under the `controls` key. `scripts/gates/check.py` calls
   it on every aggregate run and reports counts in
   `gates_check_meta.json`. Result: 19/25 gates carry control outcomes;
   6 carry an honest `"controls": []` (rr_qexpand, pdn1, giuga_oracle,
   lame_h23, gb_sce, mah_3 — two of these carry controls inline in the
   gate instead). Paper updated: Appendix A schema table, Appendix B
   conventions, §5.2. **Verify: does the code do what the paper claims?
   Does the paper overclaim anywhere (e.g., "every control outcome is
   recorded" vs. the 6 empty lists)? Read the script, not just the prose.**

2. **Title page.** Hebrew epigraph (`<p class="hebrew-epigraph"
   dir="rtl" lang="he">אִם יִרְצֶה הַשֵּׁם</p>`), date "12 Tishrei 5787"
   (independently verified: Sept 23, 2026 per Chabad/Hebcal — an earlier
   draft said 13 Elul 5787, which was wrong and has been corrected),
   CC-BY 4.0 line, linked ORCID, AI-utilization statement. **Check the
   epigraph markup renders sensibly and the date is right.**

3. **§8 rendering fix.** An unclosed `$` in the Polymath15 bound
   (`($\Lambda \le 0.22)` with no closing delimiter) caused the rest of
   the paragraph to render letter-spaced. Fixed and the whole paper
   scanned for unbalanced `$` — this was the only instance. **Spot-check
   for any other LaTeX/Markdown rendering hazards.**

## Standing unresolved items (do not invent; flag only)

- **Odd-zeta authorship.** The pinned PDF (SHA-256
  `686998ff30f778fba4aa9a3874ccf09637bd76663a4edb7c39fae24b1125aae2`)
  identifies as *On the Irrationality of the Odd Zeta Values* by
  Maximilian Stein; gate/docstring/commit language calls the target
  Chattopadhyay. If you can resolve this from the evidence in the repo,
  do; otherwise leave it flagged.
- External verification checks (NCC Group, Sherlock) and the archival
  DOI are still pending submission-day items — note, don't act.

## Boundaries

- Private repo. Do not push anywhere public, do not mint DOIs, do not
  contact authors.
- Do not invent facts (dates, citations, names). Flag what you cannot
  verify.
- The 25-gate verdict lock (17 BREAK / 8 PASS) is untouched by this
  work; control embedding did not alter any verdict — confirm this
  mechanically if you wish.

## Deliverable

Numbered findings, MUST-FIX vs SHOULD-FIX, each grounded in a file and
line number. No rewrite of the paper — findings only.
