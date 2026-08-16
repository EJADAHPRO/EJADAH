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
| PostgreSQL schema | COMPLETE | 8 migrations, constraint-enforced product rules |
| Design tokens | COMPLETE | generated from `DESIGN_TOKENS.json`, elevation included; raw values are defects |
| Ejadah component family | COMPLETE | buttons, cards, badges, inputs, sheets, states, bottom nav |
| Gradient budget enforcement | COMPLETE | debug assertion at six per screen |
| Typography (EN + AR rules) | COMPLETE | families, line-heights, tracking, −12% long headings |
| Bundled fonts | COMPLETE | Playfair, Inter, Amiri, IBM Plex Sans Arabic, OFL, licences recorded |
| Localization (EN/AR) | COMPLETE | 531 keys, key-identical, build fails on divergence |
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
| Compare programmes (≤3) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE — selection survives paging and filtering |
| Compare countries (≤3) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE — long-press to pick, so the tap still opens the guide |
| Saved-filter alerts | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — up to 5 watched searches, one alert per search per day |
| Career-scoped search screen | — | ✅ | ✅ | — | — | — | IN PROGRESS |
| **Identity** |
| Register / sign in / sign out | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Refresh, rotation, revocation | ✅ | ✅ | ✅ | — | — | ✅ | COMPLETE |
| Email verification (60s cooldown) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE — skippable, because nothing in Phase 1 is gated on it |
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
| Tutor onboarding (6 steps + playbook) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — PE-10/11/12. Every step draft-saved, blocked submit names every missing item, the 70/30 split is read from config so the pitch and the ledger cannot disagree |
| Availability editor (PE-14) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — weekly rules plus dated exceptions. Removing hours a confirmed session occupies is refused with a 409 that names the students |
| Tutor dashboard (PE-13) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — today with join links, money as figures, unmarked sessions releasing earnings when marked, the week ahead, and hide-me that keeps confirmed sessions |
| Tutor earnings (70/30 itemised) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — PE-15. Every row is the whole subtraction in a tabular LTR island; the payout floor states the shortfall in figures; two simultaneous requests produce one payout |
| File uploads (certificate, photo, CV) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — type decided by the bytes not the request, owner-only reads answering 404 to a stranger, 5 MB cap checked before decode, recorded in `stored_files` |
| My bookings | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| **Learn** |
| Course hub / list / detail | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Player + resume position | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — position, checkpointing and resume are real; playback is a surface until a media dependency lands |
| Handouts | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — fetched and opened in the platform's viewer. Nothing is written to the device, which is the shape of the feature: LN-11 Downloads is CUT |
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
| CV builder (PR-07) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — upload-first, sections add/delete/reorder, patient-data warning server-supplied and shown on both screens, A4 PDF export with Amiri and IBM Plex Sans Arabic embedded and Western numerals. The warning does not print |
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

The tables now hold **684 keys** in each language, up from the 374 they arrived
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
* 70 for tutor onboarding (PE-10/11/12): the pitch, the six step titles and
  their field labels, the live earnings estimate with its "assumes full
  booking" caveat, the availability floor, the review step's missing-item list
  with an ICU plural in Arabic's six forms, the three status states, and the
  playbook's three actions. The 70/30 split is **not** among them: it is
  rendered through a placeholder fed from `PLATFORM_FEE_PERCENT`, so the number
  on the public pitch cannot drift from the number in the ledger.
* 22 for the earnings ledger (PE-15): the four money states and why pending
  money is not payable yet, the three column headings, the lifetime line, and
  the payout labels. The fee percentage is a placeholder fed from config, and
  the payout shortfall is composed server-side in both languages so the figure
  the tutor is told they need is the figure the check uses.
* 21 for the CV builder (PR-07): the upload-first lead, the six section
  labels, and the field labels. The patient-data warning is **not** among them
  — CONTENT.md's exact wording is sent by the server with the CV, so a redesign
  that only touches the client cannot drop the one warning this screen must
  always show.
* 1 — `nextStep` ("Next" / «التالي»). The application's step button had been
  reaching for `continueLabel`, which is «أكمل ما بدأته» — a resume CTA, wrong
  on a form.

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
| `server` (`dart test`, real PostgreSQL) | 274 |
| `apps/mobile` (`flutter test`) | 181 |
| `packages/ejadah_ui` | 50 |
| `packages/ejadah_localization` | 8 |

`dart analyze` and `flutter analyze` are clean across every package. The
application is **70,522 lines of Dart across 259 files**; there is no JavaScript,
TypeScript, PHP or Vue anywhere in `apps/`, `packages/` or `server/`. The single
`apps/mobile/web/index.html` is Flutter's own generated bootstrap. The `.html`
under `reference/` and `uploads/` are the preserved design prototypes, read as
specification and never ported.

## The smoothness sweep

Done, in the order the owner set — 8 of 8, item 5 having been voided by the
Downloads cut rather than left open:

1. **Swipe-back everywhere.** The theme had no `pageTransitionsTheme` at all,
   so Android's default `ZoomPageTransitionsBuilder` gave no drag-to-dismiss —
   on the phones most of this product's users hold, the app-bar arrow was the
   only way out of an interior screen. One `CupertinoPageTransitionsBuilder`
   for every platform, and a test that drags a route away on Android, on iOS,
   and from the right edge in Arabic.
2. **Per-tab scroll memory** — already in place: `StatefulShellRoute` keeps
   each branch alive and every tab root carries a `PageStorageKey`.
3. **Filter persistence.** Career and each People door already persisted;
   Learn's format filter was process-lifetime only, with a comment naming
   exactly what was missing. It now goes through `LocalStore` like the others.
4. **Skeletons on the three lists** — already in place on all three.
5. **Optimistic + Undo.** Shortlist remove has it, with a five-second window.
   Download delete is **void**: LN-11 Downloads is cut (owner decision, 16 Aug
   2026), so there is no download to delete. Nothing is outstanding here.
6. **40ms stagger-in, once.** The `staggerListMs` token existed and nothing
   used it. `StaggeredIn` + `StaggerGroup` now do, on all three lists. "Once"
   is the whole design and it is what the group is for — a stagger that
   replays every time a recycled row scrolls back reads as a stutter, then as
   a bug. Capped at six items, or item 200 would wait eight seconds.
7. **Sticky bars.** Extracted `EjadahStickyBar` after writing the same
   container by hand four times. Plan, CV editor, tutor application, earnings
   and the NFC card's share action all use it; the last two did not have a
   sticky bar before.
8. **Disabled-reason audit.** Every `onPressed: … ? null : …` in the app was
   read. Six had no reason: the IAP buy button while restoring, account
   deletion before the confirmation word matches, the NFC editor on an invalid
   link, the plan builder's copy-forward before week 1 is chosen, the
   flashcards "Again" button (whose sibling showed a spinner and it did not),
   and the file picker when the form is locked. All six now explain
   themselves, and on a sticky bar the reason sits *above* the button rather
   than only behind a tap on it.

## Known gaps in what is built

* **Cairo time is a fixed +02:00 offset.** Egypt reinstated summer time in
  2023, so displayed times run an hour behind during it. Owner decision of
  15 Aug 2026: keep the fixed offset and make the copy honest — every screen
  and every reminder now names the zone ("Cairo time" / «بتوقيت القاهرة») and
  no string says "GMT+2". The offset lives in one place per side, `CairoClock`
  on the server and `CairoTime` in the app, so closing the gap is a data change
  (IANA `Africa/Cairo`) rather than a redesign.
* **Downloads is cut, not missing.** Owner decision, 16 Aug 2026, recorded as
  conflict 12 in `REGISTER.md`. Lessons stream and handouts open in the
  platform's viewer; nothing is written to the device. The wifi-only setting
  and the keep-downloads logout branch went with it, and `incHandouts` was
  reworded from "Downloadable handouts", which the cut made untrue.
* **Video playback is a surface.** Position, five-second checkpointing, the
  ten-second resume rule and completion are all real and server-backed; the
  player advances a playhead on a timer until a media dependency is added.
* **In-app purchase is not verified against the store.** The path exists and
  deliberately fails rather than granting entitlement on an unverified receipt.
  On the pre-submission checklist, not the build order: it needs real store
  credentials.
* **Uploaded files live on local disk.** `LocalFileStore` is the only
  implementation of `FileStore`; a single VM is fine for it, and moving to
  object storage changes that one class and nothing that calls it. There is no
  virus scanning and no image re-encoding — a certificate is served back as the
  bytes that arrived, always as an attachment with `nosniff`, never inline.
* **A payout request is not a transfer.** `POST /earnings/payouts` moves the
  ledger rows to `requested` and stops there. Nothing in this repository marks
  one `paid` — that is the admin panel's job, and until it exists a request is
  a message nobody reads. The states are honest about it: a tutor is never told
  they were paid on the day they asked.
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
