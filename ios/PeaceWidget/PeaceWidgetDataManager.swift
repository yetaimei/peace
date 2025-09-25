//
//  PeaceWidgetDataManager.swift
//  PeaceWidget
//
//  Created by 雷雷 on 2025/9/25.
//

import Foundation
import WidgetKit

class PeaceWidgetDataManager {
    static let shared = PeaceWidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.leilei.peace")
    private var cachedLibraryData: [String: Any]?
    private var lastUpdateTime: Date?
    private var performanceMetrics: [String: TimeInterval] = [:]
    
    private init() {
        loadCachedData()
        print("🔍 数据管理器初始化 - 缓存数据: \(cachedLibraryData != nil)")
        print("🔍 当前库ID: \(getCurrentLibraryId())")
    }
    
    private func loadCachedData() {
        // 从JSON字符串加载数据
        if let jsonString = userDefaults?.string(forKey: "library_data") {
            do {
                let jsonData = jsonString.data(using: .utf8)
                if let jsonData = jsonData {
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    cachedLibraryData = jsonObject as? [String: Any]
                    print("🔍 从JSON加载数据成功: \(cachedLibraryData?["name"] ?? "未知")")
                }
            } catch {
                print("❌ JSON解析失败: \(error)")
                cachedLibraryData = nil
            }
        } else {
            cachedLibraryData = nil
        }
        lastUpdateTime = userDefaults?.object(forKey: "last_update_time") as? Date
    }
    
    // 获取当前选中的答案库ID
    func getCurrentLibraryId() -> String {
        return userDefaults?.string(forKey: "current_answer_library") ?? "mao_zedong"
    }
    
    // 设置当前答案库
    func setCurrentLibrary(_ libraryId: String) {
        userDefaults?.set(libraryId, forKey: "current_answer_library")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // 获取答案库数据
    func getLibraryData() -> [String: Any]? {
        // 如果缓存数据存在且未过期，直接返回
        if let cached = cachedLibraryData,
           let lastUpdate = lastUpdateTime,
           Date().timeIntervalSince(lastUpdate) < 300 { // 5分钟内使用缓存
            return cached
        }
        
        // 重新加载数据
        loadCachedData()
        return cachedLibraryData
    }
    
    // 设置答案库数据
    func setLibraryData(_ data: [String: Any]) {
        userDefaults?.set(data, forKey: "library_data")
        userDefaults?.set(Date(), forKey: "last_update_time")
        cachedLibraryData = data
        lastUpdateTime = Date()
        
        // 通知Widget更新
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // 获取随机答案
    func getRandomAnswer(for libraryId: String) -> (text: String, libraryName: String) {
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
    
    // 获取智能随机答案（基于时间戳的确定性随机）
    func getSmartRandomAnswer() -> (text: String, libraryName: String) {
        guard let libraryData = getLibraryData(),
              let answers = libraryData["answers"] as? [String],
              !answers.isEmpty else {
            return ("无法获取答案", "未知库")
        }
        
        // 使用当前时间作为随机种子，确保每10秒结果不同
        let timeInterval = Date().timeIntervalSince1970
        let seed = Int(timeInterval * 10) % answers.count // 每10秒变化一次
        let selectedAnswer = answers[seed]
        let libraryName = libraryData["name"] as? String ?? "未知库"
        
        return (selectedAnswer, libraryName)
    }
    
    // 手动刷新数据
    func refreshData() {
        loadCachedData()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // 设置测试数据
    func setTestData() {
        print("📝 开始设置测试数据...")
        let testData: [String: Any] = [
            "id": "mao_zedong",
            "name": "毛泽东语录",
            "answers": [
                "为人民服务",
                "实事求是",
                "自力更生，艰苦奋斗",
                "团结就是力量",
                "好好学习，天天向上"
            ]
        ]
        setLibraryData(testData)
        setCurrentLibrary("mao_zedong")
        print("✅ 测试数据设置完成")
    }
    
    // 测试数据逻辑
    func testDataLogic() {
        print("🧪 开始测试数据逻辑...")
        
        // 设置测试数据
        setTestData()
        
        // 测试数据获取
        let libraryId = getCurrentLibraryId()
        print("📚 当前答案库ID: \(libraryId)")
        
        // 测试随机答案获取
        for i in 1...5 {
            let answer = safeGetRandomAnswer()
            print("🎲 第\(i)次随机答案: \(answer.text) (来源: \(answer.libraryName))")
        }
        
        // 测试缓存机制
        let startTime = Date()
        let _ = getLibraryData()
        let cacheTime = Date().timeIntervalSince(startTime)
        print("⚡ 缓存获取时间: \(cacheTime * 1000)ms")
        
        // 测试数据更新
        let updateTime = shouldUpdateData()
        print("🔄 需要更新数据: \(updateTime)")
        
        print("✅ 数据逻辑测试完成")
    }
    
    // 测试UI布局
    func testUILayout() {
        print("🎨 开始测试UI布局...")
        
        // 设置测试数据
        setTestData()
        
        // 测试不同长度的答案
        let testAnswers = [
            "为人民服务",
            "实事求是是马克思主义的根本观点",
            "自力更生，艰苦奋斗是我们党的优良传统",
            "团结就是力量，这力量是铁，这力量是钢",
            "好好学习，天天向上，这是我们的座右铭"
        ]
        
        for (index, answer) in testAnswers.enumerated() {
            print("📱 测试答案\(index + 1): \(answer)")
            print("   - 长度: \(answer.count)字符")
            print("   - 适合小尺寸: \(answer.count <= 20)")
            print("   - 适合中等尺寸: \(answer.count <= 50)")
            print("   - 适合大尺寸: \(answer.count <= 100)")
        }
        
        print("✅ UI布局测试完成")
    }
    
    // 性能监控
    func getPerformanceMetrics() -> [String: TimeInterval] {
        return performanceMetrics
    }
    
    // 重置性能指标
    func resetPerformanceMetrics() {
        performanceMetrics.removeAll()
    }
    
    // 监控数据获取性能
    func getLibraryDataWithMetrics() -> [String: Any]? {
        let monitor = PeaceWidgetPerformanceMonitor.shared
        monitor.startMonitoring("getLibraryData")
        
        let result = getLibraryData()
        
        monitor.endMonitoring("getLibraryData")
        
        return result
    }
    
    // 智能更新策略
    func getSmartUpdateInterval(for family: WidgetFamily) -> TimeInterval {
        switch family {
        case .systemSmall:
            return 30 // 小尺寸Widget更新频率较低
        case .systemMedium:
            return 15 // 中等尺寸Widget中等更新频率
        case .systemLarge:
            return 10 // 大尺寸Widget更新频率较高
        default:
            return 15
        }
    }
    
    // 检查内存使用情况
    func checkMemoryUsage() {
        var memoryInfo = mach_task_basic_info()
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
            print("💾 内存使用: \(memoryUsage / 1024 / 1024)MB")
        }
    }
    
    // 测试Timeline策略
    func testTimelineStrategy() {
        print("⏰ 开始测试Timeline策略...")
        
        // 设置测试数据
        setTestData()
        
        // 测试不同尺寸的更新频率
        let families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
        
        for family in families {
            let interval = getSmartUpdateInterval(for: family)
            print("📱 \(family) 更新频率: \(interval)秒")
        }
        
        // 测试性能指标
        let startTime = Date()
        let _ = getLibraryDataWithMetrics()
        let duration = Date().timeIntervalSince(startTime)
        print("⚡ 数据获取性能: \(duration * 1000)ms")
        
        // 检查内存使用
        checkMemoryUsage()
        
        // 测试缓存机制
        let cacheHit = !shouldUpdateData()
        print("💾 缓存命中: \(cacheHit)")
        
        print("✅ Timeline策略测试完成")
    }
    
    // 综合测试
    func runComprehensiveTest() {
        print("🚀 开始综合测试...")
        
        // 1. 数据逻辑测试
        testDataLogic()
        
        // 2. UI布局测试
        testUILayout()
        
        // 3. Timeline策略测试
        testTimelineStrategy()
        
        // 4. 性能测试
        runPerformanceTest()
        
        // 5. 错误处理测试
        runErrorHandlingTest()
        
        print("✅ 综合测试完成")
    }
    
    // 性能测试
    func runPerformanceTest() {
        print("⚡ 开始性能测试...")
        
        let monitor = PeaceWidgetPerformanceMonitor.shared
        monitor.resetMetrics()
        
        // 测试数据获取性能
        for _ in 0..<100 {
            let _ = getLibraryDataWithMetrics()
        }
        
        // 测试随机答案获取性能
        monitor.startMonitoring("getRandomAnswer")
        for _ in 0..<50 {
            let _ = safeGetRandomAnswer()
        }
        monitor.endMonitoring("getRandomAnswer")
        
        // 检查性能是否达标
        let performancePassed = monitor.checkPerformanceThresholds()
        print("📊 性能测试结果: \(performancePassed ? "通过" : "不通过")")
        
        // 生成性能报告
        let report = monitor.generatePerformanceReport()
        print(report)
        
        // 检查内存使用
        checkMemoryUsage()
        
        print("✅ 性能测试完成")
    }
    
    // 错误处理测试
    func runErrorHandlingTest() {
        print("🛡️ 开始错误处理测试...")
        
        // 测试空数据情况
        clearCache()
        let emptyAnswer = safeGetRandomAnswer()
        if emptyAnswer.text == "无法获取答案" {
            print("✅ 空数据测试通过")
        } else {
            print("❌ 空数据测试失败")
        }
        
        // 测试无效数据情况
        let invalidData: [String: Any] = ["id": "invalid", "name": "无效库"]
        setLibraryData(invalidData)
        let invalidAnswer = safeGetRandomAnswer()
        if invalidAnswer.text == "无法获取答案" {
            print("✅ 无效数据测试通过")
        } else {
            print("❌ 无效数据测试失败")
        }
        
        // 恢复测试数据
        setTestData()
        
        print("✅ 错误处理测试完成")
    }
    
    // 清理缓存数据
    func clearCache() {
        cachedLibraryData = nil
        lastUpdateTime = nil
    }
    
    // 检查是否需要更新数据
    func shouldUpdateData() -> Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        return Date().timeIntervalSince(lastUpdate) > 300 // 5分钟
    }
    
    // 安全获取数据
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
    
    // 安全获取随机答案
    func safeGetRandomAnswer() -> (text: String, libraryName: String) {
        do {
            let data = try safeGetLibraryData()
            let answers = data["answers"] as! [String]
            let timeInterval = Date().timeIntervalSince1970
            let seed = Int(timeInterval * 10) % answers.count
            let selectedAnswer = answers[seed]
            let libraryName = data["name"] as? String ?? "未知库"
            
            return (selectedAnswer, libraryName)
        } catch {
            print("获取随机答案失败: \(error)")
            return ("请先在主应用中选择答案库", "等待数据")
        }
    }
}

// 错误类型定义
enum WidgetError: Error {
    case dataNotFound
    case invalidData
    case networkError
    case permissionDenied
}
