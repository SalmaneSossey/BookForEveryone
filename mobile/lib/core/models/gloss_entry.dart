class GlossEntry {
  const GlossEntry({
    required this.word,
    required this.gloss,
    required this.available,
    this.sigmlPath,
  });

  final String word;
  final String gloss;
  final bool available;
  final String? sigmlPath;

  factory GlossEntry.fromJson(Map<String, dynamic> json) {
    return GlossEntry(
      word: json['word'] as String? ?? '',
      gloss: json['gloss'] as String? ?? '',
      available: json['available'] as bool? ?? false,
      sigmlPath: json['sigmlPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'gloss': gloss,
      'available': available,
      'sigmlPath': sigmlPath,
    };
  }
}
