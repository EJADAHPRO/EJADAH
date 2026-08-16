import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';
import 'widgets/profile_widgets.dart';

/// PR-04 · The NFC card editor.
///
/// The preview at the top is the same widget the card screen and the public
/// page use, and it updates on every keystroke — so what the user is editing
/// is literally what a visitor will see, not an approximation of it.
///
/// URL fields are validated as `https`. An `http` link is rejected rather than
/// silently upgraded: a printed card carrying a plaintext link is a downgrade
/// a stranger cannot see.
class NfcEditorScreen extends ConsumerStatefulWidget {
  const NfcEditorScreen({required this.card, super.key});

  final MyProfileCard card;

  @override
  ConsumerState<NfcEditorScreen> createState() => _NfcEditorScreenState();
}

class _NfcEditorScreenState extends ConsumerState<NfcEditorScreen> {
  late final TextEditingController _slug;
  late final TextEditingController _titleAr;
  late final TextEditingController _titleEn;
  late final TextEditingController _clinicAr;
  late final TextEditingController _clinicEn;
  late final TextEditingController _bioAr;
  late final TextEditingController _bioEn;
  late final Map<String, TextEditingController> _links;

  bool _isPublic = false;
  bool _isSaving = false;
  Map<String, LocalizedText> _fieldErrors = const {};
  String? _formError;

  /// The link keys the card renders. The server drops anything else.
  static const List<String> _linkKeys = [
    'website',
    'linkedin',
    'instagram',
    'whatsapp',
  ];

  @override
  void initState() {
    super.initState();
    final card = widget.card;
    _slug = TextEditingController(text: card.slug ?? '');
    _titleAr = TextEditingController(text: card.title.ar);
    _titleEn = TextEditingController(text: card.title.en);
    _clinicAr = TextEditingController(text: card.clinic.ar);
    _clinicEn = TextEditingController(text: card.clinic.en);
    _bioAr = TextEditingController(text: card.bio.ar);
    _bioEn = TextEditingController(text: card.bio.en);
    _links = {
      for (final key in _linkKeys)
        key: TextEditingController(text: card.links[key] ?? ''),
    };
    _isPublic = card.isPublic;

    // Live preview: every field rebuilds the card above as it is typed.
    for (final controller in [
      _slug,
      _titleAr,
      _titleEn,
      _clinicAr,
      _clinicEn,
      ..._links.values,
    ]) {
      controller.addListener(_onChanged);
    }
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    for (final controller in [
      _slug,
      _titleAr,
      _titleEn,
      _clinicAr,
      _clinicEn,
      _bioAr,
      _bioEn,
      ..._links.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final language = context.language;
    final isArabic = language == AppLanguage.ar;

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.editCardTitle,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: ListView(
            key: const PageStorageKey('nfc-editor'),
            children: [
              const SizedBox(height: EjadahSpacing.md),
              // The live preview. Same widget as the real card.
              NfcCardPreview(
                name: widget.card.displayName.resolve(language),
                title: isArabic ? _titleAr.text : _titleEn.text,
                clinic: isArabic ? _clinicAr.text : _clinicEn.text,
                url: _slug.text.isEmpty
                    ? null
                    : 'https://ejadah.international/dr/${_slug.text}',
              ),
              const SizedBox(height: EjadahSpacing.lg),
              if (_formError != null) ...[
                InlineAlert(message: _formError!, tone: AlertTone.danger),
                const SizedBox(height: EjadahSpacing.md),
              ],
              EjadahInput(
                label: strings.publicCardTitle,
                controller: _slug,
                hint: 'nour-hassan',
                errorText: _errorFor('slug', language),
                helperText: strings.publicPageNote,
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahInput(
                label: '${strings.fieldTitle} · العربية',
                controller: _titleAr,
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahInput(
                label: '${strings.fieldTitle} · English',
                controller: _titleEn,
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahInput(
                label: '${strings.fieldClinic} · العربية',
                controller: _clinicAr,
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahInput(
                label: '${strings.fieldClinic} · English',
                controller: _clinicEn,
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahInput(
                label: '${strings.fieldBio} · العربية',
                controller: _bioAr,
                maxLines: 4,
                helperText: strings.patientDataWarning,
                errorText: _errorFor('bio', language),
              ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahInput(
                label: '${strings.fieldBio} · English',
                controller: _bioEn,
                maxLines: 4,
              ),
              const SizedBox(height: EjadahSpacing.lg),
              SectionHeader(title: strings.linksLabel),
              for (final key in _linkKeys) ...[
                const SizedBox(height: EjadahSpacing.sm),
                EjadahInput(
                  label: key,
                  controller: _links[key]!,
                  hint: 'https://',
                  keyboardType: TextInputType.url,
                  errorText: _linkError(key),
                ),
              ],
              const SizedBox(height: EjadahSpacing.lg),
              SettingsToggleRow(
                title: strings.publicCardTitle,
                subtitle: strings.publicPageNote,
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
              ),
              const SizedBox(height: EjadahSpacing.lg),
              EjadahPrimaryButton(
                label: strings.saveChanges,
                isLoading: _isSaving,
                onPressed: _hasInvalidLink ? null : _save,
                // The offending field already shows the rule; the button
                // repeats it, because a user who scrolled past the field sees
                // only a control that will not move.
                disabledReason: context.language == AppLanguage.ar
                    ? 'يجب أن يبدأ الرابط بـ https://'
                    : 'Links must start with https://',
                onDisabledTap: (reason) =>
                    showEjadahToast(context, message: reason),
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

  bool get _hasInvalidLink => _links.values.any((c) => !_isValidLink(c.text));

  static bool _isValidLink(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    final uri = Uri.tryParse(trimmed);
    return uri != null &&
        uri.isAbsolute &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty;
  }

  /// Explains the rule at the field rather than only refusing the save.
  String? _linkError(String key) {
    if (_isValidLink(_links[key]!.text)) {
      return _errorFor('links.$key', context.language);
    }
    return context.language == AppLanguage.ar
        ? 'يجب أن يبدأ الرابط بـ https://'
        : 'Links must start with https://';
  }

  String? _errorFor(String field, AppLanguage language) =>
      _fieldErrors[field]?.resolve(language);

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _fieldErrors = const {};
      _formError = null;
    });

    try {
      await ref
          .read(profileRepositoryProvider)
          .saveCard(
            slug: _slug.text.trim(),
            isPublic: _isPublic,
            title: LocalizedText(
              en: _titleEn.text.trim(),
              ar: _titleAr.text.trim(),
            ),
            clinic: LocalizedText(
              en: _clinicEn.text.trim(),
              ar: _clinicAr.text.trim(),
            ),
            bio: LocalizedText(en: _bioEn.text.trim(), ar: _bioAr.text.trim()),
            links: {
              for (final entry in _links.entries)
                if (entry.value.text.trim().isNotEmpty)
                  entry.key: entry.value.text.trim(),
            },
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ValidationFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _fieldErrors = failure.fields;
        _isSaving = false;
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
