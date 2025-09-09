import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'answer_library_page.dart';
import 'components/pixel_dialog.dart';
import 'components/about_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0D8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFE0E0D8),
        ),
        child: CustomPaint(
          painter: PixelPatternPainter(),
          child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, MediaQuery.of(context).padding.top + 16.0, 16.0, 16.0),
              child: Column(
                children: [
                  // 顶部标题栏
                  _buildAppBar(context),
                  
                  // 主要内容区域
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        
                        // 设置选项列表
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: Column(
                            children: [
                              _buildSettingItem(
                                '答案库',
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const AnswerLibraryPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              _buildSettingItem(
                                '分享App',
                                () {
                                  _shareApp(context);
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              _buildSettingItem(
                                '关于我们',
                                () {
                                  PeaceAboutDialog.show(context);
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              _buildSettingItem(
                                '隐私政策',
                                () {
                                  _openPrivacyPolicy(context);
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              _buildCheckUpdateButton(context),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // 底部文字
                        _buildFooter(),
                      ],
                    ),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 32,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          
          // 标题居中
          Expanded(
            child: Center(
              child: Text(
                '设置',
                style: GoogleFonts.vt323(
                  fontSize: 40,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          
          // 右侧占位，保持居中
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: _buildPixelBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.vt323(
                fontSize: 24,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 24,
              color: Color(0xFF1A1A1A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckUpdateButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openAppStore(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: _buildPixelBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '检查新版本',
              style: GoogleFonts.vt323(
                fontSize: 24,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 24,
              color: Color(0xFF1A1A1A),
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp(BuildContext context) async {
    try {
      await Share.share(
        '快来试试这个神奇的答案之书App！Peace and Love 🕊️💝\n它能为你的所有问题提供智慧的答案！',
        subject: '答案之书 - Peace and Love',
      );
    } catch (e) {
      // 如果分享失败，显示友好的错误信息
      if (context.mounted) {
        PixelDialogExtended.show(
          context,
          '分享功能暂时不可用\n请在真机上测试',
          type: PixelDialogType.warning,
        );
      }
    }
  }

  void _openPrivacyPolicy(BuildContext context) async {
    // 隐私政策链接 - 这里是一个占位链接，后期你可以替换为实际的隐私政策页面
    const String privacyPolicyUrl = 'https://www.example.com/privacy-policy';
    
    try {
      final Uri url = Uri.parse(privacyPolicyUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          PixelDialogExtended.show(
            context,
            '无法打开隐私政策页面\n请稍后重试',
            type: PixelDialogType.warning,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        PixelDialogExtended.show(
          context,
          '隐私政策页面暂时无法访问',
          type: PixelDialogType.error,
        );
      }
    }
  }

  void _openAppStore(BuildContext context) async {
    // App Store链接 - 这里使用Apple的示例链接，你需要替换为实际的App ID
    // 格式: https://apps.apple.com/app/id[你的App ID]
    const String appStoreUrl = 'https://apps.apple.com/cn/app/apple-store/id375380948';
    
    try {
      final Uri url = Uri.parse(appStoreUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // 在外部浏览器打开
        );
      } else {
        // 如果无法打开，显示提示
        if (context.mounted) {
          PixelDialogExtended.show(
            context,
            '无法打开App Store\n请手动搜索"Peace答案之书"',
            type: PixelDialogType.warning,
          );
        }
      }
    } catch (e) {
      // 异常处理
      if (context.mounted) {
        PixelDialogExtended.show(
          context,
          '跳转失败，请稍后重试',
          type: PixelDialogType.error,
        );
      }
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        'Made with Peace and Love',
        style: GoogleFonts.vt323(
          fontSize: 18,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  BoxDecoration _buildPixelBoxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFE0E0D8),
      border: Border.all(
        color: const Color(0xFF1A1A1A),
        width: 2,
      ),
      boxShadow: [
        // 外阴影
        const BoxShadow(
          color: Color(0xFF1A1A1A),
          offset: Offset(4, 4),
          blurRadius: 0,
        ),
      ],
    );
  }
}

// 像素网格背景画笔
class PixelPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // 绘制垂直线
    for (double x = 0; x < size.width; x += 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 绘制水平线
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}