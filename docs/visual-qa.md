# Visual QA — the sweep, and what it found

The checklist in `handoff-flutter/07-assets/ASSETS_AND_REFERENCE.md` §"Visual QA
checklist (Flutter vs golden)", worked screen by screen in both languages
against the live prototypes and the design system.

**The instruction was: log every divergence, fix only token-level drift.** This
file is the log. What was fixed is marked FIXED and named in the commits;
everything else is a decision the owner has not made yet, and none of it should
be quietly closed by the next person who reads this file.

## A note on the prototypes as a colour reference

`ASSETS_AND_REFERENCE.md` warns that the *Phase 0 Foundation* prototype pre-dates
the `#C2450F` / `#6B6862` corrections. **All three app prototypes do.**
`Ejadah App - Home & Career.dc.html` — the one the manifest names as the golden
reference — uses brand orange `#FF6B1A` as text 112 times and carries one
instance of the banned `#8E8A83`, and its type ramp is a continuous 8.5–26px
sequence rather than the twelve-step token scale.

`DESIGN_TOKENS.json` wins on both counts, and the app follows the JSON. **Treat
all three prototypes as layout, content and ordering references only, never as a
colour or type reference.** The caveat in the manifest should be widened from
Phase 0 to all three.

---

## Clean, verified

Recorded because a list of only problems reads as though nothing is right, and
several of these are the categories most likely to have rotted.

- **Colours.** Zero literal `Color(0x…)` outside the generated tokens file. The
  two `Colors.transparent` uses remove a Material default and are absences, not
  brand colours. `orangeText` `#C2450F` and `labelMuted` `#6B6862` both resolve
  correctly, and — the stricter question — brand orange is never used as text
  anywhere: all 30 uses are fills, borders, indicators, cursors or the scheme
  seed.
- **Elevation.** Every shadow in the product resolves to a token. No raw
  `BoxShadow` outside the tokens file, and no Material `elevation:` anywhere.
- **Radius.** Zero raw `BorderRadius.circular(N)`. The "no 18px cards" check
  passes explicitly — cards are `EjadahRadius.xl` = 20.
- **Arabic typography rules.** Zero letter-spacing in Arabic is enforced
  centrally with no unconditional `letterSpacing` anywhere; `toUpperCase()` is
  gated behind `eyebrowText()` at all 36 eyebrow sites; the −12% long-heading
  reduction is implemented, uses grapheme clusters, and is unit-tested.
- **RTL directionality.** Zero `EdgeInsets.only(left:/right:)`,
  `Alignment.centerLeft/Right`, `Positioned(left:/right:)` or
  `TextAlign.left/.right` in product code. Bidi islands are pinned around every
  rate, count, time, exam code and page number.
- **Gradient discipline.** The six permitted uses are encoded verbatim from the
  brand guide; every gradient in the app routes through `BrandGradient`; the
  angle mirrors in RTL, matching the prototype's own 135°/225° pair; and the
  step-marker guard was verified against the real 23-guide data (Germany, the US
  and Australia correctly fall back to charcoal).
- **No remote images.** Zero `flagcdn.com`, `pravatar`, `NetworkImage` or
  `Image.network` reachable from app code — or from the server. `avatarUrl` is
  carried on the model and deliberately never read, so no code path can fetch a
  portrait.
- **Fonts.** All four faces bundled; no system fallback for Arabic.
- **Navigation.** Exactly five tabs, an indicator that animates and mirrors,
  edge-swipe back on every platform, and `PageStorageKey` on every tab root.
- **State matrix.** All four skeleton gaps the matrix flags as open are closed,
  and `EjadahEmptyState` makes a dead end structurally impossible — the action
  is a required constructor parameter, and all 19 call sites route somewhere
  real.

---

## Fixed in this sweep

| # | What | Where |
|---|---|---|
| 1 | **`DirectionalIcon` double-flipped**, so all 20 list-row chevrons pointed the wrong way in Arabic | `ejadah_icons.dart` |
| 2 | **The tab indicator sat outside every gradient budget**, tripping a debug assert on every tab route | `app_shell.dart` |
| 3 | **Empty and error states could not scroll**, so at 200% Arabic the mandatory action was unreachable | `ejadah_states.dart` |
| 4 | **The secondary and destructive buttons had a fixed height** and ellipsised their labels at 200% | `ejadah_buttons.dart` |
| 5 | **The new-this-month rail had a fixed 172 height** and clipped its cards at 200% | `professional_list_screen.dart` |
| 6 | **Home's explore tiles had a fixed aspect ratio** and overflowed off the top at 200% | `home_sections.dart` |
| 7 | The AR −12% heading rule was inert on two headings that needed it | `flashcards_screen.dart`, `programme_detail_screen.dart` |
| 8 | `fontWeight: w600` on a ledger figure, which also left a body line-height on a table | `earnings_screen.dart` |
| 9 | Twelve `fontSize: 12/13` literals, and two skeletons written as `18` and `22` — the codebase's own stated defect | 12 files |
| 10 | `56` written twice for the app bar height; `172`/`280`/`56` given names | `ejadah_tokens.dart`, `ejadah_shell.dart` |

Findings 1 and 2 shared a cause worth naming: **the suite asserted the rules and
not the rendering.** `mirrorsInRtl(chevron) == true` and `maxPerScreen == 6`
were both correct while the screen was wrong. Both now have tests that measure
what is painted, and both tests were confirmed to fail against the old code
before the fix landed.

---

## Logged, not fixed — needs an owner decision

### D1 · Compare is a horizontal table on a phone, and the spec forbids it by name

`DESIGN_SYSTEM.md` §3: *"Programme/country compare — compact = stacked cards per
item (**never horizontal-scroll table**) → medium = 2-col table → expanded = full
columns"*.

Both `compare_programmes_screen.dart` and `compare_countries_screen.dart` build
a nested `SingleChildScrollView(scrollDirection: Axis.horizontal)` with a fixed
168pt column width — 622pt of content in a ~350pt viewport — and neither reads
`windowClass` or has a breakpoint at all. The code carries a comment defending
the choice:

> *The table scrolls both ways: three columns of dense facts do not fit a phone,
> and squeezing them to fit is what makes a comparison unreadable.*

That is a real argument, and it is the opposite of what the design system says.
Not a token fix — it is a rebuild of two screens behind a `LayoutBuilder`, and
ideally a `CompareTable` component in `ejadah_ui` so the switch lives in one
place. **The owner should rule: keep the table and amend the design system, or
build the stacked-card variant.**

### D2 · Flags are specified, and no flag asset exists

`ASSETS_AND_REFERENCE.md`: *"**MUST BUNDLE** locally (`assets/flags/{iso2}.png`),
never runtime-fetch"*. The never-fetch half is clean. The bundle half is absent:
`apps/mobile/assets` does not exist, `pubspec.yaml` has no `assets:` key, and 0
of the 23 country flags are present.

`ProgrammeCard` and `CountryCard` both name the flag first in their anatomy and
render none. `Programme.countryIso` exists, is documented as *"used for the
bundled flag asset"*, and is read by nothing but route parameters. **Owner
asset** — the manifest says to bundle from a clean source rather than mirror
flagcdn, which is a licensing decision, not a code one.

### D3 · Two initials avatars, three rating displays, and no canonical component

`DESIGN_SYSTEM.md` §3 closes with *"a slightly-different per-screen variant of a
catalogued component is a defect"*. Five instances:

- **Initials avatar, twice.** `InitialsAvatar` is a circle at 56 taking first +
  last word; `ProfessionalAvatar` is a rounded square at 48 taking first +
  second word after stripping «د.»/"Dr.". "Dr. Mona Adel Hassan" is `DH` on
  Profile and `MA` on a professional card.
- **Rating, three times.** `RatingStars (amber, LTR)` is named in the design
  system and does not exist. Two inline variants at different star sizes appear
  on the *same* Arabic screen, and the five-star review row is **not**
  LTR-isolated — so a 3-of-5 review renders its fill backwards in Arabic.
- **Price, twice.** `earnings_screen.dart` uses `CurrencyText` correctly twice,
  then hand-builds `'EGP …'` and `'−…'` four more times in the same file —
  neither LTR-isolated nor tabular, on the one screen the brand guide names
  specifically for tabular figures. The `'−300'` case is the classic bidi
  reversal the `CurrencyText` doc comment exists to describe.
- **`EjadahListRow`'s default chevron does not exist.** The class doc promises
  *"a mirrored trailing chevron"* and `trailing` is documented as *"replaces the
  default"*; there is no default, so seven navigating rows have no affordance at
  all, while eleven pass one explicitly.
- **Progress bar, three times**, at heights 4 and 6, all raw Material, none with
  the gradient fill the design system specifies.

The shape is one thing repeated: **a canonical component either does not exist
in `ejadah_ui` or exists and is not reached.** The fix is to promote
`RatingStars`, `ProgressBar` and one `InitialsAvatar` into the package and give
`EjadahListRow` its default. That is component work, not token drift.

### D4 · Two screens in the inventory have no implementation

Both are marked SECONDARY in `PRODUCT_CORE.md`, and neither was cut:

- **CR-08 My roadmaps** — no screen, no route. CR-07 what-if is built and nested
  inside the result screen, but there is nowhere to list saved roadmaps.
- **CR-18 Career search** — no screen, no route, no "scoped note" string. The
  only search is the programme-database field.

Recorded in `implementation-status.md` as NOT BUILT rather than left implied.

### D5 · Programme detail is eight sections short of the prototype and the backlog

The prototype's programme page is a hero plus eight sections — overview,
curriculum, requirements, application guide, scholarships, after the MSc, living
and visa, FAQs — with an admissions card and a sticky bar carrying tuition and
Apply. The app renders title, location, deadline, ten key facts, the recognition
caveat, sources and Save.

**But none of those sections' strings exist in `handoff/strings.en.json`** —
every key was checked. The shipped string table already describes a descoped
page, and the app matches the string table, which is the source of truth.

The conflict is with the delivery backlog, story P-2.2, which lists those
sections as acceptance criteria. **Either the backlog line or the status line is
stale, and only the owner can say which.** Recorded as PARTIAL in
`implementation-status.md` in the meantime.

### D6 · Two screens are reachable from exactly one conditional widget

- **`/bookings`** is reachable only from `UpcomingSessionCard` on Home, which
  renders only when a *future* booking exists. A user with only past or
  cancelled sessions cannot reach their own booking history. The Connect hub's
  "My bookings" door is in the prototype and both its strings —
  `bookingsTitle`, `bookingsBlurb` — are already translated and unused.
- **`/notifications`** is reachable only from the Home bell. `rowNotifications`
  is translated and unused; the prototype has the row on Profile.

Cheap to close and it uses strings that already exist. Left for the owner
because adding a row to two hub screens changes their information architecture,
and this sweep's brief was to log rather than to redesign.

### D7 · Home is missing two prototype sections, and the model cannot carry them

"Continue" (in-progress courses and due decks) and "Tutors for you" both exist in
the prototype with translated, unused strings — `continueLabel`, `tutorsLabel`,
`tutorsSub`. `HomeFeed` has no fields for either, so this is a server change as
well as a client one. The prototype also orders Explore before Deadlines; the app
reverses them.

### D8 · The roadmap result drops four prototype elements

The destination country is never named on screen (only inside the share text);
the total-time / estimated-cost / difficulty stat row is absent and the model has
no field for two of the three; per-stage "Mark done" is absent although
`RoadmapStage.isComplete` exists on the model; and the winning destination's
country guide is not linked, though alternatives are.

The gate itself diverges deliberately and better: the prototype blurs two stage
rows client-side, the app withholds them server-side and states the count.

### D9 · Smaller divergences, recorded

- The booking flow lost the prototype's file-upload and session-format steps.
  The patient-data warning survived onto the goal step, which is the half that
  mattered.
- `country_detail_screen.dart` builds no app bar in its loading branch, two lines
  below a comment requiring exactly that.
- `course_detail_screen.dart` re-implements `EjadahStickyBar` by hand and
  reserves `bottom: 120` for it — a hand-counted number that does not include
  the home indicator and does not grow with type, so the last curriculum rows
  sit under the bar at large text.
- `my_bookings_screen.dart` uses a raw Material `TabBar` instead of `EjadahTabs`,
  losing the `isScrollable: true` that exists specifically so Arabic labels are
  not squeezed.
- `course_list_screen.dart`'s empty action is unconditionally "Clear all", which
  is a no-op when the department is simply empty.
- The tutor dashboard's two empty sections are bare `Text` rather than
  `EjadahEmptyState`, so an empty week offers no next step.
- The notification skeleton renders four card shapes where the matrix asks for
  three row shapes.
- `externalLink` (`open_in_new`) mirrors in RTL although the mirror list reports
  that it does not — Material mirrors it deliberately, so this is a
  documentation mismatch rather than a visual bug.
- The skeleton shimmer always sweeps visual left-to-right and does not mirror.
- The guest Home branch is the one tab-root scrollable without a
  `PageStorageKey`.
- Pushed screens end with a 32pt trailing gap against a home indicator of up to
  34pt, so the last card's edge sits under it.
- Course cards render no thumbnail block, which the design system's anatomy
  opens with.

### D10 · The −12% heading rule is opt-in, and opted out of at 12 of 19 sites

`h3(text: …)` arms the Arabic long-heading reduction; `h3()` silently disables it
by measuring an empty string. Every omitting site was checked against the real
Arabic strings: two were live drift and are fixed above, the rest are safe today
and latent — they break the day a translator lengthens a string.

Making `text` a required parameter would close it permanently, at the cost of
touching 19 call sites. **That is an API change to the design system rather than
token drift, so it is logged rather than done.** It is the single highest-value
structural fix in this file.

### D11 · Five component values have no token to reach for

`focusRingWidth` (3), `dialogMinWidth`/`dialogMaxWidth` (320/400),
`readingMaxWidth` (720) and `stepMarkerSize` (28) are all specified in
`DESIGN_SYSTEM.md` and absent from `DESIGN_TOKENS.json`. The first two are
written as literals at their call sites; the last two are centralised in
`EjadahSizes` but not generated. Adding them to the canonical JSON would resolve
several call-site literals at the source — but `DESIGN_TOKENS.json` is a handoff
artefact, so that is an owner edit, not a code one.
