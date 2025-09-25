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
        
        // 清除缓存，强制重新加载数据
        cachedLibraryData = nil
        lastUpdateTime = nil
        
        print("🔄 切换答案库到: \(libraryId)")
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
        // 将数据转换为JSON字符串存储，与读取方式保持一致
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            userDefaults?.set(jsonString, forKey: "library_data")
            userDefaults?.set(Date(), forKey: "last_update_time")
            cachedLibraryData = data
            lastUpdateTime = Date()
            
            print("🔄 数据已转换为JSON存储: \(data["name"] ?? "未知库")")
            
            // 通知Widget更新
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("❌ JSON转换失败: \(error)")
        }
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
        // 清除缓存，强制重新加载
        cachedLibraryData = nil
        lastUpdateTime = nil
        
        loadCachedData()
        print("🔄 手动刷新数据完成")
        WidgetCenter.shared.reloadAllTimelines()
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
