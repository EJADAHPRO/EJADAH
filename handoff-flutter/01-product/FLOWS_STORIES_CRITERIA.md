# Flows · Stories · Acceptance · Matrix · Glossary
### Combines: USER_FLOWS, USER_STORIES_PHASE1, ACCEPTANCE_CRITERIA, FEATURE_MATRIX, PRODUCT_GLOSSARY

---

## 1 · Critical flows (entry → steps → exits)

Format: **Entry** ⇒ steps ⇒ **Success** | Cancel | Error | Offline. AUTH marks the gate.

**First launch** — store open ⇒ splash (fonts+lang+auth resolve) ⇒ language pick (tap = action) ⇒ welcome ×3 (skippable) ⇒ value teaser ⇒ guest roadmap. No signup wall anywhere here.

**Guest roadmap → activation (THE flow)** — teaser/Career/Home CTA ⇒ Q1 path (single-select auto-advances) ⇒ Q2 stage+years (advances when both answered) ⇒ Q3 budget slider + time (hard limits; honest band hints) ⇒ Q4 regions+languages (multi → explicit Continue) ⇒ generating (deterministic, min-display pacing) ⇒ result: guest sees 2 stages + blur + gate ⇒ **AUTH** sign up ⇒ verify (60s resend cooldown) ⇒ onboarding ×4 ⇒ Premium status ⇒ **lands on the SAME roadmap, full**. Cancel: leaving funnel keeps draft (resume restores). Error: plain sentence + "your answers are saved" + retry/review. Offline: funnel answers queue; generation requires connection → offline state with retry.

**Browse→save programme** — Career ⇒ database (expired hidden; count visible) ⇒ filter sheet ⇒ detail ⇒ save = **AUTH** if guest; optimistic heart + toast w/ deadline; remove = optimistic + 5s Undo. Saved deadlines surface on Home sorted by urgency.

**Compare** — ≤3 via checkboxes on cards ⇒ compare bar ⇒ side-by-side; single-item state is honest, never an error.

**Country guide** — list (region + class chips, live count) ⇒ detail tabs ⇒ crossings: → matching programmes, → mentors who made the move, ← roadmap result deep-links in.

**Booking (single)** — profile ⇒ pick slot ⇒ **hold created immediately, countdown visible** ⇒ duration ⇒ subject+goal (≥10 chars; no patient data) ⇒ review (price + cancel terms) ⇒ redirect sheet → external checkout ⇒ returned: success→confirmed+notified | failure→hold released, slot back, honest message. Slot race: 409 → "someone booked that time a moment ago" + refreshed slots. Hold expiry: explain, confirm nothing charged, back to slots.

**Booking (plan)** — cadence dials (sessions/week × length × weeks; live quote from tutor's own tiers, next-tier stated once) ⇒ **week stepper: fill week 1 → tick → advance**; "same time every week" copies wk1 forward, reports unfillable weeks; submit disabled WITH reason until every week filled ⇒ one payment ⇒ all sessions confirm together. Never re-ask what the plan answered.

**Tutor onboarding** — pitch (PUBLIC, 70/30 visible) ⇒ **AUTH** ⇒ 6 steps, draft-saved each (basics/quals+docs/subjects/rate+live estimate w/ "assumes full booking"/availability grid ≥5h hint/media) ⇒ submit blocks name every missing item ⇒ status "reply in 3 working days" ⇒ approved → playbook (3 actions).

**Course purchase→learn** — hub ⇒ list ⇒ detail (lesson 1 always free preview; locked = padlock + "Not included") ⇒ IAP sheet (store-charged wording; restore purchases) ⇒ player (resume ≤10s; bg-safe) ⇒ lesson complete (5s auto +cancel) ⇒ quiz (<60% → offer ONE session, never blocks retry) ⇒ course complete → certificate (verified) → CPD.

**Certificates/NFC** — profile ⇒ card ⇒ share/QR ⇒ public profile (install CTA; analytics private) ⇒ verify page needs no account.

**Cancel booking** — booking detail shows the refund tier BEFORE the button ⇒ confirm sheet names exact amount ⇒ done. Tutor-cancel = always 100% to student.

**Notifications** — permission asked in-context after first save, never cold-start. 3 toggles; deadline pings at 30/14/7.

**Delete account** — losses listed ⇒ type-DELETE step ⇒ 30-day undo window stated.

## 2 · User stories (canonical set — Stage 6 .docx is DEAD)

Format: ID · persona · story · key acceptance (visual criteria live in §3 + screen specs). Analytics events named per `handoff/analytics-events.md`.

| ID | Persona | Story + decisive acceptance |
|---|---|---|
| **E1-01** | Any | *Pick my language first.* Two cards, tap acts, Arabic default; switch later is instant, no state loss. `language_selected` |
| **E1-02** | Fresh grad (guest) | *Complete the roadmap without an account.* All 4 Qs guest-capable; draft survives kill+relaunch. `roadmap_started/step_completed(ms_on_step)/abandoned` |
| **E1-03** | Guest | *See enough of my result to want an account.* 2 stages readable, rest blurred, gate lists 3 benefits + "no card"; `guest_gate_shown` once |
| **E1-04** | New user | *Sign up without losing my answers.* Guest→user migration; lands on same roadmap full. `account_created(from_gate)` |
| **E2-01** | GP | *A route my budget can survive.* Over-budget destination fit ≤60; watch-out names the USD gap; "stay in Egypt" reachable |
| **E2-02** | GP | *Trust every number.* Each stage = verbatim DB row; unverified fee prints "Pending source"; sources block shows regulator+date |
| **E2-03** | GP | *Change one thing, see the plan move.* What-if = NEW roadmap, parent linked, original intact; scenario labelled |
| **E2-04** | Any | *Filter 199 to my handful.* Expired hidden by default (150/199!); zero-result offers nearest relaxation; filters persist |
| **E2-05** | Any | *Watch a deadline for me.* Save→30/14/7 alerts; Home strip sorted by urgency; remove has Undo |
| **E3-01** | Student | *Learn on a Friday hour.* Player resumes within 1s at last position; downloads play offline |
| **E3-02** | Student | *Cards due today.* Due count on Home; got-it/again updates counts live; session summary |
| **E3-03** | Any | *Buy a course once, keep it.* IAP only; lesson 1 free; "yours for good" copy; restore works cross-device |
| **E4-01** | Fresh grad | *Talk to someone who made MY move.* Mentor list filters by destination; card leads with journey (Cairo→London, year) |
| **E4-02** | Student | *Book without being burned.* Hold+countdown; race→friendly 409; cancel tiers shown pre-booking AND pre-cancel with exact EGP |
| **E4-03** | Student | *One session a week, my times.* Week stepper; aggregate-hours question is a defect |
| **E4-04** | Tutor | *Know the deal before the effort.* 70/30 in step 1 AND itemised in the estimate; earnings rows show gross−fee=net |
| **E4-05** | Tutor | *Get my first student.* Playbook 3 checkable actions on approval; progress persists on dashboard |
| **E5-01** | Specialist | *Be found, credibly.* Verified≠stated visually distinct + explainer; public profile installs-CTA; analytics private, viewers never named |
| **E5-02** | Any | *Prove my certificate to a stranger.* /verify/{code}: no account, never charged |
| **E6-01** | Any | *The app works badly-connected.* Cached saved/roadmap readable offline; banner; actions disabled WITH reason |
| **E6-02** | Any | *Failures speak human.* All 10 system states route to action; no status codes; "your answers are saved" wherever true |

## 3 · Acceptance criteria — the finished-screen checklist

Every screen, before "done":
**Visual** — tokens only (no raw hex/radius/size); gradient ≤6, permitted uses only; band rhythm; matches golden reference.
**Interaction** — ≤100ms feedback; loading inside button, width frozen; optimistic+revert on reversible; destructive = consequence stated; disabled explains on tap; one primary per screen; sticky bar on >1-viewport screens with a single main action.
**States** — default/loading(skeleton)/empty(routes to action)/error(retry)/offline per SCREEN_STATE_MATRIX; partial where composed.
**Persistence** — survives backgrounding+restart: scroll per tab, filters, drafts, video position, active tab.
**RTL/AR** — renders both langs; mirrors per RTL_GUIDE; 0 tracking; no uppercase AR; LTR-isolated numerals/codes/currency; AR line-heights.
**A11y** — 44×44; labelled in active language; focus visible; 200% font no clip; reduce-motion honored; color-independent status.
**Localization** — every string from the maps; placeholders not concatenation; Western numerals.
**Analytics** — screen's events fire w/ lang, persona, version, ms_since_first_open.
**Deep links** — per `handoff/deep-links.md`; cold-start lands correctly, back goes to the tab root.

## 4 · Feature matrix

| Feature | Phase | Tab | Roles | Design state | Missing states | Data needs | Access |
|---|---|---|---|---|---|---|---|
| Home feed | P1 | Home | all 6 | complete (6 states) | — | aggregate of all | private |
| Notif centre | P1 | Home | all | complete | offline | notif list | private |
| Programme DB | P1 | Career | all | complete | **loading skeleton** | programmes.json | public browse |
| Programme detail/deep | P1 | Career | all | complete | — | programme+profile | public |
| Compare prog | P1 | Career | all | complete | — | ≤3 programmes | public |
| Shortlist+alerts | P1 | Career | signed-in | complete | — | saves+deadlines | private |
| Country guides ×23 | P1 | Career | all | complete | — | countries.js | public |
| Compare countries | P1 | Career | all | complete | — | ≤3 guides | public |
| Roadmap+what-if | P1 | Career | guest+ | complete | — | guides+programmes | guest→gate |
| Learn hub/list/detail | P1 | Learn | all | complete | **loading skeleton** | catalog | public browse |
| Player/handouts | P1 | Learn | owner | complete | offline-player doc | media | private |
| Flashcards/quiz | P1 | Learn | owner | complete | — | decks/questions | private |
| IAP purchase | P1 | Learn | signed-in | complete | — | products | private |
| 3 marketplaces | P1 | People | all | complete | **loading skeleton** | rosters ⚠placeholder | public browse |
| Booking+plan | P1 | People | signed-in | complete | — | availability | private |
| My bookings | P1 | People | signed-in | complete | — | bookings | private |
| Tutor onboard+playbook | P1 | People | supply | complete | — | application | private |
| Earnings/instructor | P1 | People | supply | complete | — | ledger | private |
| NFC card+editor | P1 | Profile | signed-in | complete | — | profile | private |
| Public profile | P1 | deep link | anyone | complete | — | profile | PUBLIC |
| Certificates+verify | P1 | Profile | mixed | complete | — | certs | verify PUBLIC |
| CV builder | P1 | Profile | signed-in | complete | — | cv fields | private |
| Subscription (read-only) | P1 | Profile | signed-in | complete | — | status | private |
| Settings/delete/logout | P1 | Profile | signed-in | complete | — | prefs | private |
| System screens ×10 | P1 | — | all | complete | — | — | — |
| Admin / checkout | P1 | — | admin | — | — | — | **WEB-ONLY** |
| Everything in cut list | FUTURE/LEGACY | — | — | not designed | — | — | do not build |

## 5 · Glossary — canonical EN/AR terms (one translation per concept, everywhere)

| Term | EN | AR | Note |
|---|---|---|---|
| Programme | Programme | برنامج | postgrad degree offering; never "program" in UI EN |
| Course | Course | دورة | Ejadah recorded content |
| Lesson | Lesson | درس | |
| Roadmap | Roadmap | خارطة المسار | |
| Country guide | Country guide | دليل الدولة | |
| Tutor / Mentor / Consultant | Tutor/Mentor/Consultant | مدرّس / مرشد / مستشار | mentor = made the move |
| Booking / Session | Booking / Session | حجز / جلسة | booking=record, session=event |
| Certificate | Certificate | شهادة | |
| Verified / Stated | Verified by Ejadah / Stated by the tutor | موثّق من إجادة / مُقدَّم من المدرّس | never conflate |
| Not verified | Not verified | غير موثّق | data state, not judgement |
| Pending source | Pending source | بانتظار المصدر | exact strings, no variants |
| Shortlist | My shortlist | قائمتي المختارة | |
| Deadline | Deadline | موعد التقديم | |
| Intake | Intake | موعد البدء | |
| NFC card | Ejadah card | بطاقة إجادة | |
| Premium | Premium | بريميوم | renewal 30 Jan 2027 |
| Free intro call | Free intro call | مكالمة تعريفية مجانية | 15 min |
| CPD | CPD points | نقاط CPD | Latin "CPD" both langs |
| Fit score | Fit | ملاءمة | 0–100 |
| Watch-out | The honest watch-out | تحذير صريح | |
| Latin-always | ORE·ADC·NDEB·INBDE·SDLE·DHA·DOH·MOHAP·SCFHS·QCHP·NHRA·GDC·Prometric·Pearson VUE·DataFlow·IELTS·exocad·3Shape·EGP·USD·AED·SAR | same, bidi-isolated | never transliterate |
