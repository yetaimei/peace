# 任务6：测试和性能优化

## 📋 任务概述
对小组件进行全面测试和性能优化，确保功能稳定、性能良好、用户体验优秀。

## 🎯 目标
- 完成功能测试
- 性能优化
- 用户体验优化
- 错误处理完善

## 📁 涉及文件
- 所有Widget相关文件
- 测试用例文件
- 性能监控代码

## 🔧 具体实现步骤

### 步骤1：创建测试用例
创建 `ios/PeaceWidget/PeaceWidgetTests.swift`：

```swift
import XCTest
@testable import PeaceWidget

class PeaceWidgetTests: XCTestCase {
    var dataManager: PeaceWidgetDataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = PeaceWidgetDataManager.shared
    }
    
    func testDataManagerInitialization() {
        XCTAssertNotNil(dataManager)
    }
    
    func testGetCurrentLibraryId() {
        let libraryId = dataManager.getCurrentLibraryId()
        XCTAssertNotNil(libraryId)
        XCTAssertFalse(libraryId.isEmpty)
    }
    
    func testSetLibraryData() {
        let testData = [
            "id": "test_library",
            "name": "测试库",
            "answers": ["答案1", "答案2", "答案3"]
        ]
        
        dataManager.setLibraryData(testData)
        let retrievedData = dataManager.getLibraryData()
        
        XCTAssertNotNil(retrievedData)
        XCTAssertEqual(retrievedData?["id"] as? String, "test_library")
    }
    
    func testGetRandomAnswer() {
        let testData = [
            "id": "test_library",
            "name": "测试库",
            "answers": ["答案1", "答案2", "答案3"]
        ]
        
        dataManager.setLibraryData(testData)
        let answer = dataManager.getSmartRandomAnswer()
        
        XCTAssertNotNil(answer.text)
        XCTAssertFalse(answer.text.isEmpty)
        XCTAssertEqual(answer.libraryName, "测试库")
    }
}
```

### 步骤2：性能监控
在 `PeaceWidgetDataManager.swift` 中添加性能监控：

```swift
class PeaceWidgetDataManager {
    // 现有代码...
    
    private var performanceMetrics: [String: TimeInterval] = [:]
    
    /// 监控数据获取性能
    func getLibraryDataWithMetrics() -> [String: Any]? {
        let startTime = Date()
        let result = getLibraryData()
        let duration = Date().timeIntervalSince(startTime)
        
        performanceMetrics["getLibraryData"] = duration
        LoggerService.debug("数据获取耗时: \(duration)秒")
        
        return result
    }
    
    /// 获取性能指标
    func getPerformanceMetrics() -> [String: TimeInterval] {
        return performanceMetrics
    }
    
    /// 重置性能指标
    func resetPerformanceMetrics() {
        performanceMetrics.removeAll()
    }
}
```

### 步骤3：内存优化
实现内存优化策略：

```swift
extension PeaceWidgetDataManager {
    /// 清理缓存数据
    func clearCache() {
        cachedLibraryData = nil
        lastUpdateTime = nil
        performanceMetrics.removeAll()
    }
    
    /// 检查内存使用情况
    func checkMemoryUsage() {
        let memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryUsage = memoryInfo.resident_size
            LoggerService.debug("内存使用: \(memoryUsage / 1024 / 1024)MB")
        }
    }
}
```

### 步骤4：错误处理完善
添加完善的错误处理：

```swift
enum WidgetError: Error {
    case dataNotFound
    case invalidData
    case networkError
    case permissionDenied
}

extension PeaceWidgetDataManager {
    /// 安全获取数据
    func safeGetLibraryData() throws -> [String: Any] {
        guard let data = getLibraryData() else {
            throw WidgetError.dataNotFound
        }
        
        guard let answers = data["answers"] as? [String],
              !answers.isEmpty else {
            throw WidgetError.invalidData
        }
        
        return data
    }
    
    /// 安全获取随机答案
    func safeGetRandomAnswer() -> (text: String, libraryName: String) {
        do {
            let data = try safeGetLibraryData()
            let answers = data["answers"] as! [String]
            let randomIndex = Int.random(in: 0..<answers.count)
            let selectedAnswer = answers[randomIndex]
            let libraryName = data["name"] as? String ?? "未知库"
            
            return (selectedAnswer, libraryName)
        } catch {
            LoggerService.error("获取随机答案失败: \(error)", "WIDGET_ERROR")
            return ("无法获取答案", "错误")
        }
    }
}
```

### 步骤5：用户体验优化
优化用户体验：

```swift
struct peaceWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
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
                    .animation(.easeInOut(duration: 0.3), value: entry.answer)
                
                // 答案库名称
                Text(entry.libraryName)
                    .font(.caption2)
                    .foregroundColor(.tertiary)
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundView)
        .onAppear {
            // 记录显示时间
            LoggerService.debug("Widget显示: \(entry.answer)")
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.quaternary, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
```

### 步骤6：创建测试脚本
创建 `scripts/test_widget.sh`：

```bash
#!/bin/bash

echo "🧪 开始小组件测试..."

# 清理构建
echo "🧹 清理构建..."
xcodebuild clean -workspace ios/Runner.xcworkspace -scheme Runner

# 构建项目
echo "🔨 构建项目..."
xcodebuild build -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# 运行测试
echo "🧪 运行测试..."
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# 检查Widget
echo "📱 检查Widget..."
xcrun simctl list devices | grep "iPhone 16 Pro"

echo "✅ 测试完成！"
```

## ✅ 验收标准
- [ ] 所有测试用例通过
- [ ] 性能指标符合要求
- [ ] 内存使用合理
- [ ] 错误处理完善
- [ ] 用户体验优秀

## 🔍 测试方法
1. 运行单元测试
2. 性能压力测试
3. 内存泄漏检查
4. 用户体验测试

## ⚠️ 注意事项
- 确保测试覆盖所有功能
- 监控性能指标
- 处理边界情况
- 优化用户体验
