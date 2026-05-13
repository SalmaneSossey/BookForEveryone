import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AvatarPlaceholder extends StatefulWidget {
  const AvatarPlaceholder({
    required this.active,
    super.key,
  });

  final bool active;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final lift = widget.active ? (_controller.value * 16) : 0.0;
        return Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Transform.translate(
              offset: Offset(0, -lift),
              child: Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.teal, width: 3),
                ),
                child: const Icon(
                  Icons.sign_language,
                  color: Colors.white,
                  size: 86,
                  semanticLabel: 'Signing avatar placeholder',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
