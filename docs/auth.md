# Authentication and authorization

## The model

Browsing is open. A guest can read the programme database, every country guide,
public profiles and certificate verification, and can complete the entire
roadmap funnel and generate a result — all without an account.

There are five gates: the roadmap **result**, saving and shortlisting, booking,
purchasing, and Profile. Nothing else.

The gate placement is the highest-leverage decision in the product: it falls
*between the funnel and the full result*, so four answers are already invested
by the time an account is asked for. A cold signup wall at the entrance converts
far worse.

## Guest work, and why it must not be lost

An anonymous device token is minted on first launch and kept until uninstall.
Guest funnel drafts and generated roadmaps are keyed by it.

On sign-up, `RoadmapRepository.adoptGuestWork` runs **inside the registration
transaction**. If adoption fails, the account is not created either. A user who
signs up at the gate and loses their four answers is a critical defect, not an
acceptable edge case, and a test asserts the migration.

Signing out clears the session but keeps the device token: signing out is not
becoming a different person.

## Tokens

**Access** — JWT, 15 minutes, carries subject and role. The common path needs no
database read.

**Refresh** — opaque, 60 days, single-use, stored only as a SHA-256 hash. Each
carries a family id. Using one rotates it; presenting a consumed one proves it
leaked, so the whole family is revoked.

The client refreshes once on a 401 and replays the request, so an expiry the app
can resolve itself never surfaces as a sign-in screen. Concurrent 401s share one
refresh rather than each starting their own.

## Passwords

Argon2id. At least 8 characters with a letter and a number — the same rules the
sign-up checklist shows, so the two cannot drift. A reset revokes every session.

## Roles

`student` · `professional` · `admin`, enforced server-side on every protected
route. Frontend visibility is never authorization. Ownership is a `WHERE`
clause, and a test asserts one user cannot read another's shortlist.

## Verification

A six-digit code, hashed at rest, valid 24 hours. Resend has a 60-second
cooldown returned as `cooldown_seconds` so the UI can show it as text rather
than as a disabled button with no explanation.
