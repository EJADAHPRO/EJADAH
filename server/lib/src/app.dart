import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'config/config.dart';
import 'db/database.dart';
import 'http/api_error.dart';
import 'http/middleware.dart';
import 'http/responses.dart';
import 'modules/auth/auth_repository.dart';
import 'modules/auth/auth_routes.dart';
import 'modules/auth/auth_service.dart';
import 'modules/career/career_repository.dart';
import 'modules/career/career_routes.dart';
import 'modules/career/career_service.dart';
import 'modules/home/home_routes.dart';
import 'modules/home/home_service.dart';
import 'modules/learn/learn_repository.dart';
import 'modules/learn/learn_routes.dart';
import 'modules/learn/learn_service.dart';
import 'modules/notifications/notification_routes.dart';
import 'modules/notifications/notification_scheduler.dart';
import 'modules/people/booking_service.dart';
import 'modules/people/people_repository.dart';
import 'modules/people/people_routes.dart';
import 'modules/people/people_service.dart';
import 'modules/profile/profile_repository.dart';
import 'modules/profile/profile_routes.dart';
import 'modules/profile/profile_service.dart';
import 'modules/roadmap/roadmap_repository.dart';
import 'modules/roadmap/roadmap_routes.dart';
import 'modules/roadmap/roadmap_service.dart';
import 'observability/logger.dart';
import 'services/mailer.dart';
import 'services/password_hasher.dart';
import 'services/payments/payment_provider.dart';
import 'services/token_service.dart';

/// The composed application.
///
/// A modular monolith: one process, one database, clear module boundaries. No
/// microservices, no broker, no cache tier — none of which this product has a
/// measured need for.
class EjadahApp {
  EjadahApp._({
    required this.config,
    required this.database,
    required this.handler,
    required this.logger,
  });

  final AppConfig config;
  final Database database;
  final Handler handler;
  final AppLogger logger;

  static Future<EjadahApp> create({
    required AppConfig config,
    required Database database,
    AppLogger? logger,
    Mailer? mailer,
    PasswordHasher? hasher,
  }) async {
    final log = logger ?? AppLogger('ejadah');

    if (config.environment.isProduction && mailer is ConsoleMailer) {
      throw ConfigurationError(
        'The console mailer writes verification codes to the log and '
        'cannot run in production.',
      );
    }

    final tokens = TokenService(config);
    final resolvedMailer = mailer ?? ConsoleMailer(log.child('mail'));
    final resolvedHasher = hasher ?? PasswordHasher();

    final authRepository = AuthRepository(database);
    final careerRepository = CareerRepository(database);
    final roadmapRepository = RoadmapRepository(database);
    final peopleRepository = PeopleRepository(database);

    final authService = AuthService(
      database: database,
      repository: authRepository,
      roadmaps: roadmapRepository,
      hasher: resolvedHasher,
      tokens: tokens,
      mailer: resolvedMailer,
      config: config,
      logger: log.child('auth'),
    );
    final careerService = CareerService(careerRepository);
    final roadmapService = RoadmapService(repository: roadmapRepository);
    final homeService = HomeService(
      career: careerRepository,
      roadmaps: roadmapRepository,
      people: peopleRepository,
      logger: log.child('home'),
    );

    final notifications = NotificationScheduler(database);

    // The simulator is the only provider built here, and AppConfig refuses to
    // boot with it in production — so a real provider landing later replaces
    // this line without any route knowing.
    final payments = DevPaymentProvider(
      config: config,
      logger: log.child('payments'),
    );
    final bookingService = BookingService(
      database: database,
      repository: peopleRepository,
      payments: payments,
      config: config,
      logger: log.child('booking'),
    );
    final peopleService = PeopleService(peopleRepository);
    final learnService = LearnService(
      repository: LearnRepository(database),
      config: config,
    );
    final profileService = ProfileService(
      repository: ProfileRepository(database),
      config: config,
    );

    final api = Router()
      ..mount(
        '/auth',
        authRoutes(
          authService,
          trustedProxyCount: config.trustedProxyCount,
        ).call,
      )
      ..mount('/career', careerRoutes(careerService).call)
      ..mount('/roadmap', roadmapRoutes(roadmapService).call)
      ..mount('/home', homeRoutes(homeService, authService).call)
      ..mount('/notifications', notificationRoutes(notifications).call)
      ..mount('/learn', learnRoutes(learnService).call)
      ..mount('/people', peopleRoutes(peopleService, bookingService).call)
      ..mount('/profile', profileRoutes(profileService).call);

    final root = Router()
      ..mount('/api/v1', api.call)
      ..get('/health', (Request request) async {
        // Touches the database so a green health check means the process can
        // actually serve, not merely that it is listening.
        await database.run((session) => session.execute('SELECT 1'));
        return Json.ok({
          'status': 'ok',
          'environment': config.environment.name,
        });
      })
      ..all('/<ignored|.*>', (Request request) {
        // A link to deleted content resolves to a real not-found state with a
        // working action, never a blank screen.
        throw ApiException.notFound();
      });

    final handler = const Pipeline()
        .addMiddleware(contextMiddleware(tokens))
        .addMiddleware(securityHeadersMiddleware())
        .addMiddleware(
          corsMiddleware(
            config.environment.isProduction ? [config.publicBaseUrl] : ['*'],
          ),
        )
        .addMiddleware(errorMiddleware(log))
        .addMiddleware(loggingMiddleware(log))
        .addHandler(root.call);

    return EjadahApp._(
      config: config,
      database: database,
      handler: handler,
      logger: log,
    );
  }

  Future<void> close() => database.close();
}
