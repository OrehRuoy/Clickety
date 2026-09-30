#!/usr/bin/env python3
"""Clickety pre-launch ASO check (stdlib only). Usage:
  python tools/aso_check.py "<TITLE>" "<SUBTITLE>" "<KEYWORDS>"
Checks Apple's limits and our rules, then searches the US App Store for the title to spot
name collisions. Exit code 1 if any hard rule fails."""
import json, re, sys, time, urllib.parse, urllib.request

UA = "AppStore/3.0 iOS/17.0 model/iPhone15,2 hwp/t8120 build/21A329 (6; dt:230) AMS/1"
STOREFRONT = "143441-1,29"
BANNED = ["free", "app", "best", "sale", "cheap", "lifetime", "subscription", "$", "#1", "top",
          "ravelry", "loopsy", "knitcompanion", "rowvo", "stitchtally", "knitcounter", "pattern keeper",
          "my row counter", "cozyknit", "iphone", "ipad", "apple"]

def words(s):
    return [w for w in re.split(r"[^a-z0-9]+", s.lower()) if w]

def mz_names(term):
    url = "https://search.itunes.apple.com/WebObjects/MZStore.woa/wa/search?" + urllib.parse.urlencode(
        {"clientApplication": "Software", "term": term})
    req = urllib.request.Request(url, headers={"User-Agent": UA, "X-Apple-Store-Front": STOREFRONT})
    with urllib.request.urlopen(req, timeout=45) as r:
        d = json.load(r)
    ids = [str(it["id"]) for b in (d.get("pageData") or {}).get("bubbles") or [] for it in b.get("results") or []]
    res = ((d.get("storePlatformData") or {}).get("native-search-lockup") or {}).get("results", {})
    return [(i, (res.get(i) or {}).get("name", "?")) for i in ids[:25]]

def main():
    if len(sys.argv) != 4:
        print(__doc__); sys.exit(2)
    title, subtitle, keywords = sys.argv[1], sys.argv[2], sys.argv[3]
    fails, warns = [], []
    if len(title) > 30: fails.append(f"title is {len(title)} chars (max 30)")
    if len(subtitle) > 30: fails.append(f"subtitle is {len(subtitle)} chars (max 30)")
    kb = len(keywords.encode("utf-8"))
    if kb > 100: fails.append(f"keywords are {kb} bytes (max 100)")
    if ", " in keywords or " ," in keywords: fails.append("keywords: no spaces around commas (wastes bytes)")
    terms = [t.strip() for t in keywords.split(",") if t.strip()]
    for t in terms:
        if len(t) <= 2: warns.append(f"keyword '{t}' is 2 chars or less")
    dup = sorted({t for t in terms if terms.count(t) > 1})
    if dup: fails.append(f"keywords repeated: {dup}")
    ts_words = set(words(title) + words(subtitle))
    rep = sorted({t for t in terms if set(words(t)) <= ts_words})
    if rep: fails.append(f"keywords already in title/subtitle (wasted): {rep}")
    all_text = " ".join([title, subtitle, keywords]).lower()
    for b in BANNED:
        hit = (b in all_text) if not b.isalnum() else (b in words(all_text) or (" " in b and b in all_text))
        if hit: fails.append(f"banned/competitor/pricing word: '{b}'")
    for w in ("knitting", "crochet", "counter"):
        if w not in ts_words: warns.append(f"'{w}' is not in title+subtitle (kill-line terms need it)")
    print(f"Title    ({len(title)}/30): {title}\nSubtitle ({len(subtitle)}/30): {subtitle}\nKeywords ({kb}/100 bytes, {len(terms)} terms): {keywords}")
    try:
        norm = lambda s: re.sub(r"[^a-z0-9]", "", s.lower())
        brand = re.split(r"[:\-–—]", title)[0].strip()
        for q in dict.fromkeys([title, brand]):
            hits = mz_names(q)
            exact = [n for _, n in hits if norm(n) == norm(q)]
            near = [n for _, n in hits if norm(brand) and norm(brand) in norm(n)]
            print(f"\nSearch '{q}': top 3 = {[n for _, n in hits[:3]]}")
            if exact: fails.append(f"an app named exactly '{q}' already exists: {exact}")
            if near: warns.append(f"apps containing '{brand}': {near[:5]}")
            time.sleep(0.6)
    except Exception as e:
        warns.append(f"collision search failed ({e}); re-run later")
    for w in warns: print("WARN:", w)
    for f in fails: print("FAIL:", f)
    print("RESULT:", "FAIL" if fails else "PASS")
    sys.exit(1 if fails else 0)

if __name__ == "__main__":
    main()
