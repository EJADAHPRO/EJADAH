import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';

/// PE-07 — coming back from the external checkout.
///
/// Two honest outcomes and no third. A payment that did not complete says so
/// plainly, confirms nothing was charged, and offers the way forward — never a
/// blank screen, a spinner, or a cheerful "processing" that means nothing.
///
/// The user tells us which happened, because the app cannot observe a browser
/// it handed off to. That is why the failure copy is careful to state what is
/// and is not true rather than asserting an outcome it did not witness.
class PaymentReturnedScreen extends StatelessWidget {
  const PaymentReturnedScreen({required this.booking, super.key});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return GradientBudget(
      screenName: 'payment-returned',
      child: Scaffold(
        appBar: EjadahAppBar(
          title: strings.bookingConfirmed,
          backLabel: strings.back,
          onBack: () => Navigator.of(context).pop(false),
        ),
        body: SafeArea(
          child: EjadahPageBody(
            child: ListView(
              children: [
                const SizedBox(height: EjadahSpacing.section),
                Text(strings.bookedTitle, style: context.type.h4()),
                const SizedBox(height: EjadahSpacing.xs),
                Text(
                  strings.payNoteExternal,
                  style: context.type.bodyText(
                    color: EjadahColors.textSecondary,
                  ),
                ),
                const SizedBox(height: EjadahSpacing.md),
                EjadahCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          strings.sessionFee,
                          style: context.type.small(
                            color: EjadahColors.textSecondary,
                          ),
                        ),
                      ),
                      CurrencyText(
                        amount: booking.totalEgp,
                        currency: 'EGP',
                        style: context.type.bodyStrong(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: EjadahSpacing.section),
                EjadahPrimaryButton(
                  label: strings.bookingConfirmed,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: EjadahSpacing.sm),
                // The "not completed" path. Nothing was charged, the place is
                // not held, and the copy says both.
                EjadahSecondaryButton(
                  label: strings.cancelTitle,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(height: EjadahSpacing.sm),
                Text(
                  strings.cancelBody,
                  style: context.type.small(color: EjadahColors.labelMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
