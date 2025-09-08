import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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

class _BookOfAnswersPageState extends State<BookOfAnswersPage> {
  final TextEditingController _questionController = TextEditingController();
  String _currentAnswer = '';

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

  void _getAnswer() {
    if (_questionController.text.isNotEmpty) {
      final random = Random();
      setState(() {
        _currentAnswer = _answers[random.nextInt(_answers.length)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0D8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                  Icon(
                    Icons.person,
                    size: 32,
                    color: const Color(0xFF1A1A1A),
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
                      fontSize: 24,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '答案之书',
                    style: GoogleFonts.vt323(
                      fontSize: 64,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'THE BOOK OF ANSWERS',
                    style: GoogleFonts.vt323(
                      fontSize: 18,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // 主要内容区域 - 书本和提示文字
              Container(
                width: 288,
                height: 320, // 减小高度
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 96, // 减小图标大小
                      color: const Color(0xFF1A1A1A),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '请在心中默念你的问题，然后按下按钮',
                        style: GoogleFonts.vt323(
                          fontSize: 16, // 减小字体大小
                          color: const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 答案显示区域
              Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  _currentAnswer,
                  style: GoogleFonts.vt323(
                    fontSize: 30,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 输入框
              Container(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Container(
                  height: 64,
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
                      fontSize: 24,
                      color: const Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '输入你的问题...',
                      hintStyle: GoogleFonts.vt323(
                        fontSize: 24,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 获取答案按钮
              GestureDetector(
                onTap: _getAnswer,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48.0,
                    vertical: 16.0,
                  ),
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
                  child: Text(
                    '获取答案',
                    style: GoogleFonts.vt323(
                      fontSize: 30,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
