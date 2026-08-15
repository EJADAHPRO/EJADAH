-- 001 · Core identity, sessions and audit.
--
-- Conventions used by every migration in this directory:
--   * all timestamps are `timestamptz` and written in UTC
--   * every table carries created_at, and mutable tables carry updated_at
--   * text that the product renders in both languages is stored as two columns
--     (_en / _ar) rather than JSON, so a missing translation is a constraint
--     violation rather than a silent empty string

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Roles are enforced on the server; frontend visibility is never authorization.
CREATE TYPE user_role AS ENUM ('student', 'professional', 'admin');

CREATE TYPE career_stage AS ENUM (
  'student',
  'fresh_graduate',
  'general_dentist',
  'specialist',
  'consultant_owner'
);

CREATE TYPE professional_status AS ENUM (
  'none',
  'draft',
  'under_review',
  'approved',
  'rejected'
);

CREATE TABLE users (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email               text NOT NULL,
  -- Argon2id encoded string. Plaintext and fast hashes are never acceptable.
  password_hash       text NOT NULL,
  full_name_en        text NOT NULL,
  full_name_ar        text NOT NULL,
  role                user_role NOT NULL DEFAULT 'student',
  stage               career_stage NOT NULL DEFAULT 'general_dentist',
  -- Arabic is the product default.
  language            text NOT NULL DEFAULT 'ar' CHECK (language IN ('ar', 'en')),
  email_verified_at   timestamptz,
  professional_status professional_status NOT NULL DEFAULT 'none',
  is_premium          boolean NOT NULL DEFAULT true,
  -- Phase 1 Premium is read-only with a fixed renewal date and no prices.
  premium_renews_on   date NOT NULL DEFAULT DATE '2027-01-30',
  public_slug         text,
  avatar_url          text,
  referred_by_code    text,
  -- Account deletion is a 30-day undo window, so rows are retired, not dropped.
  deleted_at          timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Case-insensitive uniqueness on live accounts only, so a deleted account's
-- address can be reused once its undo window has passed.
CREATE UNIQUE INDEX users_email_unique
  ON users (lower(email))
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX users_public_slug_unique
  ON users (public_slug)
  WHERE public_slug IS NOT NULL AND deleted_at IS NULL;

-- Refresh tokens are opaque and stored only as a hash: a database leak must not
-- hand an attacker usable sessions.
CREATE TABLE refresh_tokens (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  token_hash   text NOT NULL UNIQUE,
  -- Rotation chain: a token that is used twice proves theft, and the whole
  -- family is revoked rather than just the replayed token.
  family_id    uuid NOT NULL,
  expires_at   timestamptz NOT NULL,
  used_at      timestamptz,
  revoked_at   timestamptz,
  user_agent   text,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX refresh_tokens_user_idx ON refresh_tokens (user_id);
CREATE INDEX refresh_tokens_family_idx ON refresh_tokens (family_id);

CREATE TABLE email_verifications (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  code_hash   text NOT NULL,
  expires_at  timestamptz NOT NULL,
  consumed_at timestamptz,
  attempts    integer NOT NULL DEFAULT 0,
  -- The resend cooldown is 60s and is shown as text, never as a mystery
  -- disabled button.
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX email_verifications_user_idx ON email_verifications (user_id);

CREATE TABLE password_resets (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  token_hash  text NOT NULL UNIQUE,
  expires_at  timestamptz NOT NULL,
  consumed_at timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE notification_preferences (
  user_id            uuid PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  -- Exactly three categories. There is deliberately no marketing category.
  deadline_alerts    boolean NOT NULL DEFAULT true,
  session_reminders  boolean NOT NULL DEFAULT true,
  study_nudges       boolean NOT NULL DEFAULT true,
  updated_at         timestamptz NOT NULL DEFAULT now()
);

-- Immutable record of consequential actions. No secrets, ever.
CREATE TABLE audit_log (
  id          bigserial PRIMARY KEY,
  actor_id    uuid REFERENCES users (id) ON DELETE SET NULL,
  action      text NOT NULL,
  resource    text NOT NULL,
  resource_id text,
  metadata    jsonb NOT NULL DEFAULT '{}'::jsonb,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX audit_log_resource_idx ON audit_log (resource, resource_id);
CREATE INDEX audit_log_actor_idx ON audit_log (actor_id, occurred_at DESC);

-- Login, registration and password-reset attempts, for rate limiting.
CREATE TABLE auth_attempts (
  id          bigserial PRIMARY KEY,
  scope       text NOT NULL,
  identifier  text NOT NULL,
  succeeded   boolean NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX auth_attempts_lookup_idx
  ON auth_attempts (scope, identifier, occurred_at DESC);
