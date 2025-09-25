# 任务4：实现Timeline数据更新策略

## 📋 任务概述
实现小组件的Timeline更新策略，确保每10秒更新一次答案，并处理数据同步和性能优化。

## 🎯 目标
- 实现每10秒的Timeline更新
- 优化数据获取性能
- 处理数据同步机制
- 实现智能更新策略

## 📁 涉及文件
- `ios/PeaceWidget/PeaceWidget.swift` - 主要修改文件
- `ios/PeaceWidget/PeaceWidgetDataManager.swift` - 数据管理类

## 🔧 具体实现步骤

### 步骤1：优化Timeline生成策略
更新 `ios/PeaceWidget/PeaceWidget.swift` 中的TimelineProvider：

```swift
struct Provider: AppIntentTimelineProvider {
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        var entries: [SimpleEntry] = []
        
        // 生成未来2小时的条目，每10秒一个
        let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: currentDate)!
        var entryDate = currentDate
        
        while entryDate < endDate {
            let answer = await getRandomAnswer()
            let entry = SimpleEntry(
                date: entryDate,
                answer: answer.text,
                libraryName: answer.libraryName
            )
            entries.append(entry)
            
            // 每10秒增加一个条目
            entryDate = Calendar.current.date(byAdding: .second, value: 10, to: entryDate)!
        }
        
        // 设置Timeline策略
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    private func getRandomAnswer() async -> (text: String, libraryName: String) {
        let dataManager = PeaceWidgetDataManager.shared
        let libraryId = dataManager.getCurrentLibraryId()
        
        // 从App Groups获取数据
        guard let libraryData = dataManager.getLibraryData(),
              let answers = libraryData["answers"] as? [String],
              !answers.isEmpty else {
            return ("无法获取答案", "未知库")
        }
        
        // 使用当前时间作为随机种子，确保每次调用结果不同
        let timeInterval = Date().timeIntervalSince1970
        let seed = Int(timeInterval) % answers.count
        let selectedAnswer = answers[seed]
        let libraryName = libraryData["name"] as? String ?? "未知库"
        
        return (selectedAnswer, libraryName)
    }
}
```

### 步骤2：实现数据缓存机制
在 `PeaceWidgetDataManager.swift` 中添加缓存：

```swift
class PeaceWidgetDataManager {
    static let shared = PeaceWidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.peace.widget")
    private var cachedLibraryData: [String: Any]?
    private var lastUpdateTime: Date?
    
    private init() {
        loadCachedData()
    }
    
    private func loadCachedData() {
        cachedLibraryData = userDefaults?.dictionary(forKey: "library_data")
        lastUpdateTime = userDefaults?.object(forKey: "last_update_time") as? Date
    }
    
    func getLibraryData() -> [String: Any]? {
        // 如果缓存数据存在且未过期，直接返回
        if let cached = cachedLibraryData,
           let lastUpdate = lastUpdateTime,
           Date().timeIntervalSince(lastUpdate) < 300) { // 5分钟内使用缓存
            return cached
        }
        
        // 重新加载数据
        loadCachedData()
        return cachedLibraryData
    }
    
    func setLibraryData(_ data: [String: Any]) {
        userDefaults?.set(data, forKey: "library_data")
        userDefaults?.set(Date(), forKey: "last_update_time")
        cachedLibraryData = data
        lastUpdateTime = Date()
        
        // 通知Widget更新
        WidgetCenter.shared.reloadAllTimelines()
    }
}
```

### 步骤3：实现智能更新策略
添加智能更新逻辑：

```swift
extension PeaceWidgetDataManager {
    /// 检查是否需要更新数据
    func shouldUpdateData() -> Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        return Date().timeIntervalSince(lastUpdate) > 300 // 5分钟
    }
    
    /// 获取智能更新的答案
    func getSmartRandomAnswer() -> (text: String, libraryName: String) {
        guard let libraryData = getLibraryData(),
              let answers = libraryData["answers"] as? [String],
              !answers.isEmpty else {
            return ("无法获取答案", "未知库")
        }
        
        // 使用时间戳确保每次调用结果不同
        let timeInterval = Date().timeIntervalSince1970
        let seed = Int(timeInterval * 1000) % answers.count
        let selectedAnswer = answers[seed]
        let libraryName = libraryData["name"] as? String ?? "未知库"
        
        return (selectedAnswer, libraryName)
    }
}
```

### 步骤4：实现数据同步监听
添加数据变化监听：

```swift
extension PeaceWidgetDataManager {
    /// 开始监听数据变化
    func startObserving() {
        NotificationCenter.default.addObserver(
            forName: .NSUbiquitousKeyValueStoreDidChangeExternally,
            object: nil,
            queue: .main
        ) { _ in
            self.loadCachedData()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// 停止监听
    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }
}
```

### 步骤5：优化Timeline策略
实现更智能的Timeline策略：

```swift
struct Provider: AppIntentTimelineProvider {
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        var entries: [SimpleEntry] = []
        
        // 根据Widget家族决定更新频率
        let updateInterval: TimeInterval = context.family == .systemSmall ? 30 : 10
        
        // 生成未来1小时的条目
        let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        var entryDate = currentDate
        
        while entryDate < endDate {
            let answer = await getRandomAnswer()
            let entry = SimpleEntry(
                date: entryDate,
                answer: answer.text,
                libraryName: answer.libraryName
            )
            entries.append(entry)
            
            entryDate = Calendar.current.date(byAdding: .second, value: Int(updateInterval), to: entryDate)!
        }
        
        // 使用智能更新策略
        return Timeline(entries: entries, policy: .atEnd)
    }
}
```

## ✅ 验收标准
- [ ] Timeline每10秒更新一次
- [ ] 数据缓存机制正常工作
- [ ] 智能更新策略有效
- [ ] 数据同步监听正常
- [ ] 性能优化到位

## 🔍 测试方法
1. 测试Timeline更新频率
2. 验证数据缓存效果
3. 测试数据同步机制
4. 检查内存使用情况

## ⚠️ 注意事项
- 避免频繁的数据获取操作
- 合理设置缓存过期时间
- 处理网络异常情况
- 遵循iOS Widget性能限制
