import 'dart:io';

import 'package:ejadah_server/src/config/config.dart';
import 'package:ejadah_server/src/db/database.dart';
import 'package:ejadah_server/src/db/migrator.dart';
import 'package:ejadah_server/src/import/country_importer.dart';
import 'package:ejadah_server/src/import/programme_importer.dart';
import 'package:ejadah_server/src/observability/logger.dart';

/// Imports the canonical Ejadah datasets into PostgreSQL.
///
///     dart run tool/import_data.dart
///
/// Reproducible and idempotent — safe to run repeatedly. Country guides are
/// imported first because programmes link to them.
Future<void> main(List<String> arguments) async {
  final logger = AppLogger('import');
  final config = AppConfig.fromEnvironment();
  final database = await Database.connect(config.databaseUrl);

  try {
    await Migrator(
      database,
      directory: Directory('server/migrations'),
      logger: logger,
    ).migrate();

    final countries = await CountryImporter(
      database,
      logger: logger.child('countries'),
    ).importFrom(File('data/countries.js'));
    stdout.writeln('Country guides: $countries');

    final programmes = await ProgrammeImporter(
      database,
      logger: logger.child('programmes'),
    ).importFrom(File('data/programmes.json'));
    stdout.writeln('Programmes:     $programmes');

    // A dataset that does not match its known shape means the wrong file was
    // read, and shipping that silently would corrupt the product's one claim.
    final problems = programmes.validate();
    if (problems.isNotEmpty) {
      stderr.writeln('\nImport validation failed:');
      for (final problem in problems) {
        stderr.writeln('  · $problem');
      }
      exitCode = 1;
      return;
    }

    stdout.writeln('\nImport validated.');
  } finally {
    await database.close();
  }
}
