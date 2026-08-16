# Implementation status

Honest state of the build against the locked Phase 1 scope
(`handoff-flutter/01-product/PRODUCT_CORE.md` §2, 28 features).

Legend: **COMPLETE** · **PARTIAL** (reachable, but missing named elements of
its screen spec) · **NOT BUILT** (in the inventory, no screen and no route) ·
**CUT** (owner decision, deliberately absent) · **BLOCKED** (needs something
this repository cannot supply) · **FUTURE** (out of Phase 1 scope — must not be
built).

**Phase 1 is closed.** Feature work stopped on 16 August 2026 and the build
went through a hardening pass — a clean-checkout test run, the visual QA
checklist, an accessibility sweep and a store-readiness review. What that pass
found is in [`visual-qa.md`](visual-qa.md) and
[`pre-submission-checklist.md`](pre-submission-checklist.md); what it changed is
in the rows below.

Last updated: 16 August 2026.

---

## Summary

All five tabs are built and every module is mounted: Flutter UI → Riverpod
controller → typed client → Dart server → PostgreSQL → back, in both languages.
The two guarantees the brief singles out as mandatory — roadmap determinism and
booking concurrency-safety — are implemented and proven by test against real
PostgreSQL.

Rows below say COMPLETE only where the screen matches its entry in
`04-screens/SCREENS.md`, not merely where something renders.

**The Phase-1 ledger, honestly:**

| | Count |
|---|---|
| COMPLETE | 45 |
| PARTIAL — reachable, missing named elements | 7 |
| NOT BUILT — in the inventory, no screen | 3 |
| CUT — owner decision | 1 |
| BLOCKED on something outside this repository | 2 |

Two things that reading only the COMPLETE count would hide. **Programme detail
moved from COMPLETE to PARTIAL** — it renders ten key facts and the sources
block, and the delivery backlog's story P-2.2 asks for eight sections it does
not have. The shipped string table has no keys for any of them, so the app
matches its own source of truth and the backlog line is the one that is
probably stale — but only the owner can say which, so the row is honest in the
meantime. And **three screens in the inventory were never built**; they were
never cut either, so they are listed rather than left implied.

---

## Platform foundation

| Area | Status | Notes |
|---|---|---|
| Flutter workspace + packages | COMPLETE | apps/mobile, ejadah_ui, ejadah_core, ejadah_models, ejadah_localization |
| Dart backend (Shelf, layered) | COMPLETE | route → service → domain → repository → SQL |
| PostgreSQL schema | COMPLETE | 10 migrations, constraint-enforced product rules |
| Design tokens | COMPLETE | generated from `DESIGN_TOKENS.json`, elevation included; raw values are defects |
| Ejadah component family | COMPLETE | buttons, cards, badges, inputs, sheets, states, bottom nav |
| Gradient budget enforcement | COMPLETE | debug assertion at six per screen, and the shell carries its own budget for the tab indicator — which sits in `bottomNavigationBar`, outside every route's scope |
| Typography (EN + AR rules) | COMPLETE | families, line-heights, tracking, −12% long headings |
| Bundled fonts | COMPLETE | Playfair, Inter, Amiri, IBM Plex Sans Arabic, OFL, licences recorded |
| Localization (EN/AR) | COMPLETE | 684 keys, key-identical, build fails on divergence |
| RTL | COMPLETE | locale-driven `Directionality`, logical edges, mirror list, bidi islands. Mirroring is asserted on what is painted, not on the list — the list was right while twenty chevrons were rendering backwards |
| Routing + deep links | COMPLETE | canonical paths, guards, public routes, single cold-start navigation |
| API client | COMPLETE | single-flight refresh, timeouts, typed failure translation |
| Error architecture | COMPLETE | ten typed failures carrying the approved bilingual copy |
| Analytics abstraction | COMPLETE | canonical event names, required properties stamped, privacy list enforced |
| Storage abstraction | COMPLETE | `FileStore` with a local implementation, upload and download routes, type decided by magic bytes, owner-only reads, 5 MB cap, recorded in `stored_files` |
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
| Programme detail | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — ten key facts, the recognition caveat and the sources block naming the regulator or saying Not verified. The prototype and backlog story P-2.2 ask for eight further sections (overview, curriculum, requirements, application guide, scholarships, after the MSc, living and visa, FAQs); no string key exists for any of them, so the app matches the string table. See `visual-qa.md` D5 — needs an owner ruling |
| Shortlist + optimistic save/undo | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| 23 country guides (4 tabs) | ✅ | ✅ | ✅ | ✅ | ✅ | — | PARTIAL — all three crossings and the list's chips and live count are in; no jump-pills or FAQ accordion |
| Roadmap generator + gate | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — share row is in and ungated; no per-stage SourceLine list |
| Roadmap funnel (guest-capable) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| Guest → account migration | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE |
| What-if scenarios | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — six presets, each a new roadmap linked to the original |
| Compare programmes (≤3) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE — selection survives paging and filtering |
| Compare countries (≤3) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE — long-press to pick, so the tap still opens the guide |
| Saved-filter alerts | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | COMPLETE — up to 5 watched searches, one alert per search per day |
| Career-scoped search screen (CR-18) | — | ✅ | ✅ | — | — | — | NOT BUILT — the server side answers; there is no screen, no route and no scoped-note string. The only search is the programme database's own field |
| My roadmaps (CR-08) | — | ✅ | ✅ | — | — | — | NOT BUILT — roadmaps are saved and reachable by id, and CR-07 what-if is built inside the result screen; there is nowhere to list them |
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
| Activation checklist (HM-03) | — | — | — | — | — | — | NOT BUILT |
| **Platform** |
| Notifications (3 categories) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | PARTIAL — scheduling, quiet hours, the daily cap and the centre are all in; no OS permission priming sheet, and no push transport |
| Premium status (read-only) | ✅ | ✅ | ✅ | ✅ | ✅ | — | COMPLETE — status and renewal date, never prices |
| System states (10) | ✅ | ✅ | — | ✅ | ✅ | ✅ | COMPLETE — one template, ten screens, a failure registry and a root error boundary |
| Admin panel | — | — | ✅ | — | — | — | BLOCKED — web-only and deliberately outside this repository. The two flows that cannot wait for it — approving a tutor, marking a payout sent — are run by hand from `operations.md` and logged in `ops-log.md` |

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

Counts from a **fresh clone of this branch** — cloned, resolved and run, not
carried over from a working tree that had already been warmed up:

| Suite | Count |
|---|---|
| `server` (`dart test`, real PostgreSQL) | 274 |
| `apps/mobile` (`flutter test`) | 182 |
| `packages/ejadah_ui` | 64 |
| `packages/ejadah_localization` | 8 |
| **Total** | **528** |

`ejadah_models` and `ejadah_core` have no test directories of their own; every
behaviour they carry is exercised through the packages above.

The clean checkout is also what caught two things a warm tree hides.
`./tool/dev.sh test` — the command the README, `deployment.md` and
`local-development.md` all point at as "every suite" — exited 65 at its second
step and had done so since it was written, because it named a package with no
`test/` directory and `set -e` stopped the run there. It also never named
`ejadah_localization`, so the guard tests that keep the two string tables
key-identical were outside the command that claims to run everything. The target
now discovers packages instead of listing them, and there is a `dev.sh analyze`
beside it.

`dart analyze` and `flutter analyze` are clean across every package. The
application is **73,239 lines of Dart across 267 files**; there is no JavaScript,
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
* **The refresh token is not in the Keychain, on any platform.** `TokenStore`
  uses `SharedPreferences` everywhere, native included — an earlier version of
  this line said native builds used secure storage, and that was not true. On
  Android that means app-private storage, which is reasonable on a non-rooted
  device; on iOS it means `NSUserDefaults`, which is **included in device and
  iCloud backups**; on web it means `localStorage`, which any script in the
  origin can read. Web is an accepted owner decision (preview surface,
  native-first, a banner in debug builds saying so). The native half is not, and
  it is item 3.1 on the store-submission checklist: the fix is
  `flutter_secure_storage` behind the existing interface, and it wants one run on
  real hardware before it lands, because a token store that compiles but does not
  persist signs every user out on relaunch.
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
* **Compare is a horizontal table on a phone**, which `DESIGN_SYSTEM.md` forbids
  by name. The code carries a comment arguing the case, which makes it a
  disagreement with the design system rather than an oversight. `visual-qa.md`
  D1 — owner ruling.
* **No flag asset exists.** The manifest requires 23 bundled flags and says
  never to fetch them at runtime. Nothing is fetched, and nothing is bundled
  either: `apps/mobile/assets` does not exist. Programme and country cards both
  name the flag first in their anatomy and render none.
* **Five components exist twice or not at all** — two initials avatars with
  different shapes and different initials rules, three rating displays with no
  canonical `RatingStars`, a second hand-built price display on the earnings
  screen, an `EjadahListRow` whose documented default chevron does not exist,
  and three progress bars at two heights. `visual-qa.md` D3.
* **`/bookings` and `/notifications` are each reachable from one conditional
  widget on Home.** A user with only past bookings cannot reach their own
  history. Both hub entries exist in the prototype and both sets of strings are
  already translated and unused. `visual-qa.md` D6.

## What Phase 1 closing means

Feature work stopped. Nothing on the cut list gets built, no screen in the
NOT BUILT rows above gets started, and the next change to this repository should
be one of three things: a decision from `visual-qa.md`, an item from
`pre-submission-checklist.md`, or a bug.

The four hardening passes and what each produced:

1. **Clean checkout.** Cloned fresh, resolved, analyzed and run: 528 tests
   green, no analyzer issue in any package. Found that the project's own
   "run every suite" command had never worked end to end.
2. **Visual QA**, screen by screen in both languages against the prototypes.
   Ten fixes, eleven divergences logged for an owner decision. Two of the fixes
   were bugs a rule-level test could not see — the suite asserted
   `mirrorsInRtl(chevron) == true` and `maxPerScreen == 6`, both of which were
   true while the screen was wrong.
3. **Accessibility.** A new sweep over the whole interactive catalog in both
   languages: 44×44, a label on every target, AA contrast on what is painted,
   200% type, reduce-motion. Verified against a deliberately broken catalog
   before being trusted. Found four real 200% failures, all fixed.
4. **Store readiness.** Four Flutter scaffold defaults fixed — the app was
   called `ejadah_mobile` on the home screen, release builds were signed with
   the debug key, iOS declared no Arabic, and export compliance was unanswered.
   Privacy-label answers for both stores derived from the code rather than from
   intent.

Three things are true at once and all three belong in the same paragraph. The
product works end to end in both languages, and the two guarantees the brief
called mandatory are proven by test against a real database. There are eleven
logged divergences and three unbuilt screens, none of which anyone should
discover by using the app rather than by reading this file. And nothing here can
be installed from a store until the owner supplies a keystore, an icon,
screenshots and store credentials — which is a different kind of incomplete from
the first two, and the reason it has its own document.
