# LiquidGlass \u2014 Pure Liquid Glass for macOS

> A floating piece of pure liquid glass on your desktop. Drag anywhere, resize from any edge, and choose between clear and regular glass styles. Includes a WidgetKit widget that renders nothing but the system native glass substrate.

![macOS](https://img.shields.io/badge/macOS-26+-black?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange?style=flat-square)
![No Xcode](https://img.shields.io/badge/build-No%20Xcode%20needed-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

[English](#english) | [\u4e2d\u6587](#chinese)

---

<a id="english"></a>
## English

### What is this?

LiquidGlass has two parts:

- **Floating glass window** \u2014 A borderless, draggable, resizable window rendered with `NSGlassEffectView` (macOS 26 / 27 Liquid Glass). Lives in the menu bar (LSUIElement) so it does not clutter the Dock.
- **Desktop widget** \u2014 A WidgetKit extension whose SwiftUI body is `Color.clear`, so only the system default glass plate is visible. Available in all four widget sizes (small / medium / large / extra-large).

Built **without Xcode** \u2014 pure command-line toolchain (`swiftc` + `codesign`, ad-hoc signing).

### Preview

> Add screenshots or GIFs under `docs/screenshots/` and link them here.

```
LiquidGlass/
\u251c\u2500\u2500 app/
\u2502   \u251c\u2500\u2500 main.swift          # AppKit + NSGlassEffectView window app
\u2502   \u2514\u2500\u2500 Info.plist          # LSUIElement menu-bar app
\u251c\u2500\u2500 widget/
\u2502   \u251c\u2500\u2500 GlassWidget.swift   # WidgetKit extension (empty = pure system glass)
\u2502   \u251c\u2500\u2500 Info.plist          # XPC! + com.apple.widgetkit-extension
\u2502   \u2514\u2500\u2500 widget.entitlements # app-sandbox
\u251c\u2500\u2500 tools/
\u2502   \u2514\u2500\u2500 material-lab.swift  # Side-by-side comparison of 10 glass/blur materials
\u2514\u2500\u2500 build.sh                # One-shot build (compile + bundle + ad-hoc sign)
```

### Requirements

- macOS 26+ (Liquid Glass APIs: `NSGlassEffectView`, `glassEffect()`)
- Xcode Command Line Tools (`xcode-select --install`) \u2014 no full Xcode needed
- Apple Silicon recommended (build target `arm64-apple-macos26.0`)

### Quick Start

```bash
git clone https://github.com/<you>/LiquidGlass.git
cd LiquidGlass
bash build.sh

# Install to /Applications
pkill -x LiquidGlass 2>/dev/null; true
ditto dist/LiquidGlass.app /Applications/LiquidGlass.app
open /Applications/LiquidGlass.app
```

Alternative via `make`:

```bash
make          # build
make install  # build + install to /Applications
make lab      # run the material comparison lab
make clean
```

### Usage

- A glass tile appears at the center of the screen \u2014 **drag anywhere** to move, drag edges to resize.
- Menu bar droplet icon:
  - **Size** \u2014 Small 170x170 / Medium 364x170 / Large 364x382 / Extra Large 736x382
  - **New glass** \u2014 open another tile
  - **Desktop layer** \u2014 sink glass between wallpaper and desktop icons (icons float above the glass)
  - **Edit layout** \u2014 re-enable dragging/resizing while in desktop layer
  - **Stay on top** / **Clear glass** (Control Center style) / **Interactive glass** (follows pointer)
- **Widget**: Right-click desktop \u2192 Edit Widgets \u2026 \u2192 search "Liquid Glass" \u2192 drag small/medium/large/extra-large onto the desktop.

### How it works

- Liquid Glass on macOS 26/27: `NSGlassEffectView` (AppKit) and `glassEffect()` (SwiftUI), two styles:
  - `.regular` \u2014 standard frosted feel
  - `.clear` \u2014 ultra-transparent Control Center / widget style
- The widget extension is hand-assembled **without Xcode**: `XPC!` bundle type + `NSExtensionPointIdentifier = com.apple.widgetkit-extension`, ad-hoc signed with `com.apple.security.app-sandbox`, picked up by `pluginkit` / `chronod`.
- Widget body is empty (`Color.clear`, no `containerBackground`) so the system glass plate shows through unchanged.
- **Known difference**: Window glass (`NSGlassEffectView`) blurs the desktop background more heavily than the widget plate \u2014 the system renders the two surfaces differently; blur intensity is not API-configurable. Use `tintColor` to nudge brightness if needed.

### Material Lab

Compare 10 materials side-by-side to find the closest match to the system widget plate:

```bash
swiftc -O -o /tmp/materiallab tools/material-lab.swift -framework AppKit && /tmp/materiallab
# Esc to quit
```

---

<a id="chinese"></a>
## \u4e2d\u6587

### \u7b80\u4ecb

LiquidGlass \u662f macOS 26+ \u4e0a\u7684\u201c\u7eaf\u6db2\u6001\u73bb\u7483\u201d\uFF1A\u4e00\u4e2a\u53ef\u62d6\u62fd/\u53ef\u7f29\u653e\u7684\u73bb\u7483\u7a97\u53e3 App + \u4e00\u4e2a\u201c\u4ec0\u4e48\u90fd\u6ca1\u6709\u201d\u7684\u684c\u9762\u5c0f\u7ec4\u4ef6\u3002**\u4e0d\u9700\u8981 Xcode**\uFF0C\u7eaf\u547d\u4ee4\u884c\u5de5\u5177\u94fe\uFF08CLT + swiftc\uFF09\u6784\u5efa\uFF0Cad-hoc \u7b7e\u540d\u3002

### \u5feb\u901f\u5f00\u59cb

```bash
git clone https://github.com/<you>/LiquidGlass.git
cd LiquidGlass
bash build.sh
pkill -x LiquidGlass 2>/dev/null; true
ditto dist/LiquidGlass.app /Applications/LiquidGlass.app
open /Applications/LiquidGlass.app
```

### \u4f7f\u7528

- \u5c4f\u5e55\u4e2d\u95f4\u51fa\u73b0\u4e00\u5757\u73bb\u7483\uFF1A**\u6309\u4f4f\u4efb\u610f\u5904\u62d6\u52a8**\uFF0C\u62d6\u8fb9\u7f18\u7f29\u653e
- \u83dc\u5355\u680f\u6c34\u6ef4\u56fe\u6807\uFF1A\u5c3a\u5bf8\uFF08\u5c0f/\u4e2d/\u5927/\u7279\u5927\uFF09\u3001\u518d\u5f00\u4e00\u5757\u3001\u684c\u9762\u53e0\u5c42\u3001\u4fdd\u6301\u7f6e\u9876\u3001\u6e05\u900f\u73bb\u7483\u3001\u4e92\u52a8\u73bb\u7483\u3001\u9000\u51fa
- \u5c0f\u7ec4\u4ef6\uFF1A\u53f3\u952e\u684c\u9762 \u2192 \u300c\u7f16\u8f91\u5c0f\u7ec4\u4ef6\u2026\u300d\u2192 \u641c\u300c\u6db2\u6001\u73bb\u7483\u300d\u2192 \u5c0f/\u4e2d/\u5927/\u7279\u5927\u56db\u6863\u62d6\u4e0a\u684c\u9762

\u66f4\u591a\u6280\u672f\u7ec6\u8282\u89c1\u4e0a\u65b9 English \u90e8\u5206\u3002

---

## Contributing

PRs and issues are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

See [SECURITY.md](SECURITY.md) for reporting vulnerabilities.

## License

[MIT](LICENSE) \u00a9 LiquidGlass Contributors
