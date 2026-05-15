import 'package:flutter_test/flutter_test.dart';
import 'package:kitab_lil_jamie/core/models/book.dart';
import 'package:kitab_lil_jamie/core/services/book_repository.dart';
import 'package:kitab_lil_jamie/features/signbook/services/text_to_gloss_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Book parses local JSON shape', () {
    final book = Book.fromJson({
      'id': 'demo',
      'title': 'Demo Book',
      'titleAr': 'كتاب تجريبي',
      'author': 'Tester',
      'language': 'ar',
      'category': 'Demo',
      'description': 'Accessible reading sample',
      'totalPages': 1,
      'coverEmoji': '📖',
      'accentColor': '#159A8C',
      'hasSigml': true,
      'sigmlCoverage': 0.5,
      'pages': [
        {
          'pageNumber': 1,
          'content': 'القراءة حق للجميع',
          'wordCount': 3,
        }
      ],
    });

    expect(book.id, 'demo');
    expect(book.pages, hasLength(1));
    expect(book.pageAt(1).content, contains('للجميع'));
  });

  test('TextToGlossService flags available SiGML words', () {
    const service = TextToGlossService();
    final glosses = service.convert('كتابا وقراءة وصوتا وحركة');

    expect(glosses.where((entry) => entry.available), isNotEmpty);
    expect(glosses.first.sigmlPath, 'additions_lsm/kitab.sigml');
    expect(glosses.where((entry) => entry.available), hasLength(4));
  });

  test('TextToGlossService maps CWASA sample motion words', () {
    const service = TextToGlossService();
    final glosses = service.convert('I take mug');

    expect(glosses.map((entry) => entry.sigmlPath), [
      'cwasa_sample/i.sigml',
      'cwasa_sample/take.sigml',
      'cwasa_sample/mug.sigml',
    ]);
    expect(glosses.every((entry) => entry.available), isTrue);
  });

  test('TextToGlossService maps CWASA Blender Story demo words', () {
    const service = TextToGlossService();
    final glosses = service.convert(
      'I see woman four friends cook soup orange blender explodes',
    );

    expect(
      glosses.where(
          (entry) => entry.sigmlPath == 'cwasa_story/blenderStory.sigml'),
      hasLength(9),
    );
    expect(glosses.every((entry) => entry.available), isTrue);
  });

  test('BookRepository falls back to local assets when backend mode is off',
      () async {
    final repository = BookRepository(useBackend: false);
    final books = await repository.loadBooks();

    expect(books, isNotEmpty);
    expect(books.every((book) => book.pages.isNotEmpty), isTrue);
  });
}
