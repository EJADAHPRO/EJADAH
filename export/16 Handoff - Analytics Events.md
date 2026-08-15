# Analytics event taxonomy — Phase 1

The success metric is: **a dentist in Cairo reaches a personalised roadmap within three minutes of download.**
That is unmeasurable without the activation funnel below. Wire these in Batch 1, not later.

## Wired in the prototype today
| Event | Payload |
|---|---|
| `programme_viewed` | id |
| `programme_saved` | id, country, days_to_deadline |
| `course_viewed` | id |
| `roadmap_stage_toggled` | stage |

## Required — activation funnel (the 3-minute metric)
Every event carries `lang` ('en' | 'ar') and `persona`.

| # | Event | Payload | Why |
|---|---|---|---|
| 1 | `app_first_open` | install_source, referral_code | funnel start; starts the 3-min clock |
| 2 | `language_selected` | lang | AR/EN split drives everything downstream |
| 3 | `welcome_slide_viewed` | index | where the carousel loses people |
| 4 | `welcome_skipped` | at_index | is the carousel worth keeping |
| 5 | `roadmap_started` | entry_point (home_cta | career_tab | guest_teaser) | which entry converts |
| 6 | `roadmap_step_completed` | step (1-4), ms_on_step | finds the step people abandon |
| 7 | `roadmap_abandoned` | last_step, ms_total | the number to attack |
| 8 | `roadmap_generated` | destination, fit_score, ms_since_first_open | **the metric** |
| 9 | `guest_gate_shown` | — | gate impression |
| 10 | `account_created` | from_gate (bool), ms_since_first_open | guest-first conversion proof |
| 11 | `roadmap_saved` | roadmap_id | activation complete |

## Required — retention
| Event | Payload |
|---|---|
| `deadline_alert_enabled` | granted (bool), in_context (bool) |
| `deadline_notification_sent` | days_out (30|14|7), programme_id |
| `deadline_notification_opened` | days_out, programme_id |
| `roadmap_nudge_opened` | stage |
| `checklist_item_completed` | item, items_remaining |
| `lesson_completed` | course_id, lesson_index, autoplay (bool) |
| `flashcard_session_completed` | deck_id, again_count, got_it_count |
| `course_completed` | course_id, cpd_points |

## Required — marketplace
| Event | Payload |
|---|---|
| `tutor_viewed` | tutor_id, kind (tutoring|mentoring|consulting) |
| `booking_step_completed` | step (1-8), tutor_id |
| `booking_abandoned` | last_step, tutor_id |
| `payment_redirect_opened` | booking_id, amount_egp |
| `payment_returned` | booking_id, status (completed|cancelled) |
| `tutor_application_step` | step (1-6), saved_as_draft (bool) |

## Required — distribution
| Event | Payload |
|---|---|
| `share_opened` | object_type (roadmap|programme|tutor|nfc_card|certificate) |
| `share_completed` | object_type, channel (whatsapp|copy|email|other) |
| `referral_link_created` | code |
| `referral_signup_attributed` | code |
| `nfc_card_scanned` | card_id, by_account (bool) |

## Rules
- Never log patient data, clinical images, or free-text notes from bookings.
- `ms_since_first_open` is required on events 8 and 10 — without it the headline metric cannot be reported.
- Sentry breadcrumbs on every `*_abandoned` event so crashes can be correlated with drop-off.
