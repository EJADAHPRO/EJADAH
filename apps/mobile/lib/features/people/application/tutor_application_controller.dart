import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tutor_application_repository.dart';

/// How the last save went.
///
/// Shown as a quiet "Saved" rather than a toast per step: the promise the flow
/// makes is that nothing is lost, and the user needs to be able to *see* that
/// promise being kept without being interrupted six times.
enum SaveState { idle, saving, saved, failed }

/// What the application screen is showing.
sealed class TutorApplicationState {
  const TutorApplicationState();
}

class TutorApplicationLoading extends TutorApplicationState {
  const TutorApplicationLoading();
}

class TutorApplicationFailed extends TutorApplicationState {
  const TutorApplicationFailed(this.failure);

  final Failure failure;
}

class TutorApplicationReady extends TutorApplicationState {
  const TutorApplicationReady({
    required this.snapshot,
    this.step = ApplicationStep.basics,
    this.onReview = false,
    this.saveState = SaveState.idle,
    this.submitting = false,
    this.saveFailure,
  });

  final TutorApplicationSnapshot snapshot;

  /// Which of the six the user is on.
  final ApplicationStep step;

  /// The seventh screen: everything is answered, or it names what is not.
  final bool onReview;
  final SaveState saveState;
  final bool submitting;

  /// Why the last draft save failed. A step that did not save must say so —
  /// silently discarding an answer is the failure this whole feature guards
  /// against.
  final Failure? saveFailure;

  TutorApplication? get application => snapshot.application;

  List<MissingItem> get missing => snapshot.missing;

  bool get canSubmit => snapshot.hasStarted && missing.isEmpty;

  ProfessionalStatus get status =>
      application?.status ?? ProfessionalStatus.draft;

  /// Whether the form accepts edits at all. An application under review is not
  /// a document to keep editing; a rejected one is.
  bool get isEditable => application?.isEditable ?? true;

  Map<String, dynamic> answersFor(ApplicationStep step) =>
      application?.answersFor(step) ?? const {};

  List<MissingItem> missingIn(ApplicationStep step) =>
      missing.where((item) => item.step == step).toList();

  TutorApplicationReady copyWith({
    TutorApplicationSnapshot? snapshot,
    ApplicationStep? step,
    bool? onReview,
    SaveState? saveState,
    bool? submitting,
    Failure? saveFailure,
    bool clearSaveFailure = false,
  }) => TutorApplicationReady(
    snapshot: snapshot ?? this.snapshot,
    step: step ?? this.step,
    onReview: onReview ?? this.onReview,
    saveState: saveState ?? this.saveState,
    submitting: submitting ?? this.submitting,
    saveFailure: clearSaveFailure ? null : (saveFailure ?? this.saveFailure),
  );
}

final tutorApplicationControllerProvider =
    NotifierProvider<TutorApplicationController, TutorApplicationState>(
      TutorApplicationController.new,
    );

/// The six-step application.
///
/// Two rules from the flow live here and nowhere else:
///
/// * **every step is draft-saved.** [saveStep] runs on leaving a step, and the
///   server merges rather than replaces, so closing the app at step 4 loses
///   nothing;
/// * **submit names every missing item at once.** [missing] is refreshed from
///   the server on every save, so the review screen can list them before the
///   tap rather than revealing them one at a time after it.
class TutorApplicationController extends Notifier<TutorApplicationState> {
  @override
  TutorApplicationState build() {
    Future.microtask(load);
    return const TutorApplicationLoading();
  }

  TutorApplicationRepository get _repository =>
      ref.read(tutorApplicationRepositoryProvider);

  Future<void> load() async {
    state = const TutorApplicationLoading();
    try {
      final snapshot = await _repository.snapshot();
      state = TutorApplicationReady(
        snapshot: snapshot,
        // Resumes where the draft was left rather than at step 1 — the whole
        // point of saving each step is not having to walk back through them.
        step: _resumeStep(snapshot),
      );
    } on Failure catch (failure) {
      state = TutorApplicationFailed(failure);
    }
  }

  Future<void> retry() => load();

  void goTo(ApplicationStep step) {
    final current = state;
    if (current is! TutorApplicationReady) return;
    state = current.copyWith(
      step: step,
      onReview: false,
      saveState: SaveState.idle,
      clearSaveFailure: true,
    );
  }

  void goToReview() {
    final current = state;
    if (current is! TutorApplicationReady) return;
    state = current.copyWith(onReview: true, saveState: SaveState.idle);
  }

  /// Saves one step and stays where it is.
  ///
  /// Returns false when the save failed, so a caller advancing to the next step
  /// can refuse to move — walking someone forward past an answer that did not
  /// reach the server is how a six-step form quietly loses step 4.
  Future<bool> saveStep(
    ApplicationStep step,
    Map<String, dynamic> answers,
  ) async {
    final current = state;
    if (current is! TutorApplicationReady) return false;
    if (!current.isEditable) return false;

    state = current.copyWith(
      saveState: SaveState.saving,
      clearSaveFailure: true,
    );
    try {
      await _repository.saveStep(step: step, answers: answers);
      // Re-read rather than patching locally: the missing list is computed by
      // the server, and a locally guessed one could disagree with the server
      // that decides whether submit is allowed.
      final snapshot = await _repository.snapshot();
      state = current.copyWith(snapshot: snapshot, saveState: SaveState.saved);
      return true;
    } on Failure catch (failure) {
      state = current.copyWith(
        saveState: SaveState.failed,
        saveFailure: failure,
      );
      return false;
    }
  }

  /// Saves the current step and moves on, review included.
  Future<void> saveAndAdvance(
    ApplicationStep step,
    Map<String, dynamic> answers,
  ) async {
    if (!await saveStep(step, answers)) return;
    final current = state;
    if (current is! TutorApplicationReady) return;

    final next = ApplicationStep.fromPosition(step.position + 1);
    state = current.copyWith(
      step: next ?? step,
      onReview: next == null,
      saveState: SaveState.saved,
    );
  }

  /// Sends for review.
  ///
  /// A refusal arrives as a [ValidationFailure] carrying every missing item; it
  /// is folded back into [TutorApplicationReady.missing] so the screen lists
  /// them rather than showing a single message.
  Future<bool> submit() async {
    final current = state;
    if (current is! TutorApplicationReady) return false;

    state = current.copyWith(submitting: true);
    try {
      await _repository.submit();
      state = TutorApplicationReady(snapshot: await _repository.snapshot());
      return true;
    } on Failure catch (failure) {
      // Even on an unexpected refusal the live list is re-read, so the screen
      // never sits on a stale "nothing missing" while submit keeps failing.
      final snapshot = await _refreshQuietly(current.snapshot);
      state = current.copyWith(
        snapshot: snapshot,
        submitting: false,
        onReview: true,
        saveFailure: failure,
      );
      return false;
    }
  }

  Future<TutorApplicationSnapshot> _refreshQuietly(
    TutorApplicationSnapshot fallback,
  ) async {
    try {
      return await _repository.snapshot();
    } on Failure {
      return fallback;
    }
  }

  static ApplicationStep _resumeStep(TutorApplicationSnapshot snapshot) {
    final application = snapshot.application;
    if (application == null) return ApplicationStep.basics;
    return ApplicationStep.fromPosition(application.lastStep) ??
        ApplicationStep.basics;
  }
}

/// The three actions after approval.
final playbookControllerProvider =
    AsyncNotifierProvider<PlaybookController, Playbook>(PlaybookController.new);

class PlaybookController extends AsyncNotifier<Playbook> {
  @override
  Future<Playbook> build() =>
      ref.read(tutorApplicationRepositoryProvider).playbook();

  /// Ticks an item.
  ///
  /// Optimistic: the tick lands immediately and the server's answer replaces
  /// it, because a checklist that pauses on every tap reads as broken. A
  /// failure puts the previous state back rather than leaving a tick that was
  /// never recorded.
  Future<void> complete(String item) async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncData(Playbook({...previous.items, item: true}));
    }
    try {
      state = AsyncData(
        await ref
            .read(tutorApplicationRepositoryProvider)
            .completePlaybookItem(item),
      );
    } on Failure catch (failure, stack) {
      if (previous != null) {
        state = AsyncData(previous);
      } else {
        state = AsyncError(failure, stack);
      }
      rethrow;
    }
  }
}
