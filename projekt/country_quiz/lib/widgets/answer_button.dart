import 'package:flutter/material.dart';

enum AnswerState { idle, correct, wrong, disabled }

/// Tlačidlo s možnosťou odpovede. Farba podľa [state],
/// kliknutie sa odovzdá rodičovi cez callback [onPressed].
class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    required this.state,
    required this.onPressed,
  });

  final String label;
  final AnswerState state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground) = switch (state) {
      AnswerState.idle => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      AnswerState.correct => (Colors.green.shade600, Colors.white),
      AnswerState.wrong => (Colors.red.shade600, Colors.white),
      AnswerState.disabled => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };

    final IconData? icon = switch (state) {
      AnswerState.correct => Icons.check_circle,
      AnswerState.wrong => Icons.cancel,
      _ => null,
    };

    return SizedBox(
      height: 64,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background,
          disabledForegroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
