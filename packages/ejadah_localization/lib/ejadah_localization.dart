/// Ejadah's EN/AR strings.
///
/// The tables are generated from `handoff/strings.{en,ar}.json` by
/// `tool/generate_arb.dart`, key-for-key. Interface copy is never written
/// inline in a widget, and Arabic is never machine-translated from English —
/// both tables are authored.
library;

import 'package:ejadah_models/ejadah_models.dart';
import 'package:flutter/widgets.dart';

export 'generated/app_localizations.dart';

import 'generated/app_localizations.dart';

/// Reads the active strings and language from the widget tree.
extension EjadahStringsAccess on BuildContext {
  /// The string table for the active language.
  EjadahStrings get strings => EjadahStrings.of(this);

  /// The active language. Arabic is the default when nothing says otherwise.
  AppLanguage get language =>
      AppLanguage.fromCode(Localizations.localeOf(this).languageCode);
}

/// The locales the app ships. Arabic leads because it is the default.
const List<Locale> ejadahSupportedLocales = [Locale('ar'), Locale('en')];

/// Resolves a [LocalizedText] against the active language.
extension LocalizedTextResolution on LocalizedText {
  String call(BuildContext context) => resolve(context.language);
}
