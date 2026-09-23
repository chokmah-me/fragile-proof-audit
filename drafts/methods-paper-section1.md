# §1. Abstract — draft (2026-09-23)

Published mathematics is trusted far more than it is independently
re-run. Peer review checks reasoning, not computation — and
increasingly, part of the proof *is* a computation. This paper
describes a short, intensive audit campaign (first commit 2026-09-18)
that replays published mathematical claims from scratch, under a
hostile posture: every computational claim must survive an
independent, well-resourced re-execution, and every instrument must
demonstrate it can produce the opposite verdict where the opposite is
correct.

The contribution is the playbook, not the verdicts. §3 defines a
five-disposition taxonomy (BREAK, GAP, PASS, SKIP, UNKNOWN) with a
CI-enforced verdict lock — currently 25 gates, 17 BREAK / 8 PASS —
that fails loudly on drift in either direction. §4 classifies the
attacks by mechanism (scalar gates, base-case kills, WZ-certificate
audits, finite q-expansions, CAS-transcript replays, counterexample
search, logical-gap exposure), each with a worked example. §5 states
the evidentiary disciplines that keep the attacks honest —
paper-first gating, discrimination controls, gate-before-prove,
fail-closed replay, independent anchors with dual implementation,
durable job discipline — together with the record of where those
disciplines were violated and what caught the violations. §6 gives
case studies (a refutation, a confirmation, a canonization, an
unfinished line); §7 states the limitations, including the ones no
discipline closes.

The repository — every gate, control, certificate, and audit note —
is released alongside this paper. The standing doctrine throughout:
gates refute routes, not theorems.
