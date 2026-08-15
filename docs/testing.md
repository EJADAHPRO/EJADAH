# Testing

```bash
./tool/dev.sh test          # everything
cd server && dart test      # backend
cd packages/ejadah_ui && flutter test
```

Backend suites need PostgreSQL and use `ejadah_test`, which `docker-compose`
creates alongside the development database. Tables are truncated between tests,
so each starts clean without re-migrating.

## Why these run against real PostgreSQL

The behaviour that matters most here — an exclusion constraint refusing a
concurrent write, a transaction rolling back, a `FOR UPDATE` serialising two
callers — is the database's behaviour. A mocked repository would prove only that
the mock behaves. So the suites connect to a real engine.

## What is covered

### Booking concurrency — `server/test/booking_concurrency_test.dart`

The mandatory proof, eight tests:

* two callers racing for one slot: exactly one wins, and the loser gets the
  approved conflict copy in both languages
* ten simultaneous attempts: still exactly one
* a confirmed booking blocks a later attempt
* an expired hold frees the slot, and the stale hold can no longer confirm
* adjacent slots do not collide (the range is half-open)
* the price is computed server-side, and the 70/30 fee with it
* another user cannot confirm someone else's hold
* cancelling refunds by the stated tier and returns the slot

### Roadmap determinism — `server/test/roadmap_determinism_test.dart`

Thirteen tests holding the engine to "same inputs, same output":

* identical answers produce an identical roadmap, field for field
* candidate order does not change the winner — reproducibility must not depend
  on query ordering
* projected dates come from the supplied date, not the wall clock
* tie-breaks resolve on cost, then country code, deterministically
* incomplete cost data never reads as affordability
* an unaffordable destination cannot exceed 60
* the formula cannot saturate the 100 clamp
* the watch-out names the gap in figures, without hedging
* a digital route never returns a licensing exam abroad
* "work abroad" does not answer with Egypt unless it was asked for
* a chosen region outranks one that was not chosen
* an unsourced stage cost stays pending rather than becoming zero
* stages are verbatim copies of the guide rows

### Identity and persistence — `server/test/auth_and_persistence_test.dart`

Ten tests:

* a password is never stored recoverably
* an unknown address fails exactly like a wrong password
* refresh tokens rotate, and a replay revokes the family
* refresh tokens are stored only as hashes
* **a saved programme survives**: written through one connection pool, read back
  through a second and then a third, opened after the first was closed. If the
  shortlist lived in process memory, this read would come back empty
* removal is idempotent, so a repeated undo cannot fail
* guest funnel answers and a guest roadmap migrate to the account on sign-up —
  losing them is a critical defect, so it is asserted
* one user cannot read another's shortlist

### Design system — `packages/ejadah_ui/test/design_system_test.dart`

Twenty tests on the rules most likely to erode:

* orange text uses `#C2450F`, not the brand fill that fails AA
* `#8E8A83` is not a role anywhere
* the small-text roles measure at least 4.5:1 on the app surface
* the gradient budget is six, with six permitted uses, mirroring 135°/225°
* Playfair is never used for Arabic; Arabic line-heights are raised; Arabic
  never carries tracking and is never uppercased; headings shrink 12% above 28
  characters
* directional icons mirror and symbols do not
* currency renders LTR inside an Arabic page, with Western digits
* an empty state always offers an action
* the pending chip prints the exact words and never a number
* a disabled button surfaces its reason on tap

### Goldens — `packages/ejadah_ui/test/golden_test.dart`

Six goldens, every component in both languages, with the bundled fonts loaded so
the images prove typography rather than a placeholder face:

`programme_card_{en,ar}` · `badges_{en,ar}` · `buttons_{en,ar}`

```bash
flutter test --update-goldens        # after an intended visual change
```

## Current totals

| Suite | Tests | Result |
|---|---|---|
| Booking concurrency | 8 | pass |
| Roadmap determinism | 13 | pass |
| Auth and persistence | 10 | pass |
| Design system | 20 | pass |
| Goldens | 6 | pass |
| App smoke | 2 | pass |
| **Total** | **59** | **pass** |

## Not yet written

Integration tests driving the Flutter app against a live server, and per-screen
widget tests for the screens beyond Career. See
`docs/implementation-status.md`.
