# API

Base path `\/api\/v1`. JSON in, JSON out, UTF-8. Errors share one envelope.

## Conventions

| Header | Purpose |
|---|---|
| `authorization: Bearer <access>` | the signed-in caller |
| `x-device-token` | anonymous identifier; carries guest funnel work so it can migrate to the account on sign-up |
| `x-ejadah-language` | `ar` or `en`; the server answers in it |
| `x-correlation-id` | echoed on every response for log correlation |

### Error envelope

```json
{
  "error": {
    "code": "conflict",
    "message": {
      "en": "Someone booked that time a moment ago. Here's what's still open.",
      "ar": "حُجز هذا الموعد قبل لحظات. هذه المواعيد المتاحة."
    },
    "fields": { "password": { "en": "…", "ar": "…" } },
    "retry_after_seconds": 120
  }
}
```

Codes map to status: `validation` 422 · `authentication` 401 · `authorization`
403 · `not_found` 404 · `conflict` 409 · `rate_limit` 429 · `payment` 402 ·
`storage` 400 · `unexpected` 500. Every message is approved copy in both
languages — the client can render a failure from a route it does not know.

## Auth — `/auth`

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/register` | — | adopts guest work via `x-device-token`, in the same transaction |
| POST | `/login` | — | rate limited 8 / 5 min |
| POST | `/refresh` | — | single-use; a replay revokes the family |
| POST | `/logout` | — | revokes one token |
| POST | `/logout-all` | ✅ | revokes every session |
| GET | `/me` | ✅ | |
| PATCH | `/me/language` | ✅ | |
| POST | `/verify-email` | — | |
| POST | `/verify-email/resend` | ✅ | returns `cooldown_seconds` so the UI can show it as text |
| POST | `/forgot-password` | — | always 204; account existence is not public |
| POST | `/reset-password` | — | revokes every session |
| DELETE | `/me` | ✅ | soft delete, 30-day undo window |

## Career — `/career`

Browsing is open to guests; only the shortlist requires an account.

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/programmes` | optional | filter, search, sort, page — all server-side |
| GET | `/programmes/facets` | — | the filter values the data actually contains |
| GET | `/programmes/compare?ids=` | optional | at most 3 |
| GET | `/programmes/{id}` | optional | |
| GET | `/shortlist` | ✅ | plus `open_programme_count` for the empty state |
| PUT | `/shortlist/{id}` | ✅ | |
| DELETE | `/shortlist/{id}` | ✅ | idempotent, so a repeated undo cannot fail |
| GET | `/countries` | — | `?region=` `?class=` |
| GET | `/countries/compare?iso=` | — | at most 3 |
| GET | `/countries/{iso}` | — | full guide with steps, exams, costs, documents |
| GET | `/countries/{iso}/programmes` | optional | the guide → database crossing |

`GET /programmes` accepts `q`, `region`, `country`, `specialty`, `degree`,
`intake`, `max_tuition_usd`, `max_years`, `min_ielts`, `scholarship`,
`no_thesis`, `no_interview`, `show_expired`, `sort`, `page`, `page_size`
(capped at 50). Expired intakes are hidden unless asked for.

When a filtered search returns nothing, the response carries a `relaxation`
object naming the single filter whose removal recovers the most results.

## Roadmap — `/roadmap`

Guest-capable throughout except saving and scenarios.

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/draft` | optional | guest draft resolved by device token |
| PUT | `/draft` | optional | written after every funnel step |
| POST | `/generate` | optional | deterministic; guests get a gated result |
| GET | `/mine` | ✅ | |
| GET | `/{id}` | optional | |
| POST | `/{id}/save` | ✅ | |
| POST | `/{id}/what-if` | ✅ | creates a NEW roadmap; the original is preserved |
| PATCH | `/{id}/stages/{position}` | ✅ | mark a stage complete |

A gated response carries `is_gated`, `total_stage_count` and
`visible_stage_count`. The withheld stages are **not in the payload** — the gate
is server-side, not a blur.

## Health

`GET /health` touches the database, so a green check means the process can
serve, not merely that it is listening.

## Not yet mounted

People, Learn and Profile services and repositories exist and are tested
directly, but their HTTP routes are not mounted. See
`docs/implementation-status.md`.
