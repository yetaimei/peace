# App Store 跳转配置指南

## 📱 当前实现

现在点击"检查新版本"会直接跳转到App Store，目前使用的是示例链接。

## 🔧 配置你的App Store链接

### 1. 获取你的App ID

当你将应用上传到App Store Connect后，会获得一个唯一的App ID，例如：`123456789`

### 2. 修改代码中的App Store链接

在 `lib/settings_page.dart` 文件中找到 `_openAppStore` 方法，修改以下代码：

```dart
// 当前的示例链接
const String appStoreUrl = 'https://apps.apple.com/cn/app/apple-store/id375380948';

// 替换为你的实际App ID
const String appStoreUrl = 'https://apps.apple.com/cn/app/peace/id[你的App ID]';
```

### 3. App Store链接格式

- **标准格式**: `https://apps.apple.com/cn/app/[app-name]/id[app-id]`
- **简化格式**: `https://apps.apple.com/app/id[app-id]`
- **iTunes格式**: `itms-apps://apps.apple.com/app/id[app-id]`

### 4. 示例配置

假设你的App ID是 `123456789`，应用名称是 `peace`：

```dart
const String appStoreUrl = 'https://apps.apple.com/cn/app/peace/id123456789';
```

## 🚀 测试跳转功能

### 在模拟器中测试
- 点击"检查新版本"
- 应该会打开Safari浏览器
- 跳转到App Store页面

### 在真机中测试
- 点击"检查新版本"
- 应该会直接打开App Store应用
- 跳转到你的应用页面

## 📋 iOS配置要求

已自动添加到 `ios/Runner/Info.plist` 中：

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>https</string>
    <string>http</string>
    <string>itms-apps</string>
</array>
```

## ⚠️ 注意事项

1. **应用上架前**: 使用示例链接或显示"即将上线"消息
2. **应用上架后**: 替换为实际的App Store链接
3. **测试环境**: 可以跳转到其他已上架的应用进行测试

## 🔄 动态配置建议

你也可以考虑从服务器获取App Store链接，这样可以动态更新：

```dart
// 从远程服务器获取链接
String appStoreUrl = await getAppStoreUrlFromServer();
// 或者使用默认链接
String appStoreUrl = 'https://apps.apple.com/cn/app/peace/id123456789';
```

## 📞 当前状态

- ✅ **依赖已添加**: `url_launcher: ^6.3.1`
- ✅ **iOS权限已配置**: `LSApplicationQueriesSchemes`
- ✅ **异常处理已实现**: 跳转失败时显示友好提示
- ✅ **构建成功**: 可以在模拟器和真机测试

现在点击"检查新版本"就会跳转到App Store了！🎉
