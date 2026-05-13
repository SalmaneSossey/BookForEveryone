import 'book_page.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.language,
    required this.category,
    required this.description,
    required this.totalPages,
    required this.coverEmoji,
    required this.accentColor,
    required this.hasSigml,
    required this.sigmlCoverage,
    required this.pages,
    this.titleAr,
  });

  final String id;
  final String title;
  final String? titleAr;
  final String author;
  final String language;
  final String category;
  final String description;
  final int totalPages;
  final String coverEmoji;
  final String accentColor;
  final bool hasSigml;
  final double sigmlCoverage;
  final List<BookPage> pages;

  factory Book.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final rawPages = json['pages'] as List<dynamic>? ?? const [];
    final pages = rawPages
        .map((item) => BookPage.fromJson(id, Map<String, dynamic>.from(item as Map)))
        .toList();

    return Book(
      id: id,
      title: json['title'] as String? ?? '',
      titleAr: json['titleAr'] as String?,
      author: json['author'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      totalPages: json['totalPages'] as int? ?? pages.length,
      coverEmoji: json['coverEmoji'] as String? ?? '📖',
      accentColor: json['accentColor'] as String? ?? '#159A8C',
      hasSigml: json['hasSigml'] as bool? ?? false,
      sigmlCoverage: (json['sigmlCoverage'] as num?)?.toDouble() ?? 0,
      pages: pages,
    );
  }

  BookPage pageAt(int pageNumber) {
    return pages.firstWhere(
      (page) => page.pageNumber == pageNumber,
      orElse: () => pages.first,
    );
  }

  bool matches(String query) {
    final normalized = query.toLowerCase().trim();
    if (normalized.isEmpty) {
      return true;
    }
    return title.toLowerCase().contains(normalized) ||
        (titleAr?.contains(query.trim()) ?? false) ||
        author.toLowerCase().contains(normalized) ||
        category.toLowerCase().contains(normalized);
  }
}
