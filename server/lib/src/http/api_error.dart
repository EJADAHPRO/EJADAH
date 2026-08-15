import 'package:ejadah_models/ejadah_models.dart';

/// The typed failure taxonomy shared by server and client.
///
/// The client maps each code onto the approved bilingual copy; the server also
/// carries that copy so a failure surfaced by a route the client does not know
/// still reads as Ejadah rather than as a status code.
enum ApiErrorCode {
  validation('validation', 422),
  authentication('authentication', 401),
  authorization('authorization', 403),
  notFound('not_found', 404),
  conflict('conflict', 409),
  rateLimit('rate_limit', 429),
  payment('payment', 402),
  storage('storage', 400),
  unexpected('unexpected', 500);

  const ApiErrorCode(this.wire, this.statusCode);

  final String wire;
  final int statusCode;

  static ApiErrorCode fromWire(String? value) => ApiErrorCode.values.firstWhere(
    (code) => code.wire == value,
    orElse: () => ApiErrorCode.unexpected,
  );
}

/// The approved failure copy.
///
/// Every string is taken verbatim from `handoff-flutter/06-content/CONTENT.md`.
/// The rules those sentences follow — say what happened and what survived, no
/// status codes, no "Oops!", no exclamation marks — are the reason this
/// catalogue exists in one place rather than being written per route.
abstract final class ApiErrorCopy {
  static const LocalizedText generic = LocalizedText(
    en: "We couldn't do that just now. Nothing you entered is lost.",
    ar: 'تعذّر ذلك الآن. لم يُفقد ما أدخلته.',
  );

  static const LocalizedText server = LocalizedText(
    en: 'Something went wrong on our side. Nothing you saved is affected.',
    ar: 'حدث خطأ من جانبنا. لم يتأثر ما حفظته.',
  );

  static const LocalizedText sessionExpired = LocalizedText(
    en: "Please sign in again. You'll come straight back — nothing is lost.",
    ar: 'سجّل الدخول مجددًا. ستعود لمكانك — لم يُفقد شيء.',
  );

  static const LocalizedText rateLimited = LocalizedText(
    en: 'Take a short break — try in 2 minutes.',
    ar: 'خذ وقتًا قصيرًا — حاول بعد دقيقتين.',
  );

  static const LocalizedText contentUnavailable = LocalizedText(
    en: 'This is no longer available — often the intake closed.',
    ar: 'لم يعد متاحًا — غالبًا أُغلقت الدفعة.',
  );

  static const LocalizedText slotTaken = LocalizedText(
    en: "Someone booked that time a moment ago. Here's what's still open.",
    ar: 'حُجز هذا الموعد قبل لحظات. هذه المواعيد المتاحة.',
  );

  static const LocalizedText holdExpired = LocalizedText(
    en: 'That hold ran out and the time was released. '
        'Pick another — nothing was charged.',
    ar: 'انتهى الحجز المؤقت وتحرر الموعد. اختر آخر — لم يُخصم شيء.',
  );

  static const LocalizedText notPermitted = LocalizedText(
    en: "You don't have access to this.",
    ar: 'لا تملك صلاحية الوصول إلى هذا.',
  );

  static const LocalizedText signInRequired = LocalizedText(
    en: 'Sign in to continue — your work is saved.',
    ar: 'سجّل الدخول للمتابعة — عملك محفوظ.',
  );
}

/// A failure a route deliberately returns.
///
/// Anything else that escapes a handler becomes [ApiErrorCode.unexpected] with
/// the approved server copy — an internal message never reaches a user.
class ApiException implements Exception {
  ApiException(
    this.code, {
    LocalizedText? message,
    this.fields = const {},
    this.details,
    this.retryAfter,
  }) : message = message ?? _defaultMessage(code);

  ApiException.validation(Map<String, LocalizedText> fields, {LocalizedText? message})
    : this(ApiErrorCode.validation, fields: fields, message: message);

  ApiException.notFound({LocalizedText? message})
    : this(ApiErrorCode.notFound, message: message);

  ApiException.authentication({LocalizedText? message})
    : this(ApiErrorCode.authentication, message: message);

  ApiException.authorization({LocalizedText? message})
    : this(ApiErrorCode.authorization, message: message);

  ApiException.conflict({LocalizedText? message})
    : this(ApiErrorCode.conflict, message: message);

  final ApiErrorCode code;
  final LocalizedText message;

  /// Field name → the approved message for that field. Rendered below the
  /// field, announced to assistive technology.
  final Map<String, LocalizedText> fields;

  /// Never rendered; for server logs only.
  final String? details;
  final Duration? retryAfter;

  static LocalizedText _defaultMessage(ApiErrorCode code) => switch (code) {
    ApiErrorCode.authentication => ApiErrorCopy.sessionExpired,
    ApiErrorCode.authorization => ApiErrorCopy.notPermitted,
    ApiErrorCode.notFound => ApiErrorCopy.contentUnavailable,
    ApiErrorCode.rateLimit => ApiErrorCopy.rateLimited,
    ApiErrorCode.unexpected => ApiErrorCopy.server,
    _ => ApiErrorCopy.generic,
  };

  Map<String, dynamic> toJson() => {
    'error': {
      'code': code.wire,
      'message': message.toJson(),
      if (fields.isNotEmpty)
        'fields': fields.map((key, value) => MapEntry(key, value.toJson())),
      if (retryAfter != null) 'retry_after_seconds': retryAfter!.inSeconds,
    },
  };

  @override
  String toString() => 'ApiException(${code.wire}: ${details ?? message.en})';
}
