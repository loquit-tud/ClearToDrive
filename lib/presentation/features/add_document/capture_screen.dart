import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/document_scanner_service.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
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
          ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              DecoratedBox(
                decoration: AppTheme.cardDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        child: const Icon(
                          Icons.document_scanner_outlined,
                          size: 34,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        documentTypeLabel(l10n, type),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Alege cum adaugi documentul.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _CaptureActionCard(
                title: l10n.scanDocument,
                subtitle: 'Folosește scanarea demo și verifică datele.',
                icon: Icons.camera_alt_outlined,
                primary: true,
                enabled: !_loading,
                onTap: _runScan,
              ),
              const SizedBox(height: AppSpacing.md),
              _CaptureActionCard(
                title: l10n.importGallery,
                subtitle: 'Alege o poză existentă din telefon.',
                icon: Icons.photo_library_outlined,
                enabled: !_loading,
                onTap: _importFromGallery,
              ),
              const SizedBox(height: AppSpacing.md),
              _CaptureActionCard(
                title: l10n.manualEntry,
                subtitle: 'Completează datele fără imagine.',
                icon: Icons.edit_calendar_outlined,
                enabled: !_loading,
                onTap: _manual,
              ),
            ],
          ),
          if (_loading)
            ColoredBox(
              color: Colors.black26,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSpacing.lg),
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

class _CaptureActionCard extends StatelessWidget {
  const _CaptureActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final background = primary
        ? AppColors.primaryBlue
        : AppColors.cardBackground;
    final foreground = primary ? Colors.white : AppColors.darkText;
    final muted = primary
        ? Colors.white.withValues(alpha: 0.78)
        : AppColors.mutedText;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: AppTheme.cardDecoration(
          color: background,
          borderColor: primary ? AppColors.primaryBlue : AppColors.border,
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: AppTheme.cardRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primary
                        ? Colors.white.withValues(alpha: 0.14)
                        : AppColors.primaryBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    icon,
                    color: primary ? Colors.white : AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: foreground),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: muted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: primary
                      ? Colors.white.withValues(alpha: 0.80)
                      : AppColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
