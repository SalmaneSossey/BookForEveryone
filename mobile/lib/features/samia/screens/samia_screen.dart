import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/voice_commands.dart';
import '../../../core/models/book.dart';
import '../../../core/services/book_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/accessible_button.dart';
import '../../../core/widgets/book_card.dart';

class SamiaScreen extends StatefulWidget {
  const SamiaScreen({super.key});

  @override
  State<SamiaScreen> createState() => _SamiaScreenState();
}

class _SamiaScreenState extends State<SamiaScreen> {
  final BookRepository _repository = BookRepository();
  final TextEditingController _commandController = TextEditingController();
  late Future<List<Book>> _booksFuture = _repository.loadBooks();
  String _status = 'Samia is ready';

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _handleCommand() async {
    final command = _commandController.text.trim();
    final books = await _repository.loadBooks();
    if (!mounted) {
      return;
    }

    if (command.isEmpty) {
      setState(() {
        _status = 'Type a title or command';
        _booksFuture = Future.value(books);
      });
      return;
    }

    final lower = command.toLowerCase();
    final query = _commandQuery(command);
    final queryLower = query.toLowerCase();

    final matchedBook = books.cast<Book?>().firstWhere(
      (book) {
        if (book == null) {
          return false;
        }
        return lower.contains(book.title.toLowerCase()) ||
            queryLower.contains(book.title.toLowerCase()) ||
            book.title.toLowerCase().contains(queryLower) ||
            (book.titleAr != null &&
                (command.contains(book.titleAr!) ||
                    query.contains(book.titleAr!) ||
                    book.titleAr!.contains(query)));
      },
      orElse: () => null,
    );

    if (matchedBook != null) {
      if (mounted) {
        context.go('/reading/${matchedBook.id}');
      }
      return;
    }

    final isReadCommand =
        VoiceCommands.read.any((token) => lower.contains(token));
    if (isReadCommand && books.isNotEmpty) {
      if (mounted) {
        context.go('/reading/${books.first.id}');
      }
      return;
    }

    final results = await _repository.search(query.isEmpty ? command : query);
    if (!mounted) {
      return;
    }

    setState(() {
      _status = results.isEmpty
          ? 'No matching book yet'
          : 'Found ${results.length} matching book${results.length == 1 ? '' : 's'}';
      _booksFuture = Future.value(results.isEmpty ? books : results);
    });
  }

  String _commandQuery(String command) {
    var query = command.trim();
    final lower = query.toLowerCase();
    final tokens = [...VoiceCommands.read, ...VoiceCommands.search]
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final token in tokens) {
      final tokenLower = token.toLowerCase();
      if (lower == tokenLower) {
        return '';
      }
      if (lower.startsWith('$tokenLower ')) {
        query = query.substring(token.length).trim();
        break;
      }
    }
    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Samia'),
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
            final books = snapshot.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hearing, color: Colors.white, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _status,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _commandController,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _handleCommand(),
                  decoration: InputDecoration(
                    labelText: 'Command or book title',
                    prefixIcon: const Icon(Icons.keyboard_voice),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _CommandExamples(
                  onSelected: (command) {
                    _commandController.text = command;
                    _commandController.selection = TextSelection.collapsed(
                      offset: command.length,
                    );
                  },
                ),
                const SizedBox(height: 12),
                AccessibleButton(
                  label: 'Search / read',
                  icon: Icons.search,
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  onPressed: _handleCommand,
                ),
                const SizedBox(height: 24),
                Text('Books', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final book in books) ...[
                  SizedBox(
                    height: 238,
                    child: BookCard(
                      book: book,
                      trailing: const Icon(Icons.play_arrow),
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

class _CommandExamples extends StatelessWidget {
  const _CommandExamples({required this.onSelected});

  final ValueChanged<String> onSelected;

  static const _examples = [
    'read garden of words',
    'قرا ليا',
    'قلب على السوق',
    'read le jardin de rabat',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final example in _examples)
          ActionChip(
            avatar: const Icon(Icons.bolt, size: 18),
            label: Text(example),
            onPressed: () => onSelected(example),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      ],
    );
  }
}
