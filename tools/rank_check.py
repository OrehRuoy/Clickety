#!/usr/bin/env python3
"""Clickety rank check (stdlib only). Usage:
  python tools/rank_check.py <APPLE_ID_NUMBER> [label]
Searches the US App Store (iPhone) for each term in tools/rank_terms.txt the same way the
App Store app does, finds our app's position, and appends a table to docs/aso-log.md.
<APPLE_ID_NUMBER> = App Store Connect -> App Information -> Apple ID (digits only)."""
import json, sys, time, urllib.parse, urllib.request
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TERMS_FILE = ROOT / "tools" / "rank_terms.txt"
LOG = ROOT / "docs" / "aso-log.md"
UA = "AppStore/3.0 iOS/17.0 model/iPhone15,2 hwp/t8120 build/21A329 (6; dt:230) AMS/1"
STOREFRONT = "143441-1,29"  # US, iPhone software
DEFAULT_TERMS = ["row counter", "knitting counter", "crochet counter", "stitch counter", "knit counter",
                 "knitting row counter", "crochet row counter"]

def search(term):
    url = "https://search.itunes.apple.com/WebObjects/MZStore.woa/wa/search?" + urllib.parse.urlencode(
        {"clientApplication": "Software", "term": term})
    req = urllib.request.Request(url, headers={"User-Agent": UA, "X-Apple-Store-Front": STOREFRONT,
                                               "Accept": "application/json"})
    last = None
    for i in range(3):
        try:
            with urllib.request.urlopen(req, timeout=45) as r:
                d = json.load(r)
            break
        except Exception as e:  # network hiccup: retry
            last = e; time.sleep(1 + i)
    else:
        raise last
    ids = []
    for b in (d.get("pageData") or {}).get("bubbles") or []:
        for it in b.get("results") or []:
            if it.get("entity") == "software" or it.get("type") == 0:
                ids.append(str(it["id"]))
    names = {}
    for k, v in ((d.get("storePlatformData") or {}).get("native-search-lockup") or {}).get("results", {}).items():
        names[str(k)] = v.get("name", "?")
    return ids, names

def main():
    if len(sys.argv) < 2 or not sys.argv[1].isdigit():
        print(__doc__); sys.exit(2)
    app_id = sys.argv[1]
    label = sys.argv[2] if len(sys.argv) > 2 else ""
    terms = [l.strip() for l in TERMS_FILE.read_text().splitlines() if l.strip()] if TERMS_FILE.exists() else DEFAULT_TERMS
    stamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    rows = []
    for t in terms:
        try:
            ids, names = search(t)
        except Exception as e:
            rows.append(f"| {t} | error: {e} | |"); print(t, "ERROR", e); continue
        pos = ids.index(app_id) + 1 if app_id in ids else None
        rank = str(pos) if pos else f">{len(ids)}"
        top3 = "; ".join(names.get(i, i) for i in ids[:3])
        rows.append(f"| {t} | {rank} | {top3} |")
        print(f"{t:<20} rank {rank:<5} top3: {top3}")
        time.sleep(0.6)
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(f"\n### Rank check {stamp} (local time) {label}\n\n| Term | Our rank | Top 3 |\n|---|---|---|\n")
        f.write("\n".join(rows) + "\n")
    print(f"Appended to {LOG}")

if __name__ == "__main__":
    main()
