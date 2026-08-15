# Ejadah App — Developer Handoff (Phase 1)
Updated 29 Jul 2026 · Design source of truth: `Ejadah App - Home & Career.dc.html` (single-file interactive prototype), plus `Ejadah App - Phase 0 Foundation.dc.html` (design system) and `Ejadah App - Programme Profile.dc.html` (King's deep profile template).

## Stack intent
React Native (Expo) · lucide-react-native icons (stroke 2) · fonts: PlayfairDisplay 700/800 + Inter 400–800 (EN), Amiri 700 + IBMPlexSansArabic 400–700 (AR). All copy is bilingual; every string in the prototype lives in the `S.en` / `S.ar` tables or inline `ar ? … : …` ternaries — extract to `strings.ts` verbatim.

## Global rules (from Phase 0 sheet — normative)
- Colors: charcoal #1B1B1B, offWhite #FFF9EF, paleGray #F5F2EC, border #E7E2DA, warmGray #716D67, brand gradient 135° #FF2D32→#FF6B1A→#FFC62E (225° in RTL). Semantic: success #2D9B68, info #496FA8, danger #FF2D32, gold #FFC62E.
- Gradient allowed ONLY: primary button, logo tile, step tiles, one heading phrase, one CTA band, active tab bar. Max 6 per viewport.
- Arabic: letterSpacing 0 always, Amiri for display, line-heights 1.45/1.65/1.85, Western numerals, Latin fragments bidi-isolated, back-chevrons mirrored (scaleX -1), progress fills from start edge.
- Numerals western everywhere. Difficulty vocabulary exactly متوسط/صعب/صعب جدًا.
- Tab bar: 6 tabs — Home · Connect · Courses · Career · Postgrad(label "Postgrad"/"دراسات عليا", route name masters) · Profile. Active = gradient indicator bar + white icon.
- Every list uses flex/grid + gap. Cards: radius 20, border 1.5 #E7E2DA, shadow 0 1 3 rgba(0,0,0,.05).

## Screen map (prototype state → screen)
Home: tab=home; states default/new/loading/error/offline/partial (left-rail switcher). Persona CTA card driven by `persona` (student/grad/dentist/spec).
Connect hub: tab=connect kView=hub. Lists: kView=list kind=tutoring|mentoring|consulting. Profile: kView=profile (+pTab about/pkg/rev). Booking: kView=book bStep 1–8. Bookings: kView=bookings (+pkg balance card, reschedule/cancel sheets). Tutor side: xView=requests|earnings|instructor; onboarding xView=onboard oStep 1–8 → onboardDone.
Courses: cView hub→list(cat,fmt)→detail→player | flash | quiz; pay sheet → paysuccess/paycancel (payKind course/session).
Career: paths + country guides xView=countries/countryDetail (23 countries) + roadmap rStep 0–6 (live gen via window.claude.complete → backend LLM endpoint in production; salvage+retry+fallback logic in `runRoadmap`, `salvage`).
Postgrad: quick tabs All/Open/Closing/Saved, search, spec chips, expired toggle, detail, compare (≤3), King's featured → Programme Profile DC.
Profile: pView home/nfc/nfcedit/public/certs/settings/notifs/membership/pricing/shortlist/handouts + verify xView; certificates model below.

## Data models (mock → API)
- programmes: `data/programmes.js` — 199 real records, fields incl usdOnly/usdEst, *_Ar localized fields, status open|soon|expired, days. Fees converted Jul-2026 mid-market; flag: usdEst.
- TUT2 (10 tutors: subject, uni, years[], cat pre/clin/exam, staff, rate, availability), MEN (4 mentors: areasIds, prices[4], outcomes, approach, mPkgs), CON (4 consultants: cat, dels, sTypes) — all in connectVals.
- Certificates: ej(bool)=Ejadah-issued → verified badge + verification chips [syn, ada, qchp] (acc[] = granted, others requestable); external adds are self-reported, never verified.
- Packages: tutoring PKGS computed from tutor rate (×4·-10%, ×10·-15%, ×16·-20%); mentors/consultants use their own mPkgs. Entitlement: pkgOwned index + pkgUsed count; rebook sets bkFromBal → total "EGP 0 due", pkgUsed++.

## Integration points
- Payments: NEVER in-app. All pay CTAs deep-link to ejadah.com checkout; return deep links → paysuccess / paycancel (payKind).
- Roadmap LLM: prompt template in `runRoadmap` (answers, hard budget/time limits, per-direction guides, AR output block, strict minified JSON, 5 stages). Keep salvage + 1 retry + worked-example fallback.
- Flags: flagcdn.com w80 PNGs by ISO2. Portraits/course art: pravatar/picsum placeholders — replace with real shoot (single seed list per surface).
- Toast: single toast helper (bottom, above tab bar, 2.6s).
- Scroll: every nav resets scroll (nav() helper) — replicate with ScrollView refs.

## Analytics to wire (min set)
persona_selected, tab_view, tutor_list_filtered, tutor_profile_view, package_selected, booking_step, booking_paid(kind, fromBalance), onboard_step, onboard_submitted, course_viewed, lesson_play, flashcard_reviewed, quiz_answered, programme_saved, compare_opened, roadmap_generated(live|fallback), cert_verify_requested(body), notif_pref_toggled.

## Known mocks / not built (Phase 1 accepted)
Auth is stubbed (first-run flow exists, no real accounts) · search fields filter locally · files upload boxes are visual · LinkedIn connect is a toast · recognition data removed by decision · 11 country guides missing fee figures ("Pending source").

## Programme deep-profile templating (proves King's generalises)
`Ejadah App - Programme Profile.dc.html` is one CMS template, nine sections. Field classes:
- **Data-driven (from the programmes DB):** hero (uni, name, city, flag ISO, tuition, duration, cohort, acceptance, intake, deadline), facts rail, sticky bar, recognition chips.
- **Editorial per programme (CMS rich-text lists):** differentiators[7], equipment[6]{kind,name,desc}, week[5], modules[n]{weeks,credits,title,desc}, assessments[n]{weight,title,desc}, requirements[n]{mand,title,desc}, statement[5], portfolio[5], interview[6]{q,a}, rejections[6], scholarships[n]{...,tip,deadline}, salaries[3], syndicate[6], paths[5], costs[7], areas[5], setup[6], visa[7], faqs[8].
- **Shared boilerplate (write once):** section labels, verify warnings, CTA bar, consultation card.
Every array is bilingual {en,ar} at the item level — no per-language layouts. A second programme = one JSON document in this shape; no new screens.


## Country guides (added 28 Jul 2026)
Data model: `data/countries.js` → `window.EJADAH_COUNTRIES`, keyed by ISO-2. All 23 countries populated, bilingual ({en, ar} pairs).

Schema per country:
- iso, exam (badge code), months, cls: "fast"|"exam"|"lang"|"complex"
- name, examFull, clsL, diff, market, overview, visa, authority (+ site), updated — {en,ar}
- salary: { band (LTR string, local currency), note {en,ar} }
- steps[]: { t, d {en,ar}, when ("~ Mon YYYY" projected date), opt? } — render Optional badge
- tips[] {en,ar} — dark card, yellow bullets
- exams[]: { n, d, dates, pass {en,ar}, fee (LTR) }
- docs[] {en,ar} — checklist rows
- costs[]: { l {en,ar}, v (local, LTR), usd (approx) } + costNote, recNote {en,ar}

Honesty rule: unpublished regulator fees are the literal string "Pending source" — render as-is, never estimate. Fees sourced Jul 2026; refresh cycle recommended every 6 months.

Screens: countries directory (pathway-class chips + region chips + live count + POPULAR badges on ae/sa/gb/au), country detail (hero chips + salary card + authority/visa/updated table + 4 tabs: Pathway/Documents/Costs/Recognition + Ejadah Resources), country compare (up to 3, add/remove from detail, columns: exam/pathway/timeline/cost/salary/difficulty/market). Roadmap result deep-links to the matching guide by name match (en/ar containment).

All currency figures and exam codes render LTR (direction:ltr; unicode-bidi:isolate) inside RTL text.
