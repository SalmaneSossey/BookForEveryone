import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/book.dart';
import '../../../core/services/book_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/book_card.dart';

class HomeDeafScreen extends StatefulWidget {
  const HomeDeafScreen({super.key});

  @override
  State<HomeDeafScreen> createState() => _HomeDeafScreenState();
}

class _HomeDeafScreenState extends State<HomeDeafScreen> {
  final BookRepository _repository = BookRepository();
  late final Future<List<Book>> _booksFuture = _repository.loadBooks();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('SignBook'),
        actions: [
          IconButton(
            tooltip: 'Explore',
            icon: const Icon(Icons.explore),
            onPressed: () => context.go('/explore'),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Book>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final books = snapshot.data ?? const [];
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 238,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return BookCard(
                  book: book,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/signbook/${book.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
