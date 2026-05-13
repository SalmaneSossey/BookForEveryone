import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/book.dart';
import '../../../core/services/book_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/accessible_button.dart';
import '../../../core/widgets/book_card.dart';

class HomeExploreScreen extends StatefulWidget {
  const HomeExploreScreen({super.key});

  @override
  State<HomeExploreScreen> createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen> {
  final BookRepository _repository = BookRepository();
  late final Future<List<Book>> _booksFuture = _repository.loadBooks();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: SafeArea(
        child: FutureBuilder<List<Book>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            final books = snapshot.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Two reading paths',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AccessibleButton(
                        label: 'Samia',
                        icon: Icons.record_voice_over,
                        backgroundColor: AppColors.ink,
                        foregroundColor: Colors.white,
                        onPressed: () => context.go('/samia'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AccessibleButton(
                        label: 'SignBook',
                        icon: Icons.sign_language,
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        onPressed: () => context.go('/home-deaf'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Library', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final book in books) ...[
                  SizedBox(
                    height: 238,
                    child: BookCard(
                      book: book,
                      trailing: const Icon(Icons.auto_stories),
                      onTap: () => context.go('/reading/${book.id}'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
