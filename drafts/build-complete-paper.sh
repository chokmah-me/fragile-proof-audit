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
# Trust, but Replay: Auditing Published Mathematical Claims

**Daniyel Yaacov Bilar**

*Chokmah LLC* ,  [ORCID 0000-0002-9040-6914](https://orcid.org/0000-0002-9040-6914)

*Draft manuscript -- companion methods paper to the fragile-proof-audit campaign. Exported 2026-09-23. Licensed CC-BY 4.0.*

*13 Elul 5787*

*AI utilization: the candidate-harvest list was assembled with Kimi 3 and Grok 3.1 deep research; gate execution, audit-note drafting, and manuscript preparation were performed by Muse Spark agents at the author's direction. Human-review protocol: the author directed a clean re-run of all 25 locked gates (25/25 [ok], zero drift) and read every gate script, audit note, and prose disposition before this draft.*

EOF
for i in 1 2 3 4 5 6 7 8 9; do
  # Convert "# §N. Title -- draft (DATE)" -> "## N. Title"; demote "## N.M" -> "### N.M"
  sed -E -e '1s/^# §([0-9]+)\. (.*) -- draft \([0-9-]+\)$/## \1. \2/' -e 's/^## ([0-9]+\.[0-9]+)/### \1/' "$D/methods-paper-section$i.md"
  echo
done
# References: "# References -- draft (DATE)" -> "# References", drop the intro paragraph
{
echo "## References"
echo
awk 'BEGIN{skip=1} /^Code4rena\./{skip=0} skip==0{print}' "$D/methods-paper-references.md"
}
echo
# Appendices: rewrite H1 draft heading to "## Appendices"
sed -E '1s/^# Appendices -- draft \([0-9-]+\)$/## Appendices/' "$D/methods-paper-appendices.md"
} > "$TMP"
mv "$TMP" "$OUT"
echo "wrote $OUT ($(wc -w < "$OUT") words)"
