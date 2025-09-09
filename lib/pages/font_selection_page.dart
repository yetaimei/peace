import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/font_service.dart';
import '../services/logger_service.dart';
import '../components/pixel_dialog.dart';

class FontSelectionPage extends StatefulWidget {
  const FontSelectionPage({super.key});

  @override
  State<FontSelectionPage> createState() => _FontSelectionPageState();
}

class _FontSelectionPageState extends State<FontSelectionPage> {
  String _currentFontId = '';
  String _selectedFontId = '';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentFont();
  }

  Future<void> _loadCurrentFont() async {
    final fontId = await FontService.getCurrentFontId();
    setState(() {
      _currentFontId = fontId;
      _selectedFontId = fontId;
    });
    LoggerService.debug('字体选择页面-加载当前字体: $fontId');
  }

  void _selectFont(String fontId) {
    setState(() {
      _selectedFontId = fontId;
      _hasChanges = _selectedFontId != _currentFontId;
    });
    LoggerService.debug('用户临时选择字体: $fontId');
  }

  Future<void> _saveFont() async {
    if (!_hasChanges) {
      Navigator.of(context).pop(false);
      return;
    }

    final success = await FontService.setCurrentFont(_selectedFontId);
    if (success) {
      LoggerService.userAction('用户保存字体设置', {
        'fromFont': _currentFontId,
        'toFont': _selectedFontId,
      });
      
      if (mounted) {
        PixelDialogExtended.show(
          context,
          '字体设置已保存',
          type: PixelDialogType.success,
          duration: const Duration(seconds: 1),
        );
        
        // 等待提示显示完成再返回
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } else {
      LoggerService.error('保存字体设置失败', 'FONT_SELECTION');
      if (mounted) {
        PixelDialogExtended.show(
          context,
          '保存失败，请重试',
          type: PixelDialogType.error,
        );
      }
    }
  }

  void _discardChanges() {
    if (_hasChanges) {
      setState(() {
        _selectedFontId = _currentFontId;
        _hasChanges = false;
      });
      LoggerService.debug('用户放弃字体更改');
    }
    Navigator.of(context).pop(false);
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
          child: Column(
            children: [
              // 顶部标题栏
              _buildHeader(),
              
              // 字体列表
              Expanded(
                child: _buildFontList(),
              ),
              
              // 底部按钮
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.0,
        MediaQuery.of(context).padding.top + 20.0,
        20.0,
        20.0,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1A1A1A),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _discardChanges,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0D8),
                border: Border.all(
                  color: const Color(0xFF1A1A1A),
                  width: 2,
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0xFF1A1A1A),
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 24,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '选择字体',
              style: GoogleFonts.vt323(
                fontSize: 28,
                color: const Color(0xFF1A1A1A),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: FontService.availableFonts.length,
      itemBuilder: (context, index) {
        final font = FontService.availableFonts[index];
        final isSelected = font.id == _selectedFontId;
        final isCurrent = font.id == _currentFontId;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () => _selectFont(font.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0D8),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                    offset: Offset(isSelected ? 2 : 1, isSelected ? 2 : 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 左侧字体名称和状态
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                font.name,
                                style: GoogleFonts.vt323(
                                  fontSize: 18,
                                  color: const Color(0xFF1A1A1A),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrent) 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0D8),
                                  border: Border.all(
                                    color: const Color(0xFF1A1A1A),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '当前',
                                  style: GoogleFonts.vt323(
                                    fontSize: 10,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // 右侧预览和选中状态
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0D8),
                              border: Border.all(
                                color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '答案之书',
                              style: font.getTextStyle(
                                fontSize: 14,
                                color: const Color(0xFF1A1A1A),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isSelected)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              border: Border.all(
                                color: const Color(0xFF1A1A1A),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFFE0E0D8),
                              size: 14,
                            ),
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0D8),
                              border: Border.all(
                                color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0D8),
        border: Border(
          top: BorderSide(
            color: Color(0xFF1A1A1A),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 取消按钮
            Expanded(
              child: GestureDetector(
                onTap: _discardChanges,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0D8),
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 1,
                    ),
                    boxShadow: [
                      const BoxShadow(
                        color: Color(0xFF1A1A1A),
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    '取消',
                    style: GoogleFonts.vt323(
                      fontSize: 16,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            
            // 保存按钮
            Expanded(
              child: GestureDetector(
                onTap: _saveFont,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  margin: const EdgeInsets.only(left: 8.0),
                  decoration: BoxDecoration(
                    color: _hasChanges 
                        ? const Color(0xFFE0E0D8)
                        : const Color(0xFFE0E0D8).withValues(alpha: 0.5),
                    border: Border.all(
                      color: _hasChanges 
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                      width: _hasChanges ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _hasChanges 
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                        offset: Offset(_hasChanges ? 2 : 1, _hasChanges ? 2 : 1),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    '保存',
                    style: GoogleFonts.vt323(
                      fontSize: 16,
                      color: _hasChanges 
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                      fontWeight: _hasChanges ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
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
