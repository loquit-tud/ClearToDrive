import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/widgets/document_card.dart';
import 'package:cleartodrive/presentation/widgets/document_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  DocumentType? _type;
  TextEditingController? _plateController;
  DateTime? _expiryDate;
  var _saving = false;

  @override
  void dispose() {
    _plateController?.dispose();
    super.dispose();
  }

  void _ensureInitialized() {
    if (_type != null) return;
    final draft = ref.read(confirmDraftProvider);
    _type = draft?.type ?? ref.read(selectedDocumentTypeProvider) ?? DocumentType.rca;
    _plateController = TextEditingController(text: draft?.licensePlate ?? '');
    _expiryDate = draft?.expiryDate ?? DateTime.now().add(const Duration(days: 30));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final draft = ConfirmDraft(
        type: _type!,
        licensePlate: _plateController!.text,
        expiryDate: _expiryDate!,
        source: DocumentSource.manual,
      );
      await ref.read(confirmDocumentUseCaseProvider).save(draft);
      ref.read(confirmDraftProvider.notifier).state = null;
      ref.read(documentsRefreshProvider.notifier).state++;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).documentSaved)),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manualEntry)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DisclaimerBanner(message: l10n.confirmDisclaimer),
            const SizedBox(height: 16),
            DocumentTypeSelector(
              value: _type!,
              enabled: !_saving,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: l10n.licensePlate,
                hintText: 'B 123 ABC',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _saving ? null : _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: l10n.expiryDate),
                child: Text(
                  DateFormat('dd.MM.yyyy').format(_expiryDate!),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
