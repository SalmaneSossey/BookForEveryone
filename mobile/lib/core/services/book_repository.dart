import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/book.dart';

class BookRepository {
  BookRepository({AssetBundle? assetBundle}) : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  List<Book>? _cache;

  Future<List<Book>> loadBooks() async {
    if (_cache != null) {
      return _cache!;
    }

    final rawJson = await _assetBundle.loadString('assets/data/sample_books.json');
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final rawBooks = decoded['books'] as List<dynamic>? ?? const [];
    _cache = rawBooks
        .map((item) => Book.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
    return _cache!;
  }

  Future<Book?> findById(String id) async {
    final books = await loadBooks();
    for (final book in books) {
      if (book.id == id) {
        return book;
      }
    }
    return null;
  }

  Future<List<Book>> search(String query) async {
    final books = await loadBooks();
    return books.where((book) => book.matches(query)).toList(growable: false);
  }
}
