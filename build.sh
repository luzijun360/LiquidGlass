#!/bin/bash
# 构建 LiquidGlass.app（窗口 App + 小组件扩展），不需要 Xcode。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DIST="$ROOT/dist"
APP="$DIST/LiquidGlass.app"
WID="$APP/Contents/PlugIns/GlassWidget.appex"
TARGET="arm64-apple-macos26.0"

echo "== 清理 =="
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$WID/Contents/MacOS"

echo "== 编译小组件扩展 =="
swiftc -O -parse-as-library -target "$TARGET" \
  -Xlinker -e -Xlinker _NSExtensionMain \
  -o "$WID/Contents/MacOS/GlassWidget" \
  "$ROOT/widget/GlassWidget.swift" \
  -framework WidgetKit -framework SwiftUI
cp "$ROOT/widget/Info.plist" "$WID/Contents/Info.plist"

echo "== 编译主 App =="
swiftc -O -target "$TARGET" \
  -o "$APP/Contents/MacOS/LiquidGlass" \
  "$ROOT/app/main.swift" \
  -framework AppKit
cp "$ROOT/app/Info.plist" "$APP/Contents/Info.plist"

echo "== 签名（ad-hoc，由内向外）=="
codesign --force --sign - --entitlements "$ROOT/widget/widget.entitlements" "$WID"
codesign --force --sign - "$APP"

echo "== 完成 =="
echo "$APP"
