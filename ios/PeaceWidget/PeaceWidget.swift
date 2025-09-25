//
//  peaceWidget.swift
//  peaceWidget
//
//  Created by 雷雷 on 2025/9/25.
//

import WidgetKit
import SwiftUI

// 公共日期格式化
@inline(__always)
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

// MARK: - 主题定义
enum WidgetTheme: String { case stitchA, glass }

struct WidgetThemeConfig { let primary: Color; let secondary: Color; let accent: Color }

struct WidgetThemeProvider {
    static func current() -> WidgetTheme {
        let defaults = UserDefaults(suiteName: "group.com.leilei.peace")
        let raw = defaults?.string(forKey: "widget_theme") ?? "stitchA"
        return WidgetTheme(rawValue: raw) ?? .stitchA
    }
    
    static func colors() -> WidgetThemeConfig {
        switch current() {
        case .glass:
            return .init(primary: Color.primary.opacity(0.95), secondary: Color.secondary.opacity(0.8), accent: .white.opacity(0.7))
        case .stitchA:
            let accent = Color(red: 236/255, green: 127/255, blue: 19/255)
            return .init(primary: .primary, secondary: .secondary, accent: accent)
        }
    }
}

// MARK: - 公共主题视图渲染器
struct WidgetThemeRenderer {
    @ViewBuilder
    static func makeView(entry: SimpleEntry) -> some View {
        let mode = WidgetThemeProvider.current()
        switch mode {
        case .stitchA:
            StitchAThemeView(entry: entry)
        case .glass:
            GlassThemeView(entry: entry)
        }
    }
}

// Stitch A 主题（浅米色、顶部强调色点、中心文案、底部库名）
struct StitchAThemeView: View {
    var entry: SimpleEntry
    var body: some View {
        let theme = WidgetThemeProvider.colors()
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)
            let dateSize = max(minSide * 0.12, 10)
            let answerSize = max(minSide * 0.18, 12)
            let libSize = max(minSide * 0.11, 10)
            ZStack {
                Color(red: 248/255, green: 247/255, blue: 246/255)
                VStack(spacing: minSide * 0.04) {
                    HStack {
                        Text(formatDate(entry.date))
                            .font(.system(size: dateSize, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.accent)
                        Spacer()
                        Circle().fill(theme.accent).frame(width: dateSize * 0.45, height: dateSize * 0.45)
                    }
                    Text(entry.answer)
                        .font(.system(size: answerSize, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                    Text(entry.libraryName)
                        .font(.system(size: libSize, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.accent)
                }
                .padding(minSide * 0.08)
            }
        }
    }
}

// Glass 主题（轻玻璃风：柔和文字 + 半透明雪白面）
struct GlassThemeView: View {
    var entry: SimpleEntry
    var body: some View {
        let theme = WidgetThemeProvider.colors()
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)
            let dateSize = max(minSide * 0.12, 10)
            let answerSize = max(minSide * 0.20, 12)
            let libSize = max(minSide * 0.11, 10)
            ZStack {
                Color.clear
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(minSide * 0.02)
                VStack(spacing: minSide * 0.05) {
                    Text(formatDate(entry.date))
                        .font(.system(size: dateSize, weight: .medium, design: .monospaced))
                        .foregroundColor(theme.secondary)
                    Text(entry.answer)
                        .font(.system(size: answerSize, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)
                    Text(entry.libraryName)
                        .font(.system(size: libSize, weight: .regular, design: .monospaced))
                        .foregroundColor(theme.secondary)
                }
                .padding(minSide * 0.08)
            }
        }
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            answer: "示例答案内容",
            libraryName: "毛泽东语录"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let dataManager = PeaceWidgetDataManager.shared
        let libraryId = dataManager.getCurrentLibraryId()
        let answer = dataManager.getRandomAnswer(for: libraryId)
        
        let entry = SimpleEntry(
            date: Date(),
            answer: answer.text,
            libraryName: answer.libraryName
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        var entries: [SimpleEntry] = []
        let dataManager = PeaceWidgetDataManager.shared
        
        // 使用智能更新策略
        let updateInterval = dataManager.getSmartUpdateInterval(for: context.family)
        
        // 生成未来1小时的条目
        let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        var entryDate = currentDate
        
        while entryDate < endDate {
            let answer = getRandomAnswerSync(for: entryDate)
            let entry = SimpleEntry(
                date: entryDate,
                answer: answer.text,
                libraryName: answer.libraryName
            )
            entries.append(entry)
            
            entryDate = Calendar.current.date(byAdding: .second, value: Int(updateInterval), to: entryDate)!
        }
        
        // 使用智能更新策略
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getRandomAnswerSync(for date: Date) -> (text: String, libraryName: String) {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 从App Groups获取数据
        guard let libraryData = dataManager.getLibraryData(),
              let answers = libraryData["answers"] as? [String],
              !answers.isEmpty else {
            return ("无法获取答案", "未知库")
        }
        
        // 使用特定时间作为随机种子，确保每次调用结果不同
        let timeInterval = date.timeIntervalSince1970
        let seed = Int(timeInterval * 10) % answers.count
        let selectedAnswer = answers[seed]
        let libraryName = libraryData["name"] as? String ?? "未知库"
        
        return (selectedAnswer, libraryName)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let answer: String
    let libraryName: String
}

// MARK: - 小尺寸Widget视图
struct SmallWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        WidgetThemeRenderer.makeView(entry: entry)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - 中等尺寸Widget视图
struct MediumWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        WidgetThemeRenderer.makeView(entry: entry)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - 大尺寸Widget视图
struct LargeWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        WidgetThemeRenderer.makeView(entry: entry)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - 主Widget视图
struct peaceWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            default:
                MediumWidgetView(entry: entry)
            }
        }
        .onAppear {
            // 记录显示时间
            print("Widget显示: \(entry.answer)")
        }
        .animation(.easeInOut(duration: 0.3), value: entry.answer)
    }
}

struct peaceWidget: Widget {
    let kind: String = "peaceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            peaceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Peace小组件")
        .description("显示每日精选答案")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - 预览
struct peaceWidget_Previews: PreviewProvider {
    static var previews: some View {
        peaceWidgetEntryView(entry: SimpleEntry(date: Date(), answer: "为人民服务", libraryName: "毛泽东语录"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
