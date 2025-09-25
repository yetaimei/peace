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
