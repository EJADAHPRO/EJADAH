import 'package:ejadah_localization/ejadah_localization.dart';
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
/// The copy names the zone rather than an offset — "Cairo time", never
/// "GMT+2". Egypt reinstated summer time in 2023, so an offset in the copy is
/// wrong for roughly half the year while the zone name is always true.
///
/// The offset here is fixed at +02:00, which means displayed times run an hour
/// behind during Egyptian summer time. That is recorded, not overlooked: it is
/// the same known gap as the server's `CairoClock`, and closing it is a data
/// change — the IANA `Africa/Cairo` rules — applied to [offset] alone. It is
/// deliberately not the device zone: a booking read in the user's own zone and
/// attended in Cairo's is the most expensive misunderstanding this product can
/// cause.
///
/// Owner decision, 15 Aug 2026: keep the fixed offset, make the copy honest.
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

/// The weekday's short name, `0` = Sunday.
///
/// Zero-based from Sunday because that is what `availability_rules` stores and
/// what the booking calendar shows first, in both languages. Two conventions
/// for this one number is how a tutor ends up bookable on the wrong day.
///
/// The name comes from the locale rather than from seven strings of our own:
/// `intl` already knows both languages' day names, and a hand table would be
/// one more thing to keep in step.
String weekdayShortLabel(BuildContext context, int weekday) {
  // 7 January 2024 was a Sunday, so adding `weekday` lands on the right day.
  final day = DateTime(2024, 1, 7 + weekday);
  return DateFormat.E(context.language.code).format(day);
}
