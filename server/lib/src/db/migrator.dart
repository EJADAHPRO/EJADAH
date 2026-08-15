import 'dart:io';

import 'package:postgres/postgres.dart';

import '../observability/logger.dart';
import 'database.dart';

/// Applies the ordered SQL migrations in `server/migrations/`.
///
/// Migrations are plain SQL files named `NNN_description.sql`. Each runs once,
/// inside a transaction, and is recorded in `schema_migrations` — so running the
/// migrator twice is a no-op and a half-applied migration cannot exist.
class Migrator {
  Migrator(this._database, {Directory? directory, AppLogger? logger})
    : _directory = directory ?? Directory(_defaultPath),
      _logger = logger ?? AppLogger('migrator');

  static const String _defaultPath = 'migrations';

  final Database _database;
  final Directory _directory;
  final AppLogger _logger;

  Future<List<String>> migrate() async {
    if (!_directory.existsSync()) {
      throw StateError('Migrations directory not found: ${_directory.path}');
    }

    await _database.run(
      (session) => session.execute('''
        CREATE TABLE IF NOT EXISTS schema_migrations (
          version    text PRIMARY KEY,
          applied_at timestamptz NOT NULL DEFAULT now()
        )
      '''),
    );

    final applied = await _appliedVersions();
    final pending = _migrationFiles().where(
      (file) => !applied.contains(_versionOf(file)),
    );

    final result = <String>[];
    for (final file in pending) {
      final version = _versionOf(file);
      final sql = file.readAsStringSync();

      // Each migration is its own transaction: a failure leaves the schema
      // exactly as it was, with nothing recorded.
      await _database.runTx((tx) async {
        // Migration files contain many statements; the simple query protocol is
        // the one that accepts a multi-statement script.
        await tx.execute(sql, queryMode: QueryMode.simple);
        await tx.execute(
          Sql.named(
            'INSERT INTO schema_migrations (version) VALUES (@version)',
          ),
          parameters: {'version': version},
        );
      });

      _logger.info('applied migration', {'version': version});
      result.add(version);
    }

    return result;
  }

  /// Drops and recreates the public schema. Test and development only — the
  /// caller is responsible for refusing this in any other environment.
  Future<void> reset() async {
    await _database.run((session) async {
      await session.execute('DROP SCHEMA public CASCADE');
      await session.execute('CREATE SCHEMA public');
    });
  }

  Future<Set<String>> _appliedVersions() async {
    final rows = await _database.run(
      (session) => session.execute('SELECT version FROM schema_migrations'),
    );
    return rows.map((row) => row[0] as String).toSet();
  }

  List<File> _migrationFiles() =>
      _directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  String _versionOf(File file) => file.uri.pathSegments.last;
}
