import 'dart:io';

/// Which environment the process is running in.
///
/// The distinction is load-bearing: several development affordances (the
/// payment simulator, demo accounts, verbose errors) are refused outright in
/// production rather than merely discouraged.
enum AppEnvironment {
  development,
  test,
  staging,
  production;

  static AppEnvironment fromName(String? value) => switch (value?.toLowerCase()) {
    'test' => AppEnvironment.test,
    'staging' => AppEnvironment.staging,
    'production' || 'prod' => AppEnvironment.production,
    _ => AppEnvironment.development,
  };

  bool get isProduction => this == AppEnvironment.production;

  bool get isTest => this == AppEnvironment.test;

  /// Development-only features may run here and nowhere else.
  bool get allowsDevelopmentAffordances =>
      this == AppEnvironment.development || this == AppEnvironment.test;
}

/// A configuration value that was required and missing.
class ConfigurationError implements Exception {
  ConfigurationError(this.message);

  final String message;

  @override
  String toString() => 'ConfigurationError: $message';
}

/// Runtime configuration, read once at boot.
///
/// Values come from the process environment; `.env.example` documents every key
/// with a placeholder. Real secrets are never committed.
class AppConfig {
  AppConfig({
    required this.environment,
    required this.port,
    required this.databaseUrl,
    required this.jwtSecret,
    required this.accessTokenTtl,
    required this.refreshTokenTtl,
    required this.bookingHoldDuration,
    required this.platformFeePercent,
    required this.publicBaseUrl,
    required this.checkoutBaseUrl,
    required this.storageRoot,
    required this.paymentProvider,
    required this.enableBackgroundJobs,
    required this.logLevel,
  });

  final AppEnvironment environment;
  final int port;
  final String databaseUrl;
  final String jwtSecret;
  final Duration accessTokenTtl;
  final Duration refreshTokenTtl;

  /// Server-controlled and configurable, never decided by the client.
  final Duration bookingHoldDuration;

  /// The 70/30 split. 30 means the platform keeps 30%.
  final int platformFeePercent;
  final String publicBaseUrl;

  /// Sessions and the physical card are paid on the website; the app shows a
  /// redirect sheet that names this host.
  final String checkoutBaseUrl;
  final String storageRoot;
  final String paymentProvider;
  final bool enableBackgroundJobs;
  final String logLevel;

  static AppConfig fromEnvironment([Map<String, String>? source]) {
    final env = source ?? Platform.environment;
    final environment = AppEnvironment.fromName(env['EJADAH_ENV']);

    final databaseUrl = env['DATABASE_URL'];
    if (databaseUrl == null || databaseUrl.isEmpty) {
      throw ConfigurationError(
        'DATABASE_URL is required. See .env.example for the expected form.',
      );
    }

    final jwtSecret = env['JWT_SECRET'] ?? '';
    if (environment.isProduction && jwtSecret.length < 32) {
      throw ConfigurationError(
        'JWT_SECRET must be at least 32 characters in production.',
      );
    }

    final paymentProvider = env['PAYMENT_PROVIDER'] ?? 'dev';
    if (environment.isProduction && paymentProvider == 'dev') {
      // The simulator can complete a payment without money moving. Booting it
      // in production would be a financial defect, so this is fatal.
      throw ConfigurationError(
        'The development payment simulator cannot run in production. '
        'Set PAYMENT_PROVIDER to a real provider.',
      );
    }

    return AppConfig(
      environment: environment,
      port: int.tryParse(env['PORT'] ?? '') ?? 8080,
      databaseUrl: databaseUrl,
      jwtSecret: jwtSecret.isEmpty
          ? 'ejadah-development-only-secret-not-for-production'
          : jwtSecret,
      accessTokenTtl: Duration(
        minutes: int.tryParse(env['ACCESS_TOKEN_TTL_MINUTES'] ?? '') ?? 15,
      ),
      refreshTokenTtl: Duration(
        days: int.tryParse(env['REFRESH_TOKEN_TTL_DAYS'] ?? '') ?? 60,
      ),
      bookingHoldDuration: Duration(
        minutes: int.tryParse(env['BOOKING_HOLD_MINUTES'] ?? '') ?? 15,
      ),
      platformFeePercent:
          int.tryParse(env['PLATFORM_FEE_PERCENT'] ?? '') ?? 30,
      publicBaseUrl: env['PUBLIC_BASE_URL'] ?? 'https://ejadah.international',
      checkoutBaseUrl:
          env['CHECKOUT_BASE_URL'] ?? 'https://ejadah.international/checkout',
      storageRoot: env['STORAGE_ROOT'] ?? '.storage',
      paymentProvider: paymentProvider,
      enableBackgroundJobs:
          (env['ENABLE_BACKGROUND_JOBS'] ?? 'true').toLowerCase() != 'false',
      logLevel: env['LOG_LEVEL'] ?? 'info',
    );
  }

  /// The share of a booking the professional keeps.
  int get professionalSharePercent => 100 - platformFeePercent;
}
