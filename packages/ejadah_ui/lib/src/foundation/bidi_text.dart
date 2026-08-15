import 'package:flutter/widgets.dart';

import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// A run of text that must always read left-to-right, even inside Arabic.
///
/// Arabic pages are full of Latin islands — exam codes, regulators, currency,
/// dates, percentages, reference codes — and letting the bidi algorithm resolve
/// them against a right-to-left paragraph reorders them wrongly: "EGP 1,400"
/// becomes "1,400 EGP", "12–24" flips its endpoints, and "ORE Part 1" loses its
/// number to the wrong side.
///
/// Wrapping the run in an explicit [Directionality] is the fix, and doing it
/// through these widgets means no string ever needs embedded Unicode control
/// characters — which would otherwise leak into search, sorting and analytics.
class LtrIsland extends StatelessWidget {
  const LtrIsland({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Directionality(textDirection: TextDirection.ltr, child: child);
}

/// A currency amount: code plus Western digits, as one island.
///
/// "EGP 1,400" and "USD 3,000" are single units — splitting the code from the
/// figure across a bidi boundary is what produces the classic reversed-price
/// bug on Arabic screens.
class CurrencyText extends StatelessWidget {
  const CurrencyText({
    required this.amount,
    required this.currency,
    this.style,
    this.approximateUsd,
    super.key,
  });

  final int amount;

  /// Always a code — never a symbol.
  final String currency;
  final TextStyle? style;

  /// Rendered inside the same island: "EGP 1,400 (≈ $327)".
  final int? approximateUsd;

  @override
  Widget build(BuildContext context) {
    final text = StringBuffer('$currency ${formatThousands(amount)}');
    if (approximateUsd != null) {
      text.write(' (≈ \$${formatThousands(approximateUsd!)})');
    }
    return LtrIsland(
      child: Text(text.toString(), style: style ?? context.type.tabular()),
    );
  }
}

/// A Latin code that is never transliterated or mirrored.
///
/// ORE · ADC · NDEB · INBDE · SDLE · DHA · DOH · MOHAP · SCFHS · QCHP · NHRA ·
/// GDC · Prometric · Pearson VUE · DataFlow · IELTS · exocad · 3Shape — these
/// stay Latin in both languages, by name, because that is how the regulators
/// and the exams are actually written.
class CodeText extends StatelessWidget {
  const CodeText(this.code, {this.style, super.key});

  final String code;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) =>
      LtrIsland(child: Text(code, style: style ?? context.type.bodyStrong()));
}

/// A numeric range, e.g. "12–24". Endpoints must not swap in Arabic.
class RangeText extends StatelessWidget {
  const RangeText({
    required this.from,
    required this.to,
    this.suffix,
    this.style,
    super.key,
  });

  final int from;
  final int to;

  /// A localized unit that reads outside the island, e.g. "months".
  final String? suffix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? context.type.tabular();
    final range = LtrIsland(
      child: Text(from == to ? '$from' : '$from–$to', style: resolved),
    );
    if (suffix == null) return range;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        range,
        const SizedBox(width: EjadahSpacing.xxs),
        Text(suffix!, style: resolved),
      ],
    );
  }
}

/// Groups thousands with a comma, in Western digits.
///
/// Western numerals are used in **both** languages, always — never
/// Arabic-Indic, never mixed. Exam codes and fees are Latin-context, and mixing
/// numeral systems breaks scanning.
String formatThousands(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '−$buffer' : buffer.toString();
}
