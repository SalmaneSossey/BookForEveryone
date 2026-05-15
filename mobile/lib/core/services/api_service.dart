import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../models/book.dart';

class ApiService {
  ApiService({
    Dio? dio,
    String baseUrl = ApiConstants.baseUrl,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 2),
                receiveTimeout: const Duration(seconds: 4),
              ),
            );

  final Dio _dio;

  Future<bool> isHealthy() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiConstants.health);
    return response.statusCode == 200;
  }

  Future<List<Book>> loadBooks() async {
    await isHealthy();
    final response = await _dio.get<List<dynamic>>(ApiConstants.books);
    final rawBooks = response.data ?? const [];
    final enrichedBooks = await Future.wait(
      rawBooks.map((item) async {
        final bookJson = Map<String, dynamic>.from(item as Map);
        final pages = await _loadPages(
          bookJson['id'] as String? ?? '',
          bookJson['totalPages'] as int? ?? 0,
        );
        return Book.fromJson({
          ...bookJson,
          'pages': pages,
        });
      }),
    );
    return enrichedBooks.toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _loadPages(
    String bookId,
    int totalPages,
  ) async {
    if (bookId.isEmpty || totalPages <= 0) {
      return const [];
    }

    return Future.wait(
      List.generate(totalPages, (index) async {
        final pageNumber = index + 1;
        final response = await _dio.get<Map<String, dynamic>>(
          '${ApiConstants.books}/$bookId/content',
          queryParameters: {'page': pageNumber},
        );
        return response.data ?? <String, dynamic>{};
      }),
    );
  }
}
