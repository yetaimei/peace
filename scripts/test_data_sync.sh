#!/bin/bash

echo "🔄 测试数据同步功能..."

# 确保Flutter项目依赖已安装
echo "📦 运行 Flutter pub get..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Flutter pub get 失败。"
    exit 1
fi

# 运行pod install
echo "🍎 运行 pod install..."
(cd ios && pod install)
if [ $? -ne 0 ]; then
    echo "❌ pod install 失败。"
    exit 1
fi

# 清理构建
echo "🧹 清理构建..."
xcodebuild clean -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug
if [ $? -ne 0 ]; then
    echo "❌ Xcode clean 失败。"
    exit 1
fi

# 构建项目
echo "🔨 构建项目..."
xcodebuild build -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
if [ $? -ne 0 ]; then
    echo "❌ Xcode build 失败。"
    exit 1
fi

echo "✅ 数据同步测试准备完成！"
echo "📱 请在模拟器中："
echo "1. 启动主应用"
echo "2. 在设置页面切换不同的答案库"
echo "3. 观察小组件是否显示对应的数据"
echo "4. 检查控制台日志中的同步信息"
