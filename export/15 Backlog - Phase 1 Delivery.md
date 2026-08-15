# Ejadah — Phase 1 Delivery Backlog
### Replaces: "Ejadah International Academy — Stage 6 Backlog" (8 epics, 67 stories)
**Rebuilt 30 July 2026 · supersedes the Stage 6 document entirely**

---

## Part 1 — What the original file was

A sprint-ready engineering backlog. Eight epics, 67 user stories in INVEST format, each with acceptance criteria and a "Validate" block of edge cases, plus a sprint sequencing table and three architectural warnings.

**Who it was for:** a development team or agency, to build from. Not investors, not marketing.

**The job it was meant to do:** turn product intent into work that can be estimated, built, and tested without the builder having to guess. Judged on that job, it is the most useful document in the set — and also the most dangerously out of date.

---

## Part 2 — Diagnosis

**What is genuinely good, and should survive:**

The acceptance criteria are specific enough to test. Not "the form should validate" but "submitting with an Arabic name containing Latin characters must display: *Please enter your name in Arabic*." That is real work, and whoever wrote it had built software before.

The "Validate" blocks are edge cases, not restatements — superseded OTPs, idempotent purge jobs, partial records on network timeout. Most backlogs skip exactly this.

The three architectural warnings at the end show the best judgement in the document: build row-level security before anything touches the database, build auto-archive before the first content publishes, get the payment state machine right on day one. All three are correct and all three are the kind of thing teams learn the expensive way.

**What is actually wrong:**

**It describes a product that no longer exists.** This is not a nitpick — roughly **40 of the 67 stories are for features that have been cut**, and the features that now define Ejadah are almost entirely absent. Detail in Part 3.

**The header is a vanity line.** "8 Epics | 67 User Stories | INVEST Format" is written to impress a reader, not to help a builder. Story count is not a measure of anything. A backlog that needs to announce its own methodology is not confident in its content.

**It claims "sprint-ready" and isn't.** There are no estimates, no acceptance owner, no definition of done, and dependencies are captured for exactly three stories out of 67. A team cannot plan a sprint from this. They can build individual tickets from it, which is a different and lesser thing.

**Most of it could belong to any product.** Registration, OTP, password rules, social login, role switching, multi-tenancy — that is about 60% of the document and none of it is Ejadah. A competitor could lift Epics 1, 6, 7 and 8 wholesale and change the logo. The parts that are genuinely Ejadah — 199 verified programmes, recognition flags, a roadmap that respects a real budget — are the parts that are missing.

**It leads with the least valuable epic.** Epic 1 is registration. That is the correct build order for infrastructure and the wrong order for a document someone reads to understand what they are making. A reader gets eight stories deep into password validation before encountering anything that explains why this product should exist.

**Multi-tenancy is an unexamined assumption.** Epic 8 mandates tenant isolation and row-level security throughout. Ejadah as described is a single-tenant consumer platform — dentists sign up as individuals. Multi-tenancy implies a B2B white-label product for universities or clinic groups. If that is the plan, it belongs in the positioning; if it is not, this requirement adds cost and complexity to every query in the system. It is the single most expensive line in the document and nobody appears to have challenged it.

---

## Part 3 — What is out of date

Measured against the platform as it stands today.

### Cut entirely — do not build

| Original | Status |
|---|---|
| **Epic 3 — Exam Preparation** (US-3.1 to 3.5): question bank, practice quizzes, flagging | **Cut from Phase 1.** Licensing exams were removed as a category. Course quizzes survive but are a different feature living inside a course. |
| **Epic 7 — Community** (US-7.1 to 7.3) | **Cut from Phase 1.** No community, no spaces, no moderation. |
| **Epic 2 — Content Library** (US-2.1 to 2.9): study library, summaries, editorial CMS, contributor revenue share | **Cut.** The dental library and research hub are out. There is no contributor revenue-share model. |
| **US-6.1, 6.2, 6.3** — subscription tiers, cancellation, quarterly instalments | **Obsolete.** The model changed: every account is Premium, courses are bought one at a time, sessions are paid per booking. There are no tiers to subscribe to or cancel. |

That is 20 stories dead outright, plus most of Epic 6.

### Changed materially

- **US-6.4/6.5 Ambassador referral** — the mechanic is now "invite a colleague, both get one extra month added after your six," tracked against roadmap completion. The dashboard concept survives; the earnings model does not.
- **US-4.7 Payment escrow** — the rails are now split by law, not by preference. Courses are digital content and must use the platform's in-app purchase (Apple §3.1.1, 15–30% fee, no external link permitted). Sessions are real-world human services and use ejadah.com. The physical card is shipped goods and uses ejadah.com. Any escrow design must respect that three-way split.
- **Country count** — your brief says 20 countries; the build has 23 deep guides. Worth reconciling before either number reaches a public page.

### Missing entirely — and this is most of the product

None of the following appears anywhere in the 67 stories:

Postgraduate programme database (199 records) · programme detail · recognition flags · programme comparison · shortlist · saved-filter alerts · 23 country guides · country comparison · career roadmap generator · what-if scenarios · application tracker · document checklists · eligibility matching · affordability modelling · mentoring marketplace · consulting marketplace · tutor onboarding · tutor earnings · instructor dashboard · custom session plans · NFC card · public profile · CV builder · CPD ledger · certificate verification · notifications.

**A team building only from the Stage 6 document would ship a product with none of Ejadah's actual value in it.** That is the finding that matters. Everything else on this page is secondary to it.

---

## Part 4 — The rebuild

### Format decision

**I have not rebuilt this as a .docx, and I would not.** A backlog's job is to be pasted into a tracker, diffed when it changes, and argued over line by line. A dark-themed Word document does none of those well — it cannot be version-controlled, it cannot be linked to, and its styling actively fights the copy-paste it exists to serve. This is Markdown so it can live next to the code.

### Scope decision, stated plainly

I have written **full INVEST stories for the twelve where getting it wrong is expensive**, and a **registry line for the rest**. This is deliberate. Writing 67 stories of equal weight is what let the original bury the programme database under eight stories about passwords. Depth belongs where risk is, and password validation is not where the risk is on this product.

---

## E1 · Foundations

Build before anything else touches the database or the UI.

### F-1.1 — Bilingual string layer
**As** a dentist who reads Arabic, **I need** every screen authored in both languages from the first commit, **so that** Arabic is never a retrofit.

**Acceptance criteria**
- Every user-facing string resolves from `S[lang]`. No literal in any component, enforced by a lint rule that fails the build.
- Every font resolves from `FONTS[lang]`. Playfair Display has no Arabic glyphs and must never render when `lang === "ar"`.
- `letterSpacing: 0` on all Arabic text. Tracking breaks Arabic letter joining and is the most visible possible error.
- No `textTransform: uppercase` in Arabic — Arabic has no case.
- Line heights increase in Arabic: tight 1.25→1.45, snug 1.45→1.65, body 1.70→1.85.
- Headings reduce 12% above 28 characters in Arabic.
- Logical properties only — `paddingStart`/`paddingEnd`, never Left/Right.
- Western numerals (0–9) in both languages. Never Arabic-Indic, never mixed.
- Latin fragments bidi-isolated: ORE · ADC · NDEB · INBDE · Prometric · DHA · SCFHS · QCHP · exocad · 3Shape.
- Language default is Arabic, persisted, switchable instantly with no reload and no lost form state.

**Validate**
- Switching language mid-form must preserve every entered value.
- Every currency figure and exam code renders LTR inside RTL text without scrambling.
- A screen at 200% OS font size must not clip or overlap in either language.
- Strings files must be key-identical between languages; a missing key fails CI rather than rendering blank.

---

### F-1.2 — Analytics from the first screen
**As** the founder, **I need** the event taxonomy instrumented before launch, **so that** product decisions are findings rather than arguments.

**Acceptance criteria**
- All ~35 events in the taxonomy fire, with the documented properties. Four currently exist; that is not enough to measure anything.
- The activation funnel is answerable end to end: app open → guest roadmap started → roadmap completed → account created → roadmap saved.
- Every event carries language, persona and app version.
- No personally identifying data in any event payload, and no patient data ever.
- A debug view lists events fired in the current session, available in builds but not production.

**Validate**
- "What percentage of installs reach a saved roadmap, and how long does it take them?" must be answerable from the dashboard alone.
- Events must queue offline and flush on reconnect without duplicating.

**Why this is second, not last:** until it exists, nobody can tell whether any other story on this list worked.

---

### F-1.3 — System states
**As** any user, **I need** the app to behave when things break, **so that** a failure is an inconvenience rather than an uninstall.

**Acceptance criteria**
- Ten states designed and reachable: offline, server error, session expired, force update, maintenance, notification permission denied, camera permission denied, error boundary, content unavailable, rate limited.
- Every one routes to an action. "No results" with no next step is a defect, not a state.
- No status codes in user-facing copy, ever.
- Offline keeps saved programmes, the roadmap and the tracker readable; anything needing a connection is disabled with a stated reason rather than hidden.

---

### F-1.4 — Data protection and residency
**As** a user, **I need** my data handled lawfully, **so that** the platform can operate in Egypt and the Gulf.

**Registry** — see open question 4. This story cannot be written properly until the multi-tenancy question is settled and a jurisdiction is chosen for data residency.

---

## E2 · Programme database — the core of the product

### P-2.1 — Browse and filter 199 programmes
**As** a dentist deciding where to apply, **I need** to narrow 199 programmes to the handful that fit me, **so that** I am choosing rather than drowning.

**Acceptance criteria**
- All 199 records load paginated at 12 per page, with a stated range ("1–12 of 199") and page controls at 44×44 minimum.
- Filters: specialty, country, region, degree type, tuition ceiling, intake month, application deadline, scholarship available, language of instruction, interview required.
- **Expired intakes are hidden by default** — 150 of 199 deadlines have passed, and showing them first makes the database look dead. A single control reveals them.
- Active filters render as removable chips above the list.
- Result count always visible and always accurate.
- Filter state survives navigating away and returning.
- Full text search across university, city, country, specialty, degree.

**Validate**
- A filter combination with no matches must offer the nearest useful relaxation ("no MSc in Ireland under $15,000 — 3 match under $20,000"), never a bare empty state.
- Changing a filter must not reset pagination silently; it returns to page 1 and says so.
- The list must not ship the full dataset to the client. Pagination is a UX improvement, not a scraping defence — see S-9.3.

---

### P-2.2 — Programme detail with sourced facts
**As** a dentist evaluating one programme, **I need** to see what it costs, what it requires and whether it is recognised at home, **so that** I can trust the decision.

**Acceptance criteria**
- Sections: overview, entry requirements, curriculum, costs, funding, documents required, career outcomes, recognition, how to apply.
- Every cost and deadline carries a **"verified on {date}"** line and a tap-through to the official source.
- **Where a fact is not sourced, the field reads "Pending source" and is never estimated, never rounded, never inferred.** Eleven fees are currently in this state.
- Recognition flags for Egypt, UAE, Saudi Arabia and Qatar, each with its own verified date and source.
- Currency figures render LTR with the local amount primary and an approximate USD conversion secondary.
- Save to shortlist is optimistic, with Undo.

**Validate**
- A record with a missing recognition flag must show "Not verified" — not a green tick, not a blank, not an assumption.
- A source link that 404s must be caught by the freshness job and flagged to an owner, not silently left.

**Why this story is the product:** this is the only screen in the app a Facebook group cannot replicate. The discipline about unsourced fields is the entire competitive moat and must not be traded for a tidier-looking page.

---

### P-2.3 — Compare up to three programmes
**Registry.** Side by side, differences highlighted, horizontal scroll on mobile, add and remove from both detail and list.

### P-2.4 — Shortlist with deadline surfacing
**Registry.** Saved programmes appear on Home sorted by urgency, with days remaining. Remove is optimistic with a 5-second Undo. This is the feature that keeps the app installed between actions.

### P-2.5 — Saved-filter alerts
**Registry.** Save the current filter set as a watch; notify when a matching programme opens. Notification discipline is a hard requirement: one notification per programme, never more than one a day in total.

---

## E3 · Country guides and the roadmap

### C-3.1 — Country guide
**Registry, ×23.** Per country: licensing pathway with dated stages, exam detail (fees, sittings, pass mark), regulator and visa route, documents, costs in local currency plus approximate USD, salary band with an honest framing note, recognition of the Egyptian BDS, and Ejadah tips. Same sourcing discipline as P-2.2 — "Pending source" where unsourced.

---

### C-3.2 — Roadmap generation
**As** a dentist who does not know where to start, **I need** a route built around my actual budget and time, **so that** I get a plan rather than a brochure.

**Acceptance criteria**
- Four questions maximum: path, stage and years qualified, budget and study time, languages and target region.
- **Budget and available time are hard constraints, not preferences.** A route the user cannot afford is a wrong answer, not an aspirational one.
- Remote work from Egypt is a legitimate destination and must be reachable from the funnel.
- Generation shows rotating status lines for 10–15 seconds, never a bare spinner.
- The result names a destination, a fit percentage, five dated stages, the honest watch-out, and one action to take this month.
- Result is saveable, shareable, and regenerable via what-if without losing the original.
- **A guest can complete the funnel without an account.** The gate falls between funnel and full result — after five answers are invested, not before.

**Validate**
- A student answering "I'm still studying" must not receive an emigration route. That persona needs a term plan; if the branch does not exist, the question must not be asked of them.
- Two identical inputs must produce a consistent route; if generation is model-backed, the stage structure is fixed and only the prose varies.
- The result must deep-link to the matching country guide.

---

### C-3.3 — What-if scenarios
**Registry.** Change one variable, regenerate, show a change strip with previous values struck through. Six presets plus free text.

---

## E4 · Application management

### A-4.1 — Application tracker
**Registry.** Stages from shortlisted to decision, per-programme document checklists, deadline countdowns. At the Interview stage, surface a mentor from that programme — the highest willingness-to-pay moment in the product.

### A-4.2 — Eligibility match
**Registry.** Compare the user's profile against a programme's requirements; name the gap explicitly. A gap is an opportunity to offer help, not a rejection.

### A-4.3 — Affordability model
**Registry.** Tuition plus living costs plus travel against stated budget, with the shortfall named in EGP.

---

## E5 · Learning

### L-5.1 — Course purchase
**As** a dentist who wants one course, **I need** to buy it outright, **so that** I own it without a subscription.

**Acceptance criteria**
- Courses are **digital content** and must transact through the platform's in-app purchase. No external checkout link, no price steering to the web — this is Apple §3.1.1 and it is not negotiable.
- Lesson one is a free preview on every course, always.
- Owned courses read "Purchased — yours"; unowned show price and a Buy action.
- Purchase is permanent. No renewal, no expiry, and the copy says so.
- Restore purchases is available and works across devices on the same store account.

**Validate**
- A user who owns a course on the web must see it unlocked in the app without repurchasing.
- A failed or cancelled purchase must return to the course intact, with no partial unlock.

---

### L-5.2 — Course player · L-5.3 Flashcards · L-5.4 Quizzes · L-5.5 Handouts
**Registry.** Player saves position every 10 seconds and survives backgrounding. Flashcards use spaced repetition with a daily due queue surfaced on Home — this is the daily-open driver and the only feature with a genuine habit loop. Quizzes give immediate feedback with explanations; a score under 60% offers one session on that topic, never a package. Handouts are PDFs with size and offline availability stated.

---

## E6 · Marketplace — demand side

### M-6.1 — Tutor profile and booking
**Registry.** Profile carries qualifications, subjects, session length options, packages, reviews from completed bookings only, and a sticky book action. Booking collects subject, duration, date and time, goal, then hands to ejadah.com checkout — permitted, because a session with a human is a real-world service rather than digital content.

### M-6.2 — Custom multi-session plan
**As** a student booking twelve sessions, **I need** to schedule them week by week, **so that** the plan matches how my month actually works.

**Acceptance criteria**
- Cadence dials: sessions per week, hours per session, over how many weeks.
- Scheduling is **week by week**, not "N hours per week in aggregate." Four sessions a month means one hour in each of four weeks, and the interface must not demand four hours in one.
- Filling a week auto-confirms it and advances, with a visible tick.
- "Same time every week" copies the first completed week into every unscheduled week, without overwriting weeks already set.
- Different times per week are allowed.
- Volume discounts are tappable and apply the smallest cadence that reaches the tier.
- The submit action stays disabled with a stated reason until every week is scheduled.
- Confirming hands off to booking **without re-asking anything already answered.**

**Validate**
- Hours outside the tutor's stated availability must be untappable, not merely warned about.
- All times display in Cairo time with the timezone named.

### M-6.3 — Mentoring · M-6.4 Consulting · M-6.5 My bookings
**Registry.** Mentors match on destination country rather than clinical subject. Consulting targets clinic owners. A free 15-minute intro call de-risks all three and should be offered at the roadmap result, which is where intent peaks. Bookings split upcoming, past, cancelled, with join, reschedule and a cancellation flow that states the consequence in plain words.

---

## E7 · Marketplace — supply side

### M-7.1 — Tutor onboarding
**Registry.** Six steps with save-as-draft: personal, qualifications, subjects, pricing with a live earnings estimate, availability grid, media. The 70/30 split is stated up front, not buried.

### M-7.2 — First-student playbook
**As** a newly approved tutor, **I need** to know what to do next, **so that** I get a first booking before I lose interest.

**Acceptance criteria**
- The approval screen carries three checkboxed actions: share your profile, switch free intro calls on, add five or more weekly hours.
- Progress persists and is visible on the dashboard until complete.

**Why this small story matters:** an approved tutor with no students churns within a month and takes their availability with them. Supply is harder to replace than demand and slower to rebuild.

### M-7.3 — Earnings · M-7.4 Instructor dashboard
**Registry.** Balance, payout history, per-session breakdown with the 70/30 itemised. Dashboard covers courses, students and engagement.

---

## E8 · Professional identity

### I-8.1 — NFC card and public profile
**Registry.** A shareable profile at `/dr/{slug}` carrying name, credentials, verified certificates, socials and a contact action. **No messaging between users** — contact is one-directional and student-to-student messaging does not exist. Analytics are private to the owner and never name a viewer. Every card shared is a landing page carrying Ejadah branding and an install action; this is the only organic growth loop in the product and must never be gated.

### I-8.2 — Certificates and verification
**Registry.** Certificates for completed Ejadah courses are verified. Certificates a user adds themselves are displayed but explicitly unverified — the distinction must be visible at a glance. Public verification at `/verify/{code}` requires no account and is never charged for; a third party checking a credential is free marketing arriving at your door.

### I-8.3 — CV
**Registry.** Ask one question first — do you already have a CV? Upload is the normal path. Building produces a draft to download, not a stored CV. Experience, skills, languages, personal statement. A visible warning against including patient data.

### I-8.4 — CPD ledger
**Registry.** Points accrued per completed course, exportable.

---

## E9 · Platform and trust

### S-9.1 — Notifications
**Registry.** Three categories, independently switchable: deadline warnings (30, 14 and 7 days), session reminders, roadmap stage nudges. No marketing category. Permission requested in context after a save, never on cold start.

### S-9.2 — Data freshness pipeline
**As** the founder, **I need** every fact to carry an owner and a re-check date, **so that** the database does not quietly rot.

**Acceptance criteria**
- Every programme field and country fact carries `verified_on` and `source_url`.
- A record older than six months flags to an owner automatically.
- The eleven "Pending source" fees are tracked as open items until closed.
- Admin can see, in one view, what is stale and who owns it.

**Why:** data decay is the only thing that can kill this product silently. Nothing breaks, nobody complains, and the answers gradually stop being true.

### S-9.3 — Protecting the dataset
**Registry, with an honest caveat.** Pagination raises scraping cost but does not prevent it — a scraper walks pages. Real defences are server-side: an authenticated API, per-account rate limits, no bulk endpoint, and never shipping the full dataset to the client. State this in the ticket so nobody mistakes the UI change for the fix.

### S-9.4 — Admin
**Registry, web only.** User management, content management, verification queue, freshness dashboard, payout approvals.

---

## Sequencing

| Wave | Contents | Rationale |
|---|---|---|
| **0 — before anything** | F-1.1 bilingual layer · F-1.2 analytics · F-1.4 data protection decision | Retrofitting Arabic or analytics costs multiples of building them in. The data-protection decision gates schema design. |
| **1 — the reason to exist** | P-2.1 database · P-2.2 detail · C-3.1 guides · S-9.2 freshness | This is what nobody else has. Everything downstream borrows its credibility from here. |
| **2 — activation** | C-3.2 roadmap · guest gate · P-2.4 shortlist · S-9.1 notifications | The path from install to a saved roadmap is the funnel. Nothing else matters until it works. |
| **3 — revenue** | M-6.1 booking · L-5.1 purchase · M-7.1 onboarding · M-7.2 playbook | Demand and supply must land together; a marketplace with one side is a directory. |
| **4 — retention and reach** | A-4.1 tracker · L-5.3 flashcards · I-8.1 card · I-8.2 certificates | The reasons to come back, and the reason anyone else hears about you. |
| **5 — polish** | F-1.3 system states · P-2.3 compare · C-3.3 what-if · S-9.4 admin | Real, but none of it blocks a first user succeeding. |

**Three warnings, carried forward from the original because they were right:**

1. Row-level security, if multi-tenancy survives question 4, must exist before any feature touches the database.
2. The freshness clock starts on publish day. Build S-9.2 before the first record goes live, not after.
3. Payment routing must be correct from the first transaction. Financial logic is the most expensive category of bug to fix in production, and the digital-versus-physical split is a legal question, not a preference.

---

## Part 5 — What changed, and why

**Cut 40 stories.** Exams, community, the content library and the subscription tiers describe a product that no longer exists. Carrying them forward silently would have had a team building for weeks against a dead spec.

**Added the actual product.** The programme database, country guides, roadmap, tracker, marketplaces, professional identity — roughly 30 stories' worth of work that the original did not mention at all.

**Inverted the order.** The original opened with registration. This opens with the bilingual layer and analytics, because those are genuinely first, then goes straight to the database — the thing that justifies the product. A reader now learns what Ejadah is by page two.

**Wrote depth where risk is.** Twelve full stories, the rest as registry lines. Equal depth across 67 stories is how the original ended up with more words about password rules than about its own differentiator.

**Made the sourcing discipline a hard requirement, not a nicety.** "Pending source" appears as an acceptance criterion in two places. It is the difference between a database and an opinion.

**Named the payment split as law rather than preference.** Digital content must use in-app purchase; human services and physical goods may not have to. Getting this wrong is a store rejection, and it is cheaper to design around than to discover.

**Dropped the vanity header.** No story count, no methodology badge.

**Changed the format.** Markdown, not Word, for the reasons in Part 4.

---

## Assumptions I made on your behalf

1. The app's current model — free Premium account, one-off course purchases, per-session payment — is the company's model, and the website will be brought into line with it rather than the reverse.
2. The 23 country guides in the build are correct and the "20 countries" in your brief is the stale figure.
3. Multi-tenancy was inherited rather than chosen, and is likely to be dropped. I have flagged rather than removed it.
4. Launch is weeks away, not months, so "before launch" in the sequencing means the next few waves rather than a future quarter.
5. Sessions remain human-delivered. If group or recorded sessions arrive later, the payment routing changes and M-6.1 needs revisiting.

---

## What is missing from this set and should exist

- **A definition of done.** The original had none, and without one "sprint-ready" is a claim rather than a state. One paragraph, applied to every story.
- **A test plan for the bilingual layer.** Arabic breaks in ways English does not, and it will not be caught by whoever builds it.
- **A data-sourcing runbook.** Who checks a regulator fee, how often, what counts as a source, what happens when a source disappears. S-9.2 assumes this exists.
- **A content style guide.** The app's copy has a distinct voice — plain, specific, never overselling. Nothing currently records it, so the next writer will not match it.
- **A launch checklist.** Store assets, privacy policy in both languages, data-collection disclosure, age rating, screenshots. All block release and none appears in any document I have seen.

---

## Open questions

1. **Is Ejadah multi-tenant?** If universities or clinic groups get their own tenanted instance, say so and Epic 8 stands. If not, it should be removed before it taxes every query in the system. This is the highest-cost open item.
2. **What is the January price, and does the founding cohort keep anything permanently?** The subscription stories cannot be rewritten until this is decided. Decide in October, announce in November.
3. **Who owns data re-verification?** Staff, or mentors in exchange for credit? S-9.2 needs a named owner, not a process.
4. **Which jurisdiction governs data residency** — Egypt, UAE, or EU-equivalent? This gates schema and hosting decisions, so it cannot wait.
5. **Is in-session messaging shipping for launch?** Your cancellation policy references it and the product does not have it. One of the two is wrong.
6. **Were other files meant to be attached?** Your brief describes a set; only the Stage 6 backlog arrived. Send the rest and I will give each the same treatment.
