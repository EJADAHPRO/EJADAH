# Quality audit — Ejadah Phase 1 app
Run 29 July 2026 against the build brief's §9 (bilingual), §10 (definition of done) and §8 (brand).
Method: static analysis of the prototype source, not inspection by eye.

---

## Fixed in this pass

**1 · Arabic tracking on Arabic text — 10 instances (§9 breach)**
Tracking breaks Arabic letter joining; the brief calls it "the most visible error possible".
Found hardcoded `letter-spacing` on elements that render Arabic: the language-picker eyebrow,
POPULAR / ACTIVE badges, course-format and accreditation pills, exam and QS badges, the referral
code label and the WhatsApp preview label.
Fix: three language-aware tokens — `lsE` (.12em → 0), `lsB` (.06em → 0), `lsF` (.08em → 0).
English keeps its tracking; Arabic gets zero. **10 replacements.**

Deliberately left: `.28em` on password dot fields, `.16em` on the DELETE confirmation field,
`.22em` on the Latin "EJADAH INTERNATIONAL ACADEMY" card line — no Arabic passes through them.

**2 · Touch targets under 44×44 — 34 controls (§10 breach)**
Filter and department chips measured ~33–40px tall; three ghost buttons were 42px; inline text
buttons had no height at all.
Fix: `min-height:44px` on all pill chips (16 + 4 + 8 = 28 controls), 42px → 44px on ghost buttons
(6), `min-height:44px` on zero-padding text buttons (3). **34 controls.** Visual size unchanged —
the hit area grew, not the pill.

**3 · Dead string keys — 6 removed**
`flagsEg / flagsAe / flagsSa / flagsQa` (recognition flags, cut from scope), `sections`, `clearance`.
These were the entire EN/AR asymmetry.

---

## Verified clean (previously only asserted)

- **String parity: 338 / 338.** Both tables carry identical key sets after the six dead keys were
  dropped. No hardcoded English string inside the phone frame that should be localised.
- **`text-transform: uppercase` inside the app: 0.** Arabic has no case; the two hits were in the
  English-only review rail.
- **Playfair Display inside the app: 1**, and it renders the Latin string "EN" on the language
  picker. Playfair has no Arabic glyphs, so this is correct rather than a violation.
- **Gradient budget: no screen exceeds 6.** The loading screen counts 8 `linear-gradient`
  declarations but they are grey shimmer skeletons, not brand gradient surfaces.
- **Physical-direction CSS: 0.** Everything uses logical properties (`inset-inline`,
  `padding-inline`, `margin-inline`), so RTL mirrors without per-screen overrides.

---

## Open — needs a decision or data, not design

| # | Finding | Recommendation |
|---|---|---|
| 1 | **Analytics: 4 events wired, ~35 required.** The headline metric — roadmap reached within three minutes — cannot be measured at all today. | Wire `handoff/analytics-events.md` in Batch 1. Events 8 and 10 carry `ms_since_first_open`; without them there is no metric. |
| 2 | **`warmGray` #716D67 on `offWhite` is 4.28:1.** Passes AA at 14px+, fails at the 10–11px micro sizes used for card meta and tab labels. | Use `color.labelMuted` #8E8A83 (4.5:1) below 12px. Already applied to tab labels; ~40 micro labels elsewhere still use warmGray. |
| 3 | **11 regulator fees still read "Pending source."** | One enquiry each: Bahrain and Ireland exam fees, Netherlands/Sweden/Switzerland assessments, Singapore QDLE, South Africa board, Malaysia MDC. |
| 4 | **200% OS font scale untested.** §10 requires it. | Cannot be tested in a fixed-width prototype frame; must be checked on device in Batch 1 once the primitives are real components. |
| 5 | **Tutor, mentor and consultant rosters are illustrative.** Names, photos and rates are placeholders drawn from the website's structure. | Replace with the real roster before any external demo. |

---

## What this audit cannot tell you

Static analysis proves the tokens are right; it says nothing about whether the *flows* are right.
The two things worth testing with real dentists before engineering starts:

1. **Time the funnel.** Sit five Cairo dentists down and time them from cold open to a saved
   roadmap. The brief's three-minute claim is currently an assertion, including mine.
2. **Read the Arabic aloud.** The Arabic here is fluent but written by a machine. A dental
   professional needs to check the *terminology* — particularly specialty names, exam names, and
   whether "خارطة مسار" reads as natural as "roadmap" does in English.
