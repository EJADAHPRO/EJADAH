# Operations — the manual steps, until the admin panel exists

Two things this application deliberately cannot do to itself: approve a tutor,
and pay one. Both belong to the admin panel, which is web-only and outside this
repository. Until it ships, an operator runs the statements below by hand.

They are written down here because the alternative is archaeology. The first
real tutor will apply before the admin panel exists, and the person who has to
answer them should not have to read `tutor_application_service.dart` to find out
which column to set.

Every statement below has been run against the real schema, inside a
transaction that was rolled back — they are transcribed from a rehearsal, not
written from memory.

**Before running anything:** take a backup, and run each statement inside an
explicit transaction so a mistyped `WHERE` can be rolled back rather than
discovered.

```sql
BEGIN;
-- … statement …
-- Read the RETURNING output. If it is not exactly what you meant:
ROLLBACK;
-- Otherwise:
COMMIT;
```

---

## 1 · Approve (or reject) a tutor application

`POST /people/apply/submit` moves an application to `under_review` and the app
promises a reply within three working days (PE-12). Nothing in this repository
sends that reply.

### Read the application first

The answers are one JSON document. Read them before deciding — the point of the
six steps is that a person, not a script, looks at the certificate.

```sql
SELECT
  u.email,
  u.full_name_en,
  a.status,
  a.submitted_at,
  jsonb_pretty(a.payload) AS answers
FROM tutor_applications a
JOIN users u ON u.id = a.user_id
WHERE a.status = 'under_review'
ORDER BY a.submitted_at;
```

The certificate is at `payload -> 'qualifications' ->> 'document_key'` and the
photograph at `payload -> 'media' ->> 'avatar_key'`. Both are storage keys, not
URLs. Read them through the API as the applicant — reads are owner-only and a
key alone will not open one:

```
GET /api/v1/uploads/<document_key>     (authenticated as the applicant)
```

or, on the server's disk, at `$STORAGE_ROOT/uploads/<document_key>`.

### Approve

Approving is **two** statements, and doing only the first is the mistake to
avoid: the application would read as approved while no professional row exists,
so the tutor would see a playbook and no student would ever see them.

```sql
BEGIN;

-- (a) The application itself.
UPDATE tutor_applications
SET status = 'approved', rejection_reason = NULL, updated_at = now()
WHERE user_id = '<user-uuid>' AND status = 'under_review'
RETURNING user_id, status;

-- (b) The roster row the marketplace actually lists. Built from the answers,
--     so nothing is retyped and nothing is invented.
INSERT INTO professionals (
  user_id, slug, kind,
  display_name_en, display_name_ar,
  headline_en, headline_ar,
  hourly_rate_egp, avatar_url,
  is_approved, approved_at
)
SELECT
  a.user_id,
  -- The public handle. Lowercase, hyphenated, unique — it ends up in a URL.
  '<slug>',
  'tutoring',
  a.payload -> 'basics' ->> 'display_name_en',
  a.payload -> 'basics' ->> 'display_name_ar',
  a.payload -> 'basics' ->> 'headline',
  a.payload -> 'basics' ->> 'headline',
  (a.payload -> 'rate' ->> 'hourly_rate_egp')::int,
  a.payload -> 'media' ->> 'avatar_key',
  true,
  now()
FROM tutor_applications a
WHERE a.user_id = '<user-uuid>'
RETURNING id, slug;

COMMIT;
```

Then set the account's role so the app shows them the supply side:

```sql
UPDATE users SET role = 'professional' WHERE id = '<user-uuid>';
```

**The availability the applicant entered is not copied by these statements.**
Step 5's rules live in `payload -> 'availability' -> 'rules'`; the editor
(PE-14) writes `availability_rules`. Until an approved tutor opens the editor
and saves, they have no bookable slots. Either ask them to open it, or insert
the rules yourself from the payload.

### Reject

Always with a reason. The rejection screen shows it verbatim and the applicant
can edit and resend; a rejection with no reason is one nobody can act on.

```sql
UPDATE tutor_applications
SET status = 'rejected',
    rejection_reason = 'The certificate photograph is unreadable — please '
                       'upload a clearer scan.',
    updated_at = now()
WHERE user_id = '<user-uuid>' AND status = 'under_review'
RETURNING user_id, rejection_reason;
```

---

## 2 · Mark a payout sent

`POST /earnings/payouts` moves a tutor's available earnings to `requested` and
opens a `payout_requests` row. It stops there, deliberately: nothing in this
repository moves money, and telling a tutor they were paid on the day they asked
is the kind of lie a ledger never recovers from.

### Read the open requests

```sql
SELECT
  r.id,
  u.email,
  p.display_name_en,
  r.amount_egp,
  r.requested_at
FROM payout_requests r
JOIN professionals p ON p.id = r.professional_id
JOIN users u ON u.id = p.user_id
WHERE r.status IN ('requested', 'approved')
ORDER BY r.requested_at;
```

### After the transfer has actually left

Two statements, one transaction. The second is the one that matters to the
tutor: without it the ledger still shows the money as "on its way" forever, and
`requested` rows are excluded from the available balance, so the tutor cannot
request anything again.

```sql
BEGIN;

UPDATE payout_requests
SET status = 'paid', resolved_at = now(), resolver_id = '<admin-user-uuid>'
WHERE id = '<payout-uuid>' AND status IN ('requested', 'approved')
RETURNING id, amount_egp;

UPDATE earnings
SET status = 'paid'
WHERE payout_request_id = '<payout-uuid>' AND status = 'requested'
RETURNING id, status;

COMMIT;
```

Check the two agree before committing — the sum of the earnings rows must equal
the request's `amount_egp`:

```sql
SELECT
  r.amount_egp AS requested,
  COALESCE(SUM(e.gross_egp - e.platform_fee_egp), 0) AS ledger
FROM payout_requests r
LEFT JOIN earnings e ON e.payout_request_id = r.id
WHERE r.id = '<payout-uuid>'
GROUP BY r.amount_egp;
```

A professional may have only one open request at a time — `payout_requests`
carries a partial unique index on `(professional_id) WHERE status IN
('requested', 'approved')`. Resolving the open one is what lets them ask again.

### If a transfer fails

Return the rows to `available` so the tutor can ask again. Rejecting the request
without releasing the earnings is the failure mode: the money would sit in
`requested` against a closed request and be unreachable from either side.

```sql
BEGIN;

UPDATE payout_requests
SET status = 'rejected', resolved_at = now(), resolver_id = '<admin-user-uuid>'
WHERE id = '<payout-uuid>';

UPDATE earnings
SET status = 'available', payout_request_id = NULL
WHERE payout_request_id = '<payout-uuid>' AND status = 'requested';

COMMIT;
```

---

## What these statements do not do

Neither flow sends an email or a push notification. The applicant and the tutor
find out by opening the app. When the admin panel lands it should do both, and
these statements should be deleted from this file rather than left as a second
way to do the same thing.
