# Product Core — Overview · Scope · Personas · IA
### Combines: PRODUCT_OVERVIEW, PHASE1_SCOPE, PERSONAS, INFORMATION_ARCHITECTURE
**Companion narrative: `../../EJADAH-BUILD-STORY.md` (read it — it carries the *why* behind every line here).**

---

## 1 · Product overview

**Problem.** Egyptian dentists planning careers abroad rely on stale forum posts and agencies quoting wrong fees. There is no single sourced, dated answer to "where can I go, what will it cost, how long will it take."

**Value proposition.** Verified, dated licensing and postgraduate data (199 programmes, 23 country guides), a deterministic roadmap built from that data against the user's *real* budget and time, and the humans to help (tutors, mentors who made the move, consultants) — all in Arabic first.

**Product loops.**
- *Retention:* saved-programme deadline alerts (30/14/7 days) + flashcard daily due queue.
- *Activation:* guest roadmap funnel → gate at the result → free account.
- *Growth:* NFC public profile + WhatsApp-first sharing of roadmaps/programmes (never gated).
- *Revenue:* courses (IAP, one-off) + sessions (70/30 split, external checkout) + physical card.

**Trust principles.** Our data only; no AI inference; "Pending source" instead of any guess; verified vs stated credentials visibly distinct; every fact carries `verified_on` + source.

## 2 · Phase 1 scope — locked (28 features)

**Learn (4):** recorded courses (hub→list→detail→player) · downloadable handouts · spaced-repetition flashcards · course quizzes with explanations.
**Career (8):** programme database (199, paginated, expired hidden by default) · programme detail · programme comparison (≤3) · shortlist with Home deadline surfacing · saved-filter alerts · 23 country guides · country comparison (≤3) · roadmap generator + what-if.
**People (7):** tutoring · mentoring (destination-matched) · consulting · 8-step booking + week-by-week multi-session plans · 6-step tutor onboarding + first-student playbook · tutor earnings (70/30 itemised) · my bookings.
**Profile (5):** NFC digital card + editor · public profile (`/dr/{slug}`) · certificates (verified vs stated) + public verification · CV builder (upload-first) · CPD ledger.
**Platform (4):** notifications (3 categories, no marketing) · Premium status (read-only, renewal 30 Jan 2027, no prices) · settings + account deletion · the 10 system screens.

**Explicitly OUT (do not build, do not stub):** exams/question banks/mocks/analytics · live classes/Live Academy/clinical demos · dental library/research hub · AI assistants (any) · community/user-to-user messaging · achievements · accreditations page · private group training · global search · admin (web-only) · checkout/billing UI beyond the redirect sheet.

## 3 · Personas

| Persona | Goal | Home CTA | Primary tabs | Visibility notes |
|---|---|---|---|---|
| **Dental student** | Pass this term | Term plan / flashcards due | Learn, People (tutoring) | Roadmap funnel branches: "I'm still studying" must not produce an emigration route |
| **Fresh graduate** | Decide the emigration question | Build your roadmap | Career | Highest-intent signup; gate converts them |
| **GP dentist** ★core | Execute a chosen route | Roadmap progress / next stage | Career, People (mentoring) | The one complete journey — protect it |
| **Specialist** | Standing, CPD, being found | Set up your professional card | Profile, Learn | Never show emigration CTA |
| **Consultant/owner** | Clinic problems | Consulting entry | People (consulting) | Thinnest funnel; low volume, high ticket |
| **Tutor/mentor/consultant (supply)** | Fill hours, get paid | Teaching dashboard | People (supply views) | Sees earnings, availability, playbook; approval-gated |
| **Admin** | Verification, payouts, freshness | — | Web only | Not in the app |

## 4 · Information architecture — the one definitive tree

**Tabs: Home · Learn · Career · People · Profile.** (Prototype label mapping: Courses→Learn, Connect→People, Masters merged into Career.)

```
HOME (PRIMARY)
├─ Feed: greeting/streak · continue row · roadmap card/CTA · upcoming session
│        · saved-deadline strip · matched tutors · explore tiles      (sections, not screens)
├─ Notification centre                                   SECONDARY
├─ Activation checklist                                  SECONDARY
├─ Recently viewed                                       SECONDARY
└─ Notification permission priming                       SHEET

LEARN (PRIMARY)
├─ Department hub (Orthodontics · Digital · Business & Paradental)
├─ Course list (format filter, count)                    SECONDARY
├─ Course detail (overview/curriculum; lock states)      SECONDARY
├─ IAP purchase sheet (digital content — never external) SHEET
├─ Course player (resume ≤10s, landscape)                MODAL full-screen
├─ Lesson complete (5s auto-advance + cancel)            SECONDARY
├─ Handouts (PDF, size, offline)                         SECONDARY
├─ Flashcards (deck → session → summary)                 SECONDARY
├─ Quiz (per-question feedback → score; <60% offers 1 session) SECONDARY
├─ Course complete (certificate earned)                  SECONDARY

CAREER (PRIMARY)
├─ Career hub (roadmap entry · database entry · guides grid · shortlist tile)
├─ Roadmap funnel Q1–Q4 (guest-capable)                  SECONDARY
├─ Generating (min-display pacing)                       SECONDARY
├─ Roadmap result (gate for guests: 2 visible, rest blurred) SECONDARY
├─ What-if (6 presets → NEW roadmap, original kept)      SHEET→SECONDARY
├─ My roadmaps (scenarios nested under parent)           SECONDARY
├─ Programme database (search, filter sheet, 12/page)    SECONDARY
├─ Programme filter                                      SHEET
├─ Programme detail (costs, docs, sources, save)         SECONDARY
├─ Deep programme profile (King's pattern)               SECONDARY
├─ Compare programmes (≤3)                               SECONDARY
├─ Shortlist (optimistic remove + Undo)                  SECONDARY
├─ Country guide list (region + pathway-class chips)     SECONDARY
├─ Country guide detail (4 tabs: Pathway/Docs/Costs/Recognition) SECONDARY
├─ Compare countries (≤3)                                SECONDARY
└─ Career search (recent + suggestions; NOT global)      SECONDARY

PEOPLE (PRIMARY)
├─ Hub: Tutoring · Mentoring · Consulting (three doors)
├─ List per kind (filters persist; "New this month" rail) SECONDARY
├─ Tutor/mentor/consultant profile (verified quals, packages
│   with cadence sentences, availability, reviews, cancel terms,
│   sticky book bar; free intro call where enabled)      SECONDARY
├─ Booking steps 1–8 (hold + countdown at slot pick)     SECONDARY
├─ Custom plan builder (cadence dials → week stepper)    SECONDARY
├─ Payment redirect sheet ("completed securely on ejadah.international") SHEET
├─ Payment returned (success / not completed + retry)    SECONDARY
├─ My bookings (Upcoming/Past/Cancelled; cancel states refund first) SECONDARY
├─ Review (attended bookings only, once)                 SHEET
├─ Become a tutor (pitch PUBLIC → 6 steps → status)      SECONDARY
├─ First-student playbook (on approval)                  SECONDARY
├─ Tutor dashboard: today · schedule · availability editor
│   (rules+exceptions) · earnings (gross/fee/net rows) · payout request SECONDARY (supply role)
└─ Instructor dashboard (courses, students)              SECONDARY (supply role)

PROFILE (PRIMARY)
├─ Profile home (avatar/initials, stage, Premium pill, grouped rows)
├─ Edit profile                                          SECONDARY
├─ NFC card (QR, share, order physical)                  SECONDARY
├─ NFC editor (live preview)                             SECONDARY
├─ Public profile view                                   PUBLIC (deep link /dr/{slug})
├─ Certificates (verified vs stated; add own)            SECONDARY
├─ Certificate verification                              PUBLIC (/verify/{code})
├─ CV builder (upload-first; no patient data warning)    SECONDARY
├─ CPD ledger                                            SECONDARY
├─ My subscription (Premium · renews 30 Jan 2027 · read-only) SECONDARY
├─ Invite a colleague (+1 month after the 6)             SECONDARY
├─ Settings (language, notif prefs ×3, cache, legal, version) SECONDARY
├─ Log out (keeps-downloads option)                      SHEET
└─ Delete account (2-step, states losses + tax-kept invoices) SECONDARY

FIRST RUN (before tabs)
splash → language pick → welcome ×3 → value teaser →
guest roadmap … gate → sign up → verify email (60s resend) →
onboarding ×4 → Premium status screen → Home
(also: login · forgot/reset password)

SYSTEM (one template, 10 states)
offline · server error · session expired · force update · maintenance ·
notif permission denied · camera permission denied · error boundary ·
content unavailable · rate limited

WEB-ONLY: admin panel · checkout/billing pages.
FUTURE (not designed): everything in the build-story cut list.
INTERNAL: Phase 0 Foundation sheet · audit canvases · prototype rails/persona switch.
```

**Auth model:** browse everything signed out; the gates are the roadmap *result*, saving/shortlisting, booking, purchasing, and Profile. Guest work (funnel answers) migrates to the account on signup — losing it is a critical defect.
