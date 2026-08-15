import 'package:postgres/postgres.dart';

/// A thin wrapper over the connection pool.
///
/// Repositories take this rather than a raw connection so that a repository
/// method can be run inside a caller's transaction without knowing whether one
/// is open — [Session] is the shared abstraction and [runTx] supplies it.
class Database {
  Database._(this._pool);

  final Pool<void> _pool;

  /// Opens a pool against a `postgres://user:pass@host:port/database` URL.
  static Future<Database> connect(
    String databaseUrl, {
    int maxConnections = 12,
  }) async {
    final uri = Uri.parse(databaseUrl);
    final userInfo = uri.userInfo.split(':');

    final endpoint = Endpoint(
      host: uri.host.isEmpty ? 'localhost' : uri.host,
      port: uri.hasPort ? uri.port : 5432,
      database: uri.pathSegments.isEmpty ? 'postgres' : uri.pathSegments.first,
      username: userInfo.isNotEmpty && userInfo.first.isNotEmpty
          ? Uri.decodeComponent(userInfo.first)
          : null,
      password: userInfo.length > 1 ? Uri.decodeComponent(userInfo[1]) : null,
    );

    final sslMode = uri.queryParameters['sslmode'];
    final pool = Pool<void>.withEndpoints(
      [endpoint],
      settings: PoolSettings(
        maxConnectionCount: maxConnections,
        sslMode: switch (sslMode) {
          'disable' => SslMode.disable,
          'verify-full' => SslMode.verifyFull,
          _ => SslMode.disable,
        },
      ),
    );

    // Fail fast at boot rather than on the first request.
    await pool.execute('SELECT 1');
    return Database._(pool);
  }

  /// Runs [body] against a pooled connection with no explicit transaction.
  Future<T> run<T>(Future<T> Function(Session session) body) => _pool.run(body);

  /// Runs [body] inside a transaction, committing on success and rolling back
  /// on any thrown error.
  ///
  /// Every multi-statement mutation goes through here — booking confirmation,
  /// multi-session plan creation and guest→account migration are all
  /// all-or-nothing by requirement.
  Future<T> runTx<T>(Future<T> Function(TxSession tx) body) =>
      _pool.runTx(body);

  Future<void> close() => _pool.close();
}

/// Convenience helpers for reading typed values out of a result row map.
///
/// Values arrive as [UndecodedBytes] whenever the column's type OID is not one
/// the driver knows — which is every user-defined enum in this schema
/// (`deadline_status`, `pathway_class`, `source_status`, `user_role`, …).
/// Decoding is handled here rather than by casting each enum to `text` in every
/// query, so a new enum column cannot reintroduce the same crash.
extension RowReading on Map<String, dynamic> {
  String str(String column) => _asString(this[column])!;

  String? strOrNull(String column) => _asString(this[column]);

  static String? _asString(Object? value) => switch (value) {
    null => null,
    final String text => text,
    final UndecodedBytes raw => raw.asString,
    final Object other => other.toString(),
  };

  int intAt(String column) => (this[column] as num).toInt();

  int? intOrNull(String column) => (this[column] as num?)?.toInt();

  double? doubleOrNull(String column) {
    final value = this[column];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    // numeric columns arrive as a decimal type that stringifies exactly.
    return double.tryParse(value.toString());
  }

  bool boolAt(String column) => this[column] as bool;

  bool? boolOrNull(String column) => this[column] as bool?;

  DateTime? dateOrNull(String column) {
    final value = this[column];
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  DateTime dateAt(String column) => dateOrNull(column)!;

  List<String> stringList(String column) {
    final value = this[column];
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }
}
