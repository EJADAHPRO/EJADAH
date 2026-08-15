# Brand Guide — canonical, technology-independent
### Combines: BRAND_GUIDE, BRAND_VOICE, LOGO_GUIDE, COLOR_GUIDE, TYPOGRAPHY_GUIDE, IMAGERY_GUIDE, ICONOGRAPHY_GUIDE

---

## 1 · Positioning & personality

Premium, editorial, honest. A career authority for dental professionals — not education SaaS. Specific over motivational; warm over corporate; Egyptian/Gulf context native, never pasted on. **Do not redesign this identity.**

## 2 · Voice — Honest · Specific · Ambitious · Warm

| Surface | Do | Don't |
|---|---|---|
| Headlines | "Where can you practise?" / "199 programmes, honestly described" | "Unlock your potential!" |
| CTAs | verb + object: "Build my roadmap", "Open the UAE guide" | "Get started", "Learn more" |
| Errors | what happened + what survived: "We couldn't build your roadmap just now. Nothing you entered is lost." | codes, "Oops!" |
| Empty | route to action: "No saved programmes yet — 17 are open right now." | "No results" |
| Career warnings | name the cost: "The typical cost runs about USD 3,000 above your stated budget." | soft hedging |
| Pending source | exactly "Pending source" / "بانتظار المصدر" | "N/A", "~$450", "approximately" |
| Pricing | plain figures + what's included; "Bought once — yours for good" | urgency countdowns |
| Booking | consequence first: "You'll be refunded EGP 250 of EGP 500." | cancel-then-surprise |
| Success | brief, factual: "Marked — thank you" | confetti copy |
| Arabic | authored natively, MSA, clinical terms correct | word-for-word translation |
| Never | — | exclamation marks in UI, emoji as icons, "amazing/journey/unlock" |

## 3 · Logo

Canonical assets on file: `assets/ejadah-mark.jpg` (mark) and `ejadah-icon-ms4q23e9-krxx.jpg` (icon tile). **OWNER MUST SUPPLY: vector master (SVG/PDF), transparent PNG set, dark-background variant, monochrome, app icon at required sizes.** Until then: gradient tile (brand gradient, radius 16, white glyph) is the app-icon pattern — no wordmark on the icon. Clear space ≥ ½ tile height. Min digital size 24px. Never: recolour, stretch, add effects, place on the gradient itself, or pair with tracking on the Arabic wordmark.

## 4 · Colour

| Token | Hex | Role | Rules |
|---|---|---|---|
| red | #FF2D32 | gradient start · danger | fills/icons; not body text |
| orange | #FF6B1A | gradient mid · brand accent | **fills & icons ONLY — 2.35:1 on cream, fails AA as text** |
| **orangeText** | **#C2450F** | any orange text <14px+ | the text-safe version; always use for orange copy |
| amber | #FFAA18 | warnings, stars | pair with dark text |
| gold | #FFC62E | gradient end · highlight pills | dark text on it |
| offWhite | #FFF9EF | app background | |
| white | #FFFFFF | cards | |
| paleGray | #F5F2EC | inset surfaces, chips | |
| borderGray | #E7E2DA | borders 1.5px | |
| warmGray | #716D67 | secondary text ≥12px on white/offWhite | 4.62:1 offWhite |
| **labelMuted** | **#6B6862** | micro labels <12px | 4.58:1; **#8E8A83 is banned** (2.84–3.28:1, false pass in old docs) |
| charcoal | #1B1B1B | primary text · dark bands | |
| deep / espresso | #121212 / #24201D | deepest bands / offline bar | |
| success / info / danger | #2D9B68 / #496FA8 / #FF2D32 | semantic | success text on white ok |

**Gradient:** red→orange(50%)→gold; **135° EN, 225° AR** (light from the leading edge). **Discipline: ≤6 gradient elements visible; only on** primary buttons · logo tile · numbered step markers · one emphasised phrase per heading · closing CTA band · active tab indicator. No raw hex outside tokens.

## 5 · Typography

**EN:** Playfair Display 700/800 (display) · Inter 400–800 (UI/body). **AR:** Amiri 700 (display) · IBM Plex Sans Arabic 400–700. Playfair has no Arabic glyphs — never render it in AR.

Scale (12 sizes, nothing else): micro 11 · caption 12 · small 13 · body 14 · bodyLg 16 · h6 18 · h5 20 · h4 22 · h3 24 · h2 28 · h1 32 · display 36.
Line-height EN/AR: tight 1.25/**1.45** · snug 1.45/**1.65** · body 1.70/**1.85**. Letter-spacing: EN eyebrows .08em; **AR always 0**. No uppercase in AR. **AR headings −12% above 28 characters** (the long-heading rule). Buttons: Inter/Plex 700, 13–14. Numerals Western both languages; tabular where columns align (earnings, compare). Truncation: 1-line ellipsis on card titles in lists; never truncate figures.

## 6 · Imagery

Real people, warm natural light, Egyptian/Gulf professionals in real clinics — editorial, not stock-smiling-at-laptop. Portraits: chest-up, honest colour, no beauty filters, radius per component. Backgrounds: neutral/clinical, never gradient-tinted. Forbidden: generic SaaS illustration, AI-artifact hands/teeth, watermarked stock, emoji. **Current status: ALL people photos are placeholders (MUST REPLACE — todo 30); flags load from flagcdn (bundle locally); no final course/hero photography exists.** Placeholder behaviour in-app: initials avatar on brand paleGray, never a broken image.

## 7 · Iconography

Reference set: **Lucide-style outline, 2px stroke** (Flutter: `lucide_icons` or matched custom). Sizes 16 (inline) · 21 (nav/list) · 24 (feature). Outline default; filled only for active nav + saved-heart + rating stars. Active = charcoal/white per surface + gradient indicator bar; inactive = labelMuted. Badges top-end, 8px dot, danger red, 1.5px surface ring. **Directional icons mirror in RTL** (chevrons, arrows, back/send); **never mirror**: search, star, heart, camera, clock, play (media), logos, numbers. No emoji anywhere in UI.

Canonical map: Home=house · Learn=graduation-cap · Career=compass · People=users · Profile=user · search · sliders(filter) · heart/heart-filled(save) · scale(compare) · bell · calendar · clock(booking) · play · download · award(certificate) · share-2 · chevron-start(back, mirrored) · x(close) · pencil(edit) · badge-check(verified) · external-link · lock(gated) · wifi-off(offline) · alert-triangle(warning).
