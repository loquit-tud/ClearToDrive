import 'package:cleartodrive/application/use_cases/scan_and_extract_use_case.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
import 'package:cleartodrive/presentation/widgets/document_card.dart';
import 'package:cleartodrive/presentation/widgets/document_image_preview.dart';
import 'package:cleartodrive/presentation/widgets/document_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({super.key, this.editDocumentId, this.initialDraft});

  final String? editDocumentId;
  final ConfirmDraft? initialDraft;

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
  String _ocrRawText = '';
  DocumentAssistStatus _assistStatus = DocumentAssistStatus.none;
  var _needsManualReview = false;
  var _saving = false;
  var _loadingEdit = false;
  var _editLoadStarted = false;
  var _draftApplied = false;

  @override
  void initState() {
    super.initState();
    if (widget.editDocumentId != null) {
      _loadingEdit = true;
      return;
    }
    // [initialDraft] is synchronous; ref is not available in initState.
    _applyDraftIfPresent(widget.initialDraft);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.editDocumentId != null && _loadingEdit && !_editLoadStarted) {
      _editLoadStarted = true;
      _loadEdit();
      return;
    }
    if (_draftApplied || widget.editDocumentId != null) return;
    final draft = widget.initialDraft ?? ref.read(confirmDraftProvider);
    if (draft == null) return;
    setState(() => _applyDraftIfPresent(draft));
  }

  void _applyDraftIfPresent(ConfirmDraft? draft) {
    if (_draftApplied || widget.editDocumentId != null || draft == null) {
      return;
    }
    _draftApplied = true;
    _initFromDraft(draft);
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
      _ocrRawText = '';
      _assistStatus = DocumentAssistStatus.none;
      _needsManualReview = false;
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
    _ocrRawText = draft.ocrRawText.trim();
    _assistStatus = draft.assistStatus;
    _needsManualReview = draft.needsManualReview;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_expiryDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.expiryDateRequired)));
      return;
    }

    setState(() => _saving = true);
    try {
      final draft = ConfirmDraft(
        type: _type!,
        licensePlate: _plateController!.text,
        expiryDate: _expiryDate,
        source: _source ?? DocumentSource.manual,
        imagePath: _imagePath,
        documentId: widget.editDocumentId ?? _documentId,
        vehicleId: _vehicleId,
      );
      await ref.read(confirmDocumentUseCaseProvider).save(draft);
      ref.read(confirmDraftProvider.notifier).state = null;
      ref.read(documentsRefreshProvider.notifier).state++;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.documentSaved)));
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _isGalleryImport =>
      _source == DocumentSource.import &&
      _imagePath != null &&
      !_imagePath!.startsWith('fake://');

  bool get _hasImagePreview =>
      _imagePath != null &&
      _imagePath!.isNotEmpty &&
      !_imagePath!.startsWith('fake://');

  bool get _isOcrImport =>
      _isGalleryImport && _assistStatus != DocumentAssistStatus.none;

  String _helperMessage(AppLocalizations l10n) {
    if (_assistStatus == DocumentAssistStatus.ocrSuccess) {
      if (_type == DocumentType.rca && _expiryDate != null) {
        return l10n.rcaOcrExpiryHelper;
      }
      return l10n.ocrImportSuccessHelper;
    }
    if (_assistStatus == DocumentAssistStatus.ocrNoData) {
      return l10n.ocrImportFailureHelper;
    }
    if (_isGalleryImport) return l10n.galleryImportHelper;
    return l10n.confirmDisclaimer;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loadingEdit) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.editDocumentId == null && !_draftApplied) {
      final draft = widget.initialDraft ?? ref.watch(confirmDraftProvider);
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  draft == null
                      ? l10n.confirmMissingDraft
                      : l10n.analyzingDocument,
                  textAlign: TextAlign.center,
                ),
                if (draft == null) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/add/capture'),
                    child: Text(l10n.importGallery),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (_type == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.confirmMissingDraft, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/add/capture'),
                  child: Text(l10n.importGallery),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentType)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DisclaimerBanner(message: _helperMessage(l10n)),
            const SizedBox(height: AppSpacing.sm),
            const ReviewWarningBanner(
              message: 'Verifică datele înainte de salvare.',
            ),
            if (_isOcrImport) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.ocrWarning,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (_isOcrImport) ...[
              const SizedBox(height: AppSpacing.sm),
              _OcrRawTextPanel(rawText: _ocrRawText),
            ],
            if (_hasImagePreview) ...[
              const SizedBox(height: AppSpacing.lg),
              DocumentImagePreview(imagePath: _imagePath),
            ],
            const SizedBox(height: AppSpacing.lg),
            DocumentTypeSelector(
              value: _type!,
              enabled: !_saving,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: l10n.licensePlate,
                hintText: 'B 123 ABC',
                helperText:
                    _needsManualReview && _plateController!.text.isNotEmpty
                    ? l10n.ocrVerifyManually
                    : null,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSpacing.lg),
            InkWell(
              onTap: _saving ? null : _pickDate,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: InputDecorator(
                decoration: InputDecoration(labelText: l10n.expiryDate),
                child: Text(
                  _expiryDate == null
                      ? l10n.completeManually
                      : DateFormat('dd.MM.yyyy').format(_expiryDate!),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _expiryDate == null
                        ? Theme.of(context).hintColor
                        : null,
                  ),
                ),
              ),
            ),
            if (_needsManualReview && _expiryDate != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.ocrVerifyManually,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
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
              const SizedBox(height: AppSpacing.sm),
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

class _OcrRawTextPanel extends StatelessWidget {
  const _OcrRawTextPanel({required this.rawText});

  final String rawText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = rawText.trim();

    return Material(
      color: AppColors.background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.cardRadius,
        side: const BorderSide(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        title: Text(
          l10n.ocrRawTextTitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(l10n.ocrRawTextHint, style: theme.textTheme.bodySmall),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              text.isEmpty ? l10n.ocrRawTextEmpty : text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
