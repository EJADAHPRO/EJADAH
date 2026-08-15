# Security

## Passwords

Argon2id, memory-hard, with parameters carried in the encoded hash so cost can
be raised later without invalidating existing hashes. Plaintext, MD5, SHA-1 and
unsalted SHA-256 are all disqualifying. A test asserts that a stored hash is
`$argon2id$…` and does not contain the password.

## Sessions

Access tokens are 15-minute JWTs, so the common path needs no database read.
Refresh tokens are opaque, single-use, and stored **only as a SHA-256 hash** — a
database leak yields no usable sessions.

Rotation carries a family id. Presenting a consumed token proves it leaked, so
the whole family is revoked rather than just the replayed token. Both behaviours
are covered by tests.

A password reset revokes every refresh token for that account.

## Authorization

Enforced on the server, on every protected route, via
`RequestContext.requireUser` / `requireRole` / `requireAdmin`. Frontend
visibility is never authorization. Ownership is a column and a `WHERE` clause,
not a client-side filter — covered by a test that one user cannot read another's
shortlist.

## Account enumeration

A wrong password and an unknown address produce an identical failure, and the
unknown-address path performs comparable hashing work so response timing does
not become the oracle the message avoids being. `/auth/forgot-password` always
returns 204.

Registration is the one place enumeration is unavoidable — the form must say the
address is taken — so that route is rate-limited instead.

## Rate limiting

Fixed-window, per identity or address, on the routes worth attacking: sign-in
(8 / 5 min), registration (5 / 15 min), password reset and verification
(4 / 15 min). A limited caller gets the approved copy and a `Retry-After`.

*Deployment note:* the limiter is in-process, which is right for a single
instance. Running more than one requires moving the window to shared storage.

## The gate

A guest's roadmap is truncated **by the server**. The withheld stages are never
sent, so the gate cannot be defeated with an inspector.

## Prices and money

Prices are computed on the server from the professional's own rate or a package
the server looked up. A price in a request body is never read. The 70/30 split
is applied server-side. A test asserts the computed total and fee.

Provider callbacks are idempotent through a unique `(provider, event_id)`
ledger, so a duplicate cannot create a second payment, booking, entitlement,
earning or refund.

The development payment simulator can mark a booking paid without money moving,
so `AppConfig.fromEnvironment` **refuses to boot** when it is selected with
`EJADAH_ENV=production`. Same for the console mailer, which writes verification
codes to the log.

## Booking races

Guaranteed by a database exclusion constraint over one reservation timeline, not
by application checks. `test/booking_concurrency_test.dart` runs two and then
ten simultaneous attempts against real PostgreSQL and asserts exactly one wins.

## Injection

Every query is parameterised through `Sql.named`. No user input is concatenated
into SQL anywhere. The only dynamic SQL is a fixed set of `ORDER BY` clauses
chosen by an enum — never by a caller-supplied string.

## Logging

Structured JSON with a correlation id per request. A redaction list drops
passwords, tokens, authorization headers, verification codes, payment fields and
the free-text booking goal before a line is written. Internal messages, SQL
fragments and stack traces never reach a user: an unclassified failure returns
the approved server copy.

## Analytics privacy

`AnalyticsDispatcher` drops a forbidden-key list — booking goals, notes,
documents, credentials, e-mail, phone, card fields — before forwarding, and
asserts in debug when a call site tries to send one. The booking goal is the
field most likely to contain patient detail, and it is excluded by name.

## Transport and headers

`nosniff`, `DENY` framing, `no-referrer`, HSTS. CORS names an explicit origin in
production rather than `*`, because requests carry bearer tokens.

## Uploads

Server-side validation of MIME, extension, size and ownership, with a generated
storage key. Files never live inside application source directories. Client-side
validation is treated as a convenience, never as a control.

## Reviewed and not yet closed

* **File upload endpoints are not yet built.** The storage abstraction and the
  `stored_files` table exist; the routes do not. See
  `docs/implementation-status.md`.
* **Admin authorization has no surface yet.** `requireAdmin` exists and the
  audit table exists; the admin panel is not built.
* **The rate limiter is per-process**, as noted above.
