# Deployment

## Checklist

**Before the first deploy**

- [ ] `JWT_SECRET` is at least 32 random characters — the server refuses to boot
      otherwise (`openssl rand -base64 48`)
- [ ] `EJADAH_ENV=production`
- [ ] `PAYMENT_PROVIDER` is a real provider — boot fails on `dev`
- [ ] a real mailer is wired — the console mailer writes verification codes to
      the log and is refused in production
- [ ] `DATABASE_URL` uses `sslmode=verify-full`
- [ ] `PUBLIC_BASE_URL` and `CHECKOUT_BASE_URL` are the real hosts; CORS derives
      its allowed origin from the first
- [ ] object storage configured; `STORAGE_ROOT` is development-only
- [ ] no demo accounts exist — `tool/seed.dart` refuses to run, but confirm

**Every deploy**

- [ ] `dart analyze` and `flutter analyze` clean
- [ ] every suite green (`./tool/dev.sh test`)
- [ ] migrations applied as a deliberate step, before the new binary serves
- [ ] `/health` returns 200 (it touches the database)

## Server

```bash
cd server
dart compile exe bin/server.dart -o build/ejadah-server
DATABASE_URL=... EJADAH_ENV=production ./build/ejadah-server --migrate
```

A single self-contained binary; scale by running more instances behind a load
balancer. Two caveats when you do:

* the **rate limiter is per-process** — move its window to shared storage first
* the **job runner is per-process** — run it on exactly one instance, or add a
  lock, or every instance will sweep in parallel

## Client

```bash
# Web
flutter build web --release \
  --dart-define=EJADAH_API_URL=https://api.ejadah.international/api/v1

# Android
flutter build appbundle --release \
  --dart-define=EJADAH_API_URL=https://api.ejadah.international/api/v1

# iOS
flutter build ipa --release \
  --dart-define=EJADAH_API_URL=https://api.ejadah.international/api/v1
```

`EJADAH_API_URL` is compile-time, so a release build cannot accidentally point
at a development server.

**Verified here:** Flutter Web release. **Not verified here:** Android and iOS
release builds — this environment has no Android SDK and no macOS toolchain.

## Deep links

`handoff/deep-links.md` is the source. Both need registering before the growth
and trust loops work:

* Android — `assetlinks.json` at `https://ejadah.com/.well-known/`
* iOS — `apple-app-site-association` at the same path

`/dr/{slug}` and `/verify/{code}` must resolve for signed-out visitors.

## Store notes

Courses are in-app purchase only (Apple §3.1.1). Sessions and the physical card
use external checkout. The app must not present a course price outside the store
sheet, and must not route a session payment through in-app purchase. This split
is legal, not a preference.

## Database

Automated backups with point-in-time recovery. Migrations are forward-only; a
rollback is a new migration. `schema_migrations` records what has been applied.
