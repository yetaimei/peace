# 任务2：实现小组件数据逻辑

## 📋 任务概述
实现小组件的核心数据逻辑，包括答案库数据获取、随机选择算法和Timeline管理。

## 🎯 目标
- 实现答案库数据获取逻辑
- 实现随机答案选择算法
- 配置Timeline更新策略（每10秒更新一次）
- 处理数据同步和错误情况

## 📁 涉及文件
- `ios/PeaceWidget/PeaceWidget.swift` - 主要修改文件
- `ios/PeaceWidget/PeaceWidgetDataManager.swift` - 数据管理类

## 🔧 具体实现步骤

### 步骤1：修改TimelineProvider
更新 `ios/PeaceWidget/PeaceWidget.swift` 中的Provider类：

```swift
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            answer: "示例答案内容",
            libraryName: "毛泽东语录"
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let dataManager = PeaceWidgetDataManager.shared
        let libraryId = dataManager.getCurrentLibraryId()
        let answer = await getRandomAnswer(for: libraryId)
        
        return SimpleEntry(
            date: Date(),
            answer: answer.text,
            libraryName: answer.libraryName
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // 生成未来24小时的条目，每10秒一个
        for secondOffset in stride(from: 0, to: 86400, by: 10) {
            let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: currentDate)!
            let answer = await getRandomAnswer(for: dataManager.getCurrentLibraryId())
            
            let entry = SimpleEntry(
                date: entryDate,
                answer: answer.text,
                libraryName: answer.libraryName
            )
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    private func getRandomAnswer(for libraryId: String) async -> (text: String, libraryName: String) {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 从App Groups获取答案库数据
        guard let libraryData = dataManager.getLibraryData(),
              let answers = libraryData["answers"] as? [String],
              !answers.isEmpty else {
            return ("无法获取答案", "未知库")
        }
        
        // 随机选择答案
        let randomIndex = Int.random(in: 0..<answers.count)
        let selectedAnswer = answers[randomIndex]
        let libraryName = libraryData["name"] as? String ?? "未知库"
        
        return (selectedAnswer, libraryName)
    }
}
```

### 步骤2：更新SimpleEntry结构
修改SimpleEntry以包含答案数据：

```swift
struct SimpleEntry: TimelineEntry {
    let date: Date
    let answer: String
    let libraryName: String
}
```

### 步骤3：实现数据获取逻辑
在 `PeaceWidgetDataManager.swift` 中添加：

```swift
extension PeaceWidgetDataManager {
    /// 获取随机答案
    func getRandomAnswer(for libraryId: String) -> (text: String, libraryName: String) {
        guard let libraryData = getLibraryData(),
              let answers = libraryData["answers"] as? [String],
              !answers.isEmpty else {
            return ("无法获取答案", "未知库")
        }
        
        let randomIndex = Int.random(in: 0..<answers.count)
        let selectedAnswer = answers[randomIndex]
        let libraryName = libraryData["name"] as? String ?? "未知库"
        
        return (selectedAnswer, libraryName)
    }
    
    /// 监听数据变化
    func observeDataChanges() {
        NotificationCenter.default.addObserver(
            forName: .NSUbiquitousKeyValueStoreDidChangeExternally,
            object: nil,
            queue: .main
        ) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
```

## ✅ 验收标准
- [ ] Timeline每10秒更新一次
- [ ] 能够正确获取答案库数据
- [ ] 随机选择算法工作正常
- [ ] 处理数据缺失情况
- [ ] 数据同步机制正常

## 🔍 测试方法
1. 在模拟器中测试Widget显示
2. 切换不同答案库验证数据更新
3. 测试网络断开情况下的表现
4. 验证Timeline更新频率

## ⚠️ 注意事项
- 确保随机算法不会重复选择相同答案
- 处理答案库为空的情况
- 优化数据获取性能
- 遵循iOS Widget内存限制
