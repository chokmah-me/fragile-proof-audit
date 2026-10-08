"""Comprehensive tests for the agent-harness pin (scripts/harness_pin.py).

Positive: the pin has the required shape, valid timestamps, an accurate
skills inventory, JSON-serializes without a fallback, honors env overrides,
and flows into both integration points (control receipts, axiom-audit
reports) without breaking their existing contracts.

Negative: missing/empty/odd skills directories degrade gracefully, the
pin never leaks non-JSON-native types, and the pre-existing math harness
package (scripts/harness/) still imports fine.

Run:  python3 -m unittest discover -s scripts/tests -t . -v   (from repo root)
"""

from __future__ import annotations

import io
import json
import os
import subprocess
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from datetime import datetime
from pathlib import Path
from unittest.mock import patch

SCRIPTS = Path(__file__).resolve().parents[1]
ROOT = SCRIPTS.parent
sys.path.insert(0, str(SCRIPTS))
sys.path.insert(0, str(SCRIPTS / "controls"))
sys.path.insert(0, str(SCRIPTS / "forge"))

import harness_pin  # noqa: E402
from harness_pin import harness_pin as pin  # noqa: E402


def parse_iso(s: str) -> datetime:
    dt = datetime.fromisoformat(s)
    assert dt.tzinfo is not None, f"timestamp not tz-aware: {s}"
    return dt


class TestHarnessPinPositive(unittest.TestCase):
    def test_required_keys(self):
        p = pin()
        for key in ("agent", "model", "recorded_utc"):
            self.assertIn(key, p, f"missing key: {key}")

    def test_recorded_utc_is_valid_tz_aware_iso(self):
        parse_iso(pin()["recorded_utc"])

    def test_recorded_utc_is_generated_per_call(self):
        t1 = parse_iso(pin()["recorded_utc"])
        t2 = parse_iso(pin()["recorded_utc"])
        self.assertLessEqual(t1, t2)

    def test_skills_inventory_matches_disk(self):
        p = pin()
        self.assertIn("skills", p)
        s = p["skills"]
        parse_iso(s["mtime_utc"])
        on_disk = sorted(
            d.name for d in Path(s["dir"]).iterdir()
            if d.is_dir() and not d.name.startswith(".")
        )
        self.assertEqual(s["skills"], on_disk)
        self.assertEqual(s["skills"], sorted(s["skills"]))
        self.assertTrue(len(s["skills"]) > 0)

    def test_json_serializable_without_default_str(self):
        # axiom_audit.py uses json.dumps(report) with NO default=str, so a
        # leaked datetime would crash the real integration. This guards it.
        json.dumps(pin())

    def test_env_override(self):
        code = (
            "import sys, json; sys.path.insert(0, 'scripts');"
            "from harness_pin import harness_pin;"
            "print(json.dumps(harness_pin()))"
        )
        env = dict(os.environ, FPA_AGENT="TestAgent", FPA_MODEL="TestModel-9")
        r = subprocess.run(
            [sys.executable, "-c", code], capture_output=True, text=True,
            env=env, cwd=ROOT,
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        p = json.loads(r.stdout)
        self.assertEqual(p["agent"], "TestAgent")
        self.assertEqual(p["model"], "TestModel-9")

    def test_math_harness_package_still_imports(self):
        # scripts/harness/ (exact-arithmetic/Pochhammer) must not be shadowed.
        from harness import rising_factorial  # noqa
        self.assertTrue(callable(rising_factorial))


class TestHarnessPinNegative(unittest.TestCase):
    def test_missing_skills_dir_omits_skills_key(self):
        with patch.object(harness_pin, "SKILLS_DIR", Path("/nonexistent-xyz-123")):
            p = pin()
        self.assertNotIn("skills", p)
        self.assertIn("agent", p)
        self.assertIn("model", p)
        parse_iso(p["recorded_utc"])
        json.dumps(p)

    def test_empty_skills_dir_gives_empty_list(self):
        with tempfile.TemporaryDirectory() as td:
            with patch.object(harness_pin, "SKILLS_DIR", Path(td)):
                p = pin()
        self.assertEqual(p["skills"]["skills"], [])

    def test_files_and_hidden_dirs_excluded(self):
        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            (tdp / "real_skill").mkdir()
            (tdp / ".hidden").mkdir()
            (tdp / "notes.txt").write_text("not a skill")
            with patch.object(harness_pin, "SKILLS_DIR", tdp):
                p = pin()
        self.assertEqual(p["skills"]["skills"], ["real_skill"])

    def test_no_datetime_objects_leak(self):
        # Walk the whole structure; everything must be natively JSON-typed.
        def check(v):
            if isinstance(v, dict):
                for x in v.values():
                    check(x)
            elif isinstance(v, list):
                for x in v:
                    check(x)
            else:
                self.assertIsInstance(v, (str, int, float, bool, type(None)), v)
        check(pin())


class TestReceiptIntegration(unittest.TestCase):
    def test_receipt_includes_harness(self):
        from receipt import write_receipt
        stem = "_harness_pin_selftest"
        out = ROOT / "results" / f"{stem}_meta.json"
        self.addCleanup(lambda: out.unlink(missing_ok=True))
        p = write_receipt(stem, "selftest", "OK", {"ping": True}, True)
        d = json.loads(p.read_text())
        self.assertIn("harness", d)
        self.assertEqual(d["harness"]["agent"], pin()["agent"])
        parse_iso(d["harness"]["recorded_utc"])
        # Pre-existing contract intact.
        for key in ("timestamp", "control", "gate", "verdict", "ok", "checks"):
            self.assertIn(key, d)

    def test_receipt_without_extra_still_works(self):
        from receipt import write_receipt
        stem = "_harness_pin_selftest2"
        out = ROOT / "results" / f"{stem}_meta.json"
        self.addCleanup(lambda: out.unlink(missing_ok=True))
        p = write_receipt(stem, "selftest", "OK", {}, False)
        d = json.loads(p.read_text())
        self.assertIn("harness", d)
        self.assertFalse(d["ok"])


class TestAxiomAuditIntegration(unittest.TestCase):
    def run_audit(self, root: Path) -> dict:
        import axiom_audit
        out = root / "out.json"
        argv = ["axiom_audit", str(root), "--json-out", str(out)]
        buf = io.StringIO()
        with patch.object(sys, "argv", argv), redirect_stdout(buf):
            self.assertEqual(axiom_audit.main(), 0)
        return json.loads(out.read_text())

    def test_report_includes_harness(self):
        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            (tdp / "A.lean").write_text("theorem t : True := trivial\n")
            d = self.run_audit(tdp)
        self.assertIn("harness", d)
        self.assertEqual(d["harness"]["agent"], pin()["agent"])
        parse_iso(d["harness"]["recorded_utc"])
        # Pre-existing contract intact.
        self.assertEqual(d["lean_file_count"], 1)
        self.assertEqual(len(d["declarations"]), 1)

    def test_empty_dir_still_reports_harness(self):
        with tempfile.TemporaryDirectory() as td:
            d = self.run_audit(Path(td))
        self.assertIn("harness", d)
        self.assertEqual(d["lean_file_count"], 0)
        json.dumps(d)  # no default=str anywhere in the real writer


if __name__ == "__main__":
    unittest.main()
