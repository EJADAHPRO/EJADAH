# Backend

Dart on Shelf. One process, one database, module boundaries inside it.
`docs/architecture.md` covers the framework choice.

## Running

```bash
cd server && dart run bin/server.dart
```

In development the server migrates at boot, so a fresh clone is one command from
working. Staging and production run migrations as a deliberate deploy step
(`dart run bin/server.dart --migrate`, or the migrator alone).

## Request pipeline

```
context → security headers → CORS → error → logging → router
```

* **context** — mints a correlation id, resolves the language, and verifies the
  bearer token if present. Authentication is middleware because guests are
  legitimate callers on most routes; the route decides whether to demand a user.
* **error** — turns every thrown failure into the approved envelope. Two
  PostgreSQL states are translated into product states: `23P01`
  (exclusion violation) becomes the "someone booked that time a moment ago"
  conflict, and `23505` becomes a generic conflict.
* **logging** — one structured line per request with method, path, status,
  duration and user, redacted.

## Layers

```
Route handler  →  Application service  →  Domain  →  Repository  →  PostgreSQL
```

Handlers parse input and shape output. Services own decisions. Repositories own
SQL. The roadmap engine is pure — no I/O — which is what makes reproducibility
testable.

## Modules

| Module | Responsibility |
|---|---|
| `auth` | registration, sessions, verification, reset, deletion |
| `career` | programmes, country guides, shortlist, facets, relaxation |
| `roadmap` | drafts, the deterministic engine, the gate, what-if |
| `people` | professionals, availability, holds, bookings, cancellation |
| `import` | the reproducible dataset importers |
| `jobs` | the in-process scheduler |
| `services` | password hashing, tokens, mail, payments |

## Background jobs

An in-process scheduler, not a broker — hold expiry and a few reminder sweeps do
not justify that infrastructure. What matters is that none of it depends on the
Flutter app being open.

Each job runs once at boot (so a restart does not leave expired holds occupying
slots) and then on its interval, and records every run in `job_runs`.

| Job | Interval | Effect |
|---|---|---|
| `expire_holds` | 1 min | releases holds past their expiry |

Deadline reminders (30/14/7 days) and session reminders (T-24h, T-1h) have their
queries and their `scheduled_notifications` table, but are not yet scheduled.

## Configuration

Read once at boot from the environment; `.env.example` documents every key.
Several development affordances are **refused** in production rather than
discouraged — the payment simulator and the console mailer both fail the boot.
