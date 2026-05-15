import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/models/gloss_entry.dart';

class TextToGlossService {
  const TextToGlossService();

  static Future<Map<String, String>>? _indexFuture;

  static const Map<String, String> _remoteDemoIndex = {
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

  Future<List<GlossEntry>> convert(String text) async {
    final index = await _loadIndex();
    final words = text
        .split(RegExp(r'\s+'))
        .map(_clean)
        .where((word) => word.isNotEmpty)
        .toList(growable: false);

    final glosses = <GlossEntry>[];
    var wordIndex = 0;
    while (wordIndex < words.length && glosses.length < 18) {
      final match = await _resolveBestMatch(words, wordIndex, index);
      glosses.add(match.entry);
      wordIndex += match.consumedWords;
    }

    return glosses;
  }

  Future<_GlossMatch> _resolveBestMatch(
    List<String> words,
    int start,
    Map<String, String> index,
  ) async {
    final remainingWords = words.length - start;
    final maxSpan = remainingWords < 4 ? remainingWords : 4;
    for (var span = maxSpan; span >= 1; span--) {
      final phrase = words.skip(start).take(span).join(' ');
      final entry = await _resolveEntry(phrase, index);
      if (entry.available) {
        return _GlossMatch(entry, span);
      }
    }

    return _GlossMatch(await _resolveEntry(words[start], index), 1);
  }

  Future<GlossEntry> _resolveEntry(
    String word,
    Map<String, String> index,
  ) async {
    final key = _normalizeArabic(word.toLowerCase());

    for (final candidate in _candidates(key)) {
      final remotePath = _remoteDemoIndex[candidate];
      if (remotePath != null) {
        return GlossEntry(
          word: word,
          gloss: candidate,
          available: true,
          sigmlPath: remotePath,
        );
      }

      final sigmlPath = index[candidate];
      if (sigmlPath == null) {
        continue;
      }

      final sigmlText = await _loadSigmlText(sigmlPath, candidate);
      if (sigmlText == null) {
        continue;
      }

      return GlossEntry(
        word: word,
        gloss: candidate,
        available: true,
        sigmlPath: sigmlPath,
        sigmlText: sigmlText,
      );
    }

    return GlossEntry(word: word, gloss: key, available: false);
  }

  static Future<Map<String, String>> _loadIndex() {
    return _indexFuture ??= _readIndex();
  }

  static Future<Map<String, String>> _readIndex() async {
    final raw = await rootBundle.loadString('assets/sigml/_index.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final index = <String, String>{};

    for (final entry in decoded.entries) {
      final path = entry.value as String? ?? '';
      if (path.isEmpty) {
        continue;
      }

      final key = _normalizeArabicStatic(entry.key.toLowerCase().trim());
      index[key] = path;
    }

    return index;
  }

  Future<String?> _loadSigmlText(String path, String gloss) async {
    try {
      final raw = await rootBundle.loadString('assets/sigml/$path');
      return _patchEmptyGloss(raw, gloss);
    } catch (_) {
      return null;
    }
  }

  String _patchEmptyGloss(String sigml, String gloss) {
    final escapedGloss = _escapeXmlAttribute(gloss);
    return sigml.replaceFirst(
        RegExp(r'gloss\s*=\s*""'), 'gloss="$escapedGloss"');
  }

  String _escapeXmlAttribute(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  String _clean(String word) {
    return word.replaceAll(RegExp(r'[^\w\u0600-\u06FF]+'), '');
  }

  String _normalizeArabic(String value) => _normalizeArabicStatic(value);

  static String _normalizeArabicStatic(String value) {
    return value
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه');
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

class _GlossMatch {
  const _GlossMatch(this.entry, this.consumedWords);

  final GlossEntry entry;
  final int consumedWords;
}
