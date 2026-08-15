# Ejadah Design-Agent Guidelines
### Permanent guardrails for ANY future design or code generation on this project.

1. **Tokens only.** Every color, size, radius, spacing, shadow, duration from `handoff-flutter/03-design-system/DESIGN_TOKENS.json`. A raw hex or a 18px radius is a defect. New token? Document it there first.
2. **Fonts are fixed.** Playfair Display + Inter (EN); Amiri + IBM Plex Sans Arabic (AR). Playfair never renders Arabic.
3. **Gradient discipline.** ≤6 gradient elements per screen, only on the six permitted uses. 135° EN / 225° AR.
4. **Reuse before invent.** Use the canonical `Ejadah*` components (DESIGN_SYSTEM.md §1). A new component needs a reason no existing one covers — then it gets named, spec'd and added to the catalog.
5. **No generic SaaS.** No default-Material look, no dashboard-template layouts, no stock illustration, no emoji as icons, no exclamation-mark copy.
6. **Arabic is first-class.** Default AR; 0 tracking; no uppercase; raised line-heights; −12% long headings; logical start/end layout only; Western numerals; Latin codes bidi-isolated; mirrored directional icons per the never-mirror list.
7. **Data honesty.** Never invent a fee, deadline, name or fact. Unverified = "Pending source"/«بانتظار المصدر» exactly. Our database is the only source — no AI inference, no external content APIs.
8. **Interaction floor.** ≤100ms feedback; skeletons not spinners; optimistic+Undo on reversible; consequence stated before destructive; disabled explains on tap; every empty state routes to action; 44×44; AA contrast (orange text = #C2450F, muted = #6B6862, #8E8A83 banned).
9. **Mobile-first, five tabs.** Home·Learn·Career·People·Profile. No sixth tab, no exams/community/AI features from the cut list — Future stays out of Phase 1.
10. **Brand rhythm.** Dark hero → light → deep → light → gradient CTA; never two dark bands adjacent; one primary button per screen.
