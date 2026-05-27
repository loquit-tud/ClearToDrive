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

class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({super.key, this.editDocumentId});

  final String? editDocumentId;

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  DocumentType? _type;
  TextEditingController? _plateController;
  DateTime? _expiryDate;
  DocumentSource? _source;
  String? _imagePath;
  String? _documentId;
  String? _vehicleId;
  var _saving = false;
  var _loadingEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.editDocumentId != null) {
      _loadingEdit = true;
      _loadEdit();
    }
  }

  @override
  void dispose() {
    _plateController?.dispose();
    super.dispose();
  }

  Future<void> _loadEdit() async {
    final detail = await ref
        .read(getDocumentDetailUseCaseProvider)
        .execute(widget.editDocumentId!);
    if (!mounted || detail == null) return;
    setState(() {
      _type = detail.document.type;
      _plateController = TextEditingController(text: detail.plate);
      _expiryDate = detail.document.expiryDate;
      _source = detail.document.source;
      _imagePath = detail.document.imagePath;
      _documentId = detail.document.id;
      _vehicleId = detail.document.vehicleId;
      _loadingEdit = false;
    });
  }

  void _initFromDraft(ConfirmDraft draft) {
    _type ??= draft.type;
    _plateController ??= TextEditingController(text: draft.licensePlate);
    _expiryDate ??= draft.expiryDate;
    _source ??= draft.source;
    _imagePath ??= draft.imagePath;
    _documentId ??= draft.documentId;
    _vehicleId ??= draft.vehicleId;
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
        source: _source ?? DocumentSource.manual,
        imagePath: _imagePath,
        documentId: widget.editDocumentId ?? _documentId,
        vehicleId: _vehicleId,
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
    final l10n = AppLocalizations.of(context);

    if (_loadingEdit) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.editDocumentId == null) {
      final draft = ref.watch(confirmDraftProvider);
      if (draft == null && _type == null) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(l10n.completeManually)),
        );
      }
      if (draft != null) _initFromDraft(draft);
    }

    if (_type == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.completeManually)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentType)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DisclaimerBanner(message: l10n.confirmDisclaimer),
            const SizedBox(height: 16),
            if (_imagePath != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(_imagePath!),
                  subtitle: Text(l10n.sourceScan),
                ),
              ),
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
              borderRadius: BorderRadius.circular(12),
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
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
            if (widget.editDocumentId == null) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _saving ? null : () => context.pop(),
                child: Text(l10n.rescan),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
