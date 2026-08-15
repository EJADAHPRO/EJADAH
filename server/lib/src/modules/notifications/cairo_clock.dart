/// Cairo local time, in one place.
///
/// Every user-facing time in this product is stated in Cairo time, and the copy
/// names the zone rather than an offset — deliberately. Egypt reinstated
/// summer time in 2023, so "GMT+2" is wrong for roughly half the year, while
/// "Cairo time" is always true. A reminder that contradicts the screen it links
/// to is worse than no reminder, and so is a screen that contradicts the clock
/// on the user's wall.
///
/// The offset here is fixed at +02:00, which means displayed times run an hour
/// behind during Egyptian summer time. That is a known and recorded gap, not an
/// oversight: closing it is a *data* change — the IANA `Africa/Cairo` rules —
/// applied to [offset] alone, because this is the only place in the server that
/// converts to local time. Nothing else formats one.
///
/// Owner decision, 15 Aug 2026: keep the fixed offset, make the copy honest.
class CairoClock {
  const CairoClock._();

  /// Egypt's standard offset.
  ///
  /// Not DST-aware. See the class comment: this is the one value a timezone
  /// database would replace.
  static const Duration offset = Duration(hours: 2);

  /// The label the copy uses, so server-sent text and screen text agree.
  static const String labelEn = 'Cairo time';
  static const String labelAr = 'بتوقيت القاهرة';

  /// Quiet hours, as promised in `pNotifyWhy`: nothing between 22:00 and 08:00.
  static const int quietStartHour = 22;
  static const int quietEndHour = 8;

  /// The most notifications a user may receive in one Cairo day, as promised in
  /// `pNotifyWhy`: "Two a day maximum".
  static const int dailyCap = 2;

  /// The wall-clock time in Cairo for a UTC instant.
  static DateTime local(DateTime utc) => utc.toUtc().add(offset);

  /// The UTC instant for a Cairo wall-clock time.
  static DateTime toUtc(DateTime cairo) =>
      DateTime.utc(
        cairo.year,
        cairo.month,
        cairo.day,
        cairo.hour,
        cairo.minute,
        cairo.second,
      ).subtract(offset);

  /// 24-hour clock, Western digits in both languages — exam codes and times are
  /// Latin-context, and mixing numeral systems breaks scanning (REGISTER.md).
  static String formatTime(DateTime utc) {
    final at = local(utc);
    return '${at.hour.toString().padLeft(2, '0')}:'
        '${at.minute.toString().padLeft(2, '0')}';
  }

  static bool isQuiet(DateTime utc) {
    final hour = local(utc).hour;
    return hour >= quietStartHour || hour < quietEndHour;
  }

  /// Pushes a send time out of quiet hours, to 08:00 Cairo on the next morning
  /// that follows it.
  ///
  /// A reminder that would land at 02:00 is not dropped — it is held. Dropping
  /// it would silently break the promise the category makes; holding it keeps
  /// both promises at once.
  static DateTime afterQuietHours(DateTime utc) {
    if (!isQuiet(utc)) return utc;
    final at = local(utc);
    // Before 08:00 → this morning. At or after 22:00 → tomorrow morning.
    final morning = at.hour < quietEndHour
        ? DateTime.utc(at.year, at.month, at.day, quietEndHour)
        : DateTime.utc(
            at.year,
            at.month,
            at.day,
            quietEndHour,
          ).add(const Duration(days: 1));
    return morning.subtract(offset);
  }

  /// The Cairo calendar day an instant falls in, as `YYYY-MM-DD`.
  ///
  /// The daily cap is counted in Cairo days, not UTC days, because that is the
  /// day the user is living in.
  static String dayKey(DateTime utc) {
    final at = local(utc);
    return '${at.year.toString().padLeft(4, '0')}-'
        '${at.month.toString().padLeft(2, '0')}-'
        '${at.day.toString().padLeft(2, '0')}';
  }
}
