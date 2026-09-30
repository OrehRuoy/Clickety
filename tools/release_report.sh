#!/usr/bin/env bash
# Clickety release report. Prints PASS or FAIL for each check. Exit 1 if any fail.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
fail=0

pass() { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }

net_hits="$(grep -RInE 'HTTPRequest|HTTPClient|WebSocketPeer|StreamPeerTCP|PacketPeerUDP|ENetMultiplayerPeer|MultiplayerAPI' \
	--include='*.gd' --include='*.tscn' scripts scenes || true)"
net_hits="$(printf '%s\n' "$net_hits" | grep -v '^scripts/ui/enjoying.gd:' || true)"
if [ -n "$net_hits" ]; then
	printf '%s\n' "$net_hits"
	bad "network classes stay in the feedback form only"
else
	pass "network classes stay in the feedback form only"
fi

shell_bad=0
while IFS= read -r line; do
	[ -z "$line" ] && continue
	case "$line" in
		scripts/ui/about.gd:*PRIVACY_URL*) ;;
		scripts/ui/about.gd:*mailto:*) ;;
		*)
			echo "$line"
			shell_bad=1
			;;
	esac
done < <(grep -RIn 'OS.shell_open' --include='*.gd' --include='*.tscn' scripts scenes || true)
if [ "$shell_bad" -eq 0 ]; then
	pass "OS.shell_open only for the About privacy link and support email"
else
	bad "OS.shell_open only for the About privacy link and support email"
fi

ad_hits="$(grep -RInEi 'admob|applovin|firebase|analytics|crashlytics|sentry|tracking' \
	--include='*.gd' --include='*.tscn' scripts scenes || true)"
if [ -n "$ad_hits" ]; then
	ad_hits="$(printf '%s\n' "$ad_hits" | grep -v 'No ads. No account. No tracking.' || true)"
fi
if [ -n "$ad_hits" ]; then
	echo "$ad_hits"
	bad "no ad or analytics words in scripts/ or scenes/"
else
	pass "no ad or analytics words in scripts/ or scenes/"
fi

if grep -RInE 'Widget spike|Write 42|Read pending' --include='*.gd' --include='*.tscn' scripts scenes >/dev/null; then
	grep -RInE 'Widget spike|Write 42|Read pending' --include='*.gd' --include='*.tscn' scripts scenes || true
	bad "widget spike panel is gone"
else
	pass "widget spike panel is gone"
fi

if grep -q 'Debug.visible = OS.is_debug_build()' scripts/ui/projects.gd \
	&& grep -q 'if OS.is_debug_build() and not AppInfo.SCREENSHOT_MODE:' scripts/ui/settings.gd \
	&& grep -q 'Test notification in 1 minute' scripts/ui/settings.gd \
	&& grep -q 'Ask for a review' scripts/ui/settings.gd; then
	pass "debug rows stay behind OS.is_debug_build()"
else
	bad "debug rows stay behind OS.is_debug_build()"
fi

if grep -RInE '3\.99|2\.99' --include='*.gd' --include='*.tscn' scripts scenes >/dev/null; then
	grep -RInE '3\.99|2\.99' --include='*.gd' --include='*.tscn' scripts scenes || true
	bad "no hardcoded prices in scripts/ or scenes/"
else
	dollar="$(grep -RIn '\$' --include='*.gd' --include='*.tscn' scripts scenes || true)"
	if [ -n "$dollar" ]; then
		dollar="$(printf '%s\n' "$dollar" | grep -v '\$—' || true)"
	fi
	if [ -n "$dollar" ]; then
		echo "$dollar"
		bad "no hardcoded prices in scripts/ or scenes/"
	else
		pass "no hardcoded prices in scripts/ or scenes/ (debug \$— allowed)"
	fi
fi

if grep -q 'textures/vram_compression/import_etc2_astc=true' project.godot \
	&& grep -q 'application/export_project_only=true' export_presets.cfg \
	&& grep -q 'application/short_version="1.0.0"' export_presets.cfg \
	&& grep -q 'config/version="1.0.0"' project.godot; then
	pass "ETC2/ASTC, export_project_only, and version 1.0.0"
else
	bad "ETC2/ASTC, export_project_only, and version 1.0.0"
fi

on() { grep -q "^plugins/$1=true" export_presets.cfg; }
need() { test -f "$1"; }
plugin_ok=0
if on StoreKit; then
	need ios/plugins/storekit/StoreKit.gdip && need native/godot-storekit/src/storekit_plugin.mm || plugin_ok=1
fi
if on WidgetBridge; then
	need ios/plugins/widgetbridge/WidgetBridge.gdip && need native/godot-widgetbridge/src/widget_bridge.mm || plugin_ok=1
fi
if on NotificationSchedulerPlugin; then
	need addons/NotificationSchedulerPlugin/plugin.cfg \
		&& need ios/plugins/NotificationSchedulerPlugin/NotificationSchedulerPlugin.gdip || plugin_ok=1
fi
if [ "$plugin_ok" -eq 0 ]; then
	pass "plugin lines match their files"
else
	bad "plugin lines match their files"
fi

bridge=0
if on WidgetBridge; then bridge=1; fi
if [ -f ios/widget/ENABLED ] && [ "$bridge" -eq 1 ]; then
	if grep -q 'com.apple.security.application-groups' export_presets.cfg \
		&& grep -q 'ClicketyAppGroup' export_presets.cfg; then
		pass "ENABLED matches WidgetBridge and the App Group is present"
	else
		bad "ENABLED matches WidgetBridge and the App Group is present"
	fi
elif [ ! -f ios/widget/ENABLED ] && [ "$bridge" -eq 0 ]; then
	pass "ENABLED matches WidgetBridge (both off)"
else
	bad "ENABLED is present if and only if plugins/WidgetBridge=true"
fi

if grep -q 'const WIDGET_SHIPPED := false' scripts/ui/app_info.gd; then
	pass "WIDGET_SHIPPED is false until the Lock Screen is checked"
else
	bad "WIDGET_SHIPPED is false until the Lock Screen is checked"
fi

if [ "$fail" -eq 0 ]; then
	echo "RESULT: PASS"
	exit 0
fi
echo "RESULT: FAIL"
exit 1
