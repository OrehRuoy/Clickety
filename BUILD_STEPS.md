# Clickety — Cursor build steps (knit & crochet row counter, iOS)

**For:** Brock Hall · **Prepared by:** Lauren · **Date:** 2026-09-29
**Codename:** `Clickety`. It's used for the folder `Desktop\Clickety`, the repo `OrehRuoy/Clickety`, the Godot project name, and the window title.
**FINAL listing values** (the ASO test is done: `knit-counter-aso-test.md`, 2026-09-29; all three pass `tools/aso_check.py`):
| Field | Final value | Size |
|---|---|---|
| Title | `Clickety: Knitting Row Counter` | 30/30 chars |
| Subtitle | `Crochet, Knit & Stitch Counter` | 30/30 chars |
| Keywords | `amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,click,count,helper,assistant,repeat` | 97/100 bytes, 14 words |
| Category | primary **Lifestyle**, secondary **Utilities** | |

- **Keyword swaps** (the only allowed edits; each stays 97 bytes):
  - The widget ships (Step 1 PASS + Step 8 done) → `repeat` → `widget`.
  - v1 has no multiple counters per project (Step 5 cut) → `multi` → `round`. The "multi counter" claim has to be true.
- **Name status:**
  - No live US trademark: all 14 `clickety*`/`clickity*` USPTO records are dead. No App Store app is named "Clickety".
  - It's usable but **weakly distinctive / hard to trademark**. "Clickety(-clack)" is common knitting talk, and **Clickety Sticks** (clicketysticks.com, a free knit/crochet pattern site since 2010) plus two small UK craft brands use it.
  - A stale tap-counter app, "Tap Counter App: Clickity", catches misspellings.
  - Not a reason to switch, because the search value is in "Knitting Row Counter" and the subtitle. Optional: file CLICKETY in class 9 early, or ask a lawyer about Clickety Sticks' earlier use.
- **Domains:** `getclickety.com` and `clicketycounter.com` appeared free on 2026-09-29. They're optional; a free GitHub Pages site is fine for the Support and Privacy URLs.

**Identifiers** (`<prefix>` is filled in by hand in Step 0; none of these can change once used):
| What | Value |
|---|---|
| App bundle ID | `com.<prefix>.rowcounter`. Generic on purpose, so it survives a store-name change. |
| Widget extension bundle ID | `com.<prefix>.rowcounter.widget` (Step 1) |
| App Group | `group.com.<prefix>.rowcounter` (Step 1) |
| IAP product ID (non-consumable) | `com.<prefix>.rowcounter.unlock` (Step 6). Product IDs can never be reused, even after deletion. |
| ASC SKU | `clickety-ios` |
| Team | `9WRNQYQZTB` (same as Oil Due / Taptico) |

**Engine:** Godot **4.6.3** stable, GDScript, 2D, Mobile renderer. This matches Oil Due's CI.
**Ship path:** Windows + Cursor → GitHub Actions `macos-26` → Godot export (Xcode project) → CI adds plugins and the widget target → `xcodebuild archive` → IPA → `altool` → TestFlight → App Store.
**Business model (locked):**
- Free download.
- **Free:** 1 project with a main counter, plus undo/−1, notes, history, keep-awake, haptics, and backup/export.
- **Unlock, one time** (non-consumable IAP; the price tier is set in ASC and never shown in screenshots or metadata): unlimited projects, linked/repeat counters, the lock-screen/home widget, and reminders.
- No subscription, no trial, no ads, no account, no analytics SDK. No network except Apple's StoreKit.

---

## MASTER CHECKLIST — do it in this order

`[B]` = Brock by hand, in a browser or on the phone. `[C]` = a Cursor step from this file. Tick as you go.

**Week 0 — before any code (one evening)**
1. `[B]` **Reserve the name.** App Store Connect → Apps → + New App → Name **`Clickety: Knitting Row Counter`**. This is the real availability check.
   - If it's taken, try **Knitting Row Counter: Clickety**, then **Row Robin: Knitting Counter**.
   - Use bundle ID `com.<prefix>.rowcounter` and SKU `clickety-ios`. Creating the record reserves the name.
   - The USPTO check is already done: no live mark. Optional: register `getclickety.com` or `clicketycounter.com`, and check the @clicketyapp handles by hand.
2. `[B]` **developer.apple.com → Identifiers:**
   - App ID `com.<prefix>.rowcounter` with **App Groups** and **In-App Purchase** on.
   - App ID `com.<prefix>.rowcounter.widget` with **App Groups** on.
   - App Group `group.com.<prefix>.rowcounter`, assigned to both App IDs.
3. `[B]` **Profiles:** two App Store distribution profiles, one per App ID, both on your Apple Distribution cert. Name them exactly `Clickety AppStore` and `Clickety Widget AppStore`. Download both.
4. `[B]` **GitHub:**
   - Create the private repo `OrehRuoy/Clickety` and clone it to `Desktop\Clickety`.
   - Copy this file in as `BUILD_STEPS.md`.
   - Copy these from OilDue: `tools/ios/patch_xcode_signing.py` → `tools/ios/`, `native/godot-storekit/` → `native/godot-storekit/`, `scripts/generate_godot_gen_headers.py` → `native/generate_godot_gen_headers.py`, `native/build_plugins.sh` → `native/build_plugins_oildue_reference.sh`.
   - Add the secrets (Step 0 lists them; the 6th, `APPLE_WIDGET_PROVISIONING_PROFILE_BASE64`, is new).
5. `[B]` **ASC → Business:** confirm the Paid Apps agreement, tax and banking are active (Oil Due's IAP should already have covered this; **verify**).
6. `[B]` **Outreach, part 1** (the cheap test that runs during the build):
   - Send the first **5 pitch emails** from Appendix K (MDK, Simply Knitting, Simply Crochet, Knitting magazine, VeryPink). Pitch "coming mid-October".
   - Log each send and reply in `docs/outreach.md`.

**Build — about 2–3 weeks of evenings (target: ship mid-October; hard deadline mid-November)**
7. `[C]` **Step 0:** skeleton plus an empty build on TestFlight.
8. `[C]` **Step 1:** WIDGET SPIKE, timeboxed to **2 evenings max**. Record PASS or FAIL in `PLAN.md`.
   - If it FAILS: remove "widget" from the unlock list, the keywords, the screenshots and the description, and skip Step 8.
9. `[C]` **Step 2:** data model + safe save.
10. `[C]` **Step 3:** counter screen. → TestFlight (feel test: tap speed, haptic).
11. `[C]` **Step 4:** projects list + project details.
12. `[C]` **Step 5:** linked / repeat counters.
13. `[B]` **ASC → your app → Monetization → In-App Purchases → + Non-Consumable:**
    - Product ID `com.<prefix>.rowcounter.unlock`, reference name `Clickety Unlock`, display name "Unlock Clickety".
    - Pick the price tier (the plan is the $3.99 tier; the price never appears in screenshots or metadata).
    - Add a review screenshot of the Unlock screen after Step 6.
    - Family Sharing: **decide before you save.** You can turn it on later but never off. Recommended: on (trust). **Verify** the toggle behavior in ASC.
14. `[C]` **Step 6:** IAP unlock + Restore purchases. → TestFlight sandbox purchase + restore (twice).
15. `[C]` **Step 7:** settings (keep-awake, haptics, sound, theme, text size).
16. `[C]` **Step 8:** widget integration (only if Step 1 passed). → TestFlight.
17. `[C]` **Step 9:** reminders (row alerts + optional daily nudge notification). → TestFlight with the app killed.
18. `[C]` **Step 10:** backup / export / import (Files).
19. `[C]` **Step 11:** accessibility, iPad, polish, review prompt. → TestFlight (iPhone + iPad).
20. `[B]` **Outreach, part 2:** send the remaining ~5 pitches (Appendix K). Count replies. **Fewer than 2 replies by ship day** means outreach isn't a real path, and the day-14 rank check decides the app.
21. `[B]` **Lock the keyword swaps.** The final title, subtitle and keywords are at the top of this file.
    - Apply the two swap rules: widget shipped → `repeat`→`widget`; no multiple counters → `multi`→`round`.
    - Write the result into `PLAN.md`.
22. `[C]` **Step 12:** App Store assets + screenshot mode + listing pack (title, subtitle, keywords, promo text, description, caption order, category, What's New).
23. `[C]` **Step 13:** release build + the **pre-launch ASO checklist** + submission.
24. `[B]` Submit for review. The IAP is submitted with the version (**verify in ASC**: a first IAP must be attached to a version).

**Launch → day 30**
25. `[B]` **Launch day (day 0):** baseline rank snapshot for the 7 core terms (Step 14 script). Update the promo text.
26. `[C]/[B]` **Days 1–6:** bug fixes only. Also prepare **v1.0.1** so a listing revision can ship on day 7. Title, subtitle and keywords can only change with a new version (**verify**); promo text can change anytime.
27. `[B]` **Day 7:** rank check + ASC numbers.
    - If `knitting counter` or `crochet counter` is **not top 10**: make the **one listing revision** and submit v1.0.1.
      - If it's outside the top 10 for `knitting row counter` but inside for `crochet row counter` → title `Clickety: Crochet Row Counter`, subtitle `Knitting & Stitch Counter` (R-D).
      - Otherwise use the Step 14 rule.
28. `[B]` **Day 14:** rank check. **KILL** if not top 10 for `knitting counter` or `crochet counter` after that one revision.
29. `[B]` **Day 30:**
    - **KILL** if there are **fewer than 10 unlocks**, whatever the ratings.
    - **KEEP** at **25+ unlocks** (or 15+ ratings).
    - In between: push through December.
30. `[B]` **Jan 5, 2027:** decide on December unlocks. **Park it** if December is under about 44 unlocks (about $5/day).

---

## How to use this file

1. This file lives in the repo root as `BUILD_STEPS.md`. Cursor reads the appendices from it.
2. Open Cursor on `Desktop\Clickety`. Model picker: **Grok 4.7 High**.
3. Paste **one step's block** (the part inside the `text` code block) into a **new chat**.
   - Use **Plan mode** for every step in this file. They all add a screen, a system, save data, IAP or CI.
4. Cursor writes a plan. Read it. If it adds anything from the step's DO NOT list or from a later step, tell it to cut that. When it's right, say **OK**.
5. **The same chat implements the plan it wrote.** Stay on Grok 4.7 High. Don't switch to Composer, Auto or another model partway through.
6. Run the step's **Acceptance tests**:
   - F5 = run the project, F6 = run the open scene, both in the Godot editor on Windows.
   - TestFlight = on your iPhone/iPad.
7. If something fails, stay in that same chat and paste what you saw (screenshot or error text). Use Plan mode again only if the fix touches a new system.
8. When everything passes: **commit + push** (the template is at the bottom of each step), then start the next step in a **new chat**.

**Skip Plan mode** for one-line CI fixes, typos, and color, number or copy tweaks. Use the "Quick fix" template in Appendix E.

**TestFlight:** GitHub → Actions → **iOS TestFlight** → Run workflow → tick **run_macos_export** → Run. A normal push runs only the cheap Linux preflight.
- Required after Steps 0, 1, 3, 6, 8, 9, 11 and 13.

---

## Project rules (Cursor keeps these for every step)

Step 0 copies this block into the repo as `PROJECT_RULES.md`. Every step prompt tells Cursor to read it first.

```text
CLICKETY PROJECT RULES — read before every step. If a step prompt and these rules disagree, stop and ask.

IDENTITY
- Codename Clickety: folder, repo OrehRuoy/Clickety, project.godot config/name, window title.
- Store title is "Clickety: Knitting Row Counter" (App Store Connect only). Every user-facing app name inside the app reads from scripts/ui/app_info.gd (DISPLAY_NAME = "Clickety"). Never hardcode a store name anywhere else.
- Bundle id com.<prefix>.rowcounter; widget com.<prefix>.rowcounter.widget; App Group group.com.<prefix>.rowcounter; IAP product id com.<prefix>.rowcounter.unlock. All live in scripts/ui/app_info.gd (and CI reads bundle id from export_presets.cfg). They never change after first upload.

ENGINE / PLATFORM
- Godot 4.6.3 stable, GDScript only (no C#), 2D, renderer "mobile". CI GODOT_VERSION must match exactly.
- rendering/textures/vram_compression/import_etc2_astc=true must stay on (iOS export fails without it).
- Portrait only. Viewport 428x926, stretch canvas_items, aspect expand, window/handheld/orientation=1.
- Universal: iPhone + iPad (targeted_device_family=2). iPad = centered portrait column (max ~600 design px) on a full-bleed background; must look intentional.
- min iOS 15.0 for the app. Widget extension targets iOS 16.0 (lock-screen families); interactive widget buttons only on iOS 17+ (availability-guarded).
- export_project_only=true (never flip it).

PRODUCT LOCKS (v1)
- Free: 1 project with its main counter + undo/-1 + notes + history + keep-awake + haptics + backup/export. Unlock (one non-consumable IAP): unlimited projects, linked/repeat counters, widget, reminders. Nothing that is free today ever becomes paid later.
- NEVER RE-LOCK: once unlocked on a device, the cached entitlement stays true forever. No code path sets it false in release builds. StoreKit failure/offline never locks.
- NO subscriptions, trials, ads, ad SDKs, accounts/login, analytics/crash SDKs, Firebase, iCloud, backend. NO network code (HTTPRequest, HTTPClient, WebSocketPeer, StreamPeerTCP, PacketPeerUDP, ENet, MultiplayerAPI). The only network is Apple StoreKit inside the native plugin.
- NO onboarding quiz, NO forced tutorial, NO nag screens, NO paywall on launch. The app opens straight to a counter you can tap.
- Screenshots/metadata never show prices, "$", "Free", "sale", "#1", "best", or competitor names.
- NO volume-button counting (App Review 2.5.9 rejects apps that alter the Volume buttons). NO PDF patterns, Ravelry, Apple Watch, voice, sync in v1 (parking lot).

DATA SAFETY (the #1 promise: never lose a count)
- All user data in user://data/. Saves are atomic: write <file>.tmp → flush → close → copy current <file> to <file>.bak → rename .tmp over <file> (fallback: remove + rename, .bak already exists). Every JSON has "version". Load order: main → .bak → defaults; never crash; never overwrite a good .bak with a file that failed to parse.
- Save on every count change (coalesced to at most once per frame) and on NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_CLOSE_REQUEST. Resume exactly (same project, same counters, same screen).
- Schema migrations are pure functions with tests; never drop unknown keys.

PLUGINS (only these, only from the step that adds them)
- StoreKit (Step 6, built in CI from native/godot-storekit, adapted from Oil Due), WidgetBridge (Step 1, built in CI from native/godot-widgetbridge), NotificationSchedulerPlugin iOS v5.2 (Step 9, downloaded in CI; v6.x is for Godot 4.7 — do not use).
- GDScript must run on Windows with no plugins: every native call goes through an autoload that no-ops (or uses an editor "pretend" path) when Engine.has_singleton(...) is false.

FOLDERS
  project.godot, export_presets.cfg, PROJECT_RULES.md, PLAN.md (step log), BUILD_STEPS.md
  .github/workflows/ios-testflight.yml
  scenes/                counter, projects, project_edit, counters_edit, settings, unlock, backup, about
  scenes/components/     big_tap, counter_card, top_bar, sheet, row_alert_banner, toggle_row, stepper
  scripts/core/          project_model.gd, counter_logic.gd, history.gd, schema.gd, alerts.gd  (pure logic)
  scripts/autoload/      store.gd (Store), purchase.gd (Purchase), app_settings.gd (AppSettings), feedback.gd (Feedback), widget_sync.gd (WidgetSync), notify_service.gd (NotifyService)  (max 6)
  scripts/ui/            one script per scene + safe_area.gd, palette.gd, app_info.gd, layout.gd
  assets/                fonts/, sfx/, icon/, theme.tres, CREDITS.txt
  native/                godot-storekit/, godot-widgetbridge/, build_plugins.sh, generate_godot_gen_headers.py (excluded from export)
  ios/plugins/           StoreKit.gdip, WidgetBridge.gdip, NotificationSchedulerPlugin/ (xcframeworks built/downloaded in CI, not committed)
  ios/widget/            ClicketyWidget/*.swift, Info.plist, ClicketyWidget.entitlements, app/WidgetReload.swift
  addons/                NotificationSchedulerPlugin/ (Step 9)
  tests/                 test_*.tscn + test_*.gd   (excluded from export)
  tools/                 ios/patch_xcode_signing.py (verbatim from OilDue), ios/add_widget_target.rb, ios/check_signing.rb, screenshot_mode.tscn, rank_check.py (excluded)
  docs/                  store-listing.md, privacy.html, qa-checklist.md, outreach.md, aso-log.md (excluded)

CODE RULES
- scripts/core/* is pure (RefCounted/static, no Node, no autoload access) and testable headless.
- UI never computes counter logic; it calls CounterLogic.
- Buttons use the pressed signal only (Oil Due touch+mouse double-fire lesson). The big tap target is a flat Button with action_mode = ACTION_MODE_BUTTON_PRESS.
- Every screen sits inside SafeArea. Hit targets >= 56x56 design px (-1/Undo), body text >= 18, the count numeral >= 120 and scales with Text size.
- Color is never the only signal (icons/labels too). Counter accent colors from Okabe-Ito.
- Developer/debug UI only when OS.is_debug_build() (CI exports release → hidden on TestFlight).
- Assets: self-made, CC0, or OFL fonts; record in assets/CREDITS.txt. No competitor art.
- Naming: snake_case files, PascalCase class_name, scene named after its script.

PROCESS
- Plan mode first. No edits until Brock says OK. Then implement in the SAME chat as Grok 4.7 High.
- Do ONLY the current step. Later-step needs go under "Later" in the plan.
- Don't touch .github/workflows/, export_presets.cfg, native/, ios/, tools/ios/ unless the step says so.
- Don't commit or push unless Brock asks.
- End of each step: add one line to PLAN.md "Step log" and print Brock's test list.
- New pure logic gets tests/test_*.tscn (F6 shows PASS/FAIL; headless exits 0/1).
```

---
## Step 0 — Repo, skeleton, and an empty build on TestFlight

**Goal:** prove that a nearly empty Clickety build reaches TestFlight and opens on your iPhone and iPad **before any features exist**. In Oil Due this was the hardest part, so it goes first. No plugins and no widget yet.

### Before you paste (you, by hand, ~60 min — master checklist items 1–5)

1. **Pick `<prefix>`** and write down all four identifiers from the table at the top. The bundle ID becomes permanent once a build is uploaded.
2. **developer.apple.com → Certificates, IDs & Profiles:**
   - **Identifiers → + → App Groups →** `group.com.<prefix>.rowcounter` (description "Clickety shared").
   - **Identifiers → + → App IDs → App →** explicit `com.<prefix>.rowcounter`. Tick **App Groups** (Configure → select the group) and **In-App Purchase** (usually on by default).
   - **Identifiers → + → App IDs → App →** explicit `com.<prefix>.rowcounter.widget`. Tick **App Groups** (Configure → the same group). It's an extension, but Apple registers it as an ordinary App ID (**verify** the portal wording).
   - **Profiles → + → App Store Connect (distribution)**, one for each App ID, both using your existing **Apple Distribution** cert (team `9WRNQYQZTB`):
     - Name the app profile **`Clickety AppStore`** and download `Clickety_AppStore.mobileprovision`.
     - Name the widget profile **`Clickety Widget AppStore`** and download it.
     - Create the profiles **after** enabling App Groups. If you change a capability later, regenerate the profile and update the secret and UUID.
   - Open the **app** profile in Notepad and copy the **UUID** (the string after `<key>UUID</key>`). CI reads the widget profile's UUID from the file itself.
3. **App Store Connect → Apps → + New App:** iOS; Name **`Clickety: Knitting Row Counter`** (fallbacks in the master checklist); language English (U.S.); bundle ID `com.<prefix>.rowcounter`; SKU `clickety-ios`; User Access Full. **This reserves the name.** Write the name you got into `PLAN.md` after Step 0 creates it.
4. **GitHub:**
   - Create the private repo `OrehRuoy/Clickety` and clone it to `Desktop\Clickety`.
   - Copy this file in as `BUILD_STEPS.md`.
   - From your OilDue folder, copy **byte-for-byte**:
     - `tools/ios/patch_xcode_signing.py` → `tools/ios/patch_xcode_signing.py`
     - `native/godot-storekit/` (whole folder) → `native/godot-storekit/` (used from Step 6)
     - `scripts/generate_godot_gen_headers.py` → `native/generate_godot_gen_headers.py`
     - `native/build_plugins.sh` → `native/build_plugins_oildue_reference.sh` (reference only; Step 1 writes the real one)
5. **GitHub → Settings → Secrets and variables → Actions.** Add six secrets, the same five as Oil Due plus one new:
   - `APPLE_CERTIFICATE_BASE64`: the same distribution `.p12`, base64
   - `APPLE_CERTIFICATE_PASSWORD`: its password
   - `APPLE_PROVISIONING_PROFILE_BASE64`: the **new `Clickety AppStore`** profile, base64
   - `APPLE_ID_USERNAME`: your Apple ID email
   - `APPLE_ID_PASSWORD`: an **app-specific password** (appleid.apple.com), not your real password
   - **NEW** `APPLE_WIDGET_PROVISIONING_PROFILE_BASE64`: the `Clickety Widget AppStore` profile, base64 (used from Step 1)

   PowerShell to base64 a file:
   `[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\Users\Ultima\Downloads\Clickety_AppStore.mobileprovision")) | Set-Clipboard`
6. In Godot 4.6.3: **Editor → Manage Export Templates → Download 4.6.3**.

### Paste into Cursor (Plan mode)

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. Do not hand off to Composer/Auto/another model.

Clickety — Step 0: repo skeleton + GitHub Actions TestFlight pipeline. Only this step.

Read first: BUILD_STEPS.md (the "Project rules" block and Appendices A, B, C, D, F). This folder is a fresh clone of OrehRuoy/Clickety. tools/ios/patch_xcode_signing.py, native/godot-storekit/, native/generate_godot_gen_headers.py and native/build_plugins_oildue_reference.sh are already copied from OilDue: leave them byte-for-byte.

My values:
- Prefix: <PREFIX>            ← I will type it here
- App profile UUID (Clickety AppStore): <UUID>   ← I will paste it here
- Team id: 9WRNQYQZTB
- Name reserved in App Store Connect: <NAME I GOT>

GOAL
A Godot 4.6.3 project that opens in the editor, runs on Windows (F5), passes the Linux preflight on push, and on manual dispatch exports → archives → uploads an IPA to TestFlight. No features, no plugins, no widget.

WHAT TO BUILD
1. PROJECT_RULES.md = the Project rules block from BUILD_STEPS.md, verbatim, with <prefix> replaced by my prefix.
2. PLAN.md: header (codename Clickety, bundle id, widget id, app group, IAP product id, reserved store name, the FINAL title/subtitle/keywords/category table from the top of BUILD_STEPS.md + the two keyword swap rules), "## Widget spike result: (pending)", and an empty "## Step log".
3. project.godot per Appendix D. .gitignore per Appendix D.
4. Folder skeleton from the rules (empty folders get .gitkeep).
5. scripts/ui/app_info.gd: class_name AppInfo with consts DISPLAY_NAME := "Clickety", CODENAME := "Clickety", BUNDLE_ID, WIDGET_BUNDLE_ID, APP_GROUP, IAP_PRODUCT_ID (all with my prefix), PRIVACY_URL := "", SUPPORT_EMAIL := "".
6. scripts/ui/safe_area.gd (MarginContainer applying DisplayServer.get_display_safe_area() in design px, refresh on size_changed, 0 on desktop) and scripts/ui/layout.gd (content column width = min(viewport width, 600)).
7. scenes/counter.tscn as the main scene placeholder: full-bleed cream background (#FBF6EE), SafeArea, centered column with AppInfo.DISPLAY_NAME, "Step 0 pipeline build", OS.get_name() + screen size in small text. Nothing else.
8. tools/make_placeholder_icon.gd (headless: godot --headless --script tools/make_placeholder_icon.gd) → assets/icon/icon_1024.png, 1024x1024, fully OPAQUE, cream background with a terracotta (#B4492E) rounded "tally tick" mark and a yarn-ball circle, no text. Run it, keep the PNG.
9. export_presets.cfg per Appendix C BUT for Step 0: no plugins/* lines at all, and entitlements/additional="" (the App Group entitlement comes in Step 1). Fill bundle id + UUID.
10. .github/workflows/ios-testflight.yml = Appendix A exactly. (Its plugin, notification and widget steps are all conditional and are skipped while ios/widget/ENABLED is absent and no plugins/*=true lines exist.)

ACCEPTANCE TESTS (I will run these)
- Godot opens the project with no errors. F5 shows the portrait window with the title and "Step 0 pipeline build".
- Project → Export shows "iOS (TestFlight IPA)" with bundle id, team, min iOS 15.0, device family iPhone & iPad.
- git push → preflight green.
- Actions → iOS TestFlight → Run workflow (run_macos_export ticked) → green; build appears in TestFlight.
- iPhone: opens, fills the screen in portrait, respects notch/home bar. iPad: portrait, background fills (no black bars).

DO NOT
- Add counters, screens, plugins, StoreKit calls, the widget, or network code.
- Make preflight require secrets or a UUID (only the macOS job checks those).
- Change GODOT_VERSION from 4.6.3, flip export_project_only, or add Android.
- Edit the files copied from OilDue.
- Commit or push unless I ask.

When done: add the Step 0 line to PLAN.md and print my test list.
```

**If CI goes red:** open the failed step's log and use the **Quick fix** template (Appendix E) with the first `error:` line. Common causes are in Appendix F. Don't start Step 1 until an empty build has installed from TestFlight.
**Commit:** `Step 0: skeleton + iOS TestFlight pipeline`

---

## Step 1 — WIDGET SPIKE (timebox: 2 evenings, then decide)

**Why first:** the lock-screen widget is the one feature users ask for by name ("I won't unlock a phone to advance counters… add a lock screen widget"), and it's also the one thing Godot can't do. Loopsy, Ply, Cablewick and Spool already ship one. If we can't, the paid unlock loses its best reason and the kill read has to say so.

**What's uncertain (be honest with yourself):**
1. **Adding an app-extension target to Godot's exported `.pbxproj` in CI.** Godot has no option for this. We script it with the Ruby **`xcodeproj`** gem (the CocoaPods library; free). The draft script is in Appendix I. Whether the gem-generated target archives cleanly on Xcode 26 is **unverified**.
2. **Signing two targets.** Oil Due's `patch_xcode_signing.py` rewrites **every** `PROVISIONING_PROFILE_SPECIFIER` in the project to the app profile. If the widget target existed at that point, it would get the wrong profile.
   - **Fix:** run Oil Due's script first (while only the app target exists), then add the widget target with its own Manual signing and profile. Then `tools/ios/check_signing.rb` fails the build if any target has the wrong profile.
   - Never pass `PROVISIONING_PROFILE_SPECIFIER` on the `xcodebuild` command line, because that applies to every target.
3. **The WidgetCenter reload from Godot.** `WidgetCenter.reloadAllTimelines()` is Swift-only. The plan is a 5-line Swift file added to the **app** target that exports a C function with `@_cdecl`, which the Objective-C++ bridge plugin calls. `@_cdecl` works but is an underscored (unofficial) Swift attribute.
   - **Fallback:** skip reload calls. The widget then refreshes only when iOS decides, which can take minutes.
4. **Version matching.** App Store validation rejects an extension whose `CFBundleShortVersionString`/`CFBundleVersion` differ from the app's. The script copies them from the app's Info.plist.
5. **Interactive +1 from the widget** (iOS 17 AppIntents) is a **stretch**. The minimum to pass is read-only display on the Home Screen **and** the Lock Screen.
   - The intent runs in the widget's process and can't touch the Godot save. It writes a "pending taps" list into the App Group, and the app merges it on launch/resume (Step 8).
   - Cross-process `UserDefaults` read-modify-write isn't atomic. It's fine for a spike and needs care in Step 8.

**Decision rule:**
- **PASS** = a TestFlight build where you can add a "Clickety" widget on the Home Screen and the Lock Screen, and it shows the number the app wrote within a few seconds of tapping in the app.
  - **Stretch PASS** = the widget's + button increments on iOS 17+.
- **FAIL** = not working by the end of evening 2. Then:
  - delete `ios/widget/ENABLED`
  - set `plugins/WidgetBridge=false`
  - write "Widget spike: FAIL (reason)" in `PLAN.md`
  - remove "widget" from the unlock list, the Unlock screen copy (Step 6), the keywords, the description and the screenshots
  - skip Step 8
  - ship v1 without it.
- Don't spend evening 3.

**Before you paste (you):** confirm the `APPLE_WIDGET_PROVISIONING_PROFILE_BASE64` secret exists and the widget App ID has App Groups on (Step 0 prep).

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 1: WIDGET SPIKE (WidgetKit extension added to the Godot-exported Xcode project in CI + App Group + a tiny native bridge). Read PROJECT_RULES.md, PLAN.md, BUILD_STEPS.md Step 1 + Appendices A, B, F, H, I, export_presets.cfg, .github/workflows/ios-testflight.yml, tools/ios/patch_xcode_signing.py (read only), native/build_plugins_oildue_reference.sh, native/godot-storekit/src/* (as a pattern) first. Only this step. You MAY edit .github/workflows/, export_presets.cfg, native/, ios/, tools/ios/ (except patch_xcode_signing.py).

GOAL
On a TestFlight build: a Home Screen widget (small, medium) and Lock Screen widgets (rectangular, circular, inline) named "Clickety" that show a test count written by the Godot app through an App Group. Stretch: iOS 17 interactive "+1" button in the widget.

WHAT TO BUILD (Appendix I has drafts — use them, fix what doesn't compile, and tell me every change)
1. ios/widget/ENABLED (empty marker file). CI adds the widget only when it exists.
2. ios/widget/ClicketyWidget/: ClicketyWidget.swift (WidgetBundle, StaticConfiguration kind "ClicketyCount", TimelineProvider reading the "snapshot" JSON from UserDefaults(suiteName: group)), Snapshot.swift (Codable, tolerant decoding), IncrementIntent.swift (@available(iOS 17) AppIntent: +1 to the snapshot + append to "pending"), Info.plist (NSExtensionPointIdentifier com.apple.widgetkit-extension; ClicketyAppGroup key filled by CI; versions from build settings), ClicketyWidget.entitlements (com.apple.security.application-groups = [group]).
3. ios/widget/app/WidgetReload.swift: @_cdecl("clickety_widget_reload") → WidgetCenter.shared.reloadAllTimelines(). Added to the APP target by the Ruby script.
4. native/godot-widgetbridge/src/widget_bridge.mm (+ .h) and GodotPluginEntry.cpp: Engine singleton "WidgetBridge" with is_available() -> bool, write_snapshot(json: String) -> bool, reload(), take_pending() -> String (returns and clears the "pending" JSON array). Group id read from Info.plist key ClicketyAppGroup (never hardcoded). Same C++-entry/ObjC-impl split as Oil Due's StoreKit plugin.
5. ios/plugins/widgetbridge/WidgetBridge.gdip (init widgetbridge_init / deinit widgetbridge_deinit; system Foundation.framework; linker -ObjC; comments only with ';').
6. native/build_plugins.sh: adapted from the OilDue reference — same compile/libtool/xcframework flow and Godot header fetch (GODOT_SOURCE_VERSION 4.6.3, IOS_MIN 15.0, header script at native/generate_godot_gen_headers.py), but builds ONLY the plugins whose export_presets.cfg line is plugins/<Name>=true (for now WidgetBridge; StoreKit is added in Step 6). No PhotoPicker/DatePicker.
7. tools/ios/add_widget_target.rb (Appendix I): opens the exported .xcodeproj with the xcodeproj gem; copies ios/widget/ClicketyWidget into build/; adds target ClicketyWidget (app_extension, iOS 16.0, Swift 5) with Manual signing, PRODUCT_BUNDLE_IDENTIFIER <app>.widget, PROVISIONING_PROFILE_SPECIFIER = widget profile name, CODE_SIGN_ENTITLEMENTS, SKIP_INSTALL YES, APPLICATION_EXTENSION_API_ONLY YES, MARKETING_VERSION/CURRENT_PROJECT_VERSION copied from the app's Info.plist; embeds the .appex into the app (Copy Files → PlugIns) + target dependency; adds WidgetReload.swift to the app target (SWIFT_VERSION 5.0 if missing); writes ClicketyAppGroup into the widget Info.plist; ensures the app's .entitlements contains the App Group (idempotent; the preset also adds it). Fails loudly with a clear message at every lookup.
8. tools/ios/check_signing.rb: prints target → bundle id / style / profile for Release; exits 1 unless app = "Clickety AppStore" profile name and widget = "Clickety Widget AppStore" profile name (names read from the installed profiles, passed as args).
9. .github/workflows/ios-testflight.yml: the Appendix A widget-aware version (it already contains these steps behind `if [ -f ios/widget/ENABLED ]` guards — enable/verify them): build native plugins, install BOTH profiles (widget UUID extracted from the decoded profile), export, run patch_xcode_signing.py BEFORE adding the widget, ruby/setup-ruby + gem install xcodeproj, add_widget_target.rb, check_signing.rb, ExportOptions with both bundle ids → profile names, archive, then assert the IPA contains Payload/*.app/PlugIns/ClicketyWidget.appex.
10. export_presets.cfg: plugins/WidgetBridge=true; entitlements/additional = the App Group XML (Appendix C); additional_plist_content adds <key>ClicketyAppGroup</key><string>group.com.<prefix>.rowcounter</string>.
11. scripts/autoload/widget_sync.gd (autoload "WidgetSync", minimal for the spike): available() (Engine.has_singleton("WidgetBridge") and is_available()), push_test(value: int) → writes a snapshot {v:1, unlocked:true, project:"Spike", counter:"Row", value, target:60, repeat_name:"Repeat", repeat_value:1, repeat_of:8, project_id:"spike", counter_id:"row", updated:<unix>} then reload(); take_pending() → Array. Desktop: no-op + prints.
12. scenes/counter.tscn (still the Step 0 placeholder): add a DEBUG-ONLY spike panel (OS.is_debug_build() OR a hidden 5-tap on the title so it also works on the release TestFlight build — label it "Widget spike"): buttons "Write 42", "+1", "Read pending" and a status label showing available() and the last result. Remove this panel in Step 3.

ACCEPTANCE TESTS
- Preflight green. macOS job green. Logs show: "Patched app signing", then the widget target added, then check_signing table with the right profiles, then the IPA contains ClicketyWidget.appex.
- TestFlight upload is accepted (no version-mismatch or entitlement errors in the altool/processing email).
- iPhone (iOS 16+): Home Screen → long-press → + → search "Clickety" → small + medium widgets appear. Lock Screen → Customize → add rectangular/circular. Before any write they say "Open Clickety".
- In the app: 5-tap title → "Write 42" → widgets show 42 within ~5 s. "+1" → 43.
- Stretch (iOS 17+): tap + on the widget → widget shows 44; in the app "Read pending" lists one +1.
- Kill the app → the widgets keep showing the last value.
- Record PASS / stretch PASS / FAIL + the reason in PLAN.md "Widget spike result".

DO NOT
- Touch patch_xcode_signing.py, change GODOT_VERSION, or flip export_project_only.
- Pass PROVISIONING_PROFILE_SPECIFIER on the xcodebuild command line.
- Hardcode the App Group id in Swift/ObjC (read ClicketyAppGroup from Info.plist).
- Build any counter/project UI, saving, or StoreKit yet.
- Spend past evening 2: if still red, stop, write down the last error, and follow the FAIL rule in BUILD_STEPS.md Step 1.

When done: PLAN.md step log line + spike result + my test list.
```

**Commit:** `Step 1: widget spike (<PASS|FAIL>)` · **TestFlight required.**

---
## Step 2 — Data model + counter logic + safe save (no UI)

**Goal:** the part that must never break. All counting rules live in pure, tested GDScript, and every change is saved atomically with a `.bak`. The #1 complaint theme we're answering is lost counts/data (29 complaints in the teardown).

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 2: data model + counter logic + atomic save + tests. Read PROJECT_RULES.md (DATA SAFETY section), PLAN.md, project.godot, scripts/autoload/widget_sync.gd first. Only this step. No UI.

WHAT TO BUILD
1. scripts/core/schema.gd — class_name Schema (static)
   - CURRENT_VERSION := 1. new_file() -> Dictionary, new_project(name, craft) (one main counter "Row", value 0), new_counter(name, role).
   - migrate(d: Dictionary) -> Dictionary (pure; v0/missing version → v1; keeps unknown keys).
   - validate(d) -> Dictionary: coerces bad types to defaults, clamps values, drops nothing it can't understand (moves it under "_unknown").
   File shape (user://data/projects.json):
   {version:1, active_project_id, projects:[{
     id (random hex), name, craft:"knit"|"crochet", created, updated (unix), notes:"", target:0 (0 = none), archived:false,
     timer:{shown:false, running_since:0, total_sec:0},
     counters:[{id, name, value:0, start:0, step:1, reset_at:0 (0 = never wraps), role:"main"|"extra",
                link:{} or {to:<counter id>, on:"step"|"wrap"}, color_idx:0}],
     alerts:[],            (filled in Step 9)
     history:[{t, c:<counter id>, d:<delta>, v:<new value>, k:"tap"|"minus"|"undo"|"reset"|"edit"|"widget"}],   (cap 2000 per project, oldest dropped)
     undo:[ {t, before:{<counter id>: value, ...}} ]   (cap 50)
   }]}
2. scripts/core/counter_logic.gd — class_name CounterLogic (static, pure)
   - increment(project, counter_id, kind:="tap") -> Dictionary result {changed:{id:[before,after]}, wrapped:[ids]}.
     Rules: value += step. Followers (link.on=="step", link.to==counter_id) also step (recursively). A counter with reset_at>0 that goes past reset_at wraps to `start` and records itself in wrapped; each wrapped counter steps its link.on=="wrap" followers. Cycle guard: a counter is changed at most once per action; links forming a loop are rejected by validate_links().
   - decrement(project, counter_id) = exact inverse of increment (a follower at `start` goes to reset_at and un-steps its wrap followers). Never below `start` for non-wrapping counters (then it's a no-op + result.blocked=true).
   - set_value(project, counter_id, v) (edit; no link propagation), reset(project, counter_id) (to start; no propagation).
   - Every mutating call pushes one undo entry with the BEFORE values of every counter it touched and appends history rows. undo(project) restores exactly and logs k:"undo".
   - validate_links(project) -> Array[String] errors (missing target, self-link, loop, wrap-link to a counter with reset_at 0).
   - summary(project) -> Dictionary {main_name, main_value, target, secondary:[{name, value, reset_at}]} (used by UI and widget).
3. scripts/autoload/store.gd — autoload "Store"
   - load_all() at _ready: main → .bak → fresh file. If the main file fails to parse, first copy it to user://data/projects.corrupt-<unix>.json (rescue copy), then try .bak. Never write the .bak from a file that failed to parse.
   - save_now(): atomic write per PROJECT_RULES (tmp → flush → close → copy current to .bak → rename tmp over main; if rename fails: remove main, rename again; log errors, never crash).
   - mark_dirty(): coalesced save via call_deferred (at most once per frame). Also saves on NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_CLOSE_REQUEST.
   - API used by UI: active_project(), set_active(id), projects(), create_project(name, craft) (no gating here), delete_project(id) (writes user://data/deleted/<id>-<unix>.json first), tap(counter_id), minus(counter_id), undo(), edit_value(...), signal changed(project_id), signal wrapped(project_id, counter_ids).
   - After every save: WidgetSync.push(CounterLogic.summary(active)) if WidgetSync is available (the Step 1 autoload; keep push_test working for now).
   - Debug-only: print the save path + timing (target < 5 ms for 20 projects × 2000 history rows on desktop).
4. tests (Oil Due pattern: Control root, %Result label PASS / "FAIL: <msg>", print it; if DisplayServer.get_name() == "headless": get_tree().quit(0 if pass else 1)):
   - tests/test_counter_logic.tscn/.gd: 100 taps → 100; step 2; decrement at start blocked; "repeat every 8": Row (main), Pattern (follows Row on step, start 1, reset_at 8), Repeat (follows Pattern on wrap). Start values Row 0, Pattern 1, Repeat 0 (Pattern = the row of the repeat you're on). Wraps happen on taps 8 and 16, so 16 taps → Row 16, Pattern 1, Repeat 2 and 17 taps → Row 17, Pattern 2, Repeat 2. 17 decrements from there → all back to initial. Undo after a wrap restores all three. validate_links catches self-link and loop. History capped at 2000; undo capped at 50.
   - tests/test_store_io.tscn/.gd (uses a temp dir, not the real user data): save/load round-trip; truncated main + good .bak → loads .bak and writes a corrupt rescue copy; both bad → fresh file, no crash; .bak is never overwritten by bad data; migrate(v0 sample) → v1 with unknown keys preserved.

ACCEPTANCE TESTS
- F6 test_counter_logic → PASS. F6 test_store_io → PASS. Deliberately break one expectation → FAIL with a clear message; revert.
- git push → preflight green including headless tests.
- Print (debug) where user://data lives on Windows (%APPDATA%\Godot\app_userdata\Clickety\data\).

DO NOT
- Build UI, gating, StoreKit, alerts UI, or export.
- Use Nodes/autoloads inside scripts/core/.
- Save anywhere outside user://data/ (except Godot's own settings).

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 2: data model + counter logic + atomic save`

---

## Step 3 — Counter screen (the whole app, for most users)

**Goal:** you open the app and you're counting. The whole screen is the +1 button, the number is huge, −1 and Undo are hard to hit by accident, the screen stays awake, and there's a soft haptic tick. No onboarding.

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 3: counter screen. Read PROJECT_RULES.md, PLAN.md, scripts/core/*, scripts/autoload/store.gd, scripts/autoload/widget_sync.gd, scenes/counter.tscn, scripts/ui/safe_area.gd, scripts/ui/layout.gd first. Only this step.

WHAT TO BUILD
1. assets/theme.tres + scripts/ui/palette.gd (three themes; Step 7 adds the picker, default "Warm"):
   Warm: bg #FBF6EE, surface #FFFFFF, ink #1E1B18, muted #5E564E, accent #B4492E, accent-ink #FFFFFF.
   Night: bg #161412, surface #221F1C, ink #F3ECE2, muted #B8AEA2, accent #E58A6B, accent-ink #161412.
   High contrast: bg #000000, ink #FFFFFF, accent #FFD400, accent-ink #000000.
   Counter chip colors (Okabe-Ito): #E69F00 #56B4E9 #009E73 #CC79A7 #0072B2 #D55E00, each also with a letter/shape badge.
   Font: Atkinson Hyperlegible (SIL OFL) in assets/fonts/ + OFL.txt; add to CREDITS.txt. If you can't download it, tell me and I'll grab it from Google Fonts.
2. scripts/autoload/feedback.gd (autoload "Feedback"): tick() = Input.vibrate_handheld(8) on mobile only (+ amplitude if the 4.6 signature supports it), wrap() = two short pulses, sound hooks as no-ops (Step 7). Settings flags are stubs defaulting to haptics on, sound off.
3. scenes/components/big_tap.tscn: a flat Button (no focus ring, no text, action_mode = ACTION_MODE_BUTTON_PRESS) filling the area between the top bar and the bottom bar. pressed → Store.tap(focused counter) → Feedback.tick() → a ≤80 ms numeral pulse. Must register 10 taps/second with no drops and no double counts.
4. scenes/counter.tscn + scripts/ui/counter.gd (replace the Step 0/1 placeholder and remove the spike panel):
   - Top bar (inside SafeArea): project name (tap → projects list in Step 4; for now no-op), a small "screen awake" sun icon when keep-on is active, a padlock "Tap lock" toggle, a ⋯ menu placeholder.
   - Center: main counter name ("Row") + the numeral (≥ 160 design px, tabular digits, shrinks for 4+ digits) + "of 120" and a thin progress bar when target > 0 + a line for linked counters (Step 5; hidden now).
   - Bottom bar (never under the home indicator; ≥ 16 px gap above it and a visible divider so it's clearly not part of the tap zone): "−1" (left) and "Undo" (right), each ≥ 64x56, with labels + icons. −1 → Store.minus(main). Undo → Store.undo(); disabled when empty.
   - First launch (no file): Store creates "My project" (knit) with "Row" at 0 and this screen opens immediately. A single hint "Tap anywhere to count" fades out after 3 taps and never shows again (flag in the project file root "hints":{"tap":true}).
   - Tap lock: when on, the big tap ignores taps and shows "Locked — hold the padlock to unlock"; hold 0.6 s to unlock (prevents pocket/cat taps).
   - Keep screen awake: DisplayServer.screen_set_keep_on(true) while this screen is visible (Step 7 adds the setting, default on); off when leaving the screen or backgrounded.
5. main scene = scenes/counter.tscn. Resume: on launch open the active project's counter exactly as saved.
6. Layout: centered column (Layout width, max 600) on full-bleed bg; on iPad the numeral scales up (≥ 240 px) and the tap zone is still the whole column + side margins (taps on the side margins also count).

ACCEPTANCE TESTS
- F5: first launch → counter at 0, no dialogs. Click anywhere in the middle → +1. 30 rapid clicks → exactly +30. −1 → −1 (stops at 0). Undo reverts the last action (including −1).
- Stop F5 mid-count (Stop button) → relaunch → same number. Close the window → relaunch → same number.
- Tap lock on → clicks ignored; hold padlock → unlocked.
- Window shapes 428x926, 640x1136, 834x1194: nothing clipped, bottom bar separated, column looks intentional on the iPad shape.
- TestFlight (required): tap feel is instant; haptic tick on each tap; screen doesn't dim after 5+ minutes on the counter; force-quit and reopen → same count; widget (if spike passed) shows the new count after taps.

DO NOT
- Add onboarding, popups, rate prompts, or a paywall.
- Handle raw touch AND mouse events (use the Button pressed signal only).
- Build the projects list, linked counters UI, settings screen, or StoreKit.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 3: counter screen` · **TestFlight required** (feel test).

---

## Step 4 — Projects list + project details (notes, craft, target, history, optional timer)

**Goal:** name your project, write notes (needles, yarn, dye lot), set a target, see your history, and switch projects. Free users get 1 project; a 2nd one opens the Unlock screen (a stub until Step 6).

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 4: projects list + project edit + history view + (optional) timer + unlock gate stub. Read PROJECT_RULES.md, PLAN.md, scripts/core/*, scripts/autoload/*, scenes/counter.tscn, scripts/ui/counter.gd, assets/theme.tres first. Only this step.

WHAT TO BUILD
1. scripts/autoload/purchase.gd — autoload "Purchase" (STUB for now; Step 6 adds StoreKit): is_unlocked() reads user://data/entitlement.json {version:1, unlocked, product_id, since} (atomic save like Store). Debug-only "Pretend unlocked" toggle (OS.is_debug_build()) for F5. NEVER-RE-LOCK: in release builds nothing sets unlocked=false.
2. scenes/components/sheet.tscn: reusable bottom sheet (dim bg, rounded panel, rows ≥ 56 px, font 18+). Hide the on-screen keyboard (DisplayServer.virtual_keyboard_hide()) before any sheet opens (Oil Due lesson). No OS alert dialogs.
3. scenes/projects.tscn + scripts/ui/projects.gd (opened by tapping the project name on the counter screen):
   - List rows: craft icon (knit needles / crochet hook — drawn shapes, plus the word), name, main value (+ "of target"), a progress bar if target, "last worked Tue" text. Tap a row → set active → back to counter.
   - "+ New project": if projects().size() >= 1 and not Purchase.is_unlocked() → open scenes/unlock.tscn (stub: title "Unlock Clickety", the four unlock lines from BUILD_STEPS Step 6 copy, a disabled "Unlock" button, "Restore purchases" button (disabled), Back). Else → project_edit for a new project.
   - Archived projects collapse into an "Archived" section (unarchive from edit).
   - Imported/restored projects are never blocked: if a free user has more than 1 project (from a backup), all of them open and count; only CREATING new ones needs the unlock.
4. scenes/project_edit.tscn + scripts/ui/project_edit.gd:
   - Name (LineEdit, max 40), Craft (Knit / Crochet segmented; crochet default main counter name stays "Row" — editable), Target rows (stepper + field; 0 = none), Notes (multiline TextEdit, 2,000 chars, line breaks allowed — a KnitCounter reviewer asked for this).
   - History section: last 200 events grouped by day ("Tue Sep 29 · Row 12 → 24 (+12)"), plus "Reset main counter…" (confirm sheet) and "Delete project…" (confirm sheet: "This removes the project from the app. A copy is kept in Backups for 30 days." → Store.delete_project, which already writes the deleted/ copy; prune copies older than 30 days on launch).
   - Archive / Unarchive.
   - OPTIONAL (cut if it takes more than ~1 hour; tell me in the plan): Timer row, hidden by default ("Show timer" switch). Start/Pause accumulates total_sec using running_since; pauses automatically on app pause; shows "2 h 14 m" on the counter screen top bar when shown.
5. Counter screen: project name in the top bar opens projects.tscn; ⋯ menu gets "Project details" → project_edit.

ACCEPTANCE TESTS (F5)
- Rename the project, set craft Crochet, target 60, add notes with line breaks → back → counter shows "of 60" + progress. Relaunch → all kept.
- "+ New project" with Pretend off → Unlock stub. Pretend on → create "Sock 2", switch between projects; each keeps its own count and undo.
- History shows today's taps grouped; delete a project → gone from list, file exists in user://data/deleted/.
- Put a 5-project backup file in place (debug "Load sample data" button, debug-only) with Pretend off → all 5 open and count; "+ New project" → Unlock.
- (If built) timer runs, pauses on minimize, survives relaunch.

DO NOT
- Build StoreKit, linked counter UI, alerts, export/import, or settings.
- Lock or hide any existing project from a free user.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 4: projects + details + history`

---

## Step 5 — Linked / repeat counters (paid)

**Goal:** the knitter's real problem, "row 5 of the 8-row repeat, 3rd repeat", done in one tap: the main row goes up, the pattern row cycles 1–8, and the repeat count goes up on each wrap. This is paid; the logic was already built and tested in Step 2.

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 5: linked/repeat counters UI. Read PROJECT_RULES.md, PLAN.md, scripts/core/counter_logic.gd, scripts/core/schema.gd, scripts/autoload/store.gd, scripts/autoload/purchase.gd, scenes/counter.tscn, scripts/ui/counter.gd, scenes/project_edit.tscn first. Only this step.

WHAT TO BUILD
1. scenes/counters_edit.tscn + script (from project_edit → "Counters"):
   - Lists the project's counters (main first). Rows: color+letter badge, name, value, rule text ("follows Row, 1–8" / "counts wraps of Pattern" / "independent").
   - "+ Add counter" (locked → Unlock screen when not Purchase.is_unlocked(); shows a padlock icon) with 3 presets:
     a) "Repeat every N rows" → asks N (2–200) → creates "Pattern row" (follows main on step, start 1, reset_at N) + "Repeats" (follows Pattern row on wrap, start 0). One tap setup.
     b) "Independent counter" → name (e.g. "Stitches", "Decreases"), start 0, step 1.
     c) "Custom" → name, start, step, wraps at, follows (none / a counter, on step / on wrap). Uses CounterLogic.validate_links; errors shown inline.
   - Edit/delete a counter (delete re-points or removes links that referenced it after a confirm sheet). The main counter can't be deleted.
2. Counter screen:
   - Under the numeral: up to 3 secondary chips "Pattern row 3/8 · Repeats 2 · Stitches 14" (larger chips on iPad). If there are more than 3 → "+2 more" opens counters_edit.
   - Tapping a chip FOCUSES it (the big tap now counts that counter; focus shown by a thick outline + "Counting: Stitches" label under the top bar + the numeral switches to it). Tap the main name to refocus the main counter. Focus is saved per project.
   - When any counter wraps: Feedback.wrap() + a 1.5 s banner "Repeat 3 done" (tap to dismiss). No sound unless sound is on (Step 7).
   - −1 and Undo work on the focused counter with exact inverse behavior (Step 2 tests).
3. Free users who already have linked counters (from a restored backup) keep using them; only ADDING is gated.

ACCEPTANCE TESTS (F5, Pretend unlocked)
- Preset "Repeat every 8" → tap 16 times → Row 16, Pattern row 1/8, Repeats 2; one more → Row 17, Pattern row 2/8, Repeats 2 (same as the Step 2 test). −1 ×17 → back to 0/1/0. Undo after a wrap restores all.
- Independent "Stitches": focus it → big tap counts stitches only; Row unchanged.
- Custom counter with a loop → inline error, can't save.
- Pretend off → "+ Add counter" shows the padlock and opens Unlock.
- Relaunch → focus, counters and values restored.
- F6 tests still PASS; preflight green.

DO NOT
- Add alerts/reminders (Step 9), widgets UI, or StoreKit.
- Put counting logic in UI scripts.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 5: linked + repeat counters`

---
## Step 6 — IAP unlock + Restore purchases (StoreKit plugin from Oil Due)

**Goal:** one non-consumable, `com.<prefix>.rowcounter.unlock`, bought once and restored anywhere, and never re-locked. It reuses Oil Due's StoreKit 1 plugin, built in CI. The only change is that the hardcoded product ID becomes a value passed in.

**Before you paste (you):** checklist item 13 is done, so the IAP exists in ASC with status "Ready to Submit" or "Missing Metadata". A sandbox tester exists (ASC → Users and Access → Sandbox → Test Accounts), or you use your own Apple ID in TestFlight, where purchases are free sandbox purchases (**verify**).

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 6: StoreKit unlock + Restore. Read PROJECT_RULES.md, PLAN.md, BUILD_STEPS.md Appendices A, F, H, native/godot-storekit/ (all files), native/build_plugins.sh, export_presets.cfg, .github/workflows/ios-testflight.yml, scripts/autoload/purchase.gd (stub), scenes/unlock.tscn (stub), scripts/ui/app_info.gd first. Only this step. You MAY edit native/godot-storekit/, native/build_plugins.sh, ios/plugins/storekit/, export_presets.cfg, the workflow.

FACTS ABOUT THE OIL DUE PLUGIN (read from OrehRuoy/OilDue today; confirm against the copied files and tell me any difference)
- StoreKit 1 (SKProductsRequest + SKPaymentQueue observer). Engine singleton "StoreKit" registered in GodotPluginEntry.cpp (StoreKitBridge : Object). Methods: initialize(product_id), purchase(product_id), restore(), request_review(), get_price() -> String, is_price_ready() -> bool, has_lifetime() -> bool. Signals: purchase_updated(product_id), purchase_failed(message), entitlements_updated(unlocked), products_loaded(price), products_failed(message).
- storekit_plugin.mm is pure ObjC++ (built WITHOUT Godot headers, mm_needs_godot=0); it calls emit_* C++ functions defined in the entry file. File-scope globals are `static` (a duplicate `_instance` symbol broke an Oil Due link once — keep every global static).
- initialize() and purchase() already take the product id; `static NSString *g_product_id = @"unlock_oil_due";` is only the fallback when an empty id is passed. Messages the plugin emits via purchase_failed: "Purchase cancelled.", "Waiting for approval." (Ask to Buy), "Nothing to restore.", "Couldn't load Unlock Oil Due from the App Store.", connection errors.
- request_review uses requestReviewInScene only on iOS 16+ (no-op on iOS 15 — fine).

WHAT TO BUILD
1. native/godot-storekit/ (the only edits allowed in the copied plugin):
   - g_product_id fallback → @"com.<prefix>.rowcounter.unlock" (my prefix), so a missing argument still hits the right product. GDScript ALWAYS passes AppInfo.IAP_PRODUCT_ID to initialize() and purchase() anyway.
   - Log prefix "[OilDue StoreKit]" → "[Clickety StoreKit]"; rename oil_due_sk_log → clickety_sk_log; "Couldn't load Unlock Oil Due from the App Store." → "Couldn't load Unlock Clickety from the App Store." No other logic changes. Show me the diff.
2. ios/plugins/storekit/StoreKit.gdip exactly as Appendix H (';' comments only). export_presets.cfg: plugins/StoreKit=true. native/build_plugins.sh builds StoreKit when that line is true (the Appendix H flow; nm check for storekit_init). Preflight's plugin consistency check passes.
3. scripts/autoload/purchase.gd — full version modeled on Oil Due's purchase.gd:
   - is_unlocked() -> bool (cached entitlement.json OR has_lifetime()). Signals unlocked_changed(bool), price_ready(String), purchase_error(String).
   - _ready: load the cache; if Engine.has_singleton("StoreKit"): connect signals, initialize(AppInfo.IAP_PRODUCT_ID).
   - buy(): StoreKit.purchase(AppInfo.IAP_PRODUCT_ID). restore(): StoreKit.restore(); on entitlements_updated/purchase_updated with ownership → set unlocked TRUE, save cache {unlocked:true, product_id, since}. NOTHING ever sets it false in release (no refunds/revocations handling in v1 — note it in PLAN.md parking lot).
   - price_text(): StoreKit.get_price() once is_price_ready(); "" until then. Never hardcode a price on iOS.
   - Editor/desktop (no singleton): "Pretend unlocked" debug toggle and a fake 1 s buy/restore so the UI flow is testable; fake price "$—" shown only in debug.
   - Error copy (map the plugin's purchase_failed messages): "Purchase cancelled." → no message; "Waiting for approval." → "Waiting for approval (Ask to Buy). It unlocks by itself once approved."; "Nothing to restore." → "No previous unlock found for this Apple ID."; anything else → "Purchase didn't go through. You weren't charged." + the plugin text in small print.
4. scenes/unlock.tscn + scripts/ui/unlock.gd (real):
   - Title "Unlock Clickety". Four rows with icons: "Unlimited projects", "Linked row + repeat counters", "Lock Screen & Home Screen widget" (ONLY if the PLAN.md widget spike result is PASS — gate on a const in AppInfo: WIDGET_SHIPPED), "Row alerts & reminders".
   - "One-time purchase. No subscription. Yours for good." and "Your free project stays free forever."
   - Primary button "Unlock · <localized price>" (just "Unlock" until the price loads; still tappable). Secondary "Restore purchases". Busy state while StoreKit works (ignore double taps). Success → "Unlocked — thank you!" → back to where the user came from, and the action they tried (new project / add counter) proceeds.
   - A Screenshot flag (AppInfo.SCREENSHOT_MODE, Step 12) hides the price → button reads "Unlock once".
5. "Restore purchases" also appears in Settings (Step 7 builds the screen; for now add it to the ⋯ menu on the counter screen).
6. Remove the "Pretend unlocked" path from release builds (OS.is_debug_build() guard) and grep to prove it.

ACCEPTANCE TESTS
- F5: gates (2nd project, add counter) → Unlock → fake buy → unlocked, action proceeds; relaunch → still unlocked. Pretend off after unlocking in debug → still unlocked (cache wins).
- Preflight green; macOS job green; log shows StoreKit.xcframework built + nm found storekit_init.
- TestFlight #1: Unlock shows the localized price; buy with sandbox → unlocked. Delete app, reinstall from TestFlight → locked → Restore → unlocked. Airplane mode + relaunch → still unlocked.
- TestFlight #2 (next build): repeat buy/restore once more (the Oil Due rule: twice before you trust it). Cancel a purchase → no error message, still locked.

DO NOT
- Use StoreKit 2, receipts validation servers, or any network code of our own.
- Show a paywall on launch or nag. The Unlock screen appears only when the user taps a locked thing or "Unlock" in the menu.
- Hardcode a price, or put the price in any screenshot.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 6: StoreKit unlock + restore` · **TestFlight required** (twice).

After this step: `[B]` ASC → the IAP → Review screenshot = a phone screenshot of the Unlock screen (a price is fine here; it's for App Review only).

---

## Step 7 — Settings (keep-awake, haptics, sound, theme, text size) + About

**Goal:** the small comforts reviewers ask for, all on one plain screen.

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 7: settings + about. Read PROJECT_RULES.md, PLAN.md, scripts/autoload/*.gd, scripts/ui/palette.gd, assets/theme.tres, scenes/counter.tscn first. Only this step.

WHAT TO BUILD
1. scripts/autoload/app_settings.gd — autoload "AppSettings", user://data/settings.json (atomic, versioned, same helper as Store). Keys + defaults: keep_awake:true, haptics:true, sound:false, theme:"warm"|"night"|"contrast"|"system" (default "system": warm/night following DisplayServer.is_dark_mode() where supported), text_size:"default" (small 0.9 / default 1.0 / large 1.2 / huge 1.45), reduce_motion:false, swap_hands:false (−1 and Undo swap sides), hint flags. Signal changed(key).
2. Wire: Feedback respects haptics/sound; counter.gd respects keep_awake (DisplayServer.screen_set_keep_on) and reduce_motion (no pulse); Palette switches theme live; text_size scales theme font sizes + the numeral live.
3. Sound (off by default): a short soft click (self-made or CC0, in assets/sfx/, CREDITS.txt). It must NOT stop the user's podcast/music: set the iOS audio session to Ambient / mix with others. In Godot 4.6 check the exact project settings (expected: audio/general/ios/session_category = Ambient and audio/general/ios/mix_with_others = true — verify the names in the 4.6 docs and tell me).
4. scenes/settings.tscn (⋯ menu → Settings): sections "Counting" (Keep screen awake, Haptics, Tap sound, Swap −1 / Undo), "Look" (Theme: System / Warm / Night / High contrast; Text size; Reduce motion), "Purchase" (Unlock or "Unlocked ✓", Restore purchases), "Your data" (Backup & restore → Step 10, placeholder row), "About".
5. scenes/about.tscn: AppInfo.DISPLAY_NAME, version + build, "No ads. No account. No tracking. Your counts stay on this iPhone.", privacy link (AppInfo.PRIVACY_URL, opened with OS.shell_open only if not empty), support email, credits (font OFL, sounds).
6. Font: Atkinson Hyperlegible everywhere (already in Step 3); numeral uses tabular figures.

ACCEPTANCE TESTS (F5)
- Each toggle changes behavior immediately and survives relaunch. Theme High contrast: black/white/yellow, all text readable. Text size Huge: nothing clipped at 428x926 and 834x1194. Swap hands swaps the buttons.
- Settings → Restore purchases calls Purchase.restore() (fake in editor).
- TestFlight (with the Step 9 build is fine): play a podcast, turn on Tap sound, tap → podcast keeps playing.

DO NOT
- Add accounts, cloud, analytics, rating prompts, or backup logic (Step 10).
- Add more than these settings.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 7: settings + about`

---

## Step 8 — Widget integration (only if the Step 1 spike PASSED)

**Goal:** the real widget, a paid feature. It shows the active project's count, plus the repeat when one exists. On iOS 17+ the widget's + button counts too, and the app merges those taps without losing any.

**If the spike FAILED:** skip this step. Make sure `AppInfo.WIDGET_SHIPPED = false`, and in Steps 12 and 13 use the no-widget listing variants.

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 8: widget integration. Read PROJECT_RULES.md, PLAN.md (spike result + notes), BUILD_STEPS.md Appendix I, ios/widget/**, native/godot-widgetbridge/**, scripts/autoload/widget_sync.gd, scripts/autoload/store.gd, scripts/autoload/purchase.gd, scripts/core/counter_logic.gd first. Only this step.

WHAT TO BUILD
1. WidgetSync (full): push(summary) builds the snapshot {v:1, unlocked:Purchase.is_unlocked(), project, counter, value, target, repeat_name, repeat_value, repeat_of, project_id, counter_id, updated} from CounterLogic.summary(active) and calls write_snapshot + reload. Called by Store after each save. Reloads use the trailing 0.5 s debounce from Appendix I (iOS budgets reloads; the last change always gets a reload).
   Also push on unlock change, project switch and focus change; on NOTIFICATION_APPLICATION_PAUSED call WidgetSync.flush_now() (timers may not fire in the background).
2. Pending merge: on launch and on NOTIFICATION_APPLICATION_RESUMED: take_pending() → array of {project_id, counter_id, d, t}. For each entry whose project/counter still exists → CounterLogic.increment (kind "widget") in time order; unknown ids → dropped + debug log. Then save + push. Test with a fake pending array (tests/test_widget_merge.tscn: 3 pending taps on a linked counter → correct wrap results; duplicate merge impossible because take_pending clears).
3. Widget (Swift):
   - Snapshot decode tolerant (decodeIfPresent everywhere). Timeline policy .never (the app reloads).
   - unlocked == false → every family shows "Unlock in Clickety" (tap opens the app). Paid feature, but no data held hostage — the app itself stays free.
   - Families: accessoryInline "Row 42 · Repeat 3", accessoryCircular (count + ring if target), accessoryRectangular (project name, count, "Pattern 3/8 · Repeat 2"), systemSmall, systemMedium (+1 button on iOS 17+).
   - IncrementIntent (iOS 17+): read-modify-write of "snapshot" and "pending" — minimize the race: re-read both immediately before writing, append not replace, cap pending at 500. After a widget tap the widget shows value+1 immediately; linked wrap math happens in the app on merge (widget shows only the main counter change — say so in PLAN.md).
   - Dark mode + tinted Lock Screen rendering readable; .containerBackground on iOS 17; widgetURL opens the app.
4. Keywords: if this step ships, docs/store-listing.md gets the widget keyword variant from Appendix J (swap `repeat` → `widget`).

ACCEPTANCE TESTS
- F6 test_widget_merge → PASS; all earlier tests PASS; preflight green.
- TestFlight: add Lock Screen rectangular + Home small/medium. Tap in app → widget updates within ~5 s. Switch project → widget follows. Free user (fresh install, no unlock) → widget says "Unlock in Clickety"; after Unlock/Restore → shows the count.
- iOS 17+: tap widget + 5 times with the app killed → widget shows +5 → open app → count +5, repeat counters advanced correctly, undo works per tap.
- Reboot phone → widget still shows the last value.

DO NOT
- Add Live Activities, Control Center controls, or Watch (parking lot).
- Let the widget write the Godot save files directly.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 8: widget integration` · **TestFlight required.**

---

## Step 9 — Row alerts + optional daily reminder (Notification Scheduler iOS v5.2)

**Goal:** "Decrease every 6 rows" and "Buttonhole at row 40" pop up in the app at the right row (paid). There's also an optional daily "time to knit" notification (paid, off by default, asks for permission only when turned on).

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 9: row alerts + daily reminder. Read PROJECT_RULES.md, PLAN.md, BUILD_STEPS.md Appendices A, C, F, scripts/core/*, scripts/autoload/*, scenes/project_edit.tscn, scenes/counter.tscn, export_presets.cfg, the workflow first. Only this step.

WHAT TO BUILD
A. Row alerts (in-app, no permission needed)
1. scripts/core/alerts.gd (pure): alert = {id, kind:"at"|"every", counter_id, row, every, from, text, done:false}. hits(project, result) -> Array of alerts triggered by this action's new values ("at": value == row, sets done; "every": value >= from and (value - from) % every == 0 and value != from). Decrement never triggers. Tests in tests/test_alerts.tscn (every 6 from 0: hits at 6, 12, 18; at 40 once; undo then redo doesn't double-mark done).
2. project_edit → "Row alerts" (paid; padlock → Unlock): add "At row N" / "Every N rows (starting after row M)" + a short text ("Decrease", "Buttonhole", "Change color"). List, edit, delete.
3. Counter screen: on a hit → components/row_alert_banner (big, top, stays until tapped "Got it"), Feedback.wrap(). Multiple hits stack.
B. Daily reminder (local notification)
4. Install Notification Scheduler v5.2 (NOT v6 — v6 is for Godot 4.7): addons/NotificationSchedulerPlugin/ committed (from the v5.2 release); CI downloads https://github.com/godot-mobile-plugins/godot-notification-scheduler/releases/download/v5.2/NotificationSchedulerPlugin-iOS-v5.2.zip into ios/plugins/NotificationSchedulerPlugin/ (Appendix A step, enabled when the preset line exists); export_presets.cfg plugins/NotificationSchedulerPlugin=true. Match the exact folder layout Oil Due used; tell me if the zip layout differs.
5. scripts/autoload/notify_service.gd — autoload "NotifyService", Oil Due pattern: instantiate the node from res://addons/NotificationSchedulerPlugin/NotificationScheduler.gd, add_child, initialize() → wait for initialization_completed. No permission request at launch. enable_daily(hour, minute): if permission unknown → request_post_notifications_permission(); on post_notifications_permission_granted → schedule + set the setting true + refresh the toggle UI (Oil Due Day 44 bug: the toggle stayed OFF after granting — the UI must listen for AppSettings.changed and re-read); on denied → setting false + message "Notifications are off for Clickety in iOS Settings."
6. Scheduling: no repeating notifications (v5.2 repeat unreliable) → schedule one-shot notifications for the next 14 days at the chosen time (ids 9100–9113, cancel all of them first). NotificationData: set_id, set_title (AppInfo.DISPLAY_NAME), set_content ("<project name> is at row <n>. A few rows tonight?"), set_delay(seconds until that day/time). Reschedule on every launch/resume and after the count changes by ≥10 (content stays fresh). Total pending must stay < 64.
7. Settings → "Reminders" section: Daily reminder toggle (paid) + time picker (hour/minute steppers, no OS dialog). Debug-only: "Test notification in 1 minute".
8. If the killed-app test fails on TestFlight: turn the feature off (hide the section), keep row alerts, and remove "reminders" from the Unlock screen, description and screenshots. Write it in PLAN.md.

ACCEPTANCE TESTS
- F6 test_alerts PASS. F5: set "every 6" → banner at 6, 12. "At row 40" → once.
- F5 with no plugin: reminder toggle works as a no-op with a debug print, no crash.
- Preflight green; macOS job shows the v5.2 zip downloaded and unpacked.
- TestFlight: enable → permission prompt appears only now → allow → toggle shows ON (stays ON after relaunch). Debug build path not available on TestFlight release, so: set the reminder 2 minutes ahead → force-quit the app → notification arrives. Deny path → toggle OFF + message.

DO NOT
- Use Notification Scheduler v6.x, repeating notifications, or ask permission at launch.
- Add push notifications / APNs (no server).

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 9: row alerts + daily reminder` · **TestFlight required** (with the app killed).

---

## Step 10 — Backup, export, import (free, a trust feature)

**Goal:** "I got a new phone and lost everything" never happens. The user can write a backup file they can see in the Files app, restore it, and the app keeps 7 automatic daily copies. This is free forever.

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 10: backup/export/import. Read PROJECT_RULES.md, PLAN.md, scripts/core/schema.gd, scripts/autoload/store.gd, scripts/autoload/app_settings.gd, export_presets.cfg, scenes/settings.tscn first. Only this step.

WHAT TO BUILD
1. Files app visibility: export_presets.cfg user_data/accessible_from_files_app=true (Godot 4.6 → LSSupportsOpeningDocumentsInPlace) and check whether user_data/accessible_from_itunes_sharing=true (→ UIFileSharingEnabled) is ALSO needed for "On My iPhone → Clickety" to appear — read the 4.6 iOS export source/docs and tell me; set what's needed. user:// is the app's Documents folder, so everything there is visible: app data stays in user://data/ (already), exports in user://Exports/, auto copies in user://Backups/.
2. Export: Settings → Your data → "Save a backup file" → user://Exports/clickety-backup-YYYY-MM-DD-HHMM.json = {kind:"clickety-backup", version:1, app_version, created, projects:<projects.json content>, settings:<settings.json content>} (never the entitlement — Restore purchases handles that). Then show: "Saved. Find it in Files → On My iPhone → Clickety → Exports." Desktop: also print the absolute path.
3. Auto daily copies: on first launch each day, copy projects.json → user://Backups/auto-YYYY-MM-DD.json; keep the newest 7.
4. Import: "Restore from a backup file" lists every *.json under user://Exports/, user://Backups/ and user:// root (a file the user drops into the Clickety folder in Files lands in the root), newest first, showing date + project count. Desktop (not iOS): also a FileDialog. Pick → Schema.migrate + validate → preview "3 projects, 12 counters, saved Sep 29" → choose "Add these projects" (new ids when ids collide) or "Replace everything" (confirm sheet). Before either: write user://Exports/clickety-before-restore-<ts>.json. Invalid file → "This file isn't a Clickety backup." No crash.
5. Free: no gating anywhere in this step. Restored projects are fully usable by free users (Step 4 rule).
6. tests/test_backup.tscn: export → import(add) doubles projects with new ids; import(replace) round-trips exactly; garbage file rejected; old-version file migrates.

ACCEPTANCE TESTS
- F6 test_backup PASS. F5: save a backup, delete a project, restore (add) → project back.
- TestFlight: Save a backup → Files app → On My iPhone → Clickety → Exports → the file is there (open it in Files quick look = readable JSON). AirDrop/Save it to iCloud Drive, delete the app, reinstall, copy the file into On My iPhone → Clickety → Restore → everything back; Restore purchases → unlocked again.

DO NOT
- Add iCloud, sharing extensions, or a network share sheet plugin (v1 uses Files only).
- Include entitlement.json in backups.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 10: backup + restore` · **TestFlight required** (Files check; can ride with Step 11's build).

---
## Step 11 — Accessibility, iPad, polish, review prompt

**Goal:** readable for tired eyes at 11 pm, calm on iPad, and a single well-timed rating ask.

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 11: accessibility + iPad + polish + review prompt. Read PROJECT_RULES.md, PLAN.md, all scenes/ and scripts/ui/, scripts/autoload/purchase.gd, scripts/ui/palette.gd first. Only this step.

WHAT TO BUILD
1. Contrast audit: tools/contrast_check.gd (headless) computes WCAG contrast for every text/background pair in all three themes; body text ≥ 4.5:1, numeral + large text ≥ 3:1; fix colors that fail (keep the look). Print the table.
2. Text size Huge + iPad + 640x1136: walk every screen; nothing clipped, nothing overlapping, all hit targets ≥ 56 px. Counter chips wrap to a second line instead of shrinking below 16 px.
3. Color never alone: counter chips have letter badges; locked items have a padlock icon + "Unlock" text; the tap-lock state has an icon + label.
4. VoiceOver: Godot 4.6 has partial screen reader support (AccessKit). Test what works; if basic labels read correctly on iOS, set accessibility names on the big tap ("Add one to Row, now 42"), −1, Undo. DO NOT claim VoiceOver support anywhere unless I confirm it on device (note result in PLAN.md).
5. iPad: centered column ≤ 600 px with a full-bleed background; numeral ≥ 240 px; projects list and settings keep the column; the tap zone includes the side margins on the counter screen. Portrait only (UIRequiresFullScreen is set in the preset).
6. Review prompt: Purchase.request_review() (StoreKit's request_review) ONLY after a positive moment — a project reaches its target, or the 3rd repeat wrap in a session — never during the first 3 days after install, at most once per 60 days, max 3 per year (AppSettings keys review_last, review_count, installed_at). Apple also rate-limits; never show our own "rate us" dialog.
7. Polish: tap pulse ≤ 80 ms (off with Reduce motion), wrap banner, empty states ("No notes yet"), consistent copy (DISPLAY_NAME everywhere), app icon in About. Remove leftover debug prints in release (guard them).
8. docs/qa-checklist.md: the device checklist used in Step 13 (every acceptance test from Steps 2–11 as one list).

ACCEPTANCE TESTS
- contrast_check prints all PASS. F5 at 428x926, 640x1136, 834x1194 with Huge text: clean.
- TestFlight on iPhone AND iPad: walk docs/qa-checklist.md; review prompt appears only under the rules (use a debug override in F5 to test the logic).

DO NOT
- Add new features. Add landscape. Add a custom rating dialog.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 11: accessibility + iPad + polish` · **TestFlight required** (iPhone + iPad).

---

## Step 12 — App Store assets + screenshot mode + listing / ASO pack

**Goal:** everything App Store Connect asks for is sitting in the repo, ready to paste: the icon, screenshots in caption order, the listing text, the privacy page and the ASO tools.

**Before you paste (you):**
- The listing values are final (top of this file). Only the two keyword swaps are left to decide: `repeat`→`widget` if the widget shipped, and `multi`→`round` if Step 5 was cut.
- You also know the widget spike result (PASS/FAIL) and the reminder result (Step 9 kept or cut).

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 12: App Store assets, screenshot mode, listing pack, ASO tools. Read PROJECT_RULES.md, PLAN.md (widget + reminders results), BUILD_STEPS.md Appendices G and J, scripts/ui/app_info.gd, assets/icon/, all scenes first. Only this step.

My values:
- TITLE (final): Clickety: Knitting Row Counter
- SUBTITLE (final): Crochet, Knit & Stitch Counter
- KEYWORDS (final base): amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,click,count,helper,assistant,repeat
  Swaps: widget shipped → repeat→widget. Linked/multiple counters cut → multi→round. Apply them and show me the final field + byte count.
- CATEGORY (final): Lifestyle primary, Utilities secondary.
- Widget shipped: <yes/no>. Reminders shipped: <yes/no>. Multiple counters shipped: <yes/no>.
- Support + privacy URL: a free GitHub Pages site (e.g. https://orehruoy.github.io/clickety/ from a public OrehRuoy/clickety-site repo) or my own domain if I bought getclickety.com / clicketycounter.com: <URL>. Support email: <email>.

WHAT TO BUILD
1. App icon: final 1024x1024 OPAQUE PNG, no text, no transparency, no rounded corners (Apple masks it): cream #FBF6EE background, terracotta tally mark + yarn-ball circle (refine the Step 0 generator; keep it self-made). Wire it in export_presets.cfg (icons) — all required sizes generated by Godot from the 1024. Launch screen: plain cream + small mark (storyboard/launch image via the preset; no text).
2. tools/screenshot_mode.tscn + script (debug/editor only): loads a fixed demo data set (Appendix J demo projects: "Holiday socks" knit row 42 of 60 with Pattern row 3/8 and Repeats 5; "Amigurumi bee" crochet round 12; "Blanket squares" 7/20), sets AppInfo.SCREENSHOT_MODE (no price, no debug UI, fixed status-bar-free layout, time-free), and renders each caption frame to PNG at 1290x2796 (6.7"/6.9" slot), 1284x2778 (6.5" slot) and 2064x2752 (13" iPad). Caption band on top: caption text (Atkinson Bold, ink on cream) + the real app UI below, full-bleed, NO device frames (framed previews were rejected for Oil Due). Output screenshots/<size>/<nn>-<slug>.png. Also a --no-captions set (same frames, captions removed) as the fallback if a caption is rejected.
3. Caption order (Appendix J) — skip the widget frame if widget not shipped; skip reminder wording if reminders cut:
   01 hero: "Tap anywhere to count" + small line "No ads · No account · No subscription"
   02 linked: "Row, pattern repeat and repeats — in one tap"
   03 widget (only if shipped): "Count from your Lock Screen"
   04 projects: "Every project keeps its own count and notes"
   05 unlock: "Unlock once. Yours for good." (Unlock screen showing the list + Restore purchases; button reads "Unlock once"; NO price)
   06 trust: "Screen stays awake · Saves every tap · Back up to Files"
4. docs/store-listing.md — every App Store Connect field in paste order, with char/byte counts: Name, Subtitle, Promotional Text (≤170), Description (≤4000), Keywords (≤100 bytes), Support URL, Marketing URL (optional), Privacy Policy URL, Category primary/secondary, Age rating answers, Copyright ("2026 Brock Hall"), App Review notes, What's New 1.0.1 template, IAP display name + description, and the listing-revision variants R-D (crochet-first) and R-T (trust subtitle) from Appendix J. Use Appendix J text; pick the widget/no-widget variants; fill my values.
5. docs/privacy.html — one static page: "Clickety collects no data. No accounts, no analytics, no ads, no tracking. Your projects stay on your device (and in backup files you choose to save). Purchases are handled by Apple." + support email. For App Store Connect → App Privacy: "Data Not Collected".
6. tools/aso_check.py and tools/rank_check.py + tools/rank_terms.txt EXACTLY from Appendix J (stdlib Python; run from my PC; excluded from export). Run aso_check.py with my values and paste the output into PLAN.md.
7. IAP review screenshot: screenshots/iap-review.png = the Unlock screen (price visible is fine here).

ACCEPTANCE TESTS
- screenshots/ has 5 or 6 PNGs per size at the exact pixel sizes (print them with their dimensions), no alpha channel, sRGB.
- docs/store-listing.md: every field present, counts within limits; aso_check.py RESULT: PASS.
- Icon opaque (script asserts no alpha < 255).

DO NOT
- Put prices, "$", "free", "best", "#1" or competitor names in captions or metadata (PROJECT_RULES).
- Use device frames, stock photos or anyone's pattern photos.

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 12: store assets + listing pack`

### Step 12b — Fill App Store Connect (you, ~45 min, in this order)
1. **App Information:**
   - Name = `Clickety: Knitting Row Counter` (already reserved in Step 0).
   - Subtitle = `Crochet, Knit & Stitch Counter`.
   - **Category:** primary **Lifestyle**, secondary **Utilities** (final from the ASO test).
     - Of the 30 apps in the top 10s of the 7 core counter terms, 18 are Lifestyle, 8 Utilities, 3 Productivity and 1 Entertainment.
     - Lifestyle apps hold 24,856 of their 29,308 ratings.
     - Loopsy, StitchTally and Crochet and Knit Counter all use Lifestyle + Utilities.
     - The category puts you in the same aisle and "You might also like" row as the rivals. It doesn't change keyword ranking. Never put "lifestyle" or "utilities" in the keywords.
     - It can change with a later version.
   - Content Rights: no third-party content.
   - Age rating questionnaire: answer "None/No" to everything, which should give **4+** (**verify** under the new age-rating system).
2. **Pricing and Availability:**
   - Price: Free, with the IAP.
   - Availability: all countries (the English-only listing is fine).
3. **App Privacy:**
   - Privacy Policy URL.
   - Data types: **Data Not Collected**.
4. **Version 1.0 page:**
   - Promotional Text, Description, Keywords (the final field after swaps, from `docs/store-listing.md`), Support URL, Copyright.
   - Screenshots: upload in caption order (01 → 06), for iPhone 6.9"/6.7" and iPad 13". Check which slots ASC still requires and whether the 6.5" set is needed (**verify**).
   - **What's New:** there's no field for the first version (**verify**). Keep the 1.0.1 template for the day-7 revision.
5. **In-App Purchases:** the unlock has its review screenshot + description. Under the version page's "In-App Purchases and Subscriptions" section, **add the IAP to this version** (**verify** the section name).
6. **App Review Information:**
   - Notes from `docs/store-listing.md`.
   - No sign-in required.
   - Contact info.

---

## Step 13 — Release build, pre-launch ASO checklist, submission

**Goal:** a 1.0.0 build that passes every check, a listing that passes the ASO checklist, and a submission with "Manually release" on, so **you** pick day 0.

```text
PLAN MODE. Stay in planning until I say OK. After OK, YOU (Grok 4.7 High) implement in this same chat. No handoff.

Clickety — Step 13: release candidate. Read PROJECT_RULES.md, PLAN.md, docs/qa-checklist.md, docs/store-listing.md, export_presets.cfg, the workflow first. Only this step.

WHAT TO BUILD
1. Version: export_presets.cfg application/short_version = "1.0.0" (build number stays GITHUB_RUN_NUMBER from CI). About screen shows it.
2. tools/release_report.sh (bash, runs in preflight too): prints PASS/FAIL for:
   - no network classes in scripts/ scenes/ (HTTPRequest, HTTPClient, WebSocketPeer, StreamPeerTCP, PacketPeerUDP, ENetMultiplayerPeer, MultiplayerAPI, OS.shell_open except the About privacy link)
   - no ad/analytics words (admob, applovin, firebase, analytics, crashlytics, sentry, tracking)
   - no "Pretend unlocked"/debug UI reachable in release (all behind OS.is_debug_build())
   - no hardcoded price strings ("$", "3.99", "2.99") outside tests
   - export_presets: import_etc2_astc on, export_project_only=true, plugins lines match files, entitlements App Group present only if widget shipped
   - AppInfo.WIDGET_SHIPPED matches ios/widget/ENABLED
3. Remove anything left from the spike (5-tap debug panel etc.).
4. Update docs/qa-checklist.md with a "1.0.0 RC" column.

ACCEPTANCE TESTS
- release_report.sh all PASS (paste output into PLAN.md). Preflight + macOS green; TestFlight build "1.0.0 (N)".
- I walk docs/qa-checklist.md on iPhone + iPad — all ticked.

DO NOT
- Add features or change copy (except bugs found by the checklist).

When done: PLAN.md step log line + my test list.
```

**Commit:** `Step 13: 1.0.0 release candidate` · **TestFlight required.**

### Pre-launch ASO checklist (you, before pressing Submit, in order)
1. `python tools/aso_check.py "Clickety: Knitting Row Counter" "Crochet, Knit & Stitch Counter" "<final keywords after swaps>"` → **RESULT: PASS**. (The base field `amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,click,count,helper,assistant,repeat` passed on 2026-09-29 at 97 bytes, and so did both swaps.) It checks:
   - title ≤ 30 characters, subtitle ≤ 30, keywords ≤ 100 bytes with no spaces after commas
   - no word repeated between title, subtitle and keywords
   - every keyword longer than 2 characters
   - no competitor names, prices, "free", "app" or "best"
   - "knitting", "crochet" and "counter" all appear in the title + subtitle (the kill-line terms)
   - no exact-name collision on the App Store today (the same MZ search as `scripts/collide.py`)
2. The title in ASC is exactly `Clickety: Knitting Row Counter` and the subtitle is exactly `Crochet, Knit & Stitch Counter`, with the same characters, colon and comma. The keywords are pasted with no trailing comma.
   - Swap check: `widget` only if the widget shipped; `multi` only if linked/multiple counters shipped.
3. Promotional text ≤ 170 characters. The widget variant is used only if the widget shipped.
4. The description's first paragraph says what's included for everyone and what the one-time unlock adds (2.3.2 IAP disclosure). No prices anywhere. It doesn't say "VoiceOver", "reminders" or "widget" unless those shipped.
5. Screenshots:
   - uploaded in order 01→06 for each required size
   - hero first
   - no prices, no device frames
   - the widget frame only if the widget shipped
6. Category: Lifestyle primary / Utilities secondary.
7. Age rating 4+. App Privacy "Data Not Collected". Privacy URL opens.
8. The IAP is attached to the version, and its status is "Ready to Submit" or "Waiting for Review" together with the app (**verify**).
9. **App Review notes** (from `docs/store-listing.md`, Appendix J): the free project, what the unlock adds, where Restore purchases is (the Unlock screen + Settings), no login, and how to test linked counters (Project → Counters → "Repeat every 8").
10. Version release: **"Manually release this version"**, so launch day is your choice (Tuesday–Thursday morning ET is fine).
11. `rank_check.py` needs the app's **Apple ID** (the digits in ASC → App Information). Write it in `PLAN.md`.
12. Submit. While it's in review, don't change metadata: changes can reset the review (**verify**).

---

## Step 14 — Launch week, outreach, day 7/14 rank checks, one listing revision, kill line

**Goal:** give it one clean shot and then decide by the numbers, not by feel.

### Day 0 (release day)
1. ASC → **Release this version**. Wait until the listing is live on your phone (search the exact title). That can take a few hours.
2. **Baseline:** `python tools/rank_check.py <APPLE_ID> day0`. It appends to `docs/aso-log.md`. New apps often rank oddly on day 0, so this is just the reference point.
3. Promotional text: switch to the launch line (Appendix J). Promo text can change anytime without a new version.
4. Outreach: send "It's live" plus the App Store link to everyone who replied (Appendix K). Log it in `docs/outreach.md`. You send these yourself.
5. Tell 3–5 knitting friends; ask for honest ratings. No incentives (paying or rewarding for ratings is against the App Review rules).

### Days 1–6
- Bug fixes only, as v1.0.1 builds on TestFlight.
- Prepare the **v1.0.1 listing-revision candidates** (R-D and R-T in Appendix J) in `docs/store-listing.md` so day 7 is only a paste. Title, subtitle and keywords change **only with a new version submission** (**verify**). Promo text is anytime.
- Check the ASC dashboard daily (impressions, product page views, downloads, IAP units). Write the day's numbers in `docs/aso-log.md` (one line).

### Day 7 — rank check + the ONE listing revision
1. `python tools/rank_check.py <APPLE_ID> day7`
2. The decision rule. Check the rows in `docs/aso-log.md`, and use the first case that matches:
   - **Both** `knitting counter` and `crochet counter` in the **top 10** → no listing change. Ship v1.0.1 only if there are bugs.
   - **Outside the top 10 for `knitting row counter` but inside it for `crochet row counter`** → **R-D, crochet-first** (the ASO test's fallback). This is a title change, so it ships with v1.0.1:
     - Title `Clickety: Crochet Row Counter` (29)
     - Subtitle `Knitting & Stitch Counter` (25)
     - Keywords `amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,count,helper,assistant,repeat,knit` (96 bytes). `click` is dropped to make room for `knit`. Apply the same swaps: `repeat`→`widget`, `multi`→`round`.
   - **Anything else** (weak on both crafts): look at ASC impressions vs product page views vs downloads.
     - Impressions are there but few people download → **R-T, the trust subtitle**: subtitle `Knit & Crochet · No Ads` (23); keywords as final, but `click` → `stitch` (98 bytes).
     - Impressions are near zero → search isn't surfacing the app at all. R-D is still the one allowed revision, since it has the stronger crochet shelf data.
   - Run `aso_check.py` on the chosen variant first. It must PASS. (All three passed on 2026-09-29.)
3. Submit **v1.0.1** with the revision + What's New (Appendix J). **This is the only listing revision** before the kill check. Don't stack changes, or you can't read the result.
4. Log it in `docs/aso-log.md`: date, variant, reason.

### Day 14 — rank check (kill test #1)
- `python tools/rank_check.py <APPLE_ID> day14`.
  - If v1.0.1 went live later than day 9, also run a check 5 days after it went live, and use the better of the two.
- **KILL** if the app is still **not top 10 for `knitting counter` or `crochet counter`** after the one revision.

### Day 30 — unlock count (kill test #2)
- ASC → Sales and Trends (or App Analytics) → In-App Purchases → units for `com.<prefix>.rowcounter.unlock` since launch.

### KILL LINE (fixed in advance, don't renegotiate)
- **Kill at day 30 if fewer than 10 unlocks**, whatever the ratings.
- **Kill if not top 10 for `knitting counter` / `crochet counter` by day 14** after one listing revision.
- **Keep at 25+ unlocks** (or **15+ ratings**).
- **In between:** push through December, then **decide by Jan 5** on December's unlocks. **Park it if under about 44/month** (≈ $5/day).
- **"Kill"** here means:
  - stop building
  - leave it on sale as-is (unlocks never re-lock, backups keep working)
  - answer support email
  - write the lessons into `PLAN.md`
  - don't delete the app: people have paid.

---
# Appendices

## Appendix A — `.github/workflows/ios-testflight.yml` (Oil Due's working workflow, made widget- and plugin-aware)

**Kept from `OrehRuoy/OilDue/.github/workflows/ios-testflight.yml`** (read today):
- the `ubuntu-latest` preflight
- the `macos-26` job, gated by the `run_macos_export` checkbox, with `timeout-minutes: 90`
- latest Xcode, Godot 4.6.3 + templates from `godot-builds`
- "Build native iOS plugins" and "Install Notification Scheduler iOS v5.2", both before signing
- the cert keychain, `<UUID>.mobileprovision`, build number = `GITHUB_RUN_NUMBER`
- `patch_xcode_signing.py`, archive with `CODE_SIGN_IDENTITY="Apple Distribution"`, `-exportArchive`, `altool` with the app-specific password

**Changed:**
- The bundle ID, team and App Group are read from `export_presets.cfg` (Oil Due hardcoded `com.oildue.app` + the team in ExportOptions).
- Plugin steps run only for plugins that are turned on in the preset.
- The widget steps run only when `ios/widget/ENABLED` exists. They install the second profile, patch app signing **before** adding the widget target, add the target with the `xcodeproj` gem, check signing per target, map both bundle IDs in ExportOptions, and assert the `.appex` is in the IPA.
- There's a fail-fast secrets check inside the macOS job only.
- Headless tests + a no-network grep run in preflight.

```yaml
name: iOS TestFlight

on:
  push:
  pull_request:
  workflow_dispatch:
    inputs:
      run_macos_export:
        description: "Run macOS export + xcodebuild + TestFlight upload"
        required: true
        type: boolean
        default: false

permissions:
  contents: read

jobs:
  preflight:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    env:
      GODOT_VERSION: "4.6.3"
    steps:
      - uses: actions/checkout@v4

      - name: Validate project, preset, plugins (no secrets needed)
        run: |
          set -euo pipefail
          test -f project.godot
          test -f export_presets.cfg
          grep -q 'name="iOS (TestFlight IPA)"' export_presets.cfg
          grep -q 'textures/vram_compression/import_etc2_astc=true' project.godot \
            || { echo "::error::Enable ETC2/ASTC (rendering/textures/vram_compression/import_etc2_astc=true) or iOS export fails"; exit 1; }
          grep -q 'application/min_ios_version="15.0"' export_presets.cfg
          grep -q 'application/export_project_only=true' export_presets.cfg
          grep -q 'ITSAppUsesNonExemptEncryption' export_presets.cfg
          if grep -q '<prefix>' export_presets.cfg scripts/ui/app_info.gd 2>/dev/null; then
            echo "::error::Replace <prefix> in export_presets.cfg / app_info.gd"; exit 1
          fi
          if grep -q 'plugins/exported=' export_presets.cfg; then
            echo "::error::Do not use plugins/exported= - use plugins/<Name>=true lines"; exit 1
          fi
          if find ios/plugins -name '*.gdip' -print0 2>/dev/null | xargs -0 -r grep -nE '^\s*#'; then
            echo "::error::Remove # comments from .gdip files (use ;)"; exit 1
          fi
          on() { grep -q "^plugins/$1=true" export_presets.cfg; }
          need() { test -f "$1" || { echo "::error::Missing $1 (required by the enabled plugin/widget)"; exit 1; }; }
          if on StoreKit; then
            need ios/plugins/storekit/StoreKit.gdip
            need native/godot-storekit/src/storekit_plugin.mm
            need native/godot-storekit/src/GodotPluginEntry.cpp
            need native/build_plugins.sh
          fi
          if on WidgetBridge; then
            need ios/plugins/widgetbridge/WidgetBridge.gdip
            need native/godot-widgetbridge/src/widget_bridge.mm
            need native/godot-widgetbridge/src/GodotPluginEntry.cpp
            need native/build_plugins.sh
          fi
          if on NotificationSchedulerPlugin; then
            need addons/NotificationSchedulerPlugin/plugin.cfg
            need ios/plugins/NotificationSchedulerPlugin/NotificationSchedulerPlugin.gdip
          fi
          # Widget marker, bridge plugin and App Group entitlement must agree
          if [ -f ios/widget/ENABLED ]; then
            on WidgetBridge || { echo "::error::ios/widget/ENABLED exists but plugins/WidgetBridge=true is missing"; exit 1; }
            grep -q 'com.apple.security.application-groups' export_presets.cfg || { echo "::error::Widget enabled but no App Group in entitlements/additional"; exit 1; }
            grep -q 'ClicketyAppGroup' export_presets.cfg || { echo "::error::Widget enabled but ClicketyAppGroup plist key missing"; exit 1; }
            need tools/ios/add_widget_target.rb
            need tools/ios/check_signing.rb
            need ios/widget/app/WidgetReload.swift
          else
            if on WidgetBridge; then echo "::error::plugins/WidgetBridge=true but ios/widget/ENABLED is missing (the bridge needs WidgetReload.swift in the app)"; exit 1; fi
          fi
          # No network / ads / analytics in game code. StoreKit lives in native/ only.
          if grep -rnE 'HTTPRequest|HTTPClient|WebSocketPeer|StreamPeerTCP|PacketPeerUDP|ENetMultiplayerPeer|[Aa]d[Mm]ob|[Ff]irebase|[Cc]rashlytics|[Aa]pp[Ll]ovin|[Ss]entry' \
               --include='*.gd' --include='*.tscn' scripts scenes 2>/dev/null; then
            echo "::error::Network / ads / analytics code is not allowed in Clickety"; exit 1
          fi
          if [ -x tools/release_report.sh ]; then tools/release_report.sh; fi
          echo "Preflight OK"

      - name: Headless logic tests
        run: |
          set -euo pipefail
          if ! ls tests/test_*.tscn >/dev/null 2>&1; then echo "No tests yet"; exit 0; fi
          curl -fsSL "https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" -o "$RUNNER_TEMP/godot.zip"
          unzip -q "$RUNNER_TEMP/godot.zip" -d "$RUNNER_TEMP"
          GODOT="$RUNNER_TEMP/Godot_v${GODOT_VERSION}-stable_linux.x86_64"
          chmod +x "$GODOT"
          "$GODOT" --headless --path . --import || true
          for t in tests/test_*.tscn; do
            echo "== $t"
            timeout 180 "$GODOT" --headless --path . "res://$t"
          done

  build-ios:
    needs: preflight
    if: ${{ github.event_name == 'workflow_dispatch' && inputs.run_macos_export }}
    runs-on: macos-26
    timeout-minutes: 90
    env:
      GODOT_VERSION: "4.6.3"
      PRESET: "iOS (TestFlight IPA)"
    steps:
      - uses: actions/checkout@v4

      - name: Read preset values
        run: |
          set -euo pipefail
          UUID=$(sed -n 's/^application\/provisioning_profile_uuid_release="\([^"]*\)".*/\1/p' export_presets.cfg | tail -1)
          BUNDLE_ID=$(sed -n 's/^application\/bundle_identifier="\([^"]*\)".*/\1/p' export_presets.cfg | head -1)
          TEAM_ID=$(sed -n 's/^application\/app_store_team_id="\([^"]*\)".*/\1/p' export_presets.cfg | head -1)
          APP_GROUP=$(sed -n 's/.*<key>ClicketyAppGroup<\/key><string>\([^<]*\)<\/string>.*/\1/p' export_presets.cfg | head -1)
          WIDGET=0; [ -f ios/widget/ENABLED ] && WIDGET=1
          {
            echo "APP_UUID=$UUID"; echo "BUNDLE_ID=$BUNDLE_ID"; echo "TEAM_ID=$TEAM_ID"
            echo "APP_GROUP=$APP_GROUP"; echo "WIDGET_ENABLED=$WIDGET"
          } >> "$GITHUB_ENV"
          echo "bundle=$BUNDLE_ID team=$TEAM_ID group=${APP_GROUP:-none} widget=$WIDGET uuid=$UUID"

      - name: Check signing inputs (fail fast)
        env:
          APPLE_CERTIFICATE_BASE64: ${{ secrets.APPLE_CERTIFICATE_BASE64 }}
          APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
          APPLE_PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_PROVISIONING_PROFILE_BASE64 }}
          APPLE_WIDGET_PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_WIDGET_PROVISIONING_PROFILE_BASE64 }}
          APPLE_ID_USERNAME: ${{ secrets.APPLE_ID_USERNAME }}
          APPLE_ID_PASSWORD: ${{ secrets.APPLE_ID_PASSWORD }}
        run: |
          missing=0
          NEED="APPLE_CERTIFICATE_BASE64 APPLE_CERTIFICATE_PASSWORD APPLE_PROVISIONING_PROFILE_BASE64 APPLE_ID_USERNAME APPLE_ID_PASSWORD"
          [ "$WIDGET_ENABLED" = "1" ] && NEED="$NEED APPLE_WIDGET_PROVISIONING_PROFILE_BASE64"
          for v in $NEED; do
            if [ -z "${!v:-}" ]; then echo "::error::Missing secret $v"; missing=1; fi
          done
          [ -z "$APP_UUID" ] && { echo "::error::provisioning_profile_uuid_release is empty in export_presets.cfg"; missing=1; }
          [ -z "$BUNDLE_ID" ] && { echo "::error::bundle_identifier is empty"; missing=1; }
          if [ "$WIDGET_ENABLED" = "1" ] && [ -z "$APP_GROUP" ]; then echo "::error::ClicketyAppGroup key missing from additional_plist_content"; missing=1; fi
          exit $missing

      - name: Select latest Xcode
        run: |
          LATEST=$(ls -d /Applications/Xcode_*.app | sort -V | tail -1)
          sudo xcode-select -s "$LATEST"
          xcodebuild -version

      - name: Setup Godot
        run: |
          curl -fsSL "https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_macos.universal.zip" -o "$RUNNER_TEMP/godot.zip"
          unzip -q "$RUNNER_TEMP/godot.zip" -d "$RUNNER_TEMP"
          echo "GODOT_BIN=$RUNNER_TEMP/Godot.app/Contents/MacOS/Godot" >> "$GITHUB_ENV"
          curl -fsSL "https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz" -o "$RUNNER_TEMP/templates.tpz"
          unzip -q "$RUNNER_TEMP/templates.tpz" -d "$RUNNER_TEMP"
          TDIR="$HOME/Library/Application Support/Godot/export_templates/${GODOT_VERSION}.stable"
          mkdir -p "$TDIR"
          cp "$RUNNER_TEMP/templates/ios.zip" "$TDIR/"

      - name: Build native iOS plugins (only the enabled ones)
        run: |
          set -euo pipefail
          if grep -qE '^plugins/(StoreKit|WidgetBridge)=true' export_presets.cfg; then
            chmod +x native/build_plugins.sh
            native/build_plugins.sh
          else
            echo "No native plugins enabled"
          fi
          if grep -q '^plugins/StoreKit=true' export_presets.cfg; then test -d ios/plugins/storekit/StoreKit.release.xcframework; fi
          if grep -q '^plugins/WidgetBridge=true' export_presets.cfg; then test -d ios/plugins/widgetbridge/WidgetBridge.release.xcframework; fi

      - name: Install Notification Scheduler iOS v5.2 (if enabled)
        run: |
          set -euo pipefail
          if ! grep -q '^plugins/NotificationSchedulerPlugin=true' export_presets.cfg; then echo "Not enabled"; exit 0; fi
          curl -fsSL -o "$RUNNER_TEMP/ns-ios.zip" \
            "https://github.com/godot-mobile-plugins/godot-notification-scheduler/releases/download/v5.2/NotificationSchedulerPlugin-iOS-v5.2.zip"
          unzip -q "$RUNNER_TEMP/ns-ios.zip" -d "$RUNNER_TEMP/ns-ios"
          DEST="ios/plugins/NotificationSchedulerPlugin"
          mkdir -p "$DEST"
          find "$RUNNER_TEMP/ns-ios" -type d -name '*.xcframework' | while read -r fw; do
            cp -R "$fw" "$DEST/"
          done
          find "$RUNNER_TEMP/ns-ios" -name '*.gdip' -exec cp {} "$DEST/" \;
          test -f "$DEST/NotificationSchedulerPlugin.gdip"
          test -d "$DEST/NotificationSchedulerPlugin.release.xcframework" \
            || test -d "$DEST/NotificationSchedulerPlugin.xcframework"

      - name: Import signing certificate
        env:
          APPLE_CERTIFICATE_BASE64: ${{ secrets.APPLE_CERTIFICATE_BASE64 }}
          APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
        run: |
          echo "$APPLE_CERTIFICATE_BASE64" | base64 --decode > certificate.p12
          KC_PASS=$(uuidgen)
          security create-keychain -p "$KC_PASS" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "$KC_PASS" build.keychain
          security import certificate.p12 -k build.keychain -P "$APPLE_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k "$KC_PASS" build.keychain
          rm certificate.p12

      - name: Install provisioning profiles
        env:
          APPLE_PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_PROVISIONING_PROFILE_BASE64 }}
          APPLE_WIDGET_PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_WIDGET_PROVISIONING_PROFILE_BASE64 }}
        run: |
          set -euo pipefail
          PDIR="$HOME/Library/MobileDevice/Provisioning Profiles"
          mkdir -p "$PDIR"
          echo "$APPLE_PROVISIONING_PROFILE_BASE64" | base64 --decode > "$PDIR/${APP_UUID}.mobileprovision"
          APP_PROFILE_NAME=$(security cms -D -i "$PDIR/${APP_UUID}.mobileprovision" 2>/dev/null | plutil -extract Name raw -)
          echo "APP_PROFILE_NAME=$APP_PROFILE_NAME" >> "$GITHUB_ENV"
          echo "App profile: $APP_PROFILE_NAME"
          if [ "$WIDGET_ENABLED" = "1" ]; then
            echo "$APPLE_WIDGET_PROVISIONING_PROFILE_BASE64" | base64 --decode > "$RUNNER_TEMP/widget.mobileprovision"
            security cms -D -i "$RUNNER_TEMP/widget.mobileprovision" > "$RUNNER_TEMP/widget.plist" 2>/dev/null
            W_UUID=$(plutil -extract UUID raw -o - "$RUNNER_TEMP/widget.plist")
            W_NAME=$(plutil -extract Name raw -o - "$RUNNER_TEMP/widget.plist")
            mv "$RUNNER_TEMP/widget.mobileprovision" "$PDIR/${W_UUID}.mobileprovision"
            echo "WIDGET_PROFILE_NAME=$W_NAME" >> "$GITHUB_ENV"
            echo "Widget profile: $W_NAME ($W_UUID)"
          fi

      - name: Set build number
        run: sed -i '' "s|application/version=\"[^\"]*\"|application/version=\"${GITHUB_RUN_NUMBER}\"|" export_presets.cfg

      - name: Export iOS Xcode project
        run: |
          set -euo pipefail
          mkdir -p build
          grep 'application/export_project_only=' export_presets.cfg
          "$GODOT_BIN" --headless --path . --import || true
          "$GODOT_BIN" --headless --path . --export-release "$PRESET" "build/Clickety.ipa"
          XCODEPROJ=$(find build -maxdepth 2 -name '*.xcodeproj' | head -1)
          if [[ -z "$XCODEPROJ" ]]; then echo "ERROR: no .xcodeproj under build/"; find build -type d | head -50; exit 1; fi
          test -f "$XCODEPROJ/project.pbxproj"
          echo "XCODEPROJ=$XCODEPROJ" >> "$GITHUB_ENV"
          echo "Xcode project: $XCODEPROJ"

      - name: Patch app signing (BEFORE the widget target exists)
        run: python3 tools/ios/patch_xcode_signing.py build "$APP_PROFILE_NAME"

      - name: Setup Ruby (widget only)
        if: ${{ hashFiles('ios/widget/ENABLED') != '' }}
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"

      - name: Add widget extension target + check signing (widget only)
        if: ${{ hashFiles('ios/widget/ENABLED') != '' }}
        run: |
          set -euo pipefail
          gem install xcodeproj --no-document
          ruby tools/ios/add_widget_target.rb "$XCODEPROJ" "${BUNDLE_ID}.widget" "$WIDGET_PROFILE_NAME" "$TEAM_ID" "$APP_GROUP"
          ruby tools/ios/check_signing.rb "$XCODEPROJ" "$APP_PROFILE_NAME" "$WIDGET_PROFILE_NAME"

      - name: Archive and export IPA
        run: |
          set -euo pipefail
          SCHEME=$(basename "$XCODEPROJ" .xcodeproj)
          ARCHIVE="build/${SCHEME}.xcarchive"
          printf '%s\n' '{}' | plutil -convert xml1 -o build/ExportOptions.plist -
          /usr/libexec/PlistBuddy -c "Add :method string app-store" build/ExportOptions.plist
          /usr/libexec/PlistBuddy -c "Add :teamID string ${TEAM_ID}" build/ExportOptions.plist
          /usr/libexec/PlistBuddy -c "Add :signingStyle string manual" build/ExportOptions.plist
          /usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" build/ExportOptions.plist
          /usr/libexec/PlistBuddy -c "Add :provisioningProfiles:${BUNDLE_ID} string ${APP_PROFILE_NAME}" build/ExportOptions.plist
          if [ "$WIDGET_ENABLED" = "1" ]; then
            /usr/libexec/PlistBuddy -c "Add :provisioningProfiles:${BUNDLE_ID}.widget string ${WIDGET_PROFILE_NAME}" build/ExportOptions.plist
          fi
          /usr/libexec/PlistBuddy -c "Add :uploadSymbols bool true" build/ExportOptions.plist
          /usr/libexec/PlistBuddy -c "Add :compileBitcode bool false" build/ExportOptions.plist
          plutil -lint build/ExportOptions.plist
          # NEVER pass PROVISIONING_PROFILE_SPECIFIER here: it would apply to every target.
          xcodebuild \
            -project "$XCODEPROJ" -scheme "$SCHEME" -sdk iphoneos -configuration Release \
            -destination 'generic/platform=iOS' -archivePath "$ARCHIVE" \
            CODE_SIGN_IDENTITY="Apple Distribution" DEVELOPMENT_TEAM="${TEAM_ID}" \
            STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO STRIP_STYLE=non-global \
            archive
          xcodebuild -exportArchive -archivePath "$ARCHIVE" -exportPath build -exportOptionsPlist build/ExportOptions.plist
          IPA=$(ls build/*.ipa | head -1)
          test -n "$IPA"
          if [ "$WIDGET_ENABLED" = "1" ]; then
            unzip -l "$IPA" | grep -q 'Payload/.*\.app/PlugIns/ClicketyWidget\.appex/' \
              || { echo "::error::ClicketyWidget.appex is missing from the IPA"; unzip -l "$IPA" | head -80; exit 1; }
            echo "IPA contains PlugIns/ClicketyWidget.appex"
          fi
          ls -la build/*.ipa

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: Clickety-ipa
          path: build/*.ipa
          retention-days: 7

      - name: Upload to TestFlight
        env:
          APPLE_ID_USERNAME: ${{ secrets.APPLE_ID_USERNAME }}
          APPLE_ID_PASSWORD: ${{ secrets.APPLE_ID_PASSWORD }}
        run: |
          set -euo pipefail
          IPA=$(ls build/*.ipa | head -1)
          xcrun altool --upload-app -t ios -f "$IPA" -u "$APPLE_ID_USERNAME" -p "$APPLE_ID_PASSWORD" --verbose
```

*Notes:*
- The Linux editor download (`Godot_v4.6.3-stable_linux.x86_64.zip`) uses the same naming as the macOS files Oil Due downloads. It was never run in Oil Due. If it 404s, have Cursor check the asset name on the godot-builds `4.6.3-stable` release.
- The `-exportArchive` step re-signs each target with the profile mapped to its bundle ID in ExportOptions. The two profile names must match the targets' `PROVISIONING_PROFILE_SPECIFIER`, and `check_signing.rb` enforces that.
- Tests run headless with every autoload present. Autoloads that wrap native plugins must no-op when the singleton is missing (PROJECT_RULES).

---

## Appendix B — `tools/ios/patch_xcode_signing.py` (copy byte-for-byte from OilDue; don't let Cursor rewrite it)

This is the text read from `OrehRuoy/OilDue` today, for reference and diffing. **Important with the widget:**
- It rewrites **every** `PROVISIONING_PROFILE_SPECIFIER` in every non-Pods `project.pbxproj` to the app profile.
- That's why the workflow runs it **before** `add_widget_target.rb` creates the widget target.

```python
#!/usr/bin/env python3
"""Patch Godot-exported Xcode projects for App Store CI signing.

- App target: Manual + Apple Distribution (+ App Store profile when present)
- Pods targets: disable code signing (profiles are not supported on pods)
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


def patch_pods(text: str) -> str:
	for key, val in (
		("CODE_SIGNING_ALLOWED", "NO"),
		("CODE_SIGNING_REQUIRED", "NO"),
		("CODE_SIGN_STYLE", "Automatic"),
	):
		text = re.sub(rf"{key} = [^;]+;", f"{key} = {val};", text)
	return text


def patch_app(text: str, profile_name: str) -> str:
	text = text.replace("CODE_SIGN_STYLE = Automatic;", "CODE_SIGN_STYLE = Manual;")
	text = text.replace(
		'CODE_SIGN_IDENTITY = "Apple Development";',
		'CODE_SIGN_IDENTITY = "Apple Distribution";',
	)
	text = text.replace('CODE_SIGN_IDENTITY = "-";', 'CODE_SIGN_IDENTITY = "Apple Distribution";')
	if "PROVISIONING_PROFILE_SPECIFIER" in text:
		text = re.sub(
			r'PROVISIONING_PROFILE_SPECIFIER = "[^"]*";',
			f'PROVISIONING_PROFILE_SPECIFIER = "{profile_name}";',
			text,
		)
	return text


def main() -> int:
	if len(sys.argv) < 3:
		print("usage: patch_xcode_signing.py <build-root> <profile-name>", file=sys.stderr)
		return 1
	root = Path(sys.argv[1])
	profile_name = sys.argv[2]
	changed = 0
	for pbx in root.rglob("project.pbxproj"):
		text = pbx.read_text(encoding="utf-8")
		orig = text
		if "Pods" in pbx.parts:
			text = patch_pods(text)
			label = "Disabled Pod signing"
		else:
			text = patch_app(text, profile_name)
			label = "Patched app signing"
		if text != orig:
			pbx.write_text(text, encoding="utf-8")
			print(f"{label} in {pbx}")
			changed += 1
	print(f"Signing patch complete ({changed} project file(s) updated).")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
```

(The file uses tabs for indentation. The byte-for-byte copy from your repo is what counts.)

---

## Appendix C — `export_presets.cfg` (Clickety, based on Oil Due's working preset)

This is the **final** form, after all steps. The comment-free file is what goes in the repo, because Godot rewrites it. Here's what each step adds:
- **Step 0:** no `plugins/*` lines, `entitlements/additional=""`, `additional_plist_content` without the `ClicketyAppGroup` key, and `user_data/accessible_from_files_app=false`.
- **Step 1:** `plugins/WidgetBridge=true` + the App Group entitlement + `ClicketyAppGroup`.
- **Step 6:** `plugins/StoreKit=true`.
- **Step 9:** `plugins/NotificationSchedulerPlugin=true`.
- **Step 10:** `user_data/accessible_from_files_app=true`.
- **Spike FAIL:** remove WidgetBridge, the entitlement and the key.

```ini
[preset.0]

name="iOS (TestFlight IPA)"
platform="iOS"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=".godot/*,build/*,native/*,ios/widget/*,tools/*,tests/*,docs/*,screenshots/*,*.md,.github/*"
export_path="build/Clickety.ipa"
patches=PackedStringArray()
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.0.options]

custom_template/debug=""
custom_template/release=""
architectures/arm64=true
application/app_store_team_id="9WRNQYQZTB"
application/provisioning_profile_uuid_debug=""
application/provisioning_profile_uuid_release="<APP PROFILE UUID FROM STEP 0>"
application/code_sign_identity_debug=""
application/code_sign_identity_release="Apple Distribution"
application/export_method_debug=1
application/export_method_release=0
application/targeted_device_family=2
application/bundle_identifier="com.<prefix>.rowcounter"
application/signature=""
application/short_version="1.0.0"
application/version="1"
application/min_ios_version="15.0"
application/additional_plist_content="<key>ITSAppUsesNonExemptEncryption</key><false/><key>UIRequiresFullScreen</key><true/><key>ClicketyAppGroup</key><string>group.com.<prefix>.rowcounter</string>"
application/icon_interpolation=4
application/export_project_only=true
application/delete_old_export_files_unconditionally=false
entitlements/additional="<key>com.apple.security.application-groups</key><array><string>group.com.<prefix>.rowcounter</string></array>"
icons/icon_1024x1024="res://assets/icon/icon_1024.png"
icons/app_store_1024x1024="res://assets/icon/icon_1024.png"
icons/iphone_120x120="res://assets/icon/icon_1024.png"
icons/iphone_180x180="res://assets/icon/icon_1024.png"
icons/ipad_152x152="res://assets/icon/icon_1024.png"
icons/ipad_167x167="res://assets/icon/icon_1024.png"
icons/spotlight_120x120="res://assets/icon/icon_1024.png"
storyboard/use_custom_bg_color=true
storyboard/custom_bg_color=Color(0.984, 0.965, 0.933, 1)
storyboard/image_scale_mode=2
plugins/StoreKit=true
plugins/WidgetBridge=true
plugins/NotificationSchedulerPlugin=true
capabilities/access_wifi=false
capabilities/performance_a12=false
capabilities/performance_gaming_tier=false
capabilities/additional=PackedStringArray()
user_data/accessible_from_files_app=true
user_data/accessible_from_itunes_sharing=false
privacy/camera_usage_description=""
privacy/microphone_usage_description=""
privacy/photolibrary_usage_description=""
privacy/file_timestamp_access_reasons=1
privacy/system_boot_time_access_reasons=1
privacy/disk_space_access_reasons=1
privacy/active_keyboard_access_reasons=0
privacy/user_directory_access_reasons=0
privacy/user_defaults_access_reasons=1
privacy/tracking_enabled=false
privacy/tracking_domains=PackedStringArray()
privacy/collected_data=PackedStringArray()
privacy/collected_data_usage=PackedStringArray()
privacy/collected_data_purpose=PackedStringArray()
privacy/collected_data_linked=PackedStringArray()
privacy/collected_data_tracking=PackedStringArray()
privacy/accessed_api_type=PackedStringArray()
privacy/accessed_api_reason=PackedStringArray()
privacy/accessed_api_type_reason=PackedStringArray()
shader_baker/enabled=false
```

Notes:
- `entitlements/additional` is a Godot 4.6 iOS export option ("Additional data added to the root `<dict>` section of the .entitlements file"). Oil Due never used it, so on the Step 1 build, check that the exported `Clickety.entitlements` contains the group.
  - `add_widget_target.rb` also makes sure the group is there (idempotent).
  - The **app** profile must have been generated **after** App Groups was turned on for the App ID. Otherwise the archive fails with "Provisioning profile doesn't include the com.apple.security.application-groups entitlement".
- `user_data/accessible_from_files_app=true` with `accessible_from_itunes_sharing=false` is exactly what Oil Due shipped, and its Files export worked with that pair. Step 10 still verifies that "On My iPhone → Clickety" appears.
- `UIRequiresFullScreen`: this is a portrait-only iPad app. If Xcode/altool only *warn* on the iOS 26 SDK, keep it (**verify** on the first upload).
- `privacy/*_access_reasons` values are copied from Oil Due, whose uploads passed with them. `user_defaults_access_reasons=1` also covers the App Group UserDefaults the bridge uses (**verify** the reason code meaning in the export dialog). The widget extension may need its own `PrivacyInfo.xcprivacy` for UserDefaults.
  - If App Store processing emails "ITMS-91053: Missing API declaration" for the extension, add `ios/widget/ClicketyWidget/PrivacyInfo.xcprivacy` with `NSPrivacyAccessedAPICategoryUserDefaults` reason `1C8F.1` (App Group). Add it to the widget target as a resource.
- `exclude_filter` keeps `native/`, `ios/widget/`, tools, tests, docs and screenshots out of the PCK. `ios/plugins/` must **not** be excluded, because Godot reads the .gdip files from there at export.

---

## Appendix D — `project.godot` key settings + `.gitignore`

```ini
config_version=5

[application]
config/name="Clickety"
config/version="1.0.0"
run/main_scene="res://scenes/counter.tscn"
config/features=PackedStringArray("4.6", "Mobile")
config/icon="res://assets/icon/icon_1024.png"
boot_splash/bg_color=Color(0.984, 0.965, 0.933, 1)

[autoload]
AppSettings="*res://scripts/autoload/app_settings.gd"
Purchase="*res://scripts/autoload/purchase.gd"
WidgetSync="*res://scripts/autoload/widget_sync.gd"
Feedback="*res://scripts/autoload/feedback.gd"
Store="*res://scripts/autoload/store.gd"
NotifyService="*res://scripts/autoload/notify_service.gd"

[display]
window/size/viewport_width=428
window/size/viewport_height=926
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
window/handheld/orientation=1

[rendering]
renderer/rendering_method="mobile"
textures/vram_compression/import_etc2_astc=true
environment/defaults/default_clear_color=Color(0.984, 0.965, 0.933, 1)
```

- 428×926 with canvas_items + expand is the Oil Due Day 38 fix: its 1280×720 start came out tiny on phones. On iPad the extra width goes to `layout.gd`'s centered column.
- If the 926-pixel-tall F5 window doesn't fit your monitor, add `window/size/window_width_override=360` and `window/size/window_height_override=780`.
- Each autoload line is added by the step that creates it, in this order (Godot drops comments from project.godot). The order is Store after Purchase/WidgetSync, so Store's first save can push a widget snapshot. Every autoload must work without its native plugin.
- The Step 7 audio session keys (expected `audio/general/ios/session_category` = Ambient and `audio/general/ios/mix_with_others=true`) go under `[audio]` once they're verified for 4.6.

`.gitignore` (Oil Due's, plus Clickety folders):
```
.godot/
exports/
build/
screenshots/
*.ipa
*.apk
*.aab
*.pck
*.exe
*.xcframework
ios/plugins/**/*.xcframework
.mono/
data_*/
mono_crash.*.json
*.translation
```
- Never ignore `export_presets.cfg`. CI needs it.
- Commit `ios/plugins/NotificationSchedulerPlugin/NotificationSchedulerPlugin.gdip`, as Oil Due's preflight expects. The xcframeworks come from CI.

---
## Appendix E — Prompt templates

**Quick fix (no Plan mode; Grok 4.7 High):**
```text
Quick fix, no plan needed. Clickety. Read PROJECT_RULES.md. Change ONLY what's needed for this:
<paste the exact error line / what I saw>
Don't touch anything else. Tell me the one-line cause and the diff. Don't commit unless I ask.
```

**CI went red (paste the FIRST error, not the last line):**
```text
Quick fix, no plan needed. Clickety CI failed at step "<step name>" (run <number>). The first error: line in the log is:
<paste 5–10 lines around the first "error:">
Check BUILD_STEPS.md Appendix F first. Change only what's needed; don't touch tools/ios/patch_xcode_signing.py or GODOT_VERSION. Tell me the cause and the diff.
```

**Bug found while testing a step (same chat as the step):**
```text
Step N test failed. What I did: <steps>. What I expected: <x>. What happened: <y> (screenshot attached).
Plan the smallest fix first (plan mode), stay inside Step N scope, then implement after my OK.
```

**Commit + push (ask Cursor, or run it yourself):**
```text
Commit everything with message "Step N: <title>" and push to origin main. Don't change any files first.
```

---

## Appendix F — Pipeline gotchas (Oil Due lessons + the new widget ones)

**Carried over from Oil Due**
1. **ETC2/ASTC off → the export fails.** `rendering/textures/vram_compression/import_etc2_astc=true` must stay in `project.godot`. Preflight checks it.
2. **`exit 65` at "Archive and export IPA"** means xcodebuild failed. It isn't automatically a signing problem. Scroll *up* to the first `error:` line.
   - Oil Due run 33687873841 was a duplicate symbol `_instance` between two plugin static libraries.
   - **Every file-scope global in native code must be `static`** (StoreKit, WidgetBridge).
3. **The profile UUID** goes in `application/provisioning_profile_uuid_release`. CI saves the profile as `<UUID>.mobileprovision` and reads the profile **Name** from it. A profile made for the wrong bundle ID fails at archive/export.
4. **Hardcoded bundle ID in ExportOptions.** Oil Due's workflow bakes in `com.oildue.app` + the team. Appendix A reads them from the preset. Don't copy the Oil Due lines.
5. **Preflight must never need secrets or a UUID** (Oil Due Day 29). Only the macOS job checks them.
6. **Keep `export_project_only=true`.** Taptico learned that direct-IPA export plus extra frameworks crashes.
7. **The Godot version must match the templates** (4.6.3 everywhere).
8. **Tests, tools, docs and native sources stay out of the PCK** (`exclude_filter`). Debug UI is gated by `OS.is_debug_build()`, and CI exports release.
9. **Touch + mouse double-fire:** Oil Due's custom switch fired twice. Use `pressed` signals only. The big tap uses `ACTION_MODE_BUTTON_PRESS`.
10. **App previews/screenshots with device frames were rejected** (2.3.4). Use full-bleed real UI only.
11. **The build number** = `GITHUB_RUN_NUMBER` (failed runs use numbers too; that's fine).
12. **altool + app-specific password** is how Oil Due uploads. If Apple retires `altool --upload-app`, switch to the App Store Connect API-key upload (**verify** then).
13. **`.gdip` files:** use `;` comments only. A `#` breaks parsing. Use `plugins/<Name>=true` lines, **never** `plugins/exported=`.
14. **The xcframeworks aren't committed.** CI builds (StoreKit, WidgetBridge) or downloads (Notification Scheduler) them before signing.
15. **Notification Scheduler: use iOS v5.2** for Godot 4.6. v6.x targets Godot 4.7 (Oil Due's plan doc once said otherwise and was wrong).
16. **Notification toggle stays OFF after "Allow"** (Oil Due Day 44). The UI has to re-read the setting when the permission-granted signal arrives.
17. **Never show a hardcoded price on iOS** once StoreKit has loaded (Oil Due Day 43). "Restore purchases" goes on both the Unlock screen and Settings.

**New with the widget**
18. **`patch_xcode_signing.py` rewrites every `PROVISIONING_PROFILE_SPECIFIER`.** Run it before `add_widget_target.rb`, and never pass `PROVISIONING_PROFILE_SPECIFIER` to `xcodebuild` on the command line. `check_signing.rb` catches mistakes.
19. **Extension version mismatch.** The widget's `CFBundleShortVersionString`/`CFBundleVersion` must equal the app's, or App Store processing rejects it. The script copies them from the exported app Info.plist **after** "Set build number".
20. **The profiles must include the App Group.** Turn App Groups on for **both** App IDs **before** generating the profiles. If you enable it later, regenerate both profiles, update both secrets, and update the app UUID in the preset.
    - The typical symptom: "Provisioning profile … doesn't include the com.apple.security.application-groups entitlement".
21. **`@_cdecl` is an underscored Swift attribute.** It works today but isn't officially supported. If it ever breaks, drop the reload call; the widget then refreshes on its own schedule.
22. **WidgetBridge needs `WidgetReload.swift` in the app target.** Otherwise the link fails with `Undefined symbols: _clickety_widget_reload`. That's why preflight requires the bridge and `ios/widget/ENABLED` to be on or off together.
23. **Cross-process UserDefaults race.** The widget intent and the app can both write to "pending"/"snapshot". Keep writes small, re-read right before writing, and have the app only *take* (read + clear) pending on resume.
24. **iOS reload budget.** `WidgetCenter.reloadAllTimelines()` is rate-limited by iOS. Coalesce to at most one reload every ~0.5 s. The widget never needs per-tap live updates while the app is open.
25. **ITMS-91053 (privacy manifest) for the extension.** If processing emails about UserDefaults in `ClicketyWidget.appex`, add a `PrivacyInfo.xcprivacy` with reason `1C8F.1` to the widget target (Appendix C note).
26. **The Swift runtime in the app target.** Adding one Swift file to Godot's ObjC++ app target is normally fine on iOS 15+, where Swift is in the OS. If the linker complains about Swift symbols, set `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO` and `SWIFT_VERSION=5.0` on the app target in `add_widget_target.rb`.

---

## Appendix G — Things to verify in App Store Connect (not assumed)

- **Name:** `Clickety: Knitting Row Counter` is what you try at New App. That's the real check.
  - The name can change until the first release. After that, a name change needs a new version (**verify**).
  - The bundle ID can never change once a build is uploaded.
- **Paid Apps agreement**, tax and banking are active (the IAP needs them).
- **The first IAP must be submitted with a version.** Make sure the version page's in-app purchases section lists the unlock.
- **Family Sharing** on a non-consumable: once it's on, it can't be turned off (**verify** the wording on the IAP page before saving).
- **Category:** Lifestyle primary, Utilities secondary (final). It can change with any version.
- **Metadata that needs a new version:** name, subtitle, keywords, description, screenshots and What's New. Promotional text can change anytime (**verify**; this drives the day-7 plan).
- **What's New:** there's no field for the very first version (**verify**).
- **Screenshot slots:**
  - 6.9" (1290×2796 was accepted for Oil Due; 1320×2868 is native)
  - 6.5" (1284×2778), if still required
  - iPad 13" (2064×2752)
- **`UIRequiresFullScreen`:** still needed for a portrait-only universal app, or only a warning on the iOS 26 SDK.
- **Age rating:** the new questionnaire should come out 4+ with "None" everywhere.
- **"No subscription" in a screenshot caption:** medium-low risk under 2.3.7. Keep the `--no-captions` fallback ready.
  - The description's first paragraph covers IAP disclosure (2.3.2).
  - Restore purchases exists (3.1.1).
- **Widget (2.5.16):** the widget shows the app's own count, so it relates to the app.
- **App Privacy:** "Data Not Collected". StoreKit purchases don't count as the developer collecting data (**verify** in the questionnaire help).

---

## Appendix H — StoreKit adaptation notes + `native/build_plugins.sh`

**What Oil Due's plugin is** (read from `OrehRuoy/OilDue` today; the files are copied in Step 0 and edited only in Step 6):
- `native/godot-storekit/src/storekit_plugin.mm`:
  - StoreKit 1 (`SKProductsRequest`, `SKPaymentQueue` observer, `restoreCompletedTransactions`) with a localized price via `NSNumberFormatter` + `priceLocale`
  - `SKStoreReviewController requestReviewInScene:` on iOS 16+
  - All globals `static`
  - The ObjC class is (still) named `TapticoStoreKit`. Leave the name alone; it's internal.
- `native/godot-storekit/src/GodotPluginEntry.cpp`: `StoreKitBridge : Object`, registered as the Engine singleton **"StoreKit"** from `storekit_init()` (C++ linkage, no `extern "C"`, which is what Godot 4.6's generated `dummy.cpp` expects).
- **Step 6 edits, and only these:**
  - `g_product_id` fallback → `@"com.<prefix>.rowcounter.unlock"`
  - log prefix `[OilDue StoreKit]` → `[Clickety StoreKit]` (plus the `oil_due_sk_log` rename)
  - the "Couldn't load Unlock Oil Due…" message → "Unlock Clickety"
  - GDScript always passes `AppInfo.IAP_PRODUCT_ID` to `initialize()` and `purchase()`.
- **What `purchase_failed` messages the plugin emits** (Purchase autoload maps them): "Purchase cancelled.", "Waiting for approval.", "Nothing to restore.", "Purchases are not allowed on this device.", "This product is not available in your App Store region.", "No connection to the App Store. Check your network and try again."

`ios/plugins/storekit/StoreKit.gdip` (Oil Due's, verbatim):
```ini
[config]
name="StoreKit"
binary="StoreKit.xcframework"
initialization="storekit_init"
deinitialization="storekit_deinit"

[dependencies]
linked=[]
embedded=[]
system=["Foundation.framework", "StoreKit.framework", "UIKit.framework"]
capabilities=[]
files=[]
linker_flags=["-ObjC"]

[plist]
```

`native/build_plugins.sh` (Clickety). This is Oil Due's script with PhotoPicker/DatePicker removed and a WidgetBridge entry added. Both `.mm` files are pure ObjC++ (no Godot headers), like Oil Due's StoreKit. It builds only the enabled plugins, and the header script lives in `native/`:
```bash
#!/usr/bin/env bash
# Clickety: build the enabled native plugins (StoreKit, WidgetBridge) as xcframeworks for Godot 4.6.3 iOS export.
# Adapted from OilDue native/build_plugins.sh (same compile -> libtool -> xcframework flow, same flags).
# Builds ONLY plugins whose line in export_presets.cfg is plugins/<Name>=true.
# Godot 4.6: dummy.cpp calls init/deinit with C++ linkage and does NOT auto-register
# Engine singletons, so each plugin has a GodotPluginEntry.cpp that registers it.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRESET="$ROOT/export_presets.cfg"
BUILD="${RUNNER_TEMP:-$ROOT/build}/clickety-plugins"
IOS_MIN="15.0"
GODOT_SOURCE_VERSION="${GODOT_SOURCE_VERSION:-4.6.3}"
GODOT_SRC_CACHE="${GODOT_SRC_DIR:-${RUNNER_TEMP:-${TMPDIR:-/tmp}}/godot-src}"
GODOT_SRC="$GODOT_SRC_CACHE/godot-${GODOT_SOURCE_VERSION}-stable"

enabled() { grep -q "^plugins/$1=true" "$PRESET"; }

if ! enabled StoreKit && ! enabled WidgetBridge; then
  echo "No native plugins enabled in export_presets.cfg"; exit 0
fi

mkdir -p "$BUILD/device" "$BUILD/sim"

fetch_godot_headers() {
  if [[ ! -f "$GODOT_SRC/core/config/engine.h" ]]; then
    mkdir -p "$GODOT_SRC_CACHE"
    local tarball="$GODOT_SRC_CACHE/godot-${GODOT_SOURCE_VERSION}-stable.tar.xz"
    echo "Fetching Godot ${GODOT_SOURCE_VERSION} source for engine headers..."
    curl -fsSL -o "$tarball" \
      "https://github.com/godotengine/godot/releases/download/${GODOT_SOURCE_VERSION}-stable/godot-${GODOT_SOURCE_VERSION}-stable.tar.xz"
    tar -xf "$tarball" -C "$GODOT_SRC_CACHE"
  fi
  python3 "$ROOT/native/generate_godot_gen_headers.py" "$GODOT_SRC"
}

fetch_godot_headers

SDK_IOS="$(xcrun --sdk iphoneos --show-sdk-path)"
SDK_SIM="$(xcrun --sdk iphonesimulator --show-sdk-path)"
GODOT_INCLUDES=(-I"$GODOT_SRC" -I"$GODOT_SRC/platform/ios")
GODOT_DEFINES=(-DIOS_ENABLED -DAPPLE_EMBEDDED_ENABLED -DUNIX_ENABLED -DCOREAUDIO_ENABLED -DTHREADS_ENABLED -DNDEBUG)
GODOT_CXXFLAGS=(-std=gnu++17 -fno-exceptions -O2)

# Pure ObjC++ source (no Godot headers), like Oil Due's storekit_plugin.mm
compile_mm() {
  local src="$1" obj="$2" sdk="$3" arch="$4" minflag="$5"
  mkdir -p "$(dirname "$obj")"
  clang++ -std=c++17 -ObjC++ -fobjc-arc \
    -isysroot "$(xcrun --sdk "$sdk" --show-sdk-path)" \
    -arch "$arch" "$minflag" \
    -I "$(dirname "$src")" \
    -c "$src" -o "$obj"
}

# C++ entry that registers the Engine singleton (needs Godot headers)
compile_entry() {
  local src="$1" obj="$2" arch="$3" sysroot="$4" minflag="$5"
  mkdir -p "$(dirname "$obj")"
  xcrun clang++ -c "$src" -o "$obj" \
    -arch "$arch" -isysroot "$sysroot" "$minflag" \
    -I "$(dirname "$src")" \
    "${GODOT_CXXFLAGS[@]}" "${GODOT_INCLUDES[@]}" "${GODOT_DEFINES[@]}"
}

pack_plugin() {
  local plugin_name="$1" mm_src="$2" entry_src="$3" out_dir="$4"
  local stem
  stem="$(echo "$plugin_name" | tr '[:upper:]' '[:lower:]')"
  echo "Building $plugin_name ($stem)..."
  mkdir -p "$out_dir"

  compile_mm "$mm_src" "$BUILD/device/${stem}_mm_arm64.o" iphoneos arm64 "-miphoneos-version-min=$IOS_MIN"
  compile_entry "$entry_src" "$BUILD/device/${stem}_entry_arm64.o" arm64 "$SDK_IOS" "-miphoneos-version-min=$IOS_MIN"
  libtool -static -o "$BUILD/device/lib${stem}.a" \
    "$BUILD/device/${stem}_mm_arm64.o" "$BUILD/device/${stem}_entry_arm64.o"

  compile_mm "$mm_src" "$BUILD/sim/${stem}_mm_arm64.o" iphonesimulator arm64 "-mios-simulator-version-min=$IOS_MIN"
  compile_mm "$mm_src" "$BUILD/sim/${stem}_mm_x86_64.o" iphonesimulator x86_64 "-mios-simulator-version-min=$IOS_MIN"
  compile_entry "$entry_src" "$BUILD/sim/${stem}_entry_arm64.o" arm64 "$SDK_SIM" "-mios-simulator-version-min=$IOS_MIN"
  compile_entry "$entry_src" "$BUILD/sim/${stem}_entry_x86_64.o" x86_64 "$SDK_SIM" "-mios-simulator-version-min=$IOS_MIN"
  libtool -static -o "$BUILD/sim/lib${stem}_sim.a" \
    "$BUILD/sim/${stem}_mm_arm64.o" "$BUILD/sim/${stem}_mm_x86_64.o" \
    "$BUILD/sim/${stem}_entry_arm64.o" "$BUILD/sim/${stem}_entry_x86_64.o"

  local syms="$BUILD/device/syms-${stem}.txt"
  { nm -gU "$BUILD/device/lib${stem}.a" 2>/dev/null | c++filt; } > "$syms" || true
  if ! grep -q "${stem}_init()" "$syms"; then
    echo "ERROR: ${stem}_init() C++ symbol not found in lib${stem}.a"; cat "$syms" || true; exit 1
  fi
  echo "Found ${stem}_init() in lib${stem}.a"

  rm -rf "$out_dir/${plugin_name}.xcframework" "$out_dir/${plugin_name}.debug.xcframework" "$out_dir/${plugin_name}.release.xcframework"
  xcodebuild -create-xcframework \
    -library "$BUILD/device/lib${stem}.a" \
    -library "$BUILD/sim/lib${stem}_sim.a" \
    -output "$out_dir/${plugin_name}.xcframework"
  cp -R "$out_dir/${plugin_name}.xcframework" "$out_dir/${plugin_name}.release.xcframework"
  cp -R "$out_dir/${plugin_name}.xcframework" "$out_dir/${plugin_name}.debug.xcframework"
}

if enabled StoreKit; then
  pack_plugin "StoreKit" \
    "$ROOT/native/godot-storekit/src/storekit_plugin.mm" \
    "$ROOT/native/godot-storekit/src/GodotPluginEntry.cpp" \
    "$ROOT/ios/plugins/storekit"
fi

if enabled WidgetBridge; then
  pack_plugin "WidgetBridge" \
    "$ROOT/native/godot-widgetbridge/src/widget_bridge.mm" \
    "$ROOT/native/godot-widgetbridge/src/GodotPluginEntry.cpp" \
    "$ROOT/ios/plugins/widgetbridge"
fi

echo "Plugins built successfully."
```

---
## Appendix I — Widget drafts (Step 1 uses them; Step 8 finishes them)

These are **drafts**. Nobody has compiled them yet: the box has no Xcode, and Brock's machine is Windows. They're written against:
- the `xcodeproj` gem API: `new_target`, `new_copy_files_build_phase`, `symbol_dst_subfolder_spec = :plug_ins`, `add_dependency`, `add_system_framework`
- WidgetKit on iOS 16/17
- Oil Due's plugin-entry pattern

Cursor must fix whatever doesn't compile and report each change.

**Where the files go:**
- `tools/ios/add_widget_target.rb` and `tools/ios/check_signing.rb`
- `ios/widget/ClicketyWidget/`: `ClicketyWidget.swift`, `Snapshot.swift`, `IncrementIntent.swift`, `Info.plist`. `ClicketyWidget.entitlements` is generated by the Ruby script; commit a stub with the same content for reference.
- `ios/widget/app/WidgetReload.swift`
- `native/godot-widgetbridge/src/`: `widget_bridge.h`, `widget_bridge.mm`, `GodotPluginEntry.cpp`
- `ios/plugins/widgetbridge/WidgetBridge.gdip`
- `ios/widget/ENABLED`: an empty marker

**Data contract between Godot and the widget** (App Group `UserDefaults`, suite = the `ClicketyAppGroup` Info.plist value):
- `"snapshot"`: a JSON **string**:
  `{v, unlocked, project, counter, value, target, repeat_name, repeat_value, repeat_of, project_id, counter_id, updated}`
  - Written by the app after every save.
  - Also written by the widget intent when it does a +1.
- `"pending"`: a JSON **string**, an array of `{project_id, counter_id, d, t}`.
  - Appended by the widget intent (iOS 17+).
  - Read and cleared by the app (`take_pending`) on launch/resume, then applied through `CounterLogic.increment`, so linked counters stay correct.

### `tools/ios/add_widget_target.rb`
```ruby
#!/usr/bin/env ruby
# Clickety: add the ClicketyWidget WidgetKit extension to Godot's exported Xcode project (CI only).
# Usage: ruby tools/ios/add_widget_target.rb <build/Clickety.xcodeproj> <widget_bundle_id> <widget_profile_name> <team_id> <app_group>
# Run AFTER tools/ios/patch_xcode_signing.py (which would otherwise overwrite this target's profile).
require 'xcodeproj'
require 'fileutils'

proj_path, widget_id, widget_profile, team_id, app_group = ARGV
if [proj_path, widget_id, widget_profile, team_id, app_group].any? { |a| a.nil? || a.empty? }
  abort 'usage: add_widget_target.rb <xcodeproj> <widget_bundle_id> <widget_profile_name> <team_id> <app_group>'
end

repo    = File.expand_path(File.join(__dir__, '..', '..'))
srcroot = File.dirname(File.expand_path(proj_path))
project = Xcodeproj::Project.open(proj_path)

def fail!(msg)
  warn "ERROR (add_widget_target): #{msg}"
  exit 1
end

app = project.targets.find { |t| t.respond_to?(:product_type) && t.product_type == 'com.apple.product-type.application' }
fail!("no application target in #{proj_path}") unless app
if project.targets.any? { |t| t.name == 'ClicketyWidget' }
  puts 'ClicketyWidget target already present; nothing to do.'
  exit 0
end

release = app.build_configurations.find { |c| c.name == 'Release' } || fail!('app has no Release configuration')
resolve = ->(v) { v.to_s.gsub('$(SRCROOT)/', '').gsub('$(SRCROOT)', '').gsub('"', '') }
info_rel = resolve.call(release.build_settings['INFOPLIST_FILE'])
fail!('app INFOPLIST_FILE is not set') if info_rel.empty?
info_path = File.join(srcroot, info_rel)
fail!("app Info.plist not found at #{info_path}") unless File.exist?(info_path)
app_info  = Xcodeproj::Plist.read_from_path(info_path)
short_ver = app_info['CFBundleShortVersionString'] || fail!('CFBundleShortVersionString missing in app Info.plist')
build_ver = app_info['CFBundleVersion'] || fail!('CFBundleVersion missing in app Info.plist')
app_dir   = File.dirname(info_rel) # e.g. "Clickety"
puts "App target: #{app.name}  version #{short_ver} (#{build_ver})  folder #{app_dir}"

# 1) Copy widget sources into the exported project
wsrc = File.join(repo, 'ios', 'widget', 'ClicketyWidget')
fail!("missing #{wsrc}") unless Dir.exist?(wsrc)
wdst = File.join(srcroot, 'ClicketyWidget')
FileUtils.rm_rf(wdst)
FileUtils.cp_r(wsrc, wdst)
reload_src = File.join(repo, 'ios', 'widget', 'app', 'WidgetReload.swift')
fail!("missing #{reload_src}") unless File.exist?(reload_src)
FileUtils.cp(reload_src, File.join(srcroot, app_dir, 'WidgetReload.swift'))

# 2) Widget Info.plist: versions must equal the app's; group id for the Swift code
wplist_path = File.join(wdst, 'Info.plist')
wplist = Xcodeproj::Plist.read_from_path(wplist_path)
wplist['CFBundleShortVersionString'] = short_ver
wplist['CFBundleVersion'] = build_ver
wplist['ClicketyAppGroup'] = app_group
Xcodeproj::Plist.write_to_path(wplist, wplist_path)

# 3) Widget entitlements (generated, so the group id is never hardcoded in the repo)
went_path = File.join(wdst, 'ClicketyWidget.entitlements')
Xcodeproj::Plist.write_to_path({ 'com.apple.security.application-groups' => [app_group] }, went_path)

# 4) The target
widget = project.new_target(:app_extension, 'ClicketyWidget', :ios, '16.0', nil, :swift)
group = project.main_group.find_subpath('ClicketyWidget', true)
group.set_source_tree('<group>')
group.set_path('ClicketyWidget')
swift_refs = Dir[File.join(wdst, '*.swift')].sort.map { |f| group.new_reference(File.basename(f)) }
fail!('no .swift files in ios/widget/ClicketyWidget') if swift_refs.empty?
widget.add_file_references(swift_refs)
group.new_reference('Info.plist')
group.new_reference('ClicketyWidget.entitlements')
privacy = File.join(wdst, 'PrivacyInfo.xcprivacy')
widget.add_resources([group.new_reference('PrivacyInfo.xcprivacy')]) if File.exist?(privacy)
widget.add_system_framework(%w[WidgetKit SwiftUI])

widget.build_configurations.each do |c|
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER']      = widget_id
  s['PRODUCT_NAME']                   = 'ClicketyWidget'
  s['INFOPLIST_FILE']                 = 'ClicketyWidget/Info.plist'
  s['CODE_SIGN_ENTITLEMENTS']         = 'ClicketyWidget/ClicketyWidget.entitlements'
  s['CODE_SIGN_STYLE']                = 'Manual'
  s['CODE_SIGN_IDENTITY']             = 'Apple Distribution'
  s['DEVELOPMENT_TEAM']               = team_id
  s['PROVISIONING_PROFILE_SPECIFIER'] = widget_profile
  s['SWIFT_VERSION']                  = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET']     = '16.0'
  s['TARGETED_DEVICE_FAMILY']         = '1,2'
  s['SKIP_INSTALL']                   = 'YES'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['GENERATE_INFOPLIST_FILE']        = 'NO'
  s['MARKETING_VERSION']              = short_ver
  s['CURRENT_PROJECT_VERSION']        = build_ver
  s['LD_RUNPATH_SEARCH_PATHS']        = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  s['SDKROOT']                        = 'iphoneos'
end

# 5) Embed the .appex in the app (Copy Files -> PlugIns) + build dependency
embed = app.new_copy_files_build_phase('Embed App Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
bf = embed.add_file_reference(widget.product_reference, true)
bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
app.add_dependency(widget)

# 6) App side: WidgetReload.swift (exports clickety_widget_reload for the WidgetBridge plugin)
app_group_ref = project.main_group.children.find { |g| g.respond_to?(:path) && g.path == app_dir } || project.main_group
reload_ref = app_group_ref.new_reference('WidgetReload.swift')
app.add_file_references([reload_ref])
app.add_system_framework(%w[WidgetKit])
app.build_configurations.each do |c|
  c.build_settings['SWIFT_VERSION'] ||= '5.0'
end

# 7) App entitlements: make sure the App Group is present (the preset adds it too; idempotent)
ent_rel = resolve.call(release.build_settings['CODE_SIGN_ENTITLEMENTS'])
if ent_rel.empty?
  ent_rel = File.join(app_dir, "#{app.name}.entitlements")
  app.build_configurations.each { |c| c.build_settings['CODE_SIGN_ENTITLEMENTS'] = ent_rel }
end
ent_path = File.join(srcroot, ent_rel)
ent = File.exist?(ent_path) ? Xcodeproj::Plist.read_from_path(ent_path) : {}
groups = Array(ent['com.apple.security.application-groups'])
groups << app_group unless groups.include?(app_group)
ent['com.apple.security.application-groups'] = groups
Xcodeproj::Plist.write_to_path(ent, ent_path)

project.save
puts "Added ClicketyWidget (#{widget_id}, profile \"#{widget_profile}\") embedded in #{app.name}; app group #{app_group}"
```

### `tools/ios/check_signing.rb`
```ruby
#!/usr/bin/env ruby
# Clickety: print per-target Release signing and fail if a target has the wrong profile.
# Usage: ruby tools/ios/check_signing.rb <xcodeproj> <app_profile_name> <widget_profile_name>
require 'xcodeproj'
proj_path, app_profile, widget_profile = ARGV
abort 'usage: check_signing.rb <xcodeproj> <app_profile_name> <widget_profile_name>' unless proj_path && app_profile && widget_profile
project = Xcodeproj::Project.open(proj_path)
ok = true
puts format('%-18s %-42s %-8s %-22s %s', 'TARGET', 'BUNDLE ID', 'STYLE', 'IDENTITY', 'PROFILE')
project.targets.each do |t|
  c = t.build_configurations.find { |x| x.name == 'Release' }
  next unless c
  s = c.build_settings
  prof = s['PROVISIONING_PROFILE_SPECIFIER'].to_s
  puts format('%-18s %-42s %-8s %-22s %s', t.name, s['PRODUCT_BUNDLE_IDENTIFIER'], s['CODE_SIGN_STYLE'], s['CODE_SIGN_IDENTITY'], prof)
  if t.respond_to?(:product_type) && t.product_type == 'com.apple.product-type.application'
    (ok = false; warn "ERROR: app target #{t.name} uses \"#{prof}\", expected \"#{app_profile}\"") unless prof == app_profile
  elsif t.name == 'ClicketyWidget'
    (ok = false; warn "ERROR: widget uses \"#{prof}\", expected \"#{widget_profile}\"") unless prof == widget_profile
    (ok = false; warn 'ERROR: widget CODE_SIGN_STYLE must be Manual') unless s['CODE_SIGN_STYLE'] == 'Manual'
  end
end
abort 'Signing check FAILED' unless ok
puts 'Signing check OK'
```

### `ios/widget/ClicketyWidget/Snapshot.swift`
```swift
import Foundation

/// Written by the Godot app (WidgetBridge.write_snapshot) as a JSON string under "snapshot".
/// Decoding is tolerant: any missing key falls back to a default, so app/widget versions can drift.
struct Snapshot: Codable {
    var v: Int = 1
    var unlocked: Bool = false
    var project: String = ""
    var counter: String = "Row"
    var value: Int = 0
    var target: Int = 0
    var repeat_name: String = ""
    var repeat_value: Int = 0
    var repeat_of: Int = 0
    var project_id: String = ""
    var counter_id: String = ""
    var updated: Double = 0

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        v = (try? c.decodeIfPresent(Int.self, forKey: .v)) ?? 1
        unlocked = (try? c.decodeIfPresent(Bool.self, forKey: .unlocked)) ?? false
        project = (try? c.decodeIfPresent(String.self, forKey: .project)) ?? ""
        counter = (try? c.decodeIfPresent(String.self, forKey: .counter)) ?? "Row"
        value = (try? c.decodeIfPresent(Int.self, forKey: .value)) ?? 0
        target = (try? c.decodeIfPresent(Int.self, forKey: .target)) ?? 0
        repeat_name = (try? c.decodeIfPresent(String.self, forKey: .repeat_name)) ?? ""
        repeat_value = (try? c.decodeIfPresent(Int.self, forKey: .repeat_value)) ?? 0
        repeat_of = (try? c.decodeIfPresent(Int.self, forKey: .repeat_of)) ?? 0
        project_id = (try? c.decodeIfPresent(String.self, forKey: .project_id)) ?? ""
        counter_id = (try? c.decodeIfPresent(String.self, forKey: .counter_id)) ?? ""
        updated = (try? c.decodeIfPresent(Double.self, forKey: .updated)) ?? 0
    }
}

/// App Group storage shared with the app. The group id comes from Info.plist (ClicketyAppGroup), never hardcoded.
enum SharedStore {
    static var groupId: String {
        (Bundle.main.object(forInfoDictionaryKey: "ClicketyAppGroup") as? String) ?? ""
    }
    static var defaults: UserDefaults? {
        groupId.isEmpty ? nil : UserDefaults(suiteName: groupId)
    }

    static func load() -> Snapshot? {
        guard let s = defaults?.string(forKey: "snapshot"), let data = s.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }

    static func save(_ snap: Snapshot) {
        guard let data = try? JSONEncoder().encode(snap), let s = String(data: data, encoding: .utf8) else { return }
        defaults?.set(s, forKey: "snapshot")
    }

    /// Appends one +1 for the app to merge on launch/resume. Re-reads right before writing (minimise the race).
    static func appendPending(projectId: String, counterId: String) {
        guard let d = defaults else { return }
        var list: [[String: Any]] = []
        if let s = d.string(forKey: "pending"), let data = s.data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            list = arr
        }
        list.append(["project_id": projectId, "counter_id": counterId, "d": 1, "t": Date().timeIntervalSince1970])
        if list.count > 500 { list.removeFirst(list.count - 500) }
        if let out = try? JSONSerialization.data(withJSONObject: list), let s = String(data: out, encoding: .utf8) {
            d.set(s, forKey: "pending")
        }
    }
}
```

### `ios/widget/ClicketyWidget/IncrementIntent.swift`
```swift
import AppIntents
import WidgetKit

/// iOS 17+ interactive "+1". Runs in the widget process: it updates the shown number and queues the tap;
/// the Godot app applies it (including linked/repeat counters) when it next launches or resumes.
@available(iOS 17.0, *)
struct IncrementIntent: AppIntent {
    static var title: LocalizedStringResource = "Add one row"
    static var description = IntentDescription("Adds one to the current Clickety counter.")

    func perform() async throws -> some IntentResult {
        if var s = SharedStore.load(), s.unlocked {
            s.value += 1
            s.updated = Date().timeIntervalSince1970
            SharedStore.save(s)
            SharedStore.appendPending(projectId: s.project_id, counterId: s.counter_id)
        }
        return .result()  // WidgetKit reloads the widget after an intent runs
    }
}
```

### `ios/widget/ClicketyWidget/ClicketyWidget.swift`
```swift
import SwiftUI
import WidgetKit

struct CountEntry: TimelineEntry {
    let date: Date
    let snap: Snapshot?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountEntry {
        var s = Snapshot()
        s.unlocked = true; s.project = "Holiday socks"; s.value = 42; s.target = 60
        s.repeat_name = "Pattern row"; s.repeat_value = 3; s.repeat_of = 8
        return CountEntry(date: Date(), snap: s)
    }
    func getSnapshot(in context: Context, completion: @escaping (CountEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : CountEntry(date: Date(), snap: SharedStore.load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<CountEntry>) -> Void) {
        // .never: the app calls WidgetCenter.reloadAllTimelines() after it saves.
        completion(Timeline(entries: [CountEntry(date: Date(), snap: SharedStore.load())], policy: .never))
    }
}

private let cream = Color(red: 0.984, green: 0.965, blue: 0.933)
private let ink = Color(red: 0.118, green: 0.106, blue: 0.094)
private let terracotta = Color(red: 0.706, green: 0.286, blue: 0.180)

struct CountView: View {
    @Environment(\.widgetFamily) var family
    let entry: CountEntry

    var body: some View {
        content.widgetBackground(isAccessory: isAccessory)
    }

    private var isAccessory: Bool {
        family == .accessoryInline || family == .accessoryCircular || family == .accessoryRectangular
    }

    @ViewBuilder private var content: some View {
        if let s = entry.snap, s.unlocked {
            counted(s)
        } else {
            let msg = entry.snap == nil ? "Open Clickety" : "Unlock in Clickety"
            switch family {
            case .accessoryInline: Text(msg)
            case .accessoryCircular: Image(systemName: "lock.fill")
            default: Text(msg).font(.headline).multilineTextAlignment(.center)
            }
        }
    }

    private func repeatText(_ s: Snapshot) -> String? {
        guard !s.repeat_name.isEmpty else { return nil }
        return s.repeat_of > 0 ? "\(s.repeat_name) \(s.repeat_value)/\(s.repeat_of)" : "\(s.repeat_name) \(s.repeat_value)"
    }

    @ViewBuilder private func counted(_ s: Snapshot) -> some View {
        switch family {
        case .accessoryInline:
            Text([ "\(s.counter) \(s.value)", repeatText(s) ].compactMap { $0 }.joined(separator: " · "))
        case .accessoryCircular:
            if s.target > 0 {
                Gauge(value: Double(min(s.value, s.target)), in: 0...Double(s.target)) {
                    Text(s.counter)
                } currentValueLabel: {
                    Text("\(s.value)")
                }
                .gaugeStyle(.accessoryCircularCapacity)
            } else {
                ZStack {
                    AccessoryWidgetBackground()
                    Text("\(s.value)").font(.title2.bold()).minimumScaleFactor(0.5)
                }
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text(s.project).font(.headline).lineLimit(1)
                Text(s.target > 0 ? "\(s.counter) \(s.value) / \(s.target)" : "\(s.counter) \(s.value)")
                    .font(.title3.bold()).lineLimit(1).minimumScaleFactor(0.6)
                if let r = repeatText(s) { Text(r).font(.caption).lineLimit(1) }
            }
        default:
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(s.project).font(.caption).foregroundColor(ink.opacity(0.7)).lineLimit(1)
                    Text("\(s.value)").font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(ink).minimumScaleFactor(0.4).lineLimit(1)
                    Text(s.target > 0 ? "\(s.counter) of \(s.target)" : s.counter).font(.caption).foregroundColor(ink)
                    if let r = repeatText(s) { Text(r).font(.caption2).foregroundColor(ink.opacity(0.8)) }
                }
                if family == .systemMedium {
                    Spacer()
                    plusButton
                }
            }
        }
    }

    @ViewBuilder private var plusButton: some View {
        if #available(iOS 17.0, *) {
            Button(intent: IncrementIntent()) {
                Image(systemName: "plus").font(.system(size: 34, weight: .bold))
                    .frame(width: 72, height: 72)
                    .background(Circle().fill(terracotta)).foregroundColor(.white)
            }
            .buttonStyle(.plain)
        }
    }
}

extension View {
    @ViewBuilder func widgetBackground(isAccessory: Bool) -> some View {
        if #available(iOS 17.0, *) {
            if isAccessory { self.containerBackground(for: .widget) { Color.clear } }
            else { self.containerBackground(for: .widget) { cream } }
        } else {
            if isAccessory { self } else { self.padding().background(cream) }
        }
    }
}

struct ClicketyCountWidget: Widget {
    let kind = "ClicketyCount"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CountView(entry: entry)
        }
        .configurationDisplayName("Clickety")
        .description("Your current row count.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

@main
struct ClicketyWidgets: WidgetBundle {
    var body: some Widget {
        ClicketyCountWidget()
    }
}
```

### `ios/widget/ClicketyWidget/Info.plist`
CI overwrites the versions and `ClicketyAppGroup`.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key><string>en</string>
	<key>CFBundleDisplayName</key><string>Clickety</string>
	<key>CFBundleExecutable</key><string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key><string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
	<key>CFBundleName</key><string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key><string>XPC!</string>
	<key>CFBundleShortVersionString</key><string>1.0.0</string>
	<key>CFBundleVersion</key><string>1</string>
	<key>ClicketyAppGroup</key><string>set-by-ci</string>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key><string>com.apple.widgetkit-extension</string>
	</dict>
</dict>
</plist>
```

### `ios/widget/app/WidgetReload.swift` (goes in the APP target)
```swift
import WidgetKit

/// Added to the APP target by tools/ios/add_widget_target.rb. The WidgetBridge plugin (ObjC++) calls this C symbol.
@_cdecl("clickety_widget_reload")
public func clickety_widget_reload() {
    WidgetCenter.shared.reloadAllTimelines()
}
```

### `native/godot-widgetbridge/src/widget_bridge.h`
```cpp
#pragma once
#include <string>

// Pure ObjC++ side (no Godot headers). Called from GodotPluginEntry.cpp.
bool wb_is_available();
bool wb_write_snapshot(const char *json);
void wb_reload();
std::string wb_take_pending();
```

### `native/godot-widgetbridge/src/widget_bridge.mm`
```objc
#import <Foundation/Foundation.h>
#include "widget_bridge.h"

// Defined in WidgetReload.swift (app target, added by add_widget_target.rb).
extern "C" void clickety_widget_reload(void);

static NSUserDefaults *wb_defaults() {
	static NSUserDefaults *s_defaults = nil;
	if (s_defaults != nil) return s_defaults;
	id group = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ClicketyAppGroup"];
	if (![group isKindOfClass:[NSString class]] || [(NSString *)group length] == 0) {
		NSLog(@"[Clickety WidgetBridge] ClicketyAppGroup missing from Info.plist");
		return nil;
	}
	s_defaults = [[NSUserDefaults alloc] initWithSuiteName:(NSString *)group];
	return s_defaults;
}

bool wb_is_available() {
	return wb_defaults() != nil;
}

bool wb_write_snapshot(const char *json) {
	NSUserDefaults *d = wb_defaults();
	if (d == nil || json == nullptr) return false;
	NSString *s = [NSString stringWithUTF8String:json];
	if (s == nil) return false;
	[d setObject:s forKey:@"snapshot"];
	return true;
}

void wb_reload() {
	dispatch_async(dispatch_get_main_queue(), ^{
		clickety_widget_reload();
	});
}

std::string wb_take_pending() {
	NSUserDefaults *d = wb_defaults();
	if (d == nil) return "[]";
	NSString *s = [d stringForKey:@"pending"];
	[d removeObjectForKey:@"pending"];
	if (s == nil || s.length == 0) return "[]";
	return std::string([s UTF8String]);
}
```

### `native/godot-widgetbridge/src/GodotPluginEntry.cpp`
```cpp
// Godot 4.6 plugin glue: C++ linkage (void widgetbridge_init();), same pattern as Oil Due's StoreKit entry.
#include "core/config/engine.h"
#include "core/object/class_db.h"
#include "core/object/object.h"
#include "core/os/memory.h"
#include "core/string/ustring.h"

#include "widget_bridge.h"

class WidgetBridge : public Object {
	GDCLASS(WidgetBridge, Object);

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("is_available"), &WidgetBridge::is_available);
		ClassDB::bind_method(D_METHOD("write_snapshot", "json"), &WidgetBridge::write_snapshot);
		ClassDB::bind_method(D_METHOD("reload"), &WidgetBridge::reload);
		ClassDB::bind_method(D_METHOD("take_pending"), &WidgetBridge::take_pending);
	}

public:
	bool is_available() { return wb_is_available(); }
	bool write_snapshot(const String &json) { return wb_write_snapshot(json.utf8().get_data()); }
	void reload() { wb_reload(); }
	String take_pending() { return String::utf8(wb_take_pending().c_str()); }
};

static WidgetBridge *widgetbridge_singleton = nullptr;

void widgetbridge_init() {
	GDREGISTER_CLASS(WidgetBridge);
	widgetbridge_singleton = memnew(WidgetBridge);
	Engine::get_singleton()->add_singleton(Engine::Singleton("WidgetBridge", widgetbridge_singleton));
}

void widgetbridge_deinit() {
	if (widgetbridge_singleton != nullptr) {
		if (Engine::get_singleton() != nullptr) {
			Engine::get_singleton()->remove_singleton("WidgetBridge");
		}
		memdelete(widgetbridge_singleton);
		widgetbridge_singleton = nullptr;
	}
}
```

### `ios/plugins/widgetbridge/WidgetBridge.gdip`
```ini
[config]
name="WidgetBridge"
binary="WidgetBridge.xcframework"
initialization="widgetbridge_init"
deinitialization="widgetbridge_deinit"

[dependencies]
linked=[]
embedded=[]
system=["Foundation.framework"]
capabilities=[]
files=[]
linker_flags=["-ObjC"]

[plist]
```

### GDScript side (`scripts/autoload/widget_sync.gd`, shape only)
```gdscript
extends Node
## Autoload "WidgetSync". No-ops on desktop/editor (no singleton).
var _bridge: Object = null
var _reload_queued := false

func _ready() -> void:
	if Engine.has_singleton("WidgetBridge"):
		_bridge = Engine.get_singleton("WidgetBridge")

func available() -> bool:
	return _bridge != null and _bridge.is_available()

func push(snapshot: Dictionary) -> void:
	if not available():
		return
	_bridge.write_snapshot(JSON.stringify(snapshot))   # cheap; always write the latest
	_queue_reload()

func _queue_reload() -> void:
	# Trailing debounce: at most one reload per 0.5 s, and the LAST change always gets one (iOS rate-limits reloads).
	if _reload_queued:
		return
	_reload_queued = true
	await get_tree().create_timer(0.5).timeout
	_reload_queued = false
	_bridge.reload()

func flush_now() -> void:
	# Store calls this on NOTIFICATION_APPLICATION_PAUSED (timers may not fire in the background).
	if available():
		_bridge.reload()

func take_pending() -> Array:
	if not available():
		return []
	var parsed = JSON.parse_string(_bridge.take_pending())
	return parsed if parsed is Array else []
```

---
## Appendix J — ASO / listing pack (final values; paste into `docs/store-listing.md` in Step 12)

### J1. Fields (ASC paste order)
| Field | Value | Limit |
|---|---|---|
| Name | `Clickety: Knitting Row Counter` | 30/30 |
| Subtitle | `Crochet, Knit & Stitch Counter` | 30/30 |
| Keywords (base) | `amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,click,count,helper,assistant,repeat` | 97/100 bytes |
| · widget shipped | `amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,click,count,helper,assistant,widget` | 97 |
| · no multiple counters | `…,tap,round,simple,…` (`multi` → `round`) | 97 |
| Primary / secondary category | Lifestyle / Utilities | |
| Support URL | GitHub Pages (e.g. `https://orehruoy.github.io/clickety/`) or `getclickety.com` / `clicketycounter.com` if bought | |
| Privacy Policy URL | the same site + `/privacy.html` | |
| Copyright | `2026 Brock Hall` | |
| Age rating | 4+ (all "None") | |
| App Privacy | Data Not Collected | |

- Never add these to the keywords: `free`, `app`, `lifestyle`, `utilities`, `pattern` (no patterns in v1), `timer` (unless the timer shipped), competitor names, or plurals of words already there.
- The ASO test dropped `hook`, `needle`, `purl`, `sock`, `wool`, `craft` and `round` on purpose. None of them gets a craft or counter autocomplete on Apple.

### J2. Promotional text (≤ 170, can change anytime)
- **Pre-launch / default, widget shipped (159):** `Gift-knitting season? Count every row with one big tap. Linked repeat counters, a Lock Screen widget and backups to Files. No ads, no account, no subscription.`
- **Default, no widget (149):** `Gift-knitting season? Count every row with one big tap. Linked repeat counters, row alerts and backups to Files. No ads, no account, no subscription.` (Drop "row alerts" if Step 9 was cut, and use "and backups to Files".)
- **Launch week (160):** `Just launched: the simplest way to count rows. Tap anywhere on the screen. One full project is included; unlock once for unlimited projects and repeat counters.`

### J3. Description (≤ 4000). The first paragraph is the 2.3.2 IAP disclosure. No prices, and no "free".
Remove the bracketed parts that didn't ship.
```text
Tap anywhere to count. Clickety is a big, calm row counter for knitting and crochet that saves every tap.

WHAT YOU GET
Everyone gets one full project: a whole-screen counter, −1 and Undo, notes, a row history, a screen that stays awake, and backups to the Files app. A one-time in-app purchase unlocks the rest, for good: unlimited projects, linked row and repeat counters[, the Lock Screen and Home Screen widget][ and row alerts and reminders]. No ads. No account. No subscription.

MADE FOR THE MIDDLE OF A ROW
• The whole screen is the button, so you can tap without looking
• Huge numbers you can read from your lap
• −1 and Undo sit apart from the tap area; a stray tap is one tap from fixed
• Tap lock stops pocket and cat taps
• A soft haptic tick on every row; sound stays off unless you want it

REPEATS WITHOUT THE MATH
• Set "repeat every 8 rows" once: your row count keeps going, the pattern row cycles 1 to 8, and the repeat count goes up by itself
• Extra counters for stitches, decreases or anything else
[• Row alerts like "decrease every 6 rows" or "buttonhole at row 40"]
[• See your count on the Lock Screen and Home Screen]

EVERY PROJECT IN ITS PLACE
• Knit or crochet, a target row count, and notes for needles, hook, yarn and dye lot
• A history of what you counted and when

YOUR COUNTS STAY YOURS
• Every tap is saved instantly, with a backup copy
• Save a backup file to Files and restore it on a new phone
• Nothing is collected, nothing is tracked

Large text sizes, three themes including high contrast, for iPhone and iPad.
```

### J4. Screenshot captions, in upload order (no prices, no device frames, full-bleed UI)
| # | Screen | Caption | Small line |
|---|---|---|---|
| 01 | Counter, hero ("Holiday socks", Row 42 of 60) | **Tap anywhere to count** | No ads · No account · No subscription |
| 02 | Counter with linked chips (Pattern row 3/8 · Repeats 5) | **Row, pattern repeat and repeats — in one tap** | |
| 03 | Lock Screen + Home widget (**only if shipped**) | **Count from your Lock Screen** | |
| 04 | Projects list (3 demo projects) | **Every project keeps its own count and notes** | |
| 05 | Unlock screen (button "Unlock once", Restore visible) | **Unlock once. Yours for good.** | |
| 06 | Settings / backup | **Screen stays awake · Saves every tap · Back up to Files** | |

- Keep the `--no-captions` set ready in case "No subscription" gets flagged.
- The widget frame is rendered from the real widget on a device screenshot (Godot can't draw it). Brock takes it on TestFlight; Cursor composites it into the same caption band. If that isn't possible, skip 03.

Demo data for `screenshot_mode`:
- **"Holiday socks"** (knit): Row 42, target 60, Pattern row 3/8, Repeats 5. Notes: "US 1.5 needles · 64 sts · Fingering, dye lot 22B".
- **"Amigurumi bee"** (crochet): Round 12.
- **"Blanket squares"** (crochet): 7 of 20.

### J5. What's New
- **1.0:** no field for the first version (**verify**).
- **1.0.1 template:** `Thank you for the first ratings and emails! This update: • <fix 1> • <fix 2>. Your counts, projects and unlock carry over as always.`
- **With the R-D or R-T revision:** add nothing about the listing. What's New describes app changes only.

### J6. In-app purchase metadata
- Reference name `Clickety Unlock`. Product ID `com.<prefix>.rowcounter.unlock`. Non-consumable. Price tier $3.99 (set in ASC; it never appears in metadata or screenshots).
- Display name (≤ 30): `Unlock Clickety`.
- Description (≤ 55, **verify** the limit): `Unlimited projects, repeat counters and more.` (44)
- Review screenshot: `screenshots/iap-review.png` (the Unlock screen; a visible price is fine here).

### J7. App Review notes
```text
Clickety is a row counter for knitting and crochet. No account or login. The app opens directly to a counter: tap anywhere on the screen to add one.

Included without purchase: one project with full counting, −1/Undo, notes, history, keep-screen-awake, and backup/restore through the Files app.

The non-consumable in-app purchase (com.<prefix>.rowcounter.unlock) unlocks unlimited projects, linked/repeat counters[, the Home/Lock Screen widget][ and row alerts/reminders]. To reach it: tap the project name at the top → "+ New project", or ⋯ → Project details → Counters → "+ Add counter". Restore purchases is on the Unlock screen and in ⋯ → Settings → Purchase.

To test linked counters after unlocking: ⋯ → Project details → Counters → + Add counter → "Repeat every N rows" → 8. Back on the counter, tap 16 times: Row 16, Pattern row 1/8, Repeats 2.
[Widget: long-press the Home Screen → + → Clickety.]
[Reminders: ⋯ → Settings → Reminders. Notification permission is requested only when the user turns it on.]

No data leaves the device. The only network use is Apple's StoreKit for the purchase.
```

### J8. Day-7 listing-revision variants (use ONE, via v1.0.1; all passed `aso_check.py` on 2026-09-29)
| Variant | When | Title | Subtitle | Keywords |
|---|---|---|---|---|
| **R-D, crochet-first** (the ASO test's fallback) | outside top 10 for `knitting row counter`, inside for `crochet row counter` | `Clickety: Crochet Row Counter` (29) | `Knitting & Stitch Counter` (25) | `amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,count,helper,assistant,repeat,knit` (96). Widget: `repeat`→`widget`. |
| **R-T, trust subtitle** | weak on both crafts, impressions OK, downloads poor | unchanged | `Knit & Crochet · No Ads` (23) | `amigurumi,tally,clicker,tap,multi,simple,tracker,project,yarn,count,helper,assistant,repeat,stitch` (98) |

### J9. `tools/aso_check.py` (stdlib only; run from your PC: `python tools/aso_check.py "<title>" "<subtitle>" "<keywords>"`)
It uses the same App Store (MZStore) search as `scripts/collide.py` from the research. It was tested on 2026-09-29: the final values → `RESULT: PASS`, and a bad set ("Free Crochet App", repeated `counter`) → `FAIL`, exit 1.
```python
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
```

### J10. `tools/rank_check.py` + `tools/rank_terms.txt`
Run: `python tools/rank_check.py <APPLE_ID_DIGITS> day7`. It appends a table to `docs/aso-log.md`.
- It was tested on 2026-09-29 against My Row Counter (id 1342608792): #1 for `row counter`, #3 for `knitting counter`, #1 for `crochet counter`.
- It's the same search as `scripts/fetch_shelf.py` from the research. `>N` means not in the returned list.
```python
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
```

`tools/rank_terms.txt`:
```text
row counter
knitting counter
crochet counter
stitch counter
knit counter
knitting row counter
crochet row counter
```

**`docs/aso-log.md` header (Step 12 creates it):**
```markdown
# Clickety ASO log
Apple ID: <digits> · Live since: <date> · Listing: A (Clickety: Knitting Row Counter / Crochet, Knit & Stitch Counter / keywords as in store-listing.md)
Kill terms: knitting counter, crochet counter (top 10 by day 14). Revision trigger: knitting row counter vs crochet row counter.
| Date | Impressions | Page views | Downloads | Unlocks | Ratings | Note |
|---|---|---|---|---|---|---|
```

---

## Appendix K — Outreach (Brock sends these himself from Gmail; nothing is sent automatically)

**Honest expectation:**
- 0–2 pickups from about 10 pitches.
- The UK monthlies land Dec/Jan at best (that lead time is an assumption).
- **Fewer than 2 replies by ship day** means outreach isn't a path, and the day-14 rank check decides the app.

**Out of bounds** (Brock's standing locks):
- Ravelry forums/groups, Reddit (r/knitting, r/crochet), Facebook groups
- competitor-owned "best app" listicles (Knittle, cromu, Yarnzy, Hooked, Loopsy)
- paid Ravelry ads, Apple Search Ads
- Knitty: they don't review from emails, only physical samples
- Knitting Cottage: no contact found

| # | Outlet | Address | Angle | When |
|---|---|---|---|---|
| 1 | Modern Daily Knitting | `hello@moderndailyknitting.com` | Reply to Kate Atherley's "Let's Get Digital" (Aug 3, 2026): "a simple counter for readers who found knitCompanion overwhelming" (a theme in those 45 comments) | Week 0 |
| 2 | Simply Knitting (Our Media) | `simplyknitting@ourmedia.co.uk` | Press release: holiday gift-knitting season | Week 0 |
| 3 | Simply Crochet (Our Media) | `simplycrochet@ourmedia.co.uk` | Same, crochet-first wording | Week 0 |
| 4 | Knitting magazine (GMC) | `knitting@thegmcgroup.com` | Press release | Week 0 |
| 5 | VeryPink Knits (Staci Perry) | `staci@verypink.com` (podcast: `podcast@verypink.com`) | Short personal note, "for your beginner viewers" | Week 0 |
| 6 | Pepper Knits | contact page https://pepperknits.com/p/contact.html (bot-walled; open it by hand) | She reviewed knitCompanion in May 2026 | Only if the address is readable |
| 7 | The Knitter (Our Media) | `theknitter@ourmedia.co.uk` | New products | Build week 2 |
| 8 | Craft Industry Alliance | `hello@craftindustryalliance.org` | Indie maker-tool news | Build week 2 |
| 9 | Sheep and Stitch | `davina[at]sheepandstitch[dot]com` (news tip) | News tip | Build week 2 |
| 10 | Moogly | contact form https://www.mooglyblog.com/contact/ | Crochet audience | Build week 2 |

**Pitch template** (edit per outlet; one email each, no follow-up chains; attach 2 screenshots, no price in them):
```text
Subject: A one-tap row counter for holiday gift knitting (iPhone, no ads, no subscription)

Hi <name>,

<one line that shows you read them — e.g. "Kate's 'Let's Get Digital' column in August got me thinking about readers who found the big pattern apps too much.">

I made Clickety, a very plain row counter for knitters and crocheters on iPhone and iPad. The whole screen is the button, the number is huge, −1 and Undo are out of the way, and the screen stays awake. Set "repeat every 8 rows" once and it tracks the pattern row and repeats for you.

One project is included without paying; a single one-time unlock adds unlimited projects and repeat counters. No ads, no account, no subscription, nothing collected.

It's <coming mid-October / live now: App Store link>. Happy to send a promo code or answer anything.

Thanks for reading,
Brock Hall
<support email> · <site>
```
- Log each send and each reply in `docs/outreach.md` (date, outlet, reply yes/no).
- Promo codes: ASC → the app → Promo Codes (**verify** they're available for the IAP, not just the app).

---

## Parking lot (not v1; don't build)
- **Volume-button counting is OUT.** App Review 2.5.9 (checked 2026-09-29): "Apps that alter or disable the functions of standard switches, such as the Volume Up/Down and Ring/Silent switches… will be rejected."
- Voice "next row" counting.
- Apple Watch app / complication.
- Ravelry API sync (the only route into Ravelry's apps directory).
- PDF pattern viewer with a row highlighter (Pattern Keeper's territory).
- iCloud sync between devices.
- Live Activity / Dynamic Island, and Control Center controls.
- Android.
- A StoreKit 2 migration; refund/revocation handling (v1 never re-locks).
- A project timer, if it was cut in Step 4. Add `timer` to the keywords only when it ships (`crochet timer` autocompletes at #3).
- A CLICKETY trademark filing (class 9), if the app earns its keep. Clickety Sticks' earlier use in the same field is a question for a lawyer.
