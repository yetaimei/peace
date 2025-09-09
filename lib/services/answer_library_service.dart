import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/answer_libraries.dart';
import 'logger_service.dart';

/// 答案库管理服务
class AnswerLibraryService {
  static const String _currentLibraryKey = 'current_answer_library';
  static const String _customLibrariesKey = 'custom_answer_libraries';
  
  /// 获取当前选中的答案库ID
  static Future<String> getCurrentLibraryId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentLibraryKey) ?? 'default';
  }
  
  /// 设置当前答案库
  static Future<void> setCurrentLibrary(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentLibraryKey, libraryId);
    LoggerService.info('切换答案库: $libraryId', 'ANSWER_LIBRARY');
  }
  
  /// 获取当前答案库
  static Future<AnswerLibrary?> getCurrentLibrary() async {
    final libraryId = await getCurrentLibraryId();
    
    // 先尝试从预设库中获取
    final presetLibrary = AnswerLibraries.getLibraryById(libraryId);
    if (presetLibrary != null) {
      return presetLibrary;
    }
    
    // 如果不是预设库，尝试从自定义库中获取
    final customLibraries = await getCustomLibraries();
    try {
      return customLibraries.firstWhere((lib) => lib.id == libraryId);
    } catch (e) {
      // 如果找不到，返回默认库
      LoggerService.warning('找不到答案库 $libraryId，使用默认库');
      return AnswerLibraries.defaultLibrary;
    }
  }
  
  /// 获取随机答案
  static Future<String> getRandomAnswer() async {
    final library = await getCurrentLibrary();
    if (library == null || library.answers.isEmpty) {
      return '无法获取答案';
    }
    
    final random = Random();
    final answer = library.answers[random.nextInt(library.answers.length)];
    
    LoggerService.debug('从答案库 ${library.name} 获取答案: $answer');
    
    return answer;
  }
  
  /// 获取所有可用的答案库（包括预设和自定义）
  static Future<List<AnswerLibrary>> getAllLibraries() async {
    final customLibraries = await getCustomLibraries();
    return [...AnswerLibraries.allLibraries, ...customLibraries];
  }
  
  /// 获取自定义答案库列表
  static Future<List<AnswerLibrary>> getCustomLibraries() async {
    final prefs = await SharedPreferences.getInstance();
    final customLibrariesJson = prefs.getStringList(_customLibrariesKey) ?? [];
    
    final libraries = <AnswerLibrary>[];
    for (final json in customLibrariesJson) {
      try {
        final data = jsonDecode(json);
        libraries.add(_libraryFromJson(data));
      } catch (e) {
        LoggerService.error('解析自定义答案库失败: $e', 'PARSE_ERROR');
      }
    }
    
    return libraries;
  }
  
  /// 添加自定义答案库
  static Future<void> addCustomLibrary(AnswerLibrary library) async {
    final prefs = await SharedPreferences.getInstance();
    final customLibrariesJson = prefs.getStringList(_customLibrariesKey) ?? [];
    
    customLibrariesJson.add(jsonEncode(_libraryToJson(library)));
    await prefs.setStringList(_customLibrariesKey, customLibrariesJson);
    
    LoggerService.info('添加自定义答案库: ${library.name} (${library.answers.length}条答案)', 'ANSWER_LIBRARY');
  }
  
  /// 删除自定义答案库
  static Future<void> deleteCustomLibrary(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    final customLibrariesJson = prefs.getStringList(_customLibrariesKey) ?? [];
    
    customLibrariesJson.removeWhere((json) {
      try {
        final data = jsonDecode(json);
        return data['id'] == libraryId;
      } catch (e) {
        return false;
      }
    });
    
    await prefs.setStringList(_customLibrariesKey, customLibrariesJson);
    
    // 如果删除的是当前选中的库，切换到默认库
    final currentId = await getCurrentLibraryId();
    if (currentId == libraryId) {
      await setCurrentLibrary('default');
    }
    
    LoggerService.info('删除自定义答案库: $libraryId', 'ANSWER_LIBRARY');
  }
  
  /// 从JSON文件导入答案库
  static Future<AnswerLibrary?> importFromJsonFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);
      
      final library = _libraryFromJson(data);
      await addCustomLibrary(library);
      
      LoggerService.info('从文件导入答案库成功: ${library.name}', 'IMPORT');
      
      return library;
    } catch (e) {
      LoggerService.error('从文件导入答案库失败: $e', 'IMPORT_ERROR');
      return null;
    }
  }
  
  /// 从Assets导入答案库
  static Future<AnswerLibrary?> importFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final data = jsonDecode(jsonString);
      
      final library = _libraryFromJson(data);
      await addCustomLibrary(library);
      
      LoggerService.info('从Asset导入答案库成功: ${library.name}', 'IMPORT');
      
      return library;
    } catch (e) {
      LoggerService.error('从Asset导入答案库失败: $e', 'IMPORT_ERROR');
      return null;
    }
  }
  
  /// 导出答案库到JSON
  static Future<String?> exportToJson(String libraryId) async {
    try {
      AnswerLibrary? library = AnswerLibraries.getLibraryById(libraryId);
      
      if (library == null) {
        final customLibraries = await getCustomLibraries();
        library = customLibraries.firstWhere(
          (lib) => lib.id == libraryId,
          orElse: () => throw Exception('找不到答案库'),
        );
      }
      
      return jsonEncode(_libraryToJson(library));
    } catch (e) {
      LoggerService.error('导出答案库失败: $e', 'EXPORT_ERROR');
      return null;
    }
  }
  
  /// 将答案库转换为JSON
  static Map<String, dynamic> _libraryToJson(AnswerLibrary library) {
    return {
      'id': library.id,
      'name': library.name,
      'description': library.description,
      'answers': library.answers,
      'author': library.author,
      'category': library.category,
      'source': library.source.name, // 保存source字段
    };
  }
  
  /// 从JSON创建答案库
  static AnswerLibrary _libraryFromJson(Map<String, dynamic> json) {
    // 解析source字段，如果没有则默认为imported
    AnswerLibrarySource source = AnswerLibrarySource.imported;
    if (json['source'] != null) {
      switch (json['source']) {
        case 'preset':
          source = AnswerLibrarySource.preset;
          break;
        case 'imported':
          source = AnswerLibrarySource.imported;
          break;
        default:
          source = AnswerLibrarySource.imported;
      }
    }
    
    return AnswerLibrary(
      id: json['id'] ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] ?? '自定义答案库',
      description: json['description'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      author: json['author'],
      category: json['category'],
      source: source,
    );
  }
}
