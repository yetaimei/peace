# 任务1：设置App Groups数据共享机制

## 📋 任务概述
设置主应用和Widget扩展之间的数据共享机制，确保小组件能够访问用户在设置页面选择的答案库数据。

## 🎯 目标
- 配置App Groups容器
- 实现数据共享接口
- 确保数据同步机制正常工作

## 📁 涉及文件
- `ios/Runner/Runner.entitlements` - 主应用权限配置
- `ios/peaceWidgetExtension.entitlements` - Widget扩展权限配置
- `ios/PeaceWidget/PeaceWidgetDataManager.swift` - 新建数据管理类

## 🔧 具体实现步骤

### 步骤1：配置App Groups权限
1. **主应用权限配置**
   - 在 `ios/Runner/Runner.entitlements` 中添加：
   ```xml
   <key>com.apple.security.application-groups</key>
   <array>
       <string>group.com.peace.widget</string>
   </array>
   ```

2. **Widget扩展权限配置**
   - 在 `ios/peaceWidgetExtension.entitlements` 中添加：
   ```xml
   <key>com.apple.security.application-groups</key>
   <array>
       <string>group.com.peace.widget</string>
   </array>
   ```

### 步骤2：创建数据管理类
创建 `ios/PeaceWidget/PeaceWidgetDataManager.swift`：

```swift
import Foundation
import WidgetKit

class PeaceWidgetDataManager {
    static let shared = PeaceWidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.peace.widget")
    
    private init() {}
    
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
        return userDefaults?.dictionary(forKey: "library_data")
    }
    
    // 设置答案库数据
    func setLibraryData(_ data: [String: Any]) {
        userDefaults?.set(data, forKey: "library_data")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
```

### 步骤3：修改主应用数据同步
在 `lib/services/answer_library_service.dart` 中添加数据同步方法：

```dart
import 'package:shared_preferences/shared_preferences.dart';

class AnswerLibraryService {
  // 现有代码...
  
  /// 同步数据到Widget
  static Future<void> syncToWidget() async {
    final library = await getCurrentLibrary();
    if (library != null) {
      // 这里需要调用原生方法同步到App Groups
      // 具体实现需要创建Method Channel
    }
  }
}
```

## ✅ 验收标准
- [ ] App Groups权限配置正确
- [ ] 数据管理类创建完成
- [ ] 主应用能够写入共享数据
- [ ] Widget能够读取共享数据
- [ ] 数据同步机制正常工作

## 🔍 测试方法
1. 在主应用中切换答案库
2. 检查Widget是否同步更新
3. 验证数据持久化存储

## ⚠️ 注意事项
- App Groups ID必须与Bundle ID相关
- 确保权限配置在正确的target中
- 数据同步需要考虑性能影响
