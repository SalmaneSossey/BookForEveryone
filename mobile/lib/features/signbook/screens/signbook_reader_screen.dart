import 'dart:math' as math;

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
import '../widgets/cwasa_avatar_widget.dart';

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
  List<GlossEntry> _glosses = const [];
  int _pageNumber = 1;
  int _activeGlossIndex = 0;
  int _replayNonce = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final book = await _repository.findById(widget.bookId);
    final progress = HiveService.loadReadingProgress(widget.bookId);
    final pageNumber = progress?.pageNumber ?? 1;
    final glosses = book == null
        ? const <GlossEntry>[]
        : await _glossService.convert(book.pageAt(pageNumber).content);
    if (!mounted) {
      return;
    }
    setState(() {
      _book = book;
      _glosses = glosses;
      _pageNumber = pageNumber;
      _activeGlossIndex = _firstActiveGlossIndex(glosses);
      _loading = false;
    });
  }

  int _firstActiveGlossIndex(List<GlossEntry> glosses) {
    final indexes = _signingGlossIndexes(glosses);
    return indexes.isEmpty ? 0 : indexes.first;
  }

  List<int> _signingGlossIndexes(List<GlossEntry> glosses) {
    final availableIndexes = <int>[
      for (var index = 0; index < glosses.length; index++)
        if (glosses[index].available) index,
    ];
    if (availableIndexes.isNotEmpty) {
      return availableIndexes;
    }
    return List<int>.generate(glosses.length, (index) => index);
  }

  void _handleAvatarSignedGloss(String value) {
    final glosses = _currentGlosses();
    final normalizedValue = value.trim().toLowerCase();
    if (normalizedValue.isEmpty || glosses.isEmpty) {
      return;
    }

    final index = glosses.indexWhere((entry) {
      return entry.gloss.toLowerCase() == normalizedValue ||
          entry.word.toLowerCase() == normalizedValue;
    });
    if (index == -1 || !mounted) {
      return;
    }

    setState(() => _activeGlossIndex = index);
  }

  List<GlossEntry> _currentGlosses() {
    return _glosses;
  }

  void _replaySigns() {
    setState(() {
      _replayNonce += 1;
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
    final nextPage = _pageNumber + 1;
    final glosses = await _glossService.convert(book.pageAt(nextPage).content);
    if (!mounted) {
      return;
    }
    setState(() {
      _pageNumber = nextPage;
      _glosses = glosses;
      _activeGlossIndex = _firstActiveGlossIndex(glosses);
    });
    await _saveAndSignal();
  }

  Future<void> _previousPage() async {
    final book = _book;
    if (book == null || _pageNumber <= 1) {
      return;
    }
    final previousPage = _pageNumber - 1;
    final glosses =
        await _glossService.convert(book.pageAt(previousPage).content);
    if (!mounted) {
      return;
    }
    setState(() {
      _pageNumber = previousPage;
      _glosses = glosses;
      _activeGlossIndex = _firstActiveGlossIndex(glosses);
    });
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
    final glosses = _glosses;
    final activeGlossIndex =
        glosses.isEmpty ? -1 : _activeGlossIndex.clamp(0, glosses.length - 1);
    final activeGloss =
        activeGlossIndex == -1 ? null : glosses[activeGlossIndex];
    final signingHeight = math.max(
      420.0,
      MediaQuery.of(context).size.height * 0.55,
    );
    final isRtl = book.language == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(
              height: signingHeight,
              child: CwasaAvatarWidget(
                glosses: glosses,
                currentGloss: activeGloss,
                replayNonce: _replayNonce,
                onSignedGloss: _handleAvatarSignedGloss,
              ),
            ),
            const SizedBox(height: 12),
            _SigningStatusPanel(gloss: activeGloss),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _replaySigns,
                icon: const Icon(Icons.replay),
                label: const Text('Replay signs'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
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
                border:
                    Border.all(color: AppColors.ink.withValues(alpha: 0.12)),
              ),
              child: Text(
                page.content,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 21),
              ),
            ),
            const SizedBox(height: 16),
            _GlossPanel(
              glosses: glosses,
              activeIndex: activeGlossIndex,
            ),
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

class _SigningStatusPanel extends StatelessWidget {
  const _SigningStatusPanel({required this.gloss});

  final GlossEntry? gloss;

  @override
  Widget build(BuildContext context) {
    final entry = gloss;
    final available = entry?.available ?? false;
    final color = available ? AppColors.green : AppColors.amber;
    final word = entry?.word ?? 'Waiting for sign';

    return Semantics(
      liveRegion: true,
      label: available ? 'Now signing $word' : 'Visual fallback for $word',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              available ? Icons.sign_language : Icons.text_fields,
              color: color,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                word,
                textDirection:
                    _isRtl(word) ? TextDirection.rtl : TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                available ? 'Signing' : 'Fallback',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontSize: 15,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isRtl(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }
}

class _GlossPanel extends StatelessWidget {
  const _GlossPanel({
    required this.glosses,
    required this.activeIndex,
  });

  final List<GlossEntry> glosses;
  final int activeIndex;

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
          children: [
            for (var index = 0; index < glosses.length; index++)
              _GlossChip(
                entry: glosses[index],
                active: index == activeIndex,
              ),
          ],
        ),
      ],
    );
  }
}

class _GlossChip extends StatelessWidget {
  const _GlossChip({
    required this.entry,
    required this.active,
  });

  final GlossEntry entry;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = entry.available ? AppColors.green : AppColors.amber;
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      scale: active ? 1.06 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.24),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : const [],
        ),
        child: Chip(
          avatar: Icon(
            entry.available ? Icons.check_circle : Icons.text_fields,
            color: active ? Colors.white : color,
          ),
          label: Text(
            entry.word,
            style: TextStyle(
              color: active ? Colors.white : null,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          backgroundColor: active ? color : null,
          side: BorderSide(color: color, width: active ? 2 : 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
