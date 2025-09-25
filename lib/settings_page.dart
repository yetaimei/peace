import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'answer_library_page.dart';
import 'components/pixel_dialog.dart';
import 'components/about_dialog.dart';
import 'pages/font_selection_page.dart';
import 'pages/widget_theme_page.dart';
import 'services/font_service.dart';
import 'services/answer_library_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentFontName = '加载中...';
  String _currentLibraryName = '加载中...';

  @override
  void initState() {
    super.initState();
    _loadCurrentFont();
    _loadCurrentLibraryName();
  }

  Future<void> _loadCurrentFont() async {
    final fontId = await FontService.getCurrentFontId();
    final fontChoice = FontService.getFontChoiceById(fontId);
    setState(() {
      _currentFontName = fontChoice?.name ?? 'VT323';
    });
  }

  void _onFontChanged() {
    // 字体更改后重新加载当前字体名称
    _loadCurrentFont();
  }

  

  Future<void> _openFontSelection() async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const FontSelectionPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // 从右侧开始
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    
    // 如果字体有更改，通知父组件
    if (result == true) {
      _onFontChanged();
    }
  }

  Future<void> _loadCurrentLibraryName() async {
    final library = await AnswerLibraryService.getCurrentLibrary();
    if (!mounted) return;
    setState(() {
      _currentLibraryName = library?.name ?? '毛泽东语录';
    });
  }

  Future<void> _openAnswerLibrary() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AnswerLibraryPage(),
      ),
    );
    // 返回设置页后刷新当前库名
    await _loadCurrentLibraryName();
  }

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
          child: GestureDetector(
            onPanEnd: (details) {
              // 检测向右滑动手势，返回主页面
              if (details.velocity.pixelsPerSecond.dx > 300) {
                Navigator.of(context).pop();
              }
            },
            child: SafeArea(
            child: Column(
              children: [
                // 顶部标题栏
                _buildAppBar(context),
                
                // 主要内容区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                              _buildAnswerLibrarySettingItem(),
                              const SizedBox(height: 18),
                              
                              _buildFontSettingItem(),
                              const SizedBox(height: 18),
                              _buildWidgetSettingItem(),
                              const SizedBox(height: 18),
                              
                              _buildSettingItem(
                                '分享App',
                                () {
                                  _shareApp(context);
                                },
                              ),
                              const SizedBox(height: 18),
                              
                              _buildSettingItem(
                                '意见反馈',
                                () {
                                  _sendFeedback(context);
                                },
                              ),
                              const SizedBox(height: 18),
                              
                              _buildSettingItem(
                                '关于我们',
                                () {
                                  PeaceAboutDialog.show(context);
                                },
                              ),
                              const SizedBox(height: 18),
                              
                              _buildSettingItem(
                                '隐私政策',
                                () {
                                  _openPrivacyPolicy(context);
                                },
                              ),
                              const SizedBox(height: 18),
                              
                              _buildCheckUpdateButton(context),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // 底部文字
                        _buildFooter(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ),
        ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
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
        padding: const EdgeInsets.all(12.0),
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

  Widget _buildFontSettingItem() {
    return GestureDetector(
      onTap: _openFontSelection,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: _buildPixelBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    '字体设置',
                    style: GoogleFonts.vt323(
                      fontSize: 24,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '($_currentFontName)',
                      style: GoogleFonts.vt323(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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

  Widget _buildAnswerLibrarySettingItem() {
    return GestureDetector(
      onTap: _openAnswerLibrary,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: _buildPixelBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    '答案库',
                    style: GoogleFonts.vt323(
                      fontSize: 24,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '($_currentLibraryName)',
                      style: GoogleFonts.vt323(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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

  Widget _buildWidgetSettingItem() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WidgetThemePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: _buildPixelBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    '桌面小组件',
                    style: GoogleFonts.vt323(
                      fontSize: 24,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '(支持桌面小组件了)',
                      style: GoogleFonts.vt323(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
        padding: const EdgeInsets.all(12.0),
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

  // 旧的小组件主题内嵌区域已移除，统一改为独立页面

  void _shareApp(BuildContext context) async {
    // App Store链接 - 使用简单格式，确保链接有效
    const String appStoreUrl = 'https://apps.apple.com/app/id6752237394';
    
    try {
      await Clipboard.setData(ClipboardData(text: appStoreUrl));
      
      if (context.mounted) {
        PixelDialogExtended.show(
          context,
          '链接已复制到剪贴板！\n快去分享给朋友们吧 🕊️💝',
          type: PixelDialogType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        PixelDialogExtended.show(
          context,
          '复制链接失败\n请稍后重试',
          type: PixelDialogType.error,
        );
      }
    }
  }

  void _sendFeedback(BuildContext context) async {
    try {
      final emailQuery = await _buildEmailQuery();
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'leilei0091@icloud.com',
        query: emailQuery,
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          PixelDialogExtended.show(
            context,
            '无法打开邮件应用\n请手动发送邮件至:\nleilei0091@icloud.com',
            type: PixelDialogType.warning,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        PixelDialogExtended.show(
          context,
          '邮件功能暂时不可用\n请稍后重试或手动发送',
          type: PixelDialogType.error,
        );
      }
    }
  }

  Future<String> _buildEmailQuery() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final subject = Uri.encodeComponent('Peace答案之书 - 意见反馈');
    final body = Uri.encodeComponent(
      
      'Peace and Love 🕊️💝'

      '问题:\n\n'
      '功能许愿:\n\n'
      
      '应用版本: ${packageInfo.version} (${packageInfo.buildNumber})\n'
      '应用包名: ${packageInfo.packageName}\n'
      '设备信息: ${_getDeviceInfo()}\n\n'
     
     
    );
    
    return 'subject=$subject&body=$body';
  }

  String _getDeviceInfo() {
    // 简单的设备信息，实际应用中可以使用device_info_plus包获取更详细信息
    return 'iOS设备';
  }

  void _openPrivacyPolicy(BuildContext context) async {
    // 隐私政策链接 - Notion页面
    const String privacyPolicyUrl = 'https://www.notion.so/leilei0091/26b5e372803f8048b94de5dbb50fe30a?source=copy_link';
    
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
    // App Store链接 - 使用简单格式，确保链接有效
    // 格式: https://apps.apple.com/app/id[你的App ID]
    const String appStoreUrl = 'https://apps.apple.com/app/id6752237394';
    
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