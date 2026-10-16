// material-lab.swift — 材质对比实验台（开发工具）
// 把系统各种玻璃/毛玻璃材质排成一排，用于挑出最接近系统小组件底板的质感。
// Build & run: swiftc -O -o materiallab material-lab.swift -framework AppKit && ./materiallab

import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let cols = 5
let tileW: CGFloat = 152, tileH: CGFloat = 168, gap: CGFloat = 8, margin: CGFloat = 12
let W = margin * 2 + CGFloat(cols) * tileW + CGFloat(cols - 1) * gap
let H = margin * 2 + 2 * tileH + gap

let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: W, height: H),
                   styleMask: [.titled, .fullSizeContentView],
                   backing: .buffered, defer: false)
win.titleVisibility = .hidden
win.titlebarAppearsTransparent = true
win.isMovableByWindowBackground = true
win.backgroundColor = .clear
win.isOpaque = false
win.hasShadow = true

let root = NSView(frame: NSRect(x: 0, y: 0, width: W, height: H))
win.contentView = root

func label(_ text: String, over rect: NSRect) {
    let l = NSTextField(labelWithString: text)
    l.font = .systemFont(ofSize: 11, weight: .semibold)
    l.textColor = .white
    l.frame = NSRect(x: rect.minX + 8, y: rect.maxY - 20, width: rect.width - 16, height: 15)
    root.addSubview(l)
}

var idx = 0
func nextRect() -> NSRect {
    let col = idx % cols
    let row = idx / cols
    idx += 1
    return NSRect(x: margin + CGFloat(col) * (tileW + gap),
                  y: margin + CGFloat(1 - row) * (tileH + gap),
                  width: tileW, height: tileH)
}

// 1-4: NSGlassEffectView 变体
func addGlass(_ name: String, style: NSGlassEffectView.Style, tint: NSColor? = nil, interactive: Bool = false) {
    let rect = nextRect()
    let g = NSGlassEffectView(frame: rect)
    g.style = style
    g.cornerRadius = 22
    g.tintColor = tint
    if interactive, #available(macOS 27.0, *) { g.effectIsInteractive = true }
    root.addSubview(g)
    label(name, over: rect)
}
addGlass("glass.clear", style: .clear)
addGlass("glass.regular", style: .regular)
addGlass("glass.clear+tint", style: .clear, tint: NSColor.white.withAlphaComponent(0.18))
addGlass("glass.clear+int", style: .clear, interactive: true)

// 5-10: NSVisualEffectView 各材质
let mats: [(String, NSVisualEffectView.Material)] = [
    ("underWinBg", .underWindowBackground),
    ("contentBg", .contentBackground),
    ("headerView", .headerView),
    ("hudWindow", .hudWindow),
    ("popover", .popover),
    ("windowBg", .windowBackground),
]
for (name, mat) in mats {
    let rect = nextRect()
    let v = NSVisualEffectView(frame: rect)
    v.material = mat
    v.blendingMode = .behindWindow
    v.state = .active
    v.wantsLayer = true
    v.layer?.cornerRadius = 22
    v.layer?.masksToBounds = true
    root.addSubview(v)
    label(name, over: rect)
}

// 左下角摆放，避开桌面上部的小组件
win.setFrameOrigin(NSPoint(x: 20, y: 20))
win.makeKeyAndOrderFront(nil)

// 30 分钟保险超时（不会自动秒退；看完了点一下窗口按 Esc 关闭）
DispatchQueue.main.asyncAfter(deadline: .now() + 1800) { NSApp.terminate(nil) }
NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
    if event.keyCode == 53 { NSApp.terminate(nil); return nil }  // Esc
    return event
}
app.run()
