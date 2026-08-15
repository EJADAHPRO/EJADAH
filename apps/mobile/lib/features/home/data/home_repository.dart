import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// Which persona's Home this is. Mirrors the server enum.
enum HomePersona {
  student,
  freshGraduate,
  generalDentist,
  specialist,
  consultantOwner,
  supply;

  static HomePersona fromWire(String? value) => switch (value) {
    'student' => HomePersona.student,
    'fresh_graduate' => HomePersona.freshGraduate,
    'specialist' => HomePersona.specialist,
    'consultant_owner' => HomePersona.consultantOwner,
    'supply' => HomePersona.supply,
    _ => HomePersona.generalDentist,
  };
}

/// The call to action this persona's goal implies.
///
/// Chosen on the server so the rule — a specialist is never shown an emigration
/// CTA — lives in one place rather than in branches across the widget tree.
enum HomePrimaryAction {
  studyPlan,
  buildRoadmap,
  continueRoadmap,
  setUpCard,
  findConsulting,
  teachingDashboard;

  static HomePrimaryAction fromWire(String? value) => switch (value) {
    'study_plan' => HomePrimaryAction.studyPlan,
    'continue_roadmap' => HomePrimaryAction.continueRoadmap,
    'set_up_card' => HomePrimaryAction.setUpCard,
    'find_consulting' => HomePrimaryAction.findConsulting,
    'teaching_dashboard' => HomePrimaryAction.teachingDashboard,
    _ => HomePrimaryAction.buildRoadmap,
  };
}

/// The assembled feed.
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
  final Roadmap? roadmap;
  final List<ProgrammeSummary> deadlines;
  final Booking? upcomingBooking;
  final int openProgrammeCount;
  final int savedCount;

  /// Sections that failed to load. Home is the only screen where this is a
  /// designed state: those sections show a note and the rest still renders.
  final List<String> failedSections;
  final bool isFirstRun;

  bool sectionFailed(String name) => failedSections.contains(name);

  bool get isPartial => failedSections.isNotEmpty;

  factory HomeFeed.fromJson(Map<String, dynamic> json) => HomeFeed(
    persona: HomePersona.fromWire(json['persona'] as String?),
    primaryAction: HomePrimaryAction.fromWire(json['primary_action'] as String?),
    displayName: LocalizedText.fromJson(json['display_name'])!,
    roadmap: json['roadmap'] == null
        ? null
        : Roadmap.fromJson(Map<String, dynamic>.from(json['roadmap'] as Map)),
    deadlines: (json['deadlines'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              ProgrammeSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    upcomingBooking: json['upcoming_booking'] == null
        ? null
        : Booking.fromJson(
            Map<String, dynamic>.from(json['upcoming_booking'] as Map),
          ),
    openProgrammeCount: (json['open_programme_count'] as num?)?.toInt() ?? 0,
    savedCount: (json['saved_count'] as num?)?.toInt() ?? 0,
    failedSections: (json['failed_sections'] as List<dynamic>? ?? const [])
        .map((s) => s.toString())
        .toList(),
    isFirstRun: json['is_first_run'] == true,
  );
}

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(ref.watch(apiClientProvider)),
);

class HomeRepository {
  const HomeRepository(this._client);

  final ApiClient _client;

  /// One request for the whole feed.
  ///
  /// Seven parallel requests on a cold start on a mid-range Android phone is
  /// exactly what this avoids.
  Future<HomeFeed> feed() => _client.get('/home/', parse: HomeFeed.fromJson);
}
