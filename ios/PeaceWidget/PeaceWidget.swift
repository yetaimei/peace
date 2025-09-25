//
//  peaceWidget.swift
//  peaceWidget
//
//  Created by 雷雷 on 2025/9/25.
//

import WidgetKit
import SwiftUI

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
        VStack(alignment: .leading, spacing: 4) {
            Text(formatDate(entry.date))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(entry.answer)
                .font(.caption)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(entry.answer)
                    .font(.body)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatDate(entry.date))
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(entry.libraryName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.answer)
                .font(.body)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
                .padding()
                .background(Color.clear)
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
