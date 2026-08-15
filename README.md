# Ejadah International Academy

A bilingual, Arabic-default platform for Egyptian dental professionals planning
careers abroad: 199 verified postgraduate programmes, 23 country licensing
guides, a deterministic career-roadmap generator, one-to-one
tutoring/mentoring/consulting, recorded courses, and an NFC professional
identity card.

**Flutter + Dart + PostgreSQL.** One language on both sides.

## Run it

```bash
cp .env.example .env
./tool/dev.sh setup      # deps, database, migrations, real datasets, seeds
./tool/dev.sh server     # the Dart backend on :8080
./tool/dev.sh app        # the Flutter app on :3000
```

Demo credentials are in [`docs/demo.md`](docs/demo.md). They are
development-only, and the server refuses to boot in production with the
development affordances they rely on.

## Where things are

```
apps/mobile/            the Flutter application
packages/ejadah_ui/     design tokens and the Ejadah component family
packages/ejadah_core/   failures, HTTP client, storage, analytics
packages/ejadah_models/ typed models shared by app and server
packages/ejadah_localization/  EN/AR strings, generated from the handoff
server/                 the Dart backend and its SQL migrations
tool/                   importers, seeders, generators, dev.sh
handoff-flutter/        the canonical specification — read this first
data/                   the canonical datasets
reference/              the live prototypes, used as visual acceptance targets
```

## The specification

[`handoff-flutter/START_HERE.md`](handoff-flutter/START_HERE.md) is the entry
point and it is canonical. Where anything else in this repository disagrees with
it, it wins. `uploads/` and `reference/` are input material and history, never
specification.

Five rules from that document shape most of the code:

1. **Our data only.** No AI inference, no external content APIs. The roadmap is
   a deterministic filter → score → assemble over Ejadah's own rows. An
   unverified fact prints "Pending source" — never an estimate.
2. **Arabic is first-class and default.** Not English with a different font.
3. **Payments are legally split.** Courses are in-app purchase; sessions and the
   card are external. Never harmonise them.
4. **Nothing without acknowledgement.** Feedback under 100ms, optimistic UI with
   real rollback, skeletons rather than spinners, every empty state routes to
   action, disabled controls explain themselves.
5. **Preserve the identity.** Build Ejadah components in Flutter — not Material
   defaults arranged to look like Ejadah.

## Documentation

| | |
|---|---|
| [architecture](docs/architecture.md) | stack, layout, and the decisions worth knowing |
| [backend](docs/backend.md) | the Dart server, its pipeline and its jobs |
| [database](docs/database.md) | schema, and the constraints that carry product rules |
| [auth](docs/auth.md) | the guest model, the five gates, tokens |
| [api](docs/api.md) | endpoints and the error envelope |
| [local development](docs/local-development.md) | getting it running |
| [demo](docs/demo.md) | development accounts and what they contain |
| [testing](docs/testing.md) | what is covered, and why against a real database |
| [security](docs/security.md) | protections, and what is not yet closed |
| [deployment](docs/deployment.md) | the production checklist |
| **[implementation status](docs/implementation-status.md)** | **honest state of every feature** |

## State of the build

The foundation and the **Career vertical are complete end to end** — Flutter UI
through to PostgreSQL, in both languages, with persistence proven across
restarts. The **roadmap engine** and the **booking engine** are complete and
tested, including the two guarantees the brief calls mandatory: determinism and
concurrency-safety.

Learn, People's discovery surface and most of Profile have server foundations
but no screens yet. [`docs/implementation-status.md`](docs/implementation-status.md)
says exactly which is which, feature by feature.

## Quality

```bash
dart format . && dart analyze && flutter analyze
./tool/dev.sh test
```

59 tests, all passing. Analysis is clean across every package.
