# Ejadah International Academy — Markdown Export
**Exported 2 August 2026** · 23 files · every design, document and dataset in the project, with full source code.

---

## How to read the design files (01–11)

Each of these is a **Design Component**: one self-contained HTML file that opens directly in a browser with no build step. Every export splits it into the two parts you actually edit:

- **Template** — the markup that sits between `<x-dc>` and `</x-dc>`. Styling is inline, deliberately: it paints from the first streamed character rather than waiting for a stylesheet.
- **Logic** — a `class Component extends DCLogic` whose `renderVals()` returns the values the template's `{{ }}` holes read. Holes are **dotted lookups only** (`{{ user.name }}`), never expressions — anything computed lives in `renderVals()` and is exposed by name.

To reassemble a working file: document shell → `<x-dc>` + template + `</x-dc>` → `<script data-dc-script>` + logic + `</script>`.

## The app

| File | What it is |
|---|---|
| **01 App - Home and Career** | The whole Phase 1 build. 95 screens, six tabs, both languages, every state. 522 KB of source — this is the product. |
| **02 App - Phase 0 Foundation** | Design system and primitives sheet: colour, type scale, spacing, components, both languages and both directions. |
| **03 App - Programme Profile** | Deep profile for King's College London MSc Endodontology, nine sections, English and Arabic. |
| **04 App - Notification Centre** | Grouped Today / This week / Earlier, swipe to dismiss. |

## The audit (eight phases, six canvases)

| File | What it answers |
|---|---|
| **05 Phase 1 - Sitemap** | Every screen, clustered and colour-coded by journey stage. Zero dead ends in the app. |
| **06 Phase 2 - Journey Maps** | Six user types × seven stages. The GP dentist journey is the only complete one — protect it. |
| **07 Phase 3 - Interconnection** | The structural finding: 13 chains, but only **3 crossings** from the free half to the paid half, and **none reaches a course**. |
| **08 Phase 4 - Revenue Map** | Nine trigger moments, three payment rails, and five things not to monetise. |
| **09 Phase 5 - SEO Architecture** | ~400 target pages, Arabic-first. Two items block launch. |
| **10 Phases 6-7 - Action Plan** | The v2 of each feature, then a 16-item board with a "know it worked" metric each. |
| **11 Product Audit and Growth Plan** | The earlier combined audit. |

## Documents

| File | What it is |
|---|---|
| **12 Handoff - Developer Guide** | The engineering starting point: screen map, data schemas, normative design rules. |
| **13 Scope - Phase 1 (locked)** | What is in and what is explicitly out, with the standing decisions. |
| **14 Demo Script** | How to walk someone through the build. |
| **15 Backlog - Phase 1 Delivery** | Rebuilt from the Stage 6 document. ~40 of its 67 original stories were for cut features. |

## Handoff assets and data

| File | What it is |
|---|---|
| **16 Analytics Events** | ~35 events. Only 4 are wired — until the rest are, activation is unmeasurable. |
| **17 Deep Links** | URL scheme for every screen worth linking to. |
| **18 Push Notifications** | Three categories, independently switchable. No marketing category. |
| **19 Design Tokens** | Colour, type, spacing, motion. Each contrast value states its **measured** ratio and the background it was measured against — that discipline exists because an earlier version asserted ratios without measuring and the error propagated into two documents. |
| **20 Strings EN** / **21 Strings AR** | 337 keys each, key-identical. Arabic is authored, not translated after. |
| **22 Data - 23 Country Guides** | All 23 licensing pathways, bilingual. |
| **23 Data - 199 Programmes** | The real dataset from your spreadsheet. |

---

## Two things to carry forward

**Unpublished facts read "Pending source".** Eleven regulator fees are in that state. They are never estimated, never rounded, never inferred — that discipline is the entire reason a dentist would trust this over a Facebook group, and it should survive contact with a tidier-looking page.

**Measurement comes before opinion.** With 4 of ~35 events instrumented, every recommendation in the audit — including mine — is an argument rather than a finding.
