import 'value.dart';

/// How much Ejadah can vouch for a fact.
///
/// This is a data state, never a judgement (`FLOWS_STORIES_CRITERIA.md` §5).
enum SourceStatus {
  /// Ejadah holds a named source and a verification date.
  verified('verified'),

  /// No source yet. Renders the exact words "Pending source" /
  /// "بانتظار المصدر" — never an estimate, never "approximately", never blank.
  pending('pending'),

  /// The concept exists but Ejadah has not verified this instance.
  notVerified('not_verified');

  const SourceStatus(this.wire);

  final String wire;

  static SourceStatus fromWire(String? value) => switch (value) {
    'verified' => SourceStatus.verified,
    'not_verified' => SourceStatus.notVerified,
    _ => SourceStatus.pending,
  };
}

/// A fact plus its provenance.
///
/// The product's whole premise is that every number is real, so a value and
/// its source travel together and cannot be separated by accident. A [value]
/// of `null` with [SourceStatus.pending] is a legitimate, expected state — the
/// 11 unverified regulator fees are shipped this way deliberately.
///
/// Callers must go through [isPrintable] before rendering: printing a
/// `pending` fact as a number is the single defect this type exists to prevent.
class Sourced<T extends Object> extends ValueObject {
  const Sourced({
    required this.value,
    required this.status,
    this.sourceName,
    this.sourceUrl,
    this.verifiedOn,
  });

  /// A fact Ejadah has verified against a named source.
  const Sourced.verified(
    T this.value, {
    required this.sourceName,
    this.sourceUrl,
    required this.verifiedOn,
  }) : status = SourceStatus.verified;

  /// A fact with no source yet. Renders as "Pending source".
  const Sourced.pending()
    : value = null,
      status = SourceStatus.pending,
      sourceName = null,
      sourceUrl = null,
      verifiedOn = null;

  final T? value;
  final SourceStatus status;
  final String? sourceName;
  final String? sourceUrl;
  final DateTime? verifiedOn;

  /// True only when there is a value the UI is permitted to print.
  bool get isPrintable => value != null && status == SourceStatus.verified;

  /// True when the UI must print the exact "Pending source" string instead.
  bool get isPending => status == SourceStatus.pending || value == null;

  /// True when a source line ("{regulator} · Verified on {date}") can render.
  bool get hasSourceLine => sourceName != null && verifiedOn != null;

  static Sourced<T>? fromJson<T extends Object>(
    Object? json,
    T? Function(Object?) parseValue,
  ) {
    if (json == null) return null;
    if (json is! Map) return null;
    return Sourced<T>(
      value: parseValue(json['value']),
      status: SourceStatus.fromWire(json['status'] as String?),
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      verifiedOn: jsonDate(json['verified_on']),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) encodeValue) => {
    'value': value == null ? null : encodeValue(value as T),
    'status': status.wire,
    if (sourceName != null) 'source_name': sourceName,
    if (sourceUrl != null) 'source_url': sourceUrl,
    if (verifiedOn != null) 'verified_on': verifiedOn!.toIso8601String(),
  };

  @override
  List<Object?> get props => [value, status, sourceName, sourceUrl, verifiedOn];
}

/// An amount of money.
///
/// Currency is always a code (never a symbol) and digits are always Western,
/// rendered as a single LTR-isolated island in both languages
/// (`LOCALIZATION.md` — bidi islands).
class Money extends ValueObject {
  const Money({required this.amount, required this.currency});

  /// Minor units are avoided deliberately: every price in the product is a
  /// whole-unit figure (EGP 500, USD 3,000) and the datasets carry them that
  /// way. Server-side arithmetic uses integers to stay exact.
  final int amount;
  final String currency;

  static Money? fromJson(Object? json) {
    if (json is! Map) return null;
    final amount = jsonInt(json['amount']);
    final currency = json['currency'] as String?;
    if (amount == null || currency == null) return null;
    return Money(amount: amount, currency: currency);
  }

  Map<String, dynamic> toJson() => {'amount': amount, 'currency': currency};

  @override
  List<Object?> get props => [amount, currency];
}
