import 'package:ejadah_models/ejadah_models.dart';

/// The approved form-validation copy.
///
/// Taken verbatim from `handoff-flutter/06-content/CONTENT.md` §Form validation.
/// Messages say what is wrong in plain words — no codes, no "invalid input".
abstract final class ValidationCopy {
  static const LocalizedText nameRequired = LocalizedText(
    en: 'Please enter your name',
    ar: 'اكتب اسمك',
  );

  static const LocalizedText nameMustBeArabic = LocalizedText(
    en: 'Please enter your name in Arabic',
    ar: 'اكتب اسمك بالعربية',
  );

  static const LocalizedText emailFormat = LocalizedText(
    en: "That email doesn't look right",
    ar: 'البريد غير صحيح',
  );

  static const LocalizedText emailTaken = LocalizedText(
    en: 'That email already has an account. Sign in instead.',
    ar: 'هذا البريد له حساب بالفعل. سجّل الدخول بدلًا من ذلك.',
  );

  static const LocalizedText passwordTooShort = LocalizedText(
    en: 'Use at least 8 characters',
    ar: 'استخدم 8 أحرف على الأقل',
  );

  static const LocalizedText passwordNeedsLetterAndNumber = LocalizedText(
    en: 'Include a letter and a number',
    ar: 'أضف حرفًا ورقمًا',
  );

  static const LocalizedText signInFailed = LocalizedText(
    en: "That email and password don't match an account.",
    ar: 'البريد وكلمة المرور لا يطابقان أي حساب.',
  );

  static const LocalizedText codeDidNotMatch = LocalizedText(
    en: "That code didn't match.",
    ar: 'الرمز غير مطابق.',
  );

  static const LocalizedText resetLinkExpired = LocalizedText(
    en: 'That link has expired. Ask for a new one.',
    ar: 'انتهت صلاحية الرابط. اطلب رابطًا جديدًا.',
  );

  static const LocalizedText goalTooShort = LocalizedText(
    en: 'Write a line or two about what you need — '
        'it makes the session far more useful.',
    ar: 'اكتب سطرًا أو سطرين عمّا تحتاجه',
  );

  static const LocalizedText acceptTerms = LocalizedText(
    en: 'Accept the terms to continue',
    ar: 'وافق على الشروط للمتابعة',
  );
}

/// Matches the shape of an address without pretending to prove deliverability —
/// that is what the verification code is for.
final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s.]+(\.[^@\s.]+)+$');

/// Any Arabic-script character.
final RegExp _arabicScript = RegExp(r'[؀-ۿ]');

Map<String, LocalizedText> validateEmail(String email) {
  final trimmed = email.trim();
  if (trimmed.isEmpty || !_emailPattern.hasMatch(trimmed)) {
    return {'email': ValidationCopy.emailFormat};
  }
  return const {};
}

/// At least 8 characters, containing a letter and a number.
///
/// The sign-up form shows these as a live checklist that turns green as each is
/// met, so the rules here and the rules on screen must not drift apart.
Map<String, LocalizedText> validatePassword(String password) {
  if (password.length < 8) {
    return {'password': ValidationCopy.passwordTooShort};
  }
  final hasLetter = RegExp(r'[A-Za-z؀-ۿ]').hasMatch(password);
  final hasNumber = RegExp(r'[0-9]').hasMatch(password);
  if (!hasLetter || !hasNumber) {
    return {'password': ValidationCopy.passwordNeedsLetterAndNumber};
  }
  return const {};
}

/// A name is required in both languages, and the Arabic field must actually be
/// Arabic — an English name pasted into it is the mistake this catches.
Map<String, LocalizedText> validateName(
  String nameEn,
  String nameAr,
  AppLanguage language,
) {
  if (nameEn.trim().isEmpty && nameAr.trim().isEmpty) {
    return {'full_name': ValidationCopy.nameRequired};
  }
  if (language == AppLanguage.ar &&
      nameAr.trim().isNotEmpty &&
      !_arabicScript.hasMatch(nameAr)) {
    return {'full_name': ValidationCopy.nameMustBeArabic};
  }
  return const {};
}

/// The booking goal must be a real sentence, and must never contain patient
/// identifiers — the form carries that warning permanently, and this is the
/// length half of the rule.
Map<String, LocalizedText> validateBookingGoal(String goal) {
  if (goal.trim().length < 10) {
    return {'goal': ValidationCopy.goalTooShort};
  }
  return const {};
}
