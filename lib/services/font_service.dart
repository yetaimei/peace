import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// 字体选择项
class FontChoice {
  final String id;
  final String name;
  final String description;
  final TextStyle Function({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) getTextStyle;

  const FontChoice({
    required this.id,
    required this.name,
    required this.description,
    required this.getTextStyle,
  });
}

/// 字体管理服务
class FontService {
  static const String _fontPreferenceKey = 'selected_font_id';
  static const String _defaultFontId = 'vt323';
  
  /// 可选择的像素风格字体列表
  static final List<FontChoice> availableFonts = [
    FontChoice(
      id: 'vt323',
      name: 'VT323',
      description: '经典终端风格 (当前默认)',
      getTextStyle: GoogleFonts.vt323,
    ),
    FontChoice(
      id: 'press_start_2p',
      name: 'Press Start 2P',
      description: '8位游戏复古风格',
      getTextStyle: GoogleFonts.pressStart2p,
    ),
    FontChoice(
      id: 'orbitron',
      name: 'Orbitron',
      description: '未来科技感',
      getTextStyle: GoogleFonts.orbitron,
    ),
    FontChoice(
      id: 'share_tech_mono',
      name: 'Share Tech Mono',
      description: '科技等宽字体',
      getTextStyle: GoogleFonts.shareTechMono,
    ),
    FontChoice(
      id: 'courier_prime',
      name: 'Courier Prime',
      description: '复古打字机风格',
      getTextStyle: GoogleFonts.courierPrime,
    ),
    FontChoice(
      id: 'source_code_pro',
      name: 'Source Code Pro',
      description: '现代编程字体',
      getTextStyle: GoogleFonts.sourceCodePro,
    ),
    FontChoice(
      id: 'fira_code',
      name: 'Fira Code',
      description: '程序员专用字体',
      getTextStyle: GoogleFonts.firaCode,
    ),
    FontChoice(
      id: 'inconsolata',
      name: 'Inconsolata',
      description: '优雅等宽字体',
      getTextStyle: GoogleFonts.inconsolata,
    ),
    FontChoice(
      id: 'major_mono_display',
      name: 'Major Mono Display',
      description: '大胆显示字体',
      getTextStyle: GoogleFonts.majorMonoDisplay,
    ),
    FontChoice(
      id: 'nova_mono',
      name: 'Nova Mono',
      description: '现代几何风格',
      getTextStyle: GoogleFonts.novaMono,
    ),
  ];

  /// 获取当前选择的字体ID
  static Future<String> getCurrentFontId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fontId = prefs.getString(_fontPreferenceKey) ?? _defaultFontId;
      LoggerService.debug('获取当前字体ID: $fontId');
      return fontId;
    } catch (e) {
      LoggerService.error('获取字体设置失败: $e', 'FONT_SERVICE');
      return _defaultFontId;
    }
  }

  /// 设置当前字体
  static Future<bool> setCurrentFont(String fontId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontPreferenceKey, fontId);
      LoggerService.info('字体设置已保存: $fontId', 'FONT_SERVICE');
      return true;
    } catch (e) {
      LoggerService.error('保存字体设置失败: $e', 'FONT_SERVICE');
      return false;
    }
  }

  /// 根据ID获取字体选择项
  static FontChoice? getFontChoiceById(String fontId) {
    try {
      return availableFonts.firstWhere((font) => font.id == fontId);
    } catch (e) {
      LoggerService.warning('未找到字体ID: $fontId，使用默认字体');
      return availableFonts.first; // 返回默认字体
    }
  }

  /// 获取当前字体的TextStyle函数
  static Future<TextStyle Function({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  })> getCurrentTextStyleFunction() async {
    final fontId = await getCurrentFontId();
    final fontChoice = getFontChoiceById(fontId);
    
    // 添加字体加载错误处理
    try {
      return fontChoice?.getTextStyle ?? _getFallbackTextStyle;
    } catch (e) {
      LoggerService.warning('字体加载失败，使用回退字体: $e');
      return _getFallbackTextStyle;
    }
  }

  /// 回退字体样式（使用系统等宽字体）
  static TextStyle _getFallbackTextStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Courier New', // 系统等宽字体
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// 根据字体ID获取TextTheme
  static TextTheme getTextTheme(BuildContext context, String fontId) {
    final fontChoice = getFontChoiceById(fontId);
    if (fontChoice == null) {
      return _getFallbackTextTheme(context);
    }
    
    try {
      // 根据字体类型创建TextTheme
      switch (fontChoice.id) {
        case 'vt323':
          return GoogleFonts.vt323TextTheme(Theme.of(context).textTheme);
        case 'press_start_2p':
          return GoogleFonts.pressStart2pTextTheme(Theme.of(context).textTheme);
        case 'orbitron':
          return GoogleFonts.orbitronTextTheme(Theme.of(context).textTheme);
        case 'share_tech_mono':
          return GoogleFonts.shareTechMonoTextTheme(Theme.of(context).textTheme);
        case 'courier_prime':
          return GoogleFonts.courierPrimeTextTheme(Theme.of(context).textTheme);
        case 'source_code_pro':
          return GoogleFonts.sourceCodeProTextTheme(Theme.of(context).textTheme);
        case 'fira_code':
          return GoogleFonts.firaCodeTextTheme(Theme.of(context).textTheme);
        case 'inconsolata':
          return GoogleFonts.inconsolataTextTheme(Theme.of(context).textTheme);
        case 'major_mono_display':
          return GoogleFonts.majorMonoDisplayTextTheme(Theme.of(context).textTheme);
        case 'nova_mono':
          return GoogleFonts.novaMonoTextTheme(Theme.of(context).textTheme);
        default:
          return _getFallbackTextTheme(context);
      }
    } catch (e) {
      LoggerService.warning('Google Fonts加载失败，使用回退字体: $e');
      return _getFallbackTextTheme(context);
    }
  }

  /// 回退TextTheme（使用系统等宽字体）
  static TextTheme _getFallbackTextTheme(BuildContext context) {
    final baseTheme = Theme.of(context).textTheme;
    return TextTheme(
      displayLarge: baseTheme.displayLarge?.copyWith(fontFamily: 'Courier New'),
      displayMedium: baseTheme.displayMedium?.copyWith(fontFamily: 'Courier New'),
      displaySmall: baseTheme.displaySmall?.copyWith(fontFamily: 'Courier New'),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontFamily: 'Courier New'),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontFamily: 'Courier New'),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontFamily: 'Courier New'),
      titleLarge: baseTheme.titleLarge?.copyWith(fontFamily: 'Courier New'),
      titleMedium: baseTheme.titleMedium?.copyWith(fontFamily: 'Courier New'),
      titleSmall: baseTheme.titleSmall?.copyWith(fontFamily: 'Courier New'),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontFamily: 'Courier New'),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontFamily: 'Courier New'),
      bodySmall: baseTheme.bodySmall?.copyWith(fontFamily: 'Courier New'),
      labelLarge: baseTheme.labelLarge?.copyWith(fontFamily: 'Courier New'),
      labelMedium: baseTheme.labelMedium?.copyWith(fontFamily: 'Courier New'),
      labelSmall: baseTheme.labelSmall?.copyWith(fontFamily: 'Courier New'),
    );
  }

  /// 检查字体是否可用（用于调试）
  static Future<void> validateFonts() async {
    LoggerService.debug('开始验证字体可用性');
    for (final font in availableFonts) {
      try {
        // 尝试创建TextStyle来验证字体是否可用
        font.getTextStyle(fontSize: 16);
        LoggerService.debug('字体验证成功: ${font.name} (${font.id})');
      } catch (e) {
        LoggerService.warning('字体验证失败: ${font.name} (${font.id}) - $e');
        LoggerService.info('将使用回退字体: Courier New');
      }
    }
    LoggerService.debug('字体验证完成');
  }
}
