import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// A smoke check that the design tokens survived generation.
///
/// The real suites live alongside the code they cover; this file exists so
/// `flutter test` on a fresh clone proves the app package builds at all.
void main() {
  test('the brand gradient carries three stops', () {
    expect(RawTokens.gradientStops.length, 3);
    expect(RawTokens.gradientStops.first, EjadahColors.red);
    expect(RawTokens.gradientStops.last, EjadahColors.gold);
  });

  test('the gradient budget is six', () {
    expect(EjadahGradient.maxPerScreen, 6);
  });
}
