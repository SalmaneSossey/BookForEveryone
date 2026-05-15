import '../../../core/models/gloss_entry.dart';

class TextToGlossService {
  const TextToGlossService();

  static const Map<String, String> _sigmlIndex = {
    'كتاب': 'additions_lsm/kitab.sigml',
    'الكتاب': 'additions_lsm/kitab.sigml',
    'مكتبه': 'additions_lsm/library.sigml',
    'المكتبه': 'additions_lsm/library.sigml',
    'قراءة': 'additions_lsm/qiraa.sigml',
    'قراءه': 'additions_lsm/qiraa.sigml',
    'قرا': 'additions_lsm/qiraa.sigml',
    'اقرا': 'additions_lsm/qiraa.sigml',
    'تقرأ': 'additions_lsm/qiraa.sigml',
    'تقرا': 'additions_lsm/qiraa.sigml',
    'قرأ': 'additions_lsm/qiraa.sigml',
    'أمل': 'additions_lsm/amal.sigml',
    'امل': 'additions_lsm/amal.sigml',
    'صوت': 'additions_lsm/sawt.sigml',
    'حركة': 'additions_lsm/haraka.sigml',
    'حركه': 'additions_lsm/haraka.sigml',
    'اشاره': 'additions_lsm/sign.sigml',
    'الاشاره': 'additions_lsm/sign.sigml',
    'اشارات': 'additions_lsm/sign.sigml',
    'الإشارات': 'additions_lsm/sign.sigml',
    'كلمه': 'additions_lsm/word.sigml',
    'كلمة': 'additions_lsm/word.sigml',
    'كلمات': 'additions_lsm/word.sigml',
    'الكلمات': 'additions_lsm/word.sigml',
    'لغه': 'additions_lsm/language.sigml',
    'لغة': 'additions_lsm/language.sigml',
    'اللغه': 'additions_lsm/language.sigml',
    'الجميع': 'additions_lsm/everyone.sigml',
    'كل': 'additions_lsm/everyone.sigml',
    'يد': 'additions_lsm/hand.sigml',
    'يديها': 'additions_lsm/hand.sigml',
    'اليدين': 'additions_lsm/hand.sigml',
    'صوره': 'additions_lsm/image.sigml',
    'صورة': 'additions_lsm/image.sigml',
    'صور': 'additions_lsm/image.sigml',
    'المعنى': 'additions_lsm/meaning.sigml',
    'معنى': 'additions_lsm/meaning.sigml',
    'اطفال': 'additions_lsm/children.sigml',
    'الأطفال': 'additions_lsm/children.sigml',
    'الاطفال': 'additions_lsm/children.sigml',
    'ساميه': 'additions_lsm/samia.sigml',
    'سامية': 'additions_lsm/samia.sigml',
    'صباح': 'additions_lsm/morning.sigml',
    'story': 'additions_lsm/story.sigml',
    'book': 'additions_lsm/book.sigml',
    'library': 'additions_lsm/library.sigml',
    'read': 'additions_lsm/read.sigml',
    'reading': 'additions_lsm/read.sigml',
    'learn': 'additions_lsm/learn.sigml',
    'voice': 'additions_lsm/voice.sigml',
    'word': 'additions_lsm/word.sigml',
    'words': 'additions_lsm/word.sigml',
    'sign': 'additions_lsm/sign.sigml',
    'gesture': 'additions_lsm/sign.sigml',
    'hands': 'additions_lsm/hand.sigml',
    'i': 'cwasa_sample/i.sigml',
    'take': 'cwasa_sample/take.sigml',
    'mug': 'cwasa_sample/mug.sigml',
    'video': 'cwasa_story/blenderStory.sigml',
    'exciting': 'cwasa_story/blenderStory.sigml',
    'see': 'cwasa_story/blenderStory.sigml',
    'woman': 'cwasa_story/blenderStory.sigml',
    'four': 'cwasa_story/blenderStory.sigml',
    'friend': 'cwasa_story/blenderStory.sigml',
    'friends': 'cwasa_story/blenderStory.sigml',
    'cook': 'cwasa_story/blenderStory.sigml',
    'soup': 'cwasa_story/blenderStory.sigml',
    'orange': 'cwasa_story/blenderStory.sigml',
    'blender': 'cwasa_story/blenderStory.sigml',
    'put': 'cwasa_story/blenderStory.sigml',
    'explode': 'cwasa_story/blenderStory.sigml',
    'explodes': 'cwasa_story/blenderStory.sigml',
  };

  List<GlossEntry> convert(String text) {
    final words = text
        .split(RegExp(r'\s+'))
        .map(_clean)
        .where((word) => word.isNotEmpty)
        .take(18);

    return words.map((word) {
      final key = _normalizeArabic(word.toLowerCase());
      final sigmlPath = _resolveSigmlPath(key);
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

  String? _resolveSigmlPath(String key) {
    for (final candidate in _candidates(key)) {
      final match = _sigmlIndex[candidate];
      if (match != null) {
        return match;
      }
    }
    return null;
  }

  Iterable<String> _candidates(String key) sync* {
    final bases = <String>[key];
    if (key.startsWith('و') && key.length > 3) {
      bases.add(key.substring(1));
    }

    for (final base in bases) {
      yield base;

      if (base.startsWith('ال') && base.length > 3) {
        yield base.substring(2);
      }

      for (final suffix in const [
        'ها',
        'هم',
        'كم',
        'نا',
        'ات',
        'ين',
        'ون',
        'ه',
        'ي',
        'ا',
      ]) {
        if (base.endsWith(suffix) && base.length > suffix.length + 2) {
          final withoutSuffix = base.substring(0, base.length - suffix.length);
          yield withoutSuffix;
          if (withoutSuffix.startsWith('ال') && withoutSuffix.length > 3) {
            yield withoutSuffix.substring(2);
          }
        }
      }
    }
  }
}
