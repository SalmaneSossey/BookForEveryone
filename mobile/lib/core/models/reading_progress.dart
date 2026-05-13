class ReadingProgress {
  const ReadingProgress({
    required this.bookId,
    required this.pageNumber,
    required this.updatedAt,
  });

  final String bookId;
  final int pageNumber;
  final DateTime updatedAt;

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      bookId: json['bookId'] as String? ?? '',
      pageNumber: json['pageNumber'] as int? ?? 1,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'pageNumber': pageNumber,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
