import 'package:ejadah_models/ejadah_models.dart';

/// The typed failure taxonomy.
///
/// Every failure the app can surface is one of these, and each carries the
/// approved bilingual copy rather than a code the UI has to interpret. Screens
/// switch on the type; they never format an exception into a message.
sealed class Failure implements Exception {
  const Failure({required this.message, this.fields = const {}});

  /// What the user is shown, in both languages.
  final LocalizedText message;

  /// Field name → message, for form-level failures.
  final Map<String, LocalizedText> fields;

  /// Whether offering a retry makes sense. A validation error does not get one;
  /// a dropped connection does.
  bool get isRetryable => false;

  /// Builds the right failure from the server's error envelope.
  factory Failure.fromEnvelope(Map<String, dynamic> json, int statusCode) {
    final error = json['error'];
    if (error is! Map) return UnexpectedFailure(message: FailureCopy.server);

    final message =
        LocalizedText.fromJson(error['message']) ?? FailureCopy.generic;
    final fields = <String, LocalizedText>{};
    final rawFields = error['fields'];
    if (rawFields is Map) {
      for (final entry in rawFields.entries) {
        final parsed = LocalizedText.fromJson(entry.value);
        if (parsed != null) fields[entry.key.toString()] = parsed;
      }
    }

    return switch (error['code'] as String?) {
      'validation' => ValidationFailure(message: message, fields: fields),
      'authentication' => AuthenticationFailure(message: message),
      'authorization' => AuthorizationFailure(message: message),
      'not_found' => NotFoundFailure(message: message),
      'conflict' => ConflictFailure(message: message),
      'rate_limit' => RateLimitFailure(
        message: message,
        retryAfter: Duration(
          seconds: (error['retry_after_seconds'] as num?)?.toInt() ?? 60,
        ),
      ),
      'payment' => PaymentFailure(message: message),
      'storage' => StorageFailure(message: message),
      _ => UnexpectedFailure(message: message, statusCode: statusCode),
    };
  }
}

/// The connection failed or timed out.
///
/// Distinct from a server error: the user's saved content is still readable and
/// the app says so, rather than implying data loss.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = FailureCopy.offline});

  @override
  bool get isRetryable => true;
}

/// The session is gone. The user signs in again and comes straight back.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message = FailureCopy.sessionExpired});
}

/// Signed in, but not permitted.
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({super.message = FailureCopy.notPermitted});
}

/// Input the server rejected, with per-field messages.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.fields});
}

/// The resource is gone — often an intake that closed.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = FailureCopy.contentUnavailable});
}

/// Someone else got there first. The booking slot race lands here.
class ConflictFailure extends Failure {
  const ConflictFailure({super.message = FailureCopy.slotTaken});

  @override
  bool get isRetryable => true;
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = FailureCopy.rateLimited,
    required this.retryAfter,
  });

  final Duration retryAfter;
}

class PaymentFailure extends Failure {
  const PaymentFailure({super.message = FailureCopy.generic});

  @override
  bool get isRetryable => true;
}

class StorageFailure extends Failure {
  const StorageFailure({super.message = FailureCopy.generic});
}

/// Anything unclassified. Always shows the approved server copy — an internal
/// message is never rendered.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = FailureCopy.server,
    this.statusCode,
  });

  final int? statusCode;

  @override
  bool get isRetryable => true;
}

/// The approved failure copy, verbatim from `06-content/CONTENT.md`.
///
/// Each sentence says what happened *and* what survived. No codes, no "Oops!",
/// no exclamation marks.
abstract final class FailureCopy {
  static const LocalizedText generic = LocalizedText(
    en: "We couldn't do that just now. Nothing you entered is lost.",
    ar: 'تعذّر ذلك الآن. لم يُفقد ما أدخلته.',
  );

  static const LocalizedText server = LocalizedText(
    en: 'Something went wrong on our side. Nothing you saved is affected.',
    ar: 'حدث خطأ من جانبنا. لم يتأثر ما حفظته.',
  );

  static const LocalizedText offline = LocalizedText(
    en: 'Offline — showing your saved content',
    ar: 'بلا اتصال — نعرض المحتوى المحفوظ',
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

  static const LocalizedText notPermitted = LocalizedText(
    en: "You don't have access to this.",
    ar: 'لا تملك صلاحية الوصول إلى هذا.',
  );

  static const LocalizedText errorTitle = LocalizedText(
    en: "We couldn't load that",
    ar: 'تعذّر التحميل',
  );

  static const LocalizedText retry = LocalizedText(
    en: 'Try again',
    ar: 'حاول مرة أخرى',
  );
}
