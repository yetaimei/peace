import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PeaceAboutDialog {
  /// 显示关于我们的详细弹窗
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // 允许点击背景关闭
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) => const _AboutDialogWidget(),
    );
  }
}

class _AboutDialogWidget extends StatefulWidget {
  const _AboutDialogWidget();

  @override
  State<_AboutDialogWidget> createState() => _AboutDialogWidgetState();
}

class _AboutDialogWidgetState extends State<_AboutDialogWidget> {
  String _appVersion = '加载中...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'Version ${packageInfo.version}';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Version 1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(
            maxWidth: 320,
            maxHeight: 480,
          ),
          decoration: _buildPixelBoxDecoration(),
          child: CustomPaint(
            painter: PixelPatternPainter(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部关闭按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '关于我们',
                      style: GoogleFonts.vt323(
                        fontSize: 24,
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // App图标
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0D8),
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    size: 48,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // App名称
                Text(
                  'Peace 答案之书',
                  style: GoogleFonts.vt323(
                    fontSize: 20,
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 版本信息
                Text(
                  _appVersion,
                  style: GoogleFonts.vt323(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 应用描述
                Text(
                  '一个神奇的答案之书应用，为你的所有问题提供智慧的答案。在心中默念问题，获得来自宇宙的指引。',
                  style: GoogleFonts.vt323(
                    fontSize: 14,
                    color: const Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // 底部文字
                Text(
                  'Made with Peace and Love 🕊️💝',
                  style: GoogleFonts.vt323(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  BoxDecoration _buildPixelBoxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFE0E0D8),
      border: Border.all(
        color: const Color(0xFF1A1A1A),
        width: 3,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        const BoxShadow(
          color: Color(0xFF1A1A1A),
          offset: Offset(6, 6),
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
      ..color = Colors.black.withValues(alpha: 0.03)
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
