# Ops log — every manual admin action, dated

Two things this application cannot do to itself: approve a tutor, and pay one.
Both are run by hand from [`operations.md`](operations.md) until the admin panel
exists. **Every run gets a line here.**

This is the only record of who did it and why. The schema keeps *what* happened
— `professionals.approved_at`, `payout_requests.resolver_id` — and none of it
says which person typed the statement, on what evidence, or what they decided
against. That is the part a disputed transfer or an angry rejected applicant
turns out to need, and it is the part that exists nowhere else.

Append; never edit a past line. A run that turned out to be wrong gets a *new*
line recording the correction, because the mistake and the fix are both part of
what happened. The file is committed like any other, so `git log` carries the
timestamps you did not type.

## Format

One line per action, newest at the bottom, under the month it happened in:

```
YYYY-MM-DD · <operator> · <action> · <subject> · <reference> · <note>
```

- **operator** — the person, not a shared login. "khaled", not "admin".
- **action** — `approve` · `reject` · `payout-sent` · `payout-reversed`.
- **subject** — how a human finds the row again: the email address, and the
  display name if the email alone is ambiguous.
- **reference** — the id the statement's `RETURNING` clause actually printed:
  the professional id for an approval, the payout uuid for a transfer. Copy it
  from the output rather than from the statement you typed; that is what makes
  the line a check on the run and not a restatement of the intent.
- **note** — the *why*, in a clause. For a rejection, the reason given to the
  applicant. For a payout, the amount and how it was sent. For anything
  surprising, what was surprising.

**Never put in a line:** a password, a token, a bank account or card number, the
contents of an uploaded certificate, or anything a student wrote about their own
case. An email address and a name are already in the database and are what make
a line findable — that is the whole of what a line needs. The same rule the
application's logger follows applies to the person typing.

## Example

Not a real run — the format, so the first real one has something to copy.

```
2026-08-16 · khaled · approve · mona.hassan@example.com (Mona Hassan) · professional 41 · endodontics MSc verified against the certificate; availability copied from the payload
2026-08-16 · khaled · reject  · a.samir@example.com · application 88 · certificate photograph unreadable, asked for a clearer scan
2026-08-31 · khaled · payout-sent · mona.hassan@example.com · payout 3f9c…a12 · EGP 4,480, Instapay, ledger reconciled at 4,480
```

---

## 2026-08

_No manual admin action yet — the first real tutor has not applied._
