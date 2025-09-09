import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'services/logger_service.dart';
import 'components/pixel_dialog.dart';

// 主题数据类
class PixelTheme {
  final String name;
  final Color backgroundColor;
  final Color primaryColor;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;
  final IconData icon;
  final List<Color> gradientColors;
  final PatternType patternType;
  
  const PixelTheme({
    required this.name,
    required this.backgroundColor,
    required this.primaryColor,
    required this.textColor,
    required this.borderColor,
    required this.shadowColor,
    required this.icon,
    required this.gradientColors,
    required this.patternType,
  });
}

// 图案类型枚举
enum PatternType {
  grid,
  dots,
  waves,
  diagonal,
  circuit,
  hexagon,
  stars,
}

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
  // 截图控制器
  ScreenshotController screenshotController = ScreenshotController();
  
  // 按钮显示状态控制
  bool _showButtons = true;
  
  // 页面控制器
  final PageController _pageController = PageController();
  
  // 当前主题索引
  int _currentThemeIndex = 0;
  
  // 主题数组
  final List<PixelTheme> _themes = [
    // 1. 原始经典 - 保留最初的米色主题
    PixelTheme(
      name: '原始经典',
      backgroundColor: Color(0xFFE0E0D8),
      primaryColor: Color(0xFFE0E0D8),
      textColor: Color(0xFF1A1A1A),
      borderColor: Color(0xFF1A1A1A),
      shadowColor: Color(0xFF1A1A1A),
      icon: Icons.auto_awesome,
      gradientColors: [Color(0xFFE0E0D8), Color(0xFFE0E0D8)],
      patternType: PatternType.grid,
    ),
    
    // 2. 经典复古绿屏 - Matrix风格
    PixelTheme(
      name: '经典绿屏',
      backgroundColor: Color(0xFF001100),
      primaryColor: Color(0xFF003300),
      textColor: Color(0xFF00FF00),
      borderColor: Color(0xFF00CC00),
      shadowColor: Color(0xFF004400),
      icon: Icons.computer,
      gradientColors: [Color(0xFF001100), Color(0xFF003300)],
      patternType: PatternType.grid,
    ),
    
    // 3. 赛博朋克紫 - 未来科幻风
    PixelTheme(
      name: '赛博朋克',
      backgroundColor: Color(0xFF0A0A1A),
      primaryColor: Color(0xFF1A0A2E),
      textColor: Color(0xFFFF00FF),
      borderColor: Color(0xFFAA00FF),
      shadowColor: Color(0xFF2D1B69),
      icon: Icons.electric_bolt,
      gradientColors: [Color(0xFF0A0A1A), Color(0xFF2D1B69)],
      patternType: PatternType.circuit,
    ),
    
    // 4. 复古橙色 - 80年代风格
    PixelTheme(
      name: '复古橙光',
      backgroundColor: Color(0xFF1A0A00),
      primaryColor: Color(0xFF2E1A0A),
      textColor: Color(0xFFFF6600),
      borderColor: Color(0xFFCC4400),
      shadowColor: Color(0xFF331100),
      icon: Icons.radio,
      gradientColors: [Color(0xFF1A0A00), Color(0xFF2E1A0A)],
      patternType: PatternType.waves,
    ),
    
    // 5. 海洋蓝调 - 深海科技风
    PixelTheme(
      name: '深海蓝调',
      backgroundColor: Color(0xFF001122),
      primaryColor: Color(0xFF002244),
      textColor: Color(0xFF00CCFF),
      borderColor: Color(0xFF0099CC),
      shadowColor: Color(0xFF003366),
      icon: Icons.waves,
      gradientColors: [Color(0xFF001122), Color(0xFF002244)],
      patternType: PatternType.hexagon,
    ),
    
    // 6. 樱花粉 - 可爱像素风
    PixelTheme(
      name: '樱花粉恋',
      backgroundColor: Color(0xFF2A1A20),
      primaryColor: Color(0xFF3A2A30),
      textColor: Color(0xFFFF99CC),
      borderColor: Color(0xFFCC6699),
      shadowColor: Color(0xFF4A2A40),
      icon: Icons.favorite,
      gradientColors: [Color(0xFF2A1A20), Color(0xFF3A2A30)],
      patternType: PatternType.stars,
    ),
    
    // 7. 森林绿 - 自然像素风
    PixelTheme(
      name: '森林绿野',
      backgroundColor: Color(0xFF0A1A0A),
      primaryColor: Color(0xFF1A2A1A),
      textColor: Color(0xFF66FF66),
      borderColor: Color(0xFF44CC44),
      shadowColor: Color(0xFF2A3A2A),
      icon: Icons.forest,
      gradientColors: [Color(0xFF0A1A0A), Color(0xFF1A2A1A)],
      patternType: PatternType.dots,
    ),
    
    // 8. 黄金时代 - 金色奢华
    PixelTheme(
      name: '黄金时代',
      backgroundColor: Color(0xFF1A1A00),
      primaryColor: Color(0xFF2A2A00),
      textColor: Color(0xFFFFDD00),
      borderColor: Color(0xFFCCAA00),
      shadowColor: Color(0xFF333300),
      icon: Icons.diamond,
      gradientColors: [Color(0xFF1A1A00), Color(0xFF2A2A00)],
      patternType: PatternType.diagonal,
    ),
  ];
  
  /// 保存图片到相册
  /// 使用 image_gallery_saver 插件的内置权限处理
  Future<void> _saveImageToGallery(Uint8List imageData) async {
    LoggerService.info('卡片保存服务-开始保存-平台:${Platform.operatingSystem}-数据大小:${imageData.length}字节');
    
    var success = false;
    var successMessage = '壁纸已保存到相册';
    
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        LoggerService.info('卡片保存服务-移动平台-使用ImageGallerySaver');
        // 移动平台：保存到相册
        final result = await ImageGallerySaver.saveImage(
          imageData,
          quality: 100, // 保持高质量
          name: 'answer_${_themes[_currentThemeIndex].name}_${DateTime.now().millisecondsSinceEpoch}',
        );
        success = result['isSuccess'] == true;
      } else {
        LoggerService.info('卡片保存服务-桌面平台-使用文件选择器');
        // 桌面平台：使用文件选择器保存到用户指定位置
        // 这里可以添加桌面平台的文件保存逻辑
        success = false;
        successMessage = '桌面平台暂不支持直接保存到相册';
      }
      
      if (success) {
        LoggerService.info('卡片保存服务-保存成功');
        if (mounted) {
          PixelDialogExtended.show(
            context,
            successMessage,
            type: PixelDialogType.success,
          );
        }
      } else {
        LoggerService.warning('卡片保存服务-保存失败-可能是权限问题或系统错误');
        if (mounted) {
          PixelDialogExtended.show(
            context,
            '保存失败，请检查相册权限',
            type: PixelDialogType.warning,
          );
        }
      }
    } catch (e) {
      LoggerService.error('卡片保存服务-异常', null, e);
      if (mounted) {
        PixelDialogExtended.show(
          context,
          '保存图片时发生错误，请重试',
          type: PixelDialogType.error,
        );
      }
    }
  }

  // 生成壁纸截图
  Future<Uint8List?> _captureWallpaper() async {
    try {
      LoggerService.debug('开始截图 - 隐藏按钮');
      
      // 临时隐藏按钮
      setState(() {
        _showButtons = false;
      });
      
      // 等待UI更新完成
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 执行截图
      final image = await screenshotController.capture();
      LoggerService.debug('截图成功，大小: ${image?.length ?? 0} bytes');
      
      // 恢复按钮显示
      setState(() {
        _showButtons = true;
      });
      
      return image;
    } catch (e) {
      LoggerService.error('截图失败', null, e);
      
      // 确保恢复按钮显示
      setState(() {
        _showButtons = true;
      });
      
      return null;
    }
  }

  // 保存壁纸功能
  void _saveWallpaper() async {
    if (!mounted) return;
    
    try {
      LoggerService.userAction('用户点击保存壁纸');

      // 截图
      final imageBytes = await _captureWallpaper();
      if (!mounted) return;
      
      if (imageBytes == null) {
        PixelDialogExtended.show(
          context,
          '截图失败，请重试',
          type: PixelDialogType.error,
        );
        return;
      }

      // 保存到相册（插件会自动处理权限请求）
      await _saveImageToGallery(imageBytes);
      
    } catch (e) {
      LoggerService.error('保存壁纸流程异常', null, e);
      if (!mounted) return;
      PixelDialogExtended.show(
        context,
        '保存失败，请重试',
        type: PixelDialogType.error,
      );
    }
  }

  // 分享给好友功能
  void _shareToFriend() async {
    if (!mounted) return;
    
    try {
      LoggerService.debug('开始分享功能');

      // 截图
      final imageBytes = await _captureWallpaper();
      if (!mounted) return;
      
      if (imageBytes == null) {
        LoggerService.error('分享时截图失败');
        PixelDialogExtended.show(
          context,
          '生成图片失败，请重试',
          type: PixelDialogType.error,
        );
        return;
      }

      // 保存临时文件
      LoggerService.debug('保存临时分享文件');
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/answer_${_themes[_currentThemeIndex].name}.png').create();
      await file.writeAsBytes(imageBytes);
      LoggerService.debug('临时文件已保存: ${file.path}');

      if (!mounted) return;

      // 分享文件
      LoggerService.debug('调用系统分享');
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.question.isNotEmpty ? "问题: ${widget.question}\n" : ""}答案: ${widget.answer}\n\n主题: ${_themes[_currentThemeIndex].name}\n来自《答案之书》',
        subject: '我的答案之书 - ${_themes[_currentThemeIndex].name}主题',
      );
      LoggerService.debug('分享完成');
    } catch (e) {
      LoggerService.error('分享失败', null, e);
      if (!mounted) return;
      PixelDialogExtended.show(
        context,
        '分享失败，请重试',
        type: PixelDialogType.error,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 构建单个主题页面
  Widget _buildThemePage(PixelTheme theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradientColors,
        ),
      ),
      child: CustomPaint(
        painter: PixelPatternPainter(theme),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            margin: const EdgeInsets.symmetric(horizontal: 36.0),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              border: Border.all(
                color: theme.borderColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  offset: const Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  theme.icon,
                  size: 48,
                  color: theme.textColor,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.answer,
                  style: GoogleFonts.vt323(
                    fontSize: 36,
                    color: theme.textColor,
                    letterSpacing: 2.0,
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

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themes[_currentThemeIndex];
    
    return Scaffold(
      backgroundColor: currentTheme.backgroundColor,
      body: Stack(
        children: [
          // 主要内容 - PageView滑动主题
          Screenshot(
            controller: screenshotController,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentThemeIndex = index;
                });
                HapticFeedback.lightImpact(); // 轻触觉反馈
              },
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                return _buildThemePage(_themes[index]);
              },
            ),
          ),
          
          // 主题指示器（可以被隐藏）
          if (_showButtons)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20.0,
              left: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: currentTheme.primaryColor,
                  border: Border.all(
                    color: currentTheme.borderColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: currentTheme.shadowColor,
                      offset: const Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.palette,
                      size: 16,
                      color: currentTheme.textColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_currentThemeIndex + 1}/${_themes.length}',
                      style: GoogleFonts.vt323(
                        fontSize: 16,
                        color: currentTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 关闭按钮 - 右上角（可以被隐藏）
          if (_showButtons)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20.0,
              right: 20.0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: currentTheme.primaryColor,
                    border: Border.all(
                      color: currentTheme.borderColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: currentTheme.shadowColor,
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: currentTheme.textColor,
                  ),
                ),
              ),
            ),
          
          // 滑动提示（可以被隐藏）
          if (_showButtons)
            Positioned(
              left: 20.0,
              right: 20.0,
              bottom: 120.0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: currentTheme.backgroundColor.withValues(alpha: 0.8),
                    border: Border.all(
                      color: currentTheme.borderColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '← 滑动切换主题 →',
                    style: GoogleFonts.vt323(
                      fontSize: 14,
                      color: currentTheme.textColor,
                    ),
                  ),
                ),
              ),
            ),
          
          // 底部按钮组（可以被隐藏）
          if (_showButtons)
            Positioned(
              left: 20.0,
              right: 20.0,
              bottom: 40.0,
              child: Container(
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
                            color: currentTheme.primaryColor,
                            border: Border.all(
                              color: currentTheme.borderColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: currentTheme.shadowColor,
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_alt,
                                size: 20,
                                color: currentTheme.textColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '保存壁纸',
                                style: GoogleFonts.vt323(
                                  fontSize: 18,
                                  color: currentTheme.textColor,
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
                            color: currentTheme.primaryColor,
                            border: Border.all(
                              color: currentTheme.borderColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: currentTheme.shadowColor,
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.share,
                                size: 20,
                                color: currentTheme.textColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '分享好友',
                                style: GoogleFonts.vt323(
                                  fontSize: 18,
                                  color: currentTheme.textColor,
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
            ),
        ],
      ),
    );
  }
}

// 像素图案背景画笔
class PixelPatternPainter extends CustomPainter {
  final PixelTheme theme;
  
  PixelPatternPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.textColor.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = theme.textColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    switch (theme.patternType) {
      case PatternType.grid:
        _drawGrid(canvas, size, paint);
        break;
      case PatternType.dots:
        _drawDots(canvas, size, fillPaint);
        break;
      case PatternType.waves:
        _drawWaves(canvas, size, paint);
        break;
      case PatternType.diagonal:
        _drawDiagonal(canvas, size, paint);
        break;
      case PatternType.circuit:
        _drawCircuit(canvas, size, paint);
        break;
      case PatternType.hexagon:
        _drawHexagons(canvas, size, paint);
        break;
      case PatternType.stars:
        _drawStars(canvas, size, fillPaint);
        break;
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    // 绘制垂直线
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // 绘制水平线
    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    for (double x = 8; x < size.width; x += 16) {
      for (double y = 8; y < size.height; y += 16) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    for (double y = 0; y < size.height; y += 20) {
      path.reset();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 10) {
        path.lineTo(x, y + sin(x * 0.1) * 3);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawDiagonal(Canvas canvas, Size size, Paint paint) {
    for (double x = -size.height; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  void _drawCircuit(Canvas canvas, Size size, Paint paint) {
    // 绘制电路板风格的线条
    for (double x = 20; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      // 添加小方块
      for (double y = 20; y < size.height; y += 40) {
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 4, height: 4), paint);
      }
    }
    for (double y = 20; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawHexagons(Canvas canvas, Size size, Paint paint) {
    const spacing = 24.0;
    for (double y = 0; y < size.height; y += spacing * 0.75) {
      for (double x = 0; x < size.width; x += spacing) {
        final offset = (y / (spacing * 0.75)).round() % 2 == 1 ? spacing / 2 : 0;
        _drawHexagon(canvas, Offset(x + offset, y), 8, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStars(Canvas canvas, Size size, Paint paint) {
    for (double x = 16; x < size.width; x += 32) {
      for (double y = 16; y < size.height; y += 32) {
        _drawStar(canvas, Offset(x, y), 3, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * pi / 180;
      final r = i % 2 == 0 ? radius : radius * 0.5;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
