#!/bin/bash
# Rebuild drafts/complete-paper.md from the source section files.
# Usage: ./build-complete-paper.sh
# Idempotent: re-running produces the same output as long as sources are unchanged.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
OUT="$D/complete-paper.md"
TMP="$D/.complete-paper.tmp"

{
cat <<'EOF'
# Replay Audits of Published Mathematical Claims: Gates, Controls, and Dispositions

**Daniyel Yaacov Bilar**

*Draft manuscript — companion methods paper to the fragile-proof-audit campaign. Exported 2026-09-23.*

EOF
for i in 1 2 3 4 5 6 7 8 9; do
  # Convert "# §N. Title — draft (DATE)" -> "## N. Title", keep body verbatim
  sed -E '1s/^# §([0-9]+)\. (.*) — draft \([0-9-]+\)$/## \1. \2/' "$D/methods-paper-section$i.md"
  echo
done
# References: "# References — draft (DATE)" -> "# References", drop the intro paragraph
{
echo "# References"
echo
awk 'BEGIN{skip=1} /^Code4rena\./{skip=0} skip==0{print}' "$D/methods-paper-references.md"
}
echo
# Appendices verbatim
cat "$D/methods-paper-appendices.md"
} > "$TMP"
mv "$TMP" "$OUT"
echo "wrote $OUT ($(wc -w < "$OUT") words)"
