import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/widgets/document_card.dart';
import 'package:cleartodrive/presentation/widgets/document_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DocumentDetailScreen extends ConsumerWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final String documentId;

  String _sourceLabel(AppLocalizations l10n, DocumentSource source) {
    return switch (source) {
      DocumentSource.scan => l10n.sourceScan,
      DocumentSource.import => l10n.sourceImport,
      DocumentSource.manual => l10n.sourceManual,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.watch(documentsRefreshProvider);

    return FutureBuilder(
      future: ref.read(getDocumentDetailUseCaseProvider).execute(documentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final detail = snapshot.data;
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.documentNotFound)),
          );
        }

        final doc = detail.document;
        final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

        return Scaffold(
          appBar: AppBar(
            title: Text(documentTypeLabel(l10n, doc.type)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/document/$documentId/edit'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DocumentCard(
                typeLabel: documentTypeLabel(l10n, doc.type),
                plate: detail.plate,
                expiryDate: doc.expiryDate,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              DocumentImagePreview(imagePath: doc.imagePath),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _sourceLabel(l10n, doc.source),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.reminderPreview,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...detail.reminders.map(
                (r) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: Text(
                      r.offsetDays == 0
                          ? l10n.dayOfExpiry
                          : l10n.daysBeforeOffset(r.offsetDays),
                    ),
                    subtitle: Text(dateFormat.format(r.triggerAt)),
                  ),
                ),
              ),
              if (detail.reminders.isEmpty)
                Text(
                  '—',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.delete),
                      content: Text(l10n.deleteConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(deleteDocumentUseCaseProvider)
                        .execute(documentId);
                    ref.read(documentsRefreshProvider.notifier).state++;
                    if (context.mounted) context.go('/home');
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
    );
  }
}
