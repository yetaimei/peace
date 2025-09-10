import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'answer_display_page.dart';
import 'services/logger_service.dart';

class AnswerHistoryItem {
  final String question;
  final String answer;
  final DateTime timestamp;

  AnswerHistoryItem({
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory AnswerHistoryItem.fromJson(Map<String, dynamic> json) {
    return AnswerHistoryItem(
      question: json['question'] as String,
      answer: json['answer'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }
}

class AnswerHistoryPage extends StatefulWidget {
  const AnswerHistoryPage({super.key});

  @override
  State<AnswerHistoryPage> createState() => _AnswerHistoryPageState();
}

class _AnswerHistoryPageState extends State<AnswerHistoryPage> {
  List<AnswerHistoryItem> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    LoggerService.info('答案历史页面初始化', 'PAGE_LIFECYCLE');
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次页面获得焦点时重新加载数据
    LoggerService.debug('答案历史页面依赖变化，重新加载数据');
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      LoggerService.dataOperation('开始加载答案历史');
      
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('answer_history') ?? [];
      
      setState(() {
        _historyItems = historyJson
            .map((jsonStr) => AnswerHistoryItem.fromJson(jsonDecode(jsonStr)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // 最新的在前
        _isLoading = false;
      });
      
      stopwatch.stop();
      LoggerService.performance('加载答案历史', stopwatch.elapsed, {
        'recordCount': _historyItems.length,
        'rawDataCount': historyJson.length,
      });
      
    } catch (e, stackTrace) {
      stopwatch.stop();
      LoggerService.error('加载答案历史失败', 'DATA_OPERATION', e, stackTrace);
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    LoggerService.userAction('用户尝试清空历史记录', {
      'currentRecordCount': _historyItems.length,
    });
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
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
          child: CustomPaint(
            painter: PixelPatternPainter(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  Text(
                    '清空历史记录',
                    style: GoogleFonts.vt323(
                      fontSize: 24,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 内容
                  Text(
                    '确定要清空所有历史记录吗？\n此操作不可撤销。',
                    style: GoogleFonts.vt323(
                      fontSize: 18,
                      color: const Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 按钮组
                  Row(
                    children: [
                      // 取消按钮
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            LoggerService.userAction('取消清空历史记录');
                            Navigator.of(context).pop(false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                            child: Text(
                              '取消',
                              style: GoogleFonts.vt323(
                                fontSize: 18,
                                color: const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      
                      // 确定按钮
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            LoggerService.userAction('确认清空历史记录');
                            Navigator.of(context).pop(true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                            child: Text(
                              '确定',
                              style: GoogleFonts.vt323(
                                fontSize: 18,
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      try {
        LoggerService.dataOperation('执行清空历史记录操作');
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('answer_history');
        
        final oldCount = _historyItems.length;
        setState(() {
          _historyItems = [];
        });
        
        LoggerService.dataOperation('成功清空历史记录', {
          'deletedRecordCount': oldCount,
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '历史记录已清空',
                style: GoogleFonts.vt323(
                  fontSize: 16,
                  color: const Color(0xFFE0E0D8),
                ),
              ),
              backgroundColor: const Color(0xFF1A1A1A),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e, stackTrace) {
        LoggerService.error('清空历史记录失败', 'DATA_OPERATION', e, stackTrace);
      }
    }
  }

  void _viewAnswer(AnswerHistoryItem item) {
    LoggerService.userAction('查看历史答案', {
      'answer': item.answer,
      'questionLength': item.question.length,
      'timestamp': item.timestamp.toString(),
    });
    
    LoggerService.navigation('答案历史页面', '答案显示页面', '查看历史记录');
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AnswerDisplayPage(
          answer: item.answer,
          question: item.question,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
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
              // 检测向左滑动手势，返回主页面
              if (details.velocity.pixelsPerSecond.dx < -300) {
                LoggerService.userAction('向左滑动手势 - 返回主页面');
                LoggerService.navigation('答案历史页面', '主页面', '向左滑动手势');
                Navigator.of(context).pop();
              }
            },
            child: Column(
            children: [
              // 顶部标题栏
              Container(
                padding: EdgeInsets.fromLTRB(
                  20.0,
                  MediaQuery.of(context).padding.top + 20.0,
                  20.0,
                  20.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        LoggerService.userAction('返回主页面');
                        LoggerService.navigation('答案历史页面', '主页面', '点击返回按钮');
                        Navigator.of(context).pop();
                      },
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
                        '答案历史',
                        style: GoogleFonts.vt323(
                          fontSize: 28,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (_historyItems.isNotEmpty) ...[
                          GestureDetector(
                            onTap: () {
                              LoggerService.userAction('手动刷新历史记录');
                              _loadHistory();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
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
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.refresh,
                                size: 24,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearHistory,
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
                                Icons.delete_outline,
                                size: 24,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // 调试信息显示
              if (kDebugMode)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0D8),
                    border: Border.all(color: const Color(0xFF1A1A1A), width: 1),
                  ),
                  child: Text(
                    '历史记录: ${_historyItems.length}条 | 状态: ${_isLoading ? "加载中" : "完成"}',
                    style: GoogleFonts.vt323(
                      fontSize: 12,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // 内容区域
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1A1A1A),
                          ),
                        ),
                      )
                    : _historyItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 80,
                                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '暂无历史记录',
                                  style: GoogleFonts.vt323(
                                    fontSize: 24,
                                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '开始提问，获取你的第一个答案',
                                  style: GoogleFonts.vt323(
                                    fontSize: 16,
                                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: _historyItems.length,
                            itemBuilder: (context, index) {
                              final item = _historyItems[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                child: GestureDetector(
                                  onTap: () => _viewAnswer(item),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
                                    child: Row(
                                      children: [
                                        // 左侧：问题和时间
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (item.question.isNotEmpty) ...[
                                                Text(
                                                  item.question,
                                                  style: GoogleFonts.vt323(
                                                    fontSize: 14,
                                                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.7),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                              ],
                                              Text(
                                                _formatTimestamp(item.timestamp),
                                                style: GoogleFonts.vt323(
                                                  fontSize: 12,
                                                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 8),
                                        
                                        // 右侧：答案和箭头
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 6.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE0E0D8),
                                                    border: Border.all(
                                                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    item.answer,
                                                    style: GoogleFonts.vt323(
                                                      fontSize: 16,
                                                      color: const Color(0xFF1A1A1A),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14,
                                                color: Color(0xFF1A1A1A),
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
