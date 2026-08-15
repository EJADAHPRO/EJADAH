# Database

PostgreSQL 16. Migrations are ordered SQL files in `server/migrations/`, applied
once each inside their own transaction and recorded in `schema_migrations`.
Running the migrator twice is a no-op; a failed migration leaves nothing behind.

```bash
dart run tool/import_data.dart      # migrate, then import the datasets
```

## Conventions

* every timestamp is `timestamptz`, written in UTC
* every table carries `created_at`; mutable tables carry `updated_at`
* bilingual content is two columns (`_en` / `_ar`), not JSON, so a missing
  translation is a constraint violation rather than a silent empty string
* every column the filter sheet can filter on is indexed

## The constraints that carry product rules

Several product rules are enforced by the schema rather than by application
code, because application code can be bypassed by the next caller.

**No double booking.** `slot_reservations` holds a professional's whole
timeline — temporary holds and confirmed sessions alike — so one exclusion
constraint can span both:

```sql
CONSTRAINT slot_reservations_no_overlap
  EXCLUDE USING gist (professional_id WITH =, period WITH &&)
  WHERE (status = 'active')
```

A hold becomes its session's reservation *in place*, so the slot is never
momentarily free between releasing and inserting. Expired holds are released by
a background job and again lazily inside every booking attempt, so correctness
never depends on the job having run recently.

**Verification cannot be faked.**

```sql
CONSTRAINT certificates_only_verified_have_codes
  CHECK (verification_code IS NULL OR evidence = 'verified')
CONSTRAINT certificates_verified_are_ejadah_issued
  CHECK (evidence <> 'verified' OR course_id IS NOT NULL)
```

A user-uploaded certificate cannot be minted a public verification code.

**A fee cannot claim a source it does not have.**

```sql
CONSTRAINT country_exams_verified_fee_has_value
  CHECK (fee_status <> 'verified' OR fee_value IS NOT NULL)
```

**Duplicate payment callbacks are inert.** `payment_events` is unique on
`(provider, event_id)`, so a replayed callback finds its row already present and
cannot create a second payment, booking, entitlement or refund.

**Entitlements cannot be granted twice.** `entitlements` is unique on
`(user_id, course_id)` and on `external_ref`, so a replayed store receipt grants
nothing new.

## Schema map

| Migration | Contents |
|---|---|
| `001_core_identity` | users, refresh tokens, verification, resets, notification preferences, audit log, auth attempts |
| `002_career` | countries and their steps/exams/costs/documents/tips, programmes, shortlist, saved filters, recently viewed |
| `003_roadmap` | guest-capable drafts, results, stages, what-if scenarios |
| `004_learn` | courses, lessons, entitlements, progress, flashcards, quizzes |
| `005_people` | professionals, availability, the reservation timeline, bookings, sessions, reviews, applications, earnings |
| `006_profile_platform` | profiles, certificates, CPD, CV, files, payments, notifications, analytics, jobs |
| `007_cost_completeness` | records whether a country's cost floor is complete |

## On `floor_cost_usd`

A guide's cost floor is the sum of the lower bound of its USD cost rows, and
unsourced rows contribute nothing. That makes a guide with missing fees look
cheaper than one that documented everything, so `floor_cost_complete` records
whether the floor is whole. The roadmap engine withholds its budget-headroom
bonus from incomplete data and demotes it in the tie-break — missing data must
never read as affordability.

## Deletion

Account deletion is a soft delete with a stated 30-day undo window. The unique
index on e-mail applies only to live rows, so an address becomes reusable once
that window passes. Tax-kept invoices are retained regardless, as the deletion
screen states.
