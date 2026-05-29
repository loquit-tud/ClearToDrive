import 'package:cleartodrive/core/utils/expiry_status_calculator.dart';
import 'package:cleartodrive/application/use_cases/list_documents_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
import 'package:cleartodrive/presentation/widgets/document_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<List<DocumentWithVehicle>>? _listFuture;
  int? _loadedRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final refresh = ref.watch(documentsRefreshProvider);
    final notificationStatus = ref.watch(notificationPermissionProvider);

    if (_listFuture == null || _loadedRefresh != refresh) {
      _loadedRefresh = refresh;
      _listFuture = ref.read(listDocumentsUseCaseProvider).execute();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car_outlined),
            onPressed: () => context.push('/vehicles'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addDocument),
      ),
      body: FutureBuilder(
        future: _listFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          return _HomeContent(
            items: items,
            notificationEnabled: notificationStatus,
            onAddDocument: () => context.push('/add'),
            onOpenSettings: () => context.push('/settings'),
            onOpenDocument: (id) => context.push('/document/$id'),
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.items,
    required this.notificationEnabled,
    required this.onAddDocument,
    required this.onOpenSettings,
    required this.onOpenDocument,
  });

  final List<DocumentWithVehicle> items;
  final AsyncValue<bool> notificationEnabled;
  final VoidCallback onAddDocument;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final children = <Widget>[
      notificationEnabled.when(
        data: (enabled) => enabled
            ? const SizedBox.shrink()
            : _NotificationCard(onTap: onOpenSettings),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
      _DriveStatusCard(items: items),
      _VehicleSummaryCard(items: items),
      const _SectionHeader(title: 'Documente'),
      if (items.isEmpty)
        _EmptyDocumentsState(onAddDocument: onAddDocument)
      else
        ...items.map(
          (item) => DocumentCard(
            typeLabel: documentTypeLabel(l10n, item.document.type),
            plate: item.plate,
            expiryDate: item.document.expiryDate,
            onTap: () => onOpenDocument(item.document.id),
          ),
        ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        88,
      ),
      itemCount: children.length,
      separatorBuilder: (_, index) => children[index] is _SectionHeader
          ? const SizedBox(height: 8)
          : const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, index) => children[index],
    );
  }
}

class _DriveStatusCard extends StatelessWidget {
  const _DriveStatusCard({required this.items});

  final List<DocumentWithVehicle> items;

  @override
  Widget build(BuildContext context) {
    final status = _overallStatus(items);
    final color = status == null
        ? AppColors.primaryBlue
        : AppColors.status(status);
    final title = _statusTitle(status, items.isEmpty);
    final subtitle = _statusSubtitle(status, items.length);

    return DecoratedBox(
      decoration: AppTheme.cardDecoration(
        borderColor: color.withValues(alpha: 0.24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Icon(_statusIcon(status), color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ExpiryStatus? _overallStatus(List<DocumentWithVehicle> items) {
    if (items.isEmpty) return null;
    final statuses = items
        .map(
          (item) => ExpiryStatusCalculator.calculate(item.document.expiryDate),
        )
        .toList();
    if (statuses.contains(ExpiryStatus.expired)) return ExpiryStatus.expired;
    if (statuses.contains(ExpiryStatus.expiringSoon)) {
      return ExpiryStatus.expiringSoon;
    }
    return ExpiryStatus.valid;
  }

  String _statusTitle(ExpiryStatus? status, bool isEmpty) {
    if (isEmpty) return 'Adaugă documentele mașinii';
    return switch (status) {
      ExpiryStatus.expired => 'Ai documente expirate',
      ExpiryStatus.expiringSoon => 'Verifică expirările apropiate',
      ExpiryStatus.valid => 'Ești clear to drive',
      null => 'Adaugă documentele mașinii',
    };
  }

  String _statusSubtitle(ExpiryStatus? status, int count) {
    if (count == 0) {
      return 'RCA, ITP și Rovinietă vor apărea aici după salvare.';
    }
    return switch (status) {
      ExpiryStatus.expired =>
        'Actualizează documentele expirate înainte de drum.',
      ExpiryStatus.expiringSoon =>
        'Un document expiră curând. Confirmă data și setează memento-uri.',
      ExpiryStatus.valid => '$count documente sunt valide în aplicație.',
      null => 'RCA, ITP și Rovinietă vor apărea aici după salvare.',
    };
  }

  IconData _statusIcon(ExpiryStatus? status) {
    return switch (status) {
      ExpiryStatus.expired => Icons.error_outline,
      ExpiryStatus.expiringSoon => Icons.warning_amber_outlined,
      ExpiryStatus.valid => Icons.verified_outlined,
      null => Icons.directions_car_outlined,
    };
  }
}

class _VehicleSummaryCard extends StatelessWidget {
  const _VehicleSummaryCard({required this.items});

  final List<DocumentWithVehicle> items;

  @override
  Widget build(BuildContext context) {
    final plates = items.map((item) => item.plate).toSet();
    final first = items.isEmpty ? null : items.first;
    final title = first?.displayName?.trim().isNotEmpty == true
        ? first!.displayName!.trim()
        : first?.plate ?? 'Mașina ta';
    final subtitle = items.isEmpty
        ? 'Ține evidența documentelor importante local, pe telefon.'
        : plates.length == 1
        ? '${first!.plate} · ${items.length} documente urmărite'
        : '${plates.length} mașini · ${items.length} documente urmărite';

    return DecoratedBox(
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppColors.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.cardRadius,
        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.28)),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.notifications_off_outlined,
          color: AppColors.warning,
        ),
        title: Text(l10n.notificationPermissionsDisabled),
        subtitle: Text(l10n.notificationDeniedExplanation),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _EmptyDocumentsState extends StatelessWidget {
  const _EmptyDocumentsState({required this.onAddDocument});

  final VoidCallback onAddDocument;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
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
                Icons.description_outlined,
                size: 34,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.noDocuments,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noDocumentsHint,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAddDocument,
              icon: const Icon(Icons.add),
              label: Text(l10n.addDocument),
            ),
          ],
        ),
      ),
    );
  }
}
