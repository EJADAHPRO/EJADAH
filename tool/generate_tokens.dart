import 'dart:convert';
import 'dart:io';

/// Generates the Dart token constants from the canonical design tokens.
///
///     dart run tool/generate_tokens.dart
///
/// `handoff-flutter/03-design-system/DESIGN_TOKENS.json` is the single source
/// of every visual constant — "raw values are defects". Generating rather than
/// transcribing means a token correction in the handoff cannot silently fail to
/// reach the code, and the generated file is committed so a build never depends
/// on this script having been run.
Future<void> main() async {
  final source = File('handoff-flutter/03-design-system/DESIGN_TOKENS.json');
  final target = File('packages/ejadah_ui/lib/src/tokens/tokens.g.dart');

  final tokens = jsonDecode(source.readAsStringSync()) as Map<String, dynamic>;
  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE — DO NOT EDIT BY HAND.')
    ..writeln('//')
    ..writeln('// Source: ${source.path}')
    ..writeln('// Regenerate: dart run tool/generate_tokens.dart')
    ..writeln('//')
    ..writeln('// Every visual constant in the Ejadah design system resolves to')
    ..writeln('// a value in this file. A raw colour, radius, duration or size')
    ..writeln('// written anywhere else in the codebase is a defect.')
    ..writeln()
    ..writeln("import 'dart:ui';")
    ..writeln()
    ..writeln('/// The canonical Ejadah design tokens.')
    ..writeln('abstract final class RawTokens {');

  final color = tokens['color'] as Map<String, dynamic>;
  buffer.writeln('  // --- Colour ---');
  for (final group in color.entries) {
    if (group.key == 'banned') continue;
    final values = group.value as Map<String, dynamic>;
    for (final entry in values.entries) {
      final name = '${group.key}${_capitalize(entry.key)}';
      buffer.writeln(
        '  static const Color $name = Color(0x${_toArgb(entry.value as String)});',
      );
    }
  }

  final banned = (color['banned'] as Map<String, dynamic>).entries.first;
  buffer
    ..writeln()
    ..writeln('  /// Never use. ${banned.value}')
    ..writeln(
      '  static const Color bannedMutedLabel = '
      'Color(0x${_toArgb('#${banned.key}')});',
    );

  final gradient = tokens['gradient'] as Map<String, dynamic>;
  final stops = (gradient['brand'] as Map<String, dynamic>)['stops'] as List;
  final positions =
      (gradient['brand'] as Map<String, dynamic>)['positions'] as List;
  buffer
    ..writeln()
    ..writeln('  // --- Brand gradient ---')
    ..writeln(
      '  static const List<Color> gradientStops = <Color>[${stops.map((s) => 'Color(0x${_toArgb(s as String)})').join(', ')}];',
    )
    ..writeln(
      '  static const List<double> gradientPositions = <double>[${positions.map((p) => (p as num).toDouble()).join(', ')}];',
    )
    ..writeln('  static const double gradientAngleLtr = '
        '${(gradient['brand'] as Map)['angleLTR']};')
    ..writeln('  static const double gradientAngleRtl = '
        '${(gradient['brand'] as Map)['angleRTL']};')
    ..writeln('  static const int gradientMaxPerScreen = '
        '${gradient['maxPerScreen']};')
    ..writeln(
      '  static const List<String> gradientPermittedUses = <String>[${(gradient['permittedUses'] as List).map((u) => "'$u'").join(', ')}];',
    );

  final type = tokens['type'] as Map<String, dynamic>;
  buffer
    ..writeln()
    ..writeln('  // --- Typography ---');
  for (final entry in (type['families'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      "  static const String font${_capitalize(entry.key)} = '${entry.value}';",
    );
  }
  for (final entry in (type['sizes'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const double size${_capitalize(entry.key)} = '
      '${(entry.value as num).toDouble()};',
    );
  }
  for (final entry in (type['lineHeight'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const double lineHeight${_capitalize(entry.key)} = '
      '${(entry.value as num).toDouble()};',
    );
  }
  for (final entry in (type['letterSpacing'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const double letterSpacing${_capitalize(entry.key)} = '
      '${(entry.value as num).toDouble()};',
    );
  }
  for (final entry in (type['weights'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const int weight${_capitalize(entry.key)} = ${entry.value};',
    );
  }
  final arHeading = type['arHeadingReduce'] as Map<String, dynamic>;
  buffer
    ..writeln('  /// Arabic headings shrink by this fraction above')
    ..writeln('  /// [arHeadingThresholdChars] characters.')
    ..writeln('  static const double arHeadingReducePct = '
        '${(arHeading['abovePct'] as num).toDouble()};')
    ..writeln('  static const int arHeadingThresholdChars = '
        '${arHeading['thresholdChars']};');

  buffer
    ..writeln()
    ..writeln('  // --- Spacing scale ---')
    ..writeln(
      '  static const List<double> space = <double>[${(tokens['space'] as List).map((s) => (s as num).toDouble()).join(', ')}];',
    );

  buffer
    ..writeln()
    ..writeln('  // --- Radius ---');
  for (final entry in (tokens['radius'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const double radius${_capitalize(entry.key)} = '
      '${(entry.value as num).toDouble()};',
    );
  }

  buffer
    ..writeln()
    ..writeln('  // --- Opacity ---');
  for (final entry in (tokens['opacity'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const double opacity${_capitalize(entry.key)} = '
      '${(entry.value as num).toDouble()};',
    );
  }

  final motion = tokens['motion'] as Map<String, dynamic>;
  buffer
    ..writeln()
    ..writeln('  // --- Motion ---');
  for (final entry in (motion['durationMs'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const int durationMs${_capitalize(entry.key)} = ${entry.value};',
    );
  }
  buffer
    ..writeln('  static const double pressScale = '
        '${(motion['pressScale'] as num).toDouble()};')
    ..writeln('  static const int staggerListMs = ${motion['staggerListMs']};');

  buffer
    ..writeln()
    ..writeln('  // --- Breakpoints ---');
  for (final entry in (tokens['breakpoints'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const double breakpoint${_capitalize(entry.key)} = '
      '${(entry.value as num).toDouble()};',
    );
  }

  buffer
    ..writeln()
    ..writeln('  // --- Icon sizes ---');
  for (final entry in (tokens['iconSize'] as Map<String, dynamic>).entries) {
    buffer.writeln(
      '  static const double iconSize${_capitalize(entry.key)} = '
      '${(entry.value as num).toDouble()};',
    );
  }

  final component = tokens['component'] as Map<String, dynamic>;
  buffer
    ..writeln()
    ..writeln('  // --- Component sizing ---');
  for (final entry in component.entries) {
    if (entry.value is Map) {
      for (final sub in (entry.value as Map<String, dynamic>).entries) {
        buffer.writeln(
          '  static const double ${entry.key}${_capitalize(sub.key)} = '
          '${(sub.value as num).toDouble()};',
        );
      }
    } else {
      buffer.writeln(
        '  static const double ${entry.key} = '
        '${(entry.value as num).toDouble()};',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('  // --- Z order ---');
  for (final entry in (tokens['zOrder'] as Map<String, dynamic>).entries) {
    buffer.writeln('  static const int z${_capitalize(entry.key)} = '
        '${entry.value};');
  }

  buffer.writeln('}');

  target
    ..createSync(recursive: true)
    ..writeAsStringSync(buffer.toString());

  stdout.writeln('Generated ${target.path}');
}

/// Normalises a token colour to `AARRGGBB`.
///
/// The token file expresses opaque colours as `#RRGGBB` and translucent ones as
/// `rgba(r, g, b, a)` — the on-dark text colours use the latter. Both must
/// arrive in Dart as a single `Color`, so the alpha channel is folded into the
/// literal here rather than being applied with an opacity modifier at each call
/// site, which would put a raw value back into widget code.
String _toArgb(String value) {
  final rgba = RegExp(
    r'rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)',
  ).firstMatch(value.trim());

  if (rgba != null) {
    final alpha = (double.parse(rgba.group(4)!) * 255).round().clamp(0, 255);
    final channels = [
      alpha,
      int.parse(rgba.group(1)!),
      int.parse(rgba.group(2)!),
      int.parse(rgba.group(3)!),
    ];
    return channels
        .map((c) => c.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
  }

  final hex = value.replaceAll('#', '').toUpperCase();
  if (hex.length == 6) return 'FF$hex';
  if (hex.length == 8) return hex;
  throw FormatException('Unrecognised colour token: $value');
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
