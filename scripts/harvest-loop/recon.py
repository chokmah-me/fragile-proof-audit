#!/usr/bin/env python3
"""Harvest-loop recon analyzer.

Reads the newest (or --date-selected) harvest file from incoming/harvests/,
verifies each claim's identifiers against public APIs (arXiv, GitHub),
scores fragility per the documented rubric, suggests attack lanes from the
A-G taxonomy, and writes dated recon output to docs/audits/harvest-<date>/.

Boundaries (deliberate):
- No clones, no builds, no downloads beyond API metadata. Running anything
  waits for the user to pick a target.
- Never touches the verdict lock.
- Stdlib only.

Outputs:
- docs/audits/harvest-<date>/recon.md      (human-readable recon cards)
- docs/audits/harvest-<date>/ledger.json   (machine-readable check results)
- docs/audits/harvest-<date>/issue-title.txt, issue-body.md  (for the issue step)

Idempotency: recon.md embeds the harvest file's sha256. If recon.md already
exists with the same sha, the script prints CHANGED=false and exits 0.

Health-check mode (--health-check): re-runs identifier checks for the latest
processed harvest and appends a dated note to recon.md only if something
changed since the ledger was written.
"""
import datetime
import hashlib
import json
import os
import re
import sys
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HARVEST_DIR = os.path.join(REPO_ROOT, "incoming", "harvests")
OUT_BASE = os.path.join(REPO_ROOT, "docs", "audits")
REPO_SLUG = os.environ.get("REPO_SLUG", "chokmah-me/fragile-proof-audit")
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")

SIGNAL_POINTS = {
    "ai_generated": 2,
    "released_under_pressure": 1,
    "anonymous_or_unaffiliated": 1,
    "single_author": 1,
    "ai_only_review": 1,
    "disclosed_llm_help": 1,
    "formal_subset_of_claim": 2,
    "credit_dispute": 1,
    "build_skips_main_file": 2,
    "third_party_rebuild": -2,
    "pinned_toolchain": -1,
    "public_ci_green": -1,
}

# keyword -> attack type (docs/attack-taxonomy.md); heuristic, labeled as such
LANE_KEYWORDS = [
    (r"\blean\b", "G", "logical-gap exposure (formalized subset vs headline)"),
    (r"interval", "E", "CAS-transcript replay (interval certificate)"),
    (r"certificate", "E", "CAS-transcript replay (certificate)"),
    (r"factorization|rational\b", "E", "CAS-transcript replay (exact rational object)"),
    (r"refut|counterexample|disprov", "F", "counterexample search (conjecture kill)"),
    (r"blowup|singularity", "A", "scalar gate (blowup criterion)"),
    (r"\bbound\b|inequality|ratio", "A", "scalar gate (quantitative bound)"),
    (r"q-expansion|q-series|theta", "D", "finite q-expansion"),
    (r"wz\b|telescop", "C", "WZ-certificate audit"),
    (r"base case|induction", "B", "base-case kill"),
]


def http_get(url, headers=None, timeout=20):
    req = urllib.request.Request(url, headers=headers or {})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        try:
            return e.code, e.read()
        except Exception:
            return e.code, b""
    except Exception as e:
        return -1, str(e).encode()


def gh_headers():
    h = {"Accept": "application/vnd.github+json", "User-Agent": "fragile-proof-audit-harvest-loop"}
    if GITHUB_TOKEN:
        h["Authorization"] = "Bearer " + GITHUB_TOKEN
    return h


def check_paper(paper):
    """paper: 'arXiv:2609.12345', an arXiv URL, or any other full URL.
    arXiv identifiers go through the arXiv API; other URLs get a HEAD-style
    reachability check (we verify the identifier resolves, not its content)."""
    m = re.search(r"arxiv[:.]org/(?:abs|html|pdf)/([\w.\-/]+)", paper, re.I) or re.search(
        r"arXiv:([\w.\-/]+)", paper, re.I)
    if m:
        aid = m.group(1).replace(".pdf", "")
        status, body = http_get("https://export.arxiv.org/api/query?id_list=" + aid)
        if status != 200:
            return {"status": "API-ERROR", "arxiv_id": aid, "detail": "http %s" % status}
        try:
            root = ET.fromstring(body)
            ns = {"a": "http://www.w3.org/2005/Atom"}
            entry = root.find("a:entry", ns)
            if entry is None or entry.find("a:title", ns) is None:
                return {"status": "NOT-FOUND", "arxiv_id": aid}
            title = " ".join(entry.find("a:title", ns).text.split())
            authors = [a.find("a:name", ns).text for a in entry.findall("a:author", ns)]
            published = entry.find("a:published", ns).text[:10]
            return {"status": "VERIFIED", "arxiv_id": aid, "title": title,
                    "authors": authors, "published": published,
                    "url": "https://arxiv.org/abs/" + aid}
        except Exception as e:
            return {"status": "PARSE-ERROR", "arxiv_id": aid, "detail": str(e)}
    m = re.match(r"https?://\S+", paper.strip())
    if m:
        url = m.group(0)
        status, _ = http_get(url)
        if status == 200:
            return {"status": "URL-RESOLVED", "url": url,
                    "detail": "non-arXiv URL reachable (content not checked)"}
        if status == 403:
            return {"status": "URL-BLOCKED", "url": url,
                    "detail": "http 403 (bot-blocked); reachable by humans, not verified by loop"}
        return {"status": "URL-FAILED", "url": url, "detail": "http %s" % status}
    return {"status": "UNPARSEABLE", "detail": paper}


def check_github_repo(code_url):
    """Returns repo metadata or a failure status. No cloning."""
    m = re.search(r"github\.com/([\w.\-]+/[\w.\-]+)", code_url)
    if not m:
        if code_url.strip().lower() == "none":
            return {"status": "NONE-GIVEN"}
        return {"status": "NON-GITHUB", "detail": code_url}
    slug = m.group(1).rstrip("/")
    pin = re.search(r"/(?:tree|blob)/([0-9a-f]{7,40})", code_url)
    pinned_sha = pin.group(1) if pin else None
    status, body = http_get("https://api.github.com/repos/" + slug, gh_headers())
    if status == 404:
        return {"status": "NOT-FOUND", "slug": slug}
    if status == 403:
        return {"status": "RATE-LIMITED", "slug": slug}
    if status != 200:
        return {"status": "API-ERROR", "slug": slug, "detail": "http %s" % status}
    info = json.loads(body)
    if info.get("private"):
        return {"status": "PRIVATE", "slug": slug}
    branch = info.get("default_branch", "main")
    out = {"status": "PUBLIC", "slug": slug, "branch": branch,
           "size_kb": info.get("size"), "pushed_at": (info.get("pushed_at") or "")[:10],
           "url": info.get("html_url")}
    ref = pinned_sha or branch
    if pinned_sha:
        out["pinned_in_harvest"] = pinned_sha
    # HEAD (or pinned) commit
    s2, b2 = http_get("https://api.github.com/repos/%s/commits/%s" % (slug, ref), gh_headers())
    if s2 == 200:
        c = json.loads(b2)
        out["head_sha"] = c.get("sha")
        out["head_date"] = ((c.get("commit") or {}).get("committer") or {}).get("date", "")[:10]
    # lean file count via tree (recursive); count .lean paths
    if out.get("head_sha"):
        s3, b3 = http_get("https://api.github.com/repos/%s/git/trees/%s?recursive=1"
                           % (slug, out["head_sha"]), gh_headers())
        if s3 == 200:
            t = json.loads(b3)
            paths = [e.get("path", "") for e in t.get("tree", [])]
            out["lean_files"] = sum(1 for p in paths if p.endswith(".lean"))
            out["tree_truncated"] = bool(t.get("truncated"))
            out["has_lakefile"] = any(os.path.basename(p) in ("lakefile.lean", "lakefile.toml")
                                      for p in paths)
    # lean-toolchain pin via raw
    s4, b4 = http_get("https://raw.githubusercontent.com/%s/%s/lean-toolchain" % (slug, ref))
    if s4 == 200:
        out["lean_toolchain"] = b4.decode(errors="replace").strip()
    return out


def title_match(claim_title, arxiv_title):
    """Loose token-overlap check that the arXiv record is the cited paper."""
    stop = {"the", "a", "an", "of", "for", "and", "in", "on", "to", "with", "via"}
    ct = {w for w in re.findall(r"[a-z0-9]+", claim_title.lower()) if w not in stop}
    at = {w for w in re.findall(r"[a-z0-9]+", (arxiv_title or "").lower()) if w not in stop}
    if not ct or not at:
        return False
    return len(ct & at) / len(ct | at) >= 0.25


def suggest_lanes(text):
    lanes = []
    for pat, typ, why in LANE_KEYWORDS:
        if re.search(pat, text, re.I):
            lanes.append((typ, why))
    seen, out = set(), []
    for typ, why in lanes:
        if typ not in seen:
            seen.add(typ)
            out.append((typ, why))
    return out


def parse_harvest(path):
    with open(path, encoding="utf-8") as f:
        text = f.read()
    meta = {}
    for line in text.splitlines():
        if line.startswith("## CLAIM"):
            break
        m = re.match(r"^(window|source)\s*:\s*(.+)$", line.strip())
        if m:
            meta[m.group(1)] = m.group(2).strip()
    claims = []
    for chunk in re.split(r"^## CLAIM\s+", text, flags=re.M)[1:]:
        cid, _, rest = chunk.partition("\n")
        cid = cid.strip()
        fields = {}
        notes = []
        for line in rest.splitlines():
            m = re.match(r"^(title|claim|paper|code|code_note|inputs_note|signals)\s*:\s*(.*)$", line)
            if m:
                fields[m.group(1)] = m.group(2).strip()
            elif line.strip().startswith("-") and "signals" in fields and "fragility" not in fields:
                notes.append(line.strip()[1:].strip())
        fields["id"] = cid
        if notes and not fields.get("signals"):
            fields["signals"] = ""
        claims.append(fields)
    return meta, claims


def analyze_claim(claim):
    paper_chk = check_paper(claim.get("paper", ""))
    code_chk = check_github_repo(claim.get("code", "none"))
    signals = [s.strip() for s in claim.get("signals", "").split(",") if s.strip()]
    score = 0
    adjustments = []
    for s in signals:
        if s in SIGNAL_POINTS:
            score += SIGNAL_POINTS[s]
        else:
            adjustments.append("unknown signal ignored: %s" % s)
    if code_chk.get("status") in ("NOT-FOUND", "PRIVATE", "RATE-LIMITED", "API-ERROR", "NON-GITHUB"):
        adjustments.append("code repo check: %s" % code_chk["status"])
    if code_chk.get("status") == "PUBLIC":
        if code_chk.get("lean_files") and not code_chk.get("lean_toolchain"):
            score += 1
            adjustments.append("+1: Lean files present, no lean-toolchain pin found")
        if code_chk.get("lean_toolchain"):
            adjustments.append("toolchain pinned: %s" % code_chk["lean_toolchain"])
    if paper_chk.get("status") == "VERIFIED":
        if not title_match(claim.get("title", ""), paper_chk.get("title", "")):
            score += 1
            adjustments.append("+1: arXiv title does not closely match harvest title (check citation)")
    elif paper_chk.get("status") in ("NOT-FOUND", "UNPARSEABLE", "URL-FAILED"):
        score += 1
        adjustments.append("+1: paper identifier did not resolve (%s)" % paper_chk["status"])
    elif paper_chk.get("status") == "URL-BLOCKED":
        adjustments.append("paper URL bot-blocked (http 403); human-reachable, not loop-verified")
    lanes = suggest_lanes(" ".join([claim.get("title", ""), claim.get("claim", ""),
                                    claim.get("code_note", "")]))
    return {"paper": paper_chk, "code": code_chk, "signals": signals,
            "score": score, "adjustments": adjustments, "lanes": lanes}


def render_recon(date, meta, claims, results, harvest_sha):
    lines = []
    lines.append("# Harvest recon — %s" % date)
    lines.append("")
    lines.append("**Harvest window:** %s · **Source:** %s · **Harvest sha256:** `%s`"
                 % (meta.get("window", "?"), meta.get("source", "?"), harvest_sha))
    lines.append("")
    lines.append("Generated by the harvest loop (`scripts/harvest-loop/recon.py`): "
                 "identifier verification, inputs inventory, fragility scoring, "
                 "attack-lane suggestion. No code cloned, nothing run. "
                 "Deep gates wait for a target pick. The verdict lock is untouched.")
    lines.append("")
    lines.append("## Verification ledger")
    lines.append("")
    lines.append("| # | Claim | Paper | Code |")
    lines.append("|---|---|---|---|")
    ranked = sorted(zip(claims, results), key=lambda cr: (-cr[1]["score"], cr[0]["id"]))
    for i, (c, r) in enumerate(ranked, 1):
        p = r["paper"]
        pcell = {"VERIFIED": "VERIFIED (%s)" % p.get("arxiv_id", ""),
                 "URL-RESOLVED": "URL-RESOLVED",
                 "NOT-FOUND": "NOT-FOUND", "UNPARSEABLE": "UNPARSEABLE",
                 "URL-BLOCKED": "URL-BLOCKED", "URL-FAILED": "URL-FAILED",
                 "API-ERROR": "API-ERROR", "PARSE-ERROR": "PARSE-ERROR"}.get(p["status"], p["status"])
        k = r["code"]
        if k["status"] == "PUBLIC":
            ref7 = (k.get("pinned_in_harvest") or k.get("head_sha") or "?")[:7]
            kcell = "PUBLIC %s@%s (%d lean files)" % (k["slug"], ref7, k.get("lean_files", 0))
        else:
            kcell = k["status"]
        lines.append("| %d | %s | %s | %s |" % (i, c["title"], pcell, kcell))
    lines.append("")
    lines.append("## Ranked queue")
    lines.append("")
    for i, (c, r) in enumerate(ranked, 1):
        lines.append("%d. **%s** — fragility %d" % (i, c["title"], r["score"]))
    lines.append("")
    for i, (c, r) in enumerate(ranked, 1):
        p, k = r["paper"], r["code"]
        lines.append("## Card %d: %s" % (i, c["title"]))
        lines.append("")
        lines.append("**Claim:** %s" % c.get("claim", "?"))
        lines.append("**Harvest id:** `%s`" % c["id"])
        lines.append("")
        lines.append("**Paper.** status=%s" % p["status"])
        if p["status"] == "VERIFIED":
            lines.append("- arXiv:%s — *%s*" % (p["arxiv_id"], p["title"]))
            lines.append("- authors: %s · published %s" % (", ".join(p["authors"][:6]), p["published"]))
            lines.append("- %s" % p["url"])
        elif p["status"] in ("URL-RESOLVED", "URL-BLOCKED"):
            lines.append("- %s" % p["url"])
            lines.append("- %s" % p.get("detail", ""))
        elif p.get("detail"):
            lines.append("- detail: %s" % p["detail"])
        lines.append("")
        lines.append("**Code/data.** status=%s" % k["status"])
        if k["status"] == "PUBLIC":
            lines.append("- repo: https://github.com/%s (branch `%s`, pushed %s)"
                         % (k["slug"], k["branch"], k.get("pushed_at", "?")))
            if k.get("pinned_in_harvest"):
                lines.append("- pinned ref (from harvest URL): `%s` (%s)"
                             % (k.get("head_sha", "?"), k.get("head_date", "?")))
            else:
                lines.append("- HEAD: `%s` (%s)" % (k.get("head_sha", "?"), k.get("head_date", "?")))
            lines.append("- Lean files: %d%s · lakefile: %s · toolchain: %s" % (
                k.get("lean_files", 0),
                " (tree truncated — lower bound)" if k.get("tree_truncated") else "",
                "yes" if k.get("has_lakefile") else "not found",
                k.get("lean_toolchain", "not pinned")))
        elif k.get("detail"):
            lines.append("- detail: %s" % k["detail"])
        lines.append("- code note: %s" % c.get("code_note", "?"))
        lines.append("- inputs: %s" % c.get("inputs_note", "?"))
        lines.append("")
        lines.append("**Fragility.** score=%d · signals: %s"
                    % (r["score"], ", ".join("`%s`" % s for s in r["signals"]) or "none"))
        for a in r["adjustments"]:
            lines.append("- %s" % a)
        lines.append("")
        lane_str = "; ".join("type %s — %s" % (t, w) for t, w in r["lanes"]) or "none suggested"
        lines.append("**Suggested lanes (heuristic, confirm on pick):** %s" % lane_str)
        lines.append("")
    lines.append("## Next step")
    lines.append("")
    lines.append("Pick a target. On pick: pin inputs (PDF + repo SHA), write the audit "
                 "note under `docs/audits/`, then run gates.")
    lines.append("")
    return "\n".join(lines)


def render_issue_body(date, meta, claims, results, harvest_sha):
    ranked = sorted(zip(claims, results), key=lambda cr: (-cr[1]["score"], cr[0]["id"]))
    lines = []
    lines.append("Weekly harvest recon is in — %d claims analyzed, nothing run." % len(claims))
    lines.append("")
    lines.append("| Rank | Claim | Fragility | Top signal |")
    lines.append("|---|---|---|---|")
    for i, (c, r) in enumerate(ranked, 1):
        top = r["signals"][0] if r["signals"] else "—"
        lines.append("| %d | %s | %d | `%s` |" % (i, c["title"], r["score"], top))
    lines.append("")
    lines.append("Full recon cards: [`docs/audits/harvest-%s/recon.md`](https://github.com/%s/blob/main/docs/audits/harvest-%s/recon.md)"
                 % (date, REPO_SLUG, date))
    lines.append("")
    lines.append("Reply with the claim name to pick a target. On pick: inputs get pinned, "
                 "an audit note is written, then gates run. Verdict lock untouched.")
    return "\n".join(lines)


def newest_harvest():
    files = sorted(f for f in os.listdir(HARVEST_DIR)
                   if re.match(r"^\d{4}-\d{2}-\d{2}\.md$", f) and f != "README.md")
    return os.path.join(HARVEST_DIR, files[-1]) if files else None


def write_outputs(date, meta, claims, results, harvest_sha):
    outdir = os.path.join(OUT_BASE, "harvest-" + date)
    os.makedirs(outdir, exist_ok=True)
    recon = render_recon(date, meta, claims, results, harvest_sha)
    with open(os.path.join(outdir, "recon.md"), "w", encoding="utf-8") as f:
        f.write(recon)
    ledger = {"date": date, "harvest_sha": harvest_sha, "meta": meta,
              "claims": [{"id": c["id"], "title": c["title"], "score": r["score"],
                          "paper": r["paper"], "code": r["code"],
                          "signals": r["signals"], "adjustments": r["adjustments"],
                          "lanes": r["lanes"]} for c, r in zip(claims, results)]}
    with open(os.path.join(outdir, "ledger.json"), "w", encoding="utf-8") as f:
        json.dump(ledger, f, indent=2)
    with open(os.path.join(outdir, "issue-title.txt"), "w", encoding="utf-8") as f:
        f.write("Harvest %s: %d claims recon'd — pick a target" % (date, len(claims)))
    with open(os.path.join(outdir, "issue-body.md"), "w", encoding="utf-8") as f:
        f.write(render_issue_body(date, meta, claims, results, harvest_sha))
    return outdir


def emit(date, outdir, changed):
    gh_out = os.environ.get("GITHUB_OUTPUT")
    payload = "harvest_date=%s\nrecon_dir=%s\nchanged=%s\n" % (
        date, os.path.relpath(outdir, REPO_ROOT), "true" if changed else "false")
    if gh_out:
        with open(gh_out, "a") as f:
            f.write(payload)
    else:
        print(payload, end="")


def main():
    args = sys.argv[1:]
    health = "--health-check" in args
    args = [a for a in args if a != "--health-check"]
    if health:
        # latest processed harvest
        dirs = sorted(d for d in os.listdir(OUT_BASE) if re.match(r"^harvest-\d{4}-\d{2}-\d{2}$", d))
        if not dirs:
            print("No processed harvest to health-check.")
            return emit("none", OUT_BASE, False)
        date = dirs[-1].replace("harvest-", "")
        path = os.path.join(HARVEST_DIR, date + ".md")
        if not os.path.exists(path):
            print("Harvest file missing for", date)
            return emit(date, os.path.join(OUT_BASE, dirs[-1]), False)
        with open(path, "rb") as f:
            harvest_sha = hashlib.sha256(f.read()).hexdigest()
        meta, claims = parse_harvest(path)
        results = [analyze_claim(c) for c in claims]
        outdir = os.path.join(OUT_BASE, dirs[-1])
        with open(os.path.join(outdir, "ledger.json"), encoding="utf-8") as f:
            old = json.load(f)
        new_ledger = {"date": date, "harvest_sha": harvest_sha, "meta": meta,
                      "claims": [{"id": c["id"], "paper": r["paper"], "code": r["code"]}
                                 for c, r in zip(claims, results)]}
        old_core = [{"id": c["id"], "paper": c["paper"], "code": c["code"]}
                    for c in old["claims"]]
        if new_ledger["claims"] == old_core:
            print("Health check: no identifier changes since last recon.")
            return emit(date, outdir, False)
        # something changed: rewrite ledger, append note
        with open(os.path.join(outdir, "ledger.json"), "w", encoding="utf-8") as f:
            json.dump({**old, "claims": new_ledger["claims"],
                       "last_health_check": datetime.date.today().isoformat()}, f, indent=2)
        with open(os.path.join(outdir, "recon.md"), "a", encoding="utf-8") as f:
            f.write("\n## Health check %s\n\nIdentifier drift detected:\n\n" % datetime.date.today().isoformat())
            for new, oldc in zip(new_ledger["claims"], old_core):
                if new != oldc:
                    f.write("- `%s`: %s\n" % (new["id"], json.dumps(
                        {"paper": new["paper"].get("status"), "code": new["code"].get("status"),
                         "head": (new["code"].get("head_sha") or "?")[:7]})))
            f.write("\n")
        print("Health check: drift detected, recon.md updated.")
        return emit(date, outdir, True)

    path = None
    if args:
        cand = os.path.join(HARVEST_DIR, args[0] + ".md")
        if os.path.exists(cand):
            path = cand
    if path is None:
        path = newest_harvest()
    if path is None:
        print("No harvest file found.")
        return emit("none", OUT_BASE, False)
    date = os.path.basename(path).replace(".md", "")
    with open(path, "rb") as f:
        harvest_sha = hashlib.sha256(f.read()).hexdigest()
    outdir = os.path.join(OUT_BASE, "harvest-" + date)
    recon_path = os.path.join(outdir, "recon.md")
    if os.path.exists(recon_path):
        with open(recon_path, encoding="utf-8") as f:
            if harvest_sha in f.read():
                print("Recon for %s already up to date; skipping." % date)
                return emit(date, outdir, False)
    meta, claims = parse_harvest(path)
    if not claims:
        print("No claims parsed from", path)
        return emit(date, outdir, False)
    results = [analyze_claim(c) for c in claims]
    write_outputs(date, meta, claims, results, harvest_sha)
    print("Wrote recon for %d claims to %s" % (len(claims), outdir))
    return emit(date, outdir, True)


if __name__ == "__main__":
    main()
