import 'dart:io';

import 'package:ejadah_server/src/app.dart';
import 'package:ejadah_server/src/config/config.dart';
import 'package:ejadah_server/src/db/database.dart';
import 'package:ejadah_server/src/db/migrator.dart';
import 'package:ejadah_server/src/jobs/job_runner.dart';
import 'package:ejadah_server/src/observability/logger.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

/// Entry point for the Ejadah Dart backend.
Future<void> main(List<String> arguments) async {
  final logger = AppLogger('server');
  final config = AppConfig.fromEnvironment();

  final database = await Database.connect(config.databaseUrl);
  logger.info('database connected', {'environment': config.environment.name});

  // Migrations run at boot in development so a fresh clone is one command away
  // from working. Staging and production run them as a deliberate deploy step.
  if (config.environment.allowsDevelopmentAffordances ||
      arguments.contains('--migrate')) {
    final applied = await Migrator(database, logger: logger).migrate();
    logger.info('migrations up to date', {'applied': applied.length});
  }

  final app = await EjadahApp.create(
    config: config,
    database: database,
    logger: logger,
  );

  JobRunner? jobs;
  if (config.enableBackgroundJobs) {
    // Deadline reminders, session reminders and hold expiry cannot depend on
    // the Flutter app being open.
    jobs = JobRunner(database: database, config: config, logger: logger)
      ..start();
  }

  final server = await shelf_io.serve(
    app.handler,
    InternetAddress.anyIPv4,
    config.port,
  );
  server.autoCompress = true;

  logger.info('listening', {
    'port': server.port,
    'environment': config.environment.name,
  });

  Future<void> shutdown(ProcessSignal signal) async {
    logger.info('shutting down', {'signal': signal.toString()});
    jobs?.stop();
    await server.close(force: false);
    await app.close();
    exit(0);
  }

  ProcessSignal.sigint.watch().listen(shutdown);
  if (!Platform.isWindows) ProcessSignal.sigterm.watch().listen(shutdown);
}
