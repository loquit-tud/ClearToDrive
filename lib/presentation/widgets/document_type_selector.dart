import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
import 'package:cleartodrive/presentation/widgets/document_card.dart';
import 'package:flutter/material.dart';

class DocumentTypeSelector extends StatelessWidget {
  const DocumentTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final DocumentType value;
  final ValueChanged<DocumentType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.documentType, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DocumentType.values.map((type) {
            return ChoiceChip(
              label: Text(documentTypeLabel(l10n, type)),
              selected: value == type,
              onSelected: enabled ? (_) => onChanged(type) : null,
              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.12),
              backgroundColor: AppColors.cardBackground,
              side: BorderSide(
                color: value == type
                    ? AppColors.primaryBlue.withValues(alpha: 0.38)
                    : AppColors.border,
              ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value == type
                    ? AppColors.primaryBlue
                    : AppColors.darkText,
                fontWeight: FontWeight.w700,
              ),
              checkmarkColor: AppColors.primaryBlue,
            );
          }).toList(),
        ),
      ],
    );
  }
}
