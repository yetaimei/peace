import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelDialog {
  /// 显示像素风格的弹窗
  /// [context] - 上下文
  /// [message] - 显示的消息
  /// [duration] - 显示时长，默认1秒
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 1),
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // 防止点击背景关闭
      barrierColor: Colors.black.withValues(alpha: 0.3), // 半透明背景
      builder: (BuildContext context) {
        // 自动关闭弹窗
        Future.delayed(duration, () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return _PixelDialogWidget(message: message);
      },
    );
  }
}

class _PixelDialogWidget extends StatelessWidget {
  final String message;

  const _PixelDialogWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          constraints: const BoxConstraints(
            maxWidth: 320,
            minHeight: 56,
            maxHeight: 72,
          ),
          decoration: _buildPixelBoxDecoration(),
          child: CustomPaint(
            painter: PixelPatternPainter(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0D8),
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 消息文本
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.vt323(
                      fontSize: 16,
                      color: const Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
        // 外阴影
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

/// 不同类型的弹窗样式
enum PixelDialogType {
  info,    // 信息提示
  success, // 成功提示
  warning, // 警告提示
  error,   // 错误提示
}

class PixelDialogExtended {
  /// 显示不同类型的像素风格弹窗
  static void show(
    BuildContext context,
    String message, {
    PixelDialogType type = PixelDialogType.info,
    Duration duration = const Duration(seconds: 1),
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        Future.delayed(duration, () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return _PixelDialogExtendedWidget(
          message: message,
          type: type,
        );
      },
    );
  }
}

class _PixelDialogExtendedWidget extends StatelessWidget {
  final String message;
  final PixelDialogType type;

  const _PixelDialogExtendedWidget({
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          constraints: const BoxConstraints(
            maxWidth: 320,
            minHeight: 56,
            maxHeight: 72,
          ),
          decoration: _buildPixelBoxDecoration(),
          child: CustomPaint(
            painter: PixelPatternPainter(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 根据类型显示不同图标
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(),
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getIcon(),
                    size: 20,
                    color: _getIconColor(),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 消息文本
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.vt323(
                      fontSize: 16,
                      color: const Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case PixelDialogType.success:
        return Icons.check_circle_outline;
      case PixelDialogType.warning:
        return Icons.warning_amber_outlined;
      case PixelDialogType.error:
        return Icons.error_outline;
      case PixelDialogType.info:
        return Icons.info_outline;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case PixelDialogType.success:
        return const Color(0xFF4CAF50);
      case PixelDialogType.warning:
        return const Color(0xFFF57C00);
      case PixelDialogType.error:
        return const Color(0xFFE53935);
      case PixelDialogType.info:
        return const Color(0xFF1A1A1A);
    }
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case PixelDialogType.success:
        return const Color(0xFFE8F5E8);
      case PixelDialogType.warning:
        return const Color(0xFFFFF3E0);
      case PixelDialogType.error:
        return const Color(0xFFFFEBEE);
      case PixelDialogType.info:
        return const Color(0xFFE0E0D8);
    }
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
