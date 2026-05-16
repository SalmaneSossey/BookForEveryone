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
  List<LocaleName> _speechLocales = const [];
  List<String> _preferredLocaleIds = const [];
  Book? _selectedBook;
  int _pageNumber = 1;
  int _readToken = 0;
  int _missedTurns = 0;
  int _localeIndex = 0;
  bool _loading = true;
  bool _speechAvailable = false;
  bool _listening = false;
  bool _speaking = false;
  String? _localeId;
  String _status = 'Starting Samia';
  String _lastHeard = '';
  String _lastHandledHeard = '';
  String _lastSpokenText = '';
  bool _suppressSpeechEvents = false;
  DateTime _ignoreSpeechUntil = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _postSpeechSettleDelay = Duration(milliseconds: 300);

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
      final preferredLocaleIds = _preferredLocales(locales, systemLocale);
      if (!mounted) {
        return;
      }
      setState(() {
        _speechAvailable = available;
        _speechLocales = locales;
        _preferredLocaleIds = systemLocale != null ? [systemLocale.localeId] : [];
        _localeIndex = 0;
        _localeId = systemLocale?.localeId ?? (locales.isNotEmpty ? locales.first.localeId : null);
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

  List<String> _preferredLocales(
    List<LocaleName> locales,
    LocaleName? systemLocale,
  ) {
    final ids = locales.map((locale) => locale.localeId).toList();
    final preferred = <String>[];
    final systemId = systemLocale?.localeId;

    for (final language in const ['ar', 'fr', 'en']) {
      final exactCandidates = switch (language) {
        'ar' => const ['ar_MA', 'ar-DZ', 'ar_DZ', 'ar_SA', 'ar_EG', 'ar'],
        'fr' => const ['fr_MA', 'fr_FR', 'fr-CA', 'fr'],
        _ => const ['en_US', 'en_GB', 'en'],
      };
      final match = _findLocale(ids, exactCandidates, language);
      if (match != null && !preferred.contains(match)) {
        preferred.add(match);
      }
    }

    if (systemId != null &&
        (systemId.startsWith('ar') ||
            systemId.startsWith('fr') ||
            systemId.startsWith('en')) &&
        !preferred.contains(systemId)) {
      preferred.add(systemId);
    }

    if (preferred.isEmpty && ids.isNotEmpty) {
      preferred.add(ids.first);
    }

    return preferred;
  }

  String? _findLocale(
    List<String> ids,
    List<String> exactCandidates,
    String language,
  ) {
    for (final candidate in exactCandidates) {
      if (ids.contains(candidate)) {
        return candidate;
      }
    }

    final prefix = '${language}_';
    final dashPrefix = '$language-';
    for (final id in ids) {
      final lower = id.toLowerCase();
      if (lower == language ||
          lower.startsWith(prefix) ||
          lower.startsWith(dashPrefix)) {
        return id;
      }
    }
    return null;
  }

  Future<void> _startListening() async {
    if (!_speechAvailable ||
        _speaking ||
        _shouldIgnoreSpeechInput ||
        !mounted) {
      return;
    }

    try {
      if (_speech.isListening) {
        await _cancelListening();
      }
      _suppressSpeechEvents = false;
      setState(() {
        _listening = true;
        _lastHeard = '';
        _lastHandledHeard = '';
        _status =
            'Listening... Say a book, topic, or command.';
      });
      await _speech.listen(
        onResult: _handleSpeechResult,
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 4),
        localeId: _localeId,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.search,
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
      await _cancelListening();
    }
    if (mounted) {
      setState(() => _listening = false);
    }
  }

  Future<void> _cancelListening() async {
    _suppressSpeechEvents = true;
    try {
      await _speech.cancel();
    } catch (_) {
      // Speech cancellation is best-effort across Android speech services.
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (!mounted) {
      return;
    }
    if (_shouldIgnoreRecognizedWords(words)) {
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
    if (_shouldIgnoreSpeechInput) {
      if (_listening) {
        setState(() => _listening = false);
      }
      return;
    }
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      setState(() => _listening = false);
      final words = _lastHeard.trim();
      if (words.isNotEmpty &&
          words != _lastHandledHeard &&
          !_shouldIgnoreRecognizedWords(words)) {
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
    if (_shouldIgnoreSpeechInput) {
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
        cleanCommand == _lastHandledHeard ||
        _shouldIgnoreRecognizedWords(cleanCommand)) {
      return;
    }

    _lastHandledHeard = cleanCommand;
    _missedTurns = 0;
    await _stopListening();
    if (await _handleLanguageCommand(cleanCommand)) {
      return;
    }
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
    _suppressSpeechEvents = true;
    _lastSpokenText = text;
    _lastHeard = '';
    _lastHandledHeard = '';
    _ignoreSpeechUntil = DateTime.now().add(_postSpeechSettleDelay);
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
    _ignoreSpeechUntil = DateTime.now().add(_postSpeechSettleDelay);
    setState(() => _speaking = false);
  }

  Future<void> _speakThenListen(String text) async {
    await _speakOnly(text);
    if (!_speechAvailable || !mounted) {
      _suppressSpeechEvents = false;
      return;
    }
    await Future<void>.delayed(_postSpeechSettleDelay);
    _ignoreSpeechUntil = DateTime.fromMillisecondsSinceEpoch(0);
    _suppressSpeechEvents = false;
    await _startListening();
  }

  bool get _shouldIgnoreSpeechInput {
    return _suppressSpeechEvents ||
        _speaking ||
        DateTime.now().isBefore(_ignoreSpeechUntil);
  }

  bool _shouldIgnoreRecognizedWords(String words) {
    if (_shouldIgnoreSpeechInput) {
      return true;
    }

    final recognized = _normalizeSpeech(words);
    final spoken = _normalizeSpeech(_lastSpokenText);
    if (recognized.isEmpty || spoken.isEmpty) {
      return false;
    }

    if (recognized.length > 12 &&
        (spoken.contains(recognized) || recognized.contains(spoken))) {
      return true;
    }

    final recognizedTokens =
        recognized.split(' ').where((token) => token.length > 3).toSet();
    if (recognizedTokens.length < 3) {
      return false;
    }

    final spokenTokens = spoken.split(' ').where((token) => token.length > 3);
    final overlap =
        spokenTokens.where((token) => recognizedTokens.contains(token)).length;
    return overlap / recognizedTokens.length >= 0.66;
  }

  String _normalizeSpeech(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[^\w\u0600-\u06FF ]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _handleDebugCommand() async {
    final command = _debugCommandController.text.trim();
    _debugCommandController.clear();
    await _processHeardCommand(command);
  }

  Future<bool> _handleLanguageCommand(String command) async {
    return false; // Disabled language switching for demo
  }

  Future<void> _setListeningLanguage(String language) async {
    final index = _preferredLocaleIds.indexWhere(
      (id) => id.toLowerCase().startsWith(language),
    );
    if (index == -1) {
      await _speakThenListen(
        'That listening language is not available on this phone. I can use $_availableLanguageLabels.',
      );
      return;
    }

    setState(() {
      _localeIndex = index;
      _localeId = _preferredLocaleIds[index];
    });
    await _speakThenListen('Listening language set to $_currentLocaleLabel.');
  }

  Future<void> _cycleListeningLanguage() async {
    if (_preferredLocaleIds.length <= 1) {
      await _speakThenListen(
        'Only $_currentLocaleLabel is available for speech recognition on this phone.',
      );
      return;
    }

    await _stopListening();
    setState(() {
      _localeIndex = (_localeIndex + 1) % _preferredLocaleIds.length;
      _localeId = _preferredLocaleIds[_localeIndex];
    });
    await _speakThenListen('Listening language set to $_currentLocaleLabel.');
  }

  String get _currentLocaleLabel {
    final id = _localeId;
    if (id == null || id.isEmpty) {
      return 'the phone default language';
    }
    final lower = id.toLowerCase();
    if (lower.startsWith('ar')) {
      return 'Arabic';
    }
    if (lower.startsWith('fr')) {
      return 'French';
    }
    if (lower.startsWith('en')) {
      return 'English';
    }

    final locale = _speechLocales.cast<LocaleName?>().firstWhere(
          (locale) => locale?.localeId == id,
          orElse: () => null,
        );
    return locale?.name ?? id;
  }

  String get _availableLanguageLabels {
    final labels = [
      for (final id in _preferredLocaleIds)
        if (id.toLowerCase().startsWith('ar'))
          'Arabic'
        else if (id.toLowerCase().startsWith('fr'))
          'French'
        else if (id.toLowerCase().startsWith('en'))
          'English'
        else
          id,
    ];
    return labels.toSet().join(', ');
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
      return const Scaffold(
      backgroundColor: AppColors.bg,body: Center(child: CircularProgressIndicator()));
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
      backgroundColor: AppColors.bg,
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
            const SizedBox(height: 12),
            AccessibleButton(
              label: 'Language: $_currentLocaleLabel',
              icon: Icons.language,
              outlined: true,
              onPressed: _speechAvailable
                  ? () async => _cycleListeningLanguage()
                  : null,
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
