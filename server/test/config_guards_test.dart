import 'package:ejadah_server/src/config/config.dart';
import 'package:test/test.dart';

/// Boot-time refusals.
///
/// Each of these is a configuration mistake that would be invisible at runtime
/// and expensive afterwards, so the process refuses to start rather than
/// running in a state nobody intended.
void main() {
  Map<String, String> env({
    String? jwtSecret,
    String environment = 'production',
    String paymentProvider = 'paymob',
    String? trustedProxyCount,
  }) => {
    'EJADAH_ENV': environment,
    'DATABASE_URL': 'postgres://u:p@localhost:5432/ejadah?sslmode=disable',
    'PAYMENT_PROVIDER': paymentProvider,
    if (jwtSecret != null) 'JWT_SECRET': jwtSecret,
    if (trustedProxyCount != null) 'TRUSTED_PROXY_COUNT': trustedProxyCount,
  };

  group('JWT secret', () {
    test('the placeholder from .env.example is refused in production', () {
      // 52 characters, so a length check alone lets it through — and it is
      // public in this repository, which makes every access token forgeable.
      expect(
        () => AppConfig.fromEnvironment(
          env(
            jwtSecret: 'replace-me-with-a-long-random-value-before-production',
          ),
        ),
        throwsA(isA<ConfigurationError>()),
      );
    });

    test('a long but low-variety secret is refused', () {
      // Length alone is not entropy: 64 identical characters clears any bar
      // written as a minimum length.
      expect(
        () => AppConfig.fromEnvironment(env(jwtSecret: 'a' * 64)),
        throwsA(isA<ConfigurationError>()),
      );
    });

    test('a short secret is refused', () {
      expect(
        () => AppConfig.fromEnvironment(env(jwtSecret: 'kzQ8vR2mXp')),
        throwsA(isA<ConfigurationError>()),
      );
    });

    test('a real random secret boots', () {
      final config = AppConfig.fromEnvironment(
        env(jwtSecret: 'kzQ8vR2mXp7WnLdF4hTyB9sCgJ6uEaVo3ZrQwMi1NxKl'),
      );
      expect(config.environment.isProduction, isTrue);
    });

    test('development is not held to this — the placeholder is fine there', () {
      final config = AppConfig.fromEnvironment(
        env(
          environment: 'development',
          paymentProvider: 'dev',
          jwtSecret: 'replace-me-with-a-long-random-value-before-production',
        ),
      );
      expect(config.environment.isProduction, isFalse);
    });
  });

  group('the payment simulator', () {
    test('cannot run in production', () {
      // It can complete a payment without money moving, which in production is
      // a financial defect rather than a convenience.
      expect(
        () => AppConfig.fromEnvironment(
          env(
            paymentProvider: 'dev',
            jwtSecret: 'kzQ8vR2mXp7WnLdF4hTyB9sCgJ6uEaVo3ZrQwMi1NxKl',
          ),
        ),
        throwsA(isA<ConfigurationError>()),
      );
    });
  });

  group('trusted proxies', () {
    test('default to none, so X-Forwarded-For is ignored', () {
      final config = AppConfig.fromEnvironment(
        env(jwtSecret: 'kzQ8vR2mXp7WnLdF4hTyB9sCgJ6uEaVo3ZrQwMi1NxKl'),
      );
      expect(config.trustedProxyCount, 0);
    });

    test('a negative count is refused rather than silently clamped', () {
      expect(
        () => AppConfig.fromEnvironment(
          env(
            jwtSecret: 'kzQ8vR2mXp7WnLdF4hTyB9sCgJ6uEaVo3ZrQwMi1NxKl',
            trustedProxyCount: '-1',
          ),
        ),
        throwsA(isA<ConfigurationError>()),
      );
    });
  });
}
