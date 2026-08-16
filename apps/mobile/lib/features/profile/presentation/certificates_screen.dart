import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/profile_controllers.dart';
import '../data/profile_repository.dart';
import 'verify_certificate_screen.dart';
import 'widgets/profile_widgets.dart';

/// PR-05 · Certificates.
///
/// Verified-by-Ejadah and stated-by-the-holder appear in the same list and are
/// never conflated: different icon, different colour, different words, and only
/// the verified one carries a public verification code. "Add your own" creates
/// a **stated** certificate — there is no path in this screen, or in the API
/// behind it, that produces a verified one.
class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final certificates = ref.watch(myCertificatesProvider);

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.certificatesTitle,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: certificates.when(
            loading: () => ListView.separated(
              itemCount: 3,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: EjadahSpacing.cardGap),
              itemBuilder: (_, _) => const CardSkeleton(),
            ),
            error: (error, _) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: error is Failure
                  ? error.message(context)
                  : FailureCopy.server(context),
              retryLabel: strings.retry,
              onRetry: () => ref.invalidate(myCertificatesProvider),
            ),
            data: (items) => items.isEmpty
                ? EjadahEmptyState(
                    title: strings.certificatesTitle,
                    body: strings.verifyNote,
                    actionLabel: strings.addCertificate,
                    onAction: () => _add(context, ref),
                  )
                : ListView(
                    key: const PageStorageKey('certificates'),
                    children: [
                      const SizedBox(height: EjadahSpacing.md),
                      // States the distinction before the list, so the badges
                      // are read as a system rather than as decoration.
                      InlineAlert(
                        message: strings.verifyNote,
                        tone: AlertTone.info,
                      ),
                      const SizedBox(height: EjadahSpacing.md),
                      for (final certificate in items)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: EjadahSpacing.cardGap,
                          ),
                          child: CertificateTile(
                            certificate: certificate,
                            onOpenVerification:
                                certificate.verificationCode == null
                                ? null
                                : () => _openVerification(
                                    context,
                                    certificate.verificationCode!,
                                  ),
                            onRemove:
                                certificate.evidence ==
                                    CredentialEvidence.statedByProfessional
                                // Only a self-added certificate can be
                                // removed; an Ejadah-issued one is a record.
                                ? () => _remove(context, ref, certificate)
                                : null,
                          ),
                        ),
                      const SizedBox(height: EjadahSpacing.xs),
                      EjadahSecondaryButton(
                        label: strings.addCertificate,
                        onPressed: () => _add(context, ref),
                      ),
                      const SizedBox(height: EjadahSpacing.section),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _openVerification(BuildContext context, String code) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradientBudget(
          screenName: 'verify-certificate',
          child: VerifyCertificateScreen(code: code),
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const GradientBudget(
          screenName: 'add-certificate',
          child: AddCertificateScreen(),
        ),
      ),
    );
    if (added ?? false) ref.invalidate(myCertificatesProvider);
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Certificate certificate,
  ) async {
    final strings = context.strings;
    final confirmed = await showEjadahConfirmDialog(
      context: context,
      title: certificate.title.resolve(context.language),
      consequence: strings.notVerified,
      confirmLabel: strings.done,
      cancelLabel: strings.cancel,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref
          .read(profileRepositoryProvider)
          .deleteCertificate(certificate.id);
      ref.invalidate(myCertificatesProvider);
    } on Failure catch (failure) {
      if (!context.mounted) return;
      showEjadahToast(context, message: failure.message(context));
    }
  }
}

/// Adds a certificate the user states themselves.
///
/// The form says, before anything is typed, that what it produces is stated
/// and not verified. Implying otherwise is the one thing this screen must make
/// impossible.
class AddCertificateScreen extends ConsumerStatefulWidget {
  const AddCertificateScreen({super.key});

  @override
  ConsumerState<AddCertificateScreen> createState() =>
      _AddCertificateScreenState();
}

class _AddCertificateScreenState extends ConsumerState<AddCertificateScreen> {
  final _title = TextEditingController();
  final _issuer = TextEditingController();
  final _points = TextEditingController(text: '0');
  DateTime _issuedOn = DateTime.now();
  bool _isSaving = false;
  String? _formError;
  Map<String, LocalizedText> _fieldErrors = const {};

  @override
  void dispose() {
    _title.dispose();
    _issuer.dispose();
    _points.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final language = context.language;

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.addCertificate,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: ListView(
            children: [
              const SizedBox(height: EjadahSpacing.md),
              // Said up front, not discovered afterwards.
              Row(
                children: [
                  VerificationBadge(
                    evidence: CredentialEvidence.statedByProfessional,
                    verifiedLabel: strings.verifiedByEjadah,
                    statedLabel: strings.statedByTutor,
                  ),
                ],
              ),
              const SizedBox(height: EjadahSpacing.xs),
              InlineAlert(
                message: strings.notVerified,
                tone: AlertTone.warning,
              ),
              const SizedBox(height: EjadahSpacing.md),
              if (_formError != null) ...[
                InlineAlert(message: _formError!, tone: AlertTone.danger),
                const SizedBox(height: EjadahSpacing.md),
              ],
              EjadahInput(
                label: strings.certificatesTitle,
                controller: _title,
                errorText: _fieldErrors['title']?.resolve(language),
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahInput(label: strings.issuedBy, controller: _issuer),
              const SizedBox(height: EjadahSpacing.md),
              EjadahListRow(
                title: strings.issuedOn,
                subtitle: formatCertificateDate(_issuedOn, language),
                onTap: _pickDate,
                trailing: const Icon(
                  EjadahIcons.calendar,
                  size: EjadahIconSize.inline,
                  color: EjadahColors.labelMuted,
                ),
              ),
              if (_fieldErrors['issued_on'] != null)
                Text(
                  _fieldErrors['issued_on']!.resolve(language),
                  style: context.type.caption(color: EjadahColors.dangerText),
                ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahInput(
                label: strings.incCpd,
                controller: _points,
                keyboardType: TextInputType.number,
                errorText: _fieldErrors['cpd_points']?.resolve(language),
              ),
              const SizedBox(height: EjadahSpacing.lg),
              EjadahPrimaryButton(
                label: strings.save,
                isLoading: _isSaving,
                onPressed: _save,
              ),
              const SizedBox(height: EjadahSpacing.xs),
              EjadahGhostButton(
                label: strings.cancel,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: EjadahSpacing.section),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedOn,
      firstDate: DateTime(now.year - 60),
      // A certificate cannot have been issued tomorrow.
      lastDate: now,
    );
    if (picked != null) setState(() => _issuedOn = picked);
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _formError = null;
      _fieldErrors = const {};
    });

    final title = _title.text.trim();
    try {
      await ref
          .read(profileRepositoryProvider)
          .addStatedCertificate(
            title: LocalizedText(en: title, ar: title),
            issuer: LocalizedText(
              en: _issuer.text.trim(),
              ar: _issuer.text.trim(),
            ),
            issuedOn: DateTime.utc(
              _issuedOn.year,
              _issuedOn.month,
              _issuedOn.day,
            ),
            cpdPoints: int.tryParse(_points.text.trim()) ?? 0,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ValidationFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _fieldErrors = failure.fields;
        if (failure.fields.isEmpty) {
          _formError = failure.message.resolve(context.language);
        }
      });
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _formError = failure.message.resolve(context.language);
      });
    }
  }
}
