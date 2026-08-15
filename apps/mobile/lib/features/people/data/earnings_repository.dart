import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class EarningsSummary {
  const EarningsSummary({
    required this.availableEgp,
    required this.pendingEgp,
    required this.requestedEgp,
    required this.paidEgp,
    required this.lifetimeGrossEgp,
    required this.lifetimeFeeEgp,
    required this.lifetimeNetEgp,
  });

  final int availableEgp;
  final int pendingEgp;
  final int requestedEgp;
  final int paidEgp;
  final int lifetimeGrossEgp;
  final int lifetimeFeeEgp;
  final int lifetimeNetEgp;

  static EarningsSummary fromJson(Map<String, dynamic> json) => EarningsSummary(
    availableEgp: (json['available_egp'] as num).toInt(),
    pendingEgp: (json['pending_egp'] as num).toInt(),
    requestedEgp: (json['requested_egp'] as num).toInt(),
    paidEgp: (json['paid_egp'] as num).toInt(),
    lifetimeGrossEgp: (json['lifetime_gross_egp'] as num).toInt(),
    lifetimeFeeEgp: (json['lifetime_fee_egp'] as num).toInt(),
    lifetimeNetEgp: (json['lifetime_net_egp'] as num).toInt(),
  );
}

class PayoutRequest {
  const PayoutRequest({
    required this.id,
    required this.amountEgp,
    required this.status,
    required this.requestedAt,
  });

  final String id;
  final int amountEgp;
  final String status;
  final DateTime requestedAt;

  static PayoutRequest fromJson(Map<String, dynamic> json) => PayoutRequest(
    id: json['id'] as String,
    amountEgp: (json['amount_egp'] as num).toInt(),
    status: json['status'] as String,
    requestedAt: DateTime.parse(json['requested_at'] as String),
  );
}

/// Everything the earnings screen shows.
class Earnings {
  const Earnings({
    required this.summary,
    required this.rows,
    required this.payouts,
    required this.minimumPayoutEgp,
    required this.platformFeePercent,
    this.payoutBlockedReason,
  });

  final EarningsSummary summary;
  final List<EarningRow> rows;
  final List<PayoutRequest> payouts;
  final int minimumPayoutEgp;
  final int platformFeePercent;

  /// Why the payout button is disabled, computed server-side.
  ///
  /// Arrives whether or not it is disabled, so the screen never invents a
  /// reason and never shows a dead control with nothing beside it.
  final LocalizedText? payoutBlockedReason;

  bool get canRequestPayout => payoutBlockedReason == null;

  static Earnings fromJson(Map<String, dynamic> json) => Earnings(
    summary: EarningsSummary.fromJson(
      Map<String, dynamic>.from(json['summary'] as Map),
    ),
    rows: (json['items'] as List<dynamic>)
        .map((item) => EarningRow.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
    payouts: (json['payouts'] as List<dynamic>)
        .map(
          (item) =>
              PayoutRequest.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    minimumPayoutEgp: (json['minimum_payout_egp'] as num).toInt(),
    platformFeePercent: (json['platform_fee_percent'] as num).toInt(),
    payoutBlockedReason: LocalizedText.fromJson(json['payout_blocked_reason']),
  );
}

class EarningsRepository {
  const EarningsRepository(this._client);

  final ApiClient _client;

  /// Throws [NotFoundFailure] for a user who is not a professional — there is
  /// no ledger, rather than an empty one they are forbidden from seeing.
  Future<Earnings> load() =>
      _client.get('/earnings/', parse: Earnings.fromJson);

  /// Requests the whole available balance. No amount is sent: a client-chosen
  /// amount is a client-chosen amount of someone else's money.
  Future<PayoutRequest> requestPayout() =>
      _client.post('/earnings/payouts', parse: PayoutRequest.fromJson);
}

final earningsRepositoryProvider = Provider<EarningsRepository>(
  (ref) => EarningsRepository(ref.watch(apiClientProvider)),
);
