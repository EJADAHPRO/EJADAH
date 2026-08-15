import 'package:ejadah_models/ejadah_models.dart';

import '../../observability/logger.dart';
import '../career/career_repository.dart';
import '../people/people_repository.dart';
import '../roadmap/roadmap_repository.dart';

/// Which Home a persona sees.
///
/// The CTA is the whole point of the distinction — a specialist must never be
/// shown an emigration call to action, and a student's roadmap branch must not
/// produce an emigration route. Deriving the persona on the server keeps that
/// rule in one place rather than in six `if`s across the widget tree.
enum HomePersona {
  student('student'),
  freshGraduate('fresh_graduate'),
  generalDentist('general_dentist'),
  specialist('specialist'),
  consultantOwner('consultant_owner'),

  /// An approved tutor, mentor or consultant. Supply-side Home differs from
  /// every demand-side one.
  supply('supply');

  const HomePersona(this.wire);

  final String wire;

  static HomePersona forUser(AuthUser user) {
    if (user.isApprovedProfessional) return HomePersona.supply;
    return switch (user.stage) {
      CareerStage.student => HomePersona.student,
      CareerStage.freshGraduate => HomePersona.freshGraduate,
      CareerStage.generalDentist => HomePersona.generalDentist,
      CareerStage.specialist => HomePersona.specialist,
      CareerStage.consultantOwner => HomePersona.consultantOwner,
    };
  }

  /// Whether this persona is ever shown a route-abroad call to action.
  ///
  /// A specialist's goal is standing and being found; a consultant's is clinic
  /// problems. Neither asked about emigrating.
  bool get seesEmigrationCta =>
      this == HomePersona.freshGraduate ||
      this == HomePersona.generalDentist ||
      this == HomePersona.student;
}

/// Which section leads the feed for this persona.
enum HomePrimaryAction {
  /// Student — term plan and cards due.
  studyPlan('study_plan'),

  /// Fresh graduate — build the roadmap. The highest-intent conversion.
  buildRoadmap('build_roadmap'),

  /// GP dentist — the roadmap they already have, and its next stage.
  continueRoadmap('continue_roadmap'),

  /// Specialist — set up the professional card.
  setUpCard('set_up_card'),

  /// Consultant or owner — the consulting door.
  findConsulting('find_consulting'),

  /// Supply — today's teaching.
  teachingDashboard('teaching_dashboard');

  const HomePrimaryAction(this.wire);

  final String wire;
}

/// One section of the feed, with its own load outcome.
///
/// Home is the only screen where partial data is a designed state: if the tutor
/// rail fails, the rest of the feed is still correct and still useful, and the
/// screen says so rather than throwing the whole page away. Every other screen
/// fails a section to its error state.
class HomeSection<T> {
  const HomeSection.loaded(this.data) : failed = false;

  const HomeSection.failed() : data = null, failed = true;

  final T? data;
  final bool failed;

  bool get hasData => data != null && !failed;
}

/// The assembled Home feed.
class HomeFeed {
  const HomeFeed({
    required this.persona,
    required this.primaryAction,
    required this.displayName,
    required this.roadmap,
    required this.deadlines,
    required this.upcomingBooking,
    required this.openProgrammeCount,
    required this.savedCount,
    required this.failedSections,
    required this.isFirstRun,
  });

  final HomePersona persona;
  final HomePrimaryAction primaryAction;
  final LocalizedText displayName;

  /// The user's most recent saved roadmap, if any. Drives whether the CTA is
  /// "build" or "continue".
  final Roadmap? roadmap;

  /// Saved programmes with a live deadline, most urgent first.
  final List<ProgrammeSummary> deadlines;
  final Booking? upcomingBooking;

  /// Quoted by the empty state: "…17 are open right now."
  final int openProgrammeCount;
  final int savedCount;

  /// Names the sections that failed, so the UI can show the partial-data
  /// treatment on exactly those and leave the rest alone.
  final List<String> failedSections;

  /// A user with no saved work and no roadmap sees the first-use feed.
  final bool isFirstRun;

  Map<String, dynamic> toJson() => {
    'persona': persona.wire,
    'primary_action': primaryAction.wire,
    'display_name': displayName.toJson(),
    'roadmap': roadmap?.toJson(),
    'deadlines': deadlines.map((item) => item.toJson()).toList(),
    'upcoming_booking': upcomingBooking?.toJson(),
    'open_programme_count': openProgrammeCount,
    'saved_count': savedCount,
    'failed_sections': failedSections,
    'is_first_run': isFirstRun,
  };
}

/// Assembles the Home feed.
///
/// Each section is fetched independently and a failure is recorded rather than
/// thrown, because Home's contract is that a broken section degrades to a note
/// while the rest of the feed still renders.
class HomeService {
  HomeService({
    required CareerRepository career,
    required RoadmapRepository roadmaps,
    required PeopleRepository people,
    required AppLogger logger,
  }) : _career = career,
       _roadmaps = roadmaps,
       _people = people,
       _logger = logger;

  final CareerRepository _career;
  final RoadmapRepository _roadmaps;
  final PeopleRepository _people;
  final AppLogger _logger;

  /// How many deadline rows the strip shows before "see all".
  static const int deadlineStripLimit = 4;

  Future<HomeFeed> feed(AuthUser user) async {
    final failed = <String>[];

    final roadmaps = await _section(
      'roadmap',
      failed,
      () => _roadmaps.listRoadmaps(user.id),
    );
    final deadlines = await _section(
      'deadlines',
      failed,
      () => _career.savedProgrammes(user.id),
    );
    final bookings = await _section(
      'bookings',
      failed,
      () => _people.bookingsForUser(user.id),
    );
    final openCount = await _section(
      'counts',
      failed,
      _career.countOpenProgrammes,
    );

    final roadmap = (roadmaps ?? const <Roadmap>[]).firstOrNull;
    final saved = deadlines ?? const <ProgrammeSummary>[];
    final persona = HomePersona.forUser(user);

    return HomeFeed(
      persona: persona,
      primaryAction: _primaryActionFor(persona, hasRoadmap: roadmap != null),
      displayName: user.fullName,
      roadmap: roadmap,
      // Expired intakes are not a deadline to watch; the shortlist still shows
      // them, but the Home strip is about what is still actionable.
      deadlines: saved
          .where((item) => item.deadlineStatus != DeadlineStatus.expired)
          .take(deadlineStripLimit)
          .toList(),
      upcomingBooking: _nextBooking(bookings ?? const []),
      openProgrammeCount: openCount ?? 0,
      savedCount: saved.length,
      failedSections: failed,
      isFirstRun: roadmap == null && saved.isEmpty,
    );
  }

  /// The CTA the persona's goal actually implies.
  HomePrimaryAction _primaryActionFor(
    HomePersona persona, {
    required bool hasRoadmap,
  }) => switch (persona) {
    HomePersona.supply => HomePrimaryAction.teachingDashboard,
    HomePersona.student => HomePrimaryAction.studyPlan,
    // A specialist is never shown the emigration CTA, roadmap or not.
    HomePersona.specialist => HomePrimaryAction.setUpCard,
    HomePersona.consultantOwner => HomePrimaryAction.findConsulting,
    // Build it, or carry on with the one they have.
    HomePersona.freshGraduate ||
    HomePersona.generalDentist => hasRoadmap
        ? HomePrimaryAction.continueRoadmap
        : HomePrimaryAction.buildRoadmap,
  };

  /// The soonest confirmed session that has not happened yet.
  Booking? _nextBooking(List<Booking> bookings) {
    final upcoming =
        bookings
            .where((booking) => booking.status == BookingStatus.confirmed)
            .where((booking) {
              final start = booking.firstSessionStart;
              return start != null && start.isAfter(DateTime.now().toUtc());
            })
            .toList()
          ..sort(
            (a, b) => a.firstSessionStart!.compareTo(b.firstSessionStart!),
          );
    return upcoming.firstOrNull;
  }

  /// Runs one section, recording rather than propagating a failure.
  Future<T?> _section<T>(
    String name,
    List<String> failed,
    Future<T> Function() load,
  ) async {
    try {
      return await load();
    } catch (error, stackTrace) {
      // The user still gets the rest of their feed; the section says it did not
      // load, and the rest is stated to be up to date.
      _logger.error(
        'home section failed',
        {'section': name},
        error,
        stackTrace,
      );
      failed.add(name);
      return null;
    }
  }
}
