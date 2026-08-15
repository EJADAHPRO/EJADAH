import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/profile_controllers.dart';
import 'widgets/profile_widgets.dart';

/// Public certificate verification at `/verify/{code}`.
///
/// No account, never charged for: someone checking a credential is a clinic or
/// a registrar, and making them sign up to answer "is this real?" would break
/// the trust loop the whole product rests on.
///
/// Three outcomes, each unambiguous. A revoked certificate shows the revocation
/// and **not** the certificate — printing the details beside the word "revoked"
/// is exactly the confusion a checker must not be left with.
class VerifyCertificateScreen extends ConsumerWidget {
  const VerifyCertificateScreen({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final verification = ref.watch(certificateVerificationProvider(code));

    return Scaffold(
      body: SafeArea(
        child: EjadahPageBody(
          child: ListView(
            children: [
              const SizedBox(height: EjadahSpacing.md),
              PageHeader(eyebrow: strings.certCode, title: strings.verifyTitle),
              const SizedBox(height: EjadahSpacing.xs),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CodeText(code),
              ),
              const SizedBox(height: EjadahSpacing.md),
              verification.when(
                loading: () => const Column(
                  children: [
                    Skeleton(width: double.infinity, height: 96),
                    SizedBox(height: EjadahSpacing.cardGap),
                    CardSkeleton(),
                  ],
                ),
                error: (error, _) => EjadahErrorState(
                  title: FailureCopy.errorTitle(context),
                  body: error is Failure
                      ? error.message(context)
                      : FailureCopy.server(context),
                  retryLabel: strings.retry,
                  onRetry: () =>
                      ref.invalidate(certificateVerificationProvider(code)),
                ),
                data: (result) => _Outcome(result: result),
              ),
              const SizedBox(height: EjadahSpacing.md),
              InlineAlert(message: strings.verifyNote, tone: AlertTone.info),
              const SizedBox(height: EjadahSpacing.md),
              InstallEjadahCta(onInstall: _openEjadah),
              const SizedBox(height: EjadahSpacing.section),
            ],
          ),
        ),
      ),
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({required this.result});

  final CertificateVerification result;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final language = context.language;

    return switch (result.outcome) {
      VerificationOutcome.verified => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InlineAlert(message: strings.verifyValid, tone: AlertTone.success),
          const SizedBox(height: EjadahSpacing.cardGap),
          EjadahCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                VerificationBadge(
                  evidence: CredentialEvidence.verifiedByEjadah,
                  verifiedLabel: strings.verifiedByEjadah,
                  statedLabel: strings.statedByTutor,
                ),
                const SizedBox(height: EjadahSpacing.xs),
                if (result.holderName != null)
                  Text(
                    result.holderName!.resolve(language),
                    style: context.type.h5(),
                  ),
                if (result.title != null) ...[
                  const SizedBox(height: EjadahSpacing.xxs),
                  Text(
                    result.title!.resolve(language),
                    style: context.type.bodyText(
                      color: EjadahColors.textSecondary,
                    ),
                  ),
                ],
                if (result.issuedOn != null) ...[
                  const SizedBox(height: EjadahSpacing.xs),
                  Row(
                    children: [
                      Text(
                        context.type.eyebrowText(strings.issuedOn),
                        style: context.type.micro(
                          color: EjadahColors.labelMuted,
                        ),
                      ),
                      const SizedBox(width: EjadahSpacing.xs),
                      CodeText(
                        formatCertificateDate(result.issuedOn!, language),
                        style: context.type.caption(),
                      ),
                    ],
                  ),
                ],
                if (result.cpdPoints != null) ...[
                  const SizedBox(height: EjadahSpacing.xxs),
                  Row(
                    children: [
                      Text(
                        context.type.eyebrowText(strings.incCpd),
                        style: context.type.micro(
                          color: EjadahColors.labelMuted,
                        ),
                      ),
                      const SizedBox(width: EjadahSpacing.xs),
                      CodeText(
                        '${result.cpdPoints}',
                        style: context.type.caption(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      // Deliberately no certificate body: the checker is told the state and
      // nothing that could be mistaken for a valid credential.
      VerificationOutcome.revoked => InlineAlert(
        message: strings.verifyRevoked,
        tone: AlertTone.danger,
      ),
      VerificationOutcome.notFound => InlineAlert(
        message: strings.verifyNotFound,
        tone: AlertTone.warning,
      ),
    };
  }
}

Future<void> _openEjadah() async {
  final uri = Uri.parse('https://ejadah.international');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
