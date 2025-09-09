# Apple ID 配置指南

## 📱 应用信息
- **应用名称**: Peace - 答案之书
- **Bundle Identifier**: `com.leilei.peace`
- **Apple ID**: 6752237394

## 🔧 Xcode 配置步骤

### 1. 打开项目
```bash
open ios/Runner.xcworkspace
```

### 2. 配置签名
1. 在 Xcode 中选择 `Runner` 项目
2. 选择 `Signing & Capabilities` 标签
3. 取消选中 `Automatically manage signing`
4. 在 `Team` 下拉菜单中选择你的开发者账户
5. 确认 `Bundle Identifier` 为 `com.leilei.peace`

### 3. 添加 Apple ID 账户（如果还没有）
1. 打开 Xcode → Preferences → Accounts
2. 点击 `+` 号添加账户
3. 选择 `Apple ID`
4. 输入你的 Apple ID: `6752237394@qq.com` 或相应邮箱
5. 输入密码并完成验证

### 4. 创建 App ID（在 Apple Developer 网站）
1. 登录 [Apple Developer](https://developer.apple.com/)
2. 进入 `Certificates, Identifiers & Profiles`
3. 选择 `Identifiers`
4. 点击 `+` 创建新的 App ID
5. 选择 `App IDs`
6. 填写信息：
   - **Description**: Peace Answers Book
   - **Bundle ID**: `com.leilei.peace`
   - **Capabilities**: 根据需要选择（建议选择 App Groups, Push Notifications 等）

### 5. 配置证书和描述文件
1. 在 Apple Developer 网站创建开发证书
2. 创建开发描述文件（Provisioning Profile）
3. 下载并安装到 Xcode

## 🚀 构建和测试

### 模拟器测试
```bash
flutter run
```

### 真机测试
```bash
flutter run -d <your-device-id>
```

### 构建 IPA
```bash
flutter build ipa
```

## ⚠️ 注意事项

1. **分享功能**: `share_plus` 插件在模拟器上可能不工作，需要在真机上测试
2. **证书有效期**: 开发证书通常有效期为1年
3. **设备注册**: 确保你的测试设备已在 Apple Developer 账户中注册

## 🐛 常见问题

### 问题1: "No implementation found for method share"
- **原因**: 插件在模拟器上不支持
- **解决**: 在真机上测试，或使用异常处理（已实现）

### 问题2: 签名错误
- **检查**: Bundle Identifier 是否正确
- **检查**: 开发者账户是否有效
- **检查**: 证书是否过期

### 问题3: 设备无法安装
- **检查**: 设备是否已注册到开发者账户
- **检查**: 描述文件是否包含该设备

## 📞 技术支持

如果遇到问题，可以：
1. 检查 Xcode 控制台的详细错误信息
2. 验证 Apple Developer 账户状态
3. 确认所有证书和描述文件都是最新的
