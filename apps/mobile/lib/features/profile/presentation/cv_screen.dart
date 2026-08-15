import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../uploads/file_field.dart';
import '../../uploads/upload_repository.dart' as uploads;
import '../application/cv_controller.dart';
import '../data/cv_repository.dart';

/// PR-07 — the CV builder. Upload-first.
///
/// Most dentists already have a CV. Asking them to retype one into six boxes is
/// how a feature goes unused, so the upload is the first thing on the screen
/// and everything below it is explicitly optional.
///
/// The patient-data warning is always visible, never behind a tap, and its
/// wording comes from the server. A CV is a document clinicians paste case
/// notes into, and a patient's name arriving here is a data-protection incident
/// rather than an untidy field — so the reminder is part of the screen's
/// furniture, not a validation message that appears after the fact.
class CvScreen extends ConsumerWidget {
  const CvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final cv = ref.watch(cvControllerProvider);

    return GradientBudget(
      screenName: 'cv',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.cvTitle,
          backLabel: strings.back,
          onBack: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        body: SafeArea(
          top: false,
          child: switch (cv) {
            AsyncData(:final value) => _Builder(cv: value),
            AsyncError(:final error) => EjadahErrorState(
              title: FailureCopy.errorTitle(context),
              body: error is Failure
                  ? error.message(context)
                  : FailureCopy.generic(context),
              retryLabel: strings.retry,
              onRetry: () => ref.read(cvControllerProvider.notifier).refresh(),
            ),
            _ => const _CvSkeleton(),
          },
        ),
      ),
    );
  }
}

class _Builder extends ConsumerWidget {
  const _Builder({required this.cv});

  final Cv cv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final type = context.type;

    return ListView(
      key: const PageStorageKey('cv'),
      padding: const EdgeInsets.only(bottom: EjadahSpacing.xxl),
      children: [
        EjadahPageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: EjadahSpacing.md),
              PageHeader(title: strings.cvTitle, subtitle: strings.cvLead),
              const SizedBox(height: EjadahSpacing.md),

              // Always on screen, above everything that takes typing. The
              // wording is the server's, so it cannot be edited away here.
              InlineAlert(
                message: cv.patientDataWarning(context),
                tone: AlertTone.warning,
              ),
              const SizedBox(height: EjadahSpacing.lg),

              SectionHeader(title: strings.cvUploadTitle),
              const SizedBox(height: EjadahSpacing.xs),
              EjadahFileField(
                label: strings.cvTitle,
                purpose: uploads.UploadPurpose.cv,
                storedKey: cv.uploaded?.body,
                helperText: strings.cvUploadHint,
                onUploaded: (file) async {
                  final failure = await ref
                      .read(cvControllerProvider.notifier)
                      .setUploadedFile(file.key);
                  if (context.mounted && failure != null) {
                    showEjadahToast(context, message: failure.message(context));
                  }
                },
              ),
              if (cv.uploaded != null) ...[
                const SizedBox(height: EjadahSpacing.xs),
                EjadahGhostButton(
                  label: strings.cvRemoveFile,
                  onPressed: () => _removeFile(context, ref),
                ),
              ],

              const SizedBox(height: EjadahSpacing.lg),
              SectionHeader(title: strings.cvSectionsTitle),
              const SizedBox(height: EjadahSpacing.xs),
              if (cv.typed.isEmpty && cv.uploaded == null)
                Text(
                  strings.cvEmpty,
                  style: type.bodyText(color: EjadahColors.textSecondary),
                )
              else
                for (final section in cv.typed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: EjadahSpacing.sm),
                    child: _SectionCard(
                      section: section,
                      onDelete: () => _deleteSection(context, ref, section),
                    ),
                  ),
              const SizedBox(height: EjadahSpacing.md),
              EjadahSecondaryButton(
                label: strings.cvAddSection,
                expand: false,
                onPressed: () => _addSection(context, ref, cv),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _removeFile(BuildContext context, WidgetRef ref) async {
    final failure = await ref
        .read(cvControllerProvider.notifier)
        .removeUploadedFile();
    if (!context.mounted) return;
    showEjadahToast(
      context,
      message: failure?.message(context) ?? context.strings.cvFileRemoved,
    );
  }

  Future<void> _deleteSection(
    BuildContext context,
    WidgetRef ref,
    CvSection section,
  ) async {
    final failure = await ref
        .read(cvControllerProvider.notifier)
        .deleteSection(section.id);
    if (!context.mounted) return;
    showEjadahToast(
      context,
      message: failure?.message(context) ?? context.strings.cvSectionRemoved,
    );
  }

  Future<void> _addSection(
    BuildContext context,
    WidgetRef ref,
    Cv cv,
  ) async {
    // A screen, not a sheet. The design system's own rule: sheets carry
    // options and confirmations, never forms — a form in a sheet fights the
    // keyboard and loses its place in the back stack.
    final draft = await Navigator.of(context).push<_SectionDraft>(
      MaterialPageRoute(
        builder: (_) => _SectionEditor(
          kinds: cv.kinds,
          warning: cv.patientDataWarning,
        ),
      ),
    );
    if (draft == null || !context.mounted) return;

    final failure = await ref
        .read(cvControllerProvider.notifier)
        .saveSection(
          kind: draft.kind,
          heading: draft.heading,
          body: draft.body,
        );
    if (context.mounted && failure != null) {
      showEjadahToast(context, message: failure.message(context));
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.onDelete});

  final CvSection section;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final type = context.type;

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  section.heading.isEmpty
                      ? _kindLabel(context.strings, section.kind)
                      : section.heading,
                  style: type.h5(),
                ),
              ),
              EjadahIconButton(
                icon: EjadahIcons.close,
                semanticLabel: context.strings.removeWindow,
                onPressed: onDelete,
              ),
            ],
          ),
          if (section.body.isNotEmpty) ...[
            const SizedBox(height: EjadahSpacing.xxs),
            Text(
              section.body,
              style: type.bodyText(color: EjadahColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionDraft {
  const _SectionDraft({
    required this.kind,
    required this.heading,
    required this.body,
  });

  final String kind;
  final String heading;
  final String body;
}

/// The add-a-section screen.
///
/// Its own route rather than a sheet: this is a form, and the design system
/// reserves sheets for options and confirmations. On a screen the keyboard, the
/// back gesture and scroll restoration all behave the way the rest of the app
/// does.
class _SectionEditor extends StatefulWidget {
  const _SectionEditor({required this.kinds, required this.warning});

  final List<String> kinds;
  final LocalizedText warning;

  @override
  State<_SectionEditor> createState() => _SectionEditorState();
}

class _SectionEditorState extends State<_SectionEditor> {
  final _heading = TextEditingController();
  final _body = TextEditingController();
  late String _kind = widget.kinds.first;

  @override
  void dispose() {
    _heading.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    return GradientBudget(
      screenName: 'cv-section',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.cvAddSection,
          backLabel: strings.back,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: SafeArea(
          top: false,
          child: EjadahPageBody(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: EjadahSpacing.md),

                // The same warning, here too: this is where the typing actually
                // happens, and a reminder on the screen behind it is a reminder
                // nobody is reading at the moment it matters.
                InlineAlert(
                  message: widget.warning(context),
                  tone: AlertTone.warning,
                ),
                const SizedBox(height: EjadahSpacing.md),

                Text(
                  type.eyebrowText(strings.cvSectionKind),
                  style: type.eyebrow(color: EjadahColors.labelMuted),
                ),
                const SizedBox(height: EjadahSpacing.xxs),
                Wrap(
                  spacing: EjadahSpacing.xxs,
                  runSpacing: EjadahSpacing.xxs,
                  children: [
                    // Only the kinds the server said it accepts — a chip that
                    // produces a 404 is a chip that should not be offered.
                    for (final kind in widget.kinds)
                      EjadahFilterChip(
                        label: _kindLabel(strings, kind),
                        isSelected: _kind == kind,
                        onTap: () => setState(() => _kind = kind),
                      ),
                  ],
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahInput(
                  label: strings.cvHeading,
                  controller: _heading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahInput(
                  label: strings.cvBody,
                  controller: _body,
                  maxLines: 6,
                ),
                const SizedBox(height: EjadahSpacing.lg),
                EjadahPrimaryButton(
                  label: strings.save,
                  onPressed: () => Navigator.of(context).pop(
                    _SectionDraft(
                      kind: _kind,
                      heading: _heading.text.trim(),
                      body: _body.text.trim(),
                    ),
                  ),
                ),
                const SizedBox(height: EjadahSpacing.md),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

String _kindLabel(EjadahStrings strings, String kind) => switch (kind) {
  'summary' => strings.cvKindSummary,
  'education' => strings.cvKindEducation,
  'experience' => strings.cvKindExperience,
  'skills' => strings.cvKindSkills,
  'publications' => strings.cvKindPublications,
  _ => strings.cvKindOther,
};

class _CvSkeleton extends StatelessWidget {
  const _CvSkeleton();

  @override
  Widget build(BuildContext context) => const EjadahPageBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: EjadahSpacing.md),
        Skeleton(width: 160, height: 28),
        SizedBox(height: EjadahSpacing.md),
        Skeleton(width: double.infinity, height: 64),
        SizedBox(height: EjadahSpacing.lg),
        Skeleton(width: double.infinity, height: 88),
        SizedBox(height: EjadahSpacing.sm),
        Skeleton(width: double.infinity, height: 88),
      ],
    ),
  );
}
