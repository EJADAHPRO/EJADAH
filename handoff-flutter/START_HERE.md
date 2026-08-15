# START HERE — Ejadah Flutter Handoff
### Read this in five minutes. Everything else in this folder expands on it.
**14 August 2026 · canonical entry point for the Flutter + Dart implementation**

---

## What Ejadah is

A bilingual (Arabic-default) mobile platform for Egyptian dental professionals planning careers abroad: 199 verified postgraduate programmes, 23 country licensing guides, a deterministic career-roadmap generator, one-to-one tutoring/mentoring/consulting marketplaces, recorded courses, and an NFC professional identity card. Cairo-based, launching soon.

**The one-line product:** a Cairo dentist opens the app and, in ~3 minutes, gets a real, costed, sourced answer to "where can I actually go, and what will it take" — in Arabic, on a mid-range Android phone, every number from Ejadah's own verified database.

## Who it serves

Dental students · fresh graduates · GP dentists (the core persona) · specialists · supply-side tutors/mentors/consultants. See `01-product/PERSONAS.md`.

## The five tabs — canonical, supersedes everything older

**Home · Learn · Career · People · Profile**

Mapping from the prototype (which used older names): prototype "Courses" = **Learn** · prototype "Connect" = **People** · prototype "Masters" (postgrad database) folds **into Career**. Any six-tab structure anywhere is legacy. See `09-handoff/SPEC_CONFLICTS.md` row 1.

## Technology target

**Flutter + Dart, with a Dart backend.** All PHP/CodeIgniter packs and React/React-Native intents are legacy and were deleted or archived. Design docs here are framework-neutral; Flutter-specific guidance lives only in `03-design-system/FLUTTER_DESIGN_MAPPING.md`.

## The five rules that override everything

1. **Our data only.** No AI inference, no external content APIs, no web lookups. The roadmap is a deterministic filter→score→assemble formula over Ejadah's own rows. Unverified facts print **"Pending source" / "بانتظار المصدر"** — never an estimate.
2. **Arabic is first-class and default.** `letterSpacing: 0` on Arabic, no uppercase transforms, line-heights up (1.25→1.45 / 1.45→1.65 / 1.70→1.85), Western numerals in both languages, Latin exam codes (ORE, DHA, DataFlow…) bidi-isolated LTR, gradient mirrors 135°→225°, instant language switch with no lost state.
3. **Payments are legally split.** Courses = digital content → in-app purchase only (Apple §3.1.1). Sessions = human services → external checkout permitted (70/30 split). NFC card = shipped goods → external. These look inconsistent; they are law. Never harmonise.
4. **Nothing without acknowledgement.** ≤100ms feedback, optimistic UI + Undo on reversible actions, skeletons not spinners, every empty state routes to action, disabled controls explain themselves on tap, destructive actions state the exact consequence (incl. refund amount).
5. **Preserve the identity.** Ejadah gradient red→orange→gold (max six gradient elements per screen, on the six permitted uses only), warm off-white surfaces, Playfair/Inter (EN) + Amiri/IBM Plex Sans Arabic (AR), the existing card language. Build Ejadah components in Flutter — not Material defaults arranged like Ejadah.

## Source-of-truth hierarchy

1. This folder (`handoff-flutter/`)
2. `EJADAH-BUILD-STORY.md` (the narrative brief: 45→28 features, why each cut)
3. The canonical prototype: **`Ejadah App - Home & Career.dc.html`** (95 screens, both languages) + `Ejadah App - Programme Profile.dc.html` + `Ejadah - Notifications.dc.html` + `Ejadah App - Phase 0 Foundation.dc.html` (design-system sheet)
4. `handoff/tokens.ts`, `handoff/strings.en.json`, `handoff/strings.ar.json`, `handoff/analytics-events.md`, `handoff/deep-links.md`, `handoff/push-notifications.md`
5. `data/` — the real datasets: `programmes.json` (199 records), `countries.js` (23 guides), `kings-profile.md`
6. `export/` — readable .md mirrors of all of the above

**Anything in `uploads/` is INPUT MATERIAL, not specification** — old website exports, the superseded Stage 6 backlog, the old PHP architecture audit. See `09-handoff/LEGACY_FILES.md`.

## What must NOT be implemented

No exams/question banks/mock tests · no live classes · no dental library/research hub · no AI assistants of any kind · no community/user-to-user messaging (contact is student↔tutor on a booking only, admin-visible) · no achievements/badges · no global cross-content search (Career-scoped search only) · no course prices outside IAP · no six-tab navigation.

## Read next, in order

1. `01-product/PHASE1_SCOPE.md` — the locked 28 features
2. `01-product/INFORMATION_ARCHITECTURE.md` — every screen under its tab
3. `02-brand/BRAND_GUIDE.md` + `03-design-system/DESIGN_TOKENS.json`
4. `04-screens/SCREEN_STATE_MATRIX.md` — what states exist, what you must add
5. `05-localization/RTL_GUIDE.md` + `BIDI_RULES.md`
6. `09-handoff/SPEC_CONFLICTS.md` — every contradiction, resolved or flagged
7. `03-design-system/FLUTTER_DESIGN_MAPPING.md` — then start building

## Golden visual references

Open the prototype files above in a browser — they render live in both languages and are the acceptance reference. `08-reference/GOLDEN_SCREEN_INDEX.md` lists the specific screens/states to compare against.
