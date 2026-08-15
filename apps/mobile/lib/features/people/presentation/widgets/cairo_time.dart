import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Times, in Cairo.
///
/// Every professional's calendar and every session is quoted in Cairo time, in
/// both languages, and every screen that shows one says so — a booking a user
/// reads in their own device's zone and attends in Cairo's is the single most
/// expensive misunderstanding this product can cause.
///
/// The offset is fixed at GMT+2, which is what the product's own copy states
/// ("Times shown in Cairo time (GMT+2)"). It is deliberately not the device
/// zone, and deliberately not a full tz database: a formatting helper is the
/// wrong place to acquire one, and the string table has already committed to
/// this wording.
abstract final class CairoTime {
  static const Duration offset = Duration(hours: 2);

  static DateTime of(DateTime utc) => utc.toUtc().add(offset);

  /// "7:00 pm" — Western digits in both languages, always rendered inside an
  /// LTR island by the widget that shows it.
  static String time(DateTime utc) => DateFormat.jm('en').format(of(utc));

  /// "Sun 18 Aug".
  static String dayLabel(DateTime utc) =>
      DateFormat('EEE d MMM', 'en').format(of(utc));

  /// "Sunday 18 August".
  static String longDayLabel(DateTime utc) =>
      DateFormat('EEEE d MMMM', 'en').format(of(utc));

  /// "Sun 18 Aug · 7:00 pm".
  static String stamp(DateTime utc) => '${dayLabel(utc)} · ${time(utc)}';

  /// Whether two instants fall on the same Cairo day.
  static bool sameDay(DateTime a, DateTime b) {
    final left = of(a);
    final right = of(b);
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

/// A time, code or date rendered as an LTR island in the ambient type style.
///
/// Dates and clock times are Latin-context runs exactly like currency and exam
/// codes; letting the bidi algorithm resolve "7:00 pm" against an Arabic
/// paragraph is what produces the classic reversed-time bug.
class TimeText extends StatelessWidget {
  const TimeText(this.text, {this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) =>
      LtrIsland(child: Text(text, style: style ?? context.type.tabular()));
}
