# Audit Report — pre-cleanup, per brief §70
### File inventory · current-vs-legacy · conflicts · gaps
**14 August 2026 · produced before any cleanup, as instructed**

---

## 1 · Current-file inventory (what actually exists in this repository)

**Note on the brief's file list:** several files the brief names do **not exist** in this repository — `BrandGuide.tsx`, `DesignSystem.tsx`, `RTLDemo.tsx`, `routes.ts`, `shared.tsx`, `guidelines/Guidelines.md`, `handoff-developer.md` (deleted 14 Aug on owner instruction with all web/backend packs), `roadmap documentation`/`tutoring documentation` folders (same deletion). They belong to a separate React/Figma-Make repo not present here. Their intent is covered by equivalents below; where the brief demands their content (e.g. Guidelines.md), this handoff creates it fresh.

| Path | What it is |
|---|---|
| `Ejadah App - Home & Career.dc.html` | **The canonical prototype.** 95 screens, 5 core tabs + rails, EN/AR, all states switchable |
| `Ejadah App - Programme Profile.dc.html` | Deep programme profile (King's College MSc Endodontology), EN/AR |
| `Ejadah - Notifications.dc.html` | Notification centre design |
| `Ejadah App - Phase 0 Foundation.dc.html` (+ `-print`) | Design-system foundation sheet, both languages |
| `Ejadah-App-Standalone.html` | Shareable offline bundle of the prototype (stale vs live file) |
| `EJADAH-BUILD-STORY.md` | Master narrative brief for Claude Code: 45→28 features, all cut reasons, build order |
| `scope-phase-1.md` | Locked Phase-1 scope (28 features) — **predates the Masters/Career merge; tab list stale** |
| `Ejadah - Phase 1 Delivery Backlog.md` | Rebuilt backlog (supersedes Stage 6 .docx) |
| `Ejadah - Sitemap/Journey Maps/Interconnection/Revenue Map/SEO/Action Plan/Product Audit (7 .dc.html)` | PM audit canvases — INTERNAL DESIGN REFERENCE |
| `handoff/tokens.ts` | Design tokens incl. measured contrast corrections (#C2450F, #6B6862) |
| `handoff/strings.en.json` / `strings.ar.json` | String tables (key-identical) |
| `handoff/analytics-events.md` | ~35-event taxonomy |
| `handoff/deep-links.md` / `push-notifications.md` | Link + notification specs |
| `data/programmes.json` (+ .js, raw) | 199 real programme records, 40 fields |
| `data/countries.js` | 23 deep country guides, bilingual, `window.EJADAH_COUNTRIES` |
| `data/kings-profile.md` | Extracted King's content |
| `data/stage6-clean.txt` / `stage6-user-stories.txt` | Extracted text of legacy Stage 6 backlog |
| `export/01–23 + README` | Readable .md mirrors of prototype docs, audits, handoff files, datasets |
| `audit/findings.md`, `audit/app-qa.html` | QA sweep results |
| `assets/ejadah-mark.jpg`, `ejadah-icon-ms4q23e9-krxx.jpg` | Two logo candidates — **canonical one must be declared** (see §6) |
| `demo-script.md` | Investor demo walkthrough |
| `doc-page.js`, `support.js` | Prototype runtime — never spec |
| `uploads/*` (~90 files) | Input material: old website HTML exports (tutoring/mentoring/consulting/courses/cards/certs/KINGS×10), `EJADAH-ARCHITECTURE.md` (old PHP), Stage 6 .docx, brand PDFs, programmes .xlsx |

## 2 · Current-vs-legacy classification

**CURRENT — PHASE 1:** the four app .dc.html prototypes · `EJADAH-BUILD-STORY.md` · `handoff/*` · `data/programmes.json` · `data/countries.js` · `export/16–23`.

**INTERNAL DESIGN REFERENCE:** Phase 0 Foundation sheets · the 7 audit canvases · `audit/*` · `demo-script.md` · `export/05–15`.

**FUTURE:** nothing designed-but-deferred exists as separate screens; future features are listed (not designed) in the build story's cut list.

**LEGACY / OBSOLETE:** `uploads/EJADAH-ARCHITECTURE.md` (PHP/CI3) · `uploads/EJADAH STAGE 6 USER STORIES.docx` + `data/stage6-*` (40/67 stories cut) · all `uploads/*.html` website exports (visual input only; old 6-tab web nav, old pricing tiers) · `uploads/EJADAH PRO 101.make` · `Ejadah-App-Standalone.html` (stale snapshot — regenerate or mark) · `scope-phase-1.md` **partially** (scope list current, tab list stale).

## 3 · Conflict register (full table in `SPEC_CONFLICTS.md`)

| # | Topic | A | B | Resolution |
|---|---|---|---|---|
| 1 | **Tab names/count** | Prototype: Home·Connect·Courses·Career·Masters·Profile (6) | This brief + build story: 5 tabs; brief names them Home·**Learn**·Career·**People**·Profile | **Brief wins (precedence rule 1):** Learn/People naming, Masters→Career. Prototype labels to be updated in cleanup |
| 2 | Technology | Old: React Native, then PHP/CI3 web packs | Current: Flutter + Dart + Dart backend | Flutter/Dart. PHP packs already deleted |
| 3 | Roadmap engine | Old: Claude API + validator | Current: deterministic, our-data-only | Deterministic (owner instruction 12–14 Aug, in build story) |
| 4 | Backlog | Stage 6 .docx (67 stories, exams/community/CMS) | Phase 1 Delivery Backlog | Phase 1 backlog; Stage 6 legacy |
| 5 | Course access | One session: "everything free 6 months / Premium" | Later: courses bought individually via IAP, lesson 1 free | **Courses = individual IAP purchases**; Premium covers database/guides/roadmaps/profile (build story Part 5 §3). Membership screen shows Premium status, renewal 30 Jan 2027, no prices |
| 6 | Payments | Old website exports show pricing tiers + web checkout for courses | App: IAP for courses, web for sessions/card | App rule wins; website exports are legacy visuals |
| 7 | Programme "Recognition" | Early designs showed recognition flags | Owner: "we don't need recognition" ×2 | Removed from database UI; unsourced data renders "Not verified" where the concept appears at all |
| 8 | Gap policy | Career-web pack: omit missing facts entirely | App/roadmap: print "Pending source" | **App convention wins for the app:** "Pending source". (The omission policy belonged to the deleted web pack) |
| 9 | Canonical logo | `assets/ejadah-mark.jpg` vs `ejadah-icon-...jpg` | — | **OWNER DECISION REQUIRED** — both are JPGs; production needs one declared canonical + vector/PNG master |
| 10 | Standalone bundle | Stale vs live prototype | — | Mark stale; live .dc.html is reference |

**Owner decisions required: #9 only** (plus the 5 open items in §8).

## 4 · Missing-handoff-artifact report

Existing coverage: tokens ✓ strings ✓ analytics ✓ deep links ✓ push ✓ scope ✓ backlog ✓ datasets ✓ build story ✓.
**Missing and to be created in `handoff-flutter/`:** personas file · single IA/navigation map · user flows with error/offline exits · fresh Phase-1 user stories (Stage 6 replacement) · acceptance criteria · feature matrix · glossary with EN/AR terms · consolidated brand guide (.md, tech-neutral) · brand voice · logo guide · imagery guide · iconography guide + icon map · DESIGN_TOKENS.json (neutral re-issue of tokens.ts) · component catalog + state matrix · layout/responsive rules · motion spec · accessibility spec · Flutter mapping · screen inventory/state matrix/component map · localization/RTL/BIDI guides · microcopy/validation/empty-error copy · asset manifest + placeholder list + licenses · golden screen index + QA checklist · design decisions · conflict register · legacy manifest · guidelines file · handoff checklist.

## 5 · Prototype UI inconsistencies found (to normalize in cleanup)

1. Historical `#8E8A83` muted labels were swept to `#6B6862`, but the **standalone bundle** still carries old values — regenerate or mark stale.
2. Orange-as-text: corrected to `#C2450F` in later screens; earliest screens (Phase 0 sheet) still show `#FF6B1A` small text — sheet must carry the correction note.
3. Card radius drift: 16/18/20px all appear on peer-level cards; canonical scale is 4/8/12/16/20/24 — 18px instances map to 20.
4. Eyebrow letter-spacing varies (.08em–.14em) in EN; tokenize to one value (.08em) — AR always 0.
5. Six-tab bar in the live prototype vs canonical five (conflict #1) — the single biggest visible cleanup.
6. Two "saved/heart" treatments (filled heart vs check pill) between Masters list and programme profile; pick the heart, used in 90% of cases.
7. Rail/demo controls (persona switcher, state pickers, gradient-budget cards) render alongside the phone — must be classified INTERNAL, not product UI.

## 6 · Asset findings

Only two raster logo files exist, both JPG, no vector, no dark-background variant, no declared favicon/app icon master → **logo guide will document what exists and flag the vector master as MUST SUPPLY**. All tutor/mentor/consultant photos are placeholder (pravatar-style) → MUST REPLACE (todo #30). Country flags load from flagcdn.com at runtime → must become bundled assets in Flutter. Course/hero imagery: none final.

## 7 · Missing screen states (to design in cleanup, same visual system)

Per-screen matrix in `04-screens/SCREEN_STATE_MATRIX.md`. Headlines: Home has all 6 states ✓; **Masters/Learn/People lists lack loading skeletons** (todo #38-4); offline states exist as system screens but per-screen cached-content behaviour is undesigned for Learn player and People booking; "signed-out" variants exist via the guest gate for Career only — Learn/People need their guest treatment documented (browse-open, act-gated); partial-data state exists on Home only.

## 8 · Missing component definitions + open product items

Components used but never spec'd as reusables: DeadlineBadge (red/green urgency chip) · VerificationBadge (verified vs stated) · SourceLine ("verified on + source") · PendingSourceChip · WeekStepper (plan scheduler) · AvailabilityGrid · SlotButton · HoldCountdown · CurrencyText (LTR-isolated) · PersonaSwitch (internal-only). All enter `COMPONENT_CATALOG.md`.

**Open items needing the owner (carried from todos):** real rosters (#30) · Arabic clinical-terminology review (#31) · 11 pending regulator fees (#32) · 3-minute activation timing test (#36) · canonical logo + vector master (conflict #9).

---

**Next:** cleanup + the canonical `handoff-flutter/` folder, per the proposed structure in the brief (accepted as-is, with files combined where noted in each folder's README).
