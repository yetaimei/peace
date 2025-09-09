import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class AnswerDisplayPage extends StatefulWidget {
  final String answer;
  final String question;

  const AnswerDisplayPage({
    super.key,
    required this.answer,
    required this.question,
  });

  @override
  State<AnswerDisplayPage> createState() => _AnswerDisplayPageState();
}

class _AnswerDisplayPageState extends State<AnswerDisplayPage> {

  // 保存壁纸功能
  void _saveWallpaper() async {
    try {
      // 显示保存提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '壁纸已保存到相册',
            style: GoogleFonts.vt323(fontSize: 16),
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '保存失败: ${e.toString()}',
            style: GoogleFonts.vt323(fontSize: 16),
          ),
          backgroundColor: const Color(0xFFFF5722),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 分享给好友功能
  void _shareToFriend() {
    final shareText = '${widget.question.isNotEmpty ? "问题: ${widget.question}\n" : ""}答案: ${widget.answer}\n\n来自《答案之书》';
    Share.share(
      shareText,
      subject: '我的答案之书',
    );
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
          child: Container(
              padding: EdgeInsets.fromLTRB(20.0, MediaQuery.of(context).padding.top + 20.0, 20.0, 20.0),
              child: Column(
                children: [
                  // 顶部间距
                  const SizedBox(height: 20),
                  
                  // 关闭按钮（右上角）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0D8),
                            border: Border.all(
                              color: const Color(0xFF1A1A1A),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // 主要内容区域
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 答案显示区域
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32.0),
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0D8),
                        border: Border.all(
                          color: const Color(0xFF1A1A1A),
                          width: 3,
                        ),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0xFF1A1A1A),
                            offset: Offset(6, 6),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 48,
                            color: const Color(0xFF1A1A1A),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.answer,
                            style: GoogleFonts.vt323(
                              fontSize: 36,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 底部按钮组
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // 保存壁纸按钮
                    Expanded(
                      child: GestureDetector(
                        onTap: _saveWallpaper,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0D8),
                            border: Border.all(
                              color: const Color(0xFF1A1A1A),
                              width: 2,
                            ),
                            boxShadow: [
                              const BoxShadow(
                                color: Color(0xFF1A1A1A),
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.save_alt,
                                size: 20,
                                color: Color(0xFF1A1A1A),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '保存壁纸',
                                style: GoogleFonts.vt323(
                                  fontSize: 18,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // 分享给好友按钮
                    Expanded(
                      child: GestureDetector(
                        onTap: _shareToFriend,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          margin: const EdgeInsets.only(left: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0D8),
                            border: Border.all(
                              color: const Color(0xFF1A1A1A),
                              width: 2,
                            ),
                            boxShadow: [
                              const BoxShadow(
                                color: Color(0xFF1A1A1A),
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.share,
                                size: 20,
                                color: Color(0xFF1A1A1A),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '分享好友',
                                style: GoogleFonts.vt323(
                                  fontSize: 18,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
