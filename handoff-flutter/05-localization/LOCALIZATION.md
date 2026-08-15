# Localization — Guide · RTL · Bidi · Terminology
### Combines: LOCALIZATION_GUIDE, RTL_GUIDE, BIDI_RULES, TERMINOLOGY_EN_AR
Strings live in `../../handoff/strings.en.json` / `strings.ar.json` (key-identical; a missing key fails the build). Terminology table: `../01-product/FLOWS_STORIES_CRITERIA.md` §5.

## Rules
- **Arabic is the default language**, switchable instantly, no reload, no lost form state.
- EN/AR parity from the first commit; never English-first-Arabic-later.
- No concatenated fragments — placeholders only (`{x} of {y}`); plurals via ICU (Arabic has 6 plural forms — use them for counts like "3 جلسات").
- Dates: localized month names, Western digits, `j M Y` style. Times: 24h with zone named ("توقيت القاهرة"). Currency: code + Western digits, LTR-isolated.
- **Western numerals (0–9) in both languages, always.** Never Arabic-Indic, never mixed.
- Proper nouns untranslated: universities, Prometric/Pearson VUE/DataFlow, product names (exocad, 3Shape), exam codes.
- Long-string handling: AR headings −12% above 28 chars; card titles 1-line ellipsis; never truncate figures or codes.
- Accessibility labels localized to the active language, including icon-only buttons.

## RTL — what mirrors
**Mirrors:** layout (logical start/end), back/forward chevrons & arrows, progress/track fills, stepper order, tab indicator travel, carousel/week-pill order, gradient angle (135°→225°), jump-pill row, compare column order, send/reply icons.
**Never mirrors:** logos, photos, media play/pause, search/star/heart/camera/clock icons, numbers, exam codes, currency strings, OTP boxes, phone numbers, URLs, email addresses, video scrubber direction (time flows LTR).
Pattern refs (all visible in the AR prototype): app bar (title start-aligned, back at start pointing "forward-in-reading"), bottom nav order mirrors, cards (flag/avatar at start), forms (labels start, errors below), booking calendar (week starts Sunday both), roadmap stages (marker at start edge), NFC card (fixed brand layout; only text alignment flips).

## Bidi islands (wrap in LTR + isolate)
ORE · ADC · NDEB · INBDE · SDLE · DHA · DOH · MOHAP · SCFHS · QCHP · NHRA · GDC · Prometric · Pearson VUE · DataFlow · IELTS/OET · university names in Latin · URLs · emails · phone numbers · currency amounts ("EGP 1,400 (≈ $327)" as ONE island) · date-ranges ("12–24") · percentages ("85%") · OTP digits · reference codes (EJ-7K2M9Q).
Flutter: `Directionality(textDirection: TextDirection.ltr, child: Text(...))` via the `CurrencyText`/`CodeText` widgets — never raw unicode control chars in strings.
