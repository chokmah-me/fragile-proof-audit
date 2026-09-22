"""Regression entrypoint for all numeric gates.

Phase 0: harness self-test only (empty target suite).
Phase 1+: each target gate registers here and must stay green in CI.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "results"
HARNESS_SELFTEST = ROOT / "scripts" / "harness" / "selftest.py"
SUMAN_EQ48 = ROOT / "scripts" / "gates" / "suman_eq48.py"
ODD_ZETA_1609 = ROOT / "scripts" / "gates" / "odd_zeta_1609.py"
ES_COVER = ROOT / "scripts" / "gates" / "es_cover.py"
RR_QEXPAND = ROOT / "scripts" / "gates" / "rr_qexpand.py"
PDN1 = ROOT / "scripts" / "gates" / "pdn1.py"
GIUGA_ORACLE = ROOT / "scripts" / "gates" / "giuga_oracle.py"
LAME_H23 = ROOT / "scripts" / "gates" / "lame_h23.py"
LAME_IDEAL_NEG23 = ROOT / "scripts" / "gates" / "lame_ideal_neg23.py"
COHEN_SUBADDITIVITY = ROOT / "scripts" / "gates" / "cohen_subadditivity.py"
BASTE_DOMINATION = ROOT / "scripts" / "gates" / "baste_domination.py"
SARKOZY_SUM_PRODUCT = ROOT / "scripts" / "gates" / "sarkozy_sum_product.py"
TANG_ZHANG_SCHATTEN = ROOT / "scripts" / "gates" / "tang_zhang_schatten.py"
THAKUR_CARLITZ = ROOT / "scripts" / "gates" / "thakur_carlitz.py"
CHUNG_GRAHAM_SPIRO = ROOT / "scripts" / "gates" / "chung_graham_spiro.py"
SALEZ_YOUSSEF_LOGSOBOLEV = ROOT / "scripts" / "gates" / "salez_youssef_logsobolev.py"
TPC_AREA = ROOT / "scripts" / "gates" / "tpc_area.py"
ES5_EQ35 = ROOT / "scripts" / "gates" / "es5_eq35.py"
CAT_G = ROOT / "scripts" / "gates" / "cat_g.py"
KRR_CL = ROOT / "scripts" / "gates" / "krr_cl.py"
TPC_GN = ROOT / "scripts" / "gates" / "tpc_gn.py"
JAC_2D = ROOT / "scripts" / "gates" / "jac_2d.py"

# ---------------------------------------------------------------------------
# Verdict lock.
#
# Gate scripts deliberately exit 0 whether they find PASS or BREAK: a BREAK is
# the campaign's desired finding, not a build failure. The consequence was that
# NOTHING detected a verdict flip in either direction -- a dependency bump that
# silently turned a landed BREAK back into a PASS would have left CI green.
#
# Each gate's verdict is therefore pinned here and compared against the meta
# JSON it wrote. Deviation in EITHER direction fails the run. Changing an entry
# is a deliberate act that should land in the same commit as the re-audit.
# ---------------------------------------------------------------------------

EXPECTED_VERDICT: dict[str, tuple[str, str]] = {
    "suman_eq48": ("suman_gate_meta.json", "BREAK"),
    "odd_zeta_1609": ("odd_zeta_gate_meta.json", "BREAK"),
    "es_cover": ("es_cover_gate_meta.json", "PASS"),
    "rr_qexpand": ("rr_qexpand_gate_meta.json", "PASS"),
    "pdn1": ("pdn1_gate_meta.json", "PASS"),
    "giuga_oracle": ("giuga_oracle_gate_meta.json", "PASS"),
    "lame_h23": ("lame_h23_gate_meta.json", "PASS"),
    "lame_ideal_neg23": ("lame_ideal_neg23_gate_meta.json", "PASS"),
    "cohen_subadditivity": ("cohen_subadditivity_gate_meta.json", "BREAK"),
    "baste_domination": ("baste_domination_gate_meta.json", "BREAK"),
    "sarkozy_sum_product": ("sarkozy_sum_product_gate_meta.json", "BREAK"),
    "tang_zhang_schatten": ("tang_zhang_schatten_gate_meta.json", "BREAK"),
    "thakur_carlitz": ("thakur_carlitz_gate_meta.json", "BREAK"),
    "chung_graham_spiro": ("chung_graham_spiro_gate_meta.json", "BREAK"),
    "salez_youssef_logsobolev": ("salez_youssef_gate_meta.json", "BREAK"),
    "tpc_area": ("tpc_area_gate_meta.json", "BREAK"),
    "es5_eq35": ("es5_eq35_gate_meta.json", "BREAK"),
    "cat_g": ("cat_g_gate_meta.json", "BREAK"),
    "krr_cl": ("krr_cl_gate_meta.json", "BREAK"),
    "tpc_gn": ("tpc_gn_gate_meta.json", "BREAK"),
    "jac_2d": ("jac_2d_gate_meta.json", "PASS"),
}


def check_verdicts() -> list[dict]:
    """Compare each gate's recorded verdict against its pinned expectation."""
    rows: list[dict] = []
    for name, (meta_name, expected) in EXPECTED_VERDICT.items():
        path = RESULTS / meta_name
        actual: str | None = None
        note = ""
        if not path.exists():
            note = "meta file missing"
        else:
            try:
                actual = json.loads(path.read_text(encoding="utf-8")).get("verdict")
                if actual is None:
                    note = "no verdict key"
            except json.JSONDecodeError as exc:
                note = f"unreadable meta: {exc}"
        rows.append(
            {
                "name": name,
                "meta": meta_name,
                "expected": expected,
                "actual": actual,
                "ok": actual == expected,
                "note": note,
            }
        )
    return rows



def run_script(name: str, path: Path) -> dict:
    """Run a gate, forcing UTF-8 on both ends.

    Gates print mathematical notation (√, ≡, θ). Under a cp1252
    console the *child's* own print() raises UnicodeEncodeError, so the gate
    exits 1 having already written a correct verdict -- a passing gate reported
    as FAIL, and a red verify.ps1, purely from the operator's code page.
    """
    proc = subprocess.run(
        [sys.executable, str(path)],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env={**os.environ, "PYTHONIOENCODING": "utf-8"},
    )
    return {
        "name": name,
        "exit_code": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "ok": proc.returncode == 0,
    }


def run_harness() -> dict:
    return run_script("harness_selftest", HARNESS_SELFTEST)


def run_suman_eq48() -> dict:
    return run_script("suman_eq48", SUMAN_EQ48)


def run_odd_zeta_1609() -> dict:
    return run_script("odd_zeta_1609", ODD_ZETA_1609)


def run_es_cover() -> dict:
    return run_script("es_cover", ES_COVER)


def run_rr_qexpand() -> dict:
    return run_script("rr_qexpand", RR_QEXPAND)


def run_pdn1() -> dict:
    return run_script("pdn1", PDN1)


def run_giuga_oracle() -> dict:
    return run_script("giuga_oracle", GIUGA_ORACLE)


def run_lame_h23() -> dict:
    return run_script("lame_h23", LAME_H23)


def run_lame_ideal_neg23() -> dict:
    return run_script("lame_ideal_neg23", LAME_IDEAL_NEG23)


def run_cohen_subadditivity() -> dict:
    return run_script("cohen_subadditivity", COHEN_SUBADDITIVITY)


def run_baste_domination() -> dict:
    return run_script("baste_domination", BASTE_DOMINATION)


def run_sarkozy_sum_product() -> dict:
    return run_script("sarkozy_sum_product", SARKOZY_SUM_PRODUCT)


def run_tang_zhang_schatten() -> dict:
    return run_script("tang_zhang_schatten", TANG_ZHANG_SCHATTEN)


def run_thakur_carlitz() -> dict:
    return run_script("thakur_carlitz", THAKUR_CARLITZ)


def run_chung_graham_spiro() -> dict:
    return run_script("chung_graham_spiro", CHUNG_GRAHAM_SPIRO)


def run_salez_youssef_logsobolev() -> dict:
    return run_script("salez_youssef_logsobolev", SALEZ_YOUSSEF_LOGSOBOLEV)


def run_tpc_area() -> dict:
    return run_script("tpc_area", TPC_AREA)


def run_es5_eq35() -> dict:
    return run_script("es5_eq35", ES5_EQ35)


def run_cat_g() -> dict:
    return run_script("cat_g", CAT_G)


def run_krr_cl() -> dict:
    return run_script("krr_cl", KRR_CL)


def run_tpc_gn() -> dict:
    return run_script("tpc_gn", TPC_GN)


def run_jac_2d() -> dict:
    return run_script("jac_2d", JAC_2D)


def main() -> int:
    # The suite relays child output containing mathematical notation; a cp1252
    # console would otherwise kill the runner itself while every gate passed.
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, OSError):
            pass

    RESULTS.mkdir(parents=True, exist_ok=True)
    # Phase 1(b)+2(d)–2(g)+3(h)+3(i)+3(i)++: prior gates + Lamé ideal witness.
    # Track D#1–#8: Cohen, Baste, Sárközy, Tang-Zhang, Thakur,
    # Chung-Graham-Spiro, Salez-Youssef (NCI SKIPPED, see
    # results/nci_skip_meta.json). Sources: corpus/live-fragile-proofs-2024-2026.md
    # plus the pinned PDFs under incoming/.
    results = [
        run_harness(),
        run_suman_eq48(),
        run_odd_zeta_1609(),
        run_es_cover(),
        run_rr_qexpand(),
        run_pdn1(),
        run_giuga_oracle(),
        run_lame_h23(),
        run_lame_ideal_neg23(),
        run_cohen_subadditivity(),
        run_baste_domination(),
        run_sarkozy_sum_product(),
        run_tang_zhang_schatten(),
        run_thakur_carlitz(),
        run_chung_graham_spiro(),
        run_salez_youssef_logsobolev(),
        run_tpc_area(),
        run_es5_eq35(),
        run_cat_g(),
        run_krr_cl(),
        run_tpc_gn(),
        run_jac_2d(),
    ]
    failed = [r for r in results if not r["ok"]]
    verdicts = check_verdicts()
    drifted = [v for v in verdicts if not v["ok"]]
    meta = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "phase": "track-D",
        "lock_size": len(EXPECTED_VERDICT),
        "gates": [
            {
                "name": r["name"],
                "ok": r["ok"],
                "exit_code": r["exit_code"],
            }
            for r in results
        ],
        "verdict_lock": verdicts,
        "verdict_drift": [v["name"] for v in drifted],
        "all_ok": not failed and not drifted,
    }
    out = RESULTS / "gates_check_meta.json"
    out.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    for r in results:
        status = "PASS" if r["ok"] else "FAIL"
        print(f"[{status}] {r['name']}")
        if r["stdout"]:
            print(r["stdout"].rstrip())
        if r["stderr"]:
            print(r["stderr"].rstrip(), file=sys.stderr)
    print("\n=== verdict lock ===")
    for v in verdicts:
        mark = "ok" if v["ok"] else "DRIFT"
        extra = f" ({v['note']})" if v["note"] else ""
        print(
            f"[{mark}] {v['name']}: expected {v['expected']}, "
            f"got {v['actual']}{extra}"
        )
    if drifted:
        print(
            "\nVERDICT DRIFT -- a gate's finding changed without the pin being "
            "updated. Re-audit the target, then update EXPECTED_VERDICT in the "
            "same commit."
        )

    print(f"\nWrote {out}")
    return 1 if (failed or drifted) else 0


if __name__ == "__main__":
    raise SystemExit(main())
