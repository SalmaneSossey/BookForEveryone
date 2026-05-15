import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/book.dart';
import '../../../core/models/reading_progress.dart';
import '../../../core/services/book_repository.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/accessible_button.dart';
import '../services/samia_voice_assistant.dart';

class SamiaScreen extends StatefulWidget {
  const SamiaScreen({super.key});

  @override
  State<SamiaScreen> createState() => _SamiaScreenState();
}

class _SamiaScreenState extends State<SamiaScreen> {
  final BookRepository _repository = BookRepository();
  final TtsService _ttsService = TtsService();
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _debugCommandController = TextEditingController();

  SamiaVoiceAssistant? _assistant;
  List<Book> _books = const [];
  List<Book> _suggestions = const [];
  Book? _selectedBook;
  int _pageNumber = 1;
  int _readToken = 0;
  int _missedTurns = 0;
  bool _loading = true;
  bool _speechAvailable = false;
  bool _listening = false;
  bool _speaking = false;
  String? _localeId;
  String _status = 'Starting Samia';
  String _lastHeard = '';
  String _lastHandledHeard = '';

  @override
  void initState() {
    super.initState();
    _bootVoiceMode();
  }

  @override
  void dispose() {
    _readToken += 1;
    _speech.cancel();
    _ttsService.stop();
    _debugCommandController.dispose();
    super.dispose();
  }

  Future<void> _bootVoiceMode() async {
    final books = await _repository.loadBooks();
    final assistant = SamiaVoiceAssistant(books);

    if (!mounted) {
      return;
    }
    setState(() {
      _books = books;
      _assistant = assistant;
      _loading = false;
      _status = 'Preparing microphone';
    });

    await _initSpeech();
    await _handleResponse(assistant.welcome());
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: _handleSpeechStatus,
        onError: _handleSpeechError,
      );
      final locales = available ? await _speech.locales() : <LocaleName>[];
      final systemLocale = available ? await _speech.systemLocale() : null;
      if (!mounted) {
        return;
      }
      setState(() {
        _speechAvailable = available;
        _localeId = _chooseLocale(locales, systemLocale);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _speechAvailable = false;
        _status = 'Microphone is not available';
      });
    }
  }

  String? _chooseLocale(List<LocaleName> locales, LocaleName? systemLocale) {
    final ids = locales.map((locale) => locale.localeId).toSet();
    final systemId = systemLocale?.localeId;
    if (systemId != null &&
        (systemId.startsWith('ar') ||
            systemId.startsWith('fr') ||
            systemId.startsWith('en'))) {
      return systemId;
    }

    for (final candidate in const ['ar_MA', 'ar_SA', 'en_US', 'fr_FR']) {
      if (ids.contains(candidate)) {
        return candidate;
      }
    }
    return systemId ?? (ids.isEmpty ? null : ids.first);
  }

  Future<void> _startListening() async {
    if (!_speechAvailable || _speaking || !mounted) {
      return;
    }

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
      setState(() {
        _listening = true;
        _lastHeard = '';
        _lastHandledHeard = '';
        _status = 'Listening. Say a book, topic, or command.';
      });
      await _speech.listen(
        onResult: _handleSpeechResult,
        listenFor: const Duration(seconds: 9),
        pauseFor: const Duration(seconds: 2),
        localeId: _localeId,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _listening = false;
        _speechAvailable = false;
        _status = 'Speech recognition is not available on this device.';
      });
    }
  }

  Future<void> _stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (mounted) {
      setState(() => _listening = false);
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (!mounted) {
      return;
    }
    setState(() => _lastHeard = words);
    if (result.finalResult && words.isNotEmpty) {
      _processHeardCommand(words);
    }
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) {
      return;
    }
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      setState(() => _listening = false);
      final words = _lastHeard.trim();
      if (words.isNotEmpty && words != _lastHandledHeard) {
        _processHeardCommand(words);
      } else if (!_speaking && _speechAvailable && _missedTurns < 2) {
        _missedTurns += 1;
        _speakThenListen(
          'I did not catch that. Please say a book title, or say a topic.',
        );
      }
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (!mounted) {
      return;
    }
    setState(() {
      _listening = false;
      _status = error.permanent
          ? 'Speech recognition needs microphone permission or a working speech service.'
          : 'I did not catch that.';
    });
    if (!error.permanent && _missedTurns < 2) {
      _missedTurns += 1;
      _speakThenListen('I did not catch that. Please try again.');
    }
  }

  Future<void> _processHeardCommand(String command) async {
    final assistant = _assistant;
    final cleanCommand = command.trim();
    if (assistant == null ||
        cleanCommand.isEmpty ||
        cleanCommand == _lastHandledHeard) {
      return;
    }

    _lastHandledHeard = cleanCommand;
    _missedTurns = 0;
    await _stopListening();
    await _handleResponse(assistant.handleCommand(cleanCommand));
  }

  Future<void> _handleResponse(SamiaResponse response) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _status = response.prompt;
      _suggestions = response.suggestions;
      _selectedBook = response.selectedBook ?? _selectedBook;
    });

    switch (response.action) {
      case SamiaAction.none:
        await _speakThenListen(response.prompt);
      case SamiaAction.startReading:
        final book = response.selectedBook;
        if (book == null) {
          await _speakThenListen('Which book would you like to hear?');
          return;
        }
        await _speakOnly(response.prompt);
        await _startBook(book);
      case SamiaAction.pauseReading:
        await _pauseReading();
        await _speakThenListen(response.prompt);
      case SamiaAction.stopReading:
        await _stopReading();
        await _speakThenListen(response.prompt);
      case SamiaAction.resumeReading:
        await _speakOnly(response.prompt);
        await _readCurrentPage();
      case SamiaAction.nextPage:
        await _speakOnly(response.prompt);
        await _nextPage();
      case SamiaAction.previousPage:
        await _speakOnly(response.prompt);
        await _previousPage();
      case SamiaAction.repeatPage:
        await _speakOnly(response.prompt);
        await _readCurrentPage();
    }
  }

  Future<void> _startBook(Book book) async {
    final progress = HiveService.loadReadingProgress(book.id);
    final pageNumber = progress?.pageNumber ?? 1;
    _assistant?.readingStarted(book);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedBook = book;
      _pageNumber = pageNumber.clamp(1, book.totalPages);
      _suggestions = const [];
    });
    await _readCurrentPage();
  }

  Future<void> _readCurrentPage() async {
    final book = _selectedBook;
    if (book == null) {
      await _speakThenListen('Choose a book first.');
      return;
    }

    final token = ++_readToken;
    final page = book.pageAt(_pageNumber);
    await _saveProgress(book);

    if (!mounted) {
      return;
    }
    setState(() {
      _speaking = true;
      _listening = false;
      _status = 'Reading ${book.title}, page $_pageNumber.';
    });

    await _ttsService.speak(page.content, book.language);

    if (!mounted || token != _readToken) {
      return;
    }

    setState(() {
      _speaking = false;
      _status = 'Finished page $_pageNumber of ${book.totalPages}.';
    });

    final response = _assistant?.pageFinished(
      hasNextPage: _pageNumber < book.totalPages,
      isBookFinished: _pageNumber >= book.totalPages,
    );
    if (response != null) {
      await _speakThenListen(response.prompt);
    }
  }

  Future<void> _nextPage() async {
    final book = _selectedBook;
    if (book == null) {
      await _speakThenListen('Choose a book first.');
      return;
    }
    if (_pageNumber >= book.totalPages) {
      await _speakThenListen(
        'This is the last page. Say repeat, choose another book, or stop.',
      );
      return;
    }
    setState(() => _pageNumber += 1);
    await _readCurrentPage();
  }

  Future<void> _previousPage() async {
    final book = _selectedBook;
    if (book == null) {
      await _speakThenListen('Choose a book first.');
      return;
    }
    if (_pageNumber <= 1) {
      await _speakThenListen('This is the first page. Say continue or repeat.');
      return;
    }
    setState(() => _pageNumber -= 1);
    await _readCurrentPage();
  }

  Future<void> _pauseReading() async {
    _readToken += 1;
    await _ttsService.pause();
    _assistant?.readingPaused();
    if (mounted) {
      setState(() {
        _speaking = false;
        _status = 'Paused. Say continue when ready.';
      });
    }
  }

  Future<void> _stopReading() async {
    _readToken += 1;
    await _ttsService.stop();
    _assistant?.readingStopped();
    if (mounted) {
      setState(() {
        _speaking = false;
        _status = 'Stopped. What would you like next?';
      });
    }
  }

  Future<void> _saveProgress(Book book) async {
    await HiveService.saveReadingProgress(
      ReadingProgress(
        bookId: book.id,
        pageNumber: _pageNumber,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _speakOnly(String text) async {
    await _stopListening();
    if (!mounted) {
      return;
    }
    setState(() {
      _speaking = true;
      _status = text;
    });
    await _ttsService.speak(text, 'en');
    if (!mounted) {
      return;
    }
    setState(() => _speaking = false);
  }

  Future<void> _speakThenListen(String text) async {
    await _speakOnly(text);
    if (!_speechAvailable || !mounted) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _startListening();
  }

  Future<void> _handleDebugCommand() async {
    final command = _debugCommandController.text.trim();
    _debugCommandController.clear();
    await _processHeardCommand(command);
  }

  Future<void> _vibrate() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 40);
      }
    } catch (_) {
      // Haptics are best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedBook = _selectedBook;
    final voiceState = _speaking
        ? 'Speaking'
        : _listening
            ? 'Listening'
            : _speechAvailable
                ? 'Ready'
                : 'Microphone unavailable';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samia'),
        actions: [
          IconButton(
            tooltip: 'Explore',
            icon: const Icon(Icons.explore),
            onPressed: () => context.go('/explore'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Semantics(
              liveRegion: true,
              label: 'Samia voice assistant status. $voiceState. $_status',
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _listening ? Icons.mic : Icons.record_voice_over,
                          color: Colors.white,
                          size: 34,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            voiceState,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    if (_lastHeard.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Heard: $_lastHeard',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AccessibleButton(
                    label: _listening ? 'Listening' : 'Start listening',
                    icon: Icons.mic,
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    onPressed: _speechAvailable
                        ? () async {
                            await _vibrate();
                            await _startListening();
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AccessibleButton(
                    label: 'Stop',
                    icon: Icons.stop,
                    outlined: true,
                    onPressed: () async {
                      await _vibrate();
                      await _stopReading();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedBook != null)
              _CurrentBookPanel(
                book: selectedBook,
                pageNumber: _pageNumber,
              ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SuggestionPanel(suggestions: _suggestions),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _debugCommandController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleDebugCommand(),
              decoration: InputDecoration(
                labelText: 'Debug command',
                helperText: 'For demos when the room is too noisy',
                prefixIcon: const Icon(Icons.keyboard_voice),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AccessibleButton(
              label: 'Send debug command',
              icon: Icons.send,
              outlined: true,
              onPressed: _handleDebugCommand,
            ),
            const SizedBox(height: 22),
            Text(
              'Try saying: read Garden of Words, Arabic story, continue, repeat, previous page, stop.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Loaded ${_books.length} books. Samia ignores SignBook-only demos unless launched from SignBook.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentBookPanel extends StatelessWidget {
  const _CurrentBookPanel({
    required this.book,
    required this.pageNumber,
  });

  final Book book;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.teal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current book',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(
            book.titleAr == null
                ? book.title
                : '${book.title} / ${book.titleAr}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text('Page $pageNumber of ${book.totalPages}'),
        ],
      ),
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({required this.suggestions});

  final List<Book> suggestions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suggestions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (var index = 0; index < suggestions.length; index++) ...[
            Text(
              '${index + 1}. ${suggestions[index].title}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (suggestions[index].titleAr != null)
              Text(
                suggestions[index].titleAr!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (index < suggestions.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
