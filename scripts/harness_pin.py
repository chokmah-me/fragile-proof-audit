"""Agent-harness pin for machine-readable verification artifacts.

Every verification artifact records the harness that produced it (agent
identity + model + skill-set state + timestamp), the same way it records
the Lean toolchain. Harness choice moves results more than model choice,
so a verdict without model + harness + version is unreproducible.

Policy: docs/harvest-loop.md "Boundaries" (harness-pinning, 2026-10-08).

The agent/model default to this campaign's harness; a hand-run outside
the agent should override via FPA_AGENT / FPA_MODEL so the pin stays
honest. The skills entry degrades gracefully: on machines without the
skills directory (e.g. CI runners) it is simply omitted.
"""

from __future__ import annotations

import os
from datetime import datetime, timezone
from pathlib import Path

AGENT = os.environ.get("FPA_AGENT", "Muse (Meta)")
MODEL = os.environ.get("FPA_MODEL", "Muse Spark 1.3")
SKILLS_DIR = Path.home() / "workspace" / "skills"


def harness_pin() -> dict:
    """Return the harness pin dict for embedding in a result artifact."""
    pin: dict = {"agent": AGENT, "model": MODEL}
    if SKILLS_DIR.is_dir():
        pin["skills"] = {
            "dir": str(SKILLS_DIR),
            "mtime_utc": datetime.fromtimestamp(
                SKILLS_DIR.stat().st_mtime, timezone.utc
            ).isoformat(),
            "skills": sorted(
                p.name for p in SKILLS_DIR.iterdir()
                if p.is_dir() and not p.name.startswith(".")
            ),
        }
    pin["recorded_utc"] = datetime.now(timezone.utc).isoformat()
    return pin
