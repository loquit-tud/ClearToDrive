import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
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

  DocumentType? get _selectedType => ref.read(selectedDocumentTypeProvider);

  var _loadingMessage = '';

  Future<void> _runScan() async {
    final l10n = AppLocalizations.of(context);
    final type = _selectedType;
    if (type == null) return;

    setState(() {
      _loading = true;
      _loadingMessage = l10n.analyzingDocument;
    });
    try {
      final draft = await ref
          .read(scanAndExtractUseCaseProvider)
          .fromScan(typeHint: type);
      if (!mounted) return;
      ref.read(confirmDraftProvider.notifier).state = draft;
      await context.push('/confirm', extra: draft);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.actionFailedTryAgain)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _importFromGallery() async {
    final l10n = AppLocalizations.of(context);
    final type = _selectedType;
    if (type == null) return;

    // Do not show a modal overlay while the system gallery is open — it can
    // block or cancel the picker on some Android devices.
    try {
      final draft = await ref
          .read(importFromGalleryUseCaseProvider)
          .execute(typeHint: type);
      if (!mounted) return;
      ref.read(confirmDraftProvider.notifier).state = draft;
      await context.push('/confirm', extra: draft);
    } on ScanCancelled {
      // User dismissed picker — stay on capture, no message.
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.galleryImportFailed)));
      }
    }
  }

  void _manual() {
    final type = _selectedType;
    if (type == null) return;
    final draft = ref.read(manualEntryDraftFactoryProvider).empty(type: type);
    ref.read(confirmDraftProvider.notifier).state = draft;
    context.push('/manual');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(selectedDocumentTypeProvider);

    if (type == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addDocument)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.captureMissingType, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/add'),
                  child: Text(l10n.addDocument),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                  onPressed: _loading ? null : _runScan,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.scanDocument),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _importFromGallery,
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
                        Text(_loadingMessage),
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
