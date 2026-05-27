import 'package:cleartodrive/core/utils/expiry_status_calculator.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.typeLabel,
    required this.plate,
    required this.expiryDate,
    this.onTap,
  });

  final String typeLabel;
  final String plate;
  final DateTime expiryDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ExpiryStatusCalculator.calculate(expiryDate);
    final days = ExpiryStatusCalculator.daysUntilExpiry(expiryDate);
    final scheme = Theme.of(context).colorScheme;
    final color = AppTheme.urgencyColor(status, scheme);
    final dateText = DateFormat('dd.MM.yyyy').format(expiryDate);

    final statusLabel = switch (status) {
      ExpiryStatus.expired => l10n.expired,
      ExpiryStatus.expiringSoon => l10n.expiringSoon,
      ExpiryStatus.valid => l10n.valid,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(plate, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      dateText,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(
                    label: Text(statusLabel),
                    backgroundColor: color.withValues(alpha: 0.12),
                    labelStyle: TextStyle(color: color, fontSize: 12),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (days >= 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.expiresIn(days),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String documentTypeLabel(AppLocalizations l10n, DocumentType type) {
  return switch (type) {
    DocumentType.rca => l10n.documentTypeRca,
    DocumentType.itp => l10n.documentTypeItp,
    DocumentType.rovinieta => l10n.documentTypeRovinieta,
  };
}
