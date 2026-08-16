import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The avatar, always initials.
///
/// Phase 1 ships no licensed portraits, so there is no image path here at all:
/// a widget that cannot load a photo cannot show a broken one.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({required this.name, this.size = 56, super.key});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: EjadahColors.inset,
      borderRadius: EjadahRadius.all(EjadahRadius.pill),
    ),
    child: Center(
      child: Text(
        _initials(name),
        style: size >= 56 ? context.type.h5() : context.type.bodyStrong(),
      ),
    ),
  );

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first.toUpperCase()}'
        '${parts.last.characters.first.toUpperCase()}';
  }
}

/// One certificate row.
///
/// Verified and stated differ in three ways at once — icon, colour and words —
/// because the whole product rests on a stranger being able to tell them apart
/// at a glance. The stated variant additionally spells out that Ejadah has not
/// checked it, and carries no verification code, because only a verified
/// certificate has one to show.
class CertificateTile extends StatelessWidget {
  const CertificateTile({
    required this.certificate,
    this.onOpenVerification,
    this.onRemove,
    super.key,
  });

  final Certificate certificate;

  /// Opens `/verify/{code}`. Null for a stated certificate, which has no code.
  final VoidCallback? onOpenVerification;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final language = context.language;
    final isVerified =
        certificate.evidence == CredentialEvidence.verifiedByEjadah;

    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isVerified ? EjadahIcons.verified : EjadahIcons.certificate,
                size: EjadahIconSize.inline,
                color: isVerified
                    ? EjadahColors.successText
                    : EjadahColors.labelMuted,
              ),
              const SizedBox(width: EjadahSpacing.xs),
              Expanded(
                child: Text(
                  certificate.title.resolve(language),
                  style: context.type.h6(),
                ),
              ),
              if (onRemove != null)
                EjadahIconButton(
                  icon: EjadahIcons.close,
                  semanticLabel: strings.cancel,
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
          VerificationBadge(
            evidence: certificate.evidence,
            verifiedLabel: strings.verifiedByEjadah,
            statedLabel: strings.statedByTutor,
          ),
          if (!isVerified) ...[
            const SizedBox(height: EjadahSpacing.xxs),
            // Words, not just a colour: the stated state says in plain
            // language that no check has happened.
            Text(
              strings.notVerified,
              style: context.type.caption(color: EjadahColors.textSecondary),
            ),
          ],
          const SizedBox(height: EjadahSpacing.xs),
          _LabelledValue(
            label: strings.issuedBy,
            value: certificate.issuer.resolve(language),
          ),
          _LabelledValue(
            label: strings.issuedOn,
            value: formatCertificateDate(certificate.issuedOn, language),
            isLatinIsland: true,
          ),
          if (certificate.cpdPoints > 0)
            _LabelledValue(
              label: strings.incCpd,
              value: '${certificate.cpdPoints}',
              isLatinIsland: true,
            ),
          if (certificate.verificationCode != null) ...[
            const SizedBox(height: EjadahSpacing.xs),
            _LabelledValue(
              label: strings.certCode,
              value: certificate.verificationCode!,
              isLatinIsland: true,
            ),
            const SizedBox(height: EjadahSpacing.xs),
            EjadahSecondaryButton(
              label: strings.shareVerify,
              onPressed: onOpenVerification,
            ),
          ],
        ],
      ),
    );
  }
}

class _LabelledValue extends StatelessWidget {
  const _LabelledValue({
    required this.label,
    required this.value,
    this.isLatinIsland = false,
  });

  final String label;
  final String value;

  /// Codes, dates and counts stay left-to-right inside Arabic copy.
  final bool isLatinIsland;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: EjadahSpacing.xxs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.type.eyebrowText(label),
          style: context.type.micro(color: EjadahColors.labelMuted),
        ),
        const SizedBox(width: EjadahSpacing.xs),
        Expanded(
          child: isLatinIsland
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CodeText(value, style: context.type.caption()),
                )
              : Text(value, style: context.type.caption()),
        ),
      ],
    ),
  );
}

/// The date on a certificate: Arabic month names, Western digits.
///
/// `intl` renders Arabic dates with Arabic-Indic numerals by default. The
/// product uses Western digits in both languages — a certificate date is read
/// alongside codes and points, and mixing numeral systems down one column is
/// what makes a credential look improvised.
String formatCertificateDate(DateTime date, AppLanguage language) =>
    toWesternDigits(DateFormat('d MMM yyyy', language.code).format(date.toLocal()));

/// Replaces Arabic-Indic digits with Western ones, leaving all other
/// characters untouched.
String toWesternDigits(String value) {
  const arabicZero = 0x0660;
  return String.fromCharCodes([
    for (final unit in value.runes)
      if (unit >= arabicZero && unit <= arabicZero + 9)
        unit - arabicZero + 0x30
      else
        unit,
  ]);
}

/// The card preview shown on the NFC screen and, live, in the editor.
///
/// One widget for both so the editor's preview cannot drift from the real
/// card — a preview that lies is worse than no preview.
class NfcCardPreview extends StatelessWidget {
  const NfcCardPreview({
    required this.name,
    required this.title,
    required this.clinic,
    this.url,
    super.key,
  });

  final String name;
  final String title;
  final String clinic;

  /// The public URL. Null before a handle is claimed.
  final String? url;

  @override
  Widget build(BuildContext context) => DarkCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            InitialsAvatar(name: name, size: 48),
            const SizedBox(width: EjadahSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: context.type.h5(color: EjadahColors.onDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: context.type.small(
                        color: EjadahColors.onDarkMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        if (clinic.isNotEmpty) ...[
          const SizedBox(height: EjadahSpacing.sm),
          Text(
            clinic,
            style: context.type.caption(color: EjadahColors.onDarkFaint),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (url != null && url!.isNotEmpty) ...[
          const SizedBox(height: EjadahSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: CodeText(
              url!,
              style: context.type.micro(color: EjadahColors.onDarkMuted),
            ),
          ),
        ],
      ],
    ),
  );
}

/// The install call to action carried by every public page.
///
/// A public card or a verification result is often a stranger's first contact
/// with Ejadah, so both offer a way in — without gating what they came for.
class InstallEjadahCta extends StatelessWidget {
  const InstallEjadahCta({required this.onInstall, super.key});

  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return EjadahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.installEjadah, style: context.type.h6()),
          const SizedBox(height: EjadahSpacing.xxs),
          Text(
            strings.registerSub,
            style: context.type.small(color: EjadahColors.textSecondary),
          ),
          const SizedBox(height: EjadahSpacing.sm),
          EjadahPrimaryButton(
            label: strings.installEjadah,
            onPressed: onInstall,
          ),
        ],
      ),
    );
  }
}

/// A settings row carrying a switch.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => EjadahListRow(
    title: title,
    subtitle: subtitle,
    onTap: () => onChanged(!value),
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: EjadahColors.orange,
    ),
  );
}

/// The career stage, in the reader's language.
///
/// Shared rather than per-screen: it appears on the profile header and in the
/// exported CV, and those two disagreeing about what someone is would be worse
/// than either being wrong alone.
String careerStageLabel(EjadahStrings strings, CareerStage stage) =>
    switch (stage) {
      CareerStage.student => strings.stageStudent,
      CareerStage.freshGraduate => strings.stageFreshGraduate,
      CareerStage.generalDentist => strings.stageGeneralDentist,
      CareerStage.specialist => strings.stageSpecialist,
      CareerStage.consultantOwner => strings.stageConsultantOwner,
    };
