import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/people_repository.dart';

/// What a professional's profile is showing.
sealed class ProfessionalProfileState {
  const ProfessionalProfileState();
}

class ProfessionalProfileLoading extends ProfessionalProfileState {
  const ProfessionalProfileLoading();
}

class ProfessionalProfileReady extends ProfessionalProfileState {
  const ProfessionalProfileReady({
    required this.profile,
    required this.availability,
    this.availabilityFailed = false,
  });

  final ProfessionalProfile profile;

  /// The next week, as a preview. The full grid lives in the booking flow.
  final List<AvailabilitySlot> availability;

  /// The profile loaded but the preview did not. The preview says so and the
  /// rest of the page stays correct — nothing here is guessed.
  final bool availabilityFailed;

  Professional get professional => profile.professional;

  List<AvailabilitySlot> get openSlots =>
      availability.where((slot) => slot.isAvailable).toList();
}

class ProfessionalProfileFailed extends ProfessionalProfileState {
  const ProfessionalProfileFailed(this.failure);

  final Failure failure;
}

final professionalProfileControllerProvider = NotifierProvider.family<
  ProfessionalProfileController,
  ProfessionalProfileState,
  String
>(ProfessionalProfileController.new);

/// Owns one profile, keyed by slug — the slug is what a shared link carries.
class ProfessionalProfileController
    extends FamilyNotifier<ProfessionalProfileState, String> {
  @override
  ProfessionalProfileState build(String arg) {
    Future.microtask(load);
    return const ProfessionalProfileLoading();
  }

  Future<void> load() async {
    state = const ProfessionalProfileLoading();
    final repository = ref.read(peopleRepositoryProvider);

    try {
      final profile = await repository.profile(arg);

      // The availability preview is fetched separately and is allowed to fail
      // on its own: a profile whose calendar is briefly unreachable is still
      // worth reading, and the preview states that it did not load.
      final from = DateTime.now().toUtc();
      try {
        state = ProfessionalProfileReady(
          profile: profile,
          availability: await repository.availability(
            professionalId: profile.professional.id,
            from: from,
            to: from.add(const Duration(days: 7)),
          ),
        );
      } on Failure {
        state = ProfessionalProfileReady(
          profile: profile,
          availability: const [],
          availabilityFailed: true,
        );
      }
    } on Failure catch (failure) {
      state = ProfessionalProfileFailed(failure);
    }
  }

  Future<void> retry() => load();
}
