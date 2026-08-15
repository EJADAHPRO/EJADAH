# Design System — Components · States · Layout · Motion · A11y · Flutter Mapping
### Combines: DESIGN_SYSTEM, COMPONENT_CATALOG, COMPONENT_STATE_MATRIX, LAYOUT_SYSTEM, RESPONSIVE_RULES, MOTION_INTERACTION, ACCESSIBILITY, FLUTTER_DESIGN_MAPPING
Tokens: `DESIGN_TOKENS.json`. All values below reference tokens; raw values in code are defects.

---

## 1 · Component catalog (canonical names — use these in Flutter)

**Shell:** `EjadahAppBar` (title, back-mirrored, optional action) · `EjadahBottomNav` (5 tabs, gradient indicator bar slides, filled active icon, labelMuted inactive, 72h, badge dot) · `PageHeader` (eyebrow orangeText + h-title + optional sub) · `SectionHeader` (eyebrow + optional "See all").
**Buttons:** `EjadahPrimaryButton` (gradient, 52h, radius lg, primaryGlow, press .97, spinner-in-place width-frozen; ONE per screen) · `EjadahSecondaryButton` (white, 1.5 borderGray, 48h) · `EjadahGhostButton` (text-only, secondary colour) · `EjadahDestructiveButton` (danger-tint bg, dangerText, confirm-required) · `EjadahIconButton` (44×44 min).
**Cards (all: white, 1.5 borderGray, radius xl, elevation.card, press scales card only):** `ProgrammeCard` (uni, title, country flag, deadline badge, tuition, heart) · `CountryCard` (flag, name, exam code pill gold, class/months/difficulty chips, POPULAR gradient pill) · `CourseCard` (thumb, title, dept tag, lessons·hours, plan/price line) · `ProfessionalCard` (avatar/initials, name, rating★ or NewBadge, specialty/journey line, rate LTR, intro-call tag) · `BookingCard` (date block, title, meta, action) · `CertificateCard` (title, CPD, VerificationBadge) · `RoadmapCard` (dark variant, fit pill, progress) · `StatCard` · `CtaCard` (gradient — counts against budget) · `DarkCard` (charcoal, radial gold glow).
**Rows:** `ListRow`/`SettingsRow` (44+ h, chevron mirrored) · `NotificationRow` (unread dot, swipe-dismiss) · `EarningRow` (gross −fee =net, tabular LTR).
**Inputs:** `EjadahInput` (48h, radius md, focus ring orange 3px offset) · `SearchField` (icon start) · `Textarea` · `PasswordInput` · `OtpBoxes` (6, LTR always) · `Select` · `Radio`/`Checkbox`/`Switch` (brand orange accent) · `BudgetSlider` (range + Playfair/Amiri output LTR + live band hint).
**Selection:** `EjadahFilterChip` (36h min, aria-pressed model: selected = orange 8% bg + orange border) · `Tag` (paleGray) · `Badge` · `DeadlineBadge` (soon: danger-tint "N days left"; open: success-tint "Open now") · `VerificationBadge` (verified: success "Verified by Ejadah" / stated: paleGray "Stated by the tutor") · `PendingSourceChip` (amber-tint, warningText, exact string) · `SourceLine` (regulator + "Verified on {date}" + link) · `CurrencyText` (LTR-isolated, Western numerals).
**Navigation-in-page:** `EjadahTabs` (underline slides) · `SegmentedControl` (2–4) · `Stepper`/`ProgressBar` (gradient fill, mirrors) · `WeekStepper` (pills: number → gradient current → success tick done; server-worded status line) · `Pagination` ("1–12 of 199", 44×44 arrows mirrored).
**Time:** `Calendar`/`DateStrip` · `SlotButton` (untappable when unavailable — not tappable-then-rejected) · `AvailabilityGrid` (day rows × block chips + custom hours) · `HoldCountdown` ("held for you 14:32", LTR digits, aria-live).
**Overlays:** `EjadahBottomSheet` (radius xxl top, grab handle, finger-tracked drag; options/filters/confirmations — never long forms) · `EjadahDialog` (destructive confirm only) · `Toast` (with optional Undo action, 5s) · `Banner` (offline espresso persistent) · `InlineAlert`.
**Feedback:** `Skeleton` (shapes of coming content, shimmer) · `EjadahEmptyState` (icon tile, title, body, ACTION — mandatory) · `EjadahErrorState` (plain words + retry) · `OfflineState` (cached-readable note).
**Media/learning:** `VideoPlayerControls` (play never mirrors) · `QuizOption` (correct success/ wrong danger + explanation) · `Flashcard` (tap flip, swipe again/got-it) · `NfcPreview` (live-updating card) · `RatingStars` (amber, LTR).
**Internal-only:** `PersonaSwitch`, state pickers, gradient-budget cards — never ship in product UI.

**Per-component spec contract** (applies to all above): anatomy = container/leading/content/trailing; sizes from tokens; min tap 44; RTL = logical edges + mirrored directional icons; AR type rules auto-applied; "do not use when" noted in code doc comments.

## 2 · State matrix (mobile-first — no hover reliance)

| Component | default | pressed | focus | selected | disabled | loading | error/success |
|---|---|---|---|---|---|---|---|
| Primary/Secondary/Ghost button | ✓ | scale .97 + haptic | ring | — | 50% + **reason-on-tap toast** | spinner-in, width frozen | ✓ brief ✓600ms |
| FilterChip / SlotButton | ✓ | ✓ | ring | orange-tint | unavailable = not rendered tappable | — | — |
| Cards | ✓ | card scales | ring | compare-check | comingSoon .6 non-focusable | skeleton | — |
| Input | ✓ | — | orange ring | — | 50% | — | danger border + message below, role=alert |
| Tabs/BottomNav | ✓ | ✓ | ring | indicator slides | — | — | badge |
| Switch/Check/Radio | ✓ | ✓ | ring | ✓ | 50% | — | — |
| Sheet/Dialog | — | drag-tracked | trap | — | — | — | — |
| Toast | — | Undo tappable | — | — | — | — | ✓ |

## 3 · Layout & responsive

Gutters 20 (compact) / 24 (medium+). Section spacing 32; card gap 12–16; list row gap via `gap`, never margins-between. Content max-width 480 on phone-style screens; 720 reading width on guides; bottom-nav safe area always reserved. Sticky bottom bar (blur offWhite 94%, top border) on any >1-viewport screen with a single main action: booking steps, plan builder, roadmap funnel, CV builder, order card. Sheets full-width compact, 480 max medium+. Dialogs 320–400.

**Breakpoints (fluid, not device models):** compact <600 · medium 600–1023 · expanded ≥1024.
Per-pattern reflow: **Programme/country compare** compact = stacked cards per item (never horizontal-scroll table) → medium = 2-col table → expanded = full columns. **Tutor/course/programme grids** 1 → 2 → 3 columns. **Guide authority blocks** always stacked (sequential reading). **Jump-nav pills** hidden compact, sticky medium+. **Home feed** single column always; explore tiles 2-up compact → 4-up expanded.

## 4 · Motion

All durations/curves from tokens; reduce-motion = suppress transforms, keep ≤150ms fades. Route push: slide-in from trailing edge (mirrors) 200ms + fade. Tab switch: fade 150 + indicator slide 200. Sheet: up 300, finger-tracked dismiss. Dialog: fade+scale .96→1, 200. Card/button press: .97, 150, haptic on press-in. Save/heart: fill + 1.15→1 pop 200. Filter select: 150 tint. Stepper/progress fill: 300 on mount (rings fill, never appear complete). Roadmap result reveal: stagger sections 40ms once. Toast: up+fade 200, hold 4s (5s w/ Undo). Skeleton shimmer 1.2s linear. Success tick: draw 300. Numbers animate up on first appearance only.

## 5 · Accessibility

AA contrast measured against composited bg (orangeText/labelMuted rules in tokens). 44×44 targets. Every interactive element labelled in the **active language**. Focus visible (3px orange ring, offset 2). Screen-reader order = visual order; steps announce "step n of m" (semantic ordered list). Dynamic type to 200% without clip — test the AR long-heading case. Reduce-motion honored. Status never colour-only (icon or text pairs it). Form errors: below field, role=alert, focus moves to first invalid on submit. Modals trap focus, return on close. Flutter Web: full keyboard traversal on funnel, booking, forms. RTL semantics: `Directionality` drives everything; no manual left/right.

## 6 · Flutter mapping

| Design concept | Flutter |
|---|---|
| Tokens | `ThemeExtension<EjadahTokens>` generated from DESIGN_TOKENS.json (colors, radii, spacing, elevation, motion) |
| Type scale | `TextTheme` + `EjadahText` widget that swaps family/line-height/letter-spacing on locale and applies the −12% AR long-heading rule |
| Gradient | `EjadahGradient.of(context)` → LinearGradient with angle from Directionality; a debug counter asserts ≤6 per screen in dev builds |
| Buttons/cards/chips | the `Ejadah*` widget family above — **not** raw Material buttons restyled ad hoc; Material 3 may power internals but visuals come from tokens |
| Bottom nav | custom `EjadahBottomNav` (indicator slide via `AnimatedPositioned`) |
| RTL | wrap app in locale-driven `Directionality`; use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end`; mirrored icons via `matchTextDirection`/manual flip list from Brand Guide §7 |
| Bidi islands | `Directionality(textDirection: ltr)` around `CurrencyText`, codes, dates, OTP |
| Numerals | force Western: `intl` with `en` numbering for numbers in both locales |
| Responsive | `LayoutBuilder` breakpoints 600/1024; compare-table→cards switch lives in the component |
| Persistence | scroll per tab: `PageStorageKey`; filters/drafts/video pos: local store (e.g. shared_prefs/isar) restored on launch |
| Skeletons | shimmer package or custom; shapes per screen spec |
| Haptics | `HapticFeedback.selectionClick` chips/tabs, `.lightImpact` primary press-in, `.mediumImpact` booking success |
| IAP | in_app_purchase for courses only; sessions/card open external checkout via url_launcher |
| Deep links | go_router paths per `handoff/deep-links.md`; back from deep link → tab root |
| Strings | ARB files generated from `handoff/strings.{en,ar}.json`; keys 1:1 |
| Fonts | bundle Playfair Display, Inter, Amiri, IBM Plex Sans Arabic; never system-fallback Arabic |

**Do not** ship default-Material aesthetics arranged like Ejadah; build Ejadah components in Flutter.
