import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/profile_controllers.dart';
import 'certificates_screen.dart';
import 'widgets/profile_widgets.dart';

/// PR-08 · The CPD ledger.
///
/// A running total and the entries behind it. Each row carries its evidence
/// level, because a total that mixes verified and stated points without saying
/// so is exactly the kind of number a regulator should not be handed.
class CpdScreen extends ConsumerWidget {
  const CpdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final ledger = ref.watch(cpdLedgerProvider);

    return Scaffold(
      appBar: EjadahAppBar(
        title: strings.incCpd,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: strings.back,
      ),
      body: SafeArea(
        top: false,
        child: EjadahPageBody(
          child: ledger.when(
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
              onRetry: () => ref.invalidate(cpdLedgerProvider),
            ),
            data: (data) => data.entries.isEmpty
                ? EjadahEmptyState(
                    title: strings.incCpd,
                    body: strings.verifyNote,
                    actionLabel: strings.addCertificate,
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const GradientBudget(
                          screenName: 'add-certificate',
                          child: AddCertificateScreen(),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    key: const PageStorageKey('cpd'),
                    children: [
                      const SizedBox(height: EjadahSpacing.md),
                      StatCard(
                        value: CodeText(
                          '${data.totalPoints}',
                          style: context.type.h4(),
                        ),
                        label: strings.incCpd,
                        emphasis: EjadahColors.orangeText,
                      ),
                      const SizedBox(height: EjadahSpacing.md),
                      SectionHeader(title: strings.certificatesTitle),
                      const SizedBox(height: EjadahSpacing.xs),
                      for (final entry in data.entries)
                        EjadahListRow(
                          title: entry.title.resolve(context.language),
                          subtitle: formatCertificateDate(
                            entry.earnedOn,
                            context.language,
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CodeText(
                                '${entry.points}',
                                style: context.type.bodyStrong(),
                              ),
                              const SizedBox(height: EjadahSpacing.xxs),
                              VerificationBadge(
                                evidence: entry.evidence,
                                verifiedLabel: strings.verifiedByEjadah,
                                statedLabel: strings.statedByTutor,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: EjadahSpacing.section),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
