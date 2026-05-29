import 'dart:io';

import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DocumentImagePreview extends StatelessWidget {
  const DocumentImagePreview({
    super.key,
    required this.imagePath,
    this.height = 220,
  });

  final String? imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final path = imagePath;

    if (path == null || path.isEmpty || path.startsWith('fake://')) {
      return const SizedBox.shrink();
    }

    final file = File(path);
    if (!file.existsSync()) {
      return DecoratedBox(
        decoration: AppTheme.cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.broken_image_outlined, color: AppColors.danger),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(l10n.documentImageUnavailable)),
            ],
          ),
        ),
      );
    }

    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return DecoratedBox(
        decoration: AppTheme.cardDecoration(),
        child: ClipRRect(
          borderRadius: AppTheme.cardRadius,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.border.withValues(alpha: 0.55),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: AppColors.mutedText,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: AppTheme.cardDecoration(),
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Image.file(
          file,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.danger,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(l10n.documentImageUnavailable)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
