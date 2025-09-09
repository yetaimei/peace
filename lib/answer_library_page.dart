import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/answer_libraries.dart';
import 'services/answer_library_service.dart';
import 'services/logger_service.dart';

class AnswerLibraryPage extends StatefulWidget {
  const AnswerLibraryPage({super.key});

  @override
  State<AnswerLibraryPage> createState() => _AnswerLibraryPageState();
}

class _AnswerLibraryPageState extends State<AnswerLibraryPage> {
  List<AnswerLibrary> _libraries = [];
  String _currentLibraryId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLibraries();
  }

  Future<void> _loadLibraries() async {
    try {
      final libraries = await AnswerLibraryService.getAllLibraries();
      final currentId = await AnswerLibraryService.getCurrentLibraryId();
      
      if (mounted) {
        setState(() {
          _libraries = libraries;
          _currentLibraryId = currentId;
          _isLoading = false;
        });
      }
      
      LoggerService.info('加载答案库列表: ${libraries.length}个库，当前: $currentId', 'ANSWER_LIBRARY_PAGE');
    } catch (e) {
      LoggerService.error('加载答案库列表失败: $e', 'ANSWER_LIBRARY_PAGE');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectLibrary(String libraryId) async {
    try {
      await AnswerLibraryService.setCurrentLibrary(libraryId);
      setState(() {
        _currentLibraryId = libraryId;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '已切换答案库',
              style: GoogleFonts.vt323(fontSize: 16),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      LoggerService.error('切换答案库失败: $e', 'ANSWER_LIBRARY_PAGE');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '切换失败',
              style: GoogleFonts.vt323(fontSize: 16),
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0D8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0D8),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF1A1A1A),
                width: 2,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              '答案库',
              style: GoogleFonts.vt323(
                fontSize: 32,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1A1A1A),
                size: 28,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _libraries.length,
              itemBuilder: (context, index) {
                final library = _libraries[index];
                final isSelected = library.id == _currentLibraryId;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0D8),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.green[700]! 
                          : const Color(0xFF1A1A1A),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? Colors.green[700]! 
                            : const Color(0xFF1A1A1A),
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectLibrary(library.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        library.name,
                                        style: GoogleFonts.vt323(
                                          fontSize: 24,
                                          color: const Color(0xFF1A1A1A),
                                          fontWeight: isSelected 
                                              ? FontWeight.bold 
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (library.author != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '- ${library.author}',
                                          style: GoogleFonts.vt323(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    library.description,
                                    style: GoogleFonts.vt323(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.library_books,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${library.answers.length}条答案',
                                        style: GoogleFonts.vt323(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // 来源标识
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: library.source == AnswerLibrarySource.preset 
                                              ? Colors.blue[100] 
                                              : Colors.orange[100],
                                          border: Border.all(
                                            color: library.source == AnswerLibrarySource.preset 
                                                ? Colors.blue[300]! 
                                                : Colors.orange[300]!,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          library.source == AnswerLibrarySource.preset ? '预设' : '导入',
                                          style: GoogleFonts.vt323(
                                            fontSize: 11,
                                            color: library.source == AnswerLibrarySource.preset 
                                                ? Colors.blue[700] 
                                                : Colors.orange[700],
                                          ),
                                        ),
                                      ),
                                      if (library.category != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            library.category!,
                                            style: GoogleFonts.vt323(
                                              fontSize: 12,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}