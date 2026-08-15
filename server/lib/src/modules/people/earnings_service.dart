import 'package:ejadah_models/ejadah_models.dart';
import 'package:postgres/postgres.dart';

import '../../config/config.dart';
import '../../db/database.dart';
import '../../http/api_error.dart';

/// The totals above the rows.
class EarningsSummary {
  const EarningsSummary({
    required this.availableEgp,
    required this.pendingEgp,
    required this.requestedEgp,
    required this.paidEgp,
    required this.lifetimeGrossEgp,
    required this.lifetimeFeeEgp,
  });

  final int availableEgp;
  final int pendingEgp;

  /// Asked for and on its way. Shown separately from [paidEgp] because they
  /// are different promises.
  final int requestedEgp;
  final int paidEgp;
  final int lifetimeGrossEgp;
  final int lifetimeFeeEgp;

  Map<String, dynamic> toJson() => {
    'available_egp': availableEgp,
    'pending_egp': pendingEgp,
    'requested_egp': requestedEgp,
    'paid_egp': paidEgp,
    'lifetime_gross_egp': lifetimeGrossEgp,
    'lifetime_fee_egp': lifetimeFeeEgp,
    'lifetime_net_egp': lifetimeGrossEgp - lifetimeFeeEgp,
  };
}

/// A request to be paid.
class PayoutRequest {
  const PayoutRequest({
    required this.id,
    required this.amountEgp,
    required this.status,
    required this.requestedAt,
    this.resolvedAt,
  });

  final String id;
  final int amountEgp;
  final String status;
  final DateTime requestedAt;
  final DateTime? resolvedAt;

  bool get isOpen => status == 'requested' || status == 'approved';

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount_egp': amountEgp,
    'status': status,
    'requested_at': requestedAt.toIso8601String(),
    'resolved_at': resolvedAt?.toIso8601String(),
  };
}

/// The tutor's ledger, and asking to be paid from it.
///
/// The number that matters to a tutor is what actually reaches them, and the
/// only way that number is trusted is if the subtraction is shown: gross, minus
/// Ejadah's fee, equals net, on every row. Nothing here shows a share without
/// showing what was taken to arrive at it.
class EarningsService {
  const EarningsService(this._database, this._config);

  final Database _database;
  final AppConfig _config;

  /// The least a payout may be.
  ///
  /// A floor exists because each transfer costs a fixed fee to send; paying out
  /// 40 EGP would cost more to move than it is worth. When the balance is under
  /// it, the screen states the shortfall rather than greying a button.
  static const int minimumPayoutEgp = 500;

  int get platformFeePercent => _config.platformFeePercent;

  /// The professional this user is, or null if they are not one.
  Future<int?> professionalIdFor(String userId) async {
    final rows = await _query(
      'SELECT id FROM professionals WHERE user_id = @user_id',
      {'user_id': userId},
    );
    return rows.isEmpty ? null : rows.first.intAt('id');
  }

  /// Every line, newest first.
  Future<List<EarningRow>> rows(int professionalId) async {
    final rows = await _query(
      '''
      SELECT e.id, e.booking_id, e.gross_egp, e.platform_fee_egp, e.status,
             e.occurred_at, b.subject,
             u.full_name_en, u.full_name_ar
      FROM earnings e
      JOIN bookings b ON b.id = e.booking_id
      JOIN users u ON u.id = b.user_id
      WHERE e.professional_id = @professional_id
      ORDER BY e.occurred_at DESC
      ''',
      {'professional_id': professionalId},
    );

    return rows
        .map(
          (row) => EarningRow(
            id: row.str('id'),
            bookingId: row.str('booking_id'),
            grossEgp: row.intAt('gross_egp'),
            platformFeeEgp: row.intAt('platform_fee_egp'),
            status: EarningStatus.fromWire(row.str('status')),
            occurredAt: row.dateAt('occurred_at'),
            // Who the session was with. Never their goal: that is clinical
            // free text the student wrote in confidence and it stays on the
            // booking.
            description: LocalizedText(
              en: row.str('full_name_en'),
              ar: row.str('full_name_ar'),
            ),
            subject: row.strOrNull('subject') ?? '',
          ),
        )
        .toList();
  }

  /// The totals.
  ///
  /// Computed in SQL rather than by summing the page of rows the client was
  /// sent: a balance that only counts the rows that happened to be loaded is a
  /// balance that is wrong the moment the ledger outgrows one page.
  Future<EarningsSummary> summary(int professionalId, {Session? session}) async {
    final rows = await _query(
      '''
      SELECT
        COALESCE(SUM(gross_egp - platform_fee_egp)
                 FILTER (WHERE status = 'available'), 0) AS available,
        COALESCE(SUM(gross_egp - platform_fee_egp)
                 FILTER (WHERE status = 'pending'), 0)   AS pending,
        COALESCE(SUM(gross_egp - platform_fee_egp)
                 FILTER (WHERE status = 'requested'), 0) AS requested,
        COALESCE(SUM(gross_egp - platform_fee_egp)
                 FILTER (WHERE status = 'paid'), 0)      AS paid,
        COALESCE(SUM(gross_egp)
                 FILTER (WHERE status <> 'reversed'), 0) AS gross,
        COALESCE(SUM(platform_fee_egp)
                 FILTER (WHERE status <> 'reversed'), 0) AS fee
      FROM earnings
      WHERE professional_id = @professional_id
      ''',
      {'professional_id': professionalId},
      session,
    );

    final row = rows.first;
    return EarningsSummary(
      availableEgp: row.intAt('available'),
      pendingEgp: row.intAt('pending'),
      requestedEgp: row.intAt('requested'),
      paidEgp: row.intAt('paid'),
      lifetimeGrossEgp: row.intAt('gross'),
      lifetimeFeeEgp: row.intAt('fee'),
    );
  }

  Future<List<PayoutRequest>> payouts(
    int professionalId, {
    Session? session,
  }) async {
    final rows = await _query(
      'SELECT * FROM payout_requests WHERE professional_id = @professional_id '
      'ORDER BY requested_at DESC',
      {'professional_id': professionalId},
      session,
    );
    return rows.map(_toPayout).toList();
  }

  /// Why a payout cannot be requested right now, or null when it can.
  ///
  /// Returned as a reason rather than a boolean because every disabled control
  /// in this product owes an explanation. "Request payout" greyed out with no
  /// number beside it is the exact dead end the state matrix forbids.
  LocalizedText? blockedReason({
    required EarningsSummary summary,
    required List<PayoutRequest> payouts,
  }) {
    if (payouts.any((payout) => payout.isOpen)) return _alreadyRequested;
    if (summary.availableEgp <= 0) return _nothingAvailable;
    if (summary.availableEgp < minimumPayoutEgp) {
      final short = minimumPayoutEgp - summary.availableEgp;
      // The shortfall, in figures, so the answer to "how much more?" is on the
      // screen instead of being arithmetic the tutor has to do.
      return LocalizedText(
        en:
            'Payouts start at EGP $minimumPayoutEgp. '
            'You need EGP $short more.',
        ar:
            'يبدأ الصرف من $minimumPayoutEgp جنيهًا. '
            'تحتاج إلى $short جنيهًا إضافيًا.',
      );
    }
    return null;
  }

  /// Requests a payout of the whole available balance.
  ///
  /// The amount is the balance, not a figure from the request: a client-chosen
  /// amount is a client-chosen amount of someone else's money.
  Future<PayoutRequest> requestPayout(int professionalId) =>
      _database.runTx((tx) async {
        // Locks this professional's available rows for the transaction, so two
        // taps a moment apart cannot each see the same balance and each open a
        // request against it.
        final locked = await tx.execute(
          Sql.named(
            'SELECT id FROM earnings '
            "WHERE professional_id = @professional_id AND status = 'available' "
            'FOR UPDATE',
          ),
          parameters: {'professional_id': professionalId},
        );

        // Read through the transaction, so these see the rows the lock holds.
        final current = await summary(professionalId, session: tx);
        final open = await payouts(professionalId, session: tx);
        final reason = blockedReason(summary: current, payouts: open);
        if (reason != null) {
          throw ApiException.validation({'amount': reason});
        }

        final inserted = await tx.execute(
          Sql.named(
            'INSERT INTO payout_requests (professional_id, amount_egp) '
            'VALUES (@professional_id, @amount) RETURNING *',
          ),
          parameters: {
            'professional_id': professionalId,
            'amount': current.availableEgp,
          },
        );
        final payout = _toPayout(inserted.first.toColumnMap());

        // The rows move to `requested` — not `paid`. Nothing has been
        // transferred yet, and telling a tutor otherwise on the day they asked
        // is the kind of lie a ledger never recovers from. They also leave
        // `available` in the same transaction, so a second request cannot be
        // opened against money already claimed.
        await tx.execute(
          Sql.named(
            "UPDATE earnings SET status = 'requested', "
            'payout_request_id = @payout_id '
            'WHERE id = ANY(@ids::uuid[])',
          ),
          parameters: {
            'payout_id': payout.id,
            'ids': locked.map((row) => row.toColumnMap()['id']).toList(),
          },
        );

        return payout;
      });

  PayoutRequest _toPayout(Map<String, dynamic> row) => PayoutRequest(
    id: row.str('id'),
    amountEgp: row.intAt('amount_egp'),
    status: row.str('status'),
    requestedAt: row.dateAt('requested_at'),
    resolvedAt: row.dateOrNull('resolved_at'),
  );

  /// Runs inside [session] when given one.
  ///
  /// Not optional bookkeeping: [requestPayout] locks rows in a transaction, and
  /// a read that quietly took a second connection would see the pre-lock state
  /// and make the lock decorative.
  Future<List<Map<String, dynamic>>> _query(
    String sql,
    Map<String, Object?> parameters, [
    Session? session,
  ]) async {
    final result = session != null
        ? await session.execute(Sql.named(sql), parameters: parameters)
        : await _database.run(
            (owned) => owned.execute(Sql.named(sql), parameters: parameters),
          );
    return result.map((row) => row.toColumnMap()).toList();
  }

  static const LocalizedText _alreadyRequested = LocalizedText(
    en: "You have a payout on the way. We'll email you when it lands.",
    ar: 'لديك طلب صرف قيد التنفيذ. سنراسلك عند وصوله.',
  );

  static const LocalizedText _nothingAvailable = LocalizedText(
    en: 'Nothing is available yet. Sessions become payable once they are over.',
    ar: 'لا يوجد رصيد متاح بعد. تصبح الجلسات قابلة للصرف بعد انتهائها.',
  );
}
