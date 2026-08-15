import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter/widgets.dart';

/// Department names, from the string table.
///
/// Interface copy is never written inline in a widget, so the three department
/// labels resolve through one function rather than being repeated on the hub,
/// the list and the course card.
String departmentLabel(BuildContext context, Department department) =>
    switch (department) {
      Department.orthodontics => context.strings.departmentOrtho,
      Department.digital => context.strings.departmentDigital,
      Department.businessParadental => context.strings.departmentBusiness,
    };

/// "12:34" — minutes and seconds, always left to right.
///
/// Durations are Latin-context: the endpoints of a time must not swap in
/// Arabic, so callers wrap this in an [LtrIsland].
String durationLabel(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return '$minutes:${remainder.toString().padLeft(2, '0')}';
}
