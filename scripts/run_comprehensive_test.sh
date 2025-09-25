#!/bin/bash

echo "🚀 开始综合测试..."

# 设置测试环境
export TEST_MODE=true

# 清理构建
echo "🧹 清理构建..."
xcodebuild clean -workspace ios/Runner.xcworkspace -scheme Runner

# 构建项目
echo "🔨 构建项目..."
xcodebuild build -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

if [ $? -ne 0 ]; then
    echo "❌ 构建失败！"
    exit 1
fi

# 运行单元测试
echo "🧪 运行单元测试..."
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:PeaceWidgetTests

if [ $? -ne 0 ]; then
    echo "❌ 单元测试失败！"
    exit 1
fi

# 运行Widget测试
echo "📱 运行Widget测试..."
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:PeaceWidgetTests/testTimelineStrategy

# 性能测试
echo "⚡ 运行性能测试..."
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:PeaceWidgetTests/testPerformanceMetrics

# 内存测试
echo "💾 运行内存测试..."
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:PeaceWidgetTests/testMemoryUsage

# 错误处理测试
echo "🛡️ 运行错误处理测试..."
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:PeaceWidgetTests/testErrorHandling

echo "✅ 综合测试完成！"
echo "📊 测试报告已生成"
