import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/language_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/verify_email_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/career/presentation/career_hub_screen.dart';
import '../features/career/presentation/compare_countries_screen.dart';
import '../features/career/presentation/compare_programmes_screen.dart';
import '../features/career/presentation/countries_screen.dart';
import '../features/career/presentation/country_detail_screen.dart';
import '../features/career/presentation/programme_detail_screen.dart';
import '../features/career/presentation/programmes_screen.dart';
import '../features/career/presentation/shortlist_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/learn/presentation/course_detail_screen.dart';
import '../features/learn/presentation/course_list_screen.dart';
import '../features/learn/presentation/learn_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/people/presentation/become_tutor_screen.dart';
import '../features/people/presentation/my_bookings_screen.dart';
import '../features/people/presentation/people_screen.dart';
import '../features/people/presentation/professional_list_screen.dart';
import '../features/people/presentation/professional_profile_screen.dart';
import '../features/people/presentation/tutor_application_screen.dart';
import '../features/people/presentation/tutor_status_screen.dart';
import '../features/profile/presentation/certificates_screen.dart';
import '../features/profile/presentation/cpd_screen.dart';
import '../features/profile/presentation/delete_account_screen.dart';
import '../features/profile/presentation/nfc_card_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/profile/presentation/public_profile_screen.dart';
import '../features/profile/presentation/verify_certificate_screen.dart';
import '../features/roadmap/presentation/roadmap_funnel_screen.dart';
import '../features/roadmap/presentation/roadmap_result_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/not_found_screen.dart';
import 'providers.dart';

/// Wraps a route's screen in its own gradient budget.
///
/// The six-per-screen limit is only enforceable where a [GradientBudget] sits
/// above the gradients, and a rule that depends on each new screen remembering
/// to opt in is a rule that erodes. Installing it here means every route is
/// counted by construction — including the next one somebody adds.
Widget _screen(String name, Widget child) =>
    GradientBudget(screenName: name, child: child);

/// The five tabs. Home · Learn · Career · People · Profile.
enum AppTab {
  home('/home'),
  learn('/learn'),
  career('/career'),
  people('/people'),
  profile('/profile');

  const AppTab(this.path);

  final String path;
}

final _rootKey = GlobalKey<NavigatorState>();

/// The application router.
///
/// Paths follow `handoff/deep-links.md` exactly, so a universal link, a shared
/// WhatsApp URL and an in-app push all resolve to the same screen.
///
/// Two rules shape the structure:
///
/// * **Public routes render without shell chrome.** `/dr/{slug}` and
///   `/verify/{code}` must work for a signed-out visitor: they are the growth
///   and trust loops, and gating them would break both.
/// * **Cold start navigates once.** The router waits for auth to resolve before
///   redirecting, so a deep link does not land somewhere and then jump.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: ref.watch(startupLocationProvider),
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);

      // Auth is still resolving: hold rather than guess, so the cold-start deep
      // link is not navigated twice.
      if (auth is AuthResolving) return null;

      // Everything else — browsing, the roadmap funnel, public profiles — is
      // open. The gates live in the screens that need them, not here, because a
      // guest must be able to reach and complete the funnel.
      const gated = {
        '/shortlist',
        '/bookings',
        '/profile',
        '/notifications',
        // `/teach` itself stays public — only what stores an application is
        // gated, which is the same rule booking follows.
        '/teach/apply',
        '/teach/status',
      };
      final needsAccount = gated.any(state.matchedLocation.startsWith);
      if (needsAccount && !auth.isAuthenticated) {
        // Carries where the user was headed, so sign-in returns them there.
        return '/sign-in?next=${Uri.encodeComponent(state.matchedLocation)}';
      }
      return null;
    },
    errorBuilder: (context, state) =>
        _screen('not-found', const NotFoundScreen()),
    routes: [
      // --- Public, chrome-free ----------------------------------------------
      GoRoute(
        // The old path from `handoff/deep-links.md`, kept as a redirect rather
        // than a second implementation. `/dr/{slug}` is canonical (REGISTER
        // conflict 11), but a card printed with the old one must still resolve.
        path: '/card/:handle',
        redirect: (context, state) =>
            '/dr/${state.pathParameters['handle']}',
      ),
      GoRoute(
        path: '/dr/:slug',
        builder: (context, state) => _screen(
          'public-profile',
          PublicProfileScreen(slug: state.pathParameters['slug']!),
        ),
      ),
      GoRoute(
        path: '/verify/:code',
        builder: (context, state) => _screen(
          'verify-certificate',
          VerifyCertificateScreen(code: state.pathParameters['code']!),
        ),
      ),

      // --- First run ---------------------------------------------------------
      GoRoute(
        path: '/language',
        builder: (context, state) =>
            _screen('language', const LanguageScreen()),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => _screen(
          'sign-in',
          SignInScreen(next: state.uri.queryParameters['next']),
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) =>
            _screen('verify-email', const VerifyEmailScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            _screen('forgot-password', const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => _screen(
          'sign-up',
          SignUpScreen(
            // Set when the user arrived from the guest gate, so the analytics
            // event can report guest-first conversion.
            fromGate: state.uri.queryParameters['intent'] == 'gate',
            next: state.uri.queryParameters['next'],
          ),
        ),
      ),

      // --- The roadmap funnel: guest-capable throughout ----------------------
      GoRoute(
        path: '/roadmap/new',
        builder: (context, state) => _screen(
          'roadmap-funnel',
          RoadmapFunnelScreen(seedPath: state.uri.queryParameters['path']),
        ),
      ),
      GoRoute(
        path: '/roadmap/:id',
        builder: (context, state) => _screen(
          'roadmap-result',
          RoadmapResultScreen(roadmapId: state.pathParameters['id']!),
        ),
      ),

      // --- Detail routes, pushed over the current tab ------------------------
      GoRoute(
        path: '/programme/:id',
        builder: (context, state) => _screen(
          'programme-detail',
          ProgrammeDetailScreen(
            programmeId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ),
      GoRoute(
        path: '/country/:iso',
        builder: (context, state) => _screen(
          'country-detail',
          CountryDetailScreen(
            iso: state.pathParameters['iso']!,
            initialTab: state.uri.queryParameters['tab'],
          ),
        ),
      ),
      GoRoute(
        path: '/countries',
        builder: (context, state) =>
            _screen('countries', const CountriesScreen()),
      ),
      GoRoute(
        path: '/programmes',
        builder: (context, state) => _screen(
          'programmes',
          ProgrammesScreen(
            countryIso: state.uri.queryParameters['country'],
          ),
        ),
      ),
      GoRoute(
        path: '/compare/countries',
        builder: (context, state) =>
            _screen('compare-countries', const CompareCountriesScreen()),
      ),
      GoRoute(
        path: '/compare/programmes',
        builder: (context, state) =>
            _screen('compare-programmes', const CompareProgrammesScreen()),
      ),
      GoRoute(
        path: '/shortlist',
        builder: (context, state) =>
            _screen('shortlist', const ShortlistScreen()),
      ),

      GoRoute(
        path: '/notifications',
        builder: (context, state) =>
            _screen('notifications', const NotificationsScreen()),
      ),

      // --- Learn: the catalogue and a course ---------------------------------
      GoRoute(
        // `handoff/deep-links.md`: a shared course link opens the course.
        path: '/course/:slug',
        builder: (context, state) => _screen(
          'course-detail',
          CourseDetailScreen(slug: state.pathParameters['slug']!),
        ),
      ),
      GoRoute(
        // One list per department. An unknown department is a not-found, not
        // silently the first one — Department.fromWire would coerce it.
        path: '/courses/:department',
        builder: (context, state) {
          final department = Department.values
              .where(
                (value) => value.wire == state.pathParameters['department'],
              )
              .firstOrNull;
          if (department == null) {
            return _screen('not-found', const NotFoundScreen());
          }
          return _screen(
            'course-list',
            CourseListScreen(department: department),
          );
        },
      ),

      // --- Becoming a tutor -------------------------------------------------
      //
      // `/teach` is public: the split is the first thing anyone weighing this
      // wants to know, and asking someone to open an account to find out what
      // they would be paid is the wrong order. The two routes underneath it are
      // gated, in the `gated` set above.
      GoRoute(
        path: '/teach',
        builder: (context, state) =>
            _screen('become-tutor', const BecomeTutorScreen()),
        routes: [
          GoRoute(
            path: 'apply',
            builder: (context, state) =>
                _screen('tutor-application', const TutorApplicationScreen()),
          ),
          GoRoute(
            path: 'status',
            builder: (context, state) =>
                _screen('tutor-status', const TutorStatusScreen()),
          ),
        ],
      ),

      // --- People: the doors, a professional, and the user's own sessions ----
      GoRoute(
        path: '/people/who/:slug',
        builder: (context, state) => _screen(
          'professional-profile',
          ProfessionalProfileScreen(slug: state.pathParameters['slug']!),
        ),
      ),
      GoRoute(
        // Tutoring, mentoring or consulting. An unknown door resolves to the
        // not-found state rather than an empty list that looks like a bug.
        path: '/people/:kind',
        builder: (context, state) {
          // Strictly resolved, not coerced: ServiceKind.fromWire falls back to
          // tutoring, which would answer a mistyped link with the wrong door's
          // list and no sign anything was wrong.
          final kind = ServiceKind.values
              .where((value) => value.wire == state.pathParameters['kind'])
              .firstOrNull;
          if (kind == null) {
            return _screen('not-found', const NotFoundScreen());
          }
          return _screen(
            'professional-list',
            ProfessionalListScreen(
              kind: kind,
              destinationIso: state.uri.queryParameters['destination'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) =>
            _screen('my-bookings', const MyBookingsScreen()),
      ),

      // --- Profile sub-screens ----------------------------------------------
      GoRoute(
        path: '/profile/card',
        builder: (context, state) => _screen('nfc-card', const NfcCardScreen()),
      ),
      GoRoute(
        path: '/profile/certificates',
        builder: (context, state) =>
            _screen('certificates', const CertificatesScreen()),
      ),
      GoRoute(
        path: '/profile/cpd',
        builder: (context, state) => _screen('cpd', const CpdScreen()),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) =>
            _screen('settings', const SettingsScreen()),
      ),
      GoRoute(
        path: '/profile/delete',
        builder: (context, state) =>
            _screen('delete-account', const DeleteAccountScreen()),
      ),

      // --- The tab shell -----------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Each branch keeps its own stack and scroll position, restored on
          // return and reset only when the active tab's root is re-tapped.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.home.path,
                builder: (context, state) =>
                    _screen('home', const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.learn.path,
                builder: (context, state) =>
                    _screen('learn', const LearnScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.career.path,
                builder: (context, state) =>
                    _screen('career', const CareerHubScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.people.path,
                builder: (context, state) =>
                    _screen('people', const PeopleScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppTab.profile.path,
                builder: (context, state) =>
                    _screen('profile', const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// The bottom-navigation destinations, in canonical order.
List<EjadahNavDestination> navDestinations(BuildContext context) {
  final strings = context.strings;
  return [
    EjadahNavDestination(
      label: strings.tabHome,
      icon: EjadahIcons.home,
      activeIcon: EjadahIcons.homeFilled,
    ),
    EjadahNavDestination(
      // Canonical "Learn" — the prototype's "Courses" label is legacy.
      label: strings.tabLearn,
      icon: EjadahIcons.learn,
      activeIcon: EjadahIcons.learnFilled,
    ),
    EjadahNavDestination(
      label: strings.tabCareer,
      icon: EjadahIcons.career,
      activeIcon: EjadahIcons.careerFilled,
    ),
    EjadahNavDestination(
      // Canonical "People" — the prototype's "Connect" label is legacy.
      label: strings.tabPeople,
      icon: EjadahIcons.people,
      activeIcon: EjadahIcons.peopleFilled,
    ),
    EjadahNavDestination(
      label: strings.tabProfile,
      icon: EjadahIcons.profile,
      activeIcon: EjadahIcons.profileFilled,
    ),
  ];
}
