-- 006 · Profile, payments and platform services.

CREATE TABLE profiles (
  user_id      uuid PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  title_en     text NOT NULL DEFAULT '',
  title_ar     text NOT NULL DEFAULT '',
  clinic_en    text NOT NULL DEFAULT '',
  clinic_ar    text NOT NULL DEFAULT '',
  bio_en       text NOT NULL DEFAULT '',
  bio_ar       text NOT NULL DEFAULT '',
  phone        text,
  -- The public NFC card. Only these fields ever leave the server unauthenticated.
  links        jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_public    boolean NOT NULL DEFAULT false,
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- Views of a public profile. Counted in aggregate only — a viewer is never
-- named, and the owner never sees who looked.
CREATE TABLE public_profile_views (
  id         bigserial PRIMARY KEY,
  slug       text NOT NULL,
  viewed_on  date NOT NULL DEFAULT CURRENT_DATE,
  view_count integer NOT NULL DEFAULT 1,
  UNIQUE (slug, viewed_on)
);

CREATE TABLE certificates (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  title_en          text NOT NULL,
  title_ar          text NOT NULL,
  issuer_en         text NOT NULL DEFAULT '',
  issuer_ar         text NOT NULL DEFAULT '',
  issued_on         date NOT NULL,
  -- 'verified' is reserved for Ejadah-issued certificates. A user-uploaded
  -- certificate is always 'stated', and the constraint below makes it
  -- impossible to mint a verification code for one.
  evidence          credential_evidence NOT NULL DEFAULT 'stated',
  cpd_points        integer NOT NULL DEFAULT 0,
  course_id         integer REFERENCES courses (id) ON DELETE SET NULL,
  verification_code text UNIQUE,
  document_key      text,
  revoked_at        timestamptz,
  revoked_reason    text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT certificates_only_verified_have_codes
    CHECK (verification_code IS NULL OR evidence = 'verified'),
  CONSTRAINT certificates_verified_are_ejadah_issued
    CHECK (evidence <> 'verified' OR course_id IS NOT NULL)
);

CREATE INDEX certificates_user_idx ON certificates (user_id, issued_on DESC);

CREATE TABLE cpd_entries (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  title_en       text NOT NULL,
  title_ar       text NOT NULL,
  points         integer NOT NULL CHECK (points >= 0),
  earned_on      date NOT NULL,
  evidence       credential_evidence NOT NULL DEFAULT 'stated',
  certificate_id uuid REFERENCES certificates (id) ON DELETE SET NULL,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX cpd_entries_user_idx ON cpd_entries (user_id, earned_on DESC);

CREATE TABLE cv_sections (
  id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id  uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  position integer NOT NULL,
  kind     text NOT NULL,
  heading  text NOT NULL DEFAULT '',
  body     text NOT NULL DEFAULT '',
  UNIQUE (user_id, position)
);

-- Uploads. Files never live inside application source directories; this table
-- holds keys into the storage provider (local filesystem in dev, object store
-- in production).
CREATE TABLE stored_files (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id     uuid REFERENCES users (id) ON DELETE CASCADE,
  storage_key  text NOT NULL UNIQUE,
  -- Server-detected, never the client's claim.
  mime_type    text NOT NULL,
  bytes        bigint NOT NULL CHECK (bytes > 0),
  original_name text NOT NULL DEFAULT '',
  visibility   text NOT NULL DEFAULT 'private'
                 CHECK (visibility IN ('private', 'public')),
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- Payments.
--
-- Courses never appear here: they are in-app purchases and the store is the
-- system of record. This table covers sessions (external checkout) and the
-- physical NFC card.
CREATE TABLE payments (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  booking_id    uuid REFERENCES bookings (id) ON DELETE SET NULL,
  provider      text NOT NULL,
  -- Server-computed. Never read from a client request body.
  amount_egp    integer NOT NULL CHECK (amount_egp >= 0),
  status        text NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'completed', 'cancelled', 'failed', 'refunded')),
  external_ref  text,
  refunded_egp  integer,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX payments_booking_idx ON payments (booking_id);
CREATE UNIQUE INDEX payments_external_ref_unique
  ON payments (provider, external_ref)
  WHERE external_ref IS NOT NULL;

-- The idempotency ledger. A duplicate provider callback finds its event id
-- already present and becomes a no-op, so it cannot create a second payment,
-- booking, entitlement, earning or refund.
CREATE TABLE payment_events (
  id           bigserial PRIMARY KEY,
  provider     text NOT NULL,
  event_id     text NOT NULL,
  payment_id   uuid REFERENCES payments (id) ON DELETE CASCADE,
  payload      jsonb NOT NULL DEFAULT '{}'::jsonb,
  processed_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, event_id)
);

CREATE TABLE notifications (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  category     text NOT NULL CHECK (category IN ('deadline', 'session', 'study')),
  title_en     text NOT NULL,
  title_ar     text NOT NULL,
  body_en      text NOT NULL DEFAULT '',
  body_ar      text NOT NULL DEFAULT '',
  deep_link    text,
  read_at      timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX notifications_user_idx ON notifications (user_id, created_at DESC);
CREATE INDEX notifications_unread_idx ON notifications (user_id) WHERE read_at IS NULL;

-- Server-side scheduling: deadline alerts at 30/14/7 days, session reminders at
-- T-24h and T-1h, weekly roadmap nudges. None of this can depend on the Flutter
-- app being open.
CREATE TABLE scheduled_notifications (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  category     text NOT NULL CHECK (category IN ('deadline', 'session', 'study')),
  -- Natural key of what this notification is about, so re-running the scheduler
  -- cannot queue the same reminder twice.
  dedupe_key   text NOT NULL,
  send_after   timestamptz NOT NULL,
  payload      jsonb NOT NULL DEFAULT '{}'::jsonb,
  sent_at      timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, dedupe_key)
);

CREATE INDEX scheduled_notifications_due_idx
  ON scheduled_notifications (send_after)
  WHERE sent_at IS NULL;

-- Analytics landing table. The canonical taxonomy lives in
-- handoff/analytics-events.md; the wrapper stamps lang, persona, version and
-- ms_since_first_open on every event.
--
-- Privacy rule, enforced at the service layer: no patient data, no clinical
-- images, no free-text booking notes, no credentials ever reach this table.
CREATE TABLE analytics_events (
  id                   bigserial PRIMARY KEY,
  user_id              uuid REFERENCES users (id) ON DELETE SET NULL,
  device_token         text,
  name                 text NOT NULL,
  properties           jsonb NOT NULL DEFAULT '{}'::jsonb,
  lang                 text NOT NULL DEFAULT 'ar',
  persona              text,
  app_version          text,
  ms_since_first_open  bigint,
  occurred_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX analytics_events_name_idx ON analytics_events (name, occurred_at DESC);

-- Background job bookkeeping, so a restarted server does not re-run work and a
-- stuck job is visible.
CREATE TABLE job_runs (
  id          bigserial PRIMARY KEY,
  job_name    text NOT NULL,
  started_at  timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz,
  succeeded   boolean,
  detail      text
);

CREATE INDEX job_runs_name_idx ON job_runs (job_name, started_at DESC);
