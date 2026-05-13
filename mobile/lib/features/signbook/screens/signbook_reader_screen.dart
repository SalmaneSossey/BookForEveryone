import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/book.dart';
import '../../../core/models/gloss_entry.dart';
import '../../../core/models/reading_progress.dart';
import '../../../core/services/book_repository.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/accessible_button.dart';
import '../services/text_to_gloss_service.dart';
import '../widgets/avatar_placeholder.dart';

class SignBookReaderScreen extends StatefulWidget {
  const SignBookReaderScreen({required this.bookId, super.key});

  final String bookId;

  @override
  State<SignBookReaderScreen> createState() => _SignBookReaderScreenState();
}

class _SignBookReaderScreenState extends State<SignBookReaderScreen> {
  final BookRepository _repository = BookRepository();
  final TextToGlossService _glossService = const TextToGlossService();

  Book? _book;
  int _pageNumber = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _saveAndSignal() async {
    await HiveService.saveReadingProgress(
      ReadingProgress(
        bookId: widget.bookId,
        pageNumber: _pageNumber,
        updatedAt: DateTime.now(),
      ),
    );
    try {
      final canVibrate = await Vibration.hasVibrator();
      if (canVibrate) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (_) {
      // Haptics are best-effort because emulator/device support varies.
    }
  }

  Future<void> _nextPage() async {
    final book = _book;
    if (book == null || _pageNumber >= book.totalPages) {
      return;
    }
    setState(() => _pageNumber += 1);
    await _saveAndSignal();
  }

  Future<void> _previousPage() async {
    if (_pageNumber <= 1) {
      return;
    }
    setState(() => _pageNumber -= 1);
    await _saveAndSignal();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final book = _book;
    if (book == null) {
      return const Scaffold(body: Center(child: Text('Book not found')));
    }

    final page = book.pageAt(_pageNumber);
    final glosses = _glossService.convert(page.content);
    final isRtl = book.language == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AvatarPlaceholder(active: glosses.any((entry) => entry.available)),
            const SizedBox(height: 18),
            Text(
              book.titleAr ?? book.title,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Page $_pageNumber of ${book.totalPages}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.ink.withValues(alpha: 0.12)),
              ),
              child: Text(
                page.content,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 21),
              ),
            ),
            const SizedBox(height: 16),
            _GlossPanel(glosses: glosses),
            const SizedBox(height: 18),
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

class _GlossPanel extends StatelessWidget {
  const _GlossPanel({required this.glosses});

  final List<GlossEntry> glosses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Glosses', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: glosses.map((entry) {
            final color = entry.available ? AppColors.green : AppColors.amber;
            return Chip(
              avatar: Icon(
                entry.available ? Icons.check_circle : Icons.text_fields,
                color: color,
              ),
              label: Text(entry.word),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: color),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
