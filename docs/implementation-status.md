# Implementation status

Honest state of the build against the locked Phase 1 scope
(`handoff-flutter/01-product/PRODUCT_CORE.md` §2, 28 features).

Legend: **COMPLETE** · **PARTIAL** (reachable, but missing named elements of
its screen spec) · **IN PROGRESS** · **NOT STARTED** · **BLOCKED** ·
**FUTURE** (out of Phase 1 scope — must not be built).

Last updated: 15 August 2026.

---

## Summary

All five tabs are built and every module is mounted: Flutter UI → Riverpod
controller → typed client → Dart server → PostgreSQL → back, in both languages.
The two guarantees the brief singles out as mandatory — roadmap determinism and
booking concurrency-safety — are implemented and proven by test against real
PostgreSQL.

Rows below say COMPLETE only where the screen matches its entry in
`04-screens/SCREENS.md`, not merely where something renders. Six rows that
previously read COMPLETE are corrected to PARTIAL after a conformance audit
against the handoff; what each is missing is named.

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
| Localization (EN/AR) | COMPLETE | 507 keys, key-identical, build fails on divergence |
| RTL | COMPLETE | locale-driven `Directionality`, logical edges, mirror list, bidi islands |
| Routing + deep links | COMPLETE | canonical paths, guards, public routes, single cold-start navigation |
| API client | COMPLETE | single-flight refresh, timeouts, typed failure translation |
| Error architecture | COMPLETE | ten typed failures carrying the approved bilingual copy |
| Analytics abstraction | COMPLETE | canonical event names, required properties stamped, privacy list enforced |
| Storage abstraction | IN PROGRESS | interface and `stored_files` table exist; upload routes not built |
| Background jobs | COMPLETE | hold expiry, reminder scheduling (30/14/7 · T-24h · T-1h), delivery |
| Responsive layout | COMPLETE | fluid breakpoints, per-window gutters; programme and country lists go 1 → 2 → 3 columns |
| Reduced motion | COMPLETE | followed from the platform dispatcher, so a mid-session change takes effect |
| Dev environment | COMPLETE | `./tool/dev.sh setup`, docker-compose, seeds, demo accounts |

## Data

| Dataset | Status | Notes |
|---|---|---|
| 199 programmes | COMPLETE | imported and validated: 17 open, 32 closing soon, 150 expired |
| 23 country guides | COMPLETE | bilingual, 108 steps, 28 exams, 92 cost rows |
| "Pending source" facts | COMPLETE | 7 exam fees + 7 cost rows stored as pending, never estimated |
| EN/AR strings | COMPLETE | imported to ARB, key-identical |
| Courses, decks, quizzes | SEEDED | 3 authored bilingual courses, 15 lessons, 6 handouts, 20 flashcards, 13 questions — development seed, not owner content |
| Professional roster | BLOCKED | owner decision #30 — every photo is an unlicensed placeholder |

## Features

| Feature | UI | Backend | DB | EN | AR | Tests | Status |
|---|---|---|---|---|---|---|---|
| **Career** |
| Programme database (199, paginated) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Filters, search, sort (server-side) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Zero-result relaxation | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE |
| Programme detail | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — sources block names the regulator, or says Not verified |
| Shortlist + optimistic save/undo | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| 23 country guides (4 tabs) | ✅ | ✅ | ✅ | ✅ | ✅ | — | PARTIAL — all three crossings and the list's chips and live count are in; no jump-pills or FAQ accordion |
| Roadmap generator + gate | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — share row is in and ungated; no per-stage SourceLine list |
| Roadmap funnel (guest-capable) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Guest → account migration | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| What-if scenarios | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — six presets, each a new roadmap linked to the original |
| Compare programmes (≤3) | — | ✅ | ✅ | — | — | — | IN PROGRESS — server done, no UI |
| Compare countries (≤3) | — | ✅ | ✅ | — | — | — | IN PROGRESS — server done, no UI |
| Saved-filter alerts | — | — | ✅ | — | — | — | NOT STARTED |
| Career-scoped search screen | — | ✅ | ✅ | — | — | — | IN PROGRESS |
| **Identity** |
| Register / sign in / sign out | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Refresh, rotation, revocation | ✅ | ✅ | ✅ | — | — | ✅ | COMPLETE |
| Email verification (60s cooldown) | — | ✅ | ✅ | ✅ | ✅ | — | IN PROGRESS — server done, no UI |
| Forgot password | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE — reset itself is on the website, by design |
| Authorization (roles) | ✅ | ✅ | ✅ | — | — | ✅ | COMPLETE |
| Account deletion (2-step) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE |
| **People** |
| Booking hold + countdown | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Concurrency safety | — | ✅ | ✅ | — | — | ✅ | COMPLETE |
| Availability from schedule | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Cancellation tiers + refund | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — the tier is projected live, so it shows before the button |
| Payment abstraction + simulator | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — checkout URL comes from the provider, never assembled client-side |
| Professional discovery (3 kinds) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Multi-session plans | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — one booking, one row per real time, all-or-nothing |
| Tutor onboarding (6 steps) | — | — | ✅ | — | — | — | NOT STARTED — supply-side screens PE-10..PE-16 |
| Tutor earnings (70/30 itemised) | — | — | ✅ | — | — | — | NOT STARTED |
| My bookings | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| **Learn** |
| Course hub / list / detail | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Player + resume position | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — position, checkpointing and resume are real; playback is a surface until a media dependency lands |
| Handouts | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — fetched and confirmed; not written to disk, so LN-11 Downloads is not built |
| Flashcards (spaced repetition) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — SM-2 shape, pure scheduler |
| Quizzes + explanations | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — graded server-side; the answer key never reaches the client |
| IAP purchase | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — flow and restore work; store receipt verification is not implemented, and the path fails rather than granting on an unverified receipt |
| **Profile** |
| Profile home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Language switch (instant) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE |
| NFC card + editor | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — QR is a real encoder, validated against a reference implementation |
| Public profile `/dr/{slug}` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — public, no auth, no private field emitted |
| Certificates (verified vs stated) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — two CHECK constraints make a forged verification impossible |
| Public verification `/verify/{code}` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| CPD ledger | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| CV builder (PR-07) | — | — | ✅ | — | — | — | NOT STARTED |
| Settings, notification prefs | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| **Home** |
| Feed (greeting, roadmap CTA, tiles) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — six states, per-persona CTA, partial-data treatment |
| Deadline strip | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Notification centre | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — HM-02, with the unread count on Home |
| Activation checklist | — | — | — | — | — | — | NOT STARTED |
| **Platform** |
| Notifications (3 categories) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — scheduling, quiet hours, the daily cap and the centre are all in; no OS permission priming sheet, and no push transport |
| Premium status (read-only) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE — status and renewal date, never prices |
| System states (10) | ✅ | ✅ | — | ✅ | ✅ | ✅ | COMPLETE — one template, ten screens, a failure registry and a root error boundary |
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
3. **14 pending regulator facts** (todo #32). Implemented as a first-class data
   state, not a gap to fill: 7 exam fees (`bh`, `ie`, `nl`, `se`, `ch`, `sg`,
   `za`) and 7 cost rows. The checklist's original 11 counted exam fees only;
   the owner confirmed 14 on 15 August 2026 and confirmed the dataset wins over
   the documentation wherever they disagree. Each prints "Pending source".
4. **Arabic clinical-terminology review** (todo #31). Strings ship exactly as
   authored in `strings.ar.json`. No machine translation was introduced.

## Additions made to the canonical string tables

The tables now hold **507 keys** in each language, up from the 374 they arrived
with. `CONTENT.md` states its copy "already exists (or belongs)" in the tables;
where a screen the handoff specifies had no key for copy the handoff itself
names, the key was added with the handoff's own wording rather than invented
copy. They are grouped so a reviewer can find them:

* 37 from `CONTENT.md` itself — the pending-source and verification wording,
  the funnel path, region and career-stage labels, empty/error/undo copy, and
  the pagination and gate strings.
* 66 for the Home feed, People, Learn and Profile screens.
* 19 for the ten system states, password recovery, the two tab eyebrows the
  prototype still called "Courses" and "Connect", and the ICU-plural day count.
* 10 the feature agents worked around rather than invent — a taken slot's
  label, the goal-too-short error, the mentor destination facet, the CPD title
  and total, and the settings rows.

Three keys were **corrected** rather than added, because they contradicted the
glossary: `notVerified` ("Recognition not verified" → "Not verified", a data
state and not a judgement), `rowMembership` ("Membership" → "Premium"), and
`rowShortlist`, which named the same destination as `myShortlist` differently.

The `continue` key generates an invalid Dart identifier and is renamed to
`continueAction` by the ARB generator; the table itself is unchanged.

## Verification

Counts as of this commit, all run from a clean tree:

| Suite | Count |
|---|---|
| `server` (`dart test`, real PostgreSQL) | 186 |
| `apps/mobile` (`flutter test`) | 118 |
| `packages/ejadah_ui` | 48 |
| `packages/ejadah_localization` | 8 |

`dart analyze` and `flutter analyze` are clean across every package. The
application is **54,790 lines of Dart across 213 files**; there is no JavaScript,
TypeScript, PHP or Vue anywhere in `apps/`, `packages/` or `server/`. The single
`apps/mobile/web/index.html` is Flutter's own generated bootstrap. The `.html`
under `reference/` and `uploads/` are the preserved design prototypes, read as
specification and never ported.

## Known gaps in what is built

* **Cairo time is a fixed +02:00 offset**, matching what the copy states
  ("Times shown in Cairo time (GMT+2)"). It lives in one class, `CairoClock`,
  so a DST-aware definition is a single change — but if Egypt's summer time
  applies, session reminders and displayed times are an hour out during it.
  Worth an owner decision on what the copy should say.
* **Video playback is a surface.** Position, five-second checkpointing, the
  ten-second resume rule and completion are all real and server-backed; the
  player advances a playhead on a timer until a media dependency is added.
* **Handouts fetch but do not save**, so LN-11 Downloads does not exist.
* **In-app purchase is not verified against the store.** The path exists and
  deliberately fails rather than granting entitlement on an unverified receipt.
* **Refresh tokens are in `localStorage` on Flutter Web**, which any XSS could
  read. Native builds use secure storage. Either move the web refresh token to
  an HttpOnly cookie or treat web as a preview surface.
* **The rate limiter is per-process**, which is correct for one instance only.
  `TRUSTED_PROXY_COUNT` must be set to the number of proxies in front of it, or
  `X-Forwarded-For` is ignored entirely — which is the safe default, not a bug.
* **No integration tests** driving the Flutter app against a live server. The
  flows in this document were exercised by hand against one.
* **Android and iOS release builds are unverified here** — no Android SDK or
  macOS toolchain in this environment. Flutter Web release builds successfully.
* **Two test processes cannot share `ejadah_test`.** They truncate between
  tests, so a second concurrent run wipes the first's fixtures. Set
  `TEST_DATABASE_URL` for the second one.
