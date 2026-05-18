import 'package:flutter/material.dart';

import '../../../core/models/book.dart';
import '../../../core/models/book_page.dart';
import '../../../core/models/reading_progress.dart';
import '../../../core/services/book_repository.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/accessible_button.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({required this.bookId, super.key});

  final String bookId;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final BookRepository _repository = BookRepository();
  final TtsService _ttsService = TtsService();

  Book? _book;
  int _pageNumber = 1;
  int _readToken = 0;
  bool _speaking = false;
  bool _loading = true;
  String _readerStatus = 'Ready to read';

  BookPage get _currentPage => _book!.pageAt(_pageNumber);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final book = await _repository.findById(widget.bookId);
    final progress = HiveService.loadReadingProgress(widget.bookId);
    setState(() {
      _book = book;
      _pageNumber = progress?.pageNumber ?? 1;
      _loading = false;
    });
  }

  Future<void> _saveProgress() async {
    await HiveService.saveReadingProgress(
      ReadingProgress(
        bookId: widget.bookId,
        pageNumber: _pageNumber,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _readCurrentPage() async {
    if (_book == null) {
      return;
    }
    final token = ++_readToken;
    final pageNumber = _pageNumber;
    await _saveProgress();
    setState(() {
      _speaking = true;
      _readerStatus = 'Samia is reading page $pageNumber';
    });
    await _ttsService.speak(_currentPage.content, _book!.language);
    if (!mounted || token != _readToken) {
      return;
    }
    setState(() {
      _speaking = false;
      _readerStatus = 'Finished page $pageNumber';
    });
  }

  Future<void> _pause() async {
    _readToken += 1;
    await _ttsService.pause();
    setState(() {
      _speaking = false;
      _readerStatus = 'Paused page $_pageNumber';
    });
  }

  Future<void> _stop() async {
    _readToken += 1;
    await _ttsService.stop();
    setState(() {
      _speaking = false;
      _readerStatus = 'Stopped';
    });
  }

  Future<void> _nextPage() async {
    if (_book == null || _pageNumber >= _book!.totalPages) {
      return;
    }
    await _stop();
    setState(() => _pageNumber += 1);
    await _saveProgress();
    await _readCurrentPage();
  }

  Future<void> _previousPage() async {
    if (_book == null || _pageNumber <= 1) {
      return;
    }
    await _stop();
    setState(() => _pageNumber -= 1);
    await _saveProgress();
    await _readCurrentPage();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final book = _book;
    if (book == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: Text('Book not found')),
      );
    }

    final page = _currentPage;
    final isRtl = book.language == 'ar';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(book.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              book.titleAr ?? book.title,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Page $_pageNumber of ${book.totalPages}'),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _speaking
                      ? AppColors.teal.withValues(alpha: 0.12)
                      : AppColors.ink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _speaking
                        ? AppColors.teal
                        : AppColors.ink.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _speaking ? Icons.volume_up : Icons.info_outline,
                      color: _speaking ? AppColors.teal : AppColors.ink,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _readerStatus,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.ink.withValues(alpha: 0.12)),
              ),
              child: Text(
                page.content,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 22),
              ),
            ),
            const SizedBox(height: 18),
            AccessibleButton(
              label: _speaking ? 'Repeat page' : 'Start reading',
              icon: _speaking ? Icons.replay : Icons.play_arrow,
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              onPressed: _readCurrentPage,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AccessibleButton(
                    label: 'Pause',
                    icon: Icons.pause,
                    outlined: true,
                    onPressed: _pause,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AccessibleButton(
                    label: 'Continue',
                    icon: Icons.play_circle,
                    outlined: true,
                    onPressed: _readCurrentPage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AccessibleButton(
                    label: 'Previous',
                    icon: Icons.chevron_left,
                    outlined: true,
                    onPressed: _pageNumber > 1 ? _previousPage : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AccessibleButton(
                    label: 'Next',
                    icon: Icons.chevron_right,
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    onPressed: _pageNumber < book.totalPages ? _nextPage : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
