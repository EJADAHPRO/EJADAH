# Pre-store-submission checklist

Things that cannot be finished from this repository alone, because they need
credentials, accounts or physical assets we do not have. None of them block
development; all of them block a store build.

Kept separate from `implementation-status.md` on purpose: that document says
what is built, this one says what must be true before the app is submitted.

## Blocking — the app is rejected or broken without these

### 1. In-app purchase receipt verification
The IAP path exists and **fails closed**: an unverified receipt does not grant
entitlement. That is the safe direction and it is deliberate, but it means no
purchase can currently succeed against a real store.

Needs App Store Connect and Google Play credentials, then server-side receipt
validation against Apple's `verifyReceipt` / the Play Developer API before
`POST /learn/courses/{id}/entitlement` grants anything. Owner decision, 15 Aug
2026: this belongs here rather than in the build order.

**Test before submitting:** a sandbox purchase grants the course; a replayed or
forged receipt does not.

### 2. Payment provider
`PAYMENT_PROVIDER=dev` is the simulator. `AppConfig` refuses to boot with it in
production — that guard is in configuration, not in a comment — so a real
provider must be configured or the process will not start.

### 3. `JWT_SECRET`
Production refuses known placeholders and low-variety values. Generate with
`openssl rand -base64 48`.

### 4. `TRUSTED_PROXY_COUNT`
Set to the number of proxies in front of the process. Left at zero,
`X-Forwarded-For` is ignored entirely and the rate limiter keys off the socket
address — which is safe, but wrong behind a load balancer, where every request
would appear to come from one address.

### 5. Vector logo and store assets
Conflict #9 in `REGISTER.md`. Two JPGs exist; no vector, no dark variant, no
app-icon master. The app icon uses the documented gradient-tile pattern until
one is supplied.

### 6. Real rosters and photographs
Every tutor image in the handoff is a placeholder and unlicensed for
production. The app shows initials on the inset surface — never a broken image,
never an unlicensed portrait — so this does not break, but shipping placeholder
people would.

## Known gaps that are recorded, not blocking

### Flutter Web is a preview surface
The web build keeps its refresh token in `localStorage`, readable by any script
in the origin; native builds use secure storage. Owner decision, 15 Aug 2026:
ship native-first and treat web as preview. Debug web builds carry a banner
saying so. If web becomes a real distribution channel, the fix is an HttpOnly
refresh cookie set by the existing refresh endpoint — not a patch to the client.

### Cairo time is a fixed +02:00
Egypt reinstated summer time in 2023, so displayed times run an hour behind
during it. Owner decision, 15 Aug 2026: keep the fixed offset and make the copy
honest — every string names "Cairo time" and none names an offset. Closing the
gap later is a data change (IANA `Africa/Cairo`) applied to
`CairoClock.offset`, which is the only place in the server that converts to
local time.

### 14 pending regulator facts
7 exam fees and 7 cost rows print "Pending source". This is a first-class data
state, not a gap to fill before shipping — the product's credibility rests on
it. Owner-supplied sources replace them whenever they arrive.

### Arabic clinical-terminology review
Strings ship exactly as authored in `strings.ar.json`. No machine translation
was introduced. The practising-dentist review is owed and does not block.
