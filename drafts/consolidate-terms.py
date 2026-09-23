#!/usr/bin/env python3
"""Terminology consolidation pass (2026-09-23): collapse near-synonyms to
canonical terms across the methods-paper source files.

Canonical choices:
  hostile prior   (was: hostile posture / hostile witnesses)
  replay          (was: re-run / re-execution / re-executed / re-running)
  gate            (was: instrument, where it means the gate software)
  attack type     (was: loose "attacks" for the A-G classes)
  prose audit     (was: proof reading / logical-gap audit)
  PASS            (was: Confirm)
  type-G          (was: G-type)
  dual implementation (was: clean-room second sieve)
"""
import re, sys

FILES = [f"methods-paper-section{i}.md" for i in range(1, 10)]

REPS = [
    # hostile prior (keep the *...* emphasis where present)
    (r"\bhostile posture\b", "hostile prior"),
    # replay family - specific verb forms first
    (r"independently\s+re-run", "independently replayed"),
    (r"can be re-run", "can be replayed"),
    (r"and re-run before", "and replayed before"),
    (r"\bre-executed\b", "replayed"),
    (r"\bre-executes\b", "replays"),
    (r"\bre-execution\b", "replay"),
    (r"\bre-running\b", "replaying"),
    (r"\bre-run\b", "replay"),
    # instrument -> gate
    (r"\binstruments\b", "gates"),
    (r"\binstrument\b", "gate"),
    (r"a gate whose gate has demonstrated", "a gate that has demonstrated"),
    # attack -> attack type / gate
    (r"classifies the attacks by mechanism", "classifies the attack types by mechanism"),
    (r"keep the attacks honest", "keep the gates honest"),
    (r"mechanism-classified attack\s+repertoire", "mechanism-classified attack-type repertoire"),
    (r"mechanism-classified attacks,", "mechanism-classified attack types,"),
    # prose audit
    (r"found by proof reading, not by computation", "found by a prose audit, not by computation"),
    (r"fell to proof reading where", "fell to prose audit where"),
    (r"passed its logical-gap audit", "passed its prose audit"),
    # Confirm -> PASS
    (r"\bConfirm\b", "PASS"),
    # G-type -> type-G
    (r"\bG-type\b", "type-G"),
    # dual implementation
    (r"the clean-room second sieve then agreed", "the dual implementation then agreed"),
    # S.C.E. naming
    (r"Goldbach semi-continuous target at v2", "Goldbach semi-continuous (S.C.E.) target at v2"),
    (r"the Goldbach semi-continuous\s+model", "the Goldbach S.C.E. model"),
]

for f in FILES:
    t = open(f).read()
    orig = t
    for pat, rep in REPS:
        t = re.sub(pat, rep, t)
    if t != orig:
        open(f, "w").write(t)
        print(f"updated {f}")
    else:
        print(f"no change {f}")
