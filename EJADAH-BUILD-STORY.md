# Ejadah — The Build Story
### One master brief for Claude Code · Flutter + Dart
**Written 14 August 2026 · Ejadah International Academy, Cairo**

---

## Read this file first, in full

This is not a specification handed down from nowhere. It is the story of how a 45-feature idea became a 28-feature scope, then a 5-tab app that a Cairo dentist can actually use — and *why* each cut was made. The reasons matter more than the list, because when you hit a decision this file doesn't cover, the reasoning is what tells you which way to go.

The mobile prototype (`Ejadah App - Home & Career.dc.html`) is the north star. It is 95 screens, both languages, fully navigable. Where this document and the prototype disagree, **the prototype wins** — and tell me, because it means I wrote something down wrong.

You are building this in **Flutter + Dart**. Everything below is described in terms of behaviour and intent, not in terms of the prototype's HTML, so nothing here should push you toward web idioms.

---

## Part 1 — Who this is for

A dentist in Cairo. Qualified three years ago, earning maybe EGP 8,000 a month at a clinic in Nasr City, and quietly certain that the rest of her career is somewhere else. She has a Facebook group with 40,000 members where the same six questions get asked every week and answered wrong. She has a WhatsApp group of five friends from dental school, two of whom already left. She does not have a straight answer to "what would it actually cost me to work in Dubai, and how long would it take."

That is the whole product. Everything else is in service of it.

**Four things about her that shape every decision:**

1. **She is on a mid-range Android phone**, on 3G more often than she'd like. Nothing can assume a fast connection or a recent device.
2. **She reads Arabic more comfortably than English**, but every exam is called ORE, every verification service is called DataFlow, and no one says "الترخيص" when they mean the DHA licence. So the app is Arabic-first with Latin technical terms left alone.
3. **She has been lied to by content before** — by agencies quoting fees that turn out to be stale, by forum posts from 2019 presented as current. Her default is scepticism, and it is correct.
4. **She has no money to waste.** Not "budget-conscious" as a persona trait — she has a real ceiling, and a plan that exceeds it is not an ambitious plan, it is a wrong answer.

---

## Part 2 — How 45 became 28

The original scope was 45 features across six categories. Here is what happened to each group, and why.

### The exam category: 6 features, all cut

**What it was:** an exam hub, a question bank, mock exams, free tests, exam analytics, and an exam progress dashboard. ORE, ADC, NDEB, the Gulf Prometric exams — a full test-prep product.

**Why it was cut:** because it is a different company. A question bank needs thousands of validated questions, per-exam, kept current as syllabi change, ideally written by people who've sat the exam recently. That is a years-long content operation, and it competes with well-funded incumbents. Meanwhile the *actual* unmet need — "which exam do I even need, and what does it cost" — is answerable from a well-maintained database of 23 countries.

**What this means for you:** there is no Exams tab. When the licensing pathway mentions ORE Part 1, it links to a country guide and, if a matching course exists, to that course. It never opens a practice question. If you find yourself building anything that scores an answer as right or wrong outside a course quiz, stop — that's the cut feature growing back.

### Live and synchronous learning: 4 features, all cut

**What it was:** a Live Academy, live classrooms, clinical demonstrations, and a research hub.

**Why it was cut:** live content is an operations business disguised as a software feature. Someone has to schedule it, staff it, chase the presenter who's late, and handle the 40 people who couldn't attend. And the value it delivers — expert explains a thing to you in real time — is delivered better and more profitably by a one-to-one tutoring session, which we *are* building.

**What this means for you:** courses are recorded, self-paced, and downloadable. There is no scheduled group content anywhere in the app. Video is a file with a resume position, not a stream with a start time.

### Content libraries: 2 features, cut

**What it was:** a dental library of textbooks and guidelines, and a research hub.

**Why it was cut:** a library is a licensing negotiation, not a product decision. And the honest version — a curated set of links to things she can already find — adds nothing.

### The AI assistants: 2 features, cut

**What it was:** a course AI assistant and a general dental AI assistant.

**Why it was cut, and this one is the most important cut in the document:** the product's entire claim is that its numbers are real, sourced, and dated. An assistant that answers "what does the DHA exam cost" from a language model's memory will eventually say something confidently wrong, and one screenshot of that circulating in a 40,000-member Facebook group destroys the thing we're actually selling. The trust is the product; a chatbot is a liability against it.

**What this means for you — and this is a hard architectural rule:** **there is no AI inference anywhere in this app, and no external data source of any kind.** See Part 5 rule 1 for what this means in practice; it is the most important constraint in this document.

### Community: 1 feature, cut

**What it was:** discussion spaces, posts, replies.

**Why it was cut:** she already has a community — that Facebook group, that WhatsApp thread. Competing with it means winning a fight we don't need to have, plus moderation liability in a professional context where bad clinical advice has real consequences.

**What this means for you:** there is **no user-to-user messaging of any kind.** Contact happens on a booking, between a student and their tutor, and it is visible to admin. Two students cannot message each other. This was a deliberate product decision, not an oversight — do not add a general inbox.

### Everything else cut: 5 features

- **Accreditations page** — marketing copy, belongs on the website
- **Private/group training** — needs the marketplace to work first
- **Achievements and badges** — gamifying a career decision reads as trivialising it
- **Global cross-content search** — search inside Career, where the data is deep, not across everything
- **Public course browsing without an account** — a website job

**Total: 45 → 28.**

---

## Part 3 — The 28 features that survived, as five tabs

Then a second reduction happened, not of features but of *navigation*. The original design had six tabs. Six is too many — the labels get short and cryptic, the tap targets get tight, and the fifth and sixth tabs get forgotten. So:

**Home · Connect · Courses · Career · Profile**

Career and Postgrad merged, because "where can I work" and "where can I study" are the same question asked at different life stages, and splitting them meant a dentist had to guess which tab held her answer.

---

## Part 4 — The features, as stories

### Tab 1 — Home

**The story.** She opens the app on a Tuesday evening. She has fifteen minutes. The app's job in the first two seconds is to tell her what she was doing and what needs her attention — not to sell her anything.

**What's here:** a greeting with her name and streak, a continue-where-you-left-off row, her roadmap progress (or a CTA to build one if she hasn't), the next upcoming session, her saved programmes sorted by deadline urgency, matched tutors, and four Explore tiles.

**The decision that matters:** Home's primary CTA changes by persona. A dental student gets "pass this term", a fresh graduate gets "build your roadmap", a specialist gets "set up your professional card". Six personas: student, fresh graduate, GP dentist, specialist, consultant, and the supply-side view for tutors. Getting this wrong means a specialist who already arrived is told to plan an emigration.

**States you must build:** returning user, brand-new (empty), loading (skeletons, not spinners), error, offline (cached content readable, banner shown), and partial (one section failed, the rest fine).

### Tab 2 — Connect

**The story.** She's stuck on something — a clinical technique, or a decision about the UK. She needs a person, not a page.

**Three marketplaces, one codebase.** They differ in *matching* and *copy*, not mechanics:

- **Tutoring** matches on clinical subject. For students and fresh graduates.
- **Mentoring** matches on **destination country** — a dentist who went Cairo → London is proof the route works. This is the difference between mentoring and tutoring, and it's why a mentor profile leads with the journey they made rather than their specialty.
- **Consulting** is for clinic owners. Pricing, staffing, equipment. Lowest volume, highest ticket.

Mentoring and consulting lead with a **free 15-minute intro call**, because the buyer is deciding whether to trust a stranger with something expensive. Tutoring can lead with booking, because the need is concrete.

**Booking, and the mistake we made once.** An eight-step flow: subject → tutor → date → time → duration → goal → review → pay. But the part to get right is the **multi-session plan**. Our first design asked "how many hours per week?" and then demanded all four hours be scheduled in one week. That is not what anyone wants. A four-session monthly plan means **one session in each of four weeks**, and the scheduler works week by week: fill week 1, it ticks green and advances to week 2, and the submit button stays disabled — with a stated reason — until every week is filled.

**Two things that must be architecturally true, not just usually true:**

1. **Two students can never book the same hour.** Selecting a slot creates a held booking immediately, before payment, with a visible countdown. A duplicate is rejected at the data layer, not by a client-side check that races.
2. **Availability is rules plus exceptions, computed when read** — "Mondays 18:00–22:00" plus "not on 14 September" — never a pre-generated table of slots, which goes stale the moment a tutor edits her schedule.

**Timezones.** Store UTC. Tutor availability is in *her* local time. Display in Cairo time, and always name the zone on screen. A session both parties attend at different times is the worst bug this feature can produce.

**Supply side:** a six-step tutor application with draft saving, the 70/30 split stated in step 1 *and* itemised in step 4's live earnings estimate, an availability grid, and — critically — a **first-student playbook** on the approval screen. An approved tutor with no students churns within a month and takes their availability with them. Three actions: share your profile, switch on intro calls, add five weekly hours.

### Tab 3 — Courses

**The story.** She wants to get better at rotary endodontics. She has an hour on a Friday.

Department hub first (Orthodontics, Digital, Business & Paradental), then a filtered list, then the course. Recorded video with a resume position saved every ten seconds, downloadable handouts, spaced-repetition flashcards with a daily due queue, and quizzes with explanations.

**The flashcards are the only genuine daily-habit loop in the product.** The due count surfaces on Home. Everything else here is weekly or monthly behaviour.

**Courses are bought individually.** Not a subscription. Lesson one is always a free preview. Once bought, it's hers permanently — and the copy says so. A quiz score under 60% offers one session on that topic, never a package, and never blocks the retry.

### Tab 4 — Career

**The story.** This is the reason the app exists.

**199 real programmes** across 123 countries, filterable by specialty, country, degree, tuition, intake, deadline, scholarship. **150 of those 199 deadlines have already passed**, which is why expired intakes are hidden by default — showing them first makes a live database look dead.

**23 country guides**, each with the licensing pathway as dated stages, the exam and its fee, the regulator, the visa route, real costs in local currency plus an approximate USD figure, a salary band with an honest framing note, and recognition of the Egyptian BDS.

**Programme comparison** up to three side by side. **A shortlist** whose saved deadlines surface on Home — that feature, more than any other, is why the app stays installed between actions.

**The roadmap generator.** Four questions: which direction, where you are in your career, what you can commit, and languages plus regions. Then a destination with a fit score, five dated stages, an honest watch-out, and one action to take this month.

**Four rules about the roadmap, all non-negotiable:**

1. **Budget and time are hard limits, not preferences.** A route she can't afford is a wrong answer. The question's helper text says exactly that: *"We use this as a ceiling, not a target. A plan you can't afford isn't a plan."*
2. **It is deterministic, and it reads only our own data.** No AI, no inference, no web lookup, no third-party API. The generator selects candidate countries from our own 23 country guides and 199 programmes, scores them with a fixed formula, and assembles the result from fixed sentence templates with our own values slotted in. Same inputs, same output, every time — a property no model-backed version could ever guarantee, and a better one for a feature whose whole premise is "these numbers are real."
3. **Remote work from Egypt is a legitimate destination**, not a consolation prize. If her answers point there, the app says so without apology.
4. **Every stage on the result page is a copy of a row.** The generator sequences and personalises which stages appear and in what order; it never rewrites their content. If a stage's text on screen doesn't exist verbatim in the database, something is wrong.

**How the generator works, concretely:**

```
her four answers
      ↓
1. FILTER   — query our country guides. Budget and study time are SQL
              pre-filters, not scoring nudges. A country whose floor cost
              exceeds her ceiling drops out, or survives only as a flagged
              last resort.
      ↓
2. SCORE    — a fixed formula with named constants: base score, region-match
              bonus, pathway-class weight (fast / exam / language / complex),
              budget-overage penalty, time-overage penalty, language-match
              bonus. Clamped 0–100. An unaffordable destination is
              mathematically incapable of scoring above 60.
      ↓
3. ASSEMBLE — headline, summary, watch-out and this-month action come from
              fixed templates with real values slotted in. Stages are copied
              from the winning country's own stage rows, with dates projected
              forward from today. Fees come from our exam rows — and a fee
              marked unverified prints "Pending source" because that is
              literally what the row says.
      ↓
   her roadmap
```

**Tie-breaking must be deterministic too** — equal scores break on lower cost floor, then alphabetically by country code. Never on insertion order or unordered query results, or the "same inputs, same output" guarantee quietly depends on undefined behaviour.

**What-if scenarios** change one variable and regenerate — as a *new* roadmap, with the original preserved, because the comparison is the whole value.

**The gate, and this is the highest-leverage decision in the product:** a guest completes the entire funnel **without an account**. The wall falls *between the funnel and the full result* — stages one and two readable, the rest blurred, then a free-account CTA. Four answers are already invested by then. A cold signup wall at the entrance converts far worse, and it will feel backwards to build. Build it this way anyway.

**"Pending source" is a feature.** Eleven regulator fees are currently unverified. Those print the words "Pending source" — never an estimate, never "approximately", never a blank. This is the discipline that makes every *other* number believable.

### Tab 5 — Profile

**The story.** She's at a conference in Dubai. Someone asks what she does.

**The NFC digital card** is the answer — tap a phone, land on her public profile: name, credentials, verified certificates, socials. Every card shared is a landing page carrying Ejadah branding and an install prompt. **This is the only organic growth loop in the product, so it is never gated.**

**Certificates.** Courses completed on Ejadah are **verified**. Certificates she adds herself are displayed but explicitly **unverified**, and the distinction must be visible at a glance — conflating them is exactly the credibility problem this product exists to solve. There's a public verification page for third parties, requiring no account and never charged for; someone checking her credential is free marketing arriving at your door.

**A CV builder** that asks one question first: do you already have a CV? Upload is the normal path. Plus experience, skills, languages, a personal statement — and a visible warning against including patient data.

**Analytics on her card are private to her.** Views, taps, which certificate got opened. Nobody else sees them, and no viewer is ever named.

Also here: notifications with three independently switchable categories (deadline warnings at 30/14/7 days, session reminders, roadmap nudges — no marketing category), her Premium status, settings, and account deletion.

---

## Part 5 — The rules that override everything

When this document doesn't cover your case, these decide it.

### 1 · Our data is the only source — nothing is invented, nothing is fetched

**Every fact in this app comes from Ejadah's own database.** Not from an AI model, not from a web search, not from a third-party API, not from a scraped feed. The 23 country guides, the 199 programmes, the exam fees, the recognition flags, the tutor profiles — all of it is ours, entered by our content team, each row carrying a `verified_on` date and a source URL.

This has three consequences you must build for:

**No external calls for content.** The only network traffic in this app is to our own backend. If a feature seems to need a currency rate, a country fact or an exam fee it doesn't already have, the answer is to add a row to our data — never to call out for it. A feature that depends on someone else's uptime is a feature that will be wrong on the day it matters.

**No AI inference, anywhere.** Not for the roadmap, not for course recommendations, not for a "smart" search, not for polishing prose. The roadmap generator feels like it should be AI and specifically is not — see Tab 4 above for how it actually works. If you find yourself reaching for an LLM API, you have misread the design.

**"Pending source" instead of a guess.** When a fact isn't in our data, the app prints those words — never an estimate, never "approximately", never a blank that reads as zero. Eleven regulator fees are in this state right now. That visible honesty is precisely what makes every *other* number on the page believable, and it is the difference between us and the agency quoting stale fees.

### 2 · Arabic is not a translation layer

Both languages ship from the first commit. Arabic is the default. Specifically:

- Every string from a localisation map. No hardcoded English, ever.
- **`letterSpacing: 0` on all Arabic text** — tracking breaks Arabic letter joining and is the single most visible error available.
- **No uppercase transforms in Arabic** — Arabic has no case.
- Line heights increase in Arabic: 1.25 → 1.45 tight, 1.45 → 1.65 snug, 1.70 → 1.85 body.
- Arabic headings reduce ~12% above 28 characters.
- Directional properties only — start/end, never left/right.
- **Western numerals (0–9) in both languages.** Never Arabic-Indic, never mixed.
- Latin technical terms stay Latin and bidi-isolated: ORE · ADC · NDEB · INBDE · Prometric · DHA · DOH · MOHAP · DataFlow · SCFHS · QCHP · exocad · 3Shape.
- Currency figures, dates and exam codes render LTR inside RTL text.
- Language switches instantly with no reload and **no lost form state**.

### 3 · Money never moves in the app

- **Courses are digital content.** Apple §3.1.1 forces in-app purchase — 15–30% platform fee, no external checkout link, no exceptions. Locked lessons show a padlock and "Not included in your plan". No price steering to a website.
- **Sessions are real-world services between two people.** External payment is permitted; keep the full 70/30 split.
- **The physical NFC card is shipped goods.** Store rules don't apply.

These look inconsistent side by side. They are legally distinct. Don't harmonise them.

### 4 · Nothing happens without acknowledgement

- Every tap produces feedback within 100ms — press state, haptic, or an optimistic change.
- Async work puts a spinner **inside** the button, width frozen so nothing jumps.
- Anything reversible updates instantly and reverts with a toast on failure. Never make someone watch a spinner to save a bookmark.
- Skeletons shaped like the content, not centred spinners.
- **Every empty state routes to action.** "No results" is a dead end and therefore a defect.
- Destructive actions are reversible (optimistic delete + 5-second Undo) or confirmed with the consequence stated in plain words — including the exact refund amount before a cancellation.
- **A disabled button must say what's missing when tapped.** A greyed-out Continue with no explanation is the most frustrating pattern in mobile software.

### 5 · The app remembers

Scroll position per tab, filter state, form drafts, video position, which tab you were on — all survive backgrounding and restart. And back is never the only way back: edge-swipe works everywhere, mirrored for RTL.

### 6 · Design system

**Colours:** red `#FF2D32` · orange `#FF6B1A` · amber `#FFAA18` · gold `#FFC62E` · off-white `#FFF9EF` · white `#FFFFFF` · pale gray `#F5F2EC` · border gray `#E7E2DA` · warm gray `#716D67` · charcoal `#1B1B1B` · deep `#121212` · espresso `#24201D` · success `#2D9B68` · info `#496FA8` · danger `#FF2D32`.

**Gradient:** `#FF2D32 → #FF6B1A (50%) → #FFC62E`, **135° in English, 225° in Arabic** so the light falls from the leading edge.

**Gradient discipline — maximum six gradient elements on screen at once**, and only on: primary buttons, the logo tile, numbered step markers, one emphasised phrase per heading, the closing CTA band, the active tab indicator. Overusing it is the fastest way to look like a template.

**Two contrast corrections, learned the hard way:** brand orange `#FF6B1A` measures 2.35:1 on cream and **fails AA as text** — use `#C2450F` for orange text under 14px, and keep `#FF6B1A` for fills and icons only. Muted label text is `#6B6862` (4.58:1); an earlier `#8E8A83` was used on a false claim that it passed — it measures 2.84–3.28:1 and must never come back.

**Type scale, twelve sizes, nothing else:** micro 11 · caption 12 · small 13 · body 14 · bodyLg 16 · h6 18 · h5 20 · h4 22 · h3 24 · h2 28 · h1 32 · display 36.

**Fonts:** English — Playfair Display 700/800 display, Inter 400–800 body. Arabic — **Amiri 700 display, IBM Plex Sans Arabic 400–700 body**. Playfair has no Arabic glyphs; never render it when the language is Arabic.

**Radius** 4 · 8 · 12 · 16 · 20 · 24 · 999. **Spacing** 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64. **Motion** 150/200/300ms, `cubic-bezier(0.4, 0, 0.2, 1)`, all suppressed under reduce-motion.

**Band rhythm:** dark hero → light → deep → light → gradient CTA. Never two dark bands adjacent.

**Minimums:** 44×44 touch targets, readable at 200% OS font scaling, everything labelled for screen readers in the active language.

### 7 · Measure it or it didn't happen

About 35 events, wired from the first build rather than retrofitted. The one that matters: **cold open → saved roadmap**, with elapsed time. The claim "a dentist reaches a personalised roadmap in three minutes" is currently an assertion. Make it a measurement.

Every event carries language, persona, app version, and milliseconds since first open.

---

## Part 6 — Build order

Each stage ends with a working, demonstrable thing.

**Stage 1 — Foundation.** Tokens, fonts, the bilingual string layer with instant switching, the primitives (button with all seven states, card, chip, badge, input, skeleton, empty, error, toast, bottom sheet, undo), and the five-tab shell. Deliverable: a primitives showcase in both languages, both directions, side by side.

**Stage 2 — First run to first value.** Splash, language pick, welcome carousel, the **guest roadmap funnel**, the gate, signup with the guest→user migration that must not lose her four answers, verification, onboarding profiling, and the Premium status screen.

**Stage 3 — Career.** The 199-programme database with filters and pagination, programme detail, comparison, shortlist, the 23 country guides, the roadmap generator and what-if. **This is the product.** Build it to a standard you'd show an investor.

**Stage 4 — Home.** All seven sections, six personas, and every state including offline and partial.

**Stage 5 — Connect.** All three marketplaces, tutor profiles, the eight-step booking, the week-by-week plan scheduler, tutor onboarding, earnings, and My Bookings.

**Stage 6 — Courses.** Catalogue, detail, player, handouts, flashcards, quizzes, downloads.

**Stage 7 — Profile.** NFC card, public profile, certificates and verification, CV builder, notifications, settings, account deletion.

**Stage 8 — The screens that get skipped.** Offline, server error, session expired, force update, maintenance, both permission-denied states, error boundary, content unavailable, rate limited. Ten screens. They separate a shipped product from a demo, and they cannot be added retroactively.

**Stage 9 — Polish and growth.** WhatsApp-first sharing, referral, rate prompt after a positive moment only, deep links, pull-to-refresh, haptics, the accessibility pass, and the full RTL audit.

**If time runs short:** stages 1, 2 and 3 are non-negotiable. A dentist who never opens Courses or Connect still gets the entire value of the product from the roadmap and the programme database.

---

## Part 7 — What I know is unfinished

Stated plainly, because discovering these mid-build is worse.

1. **Eleven regulator fees are unverified** and print "Pending source" — Bahrain and Ireland exams, the Dutch, Swedish and Swiss assessments, Singapore QDLE, the South African board, Malaysia's MDC among them. Honest in the app; each needs one enquiry to close.
2. **Tutor, mentor and consultant rosters are illustrative.** Real names, photos and rates are required before any external demo. A dentist recognising a fabricated colleague is an unrecoverable credibility loss.
3. **The Arabic needs a practising dentist's review**, especially specialty and exam terminology. It is grammatically sound and clinically unverified — different things.
4. **Recognition status is empty across all 199 programmes.** It renders "Not verified" rather than guessed. Sourcing it per country is real work.
5. **The three-minute activation claim is untested.** Five real Cairo dentists, a stopwatch, cold open to saved roadmap.

---

## The one-line summary

**A Cairo dentist opens this app and, in about three minutes, gets a real, costed, sourced answer to "where can I actually go, and what will it take" — in Arabic, on a mid-range Android phone, with every number coming from our own verified data and traceable to a regulator's own page.**

Everything in this document exists to make that sentence true. If a decision you face doesn't obviously serve it, that's your answer.
