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
