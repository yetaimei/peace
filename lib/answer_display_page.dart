import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'services/logger_service.dart';

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
          name: 'answer_wallpaper_${DateTime.now().millisecondsSinceEpoch}',
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                successMessage,
                style: GoogleFonts.vt323(fontSize: 16),
              ),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        LoggerService.warning('卡片保存服务-保存失败-可能是权限问题或系统错误');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '保存失败，请检查相册权限',
                style: GoogleFonts.vt323(fontSize: 16),
              ),
              backgroundColor: const Color(0xFFFF9800),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('卡片保存服务-异常', null, e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '保存图片时发生错误，请重试',
              style: GoogleFonts.vt323(fontSize: 16),
            ),
            backgroundColor: const Color(0xFFFF5722),
            duration: const Duration(seconds: 2),
          ),
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
      
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '正在保存壁纸...',
                style: GoogleFonts.vt323(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2196F3),
          duration: const Duration(seconds: 3),
        ),
      );

      // 截图
      final imageBytes = await _captureWallpaper();
      if (!mounted) return;
      
      if (imageBytes == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '截图失败，请重试',
              style: GoogleFonts.vt323(fontSize: 16),
            ),
            backgroundColor: const Color(0xFFFF5722),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // 隐藏加载提示
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // 保存到相册（插件会自动处理权限请求）
      await _saveImageToGallery(imageBytes);
      
    } catch (e) {
      LoggerService.error('保存壁纸流程异常', null, e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '保存失败，请重试',
            style: GoogleFonts.vt323(fontSize: 16),
          ),
          backgroundColor: const Color(0xFFFF5722),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 分享给好友功能
  void _shareToFriend() async {
    if (!mounted) return;
    
    try {
      LoggerService.debug('开始分享功能');
      
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '正在生成分享图片...',
                style: GoogleFonts.vt323(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2196F3),
          duration: const Duration(seconds: 3),
        ),
      );

      // 截图
      final imageBytes = await _captureWallpaper();
      if (!mounted) return;
      
      if (imageBytes == null) {
        LoggerService.error('分享时截图失败');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '生成图片失败，请重试',
              style: GoogleFonts.vt323(fontSize: 16),
            ),
            backgroundColor: const Color(0xFFFF5722),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // 保存临时文件
      LoggerService.debug('保存临时分享文件');
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/answer_wallpaper.png').create();
      await file.writeAsBytes(imageBytes);
      LoggerService.debug('临时文件已保存: ${file.path}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // 分享文件
      LoggerService.debug('调用系统分享');
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.question.isNotEmpty ? "问题: ${widget.question}\n" : ""}答案: ${widget.answer}\n\n来自《答案之书》',
        subject: '我的答案之书',
      );
      LoggerService.debug('分享完成');
    } catch (e) {
      LoggerService.error('分享失败', null, e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '分享失败，请重试',
            style: GoogleFonts.vt323(fontSize: 16),
          ),
          backgroundColor: const Color(0xFFFF5722),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0D8),
      body: Screenshot(
        controller: screenshotController,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0D8),
          ),
          child: CustomPaint(
            painter: PixelPatternPainter(),
            child: Stack(
              children: [
                // 主要内容区域 - 居中显示答案
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32.0),
                    margin: const EdgeInsets.symmetric(horizontal: 36.0),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: Color(0xFF1A1A1A),
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
                  ),
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
