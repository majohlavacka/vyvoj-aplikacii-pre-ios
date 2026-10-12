import 'package:flutter/material.dart';

/// Obrázok vlajky načítaný zo siete s indikátorom načítania.
class FlagImage extends StatelessWidget {
  const FlagImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final String url;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholderColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width ?? 120,
            height: height ?? 80,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: width ?? 120,
          height: height ?? 80,
          color: placeholderColor,
          child: const Icon(Icons.flag_outlined),
        ),
      ),
    );
  }
}
