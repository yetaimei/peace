//
//  PeaceWidgetPerformanceMonitor.swift
//  PeaceWidget
//
//  Created by 雷雷 on 2025/9/25.
//

import Foundation
import WidgetKit

class PeaceWidgetPerformanceMonitor {
    static let shared = PeaceWidgetPerformanceMonitor()
    
    private var metrics: [String: [TimeInterval]] = [:]
    private var startTimes: [String: Date] = [:]
    
    private init() {}
    
    // 开始监控
    func startMonitoring(_ operation: String) {
        startTimes[operation] = Date()
    }
    
    // 结束监控
    func endMonitoring(_ operation: String) {
        guard let startTime = startTimes[operation] else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        
        if metrics[operation] == nil {
            metrics[operation] = []
        }
        metrics[operation]?.append(duration)
        
        startTimes.removeValue(forKey: operation)
        
        print("📊 \(operation) 耗时: \(duration * 1000)ms")
    }
    
    // 获取性能报告
    func getPerformanceReport() -> [String: Any] {
        var report: [String: Any] = [:]
        
        for (operation, times) in metrics {
            let average = times.reduce(0, +) / Double(times.count)
            let min = times.min() ?? 0
            let max = times.max() ?? 0
            
            report[operation] = [
                "count": times.count,
                "average": average * 1000, // 转换为毫秒
                "min": min * 1000,
                "max": max * 1000
            ]
        }
        
        return report
    }
    
    // 重置指标
    func resetMetrics() {
        metrics.removeAll()
        startTimes.removeAll()
    }
    
    // 检查性能是否达标
    func checkPerformanceThresholds() -> Bool {
        let report = getPerformanceReport()
        var allPassed = true
        
        for (operation, data) in report {
            if let metrics = data as? [String: Double] {
                let average = metrics["average"] ?? 0
                
                // 设置性能阈值
                let threshold: Double
                switch operation {
                case "getLibraryData":
                    threshold = 10 // 10ms
                case "getRandomAnswer":
                    threshold = 5 // 5ms
                default:
                    threshold = 20 // 20ms
                }
                
                if average > threshold {
                    print("⚠️ \(operation) 性能不达标: \(average)ms > \(threshold)ms")
                    allPassed = false
                } else {
                    print("✅ \(operation) 性能达标: \(average)ms <= \(threshold)ms")
                }
            }
        }
        
        return allPassed
    }
    
    // 生成性能报告
    func generatePerformanceReport() -> String {
        let report = getPerformanceReport()
        var reportString = "📊 性能报告\n"
        reportString += "==================\n"
        
        for (operation, data) in report {
            if let metrics = data as? [String: Double] {
                reportString += "🔧 \(operation):\n"
                reportString += "   次数: \(Int(metrics["count"] ?? 0))\n"
                reportString += "   平均: \(String(format: "%.2f", metrics["average"] ?? 0))ms\n"
                reportString += "   最小: \(String(format: "%.2f", metrics["min"] ?? 0))ms\n"
                reportString += "   最大: \(String(format: "%.2f", metrics["max"] ?? 0))ms\n"
                reportString += "\n"
            }
        }
        
        return reportString
    }
}
