import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../answer_display_page.dart';

/// 主题布局组件类
/// 包含所有不同主题的专属布局设计
class ThemeLayouts {
  
  // 2. Matrix布局 - 代码雨效果
  static Widget buildMatrixLayout(PixelTheme theme, String answer) {
    return Stack(
      children: [
        // 左侧代码流
        Positioned(
          left: 20,
          top: 100,
          child: Column(
            children: List.generate(8, (index) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  ['[OK]', '>>>>', 'RUN', '+++', '===', '---', '...', '###'][index],
                  style: GoogleFonts.vt323(
                    fontSize: 12,
                    color: theme.textColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ),
        // 右侧代码流
        Positioned(
          right: 20,
          top: 150,
          child: Column(
            children: List.generate(6, (index) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  ['001', '010', '100', '111', '000', '101'][index],
                  style: GoogleFonts.vt323(
                    fontSize: 14,
                    color: theme.textColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ),
        // 中央终端窗口
        Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              border: Border.all(color: theme.borderColor, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(theme.icon, size: 20, color: theme.textColor),
                    const SizedBox(width: 8),
                    Text(
                      'SYSTEM_ANSWER.EXE',
                      style: GoogleFonts.vt323(
                        fontSize: 14,
                        color: theme.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '> $answer',
                  style: GoogleFonts.vt323(
                    fontSize: 32,
                    color: theme.textColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '> PROCESS COMPLETE_',
                  style: GoogleFonts.vt323(
                    fontSize: 12,
                    color: theme.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. 赛博朋克布局 - 科技界面
  static Widget buildCyberpunkLayout(PixelTheme theme, String answer) {
    return Stack(
      children: [
        // 左上角状态指示器
        Positioned(
          top: 120,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor, width: 1),
              color: theme.backgroundColor.withValues(alpha: 0.8),
            ),
            child: Column(
              children: [
                Icon(Icons.circle, size: 8, color: theme.textColor),
                const SizedBox(height: 4),
                Text('ONLINE', style: GoogleFonts.vt323(fontSize: 8, color: theme.textColor)),
              ],
            ),
          ),
        ),
        // 右上角数据流
        Positioned(
          top: 140,
          right: 20,
          child: Column(
            children: [
              ...List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: 60,
                height: 2,
                color: theme.textColor.withValues(alpha: 0.3 + i * 0.2),
              )),
            ],
          ),
        ),
        // 主要HUD界面
        Center(
          child: Stack(
            children: [
              // 主容器
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.9),
                  border: Border.all(color: theme.borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.textColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 顶部状态栏
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NEURAL_LINK',
                          style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor),
                        ),
                        Icon(theme.icon, size: 16, color: theme.textColor),
                        Text(
                          '█████ 100%',
                          style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 答案显示区
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.borderColor, width: 1),
                        color: theme.backgroundColor.withValues(alpha: 0.5),
                      ),
                      child: Text(
                        answer.toUpperCase(),
                        style: GoogleFonts.vt323(
                          fontSize: 28,
                          color: theme.textColor,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // 左下角装饰
              Positioned(
                bottom: -8,
                left: -8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.borderColor, width: 2),
                    color: theme.backgroundColor,
                  ),
                ),
              ),
              // 右上角装饰
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.borderColor, width: 2),
                    color: theme.backgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. 复古布局 - 80年代电视机风格
  static Widget buildRetroLayout(PixelTheme theme, String answer) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 电视机顶部
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: theme.borderColor, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.radio_button_checked, size: 12, color: theme.textColor),
                  Icon(theme.icon, size: 20, color: theme.textColor),
                  Icon(Icons.radio_button_checked, size: 12, color: theme.textColor),
                ],
              ),
            ),
            // 屏幕区域
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // 扫描线效果装饰
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: theme.textColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    answer,
                    style: GoogleFonts.vt323(
                      fontSize: 32,
                      color: theme.textColor,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: theme.textColor.withValues(alpha: 0.5),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: theme.textColor.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. 海洋布局 - 波浪层叠效果
  static Widget buildOceanLayout(PixelTheme theme, String answer) {
    return Stack(
      children: [
        // 背景波浪装饰
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  theme.textColor.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
        // 主要内容区域
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 波纹效果图标
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.borderColor, width: 3),
                  color: theme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.textColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  theme.icon,
                  size: 48,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 32),
              // 流动的答案容器
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: theme.borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      offset: const Offset(0, 8),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Text(
                  answer,
                  style: GoogleFonts.vt323(
                    fontSize: 30,
                    color: theme.textColor,
                    letterSpacing: 1.8,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // 顶部装饰气泡
        ...List.generate(3, (index) => Positioned(
          top: 80 + index * 40.0,
          left: 20 + index * 30.0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.textColor.withValues(alpha: 0.3),
            ),
          ),
        )),
      ],
    );
  }

  // 6. 可爱布局 - 卡片式设计
  static Widget buildKawaiiLayout(PixelTheme theme, String answer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 可爱的顶部装饰
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, size: 20, color: theme.textColor.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Icon(theme.icon, size: 32, color: theme.textColor),
              const SizedBox(width: 8),
              Icon(Icons.star, size: 20, color: theme.textColor.withValues(alpha: 0.7)),
            ],
          ),
          const SizedBox(height: 24),
          // 主要卡片
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  offset: const Offset(6, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: theme.textColor.withValues(alpha: 0.1),
                  offset: const Offset(-2, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                // 装饰性分割线
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  answer,
                  style: GoogleFonts.vt323(
                    fontSize: 32,
                    color: theme.textColor,
                    letterSpacing: 1.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 底部小装饰
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.textColor.withValues(alpha: 0.4 + index * 0.1),
              ),
            )),
          ),
        ],
      ),
    );
  }

  // 7. 自然布局 - 有机形状
  static Widget buildNatureLayout(PixelTheme theme, String answer) {
    return Stack(
      children: [
        // 背景有机装饰
        ...List.generate(6, (index) => Positioned(
          top: 100 + index * 60.0,
          left: 30 + (index % 2) * 200.0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.textColor.withValues(alpha: 0.2),
            ),
          ),
        )),
        // 主要内容
        Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 自然风格的图标容器
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.borderColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    theme.icon,
                    size: 40,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 32),
                // 有机形状的文本容器
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(32),
                    ),
                    border: Border.all(color: theme.borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor,
                        offset: const Offset(4, 8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Text(
                    answer,
                    style: GoogleFonts.vt323(
                      fontSize: 30,
                      color: theme.textColor,
                      letterSpacing: 1.2,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 8. 奢华布局 - 对称几何设计
  static Widget buildLuxuryLayout(PixelTheme theme, String answer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 顶部装饰边框
          Container(
            width: 200,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.borderColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 钻石型图标容器
          Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                border: Border.all(color: theme.borderColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor,
                    offset: const Offset(8, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: -pi / 4,
                child: Icon(
                  theme.icon,
                  size: 32,
                  color: theme.textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 主要文本容器
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              border: Border.all(color: theme.borderColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  offset: const Offset(12, 12),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // 顶部装饰
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 20, height: 2, color: theme.borderColor),
                    const SizedBox(width: 12),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.borderColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 20, height: 2, color: theme.borderColor),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  answer.toUpperCase(),
                  style: GoogleFonts.vt323(
                    fontSize: 32,
                    color: theme.textColor,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // 底部装饰
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 20, height: 2, color: theme.borderColor),
                    const SizedBox(width: 12),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.borderColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 20, height: 2, color: theme.borderColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 底部装饰边框
          Container(
            width: 200,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.borderColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 9. 终端布局 - 命令行风格
  static Widget buildTerminalLayout(PixelTheme theme, String answer) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          border: Border.all(color: theme.borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 终端标题栏
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
                  const SizedBox(width: 6),
                  Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.yellow)),
                  const SizedBox(width: 6),
                  Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                  const SizedBox(width: 16),
                  Text('Terminal', style: GoogleFonts.vt323(fontSize: 14, color: theme.textColor)),
                ],
              ),
            ),
            // 终端内容 - 居中显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'user@system:~\$ fortune',
                    style: GoogleFonts.vt323(fontSize: 14, color: theme.textColor.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    answer,
                    style: GoogleFonts.vt323(fontSize: 32, color: theme.textColor, letterSpacing: 1.2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'user@system:~\$ ',
                        style: GoogleFonts.vt323(fontSize: 14, color: theme.textColor.withValues(alpha: 0.7)),
                      ),
                      Container(
                        width: 8,
                        height: 16,
                        color: theme.textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 10. Game Boy布局 - 掌机风格
  static Widget buildGameBoyLayout(PixelTheme theme, String answer) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor, width: 4),
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
            // Game Boy屏幕
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.borderColor, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NINTENDO', style: GoogleFonts.vt323(fontSize: 10, color: theme.textColor)),
                      Icon(theme.icon, size: 16, color: theme.textColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    answer.toUpperCase(),
                    style: GoogleFonts.vt323(fontSize: 24, color: theme.textColor, letterSpacing: 2.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // 像素化装饰
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 4,
                      height: 4,
                      color: theme.textColor.withValues(alpha: 0.3 + (index % 3) * 0.2),
                    )),
                  ),
                ],
              ),
            ),
            // 控制按钮装饰
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.backgroundColor,
                      border: Border.all(color: theme.borderColor, width: 2),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.backgroundColor,
                      border: Border.all(color: theme.borderColor, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 11. Kindle布局 - 电纸书风格
  static Widget buildKindleLayout(PixelTheme theme, String answer) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          border: Border.all(color: theme.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kindle顶部状态栏
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(theme.icon, size: 20, color: theme.textColor),
                  Text('85%', style: GoogleFonts.vt323(fontSize: 14, color: theme.textColor)),
                ],
              ),
            ),
            // 书籍内容区域 - 完全居中
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 章节装饰
                  Container(
                    width: 60,
                    height: 2,
                    color: theme.borderColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    answer,
                    style: GoogleFonts.vt323(
                      fontSize: 32,
                      color: theme.textColor,
                      height: 1.5,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 60,
                    height: 2,
                    color: theme.borderColor,
                  ),
                ],
              ),
            ),
            // 页码
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.borderColor, width: 1)),
              ),
              child: Text(
                'Page 42 of 108',
                style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 12. VHS布局 - 录像带风格
  static Widget buildVhsLayout(PixelTheme theme, String answer) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.borderColor, width: 3),
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
            // VHS标签区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                border: Border(
                  bottom: BorderSide(color: theme.borderColor, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('VHS', style: GoogleFonts.vt323(fontSize: 16, color: theme.textColor)),
                  Icon(theme.icon, size: 20, color: theme.textColor),
                  Text('STEREO', style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor)),
                ],
              ),
            ),
            // 主要显示区域
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // 时间码装饰
                  Text(
                    '00:42:08',
                    style: GoogleFonts.vt323(fontSize: 16, color: theme.textColor.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 24),
                  // 扫描线效果
                  ...List.generate(3, (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: double.infinity,
                    height: 1,
                    color: theme.textColor.withValues(alpha: 0.2),
                  )),
                  const SizedBox(height: 16),
                  Text(
                    answer,
                    style: GoogleFonts.vt323(
                      fontSize: 28,
                      color: theme.textColor,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: theme.textColor.withValues(alpha: 0.3),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(3, (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: double.infinity,
                    height: 1,
                    color: theme.textColor.withValues(alpha: 0.2),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 13. 计算器布局 - 数字显示风格
  static Widget buildCalculatorLayout(PixelTheme theme, String answer) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 计算器显示屏
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                border: Border.all(color: theme.borderColor, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CASIO',
                    style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    answer,
                    style: GoogleFonts.vt323(
                      fontSize: 32,
                      color: theme.textColor,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            // 计算器按键装饰
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(16, (index) {
                  final labels = ['C', '±', '%', '÷', '7', '8', '9', '×', '4', '5', '6', '-', '1', '2', '3', '+'];
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      border: Border.all(color: theme.borderColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 14. 传呼机布局 - BP机风格
  static Widget buildPagerLayout(PixelTheme theme, String answer) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.borderColor, width: 3),
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
            // BP机顶部
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                ),
                border: Border(
                  bottom: BorderSide(color: theme.borderColor, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(theme.icon, size: 16, color: theme.textColor),
                  Text('MOTOROLA', style: GoogleFonts.vt323(fontSize: 10, color: theme.textColor)),
                  Text('12:34', style: GoogleFonts.vt323(fontSize: 10, color: theme.textColor)),
                ],
              ),
            ),
            // BP机显示屏
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 信号指示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MSG', style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor)),
                      Row(
                        children: List.generate(4, (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 4,
                          height: 8 + index * 2,
                          color: theme.textColor.withValues(alpha: index < 3 ? 1.0 : 0.3),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 消息内容
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      border: Border.all(color: theme.borderColor, width: 1),
                    ),
                    child: Text(
                      answer.toUpperCase(),
                      style: GoogleFonts.vt323(
                        fontSize: 24,
                        color: theme.textColor,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1/1 NEW',
                    style: GoogleFonts.vt323(fontSize: 10, color: theme.textColor.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 15. 收音机布局 - 电台风格
  static Widget buildRadioTunerLayout(PixelTheme theme, String answer) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 收音机顶部
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(color: theme.borderColor, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(theme.icon, size: 24, color: theme.textColor),
                  Text('FM 108.8', style: GoogleFonts.vt323(fontSize: 16, color: theme.textColor)),
                  Text('STEREO', style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor)),
                ],
              ),
            ),
            // 调频显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                children: [
                  // 频率刻度装饰
                  Container(
                    width: double.infinity,
                    height: 20,
                    child: CustomPaint(
                      painter: RadioScalePainter(theme.textColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 电台信息
                  Text(
                    'NOW PLAYING',
                    style: GoogleFonts.vt323(fontSize: 12, color: theme.textColor.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    answer,
                    style: GoogleFonts.vt323(
                      fontSize: 28,
                      color: theme.textColor,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // 音量指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('VOL', style: GoogleFonts.vt323(fontSize: 10, color: theme.textColor)),
                      const SizedBox(width: 8),
                      ...List.generate(10, (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 4,
                        height: 12,
                        color: theme.textColor.withValues(alpha: index < 7 ? 1.0 : 0.3),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 16. 辉光管布局 - 数码管风格
  static Widget buildNixieLayout(PixelTheme theme, String answer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 辉光管装饰边框
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                border: Border.all(color: theme.borderColor, width: 3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: theme.textColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 辉光管顶部装饰
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.textColor.withValues(alpha: 0.6),
                        boxShadow: [
                          BoxShadow(
                            color: theme.textColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                  // 主要显示区域
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: theme.borderColor, width: 2),
                    ),
                    child: Text(
                      answer.toUpperCase(),
                      style: GoogleFonts.vt323(
                        fontSize: 36,
                        color: theme.textColor,
                        letterSpacing: 3.0,
                        shadows: [
                          Shadow(
                            color: theme.textColor.withValues(alpha: 0.8),
                            blurRadius: 12,
                          ),
                          Shadow(
                            color: theme.textColor.withValues(alpha: 0.4),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 底部装饰
                  Text(
                    'NIXIE TUBE DISPLAY',
                    style: GoogleFonts.vt323(
                      fontSize: 10,
                      color: theme.textColor.withValues(alpha: 0.6),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 收音机刻度画笔
class RadioScalePainter extends CustomPainter {
  final Color color;
  
  RadioScalePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    // 绘制刻度线
    for (int i = 0; i <= 20; i++) {
      final x = (size.width / 20) * i;
      final height = i % 5 == 0 ? 8.0 : 4.0;
      canvas.drawLine(
        Offset(x, size.height - height),
        Offset(x, size.height),
        paint,
      );
    }

    // 绘制指针
    final pointerPaint = Paint()
      ..color = color
      ..strokeWidth = 2;
    
    final pointerX = size.width * 0.6;
    canvas.drawLine(
      Offset(pointerX, 0),
      Offset(pointerX, size.height),
      pointerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
