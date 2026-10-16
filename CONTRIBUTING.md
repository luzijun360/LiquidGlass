# Contributing to LiquidGlass

Thanks for wanting to contribute! This project aims to stay minimal and approachable.

## Getting started

```bash
git clone https://github.com/<you>/LiquidGlass.git
cd LiquidGlass
bash build.sh          # or: make
open dist/LiquidGlass.app  # run without installing
```

Requirements: macOS 26+, Xcode Command Line Tools (`xcode-select --install`).

## Development

- `app/main.swift` \u2014 menu-bar app (`NSGlassEffectView`, window management)
- `widget/GlassWidget.swift` \u2014 WidgetKit extension (empty body = pure glass)
- `tools/material-lab.swift` \u2014 visual comparison of glass/blur materials

```bash
make lab    # run material lab
make clean  # remove dist/
```

## Pull requests

- Keep changes focused; one feature/fix per PR.
- Describe what you changed and why. Include a screenshot or screen recording for visual changes.
- Ensure `bash build.sh` still succeeds on macOS 26+.
- Update README if you change user-facing behavior.

## Commit messages

Use a short, imperative subject line (e.g. `Add desktop-layer toggle`).
Conventional Commits (`feat:`, `fix:`, `docs:`) are welcome but not required.

## Code style

- Swift: 4-space indent, `swiftformat`/`swiftlint` if you have them (no strict enforcement).
- Keep the \u201cno Xcode needed\u201d promise \u2014 avoid introducing `.xcodeproj` or CocoaPods/SPM unless discussed in an issue first.

## Reporting bugs

Open an issue with: macOS version, steps to reproduce, expected vs actual behavior, and `build.sh` output if relevant.
