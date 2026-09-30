# Clickety

Codename: Clickety

- Bundle id: `com.yourprefix.rowcounter`
- Widget id: `com.yourprefix.rowcounter.widget`
- App group: `group.com.yourprefix.rowcounter`
- IAP product id: `com.yourprefix.rowcounter.unlock`
- Team id: `9WRNQYQZTB`
- App profile: Clickety AppStore (`cbdb39bf-bb86-4cf2-a25d-056c974c2337`)
- Widget profile: Clickety Widget AppStore (`e5571501-f310-48e8-8cb9-00b1cd110051`)
- Reserved store name: Clickety: Knitting Row Counter
- Home screen name: Clickety
- Support URL: https://orehruoy.github.io/Clickety/
- Privacy URL: https://orehruoy.github.io/Clickety/privacy.html

## Listing (final)

| Field | Final value | Size |
|---|---|---|
| Title | Clickety: Knitting Row Counter | 30/30 chars |
| Subtitle | Crochet, Knit & Stitch Counter | 30/30 chars |
| Keywords | `amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,click,count,helper,assistant,repeat` | 97/100 bytes, 14 words |
| Category | primary Lifestyle, secondary Utilities | |

Keyword swaps (the only allowed edits; each stays 97 bytes):

- The widget ships (Step 1 PASS + Step 8 done) → `repeat` → `widget`.
- v1 has no multiple counters per project (Step 5 cut) → `multi` → `round`. The "multi counter" claim has to be true.

## Widget spike result: Home Screen PASS (2026-09-29). Write 42 showed 42. A later +1 write showed 2 and stayed 2 after force-quit. Lock Screen not checked yet ("Unlock to edit"). iOS 17 button not checked.

The widget + button adds one to the main count immediately. It does not run linked counters or wraps. Those update when the app merges the taps.

## Parking lot

- v1 does not re-lock after a refund or revocation. A release build never writes `unlocked: false`.

## aso_check (2026-09-30)

```text
Title    (30/30): Clickety: Knitting Row Counter
Subtitle (30/30): Crochet, Knit & Stitch Counter
Keywords (97/100 bytes, 14 terms): amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,click,count,helper,assistant,repeat

Search 'Clickety: Knitting Row Counter': top 3 = ['Knit Row Counter', 'Knitflow — Knitting & Crochet', 'Knit and Crochet Row Counter']

Search 'Clickety': top 3 = ['Clapback AI Keyboard', 'Clicker Wars', 'School Clicker']
RESULT: PASS
```

## release_report (2026-09-30)

```text
PASS  no network classes in scripts/ or scenes/
PASS  OS.shell_open only for the About privacy link and support email
PASS  no ad or analytics words in scripts/ or scenes/
PASS  widget spike panel is gone
PASS  debug rows stay behind OS.is_debug_build()
PASS  no hardcoded prices in scripts/ or scenes/ (debug $— allowed)
PASS  ETC2/ASTC, export_project_only, and version 1.0.0
PASS  plugin lines match their files
PASS  ENABLED matches WidgetBridge and the App Group is present
PASS  WIDGET_SHIPPED is false until the Lock Screen is checked
RESULT: PASS
```

## Step log

2026-09-29 — Step 0: skeleton + iOS TestFlight pipeline (com.yourprefix.rowcounter, Clickety AppStore profile).
2026-09-29 — Step 1: widget spike code is in; phone result not known yet.
2026-09-29 — Step 2: data model, counter logic, and atomic save. Headless tests PASS.
2026-09-29 — Step 3: counter screen (big tap, hint, tap lock, keep-awake). Headless tests PASS.
2026-09-29 — Widget spike panel restored (5 taps on the project name) for the TestFlight check. Result still pending.
2026-09-29 — Step 4: projects list, details, history, timer, and unlock stub. Headless tests PASS.
2026-09-29 — Widget spike: Home Screen showed 42 after Write 42.
2026-09-29 — Widget spike: a later write showed 2 and the widget kept 2 after force-quit. Lock Screen still not checked.
2026-09-29 — Step 5: linked and repeat counters. Headless tests PASS.
2026-09-29 — Step 6: StoreKit unlock and restore, with a desktop fake buy. Headless tests PASS.
2026-09-29 — Step 7: settings and About. Headless tests PASS.
2026-09-29 — Step 8: widget snapshot and pending-tap merge. Headless tests PASS. Lock Screen still unchecked, so the listing keyword is unchanged.
2026-09-29 — Step 9: row alerts and optional daily reminder. Headless tests PASS. Phone check waits for the next build.
2026-09-30 — Step 10: backup, export, and import. Headless tests PASS.
2026-09-30 — Step 11: accessibility, iPad layout, polish, and the review prompt. Headless tests PASS. VoiceOver names are set on the big tap, −1, and Undo. VoiceOver is not confirmed on a device, so the app does not claim support.
2026-09-30 — Step 12: App Store assets, screenshots, and the listing pack. aso_check RESULT: PASS. The keyword field is 97/100 bytes and still uses repeat.
2026-09-30 — Step 13: 1.0.0 release candidate. release_report.sh RESULT: PASS. The widget spike panel is removed. TestFlight upload waits.
2026-09-30 - UI sweep: shared app theme (cards, switches, scrollbars, menus), scroll-safe taps on every scrolling screen, Back buttons, widget redesign (not compiled locally). release_report.sh RESULT: PASS.
2026-09-30 — Enjoying prompt: once, on the 3rd open or later, never on the install day. Yes opens the App Store review. No sends optional feedback through Web3Forms.
