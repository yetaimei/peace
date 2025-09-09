import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_page.dart';
import 'answer_display_page.dart';

void main() {
  // 设置全屏模式
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
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

  // 预设的答案列表（模拟HTML中的答案）
  final List<String> _answers = [
    '是的',
    '不是',
    '也许',
    '当然',
    '绝对不是',
    '很有可能',
    '问问你的心',
    '现在还不是时候',
    '专心致志',
    '毫无疑问',
    '我的回答是否定的',
    '我的消息来源说不',
    '前景不明朗，再问一次',
    '再问一次',
    '最好现在不要告诉你',
    '无法预测',
    '专注然后再问',
    '不要依赖它',
    '你可以依靠它',
    '绝对是的'
  ];

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _getAnswer() async {
    if (_questionController.text.isNotEmpty && !_isSearchingAnswer) {
      final random = Random();
      final answer = _answers[random.nextInt(_answers.length)];
      
      // 开始搜索动画
      setState(() {
        _isSearchingAnswer = true;
      });
      
      // 启动动画并重复
      _animationController.repeat(reverse: true);
      
      // 等待3秒，模拟搜索过程
      await Future.delayed(const Duration(seconds: 3));
      
      // 停止动画
      _animationController.stop();
      _animationController.reset();
      
      setState(() {
        _isSearchingAnswer = false;
      });
      
      // 导航到答案显示页面（从下方弹出）
      if (mounted) {
        Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AnswerDisplayPage(
            answer: answer,
            question: _questionController.text,
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
      
      // 清空输入框
      _questionController.clear();
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
                  Icon(
                    Icons.favorite_border,
                    size: 32,
                    color: const Color(0xFF1A1A1A),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
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
                                  color: _isSearchingAnswer 
                                      ? Color.lerp(
                                          const Color(0xFF1A1A1A),
                                          const Color(0xFF4CAF50),
                                          _pulseAnimation.value * 0.5,
                                        )
                                      : const Color(0xFF1A1A1A),
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
                                      ? '正在为您寻找答案...'
                                      : '请在心中默念你的问题，然后按下按钮',
                                  key: ValueKey(_isSearchingAnswer),
                                  style: GoogleFonts.vt323(
                                    fontSize: 14,
                                    color: _isSearchingAnswer 
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF1A1A1A),
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
                        _isSearchingAnswer ? '搜索中...' : '获取答案',
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
