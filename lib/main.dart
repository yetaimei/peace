import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';
import 'answer_display_page.dart';
import 'answer_history_page.dart';
import 'services/logger_service.dart';
import 'services/answer_library_service.dart';
import 'services/font_service.dart';
import 'data/answer_libraries.dart';

void main() {
  // 设置全屏模式
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  LoggerService.info('应用启动', 'APP_LIFECYCLE');
  
  runApp(const BookOfAnswersApp());
}

class BookOfAnswersApp extends StatefulWidget {
  const BookOfAnswersApp({super.key});

  @override
  State<BookOfAnswersApp> createState() => _BookOfAnswersAppState();
}

class _BookOfAnswersAppState extends State<BookOfAnswersApp> {
  String _currentFontId = 'vt323';

  @override
  void initState() {
    super.initState();
    _loadCurrentFont();
    _syncDataToWidget();
  }

  Future<void> _loadCurrentFont() async {
    final fontId = await FontService.getCurrentFontId();
    if (mounted) {
      setState(() {
        _currentFontId = fontId;
      });
      LoggerService.info('应用启动-加载字体: $fontId', 'APP_LIFECYCLE');
    }
  }

  Future<void> _syncDataToWidget() async {
    try {
      LoggerService.info('开始同步数据到Widget...', 'APP_LIFECYCLE');
      await AnswerLibraryService.syncToWidget();
      LoggerService.info('应用启动-同步数据到Widget成功', 'APP_LIFECYCLE');
    } catch (e) {
      LoggerService.error('应用启动-同步数据到Widget失败: $e', 'APP_LIFECYCLE');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '答案之书',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE0E0D8),
        textTheme: FontService.getTextTheme(context, _currentFontId).apply(
          bodyColor: const Color(0xFF1A1A1A),
          displayColor: const Color(0xFF1A1A1A),
        ),
      ),
      home: BookOfAnswersPage(onFontChanged: _loadCurrentFont),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BookOfAnswersPage extends StatefulWidget {
  final VoidCallback? onFontChanged;
  
  const BookOfAnswersPage({super.key, this.onFontChanged});

  @override
  State<BookOfAnswersPage> createState() => _BookOfAnswersPageState();
}

class _BookOfAnswersPageState extends State<BookOfAnswersPage> 
    with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  bool _isSearchingAnswer = false;
  late AnimationController _animationController;
  late Animation<double> _pixelWaveAnimation;
  late Animation<double> _scanLineAnimation;
  
  // 当前答案库信息
  AnswerLibrary? _currentLibrary;
  String _currentLibraryName = '加载中...';
  
  // 当前字体信息
  TextStyle Function({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) _currentTextStyle = GoogleFonts.vt323;

  // 像素动画相关
  late Animation<double> _matrixAnimation;

  @override
  void initState() {
    super.initState();
    LoggerService.info('主页面初始化', 'PAGE_LIFECYCLE');
    
    // 动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // 像素波浪动画 - 模拟数据流动
    _pixelWaveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    // 扫描线动画 - 从上到下扫描
    _scanLineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    
    // 矩阵动画 - 模拟数字雨效果
    _matrixAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    
    // 加载当前答案库和字体
    _loadCurrentLibrary();
    _loadCurrentFont();
  }

  @override
  void dispose() {
    LoggerService.info('主页面销毁', 'PAGE_LIFECYCLE');
    _animationController.dispose();
    _questionController.dispose();
    super.dispose();
  }
  
  /// 加载当前选中的答案库
  Future<void> _loadCurrentLibrary() async {
    try {
      final library = await AnswerLibraryService.getCurrentLibrary();
      if (mounted) {
        setState(() {
          _currentLibrary = library;
          _currentLibraryName = library?.name ?? '未知答案库';
        });
        LoggerService.info('加载答案库成功: ${library?.name} (${library?.answers.length}条答案)', 'ANSWER_LIBRARY');
      }
    } catch (e) {
      LoggerService.error('加载答案库失败: $e', 'ANSWER_LIBRARY');
      if (mounted) {
        setState(() {
          _currentLibraryName = '加载失败';
        });
      }
    }
  }

  /// 加载当前选中的字体
  Future<void> _loadCurrentFont() async {
    try {
      final textStyle = await FontService.getCurrentTextStyleFunction();
      if (mounted) {
        setState(() {
          _currentTextStyle = textStyle;
        });
        LoggerService.debug('主页面-字体加载成功');
      }
    } catch (e) {
      LoggerService.error('加载字体失败: $e', 'FONT_LOAD');
    }
  }

  Future<void> _saveAnswerToHistory(String question, String answer) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      LoggerService.dataOperation('开始保存答案历史', {
        'question': question.length > 20 ? '${question.substring(0, 20)}...' : question,
        'answer': answer,
      });
      
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('answer_history') ?? [];
      
      final newItem = {
        'question': question,
        'answer': answer,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      historyJson.add(jsonEncode(newItem));
      
      // 保持最多100条记录
      if (historyJson.length > 1000) {
        historyJson.removeAt(0);
        LoggerService.debug('清理历史记录，保持最多1000条');
      }
      
      await prefs.setStringList('answer_history', historyJson);
      
      stopwatch.stop();
      LoggerService.performance('保存答案历史', stopwatch.elapsed, {
        'totalRecords': historyJson.length,
      });
      
    } catch (e, stackTrace) {
      stopwatch.stop();
      LoggerService.error('保存答案历史失败', 'DATA_OPERATION', e, stackTrace);
    }
  }

  void _getAnswer() async {
    if (_questionController.text.isNotEmpty && !_isSearchingAnswer) {
      final question = _questionController.text;
      
      // 使用答案库服务获取答案
      final answer = await AnswerLibraryService.getRandomAnswer();
      
      LoggerService.userAction('用户获取答案', {
        'question': question.length > 20 ? '${question.substring(0, 20)}...' : question,
        'questionLength': question.length,
      });
      
      // 立即清空输入框，避免用户重复点击
      _questionController.clear();
      
      // 开始搜索动画
      setState(() {
        _isSearchingAnswer = true;
      });
      LoggerService.debug('开始答案搜索动画');
      
      // 启动动画并循环
      _animationController.repeat();
      
      // 等待3秒，模拟搜索过程
      final searchStartTime = DateTime.now();
      await Future.delayed(const Duration(seconds: 3));
      final searchDuration = DateTime.now().difference(searchStartTime);
      
      // 停止动画
      _animationController.stop();
      _animationController.reset();
      
      setState(() {
        _isSearchingAnswer = false;
      });
      LoggerService.debug('答案搜索动画结束');
      
      // 保存到历史记录（在导航之前保存）
      await _saveAnswerToHistory(question, answer);
      
      LoggerService.userAction('获取到答案', {
        'answer': answer,
        'searchDuration': '${searchDuration.inMilliseconds}ms',
      });
      
      // 导航到答案显示页面（从下方弹出）
      if (mounted) {
        LoggerService.navigation('主页面', '答案显示页面', '从下方弹出');
        Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AnswerDisplayPage(
            answer: answer,
            question: question,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // 从下方开始
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      }
    } else {
      if (_questionController.text.isEmpty) {
        LoggerService.warning('用户尝试获取答案但问题为空');
      }
      if (_isSearchingAnswer) {
        LoggerService.warning('用户尝试重复获取答案');
      }
    }
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
          child: GestureDetector(
            onPanEnd: (details) {
              // 检测水平滑动手势
              if (details.velocity.pixelsPerSecond.dx > 300) {
                // 向右滑动 - 呼出历史答案页面
                LoggerService.userAction('向右滑动手势 - 打开历史页面');
                LoggerService.navigation('主页面', '答案历史页面', '向右滑动手势');
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => 
                        const AnswerHistoryPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0); // 从左侧开始
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              } else if (details.velocity.pixelsPerSecond.dx < -300) {
                // 向左滑动 - 呼出设置页面
                LoggerService.userAction('向左滑动手势 - 打开设置页面');
                LoggerService.navigation('主页面', '设置页面', '向左滑动手势');
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => 
                        const SettingsPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // 从右侧开始
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(
                        CurveTween(curve: curve),
                      );

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ).then((_) {
                  // 从设置页面返回后，重新加载答案库和检查字体变更
                  _loadCurrentLibrary();
                  _loadCurrentFont();
                  if (widget.onFontChanged != null) {
                    widget.onFontChanged!();
                  }
                });
              }
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.0, MediaQuery.of(context).padding.top + 16.0, 16.0, 16.0),
              child: Column(
                children: [
              // 顶部图标区域
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      LoggerService.userAction('点击左上角历史按钮');
                      LoggerService.navigation('主页面', '答案历史页面', '从左侧滑入');
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                              const AnswerHistoryPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0); // 从左侧开始
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(
                              CurveTween(curve: curve),
                            );

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: const Icon(
                        Icons.notes,
                        size: 32,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      LoggerService.userAction('点击右上角设置按钮');
                      LoggerService.navigation('主页面', '设置页面', '普通跳转');
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                      // 从设置页面返回后，重新加载答案库和检查字体变更
                      _loadCurrentLibrary();
                      _loadCurrentFont();
                      if (widget.onFontChanged != null) {
                        widget.onFontChanged!();
                      }
                    },
                    child: const Icon(
                      Icons.settings,
                      size: 32,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // 标题区域
              Column(
                children: [
                  Text(
                    'Peace and Love',
                    style: _currentTextStyle(
                      fontSize: 38,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '答案之书',
                    style: _currentTextStyle(
                      fontSize: 48,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'THE BOOK OF ANSWERS',
                    style: _currentTextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 主要内容区域 - 像素科技风格动画
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  
                  return Container(
                    width: 280,
                    height: 280,
                    child: Stack(
                      children: [
                        // 背景框架
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0D8),
                            border: Border.all(
                              color: const Color(0xFF1A1A1A),
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            painter: PixelGridPainter(
                              animationValue: _pixelWaveAnimation.value,
                              isAnimating: _isSearchingAnswer,
                            ),
                            child: Container(),
                          ),
                        ),
                        
                        // 扫描线效果
                        if (_isSearchingAnswer)
                          Positioned(
                            top: _scanLineAnimation.value * 280,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                                    const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.2, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),
                        
                        // 中心内容 - 简化版本
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 静态书本图标
                              if (!_isSearchingAnswer) ...[
                                Icon(
                                  Icons.menu_book,
                                  size: 80,
                                  color: const Color(0xFF1A1A1A),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '答案之书正在等待你的问题',
                                  style: _currentTextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              
                              // 动态扫描效果
                              if (_isSearchingAnswer) ...[
                                // 数据矩阵效果
                                Container(
                                  width: 160,
                                  height: 120,
                                  child: CustomPaint(
                                    painter: DataMatrixPainter(
                                      animationValue: _matrixAnimation.value,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '翻阅中...',
                                  style: _currentTextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // 答案显示区域（暂时隐藏，因为将在新页面显示）
              Container(
                height: 20,
                alignment: Alignment.center,
                child: Text(
                  '', // 移除直接显示的答案
                  style: GoogleFonts.vt323(
                    fontSize: 20,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 输入框
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0D8),
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 2,
                    ),
                    boxShadow: [
                      const BoxShadow(
                        color: Color(0xFF1A1A1A),
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _questionController,
                    style: _currentTextStyle(
                      fontSize: 18,
                      color: const Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '输入你的问题...',
                      hintStyle: _currentTextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 获取答案按钮
              GestureDetector(
                onTap: _isSearchingAnswer ? null : _getAnswer,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: _isSearchingAnswer 
                        ? Colors.grey[300] 
                        : const Color(0xFFE0E0D8),
                    border: Border.all(
                      color: _isSearchingAnswer 
                          ? Colors.grey[400]! 
                          : const Color(0xFF1A1A1A),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isSearchingAnswer 
                            ? Colors.grey[400]! 
                            : const Color(0xFF1A1A1A),
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSearchingAnswer) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey[600]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _isSearchingAnswer ? '翻阅中...' : '获取答案',
                        style: _currentTextStyle(
                          fontSize: 24,
                          color: _isSearchingAnswer 
                              ? Colors.grey[600] 
                              : const Color(0xFF1A1A1A),
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

// 像素网格动画画笔
class PixelGridPainter extends CustomPainter {
  final double animationValue;
  final bool isAnimating;

  PixelGridPainter({
    required this.animationValue,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isAnimating) return;

    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;

    // 绘制动态网格
    final gridSize = 8.0;
    final waveHeight = 20.0;
    
    for (double x = 0; x < size.width; x += gridSize) {
      for (double y = 0; y < size.height; y += gridSize) {
        final distanceFromCenter = ((x - size.width / 2).abs() + (y - size.height / 2).abs()) / size.width;
        final waveOffset = sin((animationValue * 2 * pi) + (distanceFromCenter * 4)) * waveHeight;
        final opacity = (0.1 + (waveOffset / waveHeight) * 0.1).clamp(0.0, 0.2);
        
        paint.color = const Color(0xFF1A1A1A).withValues(alpha: opacity);
        canvas.drawRect(
          Rect.fromLTWH(x, y, gridSize - 1, gridSize - 1),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PixelGridPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isAnimating != isAnimating;
}


// 数据矩阵画笔
class DataMatrixPainter extends CustomPainter {
  final double animationValue;

  DataMatrixPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1;

    // 绘制数据点矩阵
    final dotSize = 4.0;
    final spacing = 8.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final noise = sin(x * 0.1 + animationValue * 2 * pi) * 
                      cos(y * 0.1 + animationValue * 2 * pi);
        final opacity = (0.2 + noise * 0.3).clamp(0.0, 0.8);
        
        paint.color = const Color(0xFF1A1A1A).withValues(alpha: opacity);
        
        // 随机显示不同形状
        if ((x + y + animationValue * 100).toInt() % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, dotSize, dotSize),
            paint,
          );
        } else {
          canvas.drawCircle(
            Offset(x + dotSize / 2, y + dotSize / 2),
            dotSize / 2,
            paint,
          );
        }
      }
    }

    // 绘制连接线
    paint.strokeWidth = 0.5;
    for (int i = 0; i < 5; i++) {
      final startX = (animationValue * size.width + i * 40) % size.width;
      final startY = sin(animationValue * 2 * pi + i) * size.height / 2 + size.height / 2;
      final endX = (startX + 40) % size.width;
      final endY = sin(animationValue * 2 * pi + i + 1) * size.height / 2 + size.height / 2;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DataMatrixPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

