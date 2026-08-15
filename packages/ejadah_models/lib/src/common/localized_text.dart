import 'value.dart';

/// Supported application languages. Arabic is the product default.
enum AppLanguage {
  ar('ar'),
  en('en');

  const AppLanguage(this.code);

  final String code;

  bool get isRtl => this == AppLanguage.ar;

  static AppLanguage fromCode(String? code) => switch (code?.toLowerCase()) {
    'en' => AppLanguage.en,
    _ => AppLanguage.ar,
  };
}

/// A piece of content authored in both languages.
///
/// The handoff requires EN/AR parity from the first commit, so content that
/// crosses the API carries both languages rather than being resolved server
/// side — this is what lets the language switch be instant with no reload and
/// no lost state (`LOCALIZATION.md`).
class LocalizedText extends ValueObject {
  const LocalizedText({required this.en, required this.ar});

  const LocalizedText.same(String value) : en = value, ar = value;

  final String en;
  final String ar;

  /// Resolves against [language].
  ///
  /// Deliberately not `call`: widget code resolves against a `BuildContext`
  /// through an extension in `ejadah_localization`, and a `call` here would
  /// shadow it, because an instance method always wins over an extension.
  String resolve(AppLanguage language) => switch (language) {
    AppLanguage.ar => ar,
    AppLanguage.en => en,
  };

  bool get isEmpty => en.trim().isEmpty && ar.trim().isEmpty;

  bool get isNotEmpty => !isEmpty;

  static LocalizedText? fromJson(Object? json) {
    if (json == null) return null;
    if (json is String) return LocalizedText.same(json);
    if (json is Map) {
      final en = json['en'];
      final ar = json['ar'];
      if (en == null && ar == null) return null;
      return LocalizedText(
        en: (en ?? ar ?? '').toString(),
        ar: (ar ?? en ?? '').toString(),
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {'en': en, 'ar': ar};

  @override
  List<Object?> get props => [en, ar];
}
