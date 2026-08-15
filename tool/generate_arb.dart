import 'dart:convert';
import 'dart:io';

/// Generates ARB files from the canonical string tables.
///
///     dart run tool/generate_arb.dart
///
/// `handoff/strings.en.json` and `strings.ar.json` are key-identical by
/// contract, and a missing key must fail the build rather than fall back to the
/// other language — an English string appearing inside an Arabic screen is a
/// defect, not a graceful degradation. This tool enforces that: any key present
/// in one table and absent from the other stops the generation.
Future<void> main() async {
  final english = _flatten(_read('handoff/strings.en.json'));
  final arabic = _flatten(_read('handoff/strings.ar.json'));

  final missingInArabic = english.keys.where((k) => !arabic.containsKey(k));
  final missingInEnglish = arabic.keys.where((k) => !english.containsKey(k));

  if (missingInArabic.isNotEmpty || missingInEnglish.isNotEmpty) {
    stderr
      ..writeln('String tables are not key-identical.')
      ..writeln('  Missing from Arabic: ${missingInArabic.join(', ')}')
      ..writeln('  Missing from English: ${missingInEnglish.join(', ')}');
    exitCode = 1;
    return;
  }

  _write('en', english);
  _write('ar', arabic);

  stdout.writeln('Generated ARB for ${english.length} keys in both languages.');
}

Map<String, dynamic> _read(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// The tables are shallow today, but nested groups are flattened with a dotted
/// path so a future grouping change does not silently drop keys.
Map<String, String> _flatten(
  Map<String, dynamic> source, [
  String prefix = '',
]) {
  final result = <String, String>{};
  for (final entry in source.entries) {
    final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      result.addAll(_flatten(value, key));
    } else {
      result[key] = value.toString();
    }
  }
  return result;
}

void _write(String locale, Map<String, String> strings) {
  final buffer = StringBuffer('{\n  "@@locale": "$locale",\n');

  final keys = strings.keys.toList()..sort();
  for (var i = 0; i < keys.length; i++) {
    final key = keys[i];
    final identifier = _toIdentifier(key);
    buffer.write('  ${jsonEncode(identifier)}: ${jsonEncode(strings[key])}');
    buffer.writeln(i == keys.length - 1 ? '' : ',');
  }
  buffer.writeln('}');

  File('packages/ejadah_localization/lib/l10n/app_$locale.arb')
    ..createSync(recursive: true)
    ..writeAsStringSync(buffer.toString());
}

/// ARB keys become Dart getters, so dotted paths become camelCase and any key
/// that collides with a Dart reserved word is renamed.
///
/// The handoff table has a `continue` key, which would generate
/// `String get continue;` and fail to compile. Renaming here — rather than in
/// the handoff — keeps the string tables as authored while still producing
/// valid Dart.
String _toIdentifier(String key) {
  final parts = key.split('.');
  final camelCase = parts.length == 1
      ? parts.first
      : parts.first +
            parts
                .skip(1)
                .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
                .join();
  return _reservedWordRenames[camelCase] ?? camelCase;
}

/// Dart reserved words that appear as string keys, and what they become.
const Map<String, String> _reservedWordRenames = {
  'continue': 'continueAction',
  'default': 'defaultAction',
  'new': 'newLabel',
  'class': 'classLabel',
  'is': 'isLabel',
  'in': 'inLabel',
  'for': 'forLabel',
  'if': 'ifLabel',
  'this': 'thisLabel',
  'switch': 'switchLabel',
  'return': 'returnLabel',
  'void': 'voidLabel',
  'true': 'trueLabel',
  'false': 'falseLabel',
  'null': 'nullLabel',
};
