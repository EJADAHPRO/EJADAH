# Demo accounts

**Development and test only.** `tool/seed.dart` refuses to run against a
production configuration, and the server refuses to boot with the payment
simulator or the console mailer selected in production. These passwords are
published, so they must never exist on a real deployment.

| Account | Password | Role |
|---|---|---|
| `student@ejadah.test` | `EjadahDemo1` | student, with four saved programmes |
| `tutor@ejadah.test` | `EjadahDemo1` | approved professional, with availability |
| `admin@ejadah.test` | `EjadahDemo1` | admin |

## What the seed gives you

* **Career** — the real 199 programmes and 23 country guides, imported from the
  canonical datasets rather than authored. 17 open intakes, 32 closing within 60
  days, 150 expired.
* **A returning student** — four saved programmes, so Home, the shortlist and
  the deadline strip all have real content.
* **A marketplace roster** — one approved mentor with verified and stated
  qualifications side by side, a multi-session package, and weekday availability.

## What is deliberately absent

**Photographs.** Every tutor image in the handoff is a placeholder and is
unlicensed for production, so none is seeded. The app falls back to initials on
the inset surface — never a broken image, and never an unlicensed portrait. This
is owner decision #30 in the conflict register.

## Verification codes and reset links

The development mailer writes them to the server log rather than sending mail:

```json
{"scope":"ejadah.mail","msg":"verification email (development)","code_for_local_testing":"418302"}
```

## Payments

`PAYMENT_PROVIDER=dev` selects the simulator, which can drive success, failure,
cancellation and refund without provider credentials. It can mark a booking paid
without money moving — which is exactly why boot fails if it is selected while
`EJADAH_ENV=production`.
