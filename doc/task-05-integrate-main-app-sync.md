# 任务5：集成主应用数据同步

## 📋 任务概述
实现主应用和Widget之间的数据同步机制，确保用户在设置页面修改答案库后，Widget能够实时更新。

## 🎯 目标
- 实现主应用到Widget的数据同步
- 处理数据格式转换
- 实现实时更新机制
- 处理数据冲突和错误情况

## 📁 涉及文件
- `lib/services/answer_library_service.dart` - 主应用服务
- `ios/Runner/AppDelegate.swift` - iOS原生桥接
- `ios/PeaceWidget/PeaceWidgetDataManager.swift` - Widget数据管理

## 🔧 具体实现步骤

### 步骤1：创建Method Channel桥接
在 `ios/Runner/AppDelegate.swift` 中添加：

```swift
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // 创建Method Channel
        let channel = FlutterMethodChannel(
            name: "com.peace.widget/sync",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "syncLibraryData":
                self.syncLibraryData(call: call, result: result)
            case "getCurrentLibraryId":
                self.getCurrentLibraryId(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func syncLibraryData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        let userDefaults = UserDefaults(suiteName: "group.com.peace.widget")
        userDefaults?.set(args, forKey: "library_data")
        userDefaults?.set(Date(), forKey: "last_update_time")
        
        // 通知Widget更新
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        result(nil)
    }
    
    private func getCurrentLibraryId(result: @escaping FlutterResult) {
        let userDefaults = UserDefaults(suiteName: "group.com.peace.widget")
        let libraryId = userDefaults?.string(forKey: "current_answer_library") ?? "mao_zedong"
        result(libraryId)
    }
}
```

### 步骤2：修改Flutter服务
更新 `lib/services/answer_library_service.dart`：

```dart
import 'package:flutter/services.dart';

class AnswerLibraryService {
  static const MethodChannel _channel = MethodChannel('com.peace.widget/sync');
  
  // 现有代码...
  
  /// 同步数据到Widget
  static Future<void> syncToWidget() async {
    try {
      final library = await getCurrentLibrary();
      if (library != null) {
        final libraryData = {
          'id': library.id,
          'name': library.name,
          'description': library.description,
          'answers': library.answers,
          'author': library.author,
          'category': library.category,
        };
        
        await _channel.invokeMethod('syncLibraryData', libraryData);
        LoggerService.info('数据已同步到Widget', 'WIDGET_SYNC');
      }
    } catch (e) {
      LoggerService.error('同步数据到Widget失败: $e', 'WIDGET_SYNC_ERROR');
    }
  }
  
  /// 设置当前答案库（重写方法）
  static Future<void> setCurrentLibrary(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentLibraryKey, libraryId);
    
    // 同步到Widget
    await syncToWidget();
    
    LoggerService.info('切换答案库: $libraryId', 'ANSWER_LIBRARY');
  }
  
  /// 添加自定义答案库（重写方法）
  static Future<void> addCustomLibrary(AnswerLibrary library) async {
    final prefs = await SharedPreferences.getInstance();
    final customLibrariesJson = prefs.getStringList(_customLibrariesKey) ?? [];
    
    customLibrariesJson.add(jsonEncode(_libraryToJson(library)));
    await prefs.setStringList(_customLibrariesKey, customLibrariesJson);
    
    // 同步到Widget
    await syncToWidget();
    
    LoggerService.info('添加自定义答案库: ${library.name} (${library.answers.length}条答案)', 'ANSWER_LIBRARY');
  }
}
```

### 步骤3：实现数据格式转换
添加数据格式转换方法：

```dart
class AnswerLibraryService {
  // 现有代码...
  
  /// 将答案库转换为Widget格式
  static Map<String, dynamic> _libraryToWidgetFormat(AnswerLibrary library) {
    return {
      'id': library.id,
      'name': library.name,
      'description': library.description,
      'answers': library.answers,
      'author': library.author,
      'category': library.category,
      'source': library.source.name,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
  
  /// 从Widget格式解析答案库
  static AnswerLibrary _libraryFromWidgetFormat(Map<String, dynamic> data) {
    return AnswerLibrary(
      id: data['id'] ?? 'unknown',
      name: data['name'] ?? '未知库',
      description: data['description'] ?? '',
      answers: List<String>.from(data['answers'] ?? []),
      author: data['author'],
      category: data['category'],
      source: AnswerLibrarySource.imported,
    );
  }
}
```

### 步骤4：实现实时同步机制
添加实时同步逻辑：

```dart
class AnswerLibraryService {
  // 现有代码...
  
  /// 初始化Widget同步
  static Future<void> initializeWidgetSync() async {
    try {
      // 获取当前答案库
      final library = await getCurrentLibrary();
      if (library != null) {
        await syncToWidget();
      }
      
      // 设置定期同步
      Timer.periodic(Duration(minutes: 5), (timer) async {
        await syncToWidget();
      });
      
      LoggerService.info('Widget同步已初始化', 'WIDGET_SYNC');
    } catch (e) {
      LoggerService.error('初始化Widget同步失败: $e', 'WIDGET_SYNC_ERROR');
    }
  }
  
  /// 强制同步到Widget
  static Future<void> forceSyncToWidget() async {
    try {
      final library = await getCurrentLibrary();
      if (library != null) {
        final libraryData = _libraryToWidgetFormat(library);
        await _channel.invokeMethod('syncLibraryData', libraryData);
        LoggerService.info('强制同步到Widget完成', 'WIDGET_SYNC');
      }
    } catch (e) {
      LoggerService.error('强制同步到Widget失败: $e', 'WIDGET_SYNC_ERROR');
    }
  }
}
```

### 步骤5：在主应用中初始化同步
在 `lib/main.dart` 中初始化：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Widget同步
  await AnswerLibraryService.initializeWidgetSync();
  
  runApp(MyApp());
}
```

## ✅ 验收标准
- [ ] Method Channel桥接正常工作
- [ ] 数据格式转换正确
- [ ] 实时同步机制有效
- [ ] 错误处理完善
- [ ] 性能优化到位

## 🔍 测试方法
1. 在主应用中切换答案库
2. 检查Widget是否实时更新
3. 测试网络异常情况
4. 验证数据格式正确性

## ⚠️ 注意事项
- 确保Method Channel名称一致
- 处理异步操作异常
- 避免频繁的数据同步
- 考虑电池消耗影响
