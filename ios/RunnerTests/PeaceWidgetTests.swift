//
//  PeaceWidgetTests.swift
//  RunnerTests
//
//  Created by 雷雷 on 2025/9/25.
//

import XCTest
@testable import Runner

class PeaceWidgetTests: XCTestCase {
    
    func testWidgetDataManager() {
        // 测试数据管理类的基本功能
        let dataManager = PeaceWidgetDataManager.shared
        
        // 测试初始化
        XCTAssertNotNil(dataManager)
        
        // 测试获取当前答案库ID
        let libraryId = dataManager.getCurrentLibraryId()
        XCTAssertNotNil(libraryId)
        XCTAssertFalse(libraryId.isEmpty)
    }
    
    func testWidgetDataOperations() {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 设置测试数据
        let testData = [
            "id": "test_library",
            "name": "测试库",
            "answers": ["答案1", "答案2", "答案3"]
        ]
        
        dataManager.setLibraryData(testData)
        
        // 验证数据设置
        let retrievedData = dataManager.getLibraryData()
        XCTAssertNotNil(retrievedData)
        XCTAssertEqual(retrievedData?["id"] as? String, "test_library")
    }
    
    func testRandomAnswerGeneration() {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 设置测试数据
        let testData = [
            "id": "test_library",
            "name": "测试库",
            "answers": ["答案1", "答案2", "答案3"]
        ]
        
        dataManager.setLibraryData(testData)
        
        // 测试随机答案获取
        let answer = dataManager.safeGetRandomAnswer()
        XCTAssertNotNil(answer.text)
        XCTAssertFalse(answer.text.isEmpty)
        XCTAssertEqual(answer.libraryName, "测试库")
    }
    
    func testCacheMechanism() {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 设置测试数据
        let testData = [
            "id": "cache_test",
            "name": "缓存测试库",
            "answers": ["缓存答案1", "缓存答案2"]
        ]
        
        dataManager.setLibraryData(testData)
        
        // 测试缓存性能
        let startTime = Date()
        let _ = dataManager.getLibraryData()
        let cacheTime = Date().timeIntervalSince(startTime)
        
        // 缓存应该很快（小于10ms）
        XCTAssertLessThan(cacheTime, 0.01)
    }
    
    func testSmartUpdateInterval() {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 测试不同Widget尺寸的更新频率
        let smallInterval = dataManager.getSmartUpdateInterval(for: .systemSmall)
        let mediumInterval = dataManager.getSmartUpdateInterval(for: .systemMedium)
        let largeInterval = dataManager.getSmartUpdateInterval(for: .systemLarge)
        
        XCTAssertEqual(smallInterval, 30)
        XCTAssertEqual(mediumInterval, 15)
        XCTAssertEqual(largeInterval, 10)
    }
    
    func testErrorHandling() {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 清理缓存，测试空数据情况
        dataManager.clearCache()
        let emptyAnswer = dataManager.safeGetRandomAnswer()
        
        XCTAssertEqual(emptyAnswer.text, "无法获取答案")
        XCTAssertEqual(emptyAnswer.libraryName, "错误")
    }
    
    func testPerformanceMetrics() {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 重置性能指标
        dataManager.resetPerformanceMetrics()
        
        // 执行一些操作来生成指标
        dataManager.setTestData()
        let _ = dataManager.getLibraryDataWithMetrics()
        
        // 验证性能指标被记录
        let metrics = dataManager.getPerformanceMetrics()
        XCTAssertNotNil(metrics["getLibraryData"])
    }
    
    func testMemoryUsage() {
        let dataManager = PeaceWidgetDataManager.shared
        
        // 测试内存使用检查不会崩溃
        dataManager.checkMemoryUsage()
    }
}
