import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/book.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class BookRepository {
  BookRepository({
    AssetBundle? assetBundle,
    ApiService? apiService,
    bool useBackend = ApiConstants.backendEnabled,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _apiService = useBackend ? apiService ?? ApiService() : null;

  final AssetBundle _assetBundle;
  final ApiService? _apiService;
  List<Book>? _cache;

  Future<List<Book>> loadBooks() async {
    if (_cache != null) {
      return _cache!;
    }

    final apiService = _apiService;
    if (apiService != null) {
      try {
        final remoteBooks = await apiService.loadBooks();
        if (remoteBooks.isNotEmpty &&
            remoteBooks.every((book) => book.pages.isNotEmpty)) {
          _cache = remoteBooks;
          return _cache!;
        }
      } catch (_) {
        // Backend mode is optional; the pitch demo must keep working offline.
      }
    }

    _cache = await _loadLocalBooks();
    return _cache!;
  }

  Future<List<Book>> _loadLocalBooks() async {
    final rawJson =
        await _assetBundle.loadString('assets/data/sample_books.json');
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final rawBooks = decoded['books'] as List<dynamic>? ?? const [];
    return rawBooks
        .map((item) => Book.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
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
