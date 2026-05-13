import 'gloss_entry.dart';

class BookPage {
  const BookPage({
    required this.bookId,
    required this.pageNumber,
    required this.content,
    required this.wordCount,
    this.glosses = const [],
  });

  final String bookId;
  final int pageNumber;
  final String content;
  final int wordCount;
  final List<GlossEntry> glosses;

  factory BookPage.fromJson(String bookId, Map<String, dynamic> json) {
    final content = json['content'] as String? ?? '';
    final rawGlosses = json['glosses'] as List<dynamic>? ?? const [];

    return BookPage(
      bookId: bookId,
      pageNumber: json['pageNumber'] as int? ?? 1,
      content: content,
      wordCount: json['wordCount'] as int? ?? _countWords(content),
      glosses: rawGlosses
          .map((item) => GlossEntry.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'pageNumber': pageNumber,
      'content': content,
      'wordCount': wordCount,
      'glosses': glosses.map((entry) => entry.toJson()).toList(),
    };
  }

  static int _countWords(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    return trimmed.split(RegExp(r'\s+')).length;
  }
}
