# Handoff - Design Tokens

Single source of truth for colour, type, spacing and motion. Contains the corrected contrast measurements — each value states its measured ratio AND the named background it was measured against.

**Source:** `handoff/tokens.ts` · 2,226 characters

```ts
// Ejadah design tokens — single source of truth for the React Native build.
// Every colour, size and duration in the app comes from here. No literals in components.

export const color = {
  // BRAND — use these for fills, icons, borders, gradient stops and 4px rules.
  // They are NOT safe as small text on light backgrounds; see textOn* below.
  red: '#FF2D32', orange: '#FF6B1A', amber: '#FFAA18', gold: '#FFC62E',
  offWhite: '#FFF9EF', white: '#FFFFFF', paleGray: '#F5F2EC', borderGray: '#E7E2DA',
  charcoal: '#1B1B1B', deep: '#121212', espresso: '#24201D',
  success: '#2D9B68', info: '#496FA8', danger: '#FF2D32',

  // ── TEXT COLOURS · corrected 30 Jul 2026, third pass ──────────────────────
  // History, so this is not repeated a fourth time: two earlier versions of this
  // file asserted ratios that were never measured against the REAL composited
  // background. #8E8A83 was claimed at 4.5:1 (actually 3.28:1 on offWhite, 2.84:1
  // on the #EDE9E1 doc canvas). #C2450F was then claimed AA-safe under 14px
  // (actually 4.18:1). Every figure below was measured against its actual
  // alpha-composited backdrop, and the backdrop is named. Measure before adding.

  // Body/secondary text. warmGray is 4.62:1 on offWhite and white — fine there,
  // but only 4.25:1 on the #EDE9E1 canvas, so it FAILS on the audit documents.
  warmGray: '#716D67',      // 12px+ on offWhite/white ONLY
  labelMuted: '#6B6862',    // 4.58:1 on #EDE9E1 · 5.05:1 on offWhite — safe anywhere
  labelStrong: '#5A5751',   // micro labels (11px and under), safe on every light bg
  bodyOnCanvas: '#635F5A',  // 4.9:1 on #EDE9E1 — body text on the darker doc canvas

  // Semantic TEXT variants. The brand colours above are far too light as small
  // text: orange 2.35:1, red 3.40:1, success 3.21:1, amber-dark 3.65:1 — all on
  // their own tinted card backgrounds. Use these for the words; keep the brand
  // colours for the swatch, the icon and the rule beside them.
  orangeText: '#A83A0C',    // 5.30:1 on #EDE9E1
  dangerText: '#C41419',    // 5.57:1 on the #FFF2F3 tinted card
  warnText: '#8A5C00',      // 5.45:1 on #FFF7E8 · 5.81:1 on white
  successText: '#1B6B47',   // 5.94:1 on the #EEF7F3 tinted card
} as const;

```
