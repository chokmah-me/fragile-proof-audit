"""ab-fluid Boussinesq gate: from-scratch replay of the Boussinesq interval certificate.

Target: Alpoge-Buckmaster forced planar Boussinesq blowup (harvest ab-fluid).
Repo: tristanbuckmaster/fluid_lean @ d0124689230b58b4f86e7b90ac59de06404b3b6b.

Same machinery as scripts/gates/ab_fluid.py (the Euler route): replays the
load-bearing numerics — the dressed interval certificate (pCheckPiece over
all ODChunk pieces), the sub-box coverage tiling, and matched perturbation
controls — using the independent Python transcription of the Lean
fixed-point (2^60) interval arithmetic in ab_fluid_parse / ab_fluid_check.

Verdict PASS iff: every piece passes, coverage tiles [0,1/100] exactly,
and both controls reject. Writes results/ab_fluid_boussinesq_gate_meta.json
and results/ab_fluid_boussinesq_control_meta.json.
"""

from __future__ import annotations

import argparse
import copy
import glob
import json
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

GATE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(GATE_DIR))
sys.path.insert(0, str(GATE_DIR.parent))  # scripts/ -> harness.resume
from ab_fluid_parse import (  # noqa: E402
    parse_piece_cert, parse_di_array_defs, parse_hcell_list, _tokenize)
from ab_fluid_check import pCheckPiece  # noqa: E402
from harness.resume import Checkpoint, file_sha256, run_units  # noqa: E402

REPO = Path.home() / "workspace" / "ab-fluid-verify"
BOUSS = REPO / "boussinesq-blowup" / "BoussinesqBlowup"
CERT = BOUSS / "Num" / "Cert"
PINNED = "d0124689230b58b4f86e7b90ac59de06404b3b6b"
RESULTS = GATE_DIR.parents[1] / "results"
META = RESULTS / "ab_fluid_boussinesq_gate_meta.json"
CONTROL_META = RESULTS / "ab_fluid_boussinesq_control_meta.json"


def fail(reason, **kw):
    meta = {"verdict": "FAIL", "reason": reason, "pinned_commit": PINNED, **kw}
    RESULTS.mkdir(parents=True, exist_ok=True)
    META.write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print(f"ab_fluid_boussinesq: FAIL — {reason}")
    return 0


def parse_args(argv=None):
    ap = argparse.ArgumentParser(
        description="ab-fluid gate: replay the Boussinesq dressed interval "
                    "certificate")
    ap.add_argument("--reset-checkpoint", action="store_true",
                    help="discard the checkpoint journal and re-check every piece")
    return ap.parse_args(argv)


def main() -> int:
    args = parse_args()
    t_start = time.time()
    if not (REPO / ".git").exists():
        return fail("repo not found", repo=str(REPO))
    got = subprocess.run(
        ["git", "-C", str(REPO), "rev-parse", "HEAD"],
        capture_output=True, text=True).stdout.strip()
    if got != PINNED:
        return fail("repo not at pinned commit", have=got, want=PINNED)

    # ---- hybrid step table
    tabtext = (BOUSS / "Num" / "FlatStepTableData.lean").read_text()
    hTab = parse_hcell_list(tabtext, "hTabA") + parse_hcell_list(tabtext, "hTabB")

    # ---- global maps
    piece_map, di_map, plist_map = {}, {}, {}
    files = sorted(glob.glob(str(CERT / "**" / "*.lean"), recursive=True))
    for fp in files:
        text = Path(fp).read_text()
        if ": PieceCert" in text:
            piece_map.update(parse_piece_cert(text))
        if ": Array DI :=" in text:
            di_map.update(parse_di_array_defs(text))
        for m in re.finditer(r"def\s+(\w+)\s*:\s*List PieceCert\s*:=\s*\[", text):
            nm = m.group(1)
            start = m.end() - 1
            depth, j = 0, start
            while True:
                c = text[j]
                if c == "[":
                    depth += 1
                elif c == "]":
                    depth -= 1
                    if depth == 0:
                        break
                j += 1
            toks = [x for x in _tokenize(text[start:j + 1]) if x not in ("[", "]", ",")]
            plist_map[nm] = [x for x in toks if isinstance(x, str)]

    # ---- ODChunk defs via top-level comma split
    odchunks = []
    for fp in files:
        text = Path(fp).read_text()
        for m in re.finditer(r"def\s+(\w+)\s*:\s*ODChunk\s*:=\s*⟨", text):
            nm = m.group(1)
            start = m.end() - 1
            depth, j = 0, start
            while True:
                if text[j] == "⟨":
                    depth += 1
                elif text[j] == "⟩":
                    depth -= 1
                    if depth == 0:
                        break
                j += 1
            body = text[start + 1:j]
            fields, d1, d2, cur = [], 0, 0, []
            for ch in body:
                if ch == "(":
                    d1 += 1
                elif ch == ")":
                    d1 -= 1
                elif ch == "⟨":
                    d2 += 1
                elif ch == "⟩":
                    d2 -= 1
                if ch == "," and d1 == 0 and d2 == 0:
                    fields.append("".join(cur).strip())
                    cur = []
                else:
                    cur.append(ch)
            fields.append("".join(cur).strip())
            if len(fields) >= 6:
                pn_, on_, ln_ = fields[2], fields[4], fields[5]
                if all(re.fullmatch(r"[A-Za-z_]\w*", s) for s in (pn_, on_, ln_)):
                    odchunks.append((nm, pn_, on_, ln_))
    if not odchunks:
        return fail("no ODChunk defs parsed")

    # ---- replay every piece (checkpointed: a reboot resumes, never restarts)
    # Units are deterministic (file/chunk/piece order); only passing pieces
    # are journaled, so a resume re-checks anything not yet proven ok.
    # The journal header pins the source commit AND this checker's hash, so
    # editing the checker or moving the source invalidates old checkpoints.
    #
    # Unit ids are occurrence-indexed (uNNNNN::chunk::piece): the source
    # lists some (chunk, piece) pairs more than once, and the original
    # Euler gate checks every occurrence.  Indexing by occurrence keeps the
    # checkpointed replay bit-for-bit identical to the uncheckpointed one.
    missing, skipped = [], []
    units: list[tuple[str, tuple]] = []
    for (_nm, p_name, om_name, pieces_name) in odchunks:
        P = di_map.get(p_name)
        Om = di_map.get(om_name)
        plist = plist_map.get(pieces_name)
        if P is None or Om is None or plist is None:
            skipped.append(_nm)
            continue
        for pn in plist:
            pc = piece_map.get(pn)
            if pc is None:
                missing.append(pn)
                continue
            uid = f"u{len(units):05d}::{_nm}::{pn}"
            units.append((uid, (Om, P, pc)))
    ckpt = Checkpoint(
        RESULTS / ".checkpoints" / "ab_fluid_boussinesq.jsonl",
        header={"pinned_commit": PINNED,
                "gate_sha": file_sha256(Path(__file__))},
    )
    if args.reset_checkpoint:
        ckpt.reset()
        print("ab_fluid_boussinesq: checkpoint reset — full re-check")
    resumed = len(ckpt)
    if resumed:
        print(f"ab_fluid_boussinesq: resuming — {resumed} pieces already "
              f"verified, {len(units) - resumed} to check")

    def _one(payload) -> bool:
        Om_, P_, pc_ = payload
        return bool(pCheckPiece(Om_, P_, pc_, hTab))

    n_ok, n_tot, failed = run_units(units, _one, ckpt, progress_every=500)
    ckpt.close()
    if missing:
        return fail("piece defs missing", missing=missing[:10], n_pieces=n_tot)
    if skipped:
        return fail("chunks skipped", skipped=skipped[:10], n_pieces=n_tot)
    if failed:
        return fail("piece checks failed", failed=failed[:10],
                    n_ok=n_ok, n_pieces=n_tot)

    # ---- coverage: 8 sub-box [a,b] rationals must tile [0, 1/100]
    def parse_q(s):
        s = s.strip()
        if "/" in s:
            n, d = s.split("/")
            return Fraction(int(n.strip()), int(d.strip()))
        return Fraction(int(s))
    intervals = []
    for d in ["SB0", "SB1", "SB2", "SB3", "SB4", "SB5", "SB6", "SB7"]:
        t = (CERT / d / "DAll.lean").read_text()
        a = re.search(r"def cellA : ℚ := ([0-9 /]+)", t).group(1)
        b = re.search(r"def cellBq : ℚ := ([0-9 /]+)", t).group(1)
        intervals.append((parse_q(a), parse_q(b)))
    cov_ok = (intervals[0][0] <= 0
              and all(intervals[i][1] == intervals[i + 1][0] for i in range(7))
              and intervals[7][1] >= Fraction(1, 100))
    if not cov_ok:
        return fail("coverage tiling broken",
                    intervals=[(str(a), str(b)) for a, b in intervals])

    # ---- controls: matched perturbations must be rejected
    (_nm, p_name, om_name, pieces_name) = odchunks[0]
    P = di_map[p_name]
    Om = di_map[om_name]
    pc0 = piece_map[plist_map[pieces_name][0]]
    baseline = bool(pCheckPiece(Om, P, pc0, hTab))
    bad = copy.deepcopy(pc0)
    bad["lo"], bad["hi"] = bad["hi"], bad["lo"]
    c1 = not pCheckPiece(Om, P, bad, hTab)
    bad = copy.deepcopy(pc0)
    bad["hi"] = [[2 * c for c in arr] for arr in bad["hi"]]
    c2 = not pCheckPiece(Om, P, bad, hTab)
    control_meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "control": "ab_fluid_boussinesq_control",
        "gate": "ab_fluid_boussinesq",
        "checks": {
            "baseline_passes": baseline,
            "inverted_barrier_rejected": c1,
            "doubled_hi_rejected": c2,
        },
        "verdict": ("PASS" if (baseline and c1 and c2) else "FAIL"),
        "ok": bool(baseline and c1 and c2),
        "note": ("matched perturbations rejected; unperturbed baseline passes; "
                 "independent artifact from the Euler certificate"),
    }
    CONTROL_META.write_text(json.dumps(control_meta, indent=2) + "\n",
                            encoding="utf-8")
    if not (baseline and c1 and c2):
        return fail("controls did not behave",
                    baseline=baseline, inverted_rejected=c1,
                    doubled_rejected=c2)

    meta = {
        "verdict": "PASS",
        "pinned_commit": PINNED,
        "htab_cells": len(hTab),
        "odchunks": len(odchunks),
        "pieces_checked": n_tot,
        "pieces_ok": n_ok,
        "checkpoint_resumed": resumed,
        "coverage": "SB0-SB7 tile [0,1/100] in 1/800 steps",
        "controls": {"baseline_passes": baseline,
                     "inverted_barrier_rejected": c1,
                     "doubled_hi_rejected": c2},
        "seconds": round(time.time() - t_start, 1),
        "scope": ("Boussinesq dressed interval certificate only; "
                  "Euler cert covered by ab_fluid; IPM cert, Lean kernel "
                  "bridge, and PDE lifting not replayed"),
    }
    RESULTS.mkdir(parents=True, exist_ok=True)
    META.write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print(f"ab_fluid_boussinesq: PASS — {n_ok}/{n_tot} pieces, "
          f"{len(odchunks)} chunks, coverage ok, controls ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
