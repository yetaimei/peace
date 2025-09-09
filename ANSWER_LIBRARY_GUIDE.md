# 答案库系统使用指南

## 概述

答案库系统允许用户轻松切换不同的答案集合，包括预设答案库和自定义答案库。

## 预设答案库

系统内置了以下预设答案库：

### 1. 经典答案库（默认）
- 包含是、否、也许等经典回答
- 适合一般性问题的回答
- 共20条答案

### 2. 毛泽东语录
- 收录了毛泽东主席的经典语录和哲理名言
- 分类包括：革命与斗争、学习与进步、人民与群众、战略与战术、人生与哲理等
- 共35条经典语录
- 适合寻求人生指导和革命精神的问题

### 3. 禅意答案
- 充满东方智慧的禅意回答
- 包含随缘、顺其自然、静待花开等禅意表达
- 共20条答案
- 适合寻求内心平静和哲学思考的问题

### 4. 正能量答案
- 充满鼓励和正能量的回答
- 包含"你一定可以的"、"相信自己"等鼓励性话语
- 共20条答案
- 适合需要鼓励和支持的问题

## 如何切换答案库

1. 打开应用，点击右上角的设置按钮
2. 在设置页面中，点击"答案库"选项
3. 在答案库列表中，选择你想要使用的答案库
4. 选中的答案库会显示绿色边框和勾选标记
5. 返回主页面后，获取的答案将来自你选择的答案库

## 自定义答案库

### 导入JSON文件

你可以通过JSON文件导入自定义答案库。JSON文件格式如下：

```json
{
  "id": "custom_wisdom",
  "name": "人生智慧语录",
  "description": "收集了各种人生智慧和哲理名言",
  "author": "智慧收集者",
  "category": "哲学",
  "answers": [
    "时间会证明一切",
    "相信过程，而非结果",
    "每个人都有自己的节奏",
    // ... 更多答案
  ]
}
```

### JSON字段说明

- `id`: 答案库的唯一标识符（必需）
- `name`: 答案库的名称（必需）
- `description`: 答案库的描述（必需）
- `answers`: 答案数组（必需）
- `author`: 作者名称（可选）
- `category`: 分类（可选）

### 导入方法

目前支持两种导入方式：

1. **从文件导入**：
   - 使用 `AnswerLibraryService.importFromJsonFile(filePath)` 方法
   - 传入JSON文件的完整路径

2. **从Assets导入**：
   - 将JSON文件放在 `assets/` 目录下
   - 使用 `AnswerLibraryService.importFromAsset('assets/your_file.json')` 方法

## 扩展建议

你可以创建各种类型的答案库，例如：

- **名人名言库**：收集各位名人的经典语录
- **电影台词库**：收集经典电影中的台词
- **诗词库**：收集古诗词中的名句
- **歌词库**：收集歌曲中的经典歌词
- **心理指导库**：收集心理学相关的建议
- **职场建议库**：收集职场相关的建议

## 注意事项

1. 每个答案库至少需要包含一条答案
2. 答案库ID必须唯一，避免与现有答案库冲突
3. 建议每个答案库包含10-50条答案，保持答案的多样性
4. 答案内容应该简短明了，便于快速阅读和理解

## 开发者接口

如果你是开发者，可以使用以下API：

```dart
// 获取当前答案库
final library = await AnswerLibraryService.getCurrentLibrary();

// 切换答案库
await AnswerLibraryService.setCurrentLibrary('mao_zedong');

// 获取随机答案
final answer = await AnswerLibraryService.getRandomAnswer();

// 获取所有答案库
final libraries = await AnswerLibraryService.getAllLibraries();

// 添加自定义答案库
await AnswerLibraryService.addCustomLibrary(customLibrary);
```

## 更新日志

- 2024-12-XX：初版发布，支持4个预设答案库
- 支持自定义答案库导入功能
- 答案库切换后自动保存选择
