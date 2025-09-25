import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetThemePage extends StatefulWidget {
  const WidgetThemePage({super.key});

  @override
  State<WidgetThemePage> createState() => _WidgetThemePageState();
}

class _WidgetThemePageState extends State<WidgetThemePage> {
  static const _platform = MethodChannel('com.leilei.peace/widget_sync');
  String _widgetTheme = 'stitchA';

  Future<void> _setWidgetTheme(String theme) async {
    setState(() => _widgetTheme = theme);
    try {
      await _platform.invokeMethod('setWidgetTheme', {'theme': theme});
    } catch (e) {
      // 忽略打印，保持页面简洁
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0D8),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 350),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          '小组件主题',
                          style: GoogleFonts.vt323(
                            fontSize: 28,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _optionButton('跟随系统主题', 'stitchA'),
                        const SizedBox(height: 12),
                        _buildMoreThemesItem(),
                        const SizedBox(height: 24),
                        Text(
                          '更改后小组件会自动刷新展示效果',
                          style: GoogleFonts.vt323(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(String label, String value) {
    final bool selected = _widgetTheme == value;
    return GestureDetector(
      onTap: () async {
        await _setWidgetTheme(value);
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0D8),
          border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1A1A1A),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.vt323(
                fontSize: 24,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check,
                color: Color(0xFF1A1A1A),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /// 构建"更多主题"项
  Widget _buildMoreThemesItem() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(
          color: Colors.grey[400]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400]!,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '更多主题',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.vt323(
                          fontSize: 24,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        border: Border.all(
                          color: Colors.orange[300]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '正在开发中',
                        style: GoogleFonts.vt323(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'email给开发者功能许愿',
                  style: GoogleFonts.vt323(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '敬请期待',
                      style: GoogleFonts.vt323(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            color: Colors.grey[400],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 32,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '小组件设置',
                style: GoogleFonts.vt323(
                  fontSize: 40,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}


