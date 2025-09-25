import WidgetKit
import SwiftUI
import UIKit

// 全局日期格式化函数
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func dayString(from date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "d"
    return f.string(from: date)
}

func monthString(from date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "MMM"
    return f.string(from: date)
}

// 生成可平铺的点阵背景图片（iOS 14 兼容）
func dotPatternUIImage(accent: UIColor, tileSize: CGFloat = 10, dotSize: CGFloat = 1, alpha: CGFloat = 0.2) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: tileSize, height: tileSize))
    return renderer.image { ctx in
        let rect = CGRect(x: (tileSize - dotSize) / 2, y: (tileSize - dotSize) / 2, width: dotSize, height: dotSize)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: dotSize / 2)
        accent.withAlphaComponent(alpha).setFill()
        path.fill()
    }
}

// MARK: - Widget主题配置
enum WidgetTheme: String, CaseIterable {
    case stitchA = "stitchA"
    case glass = "glass"
}

struct WidgetThemeConfig {
    let accent: Color
    let background: Color
    let text: Color
}

struct WidgetThemeProvider {
    static func colors() -> WidgetThemeConfig {
        return WidgetThemeConfig(
            accent: Color(red: 236/255, green: 127/255, blue: 19/255), // #ec7f13
            background: Color(red: 34/255, green: 25/255, blue: 16/255),
            text: Color.white
        )
    }
    
    static func current() -> WidgetTheme {
        let userDefaults = UserDefaults(suiteName: "group.com.leilei.peace")
        let themeString = userDefaults?.string(forKey: "widget_theme") ?? "stitchA"
        return WidgetTheme(rawValue: themeString) ?? .stitchA
    }
}

// MARK: - Widget主题渲染器
struct WidgetThemeRenderer {
    @ViewBuilder
    static func makeView(entry: SimpleEntry) -> some View {
        let theme = WidgetThemeProvider.current()
        
        switch theme {
        case .stitchA:
            StitchAThemeView(entry: entry)
        case .glass:
            GlassThemeView(entry: entry)
        }
    }
}

// Stitch A 主题（透明背景，跟随系统主题）
struct StitchAThemeView: View {
    var entry: SimpleEntry
    
    var body: some View {
        let theme = WidgetThemeProvider.colors()
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)
            let area = geo.size.width * geo.size.height
            
            // 根据组件尺寸动态调整字体大小和间距
            let config = getStitchAConfig(area: area, minSide: minSide)
            
            ZStack {
                // 透明背景，跟随系统主题
                Color.clear
                
                VStack(spacing: 0) {
                    Spacer(minLength: config.spacing)
                    
                    // 中心内容：语录
                    Text(entry.answer)
                        .font(.system(size: config.quoteSize, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: config.spacing)
                    
                    // 右下角签名
                    HStack {
                        Spacer()
                        Text("—— " + entry.libraryName)
                            .font(.system(size: config.authorSize, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .minimumScaleFactor(0.4)
                    }
                }
                .padding(config.padding)
            }
        }
    }
    
    private struct StitchAConfig {
        let quoteSize: CGFloat
        let authorSize: CGFloat
        let spacing: CGFloat
        let padding: CGFloat
    }
    
    private func getStitchAConfig(area: CGFloat, minSide: CGFloat) -> StitchAConfig {
        if area < 6000 { // 小组件
            return StitchAConfig(
                quoteSize: minSide * 0.12,
                authorSize: minSide * 0.09,
                spacing: minSide * 0.04,
                padding: minSide * 0.06
            )
        } else if area < 20000 { // 中等组件
            return StitchAConfig(
                quoteSize: minSide * 0.10,
                authorSize: minSide * 0.08,
                spacing: minSide * 0.05,
                padding: minSide * 0.05
            )
        } else { // 大组件
            return StitchAConfig(
                quoteSize: minSide * 0.08,
                authorSize: minSide * 0.06,
                spacing: minSide * 0.06,
                padding: minSide * 0.04
            )
        }
    }
}

// Glass 主题（轻玻璃风：柔和文字 + 半透明深色面）
struct GlassThemeView: View {
    var entry: SimpleEntry
    
    var body: some View {
        let theme = WidgetThemeProvider.colors()
        GeometryReader { geo in
            let minSide = min(geo.size.width, geo.size.height)
            let area = geo.size.width * geo.size.height
            
            // 根据组件尺寸动态调整字体大小和间距
            let config = getGlassConfig(area: area, minSide: minSide)
            
            ZStack {
                // 透明背景，跟随系统主题
                Color.clear
                
                VStack(spacing: 0) {
                    Spacer(minLength: config.spacing)
                    
                    // 中心内容：语录
                    Text(entry.answer)
                        .font(.system(size: config.answerSize, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: config.spacing)
                    
                    // 右下角签名
                    HStack {
                        Spacer()
                        Text("—— " + entry.libraryName)
                            .font(.system(size: config.libSize, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .minimumScaleFactor(0.4)
                    }
                }
                .padding(config.padding)
            }
        }
    }
    
    private struct GlassConfig {
        let answerSize: CGFloat
        let libSize: CGFloat
        let spacing: CGFloat
        let padding: CGFloat
    }
    
    private func getGlassConfig(area: CGFloat, minSide: CGFloat) -> GlassConfig {
        if area < 6000 { // 小组件
            return GlassConfig(
                answerSize: minSide * 0.15,
                libSize: minSide * 0.09,
                spacing: minSide * 0.04,
                padding: minSide * 0.06
            )
        } else if area < 20000 { // 中等组件
            return GlassConfig(
                answerSize: minSide * 0.12,
                libSize: minSide * 0.08,
                spacing: minSide * 0.05,
                padding: minSide * 0.05
            )
        } else { // 大组件
            return GlassConfig(
                answerSize: minSide * 0.10,
                libSize: minSide * 0.06,
                spacing: minSide * 0.06,
                padding: minSide * 0.04
            )
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
}

// MARK: - 中等尺寸Widget视图
struct MediumWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        WidgetThemeRenderer.makeView(entry: entry)
    }
}

// MARK: - 大尺寸Widget视图
struct LargeWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        WidgetThemeRenderer.makeView(entry: entry)
    }
}

struct peaceWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
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
}

struct peaceWidget: Widget {
    let kind: String = "peaceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            peaceWidgetEntryView(entry: entry)
                .background(Color.clear)
        }
        .configurationDisplayName("答案之书")
        .description("每日精选答案，带给你内心的平静。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#if DEBUG
struct peaceWidget_Previews: PreviewProvider {
    static var previews: some View {
        peaceWidgetEntryView(entry: SimpleEntry(date: Date(), answer: "随遇而安，保持内心平静", libraryName: "禅意答案"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif