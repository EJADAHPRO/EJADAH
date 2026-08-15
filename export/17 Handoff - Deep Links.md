# Deep links & universal links — Phase 1

Scheme: `ejadah://` · Universal links: `https://ejadah.com/app/...`
Every link resolves in both languages; `?lang=ar` forces language, otherwise the device/stored preference wins.

| Path | Screen | Params | Fallback if missing |
|---|---|---|---|
| `/programme/:id` | Programme detail | — | 404 screen → programme search |
| `/programme/:id/compare` | Comparison, prefilled | `with` (up to 2 more ids) | detail only |
| `/country/:iso` | Country guide | `tab` = path|docs|costs|recognition | country list |
| `/country/compare` | Country compare | `iso` (2-3, comma-sep) | country list |
| `/roadmap/:id` | Saved roadmap result | — | My roadmaps |
| `/roadmap/new` | Roadmap funnel step 1 | `path` seeds the first answer | — |
| `/course/:id` | Course detail | `lesson` opens the player | catalogue |
| `/tutor/:id` | Tutor / mentor / consultant profile | `kind` | marketplace list |
| `/booking/:id` | Booking detail in My bookings | — | My bookings |
| `/pay/return` | **Payment returned** | `booking`, `status` = completed|cancelled | My bookings |
| `/card/:handle` | Public NFC profile *(no auth)* | — | 404 |
| `/verify/:code` | Certificate verification *(no auth)* | — | "certificate not found" |
| `/invite/:code` | Sign-up with referral attributed | — | plain sign-up |
| `/settings/notifications` | Settings, notifications section | — | Settings |

## Rules
- `/card/*` and `/verify/*` must render for a signed-out visitor — they are the growth and trust loops.
- `/pay/return` is the only link the web checkout may call. Validate `booking` server-side before showing success.
- A link to deleted content resolves to the 404 screen with a working search action, never a blank screen.
- Cold-start deep links wait for fonts + language + auth to resolve, then navigate once — never navigate twice.
