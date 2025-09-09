# Flutter iOS 相册权限开发规范

## 🎯 核心原则

### 1. 按需请求权限
- **禁止**应用启动时预先请求权限
- **必须**在用户明确需要保存功能时才请求
- **遵循**最小权限原则，只申请必要的权限

### 2. 使用插件内置权限处理
- **优先**使用 `image_gallery_saver` 等成熟插件的内置权限管理
- **避免**手动实现复杂的权限检查逻辑
- **禁止**使用 `permission_handler` 进行手动权限管理（除非特殊需求）

## 📋 标准实现流程

### 第一步：权限配置
在 `ios/Runner/Info.plist` 中添加必要权限说明：

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>我们需要访问您的相册，以便将图片保存到您的设备中。</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>我们需要访问您的相册，以便将图片保存到您的设备中。</string>
```

**规则**：
- 必须提供清晰、友好的权限说明
- 说明必须解释为什么需要这个权限
- 同时配置读写权限以确保最大兼容性

### 第二步：依赖选择
在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  image_gallery_saver: ^2.0.3  # 主要保存插件
  # 不需要 permission_handler
```

**规则**：
- 优先选择专业的图片保存插件
- 避免引入额外的权限管理依赖
- 让插件自动处理权限逻辑

### 第三步：代码实现
```dart
/// 保存图片到相册的标准实现
Future<void> _saveImageToGallery(Uint8List imageData) async {
  try {
    // 插件会自动处理权限请求
    final result = await ImageGallerySaver.saveImage(
      imageData,
      quality: 100,
      name: 'app_image_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    if (result['isSuccess'] == true) {
      _showSuccessMessage('图片已保存到相册');
    } else {
      _showPermissionHint('保存失败，请检查相册权限');
    }
  } catch (e) {
    _showErrorMessage('保存图片时发生错误');
    LoggerService.error('保存图片异常', null, e);
  }
}

/// 用户操作触发的保存流程
void _onSaveButtonPressed() async {
  // 1. 用户明确操作触发
  LoggerService.userAction('用户点击保存图片');
  
  // 2. 显示加载状态
  _showLoadingMessage('正在保存图片...');
  
  // 3. 获取图片数据
  final imageData = await _captureImage();
  
  // 4. 调用保存方法（权限由插件处理）
  await _saveImageToGallery(imageData);
}
```

## ✅ 最佳实践

### 用户体验设计
1. **按需触发**：只在用户点击保存按钮时请求权限
2. **清晰反馈**：提供明确的成功/失败提示
3. **友好引导**：权限被拒绝时给予合理建议

### 代码设计原则
1. **简洁性**：避免复杂的权限状态管理
2. **可靠性**：使用成熟插件的内置功能
3. **可维护性**：减少自定义权限逻辑

### 错误处理策略
1. **成功**：绿色提示，确认保存位置
2. **权限拒绝**：橙色提示，建议检查设置
3. **系统错误**：红色提示，建议重试

## ❌ 避免的反模式

### 不要预先请求权限
```dart
// ❌ 错误做法
void initState() {
  super.initState();
  _requestPhotoPermission(); // 应用启动就请求权限
}

// ✅ 正确做法
void _onSavePressed() {
  _saveImageToGallery(imageData); // 按需请求
}
```

### 不要手动管理权限状态
```dart
// ❌ 错误做法
Future<bool> _checkPermission() async {
  final status = await Permission.photos.status;
  if (!status.isGranted) {
    final result = await Permission.photos.request();
    return result.isGranted;
  }
  return true;
}

// ✅ 正确做法
Future<void> _saveImage() async {
  // 让插件自动处理权限
  final result = await ImageGallerySaver.saveImage(imageData);
}
```

### 不要复杂的权限状态判断
```dart
// ❌ 错误做法
if (status.isPermanentlyDenied) {
  _showSettingsDialog();
} else if (status.isDenied) {
  _showPermissionDialog();
} else if (status.isRestricted) {
  _showRestrictedDialog();
}

// ✅ 正确做法
if (result['isSuccess'] != true) {
  _showSimplePermissionHint();
}
```

## 🔍 调试指南

### 日志记录规范
```dart
// 用户行为日志
LoggerService.userAction('用户点击保存图片');

// 业务流程日志
LoggerService.info('图片保存服务-开始保存-平台:${Platform.operatingSystem}');

// 错误日志
LoggerService.error('保存图片异常', null, e);
```

### 权限调试步骤
1. **删除应用**：完全重新安装测试权限流程
2. **检查配置**：确认 Info.plist 权限说明正确
3. **查看日志**：观察插件权限请求过程
4. **测试场景**：允许/拒绝/重试各种情况

## 📱 测试检查清单

### 功能测试
- [ ] 首次使用弹出系统权限对话框
- [ ] 用户允许权限后保存成功
- [ ] 用户拒绝权限后显示合理提示
- [ ] 权限被拒绝后用户可以重试
- [ ] 图片成功保存到系统相册

### 用户体验测试
- [ ] 权限请求时机合理（按需请求）
- [ ] 权限说明文字清晰友好
- [ ] 成功/失败提示明确
- [ ] 不会频繁打扰用户

### 技术实现测试
- [ ] 代码简洁，无复杂权限逻辑
- [ ] 使用插件内置权限处理
- [ ] 日志记录完整清晰
- [ ] 错误处理健壮

## 🎯 开发总结

遵循这些规范可以确保：
1. **用户体验优秀**：按需请求，友好提示
2. **代码简洁可维护**：避免复杂的权限管理
3. **功能稳定可靠**：使用成熟插件的内置功能
4. **符合平台规范**：遵循iOS App Store审核标准

记住：**简单就是美，让插件处理权限，专注于核心业务逻辑。**
