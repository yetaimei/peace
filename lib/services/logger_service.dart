import 'package:flutter/foundation.dart';

/// 日志服务类
/// 提供统一的日志记录功能，支持不同级别的日志输出
class LoggerService {
  static const String _appName = '答案之书';
  
  /// 调试级别日志
  /// 用于记录详细的调试信息，仅在调试模式下输出
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      final logTag = tag ?? 'DEBUG';
      print('[$timestamp] [$_appName] [$logTag] $message');
    }
  }
  
  /// 信息级别日志
  /// 用于记录重要的业务流程信息
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      final logTag = tag ?? 'INFO';
      print('[$timestamp] [$_appName] [$logTag] $message');
    }
  }
  
  /// 警告级别日志
  /// 用于记录可能的问题或异常情况
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      final logTag = tag ?? 'WARNING';
      print('[$timestamp] [$_appName] [$logTag] ⚠️ $message');
    }
  }
  
  /// 错误级别日志
  /// 用于记录错误信息和异常
  static void error(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      final logTag = tag ?? 'ERROR';
      print('[$timestamp] [$_appName] [$logTag] ❌ $message');
      if (error != null) {
        print('[$timestamp] [$_appName] [$logTag] 错误详情: $error');
      }
      if (stackTrace != null) {
        print('[$timestamp] [$_appName] [$logTag] 堆栈信息: $stackTrace');
      }
    }
  }
  
  /// 用户行为日志
  /// 记录用户的关键操作行为
  static void userAction(String action, [Map<String, dynamic>? params]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      final paramsStr = params != null ? ' 参数: $params' : '';
      print('[$timestamp] [$_appName] [USER_ACTION] 👤 $action$paramsStr');
    }
  }
  
  /// 数据操作日志
  /// 记录数据的增删改查操作
  static void dataOperation(String operation, [Map<String, dynamic>? details]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      final detailsStr = details != null ? ' 详情: $details' : '';
      print('[$timestamp] [$_appName] [DATA_OP] 💾 $operation$detailsStr');
    }
  }
  
  /// 页面导航日志
  /// 记录页面跳转和导航操作
  static void navigation(String from, String to, [String? action]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      final actionStr = action != null ? ' ($action)' : '';
      print('[$timestamp] [$_appName] [NAVIGATION] 🧭 $from → $to$actionStr');
    }
  }
  
  /// 性能监控日志
  /// 记录性能相关的信息
  static void performance(String operation, Duration duration, [Map<String, dynamic>? metrics]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      final metricsStr = metrics != null ? ' 指标: $metrics' : '';
      print('[$timestamp] [$_appName] [PERFORMANCE] ⚡ $operation 耗时: ${duration.inMilliseconds}ms$metricsStr');
    }
  }
}