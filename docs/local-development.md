# Local development

Everything below assumes a clone and nothing else installed but Flutter and
either Docker or a local PostgreSQL.

## One command

```bash
cp .env.example .env
./tool/dev.sh setup
```

That resolves dependencies, starts PostgreSQL, applies the migrations, imports
the canonical datasets and seeds development data. It is idempotent — running it
again is safe.

Then, in two terminals:

```bash
./tool/dev.sh server   # the Dart backend on :8080
./tool/dev.sh app      # the Flutter app on :3000
```

## What each step does

| Command | Effect |
|---|---|
| `./tool/dev.sh setup` | the whole chain below, in order |
| `./tool/dev.sh import` | migrations + the 199 programmes and 23 country guides |
| `./tool/dev.sh seed` | demo accounts, a marketplace roster, saved work |
| `./tool/dev.sh server` | the backend |
| `./tool/dev.sh app` | the Flutter app (web target) |
| `./tool/dev.sh test` | every suite |
| `./tool/dev.sh reset` | drops and rebuilds the development database |

## Doing it by hand

```bash
docker compose up -d postgres          # or: service postgresql start
dart pub get
dart run tool/import_data.dart         # migrations + canonical datasets
dart run tool/seed.dart                # development fixtures
cd server && dart run bin/server.dart
cd apps/mobile && flutter run -d chrome
```

## Regenerating what is generated

Two files are generated and committed, so a build never depends on the
generator having been run:

```bash
dart run tool/generate_tokens.dart     # DESIGN_TOKENS.json -> Dart constants
dart run tool/generate_arb.dart        # strings.{en,ar}.json -> ARB
cd packages/ejadah_localization && flutter gen-l10n
```

`generate_arb.dart` fails if the two string tables are not key-identical, which
is what stops an English string appearing on an Arabic screen.

## Pointing the app at another server

```bash
flutter run --dart-define=EJADAH_API_URL=https://api.ejadah.international/api/v1
```

## Verifying the import

The import validates itself against the dataset's known shape and exits non-zero
if it disagrees:

```
Country guides: 23 countries, 108 steps, 28 exams, 92 cost rows, 7 pending fees
Programmes:     199 programmes (17 open, 32 closing soon, 150 expired),
                79 linked to a country guide
Import validated.
```

150 of 199 intakes have already passed. That is correct, and it is why the
database hides expired intakes by default.
