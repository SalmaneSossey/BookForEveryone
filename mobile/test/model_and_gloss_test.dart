import 'package:flutter_test/flutter_test.dart';
import 'package:kitab_lil_jamie/core/models/book.dart';
import 'package:kitab_lil_jamie/features/signbook/services/text_to_gloss_service.dart';

void main() {
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
    final glosses = service.convert('كتاب وقراءة وصوت');

    expect(glosses.where((entry) => entry.available), isNotEmpty);
    expect(glosses.first.sigmlPath, 'additions_lsm/kitab.sigml');
  });
}
