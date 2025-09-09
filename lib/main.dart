import 'dart:convert';
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
import 'data/answer_libraries.dart';

void main() {
  // 设置全屏模式
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  LoggerService.info('应用启动', 'APP_LIFECYCLE');
  
  runApp(const BookOfAnswersApp());
}

class BookOfAnswersApp extends StatelessWidget {
  const BookOfAnswersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '答案之书',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE0E0D8),
        textTheme: GoogleFonts.vt323TextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF1A1A1A),
          displayColor: const Color(0xFF1A1A1A),
        ),
      ),
      home: const BookOfAnswersPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BookOfAnswersPage extends StatefulWidget {
  const BookOfAnswersPage({super.key});

  @override
  State<BookOfAnswersPage> createState() => _BookOfAnswersPageState();
}

class _BookOfAnswersPageState extends State<BookOfAnswersPage> 
    with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  bool _isSearchingAnswer = false;
  late AnimationController _animationController;
  late Animation<double> _bookScaleAnimation;
  late Animation<double> _bookRotationAnimation;
  late Animation<double> _pulseAnimation;
  
  // 当前答案库信息
  AnswerLibrary? _currentLibrary;
  String _currentLibraryName = '加载中...';

  @override
  void initState() {
    super.initState();
    LoggerService.info('主页面初始化', 'PAGE_LIFECYCLE');
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 缩放动画
    _bookScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 旋转动画
    _bookRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 脉冲动画
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    ));
    
    // 加载当前答案库
    _loadCurrentLibrary();
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
      if (historyJson.length > 100) {
        historyJson.removeAt(0);
        LoggerService.debug('清理历史记录，保持最多100条');
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
      
      // 启动动画并重复
      _animationController.repeat(reverse: true);
      
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
                      LoggerService.userAction('点击左上角爱心按钮');
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
                        Icons.favorite_border,
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
                      // 从设置页面返回后，重新加载答案库
                      _loadCurrentLibrary();
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
                    style: GoogleFonts.vt323(
                      fontSize: 18,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '答案之书',
                    style: GoogleFonts.vt323(
                      fontSize: 48,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'THE BOOK OF ANSWERS',
                    style: GoogleFonts.vt323(
                      fontSize: 14,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 主要内容区域 - 书本和提示文字
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isSearchingAnswer ? _bookScaleAnimation.value : 1.0,
                    child: Transform.rotate(
                      angle: _isSearchingAnswer ? _bookRotationAnimation.value : 0.0,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0D8),
                          border: Border.all(
                            color: const Color(0xFF1A1A1A),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A1A1A),
                              offset: const Offset(4, 4),
                              blurRadius: _isSearchingAnswer ? _pulseAnimation.value * 2 : 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Transform.scale(
                                scale: _isSearchingAnswer ? _pulseAnimation.value : 1.0,
                                child: Icon(
                                  Icons.menu_book,
                                  size: 80,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _isSearchingAnswer 
                                      ? '答案之书正在翻阅古老的智慧...'
                                      : '请在心中默念你的问题，然后按下按钮',
                                  key: ValueKey(_isSearchingAnswer),
                                  style: GoogleFonts.vt323(
                                    fontSize: 14,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    style: GoogleFonts.vt323(
                      fontSize: 18,
                      color: const Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '输入你的问题...',
                      hintStyle: GoogleFonts.vt323(
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
                        style: GoogleFonts.vt323(
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
              
              // 调试信息显示
              if (kDebugMode)
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withValues(alpha: 0.3),
                    border: Border.all(color: Colors.orange, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔧 调试信息',
                        style: GoogleFonts.vt323(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '搜索状态: ${_isSearchingAnswer ? "进行中" : "空闲"}',
                        style: GoogleFonts.vt323(
                          fontSize: 12,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '问题长度: ${_questionController.text.length}字符',
                        style: GoogleFonts.vt323(
                          fontSize: 12,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '动画状态: ${_animationController.isAnimating ? "运行中" : "停止"}',
                        style: GoogleFonts.vt323(
                          fontSize: 12,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '当前答案库: $_currentLibraryName',
                        style: GoogleFonts.vt323(
                          fontSize: 12,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '答案数量: ${_currentLibrary?.answers.length ?? 0}条',
                        style: GoogleFonts.vt323(
                          fontSize: 12,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
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
