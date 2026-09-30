CLICKETY PROJECT RULES — read before every step. If a step prompt and these rules disagree, stop and ask.

IDENTITY
- Codename Clickety: folder, repo OrehRuoy/Clickety, project.godot config/name, window title.
- Store title is "Clickety: Knitting Row Counter" (App Store Connect only). Every user-facing app name inside the app reads from scripts/ui/app_info.gd (DISPLAY_NAME = "Clickety"). Never hardcode a store name anywhere else.
- Bundle id com.yourprefix.rowcounter; widget com.yourprefix.rowcounter.widget; App Group group.com.yourprefix.rowcounter; IAP product id com.yourprefix.rowcounter.unlock. All live in scripts/ui/app_info.gd (and CI reads bundle id from export_presets.cfg). They never change after first upload.

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
- NO subscriptions, trials, ads, ad SDKs, accounts/login, analytics/crash SDKs, Firebase, iCloud, backend. NO network code (HTTPRequest, HTTPClient, WebSocketPeer, StreamPeerTCP, PacketPeerUDP, ENet, MultiplayerAPI) except scripts/ui/enjoying.gd, which posts optional feedback to Web3Forms. The other network use is Apple StoreKit inside the native plugin.
- NO onboarding quiz, NO forced tutorial, NO paywall on launch. The app opens straight to a counter you can tap. The one prompt is "Are you enjoying Clickety?": the 3rd open or later, never on the install day, and only once.
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
