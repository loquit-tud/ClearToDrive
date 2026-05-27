import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/widgets/document_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  var _loading = false;

  DocumentType get _type =>
      ref.read(selectedDocumentTypeProvider) ?? DocumentType.rca;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _scan() async {
    await _run(() async {
      final draft = await ref
          .read(scanAndExtractUseCaseProvider)
          .fromScan(typeHint: _type);
      ref.read(confirmDraftProvider.notifier).state = draft;
      if (mounted) context.push('/confirm');
    });
  }

  Future<void> _import() async {
    await _run(() async {
      final draft = await ref
          .read(scanAndExtractUseCaseProvider)
          .fromGallery(typeHint: _type);
      ref.read(confirmDraftProvider.notifier).state = draft;
      if (mounted) context.push('/confirm');
    });
  }

  void _manual() {
    final draft = ref.read(manualEntryDraftFactoryProvider).empty(type: _type);
    ref.read(confirmDraftProvider.notifier).state = draft;
    context.push('/manual');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(selectedDocumentTypeProvider) ?? DocumentType.rca;

    return Scaffold(
      appBar: AppBar(title: Text(documentTypeLabel(l10n, type))),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          documentTypeLabel(l10n, type),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loading ? null : _scan,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.scanDocument),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _import,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.importGallery),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading ? null : _manual,
                  child: Text(l10n.manualEntry),
                ),
              ],
            ),
          ),
          if (_loading)
            ColoredBox(
              color: Colors.black26,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.analyzingDocument),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
