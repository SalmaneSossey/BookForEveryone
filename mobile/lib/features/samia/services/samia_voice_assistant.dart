import '../../../core/models/book.dart';

enum SamiaMode {
  waitingForBook,
  suggestingBooks,
  confirmingBook,
  reading,
  paused,
}

enum SamiaAction {
  none,
  startReading,
  pauseReading,
  stopReading,
  resumeReading,
  nextPage,
  previousPage,
  repeatPage,
}

class SamiaResponse {
  const SamiaResponse({
    required this.mode,
    required this.prompt,
    this.action = SamiaAction.none,
    this.selectedBook,
    this.suggestions = const [],
  });

  final SamiaMode mode;
  final String prompt;
  final SamiaAction action;
  final Book? selectedBook;
  final List<Book> suggestions;
}

class SamiaVoiceAssistant {
  SamiaVoiceAssistant(List<Book> books)
      : _books = books
            .where(
              (book) => !book.category.toLowerCase().contains('signbook'),
            )
            .toList(growable: false);

  final List<Book> _books;

  SamiaMode _mode = SamiaMode.waitingForBook;
  Book? _selectedBook;
  List<Book> _suggestions = const [];

  SamiaMode get mode => _mode;
  Book? get selectedBook => _selectedBook;
  List<Book> get suggestions => _suggestions;

  SamiaResponse welcome() {
    _mode = SamiaMode.waitingForBook;
    return SamiaResponse(
      mode: _mode,
      prompt:
          'Welcome to Book for Everyone. What book would you like to listen to?',
    );
  }

  SamiaResponse handleCommand(String rawCommand) {
    final command = _normalize(rawCommand);
    if (command.isEmpty) {
      return _stay(
        'I did not hear a book name. Say a title, or say a topic like story, Arabic, French, or accessibility.',
      );
    }

    final globalAction = _globalAction(command);
    if (globalAction != null) {
      return globalAction;
    }

    switch (_mode) {
      case SamiaMode.confirmingBook:
        return _handleConfirmation(command);
      case SamiaMode.suggestingBooks:
        return _handleSuggestionChoice(command);
      case SamiaMode.reading:
      case SamiaMode.paused:
      case SamiaMode.waitingForBook:
        return _handleBookRequest(command);
    }
  }

  SamiaResponse readingStarted(Book book) {
    _selectedBook = book;
    _mode = SamiaMode.reading;
    return _stay('Reading ${_spokenTitle(book)}.');
  }

  SamiaResponse readingPaused() {
    _mode = SamiaMode.paused;
    return _stay(
        'Paused. Say continue, repeat, next page, previous page, or stop.');
  }

  SamiaResponse readingStopped() {
    _mode = SamiaMode.waitingForBook;
    return _stay('Stopped. What would you like to listen to next?');
  }

  SamiaResponse pageFinished({
    required bool hasNextPage,
    required bool isBookFinished,
  }) {
    _mode = SamiaMode.reading;
    if (isBookFinished) {
      return _stay(
        'The book is finished. Say repeat, choose another book, or stop.',
      );
    }
    if (hasNextPage) {
      return _stay(
        'Page finished. Say continue for the next page, repeat, previous page, or stop.',
      );
    }
    return _stay('Page finished. Say repeat, choose another book, or stop.');
  }

  SamiaResponse _handleConfirmation(String command) {
    if (_isYes(command) && _selectedBook != null) {
      _mode = SamiaMode.reading;
      return SamiaResponse(
        mode: _mode,
        prompt: 'Starting ${_spokenTitle(_selectedBook!)}.',
        action: SamiaAction.startReading,
        selectedBook: _selectedBook,
      );
    }

    if (_isNo(command)) {
      _selectedBook = null;
      _mode = SamiaMode.waitingForBook;
      return _stay('No problem. What type of book do you like?');
    }

    return _handleBookRequest(command);
  }

  SamiaResponse _handleSuggestionChoice(String command) {
    final index = _suggestionIndex(command);
    if (index != null && index >= 0 && index < _suggestions.length) {
      return _confirm(_suggestions[index]);
    }

    if (_isNo(command)) {
      _mode = SamiaMode.waitingForBook;
      _suggestions = const [];
      return _stay('Okay. Say a different title or topic.');
    }

    return _handleBookRequest(command);
  }

  SamiaResponse _handleBookRequest(String command) {
    final query = _removeRequestWords(command);
    final matches = _findBooks(query.isEmpty ? command : query);

    if (matches.isEmpty) {
      _mode = SamiaMode.waitingForBook;
      _suggestions = _topicFallback(command);
      if (_suggestions.isNotEmpty) {
        _mode = SamiaMode.suggestingBooks;
        return SamiaResponse(
          mode: _mode,
          prompt: _suggestionPrompt(_suggestions),
          suggestions: _suggestions,
        );
      }
      return _stay(
        'I could not find that yet. Say a topic like story, Arabic, French, education, or accessibility.',
      );
    }

    if (matches.length == 1 || _score(matches.first, query) >= 10) {
      return _confirm(matches.first);
    }

    _mode = SamiaMode.suggestingBooks;
    _suggestions = matches.take(3).toList(growable: false);
    return SamiaResponse(
      mode: _mode,
      prompt: _suggestionPrompt(_suggestions),
      suggestions: _suggestions,
    );
  }

  SamiaResponse _confirm(Book book) {
    _mode = SamiaMode.confirmingBook;
    _selectedBook = book;
    _suggestions = const [];
    return SamiaResponse(
      mode: _mode,
      prompt: 'Do you want me to start ${_spokenTitle(book)}?',
      selectedBook: book,
    );
  }

  SamiaResponse? _globalAction(String command) {
    if (_containsAny(
        command, const ['stop', 'cancel', 'quit', 'حبس', 'وقف', 'توقف'])) {
      _mode = SamiaMode.waitingForBook;
      return SamiaResponse(
        mode: _mode,
        prompt: 'Stopped. What would you like to listen to next?',
        action: SamiaAction.stopReading,
        selectedBook: _selectedBook,
      );
    }

    if (_containsAny(command, const ['pause', 'hold', 'سكت', 'وقف شوية'])) {
      _mode = SamiaMode.paused;
      return SamiaResponse(
        mode: _mode,
        prompt: 'Paused. Say continue when you are ready.',
        action: SamiaAction.pauseReading,
        selectedBook: _selectedBook,
      );
    }

    if (_containsAny(command, const ['repeat', 'again', 'عاود', 'كرر'])) {
      _mode = SamiaMode.reading;
      return SamiaResponse(
        mode: _mode,
        prompt: 'Repeating.',
        action: SamiaAction.repeatPage,
        selectedBook: _selectedBook,
      );
    }

    if (_containsAny(command, const [
      'next page',
      'next',
      'continue',
      'resume',
      'كمل',
      'تابع',
      'واصل',
      'الصفحة الموالية'
    ])) {
      final action = _mode == SamiaMode.paused
          ? SamiaAction.resumeReading
          : SamiaAction.nextPage;
      _mode = SamiaMode.reading;
      return SamiaResponse(
        mode: _mode,
        prompt: 'Continuing.',
        action: action,
        selectedBook: _selectedBook,
      );
    }

    if (_containsAny(command,
        const ['previous', 'back', 'last page', 'رجع', 'الصفحة السابقة'])) {
      _mode = SamiaMode.reading;
      return SamiaResponse(
        mode: _mode,
        prompt: 'Going back.',
        action: SamiaAction.previousPage,
        selectedBook: _selectedBook,
      );
    }

    if (_containsAny(command, const ['help', 'books', 'list', 'شنو كاين'])) {
      _mode = SamiaMode.suggestingBooks;
      _suggestions = _books.take(3).toList(growable: false);
      return SamiaResponse(
        mode: _mode,
        prompt: _suggestionPrompt(_suggestions),
        suggestions: _suggestions,
      );
    }

    return null;
  }

  List<Book> _findBooks(String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final scored = [
      for (final book in _books) MapEntry(book, _score(book, normalizedQuery)),
    ]..removeWhere((entry) => entry.value <= 0);

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((entry) => entry.key).toList(growable: false);
  }

  List<Book> _topicFallback(String command) {
    final topic = _normalize(command);
    Iterable<Book> matches = const [];

    if (_containsAny(
        topic, const ['story', 'stories', 'قصة', 'قصه', 'حكاية', 'حكايه'])) {
      matches =
          _books.where((book) => book.category.toLowerCase().contains('story'));
    } else if (_containsAny(
        topic, const ['arabic', 'عربي', 'العربية', 'العربيه'])) {
      matches = _books.where((book) => book.language == 'ar');
    } else if (_containsAny(
        topic, const ['french', 'francais', 'français', 'فرنسي'])) {
      matches = _books.where((book) => book.language == 'fr');
    } else if (_containsAny(
        topic, const ['english', 'انجليزي', 'english book'])) {
      matches = _books.where((book) => book.language == 'en');
    } else if (_containsAny(
        topic, const ['education', 'school', 'تعليم', 'مدرسة', 'مدرسه'])) {
      matches = _books
          .where((book) => book.category.toLowerCase().contains('education'));
    } else if (_containsAny(topic,
        const ['accessibility', 'blind', 'audio', 'ولوج', 'اعاقة', 'إعاقة'])) {
      matches = _books.where(
          (book) => book.category.toLowerCase().contains('accessibility'));
    }

    return matches.take(3).toList(growable: false);
  }

  int _score(Book book, String query) {
    final title = _normalize(book.title);
    final titleAr = _normalize(book.titleAr ?? '');
    final category = _normalize(book.category);
    final description = _normalize(book.description);
    var score = 0;

    if (title == query || titleAr == query) {
      score += 12;
    }
    if (title.contains(query) || titleAr.contains(query)) {
      score += 8;
    }
    if (query.contains(title) ||
        (titleAr.isNotEmpty && query.contains(titleAr))) {
      score += 8;
    }
    if (category.contains(query)) {
      score += 4;
    }

    final words = query.split(' ').where((word) => word.length > 2);
    for (final word in words) {
      if (title.contains(word) || titleAr.contains(word)) {
        score += 3;
      } else if (category.contains(word) || description.contains(word)) {
        score += 1;
      }
    }

    return score;
  }

  String _suggestionPrompt(List<Book> books) {
    if (books.isEmpty) {
      return 'I need a little more detail. What topic do you like?';
    }

    final titles = [
      for (var index = 0; index < books.length; index++)
        '${index + 1}. ${_spokenTitle(books[index])}',
    ].join('. ');
    return 'I found these books. $titles. Say the number, or say another topic.';
  }

  String _spokenTitle(Book book) {
    if (book.titleAr != null && book.language == 'ar') {
      return '${book.title}, ${book.titleAr}';
    }
    return book.title;
  }

  SamiaResponse _stay(String prompt) {
    return SamiaResponse(
      mode: _mode,
      prompt: prompt,
      selectedBook: _selectedBook,
      suggestions: _suggestions,
    );
  }

  String _removeRequestWords(String command) {
    var query = command;
    final prefixes = [
      'read',
      'start',
      'listen to',
      'open',
      'search',
      'find',
      'i want',
      'i like',
      'قرا ليا',
      'قرا',
      'بغيت',
      'قلب على',
      'فتح',
    ]..sort((a, b) => b.length.compareTo(a.length));

    for (final prefix in prefixes) {
      if (query == prefix) {
        return '';
      }
      if (query.startsWith('$prefix ')) {
        query = query.substring(prefix.length).trim();
      }
    }
    return query;
  }

  int? _suggestionIndex(String command) {
    if (_containsAny(command,
        const ['first', 'one', 'number one', '1', 'الأول', 'الاول', 'واحد'])) {
      return 0;
    }
    if (_containsAny(command,
        const ['second', 'two', 'number two', '2', 'الثاني', 'جوج', 'اثنين'])) {
      return 1;
    }
    if (_containsAny(command,
        const ['third', 'three', 'number three', '3', 'الثالث', 'ثلاثة'])) {
      return 2;
    }
    return null;
  }

  bool _isYes(String command) {
    return _containsAny(command, const [
      'yes',
      'yeah',
      'yep',
      'يس',
      'ok',
      'okay',
      'start',
      'read',
      'ريد',
      'نعم',
      'ايه',
      'اه',
      'آه',
      'بدا',
      'ابدأ',
      'موافق',
      'oui',
      'ouais',
      'daccord',
      "d'accord",
      'bien sur',
      'bien sûr',
      'commence',
      'lire',
      'yalha',
      'wakha',
      'واخا',
      'يالاه',
    ]);
  }

  bool _isNo(String command) {
    return _containsAny(command, const [
      'no',
      'nope',
      'another',
      'change',
      'لا',
      'ماشي',
      'بدل',
      'آخر',
      'اخر',
    ]);
  }

  bool _containsAny(String text, List<String> tokens) {
    return tokens.any((token) => text.contains(_normalize(token)));
  }

  String _normalize(String value) {
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
}
