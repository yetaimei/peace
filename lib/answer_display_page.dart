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
import 'components/theme_layouts.dart';

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
  final LayoutType layoutType;
  
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
    required this.layoutType,
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

// 布局类型枚举
enum LayoutType {
  classic,        // 经典居中布局
  matrix,         // Matrix代码雨风格
  cyberpunk,      // 赛博朋克科技界面
  retro,          // 复古电视机风格
  ocean,          // 海洋波浪层叠
  kawaii,         // 可爱卡片式
  nature,         // 自然有机布局
  luxury,         // 奢华对称布局
  // 新增布局类型
  terminal,       // 终端命令行风格
  gameboy,        // Game Boy掌机风格
  kindle,         // 电子书阅读器风格
  vhs,            // VHS录像带风格
  calculator,     // 计算器风格
  pager,          // 传呼机/BP机风格
  radioTuner,     // 收音机调频风格
  nixie,          // 辉光管数码显示风格
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
      layoutType: LayoutType.classic,
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
      layoutType: LayoutType.matrix,
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
      layoutType: LayoutType.cyberpunk,
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
      layoutType: LayoutType.retro,
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
      layoutType: LayoutType.ocean,
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
      layoutType: LayoutType.kawaii,
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
      layoutType: LayoutType.nature,
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
      layoutType: LayoutType.luxury,
    ),
    
    // 9. 终端黑客 - 命令行风格
    PixelTheme(
      name: '终端黑客',
      backgroundColor: Color(0xFF0D1117),
      primaryColor: Color(0xFF161B22),
      textColor: Color(0xFF58A6FF),
      borderColor: Color(0xFF30363D),
      shadowColor: Color(0xFF010409),
      icon: Icons.terminal,
      gradientColors: [Color(0xFF0D1117), Color(0xFF161B22)],
      patternType: PatternType.grid,
      layoutType: LayoutType.terminal,
    ),
    
    // 10. Game Boy怀旧 - 掌机风格
    PixelTheme(
      name: 'Game Boy',
      backgroundColor: Color(0xFF9BBB0F),
      primaryColor: Color(0xFF8BAC0F),
      textColor: Color(0xFF306230),
      borderColor: Color(0xFF0F380F),
      shadowColor: Color(0xFF0F2027),
      icon: Icons.videogame_asset,
      gradientColors: [Color(0xFF9BBB0F), Color(0xFF8BAC0F)],
      patternType: PatternType.dots,
      layoutType: LayoutType.gameboy,
    ),
    
    // 11. Kindle阅读 - 电纸书风格
    PixelTheme(
      name: 'Kindle阅读',
      backgroundColor: Color(0xFFF5F5DC),
      primaryColor: Color(0xFFE5E5E5),
      textColor: Color(0xFF2F2F2F),
      borderColor: Color(0xFF8B8B8B),
      shadowColor: Color(0xFFD3D3D3),
      icon: Icons.menu_book,
      gradientColors: [Color(0xFFF5F5DC), Color(0xFFE5E5E5)],
      patternType: PatternType.dots,
      layoutType: LayoutType.kindle,
    ),
    
    // 12. VHS录像 - 磁带风格
    PixelTheme(
      name: 'VHS录像',
      backgroundColor: Color(0xFF2B1810),
      primaryColor: Color(0xFF3D2318),
      textColor: Color(0xFFFF6B35),
      borderColor: Color(0xFFD2691E),
      shadowColor: Color(0xFF1A0F08),
      icon: Icons.videocam,
      gradientColors: [Color(0xFF2B1810), Color(0xFF3D2318)],
      patternType: PatternType.waves,
      layoutType: LayoutType.vhs,
    ),
    
    // 13. 计算器风格 - 数字显示
    PixelTheme(
      name: '计算器',
      backgroundColor: Color(0xFF2C2C2C),
      primaryColor: Color(0xFF3C3C3C),
      textColor: Color(0xFF00FF41),
      borderColor: Color(0xFF4C4C4C),
      shadowColor: Color(0xFF1C1C1C),
      icon: Icons.calculate,
      gradientColors: [Color(0xFF2C2C2C), Color(0xFF3C3C3C)],
      patternType: PatternType.grid,
      layoutType: LayoutType.calculator,
    ),
    
    // 14. 传呼机 - BP机风格
    PixelTheme(
      name: 'BP传呼机',
      backgroundColor: Color(0xFF1B1B1B),
      primaryColor: Color(0xFF2B2B2B),
      textColor: Color(0xFF32CD32),
      borderColor: Color(0xFF228B22),
      shadowColor: Color(0xFF0B0B0B),
      icon: Icons.message,
      gradientColors: [Color(0xFF1B1B1B), Color(0xFF2B2B2B)],
      patternType: PatternType.dots,
      layoutType: LayoutType.pager,
    ),
    
    // 15. 收音机调频 - 电台风格
    PixelTheme(
      name: '收音机',
      backgroundColor: Color(0xFF8B4513),
      primaryColor: Color(0xFFA0522D),
      textColor: Color(0xFFFFD700),
      borderColor: Color(0xFFCD853F),
      shadowColor: Color(0xFF654321),
      icon: Icons.radio,
      gradientColors: [Color(0xFF8B4513), Color(0xFFA0522D)],
      patternType: PatternType.waves,
      layoutType: LayoutType.radioTuner,
    ),
    
    // 16. 辉光管 - 数码管风格
    PixelTheme(
      name: '辉光管',
      backgroundColor: Color(0xFF0F0F0F),
      primaryColor: Color(0xFF1F1F1F),
      textColor: Color(0xFFFF4500),
      borderColor: Color(0xFFFF6347),
      shadowColor: Color(0xFF000000),
      icon: Icons.lightbulb,
      gradientColors: [Color(0xFF0F0F0F), Color(0xFF1F1F1F)],
      patternType: PatternType.circuit,
      layoutType: LayoutType.nixie,
    ),
    
    // 17. 暗黑经典 - 原始经典的反色调
    PixelTheme(
      name: '暗黑经典',
      backgroundColor: Color(0xFF1F1F27),
      primaryColor: Color(0xFF1F1F27),
      textColor: Color(0xFFE5E5E5),
      borderColor: Color(0xFFE5E5E5),
      shadowColor: Color(0xFFE5E5E5),
      icon: Icons.dark_mode,
      gradientColors: [Color(0xFF1F1F27), Color(0xFF1F1F27)],
      patternType: PatternType.grid,
      layoutType: LayoutType.classic,
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
        child: _buildLayoutByType(theme),
      ),
    );
  }

  // 根据布局类型构建不同的布局
  Widget _buildLayoutByType(PixelTheme theme) {
    switch (theme.layoutType) {
      case LayoutType.classic:
        return _buildClassicLayout(theme);
      case LayoutType.matrix:
        return _buildMatrixLayout(theme);
      case LayoutType.cyberpunk:
        return _buildCyberpunkLayout(theme);
      case LayoutType.retro:
        return _buildRetroLayout(theme);
      case LayoutType.ocean:
        return _buildOceanLayout(theme);
      case LayoutType.kawaii:
        return _buildKawaiiLayout(theme);
      case LayoutType.nature:
        return _buildNatureLayout(theme);
      case LayoutType.luxury:
        return _buildLuxuryLayout(theme);
      // 新增的布局类型
      case LayoutType.terminal:
        return _buildTerminalLayout(theme);
      case LayoutType.gameboy:
        return _buildGameBoyLayout(theme);
      case LayoutType.kindle:
        return _buildKindleLayout(theme);
      case LayoutType.vhs:
        return _buildVhsLayout(theme);
      case LayoutType.calculator:
        return _buildCalculatorLayout(theme);
      case LayoutType.pager:
        return _buildPagerLayout(theme);
      case LayoutType.radioTuner:
        return _buildRadioTunerLayout(theme);
      case LayoutType.nixie:
        return _buildNixieLayout(theme);
    }
  }

  // 1. 经典布局 - 居中简洁
  Widget _buildClassicLayout(PixelTheme theme) {
    return Center(
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
    );
  }

  // 2. Matrix布局
  Widget _buildMatrixLayout(PixelTheme theme) {
    return ThemeLayouts.buildMatrixLayout(theme, widget.answer);
  }

  // 3. 赛博朋克布局
  Widget _buildCyberpunkLayout(PixelTheme theme) {
    return ThemeLayouts.buildCyberpunkLayout(theme, widget.answer);
  }

  // 4. 复古布局
  Widget _buildRetroLayout(PixelTheme theme) {
    return ThemeLayouts.buildRetroLayout(theme, widget.answer);
  }

  // 5. 海洋布局
  Widget _buildOceanLayout(PixelTheme theme) {
    return ThemeLayouts.buildOceanLayout(theme, widget.answer);
  }

  // 6. 可爱布局
  Widget _buildKawaiiLayout(PixelTheme theme) {
    return ThemeLayouts.buildKawaiiLayout(theme, widget.answer);
  }

  // 7. 自然布局
  Widget _buildNatureLayout(PixelTheme theme) {
    return ThemeLayouts.buildNatureLayout(theme, widget.answer);
  }

  // 8. 奢华布局
  Widget _buildLuxuryLayout(PixelTheme theme) {
    return ThemeLayouts.buildLuxuryLayout(theme, widget.answer);
  }

  // 9. 终端布局
  Widget _buildTerminalLayout(PixelTheme theme) {
    return ThemeLayouts.buildTerminalLayout(theme, widget.answer);
  }

  // 10. Game Boy布局
  Widget _buildGameBoyLayout(PixelTheme theme) {
    return ThemeLayouts.buildGameBoyLayout(theme, widget.answer);
  }

  // 11. Kindle布局
  Widget _buildKindleLayout(PixelTheme theme) {
    return ThemeLayouts.buildKindleLayout(theme, widget.answer);
  }

  // 12. VHS布局
  Widget _buildVhsLayout(PixelTheme theme) {
    return ThemeLayouts.buildVhsLayout(theme, widget.answer);
  }

  // 13. 计算器布局
  Widget _buildCalculatorLayout(PixelTheme theme) {
    return ThemeLayouts.buildCalculatorLayout(theme, widget.answer);
  }

  // 14. 传呼机布局
  Widget _buildPagerLayout(PixelTheme theme) {
    return ThemeLayouts.buildPagerLayout(theme, widget.answer);
  }

  // 15. 收音机布局
  Widget _buildRadioTunerLayout(PixelTheme theme) {
    return ThemeLayouts.buildRadioTunerLayout(theme, widget.answer);
  }

  // 16. 辉光管布局
  Widget _buildNixieLayout(PixelTheme theme) {
    return ThemeLayouts.buildNixieLayout(theme, widget.answer);
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
