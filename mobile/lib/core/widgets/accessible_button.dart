import 'package:flutter/material.dart';

class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlined = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 24),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    if (outlined) {
      return Semantics(
        button: true,
        label: label,
        child: OutlinedButton(
          onPressed: onPressed,
          child: child,
        ),
      );
    }

    return Semantics(
      button: true,
      label: label,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
