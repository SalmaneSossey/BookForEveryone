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

  test('TextToGlossService loads bundled ALSL SiGML words', () async {
    const service = TextToGlossService();
    final glosses = await service.convert('مرحبا يقرأ كتاب كلمة صوت يد شكرا');

    expect(glosses.every((entry) => entry.available), isTrue);
    expect(glosses.map((entry) => entry.sigmlPath), [
      'alsl/مرحبا.sigml',
      'alsl/يقرأ.sigml',
      'alsl/كتاب.sigml',
      'alsl/كلمة.sigml',
      'alsl/صوت.sigml',
      'alsl/يد.sigml',
      'alsl/شكرا.sigml',
    ]);
    expect(
        glosses
            .every((entry) => entry.sigmlText?.contains('<hns_sign') ?? false),
        isTrue);
  });

  test('TextToGlossService maps CWASA sample motion words', () async {
    const service = TextToGlossService();
    final glosses = await service.convert('I take mug');

    expect(glosses.map((entry) => entry.sigmlPath), [
      'cwasa_sample/i.sigml',
      'cwasa_sample/take.sigml',
      'cwasa_sample/mug.sigml',
    ]);
    expect(glosses.every((entry) => entry.available), isTrue);
  });

  test('TextToGlossService maps CWASA Blender Story demo words', () async {
    const service = TextToGlossService();
    final glosses = await service.convert(
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
