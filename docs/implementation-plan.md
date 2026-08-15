# Ejadah — Implementation Plan

**Produced before implementation, per master brief §108.**
Source of truth: `handoff-flutter/` (canonical). This document records how that
specification is translated into Flutter + Dart + PostgreSQL. It does **not**
restate design specification — it references it.

---

## 1 · Current handoff summary

### Product
A bilingual (Arabic-default) platform for Egyptian dental professionals planning
careers abroad. Verified data only: **199 postgraduate programmes**, **23 country
licensing guides**, a **deterministic** career-roadmap generator, three
one-to-one marketplaces (tutoring / mentoring / consulting), recorded courses,
and an NFC professional identity card.

### Phase 1 scope — 28 locked features
`handoff-flutter/01-product/PRODUCT_CORE.md` §2.

| Group | Count | Features |
|---|---|---|
| Learn | 4 | recorded courses (hub→list→detail→player) · handouts · spaced-repetition flashcards · quizzes with explanations |
| Career | 8 | programme database (199) · programme detail · compare ≤3 · shortlist + deadline surfacing · saved-filter alerts · 23 country guides · country compare ≤3 · roadmap + what-if |
| People | 7 | tutoring · mentoring · consulting · 8-step booking + multi-session plans · 6-step tutor onboarding + playbook · tutor earnings (70/30) · my bookings |
| Profile | 5 | NFC card + editor · public profile `/dr/{slug}` · certificates (verified vs stated) + public verification · CV builder · CPD ledger |
| Platform | 4 | notifications (3 categories) · Premium status (read-only) · settings + account deletion · 10 system screens |

**Explicitly out (do not build, do not stub):** exams/question banks · live
classes · dental library/research hub · AI assistants of any kind ·
community/user-to-user messaging · achievements · global cross-content search ·
course prices outside IAP · six-tab navigation.

### Navigation
Five tabs: **Home · Learn · Career · People · Profile**. Prototype label mapping
(Courses→Learn, Connect→People, Masters→Career) is resolved in
`09-handoff/REGISTER.md` row 1 — the five-tab structure wins over any six-tab
material anywhere in the repository.

### Design system
`03-design-system/DESIGN_TOKENS.json` is the single source of visual constants;
raw values in code are defects. Brand gradient red→orange→gold, **≤6 gradient
elements per screen** on six permitted uses only. Warm off-white surfaces
(`#FFF9EF`), cards white with 1.5px `#E7E2DA` border at radius 20. Type: Playfair
Display + Inter (EN), Amiri + IBM Plex Sans Arabic (AR).

Two contrast corrections are load-bearing: orange `#FF6B1A` is **fills and icons
only** — orange *text* must be `#C2450F`; muted micro-labels are `#6B6862` and
`#8E8A83` is banned.

### Localization
Arabic is default and first-class. EN/AR string tables are key-identical (337
keys each, verified). Western numerals in both languages. Latin exam codes and
currency are bidi-isolated LTR islands. AR letter-spacing always 0, no uppercase,
raised line-heights, and headings shrink 12% above 28 characters.

### Primary user flows
`01-product/FLOWS_STORIES_CRITERIA.md` §1. The decisive one is **guest roadmap →
activation**: a guest completes all four funnel questions with no account, the
gate falls *between* the funnel and the full result (2 stages readable, rest
blurred), and after signup the user lands on the **same roadmap, full**. Losing
guest work at that boundary is a critical defect.

---

## 2 · Proposed technical architecture

```
apps/
  mobile/            Flutter app (Android · iOS · Web)
packages/
  ejadah_ui/         design tokens + the Ejadah* component family
  ejadah_core/       failures, result type, http client, analytics, storage
  ejadah_models/     typed domain models shared by app and server
  ejadah_localization/ ARB-generated EN/AR strings + bidi helpers
server/              Dart backend (Shelf) — modular monolith
tool/                dev scripts, importers, seeders
```

### Client
**Flutter** (stable 3.47, Dart 3.13). **Riverpod** for state (presentation /
server / auth / form state kept separate; no business logic in widgets).
**go_router** for routing with deep links, auth guards and public routes.

### Server framework — decision
**Shelf + shelf_router**, not Serverpod.

The brief prefers Serverpod "unless repository analysis reveals a strong reason
another Dart-native server framework is substantially better". Three
project-specific reasons make Shelf the better fit here, and the decision is
recorded in `docs/architecture.md`:

1. **Public unauthenticated routes are core product surface.** `/dr/{slug}`,
   `/verify/{code}` and guest roadmap generation are growth and trust loops.
   Shelf lets authentication be per-route middleware rather than the ambient
   session model Serverpod centres on.
2. **The schema is dataset-shaped, not codegen-shaped.** The canonical data (199
   programme rows with 40 fields, 23 bilingual guides with nested steps) is
   imported from fixed files and queried with deliberate SQL — server-side
   filtering, pagination, and the booking concurrency guarantee all want
   hand-written SQL with explicit locking, not generated CRUD.
3. **Booking concurrency is a hard requirement** (§51). `SELECT … FOR UPDATE`
   inside an explicit transaction, plus an exclusion constraint, is the
   guarantee; that is clearest with direct connection control.

Shelf is Dart-native, is the foundation Dart Frog itself builds on, and keeps
the whole product in one language as required.

### Layers (server)
```
Route handler  →  Application service  →  Domain  →  Repository  →  PostgreSQL
```
No SQL in handlers. No HTTP types below the handler.

### Database
**PostgreSQL 16.** Hand-written, ordered, idempotent SQL migrations run by a
Dart migration runner. Foreign keys, unique constraints, indexes on every
filtered column, `created_at`/`updated_at` on every table, UTC everywhere.

### Supporting architecture
| Concern | Approach |
|---|---|
| Auth | Argon2id password hashing; JWT access (15 min) + opaque refresh token with rotation, reuse-detection and revocation |
| Authorization | Server-side capability checks per route; roles: student, professional, admin. Frontend visibility is never authorization |
| Storage | `StorageProvider` interface; local filesystem in dev, S3-compatible in production. Server-side MIME/extension/size/ownership validation |
| Notifications | Preferences + server-scheduled notifications table; background job runner sends at 30/14/7 days. Permission asked in-context, never at cold start |
| Analytics | `AnalyticsService` interface; canonical event names from `handoff/analytics-events.md`; wrapper stamps lang/persona/version/ms_since_first_open |
| Payments | `PaymentProvider` interface + `DevPaymentProvider` (success/failure/cancel/refund) that is refused at boot in production. Courses = IAP only; sessions = external checkout; card = external. Never harmonised — this split is legal |
| Background jobs | In-process scheduler in the Dart server: hold expiry, deadline reminders, session reminders |

---

## 3 · Domain model

**Identity** — `users` · `user_roles` · `refresh_tokens` · `email_verifications`
· `password_resets` · `notification_preferences` · `audit_log`

**Career** — `programmes` (199 imported rows, 40 source fields normalised) ·
`countries` (23 guides) · `country_steps` · `country_costs` · `country_documents`
· `country_faqs` · `saved_programmes` (shortlist) · `saved_filters`

**Roadmap** — `roadmap_answers` (draft, guest-capable via device token) ·
`roadmaps` (result, `parent_id` for what-if scenarios) · `roadmap_stages`

**Learn** — `courses` · `lessons` · `enrollments` · `lesson_progress` ·
`handouts` · `flashcard_decks` · `flashcards` · `flashcard_reviews` · `quizzes` ·
`quiz_questions` · `quiz_options` · `quiz_attempts` · `quiz_answers`

**People** — `professionals` (shared across tutoring/mentoring/consulting) ·
`professional_qualifications` · `professional_packages` ·
`availability_rules` · `availability_exceptions` · `bookings` ·
`booking_sessions` (one row per scheduled session — never a vague "8 sessions"
object) · `booking_holds` · `reviews` · `tutor_applications` · `earnings`

**Commerce** — `payments` · `payment_events` (idempotency ledger) ·
`entitlements`

**Profile** — `profiles` · `public_profiles` (slug) · `certificates` ·
`cpd_entries` · `cv_sections`

**Platform** — `notifications` · `scheduled_jobs` · `analytics_events`

---

## 4 · Import strategy

All importers are Dart, reproducible, validating and idempotent (upsert on a
natural key), under `tool/`:

| Tool | Source | Target |
|---|---|---|
| `tool/import_programmes.dart` | `data/programmes.json` (199 records) | `programmes` |
| `tool/import_countries.dart` | `data/countries.js` (`window.EJADAH_COUNTRIES`, 23 guides, bilingual, nested steps/costs/docs/FAQs) | `countries` + child tables |
| `tool/generate_arb.dart` | `handoff/strings.en.json` / `strings.ar.json` | `packages/ejadah_localization/lib/l10n/*.arb` — keys 1:1, build fails on a missing key |
| `tool/seed.dart` | authored demo fixtures | courses, professionals, bookings, certificates, demo accounts |

Datasets are never retyped by hand. Import validates row counts, required
fields, and the deadline-status distribution (150 of 199 expired) before commit.

**Data honesty rule carried into the importer:** a missing or unverified fee is
stored as `null` with `source_status = 'pending'` and renders the exact string
"Pending source" / "بانتظار المصدر". The importer must never substitute an
estimate.

---

## 5 · Implementation phases

| Phase | Content |
|---|---|
| **0** | Audit + this plan (done) |
| **1** | Monorepo, tokens, design system, localization/RTL, routing, API client, error architecture, DB migrations, auth foundation, importers |
| **2** | First vertical slice, proving the architecture end to end: launch → language → Career → programme list (server-filtered) → detail → save → PostgreSQL → restart → still saved |
| **3** | Career complete: filters, compare, country guides, shortlist, deadlines, roadmap engine + funnel + gate + what-if |
| **4** | Learn: catalogue, entitlement, player position, flashcards, quizzes |
| **5** | People: professionals, availability, booking with holds and concurrency safety, payments abstraction |
| **6** | Profile: NFC/public profile, certificates + public verification, settings, deletion |
| **7** | Platform: notifications, analytics, deep links, storage, background jobs |
| **8** | Hardening: RTL audit, accessibility, golden tests, E2E, security review, performance, production builds, documentation |

---

## 6 · Risks and blockers

**Genuine blockers (owner decisions — isolated, do not stop the build):**

1. **Vector logo master** (conflict register #9, `OWNER DECISION REQUIRED`). Two
   JPGs exist, no vector, no dark variant, no app-icon master. Blocks store
   assets only. Mitigation: the app icon uses the documented gradient-tile
   pattern (Brand Guide §3) until a master is supplied.
2. **Real rosters and photographs** (todo #30). Every tutor/mentor/consultant
   photo in the prototype is a placeholder and is unlicensed for production.
   Mitigation: initials avatars on `paleGray`, never a broken image; seed data is
   clearly marked development-only.
3. **11 pending regulator fees** (todo #32). These are unverified and must print
   "Pending source". This is implemented as a first-class data state, not a gap
   to fill.
4. **Arabic clinical-terminology review** (todo #31). Strings ship as authored in
   `strings.ar.json`; no machine translation is introduced anywhere.

**Engineering risks:**

- *Booking concurrency* — mitigated by transactional `FOR UPDATE` + a database
  exclusion constraint, proven by a mandatory concurrent-booking test.
- *Roadmap reproducibility* — the "same inputs, same output" claim is the trust
  proposition; mitigated by a pure domain service with named constants,
  deterministic tie-breaks (score → lower cost floor → country code) and a
  determinism test.
- *Gradient discipline* — a debug-mode counter asserts ≤6 gradient elements per
  screen so the visual identity cannot erode silently.
- *Guest→account migration* — losing funnel answers at the gate is called out in
  the handoff as a critical defect; covered by an explicit test.

---

## 7 · Definition of done (per feature)

Flutter UI matching the golden reference · works EN · works AR · RTL correct ·
responsive · real server operation · PostgreSQL persistence · validation ·
authorization · loading / empty / error states · analytics · tests.
