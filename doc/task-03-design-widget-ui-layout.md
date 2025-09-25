# 任务3：设计小组件UI布局

## 📋 任务概述
根据PRD要求设计小组件的UI布局，包括日期显示、答案内容展示和主题适配。

## 🎯 目标
- 实现日期显示（年月日格式：2025-09-25）
- 实现答案内容展示
- 支持iOS 26主题规范
- 适配不同尺寸的Widget

## 📁 涉及文件
- `ios/PeaceWidget/PeaceWidget.swift` - 主要修改文件
- `ios/PeaceWidget/PeaceWidgetAssets.xcassets` - 资源文件

## 🔧 具体实现步骤

### 步骤1：更新Widget视图
修改 `ios/PeaceWidget/PeaceWidget.swift` 中的视图：

```swift
struct peaceWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 日期显示
            HStack {
                Text(formatDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // 答案内容
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.answer)
                    .font(.body)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                // 答案库名称
                Text(entry.libraryName)
                    .font(.caption2)
                    .foregroundColor(.tertiary)
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundView)
    }
    
    private var backgroundView: some View {
        // 支持iOS 26主题的透明背景
        RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.quaternary, lineWidth: 0.5)
            )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
```

### 步骤2：支持不同尺寸
为不同尺寸的Widget提供适配：

```swift
struct peaceWidget: Widget {
    let kind: String = "peaceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            peaceWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Peace小组件")
        .description("显示每日精选答案")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

### 步骤3：创建不同尺寸的视图
为不同尺寸创建专门的视图：

```swift
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
            }
            
            Spacer()
        }
        .padding()
    }
}

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
    }
}
```

### 步骤4：更新主视图以支持不同尺寸
修改 `peaceWidgetEntryView`：

```swift
struct peaceWidgetEntryView: View {
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
```

## ✅ 验收标准
- [ ] 日期格式正确显示（yyyy-MM-dd）
- [ ] 答案内容正确展示
- [ ] 支持iOS 26主题规范
- [ ] 不同尺寸Widget适配良好
- [ ] 背景透明效果正确
- [ ] 文字大小和间距合适

## 🔍 测试方法
1. 在模拟器中测试不同尺寸的Widget
2. 切换系统主题验证适配效果
3. 测试长文本的显示效果
4. 验证日期格式的正确性

## ⚠️ 注意事项
- 确保文字在不同主题下都清晰可见
- 处理超长文本的截断显示
- 遵循iOS Widget设计指南
- 考虑无障碍功能支持
