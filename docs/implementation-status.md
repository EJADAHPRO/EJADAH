# Implementation status

Honest state of the build against the locked Phase 1 scope
(`handoff-flutter/01-product/PRODUCT_CORE.md` §2, 28 features).

Legend: **COMPLETE** · **IN PROGRESS** · **NOT STARTED** · **BLOCKED** ·
**FUTURE** (out of Phase 1 scope — must not be built).

Last updated: 15 August 2026.

---

## Summary

The **foundation and the Career vertical are complete end to end**: Flutter UI →
Riverpod controller → typed client → Dart server → PostgreSQL → back, in both
languages, with persistence proven across connection restarts. The **roadmap
engine and the booking engine are complete and tested**, including the two
guarantees the brief singles out as mandatory — determinism and
concurrency-safety.

**Learn, People's discovery surface, and most of Profile have server foundations
but no screens yet.** Those tabs render the handoff's own "next in the build
order" treatment rather than a broken or empty screen. What follows says exactly
which is which.

---

## Platform foundation

| Area | Status | Notes |
|---|---|---|
| Flutter workspace + packages | COMPLETE | apps/mobile, ejadah_ui, ejadah_core, ejadah_models, ejadah_localization |
| Dart backend (Shelf, layered) | COMPLETE | route → service → domain → repository → SQL |
| PostgreSQL schema | COMPLETE | 7 migrations, constraint-enforced product rules |
| Design tokens | COMPLETE | generated from `DESIGN_TOKENS.json`; raw values are defects |
| Ejadah component family | COMPLETE | buttons, cards, badges, inputs, sheets, states, bottom nav |
| Gradient budget enforcement | COMPLETE | debug assertion at six per screen |
| Typography (EN + AR rules) | COMPLETE | families, line-heights, tracking, −12% long headings |
| Bundled fonts | COMPLETE | Playfair, Inter, Amiri, IBM Plex Sans Arabic, OFL, licences recorded |
| Localization (EN/AR) | COMPLETE | 374 keys, key-identical, build fails on divergence |
| RTL | COMPLETE | locale-driven `Directionality`, logical edges, mirror list, bidi islands |
| Routing + deep links | COMPLETE | canonical paths, guards, public routes, single cold-start navigation |
| API client | COMPLETE | single-flight refresh, timeouts, typed failure translation |
| Error architecture | COMPLETE | ten typed failures carrying the approved bilingual copy |
| Analytics abstraction | COMPLETE | canonical event names, required properties stamped, privacy list enforced |
| Storage abstraction | IN PROGRESS | interface and `stored_files` table exist; upload routes not built |
| Background jobs | IN PROGRESS | runner + hold expiry shipped; deadline/session reminders not scheduled yet |
| Responsive layout | COMPLETE | fluid breakpoints, per-window gutters, grid/tile column rules |
| Reduced motion | COMPLETE | applied centrally through `EjadahMotion.durationFor` |
| Dev environment | COMPLETE | `./tool/dev.sh setup`, docker-compose, seeds, demo accounts |

## Data

| Dataset | Status | Notes |
|---|---|---|
| 199 programmes | COMPLETE | imported and validated: 17 open, 32 closing soon, 150 expired |
| 23 country guides | COMPLETE | bilingual, 108 steps, 28 exams, 92 cost rows |
| "Pending source" facts | COMPLETE | 7 exam fees + 7 cost rows stored as pending, never estimated |
| EN/AR strings | COMPLETE | imported to ARB, key-identical |
| Courses, decks, quizzes | NOT STARTED | schema exists; no content imported (none exists in the handoff) |
| Professional roster | BLOCKED | owner decision #30 — every photo is an unlicensed placeholder |

## Features

| Feature | UI | Backend | DB | EN | AR | Tests | Status |
|---|---|---|---|---|---|---|---|
| **Career** |
| Programme database (199, paginated) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Filters, search, sort (server-side) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Zero-result relaxation | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE |
| Programme detail | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE |
| Shortlist + optimistic save/undo | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| 23 country guides (4 tabs) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE |
| Roadmap generator + gate | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Roadmap funnel (guest-capable) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Guest → account migration | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| What-if scenarios | — | ✅ | ✅ | ✅ | ✅ | — | IN PROGRESS — server done, no UI |
| Compare programmes (≤3) | — | ✅ | ✅ | — | — | — | IN PROGRESS — server done, no UI |
| Compare countries (≤3) | — | ✅ | ✅ | — | — | — | IN PROGRESS — server done, no UI |
| Saved-filter alerts | — | — | ✅ | — | — | — | NOT STARTED |
| Career-scoped search screen | — | ✅ | ✅ | — | — | — | IN PROGRESS |
| **Identity** |
| Register / sign in / sign out | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Refresh, rotation, revocation | ✅ | ✅ | ✅ | — | — | ✅ | COMPLETE |
| Email verification (60s cooldown) | — | ✅ | ✅ | ✅ | ✅ | — | IN PROGRESS — server done, no UI |
| Forgot / reset password | — | ✅ | ✅ | ✅ | ✅ | — | IN PROGRESS — server done, no UI |
| Authorization (roles) | ✅ | ✅ | ✅ | — | — | ✅ | COMPLETE |
| Account deletion (2-step) | — | ✅ | ✅ | — | — | — | IN PROGRESS — server done, no UI |
| **People** |
| Booking hold + countdown | — | ✅ | ✅ | ✅ | ✅ | ✅ | IN PROGRESS — engine done, no UI |
| Concurrency safety | — | ✅ | ✅ | — | — | ✅ | COMPLETE |
| Availability from schedule | — | ✅ | ✅ | — | — | — | IN PROGRESS — engine done, no UI |
| Cancellation tiers + refund | — | ✅ | ✅ | ✅ | ✅ | ✅ | IN PROGRESS — engine done, no UI |
| Payment abstraction + simulator | — | ✅ | ✅ | — | — | — | IN PROGRESS — no UI |
| Professional discovery (3 kinds) | — | — | ✅ | — | — | — | NOT STARTED |
| Multi-session plans | — | — | ✅ | — | — | — | NOT STARTED |
| Tutor onboarding (6 steps) | — | — | ✅ | — | — | — | NOT STARTED |
| Tutor earnings (70/30 itemised) | — | — | ✅ | — | — | — | NOT STARTED |
| My bookings | — | ✅ | ✅ | — | — | — | IN PROGRESS |
| **Learn** |
| Course hub / list / detail | — | — | ✅ | — | — | — | NOT STARTED |
| Player + resume position | — | — | ✅ | — | — | — | NOT STARTED |
| Handouts | — | — | ✅ | — | — | — | NOT STARTED |
| Flashcards (spaced repetition) | — | — | ✅ | — | — | — | NOT STARTED |
| Quizzes + explanations | — | — | ✅ | — | — | — | NOT STARTED |
| IAP purchase | — | — | ✅ | — | — | — | NOT STARTED |
| **Profile** |
| Profile home | ✅ | ✅ | ✅ | ✅ | ✅ | — | IN PROGRESS |
| Language switch (instant) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE |
| NFC card + editor | — | — | ✅ | — | — | — | NOT STARTED |
| Public profile `/dr/{slug}` | route | — | ✅ | — | — | — | NOT STARTED |
| Certificates (verified vs stated) | — | — | ✅ | — | — | — | NOT STARTED |
| Public verification `/verify/{code}` | route | — | ✅ | — | — | — | NOT STARTED |
| CV builder, CPD ledger | — | — | ✅ | — | — | — | NOT STARTED |
| Settings, notification prefs | — | ✅ | ✅ | — | — | — | IN PROGRESS |
| **Home** |
| Feed (greeting, roadmap CTA, tiles) | ✅ | ✅ | ✅ | ✅ | ✅ | — | IN PROGRESS |
| Deadline strip | — | ✅ | ✅ | — | — | — | IN PROGRESS — query done, no UI |
| Notification centre | — | — | ✅ | — | — | — | NOT STARTED |
| Activation checklist | — | — | — | — | — | — | NOT STARTED |
| **Platform** |
| Notifications (3 categories) | — | ✅ | ✅ | ✅ | ✅ | — | IN PROGRESS |
| Premium status (read-only) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE |
| System states (10) | partial | ✅ | — | ✅ | ✅ | ✅ | IN PROGRESS — offline, error, empty, not-found done |
| Admin panel (Flutter Web) | — | — | ✅ | — | — | — | NOT STARTED |

## Out of scope — must not be built

Exams, question banks and mock tests · live classes and clinical demonstrations
· dental library and research hub · AI assistants of any kind · community and
user-to-user messaging · achievements and badges · accreditations page · private
group training · global cross-content search · course prices outside in-app
purchase · six-tab navigation.

Their reference material is retained under `uploads/` and `reference/` and is
never followed as specification.

## Blocked on owner decisions

These are isolated so they block nothing else. They are carried from the
conflict register and the handoff checklist.

1. **Vector logo master** (conflict #9). Two JPGs exist; no vector, no dark
   variant, no app-icon master. Blocks store assets only. The app icon uses the
   documented gradient-tile pattern until one is supplied.
2. **Real rosters and photographs** (todo #30). Every tutor image in the handoff
   is a placeholder and unlicensed for production. The app shows initials on the
   inset surface — never a broken image, never an unlicensed portrait.
3. **11 pending regulator fees** (todo #32). Implemented as a first-class data
   state, not a gap to fill. The import found **14** unsourced facts in the
   current dataset — 7 exam fees and 7 cost rows — rather than the 11 the
   checklist records. Worth reconciling; either way each prints "Pending
   source".
4. **Arabic clinical-terminology review** (todo #31). Strings ship exactly as
   authored in `strings.ar.json`. No machine translation was introduced.

## Additions made to the canonical string tables

`CONTENT.md` states its copy "already exists (or belongs)" in the string tables.
Thirty-seven keys it specifies verbatim were absent and have been added, with
the wording taken from the handoff rather than invented: `pendingSource`,
`verifiedByEjadah`, `statedByTutor`, `myShortlist`, `tabLearn`, `tabPeople`, the
four funnel path labels, the five region labels, the five career-stage labels,
the empty/error/undo copy, and the pagination and gate strings.

The `continue` key generates an invalid Dart identifier and is renamed to
`continueAction` by the ARB generator; the table itself is unchanged.

## Known gaps in what is built

* **`Booking.refundableEgp` is populated only after cancellation.** The
  cancellation tier is computed correctly by `BookingService.refundFor`, but the
  booking list does not yet project it for an active booking — the UI that needs
  it does not exist yet. It must be wired before the cancel screen ships, since
  the tier has to be shown *before* the button.
* **HTTP routes for People, Learn and Profile are not mounted.** The services
  and repositories exist and are tested directly; `app.dart` mounts only
  `/auth`, `/career` and `/roadmap`.
* **No integration tests** driving the Flutter app against a live server.
* **The rate limiter is per-process**, which is correct for one instance only.
* **Android and iOS release builds are unverified here** — no Android SDK or
  macOS toolchain in this environment. Flutter Web release builds successfully.
