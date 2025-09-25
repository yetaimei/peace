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
                        _optionButton('Stitch A', 'stitchA'),
                        const SizedBox(height: 12),
                        _optionButton('Glass', 'glass'),
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


