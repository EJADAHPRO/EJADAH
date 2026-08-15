import 'dart:convert';
import 'dart:io';

import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the strings whose exact wording is the product claim.
///
/// "Pending source" is the clearest case: the handoff specifies it verbatim in
/// both languages, and a variant spelling anywhere would undo the honesty it
/// exists to signal. These assertions lock the value rather than trusting a
/// future edit to notice.
void main() {
  late EjadahStrings en;
  late EjadahStrings ar;

  setUpAll(() async {
    en = await EjadahStrings.delegate.load(const Locale('en'));
    ar = await EjadahStrings.delegate.load(const Locale('ar'));
  });

  group('Pending source', () {
    test('renders exactly, in both languages', () {
      expect(en.pendingSource, 'Pending source');
      expect(ar.pendingSource, 'بانتظار المصدر');
    });

    test('has no variant spelling anywhere in the string tables', () {
      for (final locale in ['en', 'ar']) {
        final matches = _table(locale).entries
            .where((entry) => entry.key != '@@locale')
            .where(
              (entry) =>
                  entry.value.toString().contains('Pending source') ||
                  entry.value.toString().contains('بانتظار'),
            )
            .map((entry) => entry.key)
            .toList();

        expect(
          matches,
          ['pendingSource'],
          reason: 'only one key may carry the pending-source wording',
        );
      }
    });

    test('is never "N/A", an estimate, or a blank', () {
      for (final value in [en.pendingSource, ar.pendingSource]) {
        expect(value.trim(), isNotEmpty);
        expect(value, isNot(contains('N/A')));
        expect(value, isNot(contains('~')));
        expect(value, isNot(contains('approx')));
      }
    });
  });

  group('terminology that must not drift', () {
    test('verified and stated are distinct in both languages', () {
      expect(en.verifiedByEjadah, 'Verified by Ejadah');
      expect(en.statedByTutor, 'Stated by the tutor');
      expect(ar.verifiedByEjadah, 'موثّق من إجادة');
      expect(ar.statedByTutor, 'مُقدَّم من المدرّس');

      expect(en.verifiedByEjadah, isNot(en.statedByTutor));
      expect(ar.verifiedByEjadah, isNot(ar.statedByTutor));
    });

    test('the five canonical tab labels exist in both languages', () {
      // Learn and People supersede the prototype's Courses and Connect.
      for (final label in [
        en.tabHome, en.tabLearn, en.tabCareer, en.tabPeople, en.tabProfile,
        ar.tabHome, ar.tabLearn, ar.tabCareer, ar.tabPeople, ar.tabProfile,
      ]) {
        expect(label.trim(), isNotEmpty);
      }
    });
  });

  group('voice rules', () {
    test('no interface string carries an exclamation mark', () {
      for (final locale in ['en', 'ar']) {
        final offenders = _table(locale).entries
            .where((entry) => entry.key != '@@locale')
            .where((entry) => entry.value.toString().contains('!'))
            .map((entry) => entry.key)
            .toList();

        expect(offenders, isEmpty, reason: 'no exclamation marks in UI copy');
      }
    });

    test('the two tables stay key-identical', () {
      final english = _table('en').keys.toSet();
      final arabic = _table('ar').keys.toSet();

      expect(english.difference(arabic), isEmpty);
      expect(arabic.difference(english), isEmpty);
    });

    test('no Arabic string uses Arabic-Indic digits', () {
      // Western numerals in both languages, always — mixing breaks scanning of
      // exam codes and fees, which are Latin-context.
      final arabicIndic = RegExp(r'[٠-٩۰-۹]');
      final offenders = _table('ar').entries
          .where((entry) => entry.key != '@@locale')
          .where((entry) => arabicIndic.hasMatch(entry.value.toString()))
          .map((entry) => entry.key)
          .toList();

      expect(offenders, isEmpty);
    });
  });
}

Map<String, dynamic> _table(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;
