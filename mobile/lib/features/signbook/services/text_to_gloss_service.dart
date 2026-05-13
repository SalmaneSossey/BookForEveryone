import '../../../core/models/gloss_entry.dart';

class TextToGlossService {
  const TextToGlossService();

  static const Map<String, String> _sigmlIndex = {
    'كتاب': 'additions_lsm/kitab.sigml',
    'الكتاب': 'additions_lsm/kitab.sigml',
    'قراءة': 'additions_lsm/qiraa.sigml',
    'قراءه': 'additions_lsm/qiraa.sigml',
    'أمل': 'additions_lsm/amal.sigml',
    'امل': 'additions_lsm/amal.sigml',
    'صوت': 'additions_lsm/sawt.sigml',
    'حركة': 'additions_lsm/haraka.sigml',
    'حركه': 'additions_lsm/haraka.sigml',
    'story': 'additions_lsm/story.sigml',
    'book': 'additions_lsm/book.sigml',
    'read': 'additions_lsm/read.sigml',
    'reading': 'additions_lsm/read.sigml',
    'learn': 'additions_lsm/learn.sigml',
  };

  List<GlossEntry> convert(String text) {
    final words = text
        .split(RegExp(r'\s+'))
        .map(_clean)
        .where((word) => word.isNotEmpty)
        .take(18);

    return words.map((word) {
      final key = _normalizeArabic(word.toLowerCase());
      final sigmlPath = _sigmlIndex[key];
      return GlossEntry(
        word: word,
        gloss: key,
        available: sigmlPath != null,
        sigmlPath: sigmlPath,
      );
    }).toList(growable: false);
  }

  String _clean(String word) {
    return word.replaceAll(RegExp(r'[^\w\u0600-\u06FF]+'), '');
  }

  String _normalizeArabic(String value) {
    return value
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه');
  }
}
