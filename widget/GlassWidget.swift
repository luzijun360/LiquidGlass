// GlassWidget — 一个「什么都没有」的 WidgetKit 小组件扩展。
// 内容为空，只保留系统自动渲染的 Liquid Glass 底板。
// Build: swiftc -O -parse-as-library -o GlassWidget GlassWidget.swift -framework WidgetKit -framework SwiftUI

import WidgetKit
import SwiftUI

struct GlassEntry: TimelineEntry {
    let date: Date
}

struct GlassProvider: TimelineProvider {
    func placeholder(in context: Context) -> GlassEntry {
        GlassEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (GlassEntry) -> Void) {
        completion(GlassEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GlassEntry>) -> Void) {
        completion(Timeline(entries: [GlassEntry(date: .now)], policy: .never))
    }
}

struct GlassBlockWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LiquidGlassBlock", provider: GlassProvider()) { _ in
            Color.clear
        }
        .configurationDisplayName("纯液态玻璃")
        .description("什么都没有——就是一块液态玻璃。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

@main
struct GlassWidgetBundle: WidgetBundle {
    var body: some Widget {
        GlassBlockWidget()
    }
}
