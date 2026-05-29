import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddDocumentChooserScreen extends ConsumerWidget {
  const AddDocumentChooserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addDocument)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n.whatDocument,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Selectează tipul documentului înainte de scanare sau import.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: AppSpacing.xl),
          _TypeCard(
            label: l10n.documentTypeRca,
            icon: Icons.shield_outlined,
            onTap: () => _select(context, ref, DocumentType.rca),
          ),
          const SizedBox(height: AppSpacing.md),
          _TypeCard(
            label: l10n.documentTypeItp,
            icon: Icons.car_repair_outlined,
            onTap: () => _select(context, ref, DocumentType.itp),
          ),
          const SizedBox(height: AppSpacing.md),
          _TypeCard(
            label: l10n.documentTypeRovinieta,
            icon: Icons.confirmation_num_outlined,
            subtitle: l10n.rovinietaHint,
            onTap: () => _select(context, ref, DocumentType.rovinieta),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, WidgetRef ref, DocumentType type) {
    ref.read(selectedDocumentTypeProvider.notifier).state = type;
    context.push('/add/capture');
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppTheme.cardDecoration(),
      child: InkWell(
        onTap: onTap,
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
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(icon, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
