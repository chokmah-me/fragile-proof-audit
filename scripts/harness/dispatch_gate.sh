#!/usr/bin/env bash
# dispatch_gate.sh: pre-dispatch gate wrapper (Rec 1, guarantee/attestation
# reanalysis 2026-10-18; drafted by GLM 5.3 via OpenRouter, reviewed and
# fixed by the main agent: checker resolved from this script's own
# directory, so the gate works from any working directory).
# Takes the same arguments a dispatcher would pass to pre_dispatch_checks.py.
# This script dispatches NOTHING (no gh, no network). The caller must chain
# the dispatch in ONE command so a refusal short-circuits it:
#   scripts/harness/dispatch_gate.sh <args...> && gh workflow run <workflow>
# Never run the checker and the dispatch as separate commands.
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHECKER="$SCRIPT_DIR/pre_dispatch_checks.py"

if [ ! -f "$CHECKER" ]; then
  echo "DISPATCH-GATE: REFUSED (checker missing: $CHECKER)"
  exit 3
fi

code=0
python3 "$CHECKER" "$@" || code=$?

if [ "$code" -eq 0 ]; then
  printf 'DISPATCH-GATE: PASS %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  exit 0
fi

echo "DISPATCH-GATE: REFUSED (pre_dispatch_checks exit $code)"
exit "$code"
