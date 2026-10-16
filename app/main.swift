// LiquidGlass — 一块纯液态玻璃，浮在桌面上。
// Pure AppKit + Liquid Glass (NSGlassEffectView)，无需 Xcode。
// Build: swiftc -O -o LiquidGlass main.swift -framework AppKit

import AppKit
import CoreGraphics

// MARK: - 玻璃视图

final class GlassView: NSView {
    private let glass = NSGlassEffectView()

    var interactiveMode = false {
        didSet { applyInteractive() }
    }

    /// true = 清透材质（控制中心 / 小组件风格）；false = 常规材质
    var clearStyle = true {
        didSet { glass.style = clearStyle ? .clear : .regular }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        glass.style = .clear
        glass.cornerRadius = 34
        glass.frame = bounds
        glass.autoresizingMask = [.width, .height]
        addSubview(glass)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func layout() {
        super.layout()
        let m = min(bounds.width, bounds.height)
        glass.cornerRadius = max(20, min(36, m * 0.12))
    }

    // 默认不抢鼠标事件 → 整个窗口随便拖；开启「互动玻璃」后恢复正常命中
    override func hitTest(_ point: NSPoint) -> NSView? {
        interactiveMode ? super.hitTest(point) : nil
    }

    private func applyInteractive() {
        if #available(macOS 27.0, *) {
            glass.effectIsInteractive = interactiveMode
        }
    }
}

// MARK: - App 委托

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var windows: [NSWindow] = []
    private var statusItem: NSStatusItem!
    private var keepOnTop = false
    private var interactive = false
    private var clearStyle = true
    private var desktopLayer = false
    private var editLayout = false
    private weak var desktopLayerItem: NSMenuItem?
    private weak var editLayoutItem: NSMenuItem?

    private let presets: [(title: String, size: NSSize)] = [
        ("小 · 170 × 170", NSSize(width: 170, height: 170)),
        ("中 · 364 × 170", NSSize(width: 364, height: 170)),
        ("大 · 364 × 382", NSSize(width: 364, height: 382)),
        ("特大 · 736 × 382", NSSize(width: 736, height: 382)),
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMainMenu()
        desktopLayer = UserDefaults.standard.bool(forKey: "desktopLayerMode")
        buildStatusItem()
        restoreWindows()
        applyWindowMode()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    func applicationWillTerminate(_ notification: Notification) {
        saveLayout()
    }

    // MARK: 桌面叠层（玻璃垫在图标下面）

    /// 把窗口降到壁纸与图标之间的图层（desktopWindow 层），图标即压在玻璃上。
    /// 桌面叠层开启且未进入「调整位置」时：点击穿透、无阴影、全空间常驻。
    private func applyWindowMode() {
        let desktopLevel = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        for window in windows {
            if desktopLayer && !editLayout {
                window.level = desktopLevel
                window.ignoresMouseEvents = true
                window.hasShadow = false
                window.isMovableByWindowBackground = false
                window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            } else if desktopLayer && editLayout {
                window.level = .floating
                window.ignoresMouseEvents = false
                window.hasShadow = true
                window.isMovableByWindowBackground = true
                window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            } else {
                window.level = keepOnTop ? .floating : .normal
                window.ignoresMouseEvents = false
                window.hasShadow = true
                window.isMovableByWindowBackground = true
                window.collectionBehavior = []
            }
        }
    }

    private func saveLayout() {
        let d = UserDefaults.standard
        d.set(desktopLayer, forKey: "desktopLayerMode")
        let frames = windows.map { w -> String in
            let f = w.frame
            return "\(Int(f.origin.x)),\(Int(f.origin.y)),\(Int(f.width)),\(Int(f.height))"
        }.joined(separator: ";")
        d.set(frames, forKey: "glassFrames")
    }

    private func restoreWindows() {
        let framesStr = UserDefaults.standard.string(forKey: "glassFrames") ?? ""
        for part in framesStr.split(separator: ";") {
            let n = part.split(separator: ",").compactMap { Double($0) }
            guard n.count == 4, n[2] >= 80, n[3] >= 80 else { continue }
            let window = openGlass(size: NSSize(width: n[2], height: n[3]), center: false)
            window.setFrameOrigin(NSPoint(x: n[0], y: n[1]))
        }
        if windows.isEmpty { openGlass(size: presets[2].size) }
    }

    // MARK: 菜单

    private func buildMainMenu() {
        let mainMenu = NSMenu()
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: "退出液态玻璃", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        appItem.submenu = appMenu
        NSApp.mainMenu = mainMenu
    }

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "drop.fill", accessibilityDescription: "液态玻璃")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()

        let sizeItem = NSMenuItem(title: "尺寸", action: nil, keyEquivalent: "")
        let sizeMenu = NSMenu()
        for (index, preset) in presets.enumerated() {
            let item = NSMenuItem(title: preset.title, action: #selector(applyPreset(_:)), keyEquivalent: "")
            item.target = self
            item.tag = index
            sizeMenu.addItem(item)
        }
        sizeItem.submenu = sizeMenu
        menu.addItem(sizeItem)

        let newItem = NSMenuItem(title: "再开一块玻璃", action: #selector(newGlass), keyEquivalent: "n")
        newItem.target = self
        menu.addItem(newItem)

        menu.addItem(.separator())

        let dlItem = NSMenuItem(title: "桌面叠层模式（图标压在上面）", action: #selector(toggleDesktopLayer(_:)), keyEquivalent: "")
        dlItem.target = self
        dlItem.state = desktopLayer ? .on : .off
        desktopLayerItem = dlItem
        menu.addItem(dlItem)

        let edItem = NSMenuItem(title: "调整位置（拖动 / 缩放）", action: #selector(toggleEditLayout(_:)), keyEquivalent: "")
        edItem.target = self
        edItem.state = editLayout ? .on : .off
        editLayoutItem = edItem
        menu.addItem(edItem)

        menu.addItem(.separator())

        let topItem = NSMenuItem(title: "保持置顶", action: #selector(toggleTop(_:)), keyEquivalent: "")
        topItem.target = self
        topItem.state = keepOnTop ? .on : .off
        menu.addItem(topItem)

        let clearItem = NSMenuItem(title: "清透玻璃（控制中心风格）", action: #selector(toggleClearStyle(_:)), keyEquivalent: "")
        clearItem.target = self
        clearItem.state = clearStyle ? .on : .off
        menu.addItem(clearItem)

        let interactiveItem = NSMenuItem(title: "互动玻璃（跟随指针）", action: #selector(toggleInteractive(_:)), keyEquivalent: "")
        interactiveItem.target = self
        interactiveItem.state = interactive ? .on : .off
        menu.addItem(interactiveItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    // MARK: 窗口

    @discardableResult
    private func openGlass(size: NSSize, center: Bool = true) -> NSWindow {
        let rect = NSRect(origin: .zero, size: size)
        let window = NSWindow(contentRect: rect,
                              styleMask: [.titled, .fullSizeContentView, .resizable, .closable],
                              backing: .buffered,
                              defer: false)
        window.title = "液态玻璃"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isReleasedWhenClosed = false
        window.level = keepOnTop ? .floating : .normal
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.delegate = self

        let glassView = GlassView(frame: rect)
        glassView.interactiveMode = interactive
        glassView.clearStyle = clearStyle
        window.contentView = glassView

        if center {
            window.center()
            if windows.count > 0 {
                let offset = CGFloat(windows.count) * 28
                window.setFrameOrigin(NSPoint(x: window.frame.origin.x + offset, y: window.frame.origin.y - offset))
            }
        }
        if desktopLayer && !editLayout {
            window.orderFront(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
        }
        windows.append(window)
        applyWindowMode()
        return window
    }

    private var targetWindow: NSWindow? {
        if let key = NSApp.keyWindow, windows.contains(key) { return key }
        return windows.last
    }

    @objc private func applyPreset(_ sender: NSMenuItem) {
        guard let window = targetWindow else { return }
        window.setContentSize(presets[sender.tag].size)
        if !desktopLayer { window.center() }
        saveLayout()
    }

    @objc private func newGlass() {
        openGlass(size: presets[2].size)
        saveLayout()
    }

    @objc private func toggleTop(_ sender: NSMenuItem) {
        keepOnTop.toggle()
        sender.state = keepOnTop ? .on : .off
        applyWindowMode()
    }

    @objc private func toggleClearStyle(_ sender: NSMenuItem) {
        clearStyle.toggle()
        sender.state = clearStyle ? .on : .off
        for window in windows { (window.contentView as? GlassView)?.clearStyle = clearStyle }
    }

    @objc private func toggleInteractive(_ sender: NSMenuItem) {
        interactive.toggle()
        sender.state = interactive ? .on : .off
        for window in windows { (window.contentView as? GlassView)?.interactiveMode = interactive }
    }

    @objc private func toggleDesktopLayer(_ sender: NSMenuItem) {
        desktopLayer.toggle()
        sender.state = desktopLayer ? .on : .off
        if desktopLayer {
            editLayout = false
            editLayoutItem?.state = .off
        }
        applyWindowMode()
        saveLayout()
    }

    @objc private func toggleEditLayout(_ sender: NSMenuItem) {
        editLayout.toggle()
        sender.state = editLayout ? .on : .off
        applyWindowMode()
        if !editLayout { saveLayout() }
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        windows.removeAll { $0 === window }
        saveLayout()
    }
}

// MARK: - 启动

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
