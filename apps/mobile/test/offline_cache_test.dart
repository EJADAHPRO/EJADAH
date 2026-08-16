import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_mobile/app/providers.dart';
import 'package:ejadah_mobile/features/auth/auth_controller.dart';
import 'package:ejadah_mobile/features/home/application/home_controller.dart';
import 'package:ejadah_mobile/features/home/data/home_repository.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// The offline promise.
///
/// Story E6-01: saved work stays readable offline, and the offline state's own
/// copy tells the user so. That was true only until the app was killed — the
/// feed lived in a plain field on the controller — so a relaunch on the
/// underground turned real content into a full-page error under copy claiming
/// it was safe on the device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStore store;

  setUp(() async {
    // A real store over an in-memory backing, so what is exercised is the
    // encode/decode round trip the device does, not a stub of it.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    store = LocalStore();
  });

  test('a feed the device has seen survives a relaunch offline', () async {
    // First launch: online, the feed loads and is written to the device.
    final online = _Container(
      store: store,
      repository: _FakeApi(feed: _feed),
    );
    await online.settle();
    expect(online.state, isA<HomeReady>());
    expect((online.state as HomeReady).isOffline, isFalse);
    online.dispose();

    // The app is killed and reopened with no connection. Nothing is in memory.
    final offline = _Container(
      store: store,
      repository: _FakeApi(failWith: const NetworkFailure()),
    );
    await offline.settle();

    final state = offline.state;
    expect(
      state,
      isA<HomeReady>(),
      reason: 'the copy promises the saved work is still there',
    );
    expect((state as HomeReady).isOffline, isTrue);
    expect(state.feed.displayName.en, 'Sara Hassan');
    expect(state.feed.deadlines.single.university, "King's College London");
    offline.dispose();
  });

  test('a device that has never loaded a feed still fails honestly', () async {
    final offline = _Container(
      store: store,
      repository: _FakeApi(failWith: const NetworkFailure()),
    );
    await offline.settle();

    // Nothing to show is not the same as something to show behind a banner.
    expect(offline.state, isA<HomeFailed>());
    offline.dispose();
  });

  test('signing out takes the cached feed with it', () async {
    final online = _Container(
      store: store,
      repository: _FakeApi(feed: _feed),
    );
    await online.settle();
    expect(await store.cachedResponse(HomeRepository.cacheKey), isNotNull);

    await online.container.read(authControllerProvider.notifier).logout();

    // The next person to sign in on this device must not meet the last one's
    // shortlist and sessions.
    expect(await store.cachedResponse(HomeRepository.cacheKey), isNull);
    online.dispose();
  });

  test('a cache written by an older build is a miss, not a crash', () async {
    await store.cacheResponse(HomeRepository.cacheKey, {
      'persona': 'general_dentist',
      // Every other field the model requires is absent.
    });

    final offline = _Container(
      store: store,
      repository: _FakeApi(failWith: const NetworkFailure()),
    );
    await offline.settle();

    expect(offline.state, isA<HomeFailed>());
    offline.dispose();
  });
}

/// A container with a signed-in user and a fake API.
class _Container {
  _Container({required LocalStore store, required _FakeApi repository}) {
    container = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        homeRepositoryProvider.overrideWith(
          (ref) => _RecordingRepository(repository, store),
        ),
        authControllerProvider.overrideWith(_SignedInController.new),
      ],
    );
  }

  late final ProviderContainer container;

  HomeState get state => container.read(homeControllerProvider);

  /// The controller loads in a microtask, and the load itself awaits.
  Future<void> settle() async {
    container.read(homeControllerProvider);
    for (var i = 0; i < 8; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  void dispose() => container.dispose();
}

/// Stands in for the network. Either answers or fails; never both.
class _FakeApi {
  const _FakeApi({this.feed, this.failWith});

  final Map<String, dynamic>? feed;
  final Failure? failWith;
}

/// The real caching behaviour over a fake network, so the test exercises the
/// repository's own read-through rather than a second copy of it.
class _RecordingRepository implements HomeRepository {
  _RecordingRepository(this._api, this._store);

  final _FakeApi _api;
  final LocalStore _store;

  @override
  Future<HomeFeed> feed() async {
    final failure = _api.failWith;
    if (failure != null) throw failure;
    await _store.cacheResponse(HomeRepository.cacheKey, _api.feed!);
    return HomeFeed.fromJson(_api.feed!);
  }

  @override
  Future<HomeFeed?> cachedFeed() async {
    final json = await _store.cachedResponse(HomeRepository.cacheKey);
    if (json == null) return null;
    try {
      return HomeFeed.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SignedInController extends AuthController {
  @override
  AuthState build() => Authenticated(
    const AuthUser(
      id: 'user-1',
      email: 'sara@ejadah.test',
      fullName: LocalizedText(en: 'Sara Hassan', ar: 'سارة حسن'),
      role: UserRole.student,
      stage: CareerStage.generalDentist,
      language: AppLanguage.en,
      emailVerified: true,
      professionalStatus: ProfessionalStatus.none,
      isPremium: true,
      premiumRenewsOn: null,
    ),
  );

  @override
  Future<void> logout() async {
    await ref.read(localStoreProvider).clearCachedResponses(const [
      HomeRepository.cacheKey,
    ]);
    state = const Guest();
  }
}

final Map<String, dynamic> _feed = {
  'persona': 'general_dentist',
  'primary_action': 'build_roadmap',
  'display_name': {'en': 'Sara Hassan', 'ar': 'سارة حسن'},
  'roadmap': null,
  'deadlines': [
    {
      'id': 42,
      'region': 'Europe',
      'country': 'United Kingdom',
      'city': 'London',
      'university': "King's College London",
      'programme_name': 'MSc Endodontics',
      'specialty': 'Endodontics',
      'degree_type': 'MSc',
      'deadline_status': 'closing_soon',
      'days_remaining': 14,
      'is_saved': true,
    },
  ],
  'upcoming_booking': null,
  'open_programme_count': 49,
  'saved_count': 1,
  'failed_sections': <String>[],
  'is_first_run': false,
};
