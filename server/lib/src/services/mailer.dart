import 'package:ejadah_models/ejadah_models.dart';

import '../observability/logger.dart';

/// Transactional e-mail.
///
/// An interface rather than a direct provider call so the application never
/// depends on a specific vendor. Delivery is supporting infrastructure; the
/// business logic that decides *when* to send stays in the Dart server.
abstract interface class Mailer {
  Future<void> sendVerificationCode({
    required String to,
    required AppLanguage language,
    required String code,
  });

  Future<void> sendPasswordReset({
    required String to,
    required AppLanguage language,
    required String resetUrl,
  });
}

/// Development mailer: logs that a message would have been sent.
///
/// The code and reset URL are written to the log deliberately so a developer can
/// complete the flow locally without an SMTP account. That is also exactly why
/// application wiring refuses to select this implementation in production.
class ConsoleMailer implements Mailer {
  ConsoleMailer(this._logger);

  final AppLogger _logger;

  @override
  Future<void> sendVerificationCode({
    required String to,
    required AppLanguage language,
    required String code,
  }) async {
    _logger.info('verification email (development)', {
      'to': to,
      'lang': language.code,
      'code_for_local_testing': code,
    });
  }

  @override
  Future<void> sendPasswordReset({
    required String to,
    required AppLanguage language,
    required String resetUrl,
  }) async {
    _logger.info('password reset email (development)', {
      'to': to,
      'lang': language.code,
      'url_for_local_testing': resetUrl,
    });
  }
}

/// Mailer that does nothing, for tests that do not assert on delivery.
class NoopMailer implements Mailer {
  const NoopMailer();

  @override
  Future<void> sendVerificationCode({
    required String to,
    required AppLanguage language,
    required String code,
  }) async {}

  @override
  Future<void> sendPasswordReset({
    required String to,
    required AppLanguage language,
    required String resetUrl,
  }) async {}
}
