import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.whatDocument,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _TypeCard(
              label: l10n.documentTypeRca,
              icon: Icons.shield_outlined,
              onTap: () => _select(context, ref, DocumentType.rca),
            ),
            const SizedBox(height: 12),
            _TypeCard(
              label: l10n.documentTypeItp,
              icon: Icons.build_circle_outlined,
              onTap: () => _select(context, ref, DocumentType.itp),
            ),
            const SizedBox(height: 12),
            _TypeCard(
              label: l10n.documentTypeRovinieta,
              icon: Icons.confirmation_num_outlined,
              subtitle: l10n.rovinietaHint,
              onTap: () => _select(context, ref, DocumentType.rovinieta),
            ),
          ],
        ),
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
