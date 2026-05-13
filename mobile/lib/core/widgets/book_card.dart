import 'package:flutter/material.dart';

import '../models/book.dart';
import '../theme/app_colors.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    required this.book,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final Book book;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(book.accentColor);

    return Semantics(
      button: true,
      label: '${book.title}, ${book.author}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(book.coverEmoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (book.titleAr != null)
                          Text(
                            book.titleAr!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                book.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.language, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(book.language.toUpperCase()),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String value) {
    final hex = value.replaceFirst('#', '');
    final parsed = int.tryParse('FF$hex', radix: 16);
    if (parsed == null) {
      return AppColors.teal;
    }
    return Color(parsed);
  }
}
