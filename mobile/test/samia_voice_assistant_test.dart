import 'package:flutter_test/flutter_test.dart';
import 'package:kitab_lil_jamie/core/models/book.dart';
import 'package:kitab_lil_jamie/core/models/book_page.dart';
import 'package:kitab_lil_jamie/features/samia/services/samia_voice_assistant.dart';

void main() {
  test('Samia confirms a named book and starts after yes', () {
    final assistant = SamiaVoiceAssistant(_books);

    final confirmation = assistant.handleCommand('read garden of words');
    expect(confirmation.mode, SamiaMode.confirmingBook);
    expect(confirmation.selectedBook?.id, 'garden');

    final start = assistant.handleCommand('yes');
    expect(start.action, SamiaAction.startReading);
    expect(start.selectedBook?.id, 'garden');
  });

  test('Samia suggests readable books by topic, excluding SignBook demos', () {
    final assistant = SamiaVoiceAssistant(_books);

    final response = assistant.handleCommand('Arabic story');

    expect(response.mode, SamiaMode.suggestingBooks);
    expect(response.suggestions, isNotEmpty);
    expect(
      response.suggestions.any(
        (book) => book.category.toLowerCase().contains('signbook'),
      ),
      isFalse,
    );
  });

  test('Samia maps reading commands to page controls', () {
    final assistant = SamiaVoiceAssistant(_books);
    assistant.readingStarted(_books[1]);

    expect(assistant.handleCommand('repeat').action, SamiaAction.repeatPage);
    expect(assistant.handleCommand('previous page').action,
        SamiaAction.previousPage);
    expect(assistant.handleCommand('stop').action, SamiaAction.stopReading);

    assistant.readingPaused();
    expect(
        assistant.handleCommand('continue').action, SamiaAction.resumeReading);
  });
}

final _books = [
  _book(
    id: 'signbook',
    title: 'ALSL Local Signs',
    titleAr: 'إشارات محلية جزائرية',
    category: 'SignBook demo',
    language: 'ar',
  ),
  _book(
    id: 'garden',
    title: 'Garden of Words',
    titleAr: 'حديقة الكلمات',
    category: 'Arabic',
    language: 'ar',
  ),
  _book(
    id: 'story',
    title: 'The Lantern of the Old Medina',
    titleAr: 'قنديل المدينة القديمة',
    category: 'Moroccan story',
    language: 'en',
  ),
];

Book _book({
  required String id,
  required String title,
  required String? titleAr,
  required String category,
  required String language,
}) {
  return Book(
    id: id,
    title: title,
    titleAr: titleAr,
    author: 'Tester',
    language: language,
    category: category,
    description: 'Demo book',
    totalPages: 1,
    coverEmoji: 'book',
    accentColor: '#159A8C',
    hasSigml: false,
    sigmlCoverage: 0,
    pages: [
      BookPage(
        bookId: id,
        pageNumber: 1,
        content: 'Page content',
        wordCount: 2,
      ),
    ],
  );
}
