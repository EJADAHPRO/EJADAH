import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many things may be compared at once.
///
/// Three, matching `CareerService.maxComparisonItems`. The limit is a design
/// decision rather than a technical one: four columns on a phone stop being
/// readable, and the answer to "which of these" gets worse as the list grows.
const int maxComparisonItems = 3;

/// Which programmes are selected for comparison.
///
/// Selection lives above the list because it survives paging, filtering and
/// searching — picking one programme on page 1 and another on page 4 is the
/// normal way this gets used.
final programmeComparisonProvider =
    NotifierProvider<ComparisonController, List<int>>(
      ComparisonController.new,
    );

class ComparisonController extends Notifier<List<int>> {
  @override
  List<int> build() => const [];

  bool get isFull => state.length >= maxComparisonItems;

  bool contains(int id) => state.contains(id);

  /// Adds or removes. Returns false when the selection is already full, so the
  /// caller can say why the tap did nothing rather than leaving it silent.
  bool toggle(int id) {
    if (state.contains(id)) {
      state = state.where((item) => item != id).toList();
      return true;
    }
    if (isFull) return false;
    state = [...state, id];
    return true;
  }

  void clear() => state = const [];
}

/// The same, for country guides, which are keyed by ISO code rather than id.
///
/// A separate set on purpose: comparing a programme against a country is not a
/// question this product answers.
final countryComparisonProvider =
    NotifierProvider<IsoComparisonController, List<String>>(
      IsoComparisonController.new,
    );

class IsoComparisonController extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  bool get isFull => state.length >= maxComparisonItems;

  bool contains(String iso) => state.contains(iso);

  bool toggle(String iso) {
    if (state.contains(iso)) {
      state = state.where((item) => item != iso).toList();
      return true;
    }
    if (isFull) return false;
    state = [...state, iso];
    return true;
  }

  void clear() => state = const [];
}
