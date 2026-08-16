#!/usr/bin/env bash
#
# Ejadah local development.
#
#   ./tool/dev.sh setup     install deps, start PostgreSQL, migrate, import, seed
#   ./tool/dev.sh server    run the Dart backend
#   ./tool/dev.sh app       run the Flutter app (web)
#   ./tool/dev.sh test      run every suite
#   ./tool/dev.sh analyze   analyze every package
#   ./tool/dev.sh reset     drop and rebuild the development database
#
# Everything here is idempotent: running setup twice is safe.

set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"

# shellcheck disable=SC1091
[ -f .env ] && set -a && . ./.env && set +a

: "${DATABASE_URL:=postgres://ejadah:ejadah_dev@localhost:5432/ejadah_dev?sslmode=disable}"
: "${TEST_DATABASE_URL:=postgres://ejadah:ejadah_dev@localhost:5432/ejadah_test?sslmode=disable}"
: "${EJADAH_ENV:=development}"
: "${PORT:=8080}"
export DATABASE_URL TEST_DATABASE_URL EJADAH_ENV PORT

say() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }

ensure_postgres() {
  if command -v pg_isready >/dev/null && pg_isready -q 2>/dev/null; then
    return
  fi
  if command -v docker >/dev/null && [ -f docker-compose.yml ]; then
    say "Starting PostgreSQL via Docker"
    docker compose up -d postgres
    until docker compose exec -T postgres pg_isready -q 2>/dev/null; do sleep 1; done
  elif command -v service >/dev/null; then
    say "Starting the system PostgreSQL"
    service postgresql start
  else
    echo "PostgreSQL is not running and could not be started." >&2
    exit 1
  fi
}

deps() {
  say "Resolving Dart and Flutter dependencies"
  dart pub get
  (cd "$ROOT/packages/ejadah_models" && dart pub get)
  (cd "$ROOT/server" && dart pub get)
  for package in ejadah_core ejadah_ui ejadah_localization; do
    [ -d "$ROOT/packages/$package" ] && (cd "$ROOT/packages/$package" && flutter pub get)
  done
  [ -d "$ROOT/apps/mobile" ] && (cd "$ROOT/apps/mobile" && flutter pub get)
}

case "${1:-setup}" in
  setup)
    ensure_postgres
    deps
    say "Migrating and importing the canonical datasets"
    dart run tool/import_data.dart
    say "Seeding development data"
    dart run tool/seed.dart
    say "Ready — run './tool/dev.sh server' and './tool/dev.sh app'"
    ;;

  server)
    ensure_postgres
    say "Starting the Dart backend on :$PORT"
    cd server && exec dart run bin/server.dart
    ;;

  app)
    say "Starting the Flutter app"
    cd apps/mobile && exec flutter run -d web-server --web-port 3000
    ;;

  import)
    ensure_postgres
    dart run tool/import_data.dart
    ;;

  seed)
    ensure_postgres
    dart run tool/seed.dart
    ;;

  test)
    ensure_postgres
    say "Backend tests"
    (cd server && dart test)
    # Every Flutter package that actually has tests. Discovered rather than
    # listed: the old list named ejadah_models, which has no test/ directory,
    # and `dart test` exits 65 on that — under `set -e` the whole run stopped
    # there and the suites after it never ran. It also never named
    # ejadah_localization, so the guard tests that keep the two string tables
    # honest were outside the command that claims to run everything.
    for package in packages/*/ apps/mobile; do
      [ -d "$ROOT/$package/test" ] || continue
      say "Tests: $package"
      (cd "$ROOT/$package" && flutter test)
    done
    ;;

  analyze)
    # `flutter analyze` on the two pure-Dart packages rewrites their
    # analysis_options.yaml to add platform excludes, which dirties a clean
    # checkout. They get `dart analyze`, which is also what they are.
    for package in . server packages/ejadah_models; do
      say "Analyzing $package"
      (cd "$ROOT/$package" && dart analyze)
    done
    for package in packages/ejadah_core packages/ejadah_localization \
                   packages/ejadah_ui apps/mobile; do
      say "Analyzing $package"
      (cd "$ROOT/$package" && flutter analyze)
    done
    ;;

  reset)
    ensure_postgres
    say "Rebuilding the development database"
    dart run tool/reset_db.dart
    dart run tool/import_data.dart
    dart run tool/seed.dart
    ;;

  *)
    sed -n '2,14p' "$0"
    exit 1
    ;;
esac
