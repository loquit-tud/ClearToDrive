import 'dart:io';

import 'package:cleartodrive/l10n/app_localizations.dart';
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
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != true) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.documentImageUnavailable)),
                ],
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.documentImageUnavailable),
              ),
            ),
          ),
        );
      },
    );
  }
}
