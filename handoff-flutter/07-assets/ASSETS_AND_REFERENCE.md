# Assets · Golden References · Visual QA
### Combines: 07 ASSET_MANIFEST, IMAGE_REQUIREMENTS, PLACEHOLDER_REPLACEMENT_LIST, LICENSES_ATTRIBUTIONS + 08 GOLDEN_SCREEN_INDEX, VISUAL_QA_CHECKLIST

## Asset manifest
| Asset | File | Purpose | Status |
|---|---|---|---|
| Brand mark | `assets/ejadah-mark.jpg` | logo mark | REFERENCE ONLY — JPG; **MUST SUPPLY vector master** (owner decision #9) |
| Icon tile | `ejadah-icon-ms4q23e9-krxx.jpg` | app-icon reference | REFERENCE ONLY — regenerate as gradient tile per Brand Guide §3 |
| Country flags | flagcdn.com at runtime in prototype | 23+ guide/DB flags | **MUST BUNDLE** locally in Flutter (assets/flags/{iso2}.png), never runtime-fetch |
| People photos | pravatar-style URLs in prototype | tutor/mentor/consultant | **MUST REPLACE before any external demo** (todo 30); dev fallback = initials avatar |
| Course art / hero photography | none | Learn cards, heroes | MUST SUPPLY per Imagery Guide; dev = paleGray block + dept icon |
| Fonts | Google Fonts: Playfair Display, Inter, Amiri, IBM Plex Sans Arabic | all UI | FINAL — bundle in app (OFL licenses) |
| Icons | Lucide reference (ISC license) | all icons | FINAL policy; Flutter pkg or custom set |
| King's imagery in uploads/ | website exports | deep-profile reference | STOCK REFERENCE only — do not ship |
**Licenses:** fonts OFL 1.1 · Lucide ISC · flagcdn images public-domain-equivalent but bundle from a clean source · all uploads/ photos unlicensed for production → never ship.

## Golden screen index
The **live prototypes are the golden references** — open in a browser, switch language/state via the rails:
`Ejadah App - Home & Career.dc.html` → Home (6 states × EN/AR, 6 personas) · Learn hub/list/detail/player/flashcards/quiz · Career hub/funnel/result(+gate as guest)/DB/detail/compare/shortlist/countries/guide/compare · People hubs/lists/profiles/booking/plan/onboarding/dashboard/earnings · Profile all · System ×10 · first-run.
`Ejadah App - Programme Profile.dc.html` → deep programme (King's). `Ejadah - Notifications.dc.html` → notif centre. `Ejadah App - Phase 0 Foundation.dc.html` → token sheet (note: pre-dates #C2450F/#6B6862 corrections — tokens.json wins).
Screenshot naming when exporting stills: `{screen}_{viewport}_{lang}[_{state}].png` (e.g. `home_mobile_ar_offline.png`) into `08-reference/screenshots/`.

## Visual QA checklist (Flutter vs golden)
□ colors token-exact (spot-check orangeText & labelMuted, not brand orange as text) □ type family/size/weight/line-height per locale □ AR: 0 tracking, no uppercase, −12% long headings □ spacing/radius from scale (no 18px cards) □ elevation tokens □ gradient ≤6 & permitted uses; angle mirrors □ icons: right glyph, mirror list respected □ images: no placeholder people in demo builds; flags local □ component = canonical variant (one heart style, one deadline badge) □ nav: 5 tabs, indicator slides, edge-swipe back, scroll restore □ RTL full pass per screen □ long-Arabic wrap, no clip @200% font □ every list: skeleton→content, empty routes to action □ safe areas + bottom-nav reserve □ compare = stacked cards on compact □ a11y sweep (labels in active lang, 44×44, focus)
