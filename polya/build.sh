#!/bin/bash
# polya/build.sh — full v1 pipeline: compile, anchor validation, chunk certs,
# manifest, independent verification. All logs to stdout; caller redirects.
set -euo pipefail
cd "$(dirname "$0")"

echo "=== compile ==="
gcc -O3 -o /tmp/liouville_sieve src/liouville_sieve.c
echo "compiled OK"

echo "=== sanity: N=100000 (expect L=-288) ==="
/tmp/liouville_sieve 100000

echo "=== anchors: N=1000000000 (expect L=-25216, first_cross=906150257, max=829@906316571) ==="
/tmp/liouville_sieve 1000000000

echo "=== chunk certs: [2,906150257], 10M chunks ==="
rm -f certs/cert_*.json certs/stats.json certs/manifest.json
/tmp/liouville_sieve 906150257 10000000 "$PWD/certs"
ls certs/cert_*.json | wc -l

echo "=== manifest ==="
python3 src/make_manifest.py

echo "=== independent cert verification ==="
python3 src/verify_certs.py
echo "=== BUILD.SH DONE ==="
