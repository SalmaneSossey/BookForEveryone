import 'package:flutter/material.dart';

import '../../../core/models/gloss_entry.dart';
import '../../../core/theme/app_colors.dart';

class AvatarPlaceholder extends StatefulWidget {
  const AvatarPlaceholder({
    required this.active,
    required this.currentGloss,
    super.key,
  });

  final bool active;
  final GlossEntry? currentGloss;

  @override
  State<AvatarPlaceholder> createState() => _AvatarPlaceholderState();
}

class _AvatarPlaceholderState extends State<AvatarPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gloss = widget.currentGloss;
    final available = gloss?.available ?? false;
    final accentColor = available ? AppColors.green : AppColors.amber;
    final word = gloss?.word ?? 'SignBook';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final lift = widget.active ? (_controller.value * 16) : 0.0;
        final pulse = widget.active ? 0.88 + (_controller.value * 0.12) : 0.92;
        return Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -lift),
                  child: Transform.scale(
                    scale: pulse,
                    child: Container(
                      width: 134,
                      height: 134,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.22),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        available ? Icons.sign_language : Icons.text_fields,
                        color: Colors.white,
                        size: 72,
                        semanticLabel: available
                            ? 'Mapped signing gloss'
                            : 'Visual fallback gloss',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Text(
                    word,
                    key: ValueKey(word),
                    textDirection:
                        _isRtl(word) ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor),
                  ),
                  child: Text(
                    available ? 'Mapped sign' : 'Visual fallback',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isRtl(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }
}
