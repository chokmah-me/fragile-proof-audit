#!/usr/bin/env python3
"""Build polya/certs/manifest.json: SHA-256 pins for every chunk certificate.

Reads cert_*.json + stats.json from the certs directory, hashes each cert file
with hashlib, and writes a deterministic manifest. Run after liouville_sieve.
"""
import hashlib
import json
import sys
from pathlib import Path

CERTDIR = Path(__file__).resolve().parent.parent / "certs"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def main() -> None:
    certs = sorted(CERTDIR.glob("cert_*.json"))
    if not certs:
        sys.exit(f"no certs found in {CERTDIR}")
    stats = json.loads((CERTDIR / "stats.json").read_text())
    files = [{"file": c.name, "sha256": sha256_file(c)} for c in certs]
    manifest = {
        "artifact": "polya-chunk-certificates-v1",
        "N": stats["N"],
        "chunk_size": stats["chunk_size"],
        "n_chunks": stats["n_chunks"],
        "domain": stats["domain"],
        "anchors": {
            "L_N": stats["L_N"],
            "first_cross": stats["first_cross"],
            "max_L": stats["max_L"],
            "argmax_L": stats["argmax_L"],
        },
        "generator": stats["generator"],
        "files": files,
    }
    out = CERTDIR / "manifest.json"
    out.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print(f"wrote {out} ({len(files)} certs pinned)")


if __name__ == "__main__":
    main()
