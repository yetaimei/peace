import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/pixel_dialog.dart';

class AnswerLibraryPage extends StatelessWidget {
  const AnswerLibraryPage({super.key});

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
                        
                        // 答案库选项列表
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: Column(
                            children: [
                              _buildLibraryItem(
                                '毛泽东语录',
                                () {
                                  PixelDialogExtended.show(
                                    context,
                                    '已切换到毛泽东语录',
                                    type: PixelDialogType.success,
                                  );
                                },
                                isSelected: true, // 默认选中
                              ),
                              const SizedBox(height: 24),
                              
                              _buildLibraryItem(
                                '其他',
                                () {
                                  PixelDialogExtended.show(
                                    context,
                                    '已切换到其他答案库',
                                    type: PixelDialogType.success,
                                  );
                                },
                                isSelected: false,
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // 说明文字
                        _buildDescription(),
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
                '答案库',
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

  Widget _buildLibraryItem(String title, VoidCallback onTap, {required bool isSelected}) {
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
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 24,
                color: Color(0xFF4CAF50),
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                size: 24,
                color: Color(0xFF1A1A1A),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        '选择你喜欢的答案库\n不同的答案库会给出不同风格的回答',
        style: GoogleFonts.vt323(
          fontSize: 16,
          color: Colors.grey[600],
        ),
        textAlign: TextAlign.center,
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
