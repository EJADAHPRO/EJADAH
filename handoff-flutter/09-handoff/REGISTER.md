# Handoff Register — Conflicts · Legacy · Decisions · Checklist
### Combines: SPEC_CONFLICTS, LEGACY_FILES, DESIGN_DECISIONS, IMPLEMENTATION_NOTES_FLUTTER, HANDOFF_CHECKLIST
Full audit narrative: `AUDIT-REPORT.md` (this folder).

## Spec conflicts (resolved unless marked)
| # | Topic | Old rule (file) | Current rule | Why |
|---|---|---|---|---|
| 1 | Tabs | 6 tabs Home/Connect/Courses/Career/Masters/Profile (prototype, scope-phase-1.md) | **5: Home·Learn·Career·People·Profile** (this handoff brief, precedence rule 1) | Learn=Courses, People=Connect, Masters→Career; prototype labels to update |
| 2 | Tech | React Native intent → PHP/CI3 packs (deleted) | **Flutter + Dart + Dart backend** | owner decision 14 Aug |
| 3 | Roadmap | Claude API + validator (deleted pack) | **Deterministic, our-data-only** filter→score→assemble | owner 12–14 Aug; trust is the product |
| 4 | Backlog | Stage 6 .docx (67 stories) | `Ejadah - Phase 1 Delivery Backlog.md` + FLOWS_STORIES_CRITERIA §2 | 40/67 stories were for cut features |
| 5 | Course access | "all free 6 months" session | **Premium free (renews 30 Jan 2027) covers data features; courses individual IAP, lesson 1 free** | owner correction; §3.1.1 |
| 6 | Payments | website tiers + web checkout for courses | courses IAP / sessions external / card external | legal split, never harmonise |
| 7 | Recognition flags | early designs showed per-country flags | removed from DB UI; "Not verified" where concept appears | owner ×2 |
| 8 | Gap policy | web pack: omit silently | **app: print "Pending source"** | app is the product; web pack deleted |
| 9 | Logo master | two JPGs, no vector | **OWNER DECISION REQUIRED** — supply vector + variants | blocking store assets only |
| 10 | Standalone.html | stale bundle | live .dc.html wins | mark stale |

## Legacy manifest (keep for history, never follow)
`uploads/EJADAH-ARCHITECTURE.md` (PHP/CI3 — tech dead; product notes only) · `uploads/EJADAH STAGE 6 USER STORIES.docx` + `data/stage6-*` (superseded; validation-block style worth stealing) · all `uploads/*.html` (old-website visuals: 6-tab web nav, pricing tiers, recognition UI = all dead; useful as content/tone reference for tutoring/mentoring/consulting/King's) · `uploads/*.pdf` brand/build specs (older palette naming #E23016/#F47B20/#F9B41C — tokens.json wins) · `uploads/EJADAH PRO 101.make` · `Ejadah-App-Standalone.html` (stale) · `scope-phase-1.md` (scope list valid, tab list stale) · `export/12` developer guide (references deleted packs — historical).

## Design decisions (do not "improve" away)
Gradient limited to 6 uses → scarcity keeps it premium · warm neutrals not white/gray → editorial, not SaaS · Playfair+Amiri → authority pairing; Amiri because Playfair has no Arabic · Western numerals in AR → exam codes/fees are Latin-context; mixing breaks scanning · "Pending source" → visible honesty makes every other number credible · card radius 20 (xl) at card level · Career fact-density is intentional — dentists distrust prose · no emoji, no exclamation UI · Arabic default → the audience · deterministic roadmap → reproducibility is the trust claim · gate after funnel not before → invested effort converts · no user-to-user messaging → moderation liability, deliberate · courses IAP-only → legal, not preference · new-tutor rail → cold-start supply survival · 44×44 + reason-on-tap disabled → the two most-felt a11y rules.

## Flutter implementation notes
Read `03-design-system/DESIGN_SYSTEM.md` §6 first. Also: assert gradient-count in debug · generate ARB from handoff/strings JSONs (keys 1:1; build fails on missing key) · PageStorageKey per tab list · go_router with the deep-link table · in_app_purchase only in Learn · url_launcher for ejadah.international checkout + regulator links (external-link icon + noopener semantics) · bundle fonts + flags · analytics wrapper stamps lang/persona/version/ms_since_first_open on every event (taxonomy: handoff/analytics-events.md) · min-display pacing on generating screen (~2.2s) even though generation is instant.

## Handoff checklist — state at delivery
☑ one scope · ☑ one nav map · ☑ one brand guide · ☑ one token source (JSON) · ☑ one design system+catalog · ☑ one story set · ☑ one screen inventory · ☑ one state matrix (4 skeleton gaps flagged as build tasks) · ☑ EN/AR terminology single source · ☑ asset manifest · ☑ legacy manifest · ☑ conflict register (1 owner decision open) · ☑ golden refs = live prototypes · ☑ no old-tech instructions inside handoff-flutter · ☑ no React styling needed to understand the design · ☐ prototype tab-labels still say Connect/Courses/Masters (mapping documented; relabel is the one remaining prototype cleanup) · ☐ vector logo (owner) · ☐ real rosters/photos (owner) · ☐ 11 pending fees (owner) · ☐ AR clinical review (owner).
