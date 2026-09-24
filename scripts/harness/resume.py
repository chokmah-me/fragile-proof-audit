"""Crash-safe checkpoint/resume for long gate replays.

A VM reboot mid-replay must cost minutes, not hours.  The pattern::

    from harness.resume import Checkpoint

    ckpt = Checkpoint(RESULTS / ".checkpoints" / "ab_fluid.jsonl",
                      header={"pinned_commit": PINNED, "gate_sha": _gate_sha()})
    units = [(uid, payload), ...]          # deterministic order
    for uid, payload in ckpt.pending(units):
        ok = check_one(payload)            # expensive work
        if ok:
            ckpt.mark_done(uid)
        else:
            ...fail closed, as before...

Design rules (fail-closed):

* Only *passing* units are journaled.  A unit absent from the journal is
  re-checked from scratch on the next run, so a checkpoint can never turn
  a would-be failure into a pass.
* The journal is append-only JSONL; every line is flushed and fsync'ed
  before the next unit starts, so killing the process at any point loses
  at most the in-flight unit.
* The first line is a header (e.g. pinned commit, gate-script hash).  If a
  previous journal's header differs -- source moved, checker edited -- the
  old journal is rotated aside (``<name>.stale-<utc-ts>``) and a fresh one
  starts.  Stale checkpoints never silently apply to new inputs.
* Checkpoint files live under ``results/.checkpoints/`` and are
  git-ignored: they are local resume state, not audit evidence.  The
  verdict still lands only in the gate's ``*_gate_meta.json``.

This module has no third-party dependencies.
"""

from __future__ import annotations

import hashlib
import json
import os
import time
from datetime import datetime, timezone
from pathlib import Path


class Checkpoint:
    """Append-only JSONL journal of completed (passing) unit ids."""

    def __init__(self, path: str | Path, header: dict | None = None) -> None:
        self.path = Path(path)
        self.header = dict(header or {})
        self._done: set[str] = set()
        self._fh = None
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._open()

    # -- internals ------------------------------------------------------
    def _open(self) -> None:
        if self.path.exists():
            first: dict | None = None
            try:
                with self.path.open("r", encoding="utf-8") as fh:
                    for line in fh:
                        line = line.strip()
                        if not line:
                            continue
                        rec = json.loads(line)
                        if first is None:
                            first = rec
                            continue
                        if rec.get("done"):
                            self._done.add(str(rec["id"]))
                        # NOTE: failure lines, if any, are informational only.
            except (OSError, json.JSONDecodeError, KeyError):
                first = None  # corrupt journal: rotate it aside, start fresh
            prev_header = (first or {}).get("header")
            if prev_header != self.header:
                stale = self.path.with_name(
                    self.path.name
                    + ".stale-"
                    + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
                )
                os.replace(self.path, stale)
                self._done = set()
        self._fh = self.path.open("a", encoding="utf-8")
        if not self._done and self.path.stat().st_size == 0:
            self._write({"header": self.header,
                         "created": datetime.now(timezone.utc).isoformat()})

    def _write(self, rec: dict) -> None:
        assert self._fh is not None
        self._fh.write(json.dumps(rec, sort_keys=True) + "\n")
        self._fh.flush()
        os.fsync(self._fh.fileno())

    # -- public API -----------------------------------------------------
    def __contains__(self, unit_id: str) -> bool:
        return str(unit_id) in self._done

    def __len__(self) -> int:
        return len(self._done)

    def pending(self, units):
        """Yield ``(unit_id, payload)`` for units not yet journaled as done.

        ``units`` is an iterable of ``(id, payload)`` pairs (or bare ids,
        in which case payload is the id).  Order is preserved; the caller
        must supply a deterministic order.
        """
        for u in units:
            uid, payload = u if isinstance(u, tuple) else (u, u)
            if str(uid) not in self._done:
                yield str(uid), payload

    def mark_done(self, unit_id: str, record: dict | None = None) -> None:
        """Journal a passing unit.  Crash-safe: fsync before returning."""
        rec = {"done": True, "id": str(unit_id),
               "t": datetime.now(timezone.utc).isoformat()}
        if record:
            rec["record"] = record
        self._write(rec)
        self._done.add(str(unit_id))

    def reset(self) -> None:
        """Discard the journal (e.g. for a forced full re-run)."""
        if self._fh is not None:
            self._fh.close()
            self._fh = None
        try:
            self.path.unlink()
        except FileNotFoundError:
            pass
        self._done = set()
        self._open()

    def close(self) -> None:
        if self._fh is not None:
            self._fh.close()
            self._fh = None

    def __enter__(self) -> "Checkpoint":
        return self

    def __exit__(self, *exc) -> None:
        self.close()


def file_sha256(path: str | Path) -> str:
    """sha256 of a file; used to invalidate checkpoints when a checker changes."""
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def run_units(units, fn, checkpoint: Checkpoint, *, progress_every: int = 100,
              log=print):
    """Drive ``fn(payload) -> bool`` over units with checkpoint resume.

    Returns ``(n_ok, n_tot, failed_ids)`` where both counts include units
    restored from the checkpoint.  Failing units are NOT journaled; they
    are returned for the caller to handle fail-closed.
    """
    units = list(units)
    n_tot, n_ok, failed = 0, 0, []
    resumed = len(checkpoint)
    t0 = time.time()
    for uid, payload in checkpoint.pending(units):
        n_tot += 1
        if fn(payload):
            n_ok += 1
            checkpoint.mark_done(uid)
        else:
            failed.append(uid)
        if (n_tot % progress_every) == 0:
            el = time.time() - t0
            log(f"  ... {n_ok + resumed}/{n_tot + resumed} ok "
                f"({n_tot} this run, {el:.0f}s)")
    return n_ok + resumed, n_tot + resumed, failed


if __name__ == "__main__":
    # Minimal self-test: journal, re-open (resume), header rotation.
    import tempfile

    with tempfile.TemporaryDirectory() as td:
        p = Path(td) / "t.jsonl"
        ck = Checkpoint(p, header={"v": 1})
        assert list(ck.pending([("a", 1), ("b", 2), ("c", 3)]))
        ck.mark_done("a")
        ck.mark_done("b")
        ck.close()

        ck2 = Checkpoint(p, header={"v": 1})
        assert len(ck2) == 2
        assert "a" in ck2 and "c" not in ck2
        assert [u for u, _ in ck2.pending([("a", 1), ("b", 2), ("c", 3)])] == ["c"]
        n_ok, n_tot, failed = run_units([("a", 1), ("b", 2), ("c", 3)],
                                        lambda x: True, ck2,
                                        progress_every=10, log=lambda *a: None)
        assert (n_ok, n_tot, failed) == (3, 3, [])  # counts include resumed
        ck2.close()

        ck3 = Checkpoint(p, header={"v": 2})  # header change -> rotate
        assert len(ck3) == 0
        assert any(f.name.startswith("t.jsonl.stale-") for f in Path(td).iterdir())
        ck3.close()
    print("resume.py self-test: ok")
