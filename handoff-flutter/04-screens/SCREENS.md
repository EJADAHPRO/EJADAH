# Screens — Inventory · States · Component Map · Navigation
### Combines: SCREEN_INVENTORY, SCREEN_STATE_MATRIX, SCREEN_COMPONENT_MAP, NAVIGATION_MAP, SCREEN_SPECIFICATIONS
Golden reference for every screen = the live prototype (see 08-reference). This file is the index; the prototype is the pixels.

---

## 1 · Inventory (Phase 1 · mobile · by tab)

ID → Screen · auth · states designed (D=default L=loading E=empty X=error O=offline P=partial) · primary CTA · deep link (per handoff/deep-links.md).

**FR-01..09 First run:** splash · language pick · welcome×3 · value teaser · sign up · verify email · login · forgot/reset · onboarding×4 + Premium status. Guest until sign-up. States: D,X per form; verify has cooldown state.
**HM-01 Home** all personas · D,L,E,X,O,P ✓ · CTA varies by persona. `/home`
**HM-02 Notifications** auth · D,E ✓ (add L) · mark-all. `/notifications`
**HM-03 Checklist** auth · D ✓ · dismiss-on-complete.
**HM-04 Recently viewed** auth · D,E ✓.
**LN-01 Learn hub** public · D ✓ (**add L skeleton**) · dept cards. `/learn`
**LN-02 Course list** public · D,E ✓ (**add L**) · format filter persists.
**LN-03 Course detail** public · D ✓ · Start/Buy per ownership; lesson-1 preview always. `/course/{slug}`
**LN-04 IAP sheet** auth · D,X ✓ · store wording, restore.
**LN-05 Player** owner · D ✓ (**document offline-downloaded playback**) · resume ≤10s.
**LN-06 Lesson complete** owner · D ✓ · 5s auto + cancel.
**LN-07 Handouts / LN-08 Flashcards / LN-09 Quiz / LN-10 Course complete / LN-11 Downloads** owner · D,E ✓ · quiz <60% offers one session.
**CR-01 Career hub** public · D ✓. `/career`
**CR-02..04 Roadmap funnel Q1–Q4** guest ✓ · D,X; draft resume ✓. `/roadmap`
**CR-05 Generating** · D,X ✓ · min-display pacing.
**CR-06 Result** guest-gated · D ✓ (gate = the signed-out state) · Pending-source chips ✓. `/roadmap/{id}`
**CR-07 What-if / CR-08 My roadmaps** auth · D,E ✓ · scenarios nested.
**CR-09 Programme DB** public · D,E ✓ (**add L skeleton**) · expired hidden; count. `/programmes`
**CR-10 Filter sheet** · D ✓ · zero-result relaxation ✓.
**CR-11 Programme detail / CR-12 Deep profile** public · D ✓ · save gated. `/programme/{id}`
**CR-13 Compare programmes** public · D,single ✓.
**CR-14 Shortlist** auth · D,E ✓ · remove+Undo ✓. `/shortlist`
**CR-15 Country list** public · D ✓ · chips + count. `/countries`
**CR-16 Country detail** public · D ✓ · 4 tabs; Pending-source ✓. `/country/{iso2}`
**CR-17 Compare countries** public · D,single ✓.
**CR-18 Career search** public · D,E ✓ · scoped note.
**PE-01 People hub** public · D ✓. `/people`
**PE-02 Lists ×3 kinds** public · D,E ✓ (**add L**) · filters persist; New-this-month rail. `/tutors …`
**PE-03 Professional profile** public · D ✓ · availability preview; cancel terms pre-book. `/tutor/{slug}`
**PE-04 Booking 1–8** auth · D,X ✓ · hold+countdown; race-409 state ✓.
**PE-05 Plan builder** auth · D ✓ · week stepper; partial-fill report ✓.
**PE-06 Redirect sheet / PE-07 Payment returned** auth · D,success,fail ✓.
**PE-08 My bookings** auth · D,E ✓ ×3 tabs · cancel shows tier first. `/bookings`
**PE-09 Review sheet** auth-attended · D ✓ once-only.
**PE-10 Become-a-tutor pitch** PUBLIC · D ✓.
**PE-11 Application ×6** auth · D,X ✓ draft-saved · blocked-submit names items ✓.
**PE-12 Status/Playbook** auth · under-review, approved ✓.
**PE-13 Tutor dashboard / PE-14 Availability editor / PE-15 Earnings / PE-16 Instructor** supply · D,E ✓ · block-booked-day 409 ✓.
**PR-01 Profile home** auth · D ✓ · Premium pill. `/profile`
**PR-02 Edit / PR-03 NFC card / PR-04 NFC editor / PR-05 Certificates / PR-07 CV / PR-08 CPD / PR-09 Subscription / PR-10 Invite / PR-11 Settings / PR-12 Logout / PR-13 Delete** auth · D (+E where lists) ✓.
**PR-06 Public profile** PUBLIC · D ✓ · install CTA; no analytics shown. `/dr/{slug}`
**PR-14 Verify certificate** PUBLIC · D, invalid-code ✓. `/verify/{code}`
**SY-01..10 System states** · all ✓ · each routes to action.

## 2 · State matrix — gaps to close (design in cleanup, same system)

| Gap | Screens | Treatment |
|---|---|---|
| Loading skeletons | LN-01/02, CR-09, PE-02 | Home's shimmer blocks, shaped per card type |
| Notification L | HM-02 | 3 row skeletons |
| Offline player note | LN-05 | banner + downloaded-badge; undownloaded lesson rows disabled w/ reason |
| Guest treatment doc | Learn+People | browse open; Start/Buy/Book → auth sheet w/ return-to intent |
| Partial data | Home only by design | others fail whole-section to X |
| First-use vs returning | Home ✓, others n/a | — |
Signed-out, permission-denied, expired-session, disabled, success: covered by system screens + per-flow states above.

## 3 · Screen → component map (representative; pattern holds everywhere)

**Home:** EjadahAppBar-less hero(DarkCard) · SectionHeader · ContinueCard(CourseCard variant) · RoadmapCard · BookingCard · DeadlineStrip(ListRow+DeadlineBadge) · ProfessionalCard rail · ExploreTiles · Skeleton/Empty/Error/OfflineBanner.
**Programme DB:** PageHeader · SearchField · EjadahFilterChip group + active-chip row · ProgrammeCard ×12 · Pagination · EmptyState(relaxation) · Skeleton.
**Country detail:** DarkCard hero(SourceLine, PendingSourceChip) · JumpPills · EjadahTabs · StepList(ol) · ExamCard · Doc checklist · CostTable(CurrencyText) · FAQ accordion · SourceLine list · foot disclaimer.
**Roadmap result:** hero(fit pill) · InlineAlert-warn(watch-out) · action panel · ProgressBar · Stage ol(chips, PendingSourceChip, course CtaCard-link) · Gate(DarkCard) · crosslink card · Alt cards · what-if chip grid · share buttons · SourceLine.
**Booking:** Stepper · DateStrip+SlotButton grid · HoldCountdown · chips · review rows · sticky bar.
**Plan builder:** cadence chip rows · quote panel · tier buttons · WeekStepper · AvailabilityGrid slots · sticky submit(reason).
**Tutor profile:** ProfessionalCard hero · stats · VerificationBadge quals · packages(cadence sentence) · availability preview · reviews · cancel terms · sticky book bar.
**Earnings:** StatCards · EarningRow table · payout button(min/short reason).
**NFC/Public:** NfcPreview · share row · install CTA (public).
Reuse these; a slightly-different per-screen variant is a defect.

## 4 · Navigation map & back behaviour

Root = 5-tab shell; each tab keeps its own stack + scroll (restore on return; reset only on re-tap of active tab root). Push = slide-from-trailing; **edge-swipe back everywhere, mirrored RTL; back is never the only way back**. Sheets over current context (filters, IAP, redirect, review, logout, notif-priming); full-screen modal only the player. Tab-switch always exits any overlay. Guest gate → sign-up returns to the exact roadmap. Deep links land with tab-root as back target. Scroll: restored on tab return + list→detail→back; reset on new search/filter submit. Public routes (dr/{slug}, verify/{code}, shared roadmap) render without shell chrome + install CTA.
