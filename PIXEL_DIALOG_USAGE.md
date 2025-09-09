# 像素风格弹窗组件使用指南

## 📱 组件介绍

已创建统一的像素风格弹窗组件 `PixelDialog`，完全符合App的主体设计风格。

## 🎨 设计特色

- **像素风格边框**: 3px黑色边框，圆角设计
- **像素网格背景**: 使用CustomPainter绘制像素点图案
- **VT323字体**: 保持复古像素字体风格
- **阴影效果**: 6px偏移的立体阴影
- **自动关闭**: 默认1秒后自动消失

## 🔧 组件文件

```
lib/components/pixel_dialog.dart
```

## 📋 使用方法

### 1. 基础弹窗 - PixelDialog

```dart
// 导入组件
import 'components/pixel_dialog.dart';

// 显示基础信息弹窗
PixelDialog.show(context, '这是一个提示消息');

// 自定义显示时长
PixelDialog.show(
  context, 
  '这是一个提示消息',
  duration: Duration(seconds: 2),
);
```

### 2. 扩展弹窗 - PixelDialogExtended

```dart
// 成功提示
PixelDialogExtended.show(
  context,
  '操作成功完成',
  type: PixelDialogType.success,
);

// 警告提示
PixelDialogExtended.show(
  context,
  '请注意相关事项',
  type: PixelDialogType.warning,
);

// 错误提示
PixelDialogExtended.show(
  context,
  '操作失败，请重试',
  type: PixelDialogType.error,
);

// 信息提示
PixelDialogExtended.show(
  context,
  '这是一般信息',
  type: PixelDialogType.info,
);
```

## 🎯 弹窗类型

| 类型 | 图标 | 颜色 | 用途 |
|------|------|------|------|
| `PixelDialogType.success` | ✅ | 绿色 | 操作成功 |
| `PixelDialogType.warning` | ⚠️ | 橙色 | 警告提示 |
| `PixelDialogType.error` | ❌ | 红色 | 错误信息 |
| `PixelDialogType.info` | ℹ️ | 黑色 | 一般信息 |

## 📄 已替换的页面

### 设置页面 (settings_page.dart)
- ✅ "关于我们" → 基础弹窗
- ✅ "隐私政策" → 基础弹窗  
- ✅ "分享功能不可用" → 警告弹窗
- ✅ "无法打开App Store" → 警告弹窗
- ✅ "跳转失败" → 错误弹窗

### 答案库页面 (answer_library_page.dart)
- ✅ "已切换到毛泽东语录" → 成功弹窗
- ✅ "已切换到其他答案库" → 成功弹窗

## 🎪 弹窗特性

### 视觉效果
- **居中显示**: 在屏幕中央显示
- **半透明背景**: 30%透明度的黑色遮罩
- **像素图案**: 细密的像素网格背景
- **立体边框**: 3D像素风格边框效果

### 交互体验
- **自动关闭**: 1秒后自动消失
- **防误触**: 显示期间无法点击背景关闭
- **平滑动画**: 使用Material Design动画
- **响应式布局**: 适配不同屏幕尺寸

### 技术实现
- **自定义绘制**: 使用CustomPainter绘制背景图案
- **Material组件**: 基于Flutter Material组件
- **类型安全**: 使用枚举定义弹窗类型
- **内存安全**: 自动检查context.mounted状态

## 🚀 使用示例

```dart
// 在任何需要提示的地方使用
void _showSuccess() {
  PixelDialogExtended.show(
    context,
    '设置保存成功！',
    type: PixelDialogType.success,
  );
}

void _showError() {
  PixelDialogExtended.show(
    context,
    '网络连接失败\n请检查网络设置',
    type: PixelDialogType.error,
  );
}
```

## ⚙️ 自定义配置

如需修改默认配置，可在 `pixel_dialog.dart` 中调整：

- **显示时长**: 修改 `duration` 参数
- **弹窗大小**: 调整 `maxWidth` 和 `minHeight`
- **颜色主题**: 修改各类型的颜色值
- **动画效果**: 调整 `barrierColor` 透明度

## 📱 效果预览

现在所有的提示消息都使用统一的像素风格弹窗，提供一致的用户体验：

- 🎯 **视觉统一**: 与App主体风格完全一致
- ⏱️ **时间合适**: 1秒显示时间，不干扰用户操作
- 🎨 **美观实用**: 既美观又实用的提示方式
- 📱 **移动优化**: 专为移动设备优化的显示效果

所有弹窗现在都具有统一的像素风格，提升了App的整体视觉体验！🎉
