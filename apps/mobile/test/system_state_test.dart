import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_mobile/features/system/system.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The ten system states (SY-01..SY-10) and the rules that make them trustworthy.
///
/// Story E6-02: "Failures speak human. All 10 system states route to action; no
/// status codes; 'your answers are saved' wherever true." Each clause of that
/// sentence is asserted here rather than reviewed by eye:
///
/// * every state renders, announces itself, and its primary action does
///   something real — a route change or an injected callback;
/// * nothing clips at 200% text scale, in either language, on the smallest
///   phone in the support matrix;
/// * no approved string carries a status code, an exclamation mark or an emoji,
///   and a failure that *does* carry a status code never shows it.
void main() {
  late EjadahStrings en;
  late EjadahStrings ar;

  setUpAll(() async {
    en = await EjadahStrings.delegate.load(const Locale('en'));
    ar = await EjadahStrings.delegate.load(const Locale('ar'));
  });

  EjadahStrings stringsFor(AppLanguage language) =>
      language == AppLanguage.ar ? ar : en;

  group('the ten states render and route', () {
    for (final testCase in _cases) {
      testWidgets('${testCase.name} renders and its action leads somewhere', (
        tester,
      ) async {
        final probe = _Probe();
        final router = await _pumpState(
          tester,
          screen: testCase.build(probe),
          language: AppLanguage.ar,
        );

        expect(
          find.text(testCase.title(ar)),
          findsOneWidget,
          reason: '${testCase.name} did not render its title',
        );

        await tester.tap(find.byType(EjadahPrimaryButton));
        await tester.pumpAndSettle();

        if (testCase.route case final route?) {
          expect(
            router.routerDelegate.currentConfiguration.uri.path,
            route,
            reason: '${testCase.name} did not route to $route',
          );
        } else {
          expect(
            probe.fired,
            1,
            reason: '${testCase.name} did not invoke its injected action',
          );
        }
      });
    }

    testWidgets('every state announces itself as a live region', (tester) async {
      final handle = tester.ensureSemantics();

      for (final testCase in _cases) {
        await _pumpState(
          tester,
          screen: testCase.build(_Probe()),
          language: AppLanguage.ar,
        );

        expect(
          tester.getSemantics(find.text(testCase.title(ar))),
          matchesSemantics(
            label: testCase.title(ar),
            isLiveRegion: true,
            isHeader: true,
            textDirection: TextDirection.rtl,
          ),
          reason: '${testCase.name} does not announce itself',
        );
      }

      handle.dispose();
    });

    testWidgets('nine states offer a second route; force update offers none', (
      tester,
    ) async {
      for (final testCase in _cases) {
        await _pumpState(
          tester,
          screen: testCase.build(_Probe()),
          language: AppLanguage.ar,
        );

        expect(
          find.byType(EjadahGhostButton),
          testCase.name == 'force update' ? findsNothing : findsOneWidget,
          reason: '${testCase.name} has the wrong number of exits',
        );
      }
    });

    testWidgets('force update cannot be dismissed', (tester) async {
      await _pumpState(
        tester,
        screen: ForceUpdateScreen(onUpdate: _Probe().fire),
      );

      final scope = tester.widget<PopScope<void>>(find.byType(PopScope<void>));
      // The build can no longer reach the servers; going back would only fail
      // one screen later.
      expect(scope.canPop, isFalse);
    });
  });

  group('200% text scale', () {
    // The explicit acceptance criterion, and the thing most likely to be
    // broken: 320x568 is the smallest phone in the support matrix, and Arabic
    // runs longer than English at the same size.
    for (final testCase in _cases) {
      for (final language in AppLanguage.values) {
        testWidgets(
          '${testCase.name} does not clip at 2.0 in ${language.code}',
          (tester) async {
            tester.view.physicalSize = const Size(320, 568);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);

            await _pumpState(
              tester,
              screen: testCase.build(_Probe()),
              language: language,
              textScale: 2,
            );

            expect(
              tester.takeException(),
              isNull,
              reason: '${testCase.name} overflows at 200% in ${language.code}',
            );
            expect(find.text(testCase.title(stringsFor(language))), findsOne);
          },
        );
      }
    }

    testWidgets('the action is still reachable at 2.0', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final probe = _Probe();
      await _pumpState(
        tester,
        screen: OfflineScreen(onRetry: probe.fire),
        language: AppLanguage.ar,
        textScale: 2,
      );

      // Guards the ten tests above from going quietly vacuous: if the scaler
      // stopped reaching the template they would all pass without testing
      // anything.
      final scaler = MediaQuery.textScalerOf(
        tester.element(find.byType(EjadahSystemState)),
      );
      expect(scaler.scale(10), 20);

      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      expect(
        position.maxScrollExtent,
        greaterThan(0),
        reason: 'the 200% case no longer exceeds a 320x568 phone',
      );

      await tester.scrollUntilVisible(
        find.byType(EjadahPrimaryButton),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byType(EjadahPrimaryButton));
      await tester.pumpAndSettle();

      expect(probe.fired, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('the failure registry', () {
    void expectsScreen(Failure failure, Type screen) {
      expect(
        SystemStateScreen.forFailure(failure, onRetry: () {}).runtimeType,
        screen,
        reason: '${failure.runtimeType} maps to the wrong state',
      );
    }

    test('each typed failure maps to one state', () {
      expectsScreen(const NetworkFailure(), OfflineScreen);
      expectsScreen(const AuthenticationFailure(), SessionExpiredScreen);
      expectsScreen(const AuthorizationFailure(), ContentUnavailableScreen);
      expectsScreen(const NotFoundFailure(), ContentUnavailableScreen);
      expectsScreen(
        const RateLimitFailure(retryAfter: Duration(minutes: 2)),
        RateLimitedScreen,
      );
      expectsScreen(const ConflictFailure(), ServerErrorScreen);
      expectsScreen(const PaymentFailure(), ServerErrorScreen);
      expectsScreen(const StorageFailure(), ServerErrorScreen);
      expectsScreen(const UnexpectedFailure(), ServerErrorScreen);
      expectsScreen(
        const ValidationFailure(message: FailureCopy.generic),
        ServerErrorScreen,
      );
    });

    test('failures with an inline home are flagged as such', () {
      // A field error belongs under its field, and a booking conflict belongs
      // in the slot picker — replacing the screen throws away the context that
      // makes either fixable.
      expect(
        SystemStateScreen.hasInlineHome(
          const ValidationFailure(message: FailureCopy.generic),
        ),
        isTrue,
      );
      expect(SystemStateScreen.hasInlineHome(const ConflictFailure()), isTrue);
      expect(SystemStateScreen.hasInlineHome(const NetworkFailure()), isFalse);
    });

    test('sign-in returns the user to where they were', () {
      final screen =
          SystemStateScreen.forFailure(
                const AuthenticationFailure(),
                onRetry: () {},
                next: '/shortlist',
              )
              as SessionExpiredScreen;
      expect(screen.next, '/shortlist');
    });

    testWidgets('a failure carrying a status code never shows it', (
      tester,
    ) async {
      await _pumpState(
        tester,
        screen: SystemStateScreen.forFailure(
          const UnexpectedFailure(statusCode: 500),
          onRetry: () {},
        ),
        language: AppLanguage.ar,
      );

      final rendered = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join(' ');
      expect(rendered, isNot(contains('500')));
      expect(rendered, isNot(matches(RegExp(r'\d{3}'))));
      expect(find.text(ar.errServer), findsOneWidget);
    });
  });

  group('the error boundary', () {
    setUp(() => SystemErrorBoundary.install(force: true));
    tearDown(SystemErrorBoundary.uninstall);

    testWidgets('a widget crash shows SY-08 instead of a red screen', (
      tester,
    ) async {
      await _pumpState(tester, screen: const SystemErrorBoundary(child: _Bomb()));

      expect(tester.takeException(), isStateError);
      await tester.pumpAndSettle();

      expect(find.text(ar.sysErrorBoundaryTitle), findsOneWidget);
      // Flutter's red box is never what a dentist should be looking at.
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('it routes home', (tester) async {
      final router = await _pumpState(
        tester,
        screen: const SystemErrorBoundary(child: _Bomb()),
      );
      expect(tester.takeException(), isStateError);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(EjadahPrimaryButton));
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });

    testWidgets('retry rebuilds the subtree and calls back', (tester) async {
      var resets = 0;
      await tester.pumpWidget(
        _App(
          language: AppLanguage.ar,
          child: SystemErrorBoundary(
            onReset: () => resets++,
            child: const _Bomb(),
          ),
        ),
      );
      expect(tester.takeException(), isStateError);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(EjadahGhostButton));
      await tester.pumpAndSettle();

      expect(resets, 1);
      // The cause has not gone away, so the state comes back rather than
      // pretending the crash did not happen.
      expect(tester.takeException(), isStateError);
      expect(find.text(ar.sysErrorBoundaryTitle), findsOneWidget);
    });

    testWidgets('a healthy subtree is untouched', (tester) async {
      await _pumpState(
        tester,
        screen: const SystemErrorBoundary(child: Text('the real screen')),
      );
      expect(find.text('the real screen'), findsOneWidget);
      expect(find.text(ar.sysErrorBoundaryTitle), findsNothing);
    });
  });

  group('copy discipline', () {
    // "No status codes" is not a style preference: a code is the moment the
    // product stops speaking to the user and starts speaking to itself.
    final statusCode = RegExp(r'(?<!\d)\d{3,}(?!\d)');
    final shouting = RegExp('[!！]');
    final emoji = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2190}-\u{21FF}\u{2600}-\u{27BF}\u{FE0F}]',
      unicode: true,
    );
    final selfTalk = RegExp(
      r'\b(oops|error\s*[:#]|errno|exception|null|undefined)\b',
      caseSensitive: false,
    );

    for (final language in AppLanguage.values) {
      test('no system-state string shouts, codes or emotes (${language.code})', () {
        for (final entry in _systemCopy(stringsFor(language), language).entries) {
          expect(
            entry.value,
            isNot(matches(statusCode)),
            reason: '${entry.key} carries what looks like a status code',
          );
          expect(
            entry.value,
            isNot(matches(shouting)),
            reason: '${entry.key} carries an exclamation mark',
          );
          expect(
            entry.value,
            isNot(matches(emoji)),
            reason: '${entry.key} carries an emoji',
          );
          expect(
            entry.value,
            isNot(matches(selfTalk)),
            reason: '${entry.key} speaks to the developer, not the user',
          );
        }
      });
    }

    test('every state says what survived', () {
      // "Your answers are saved" wherever true — the sentence that turns a
      // failure from frightening into merely annoying.
      const reassuring = [
        'Your saved work is safe on this device. Try again in a moment.',
        'Something went wrong on our side. Nothing you saved is affected.',
        "Please sign in again. You'll come straight back — nothing is lost.",
        'We are back shortly. Nothing you saved is affected.',
        "We couldn't do that just now. Nothing you entered is lost.",
      ];
      final bodies = [
        en.errBody,
        en.errServer,
        FailureCopy.sessionExpired.resolve(AppLanguage.en),
        en.sysMaintenanceBody,
        en.errGeneric,
      ];
      expect(bodies, reassuring);
    });
  });
}

// --- The ten states -----------------------------------------------------------

typedef _StateCase = ({
  String name,
  String Function(EjadahStrings) title,
  Widget Function(_Probe probe) build,

  /// The path the primary action lands on, or null when it fires an injected
  /// callback instead.
  String? route,
});

final List<_StateCase> _cases = [
  (
    name: 'offline',
    title: (s) => s.sysOfflineTitle,
    build: (probe) => OfflineScreen(onRetry: probe.fire),
    route: null,
  ),
  (
    name: 'server error',
    title: (s) => FailureCopy.errorTitle.resolve(_languageOf(s)),
    build: (probe) => ServerErrorScreen(onRetry: probe.fire),
    route: null,
  ),
  (
    name: 'session expired',
    title: (s) => s.sysSessionExpiredTitle,
    build: (probe) => const SessionExpiredScreen(),
    route: '/sign-in',
  ),
  (
    name: 'force update',
    title: (s) => s.sysForceUpdateTitle,
    build: (probe) => ForceUpdateScreen(onUpdate: probe.fire),
    route: null,
  ),
  (
    name: 'maintenance',
    title: (s) => s.sysMaintenanceTitle,
    build: (probe) => MaintenanceScreen(onRetry: probe.fire),
    route: null,
  ),
  (
    name: 'notification permission denied',
    title: (s) => s.sysNotifDeniedTitle,
    build: (probe) =>
        NotificationPermissionDeniedScreen(onOpenSettings: probe.fire),
    route: null,
  ),
  (
    name: 'camera permission denied',
    title: (s) => s.sysCameraDeniedTitle,
    build: (probe) => CameraPermissionDeniedScreen(onOpenSettings: probe.fire),
    route: null,
  ),
  (
    name: 'error boundary',
    title: (s) => s.sysErrorBoundaryTitle,
    build: (probe) => ErrorBoundaryScreen(onRetry: probe.fire),
    route: '/home',
  ),
  (
    name: 'content unavailable',
    title: (s) => FailureCopy.errorTitle.resolve(_languageOf(s)),
    build: (probe) => const ContentUnavailableScreen(),
    route: '/programmes',
  ),
  (
    name: 'rate limited',
    title: (s) => s.sysRateLimitedTitle,
    build: (probe) => RateLimitedScreen(onRetry: probe.fire),
    route: null,
  ),
];

AppLanguage _languageOf(EjadahStrings strings) =>
    AppLanguage.fromCode(strings.localeName);

/// Every string the ten states can show, keyed for a readable failure message.
Map<String, String> _systemCopy(EjadahStrings s, AppLanguage language) => {
  'sysOfflineTitle': s.sysOfflineTitle,
  'errBody': s.errBody,
  'errServer': s.errServer,
  'errGeneric': s.errGeneric,
  'errTitle': s.errTitle,
  'sysSessionExpiredTitle': s.sysSessionExpiredTitle,
  'sysForceUpdateTitle': s.sysForceUpdateTitle,
  'sysForceUpdateBody': s.sysForceUpdateBody,
  'sysUpdateAction': s.sysUpdateAction,
  'sysMaintenanceTitle': s.sysMaintenanceTitle,
  'sysMaintenanceBody': s.sysMaintenanceBody,
  'sysNotifDeniedTitle': s.sysNotifDeniedTitle,
  'sysNotifDeniedBody': s.sysNotifDeniedBody,
  'sysCameraDeniedTitle': s.sysCameraDeniedTitle,
  'sysCameraDeniedBody': s.sysCameraDeniedBody,
  'sysOpenSettings': s.sysOpenSettings,
  'sysErrorBoundaryTitle': s.sysErrorBoundaryTitle,
  'sysRateLimitedTitle': s.sysRateLimitedTitle,
  'contentUnavailableBody': s.contentUnavailableBody,
  'offlineBanner': s.offlineBanner,
  'retry': s.retry,
  'backHome': s.backHome,
  'browseProgrammes': s.browseProgrammes,
  'signIn': s.signIn,
  'maybeLater': s.maybeLater,
  'FailureCopy.errorTitle': FailureCopy.errorTitle.resolve(language),
  'FailureCopy.sessionExpired': FailureCopy.sessionExpired.resolve(language),
  'FailureCopy.rateLimited': FailureCopy.rateLimited.resolve(language),
  'FailureCopy.contentUnavailable': FailureCopy.contentUnavailable.resolve(
    language,
  ),
  'FailureCopy.server': FailureCopy.server.resolve(language),
  'FailureCopy.generic': FailureCopy.generic.resolve(language),
  'FailureCopy.offline': FailureCopy.offline.resolve(language),
};

// --- Harness ------------------------------------------------------------------

class _Probe {
  int fired = 0;

  void fire() => fired++;
}

/// A widget that fails during build, the way a real one does when the data
/// underneath it is not the shape the screen assumed.
class _Bomb extends StatelessWidget {
  const _Bomb();

  @override
  Widget build(BuildContext context) => throw StateError('the subtree failed');
}

/// Pumps [screen] inside a router carrying the three real destinations the
/// system states route to, so "routes to action" is proved rather than assumed.
Future<GoRouter> _pumpState(
  WidgetTester tester, {
  required Widget screen,
  AppLanguage language = AppLanguage.ar,
  double textScale = 1,
}) async {
  final router = GoRouter(
    initialLocation: '/state',
    routes: [
      GoRoute(path: '/state', builder: (_, _) => screen),
      GoRoute(path: '/home', builder: (_, _) => const _Destination('home')),
      GoRoute(
        path: '/programmes',
        builder: (_, _) => const _Destination('programmes'),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (_, _) => const _Destination('sign-in'),
      ),
    ],
  );

  await tester.pumpWidget(
    _App(language: language, textScale: textScale, router: router),
  );
  await tester.pumpAndSettle();
  return router;
}

/// The app frame: locale, direction, theme and text scale, as `EjadahApp` sets
/// them up.
class _App extends StatelessWidget {
  const _App({
    required this.language,
    this.router,
    this.child,
    this.textScale = 1,
  });

  final AppLanguage language;
  final GoRouter? router;
  final Widget? child;
  final double textScale;

  Widget _wrap(BuildContext context, Widget? content) => Directionality(
    textDirection: language.isRtl ? TextDirection.rtl : TextDirection.ltr,
    child: MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: content ?? const SizedBox.shrink(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = buildEjadahTheme(
      language: language,
      windowClass: EjadahWindowClass.compact,
    );

    if (router case final router?) {
      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        locale: Locale(language.code),
        supportedLocales: ejadahSupportedLocales,
        localizationsDelegates: EjadahStrings.localizationsDelegates,
        theme: theme,
        builder: _wrap,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(language.code),
      supportedLocales: ejadahSupportedLocales,
      localizationsDelegates: EjadahStrings.localizationsDelegates,
      theme: theme,
      home: child,
      builder: _wrap,
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(name));
}
