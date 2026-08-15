import '../../config/config.dart';
import '../../observability/logger.dart';

/// What a checkout attempt produced.
enum PaymentOutcome {
  completed('completed'),
  cancelled('cancelled'),
  failed('failed'),
  refunded('refunded');

  const PaymentOutcome(this.wire);

  final String wire;

  static PaymentOutcome fromWire(String? value) =>
      PaymentOutcome.values.firstWhere(
        (outcome) => outcome.wire == value,
        orElse: () => PaymentOutcome.failed,
      );
}

/// A checkout the client should open.
class CheckoutSession {
  const CheckoutSession({
    required this.checkoutUrl,
    required this.externalRef,
  });

  /// Opened externally. The redirect sheet names the host it goes to, so the
  /// user is never surprised about where their card details are going.
  final String checkoutUrl;
  final String externalRef;
}

/// The payment abstraction.
///
/// Ejadah's commerce is deliberately split three ways and the split is **legal,
/// not architectural**:
///
/// * **Courses** are digital content and go through in-app purchase only
///   (Apple §3.1.1). They never reach this interface — the store is their
///   system of record.
/// * **Sessions** are human services and are paid on the website, 70/30.
/// * **The physical NFC card** is shipped goods and is also external.
///
/// These look inconsistent. They are law. Never harmonise them.
abstract interface class PaymentProvider {
  String get name;

  Future<CheckoutSession> createCheckout({
    required String bookingId,
    required int amountEgp,
    required String returnUrl,
  });

  Future<void> refund({required String bookingId, required int amountEgp});
}

/// The development payment simulator.
///
/// Lets the whole booking flow — hold, confirm, redirect, return, cancel,
/// refund — be exercised end to end without provider credentials. It can mark a
/// booking paid without money moving, which is precisely why
/// [AppConfig.fromEnvironment] refuses to boot with this selected in
/// production: the guard is in configuration, not in a code comment.
class DevPaymentProvider implements PaymentProvider {
  DevPaymentProvider({
    required AppConfig config,
    required AppLogger logger,
  }) : _config = config,
       _logger = logger {
    if (config.environment.isProduction) {
      throw StateError(
        'The development payment simulator cannot run in production.',
      );
    }
  }

  final AppConfig _config;
  final AppLogger _logger;

  /// Outcomes the caller has queued, so a test can drive failure and
  /// cancellation paths as easily as the happy one.
  final List<PaymentOutcome> _queuedOutcomes = [];

  @override
  String get name => 'dev';

  /// Queues the outcome the next checkout will report.
  void enqueueOutcome(PaymentOutcome outcome) => _queuedOutcomes.add(outcome);

  PaymentOutcome nextOutcome() => _queuedOutcomes.isEmpty
      ? PaymentOutcome.completed
      : _queuedOutcomes.removeAt(0);

  @override
  Future<CheckoutSession> createCheckout({
    required String bookingId,
    required int amountEgp,
    required String returnUrl,
  }) async {
    final reference = 'dev_${bookingId.replaceAll('-', '').substring(0, 12)}';
    _logger.info('simulated checkout created', {
      'booking': bookingId,
      'amount_egp': amountEgp,
    });

    return CheckoutSession(
      checkoutUrl:
          '${_config.checkoutBaseUrl}/simulate'
          '?booking=$bookingId&ref=$reference'
          '&return=${Uri.encodeComponent(returnUrl)}',
      externalRef: reference,
    );
  }

  @override
  Future<void> refund({
    required String bookingId,
    required int amountEgp,
  }) async {
    _logger.info('simulated refund', {
      'booking': bookingId,
      'amount_egp': amountEgp,
    });
  }
}
