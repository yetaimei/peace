# 任务7：部署和配置

## 📋 任务概述
完成小组件的最终部署和配置，包括权限设置、资源管理、发布准备等。

## 🎯 目标
- 完成权限配置
- 资源文件管理
- 发布准备
- 文档完善

## 📁 涉及文件
- 所有Widget相关文件
- 配置文件
- 资源文件

## 🔧 具体实现步骤

### 步骤1：完善权限配置
更新 `ios/peaceWidgetExtension.entitlements`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.peace.widget</string>
    </array>
    <key>com.apple.developer.widgetkit</key>
    <true/>
</dict>
</plist>
```

### 步骤2：配置Widget Bundle
更新 `ios/PeaceWidget/PeaceWidgetBundle.swift`：

```swift
import WidgetKit
import SwiftUI

@main
struct PeaceWidgetBundle: WidgetBundle {
    var body: some Widget {
        PeaceWidget()
        PeaceWidgetControl()
        PeaceWidgetLiveActivity()
    }
}
```

### 步骤3：完善AppIntent配置
更新 `ios/PeaceWidget/AppIntent.swift`：

```swift
import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Peace小组件配置" }
    static var description: IntentDescription { "配置Peace小组件的显示选项" }

    @Parameter(title: "显示答案库名称", default: true)
    var showLibraryName: Bool
    
    @Parameter(title: "显示日期", default: true)
    var showDate: Bool
    
    @Parameter(title: "更新频率", default: 10)
    var updateInterval: Int
}
```

### 步骤4：资源文件管理
创建 `ios/PeaceWidget/Assets.xcassets` 并添加：

```json
{
  "info": {
    "author": "xcode",
    "version": 1
  },
  "properties": {
    "provides-namespace": true
  }
}
```

### 步骤5：创建配置文件
创建 `ios/PeaceWidget/Info.plist`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>Peace小组件</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
```

### 步骤6：创建部署脚本
创建 `scripts/deploy_widget.sh`：

```bash
#!/bin/bash

echo "🚀 开始部署小组件..."

# 检查环境
echo "🔍 检查环境..."
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode未安装或未配置"
    exit 1
fi

# 清理项目
echo "🧹 清理项目..."
xcodebuild clean -workspace ios/Runner.xcworkspace -scheme Runner

# 构建项目
echo "🔨 构建项目..."
xcodebuild build -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# 检查构建结果
if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
else
    echo "❌ 构建失败！"
    exit 1
fi

# 运行测试
echo "🧪 运行测试..."
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# 检查测试结果
if [ $? -eq 0 ]; then
    echo "✅ 测试通过！"
else
    echo "❌ 测试失败！"
    exit 1
fi

echo "🎉 部署完成！"
```

### 步骤7：创建文档
创建 `doc/小组件使用指南.md`：

```markdown
# Peace小组件使用指南

## 功能介绍
Peace小组件是一个iOS桌面小组件，用于显示每日精选的答案内容。

## 主要功能
- 显示当前日期
- 随机展示答案库内容
- 支持多种答案库
- 自动更新内容

## 使用方法
1. 长按桌面空白处
2. 点击左上角的"+"按钮
3. 搜索"Peace"
4. 选择小组件尺寸
5. 添加到桌面

## 配置选项
- 显示答案库名称
- 显示日期
- 更新频率设置

## 注意事项
- 需要iOS 14.0或更高版本
- 需要主应用已安装
- 支持多种尺寸显示
```

## ✅ 验收标准
- [ ] 权限配置正确
- [ ] 资源文件完整
- [ ] 配置文件正确
- [ ] 部署脚本可用
- [ ] 文档完善

## 🔍 测试方法
1. 检查权限配置
2. 验证资源文件
3. 测试部署脚本
4. 检查文档完整性

## ⚠️ 注意事项
- 确保所有权限配置正确
- 检查资源文件路径
- 验证配置文件格式
- 测试部署流程
