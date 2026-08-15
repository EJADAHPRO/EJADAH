-- 003 · Roadmap: guest drafts, generated results, what-if scenarios.
--
-- The generator is deterministic and reads only Ejadah's own rows. There is no
-- model call anywhere in this feature; reference_data_version is stored on every
-- result so "same inputs, same output" can be asserted against a known dataset.

CREATE TYPE roadmap_path AS ENUM (
  'gp_abroad',
  'specialise',
  'digital',
  'business'
);

-- A funnel in progress.
--
-- Guests answer all four questions without an account, so a draft is keyed by
-- an anonymous device token and adopted by the user on sign-up. Losing this at
-- the gate is called out in the handoff as a critical defect.
CREATE TABLE roadmap_drafts (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid REFERENCES users (id) ON DELETE CASCADE,
  device_token   text,
  answers        jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_step      integer NOT NULL DEFAULT 1,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT roadmap_drafts_has_owner
    CHECK (user_id IS NOT NULL OR device_token IS NOT NULL)
);

CREATE UNIQUE INDEX roadmap_drafts_device_idx
  ON roadmap_drafts (device_token)
  WHERE device_token IS NOT NULL AND user_id IS NULL;

CREATE UNIQUE INDEX roadmap_drafts_user_idx
  ON roadmap_drafts (user_id)
  WHERE user_id IS NOT NULL;

CREATE TABLE roadmaps (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                uuid REFERENCES users (id) ON DELETE CASCADE,
  device_token           text,
  -- Null for a "stay in Egypt" / remote-work outcome, which is a legitimate
  -- destination rather than a country guide.
  destination_iso        text REFERENCES countries (iso) ON DELETE SET NULL,
  destination_name_en    text NOT NULL,
  destination_name_ar    text NOT NULL,
  fit_score              integer NOT NULL CHECK (fit_score BETWEEN 0 AND 100),
  headline_en            text NOT NULL,
  headline_ar            text NOT NULL,
  summary_en             text NOT NULL DEFAULT '',
  summary_ar             text NOT NULL DEFAULT '',
  watch_out_en           text NOT NULL DEFAULT '',
  watch_out_ar           text NOT NULL DEFAULT '',
  this_month_action_en   text NOT NULL DEFAULT '',
  this_month_action_ar   text NOT NULL DEFAULT '',
  answers                jsonb NOT NULL,
  alternatives           jsonb NOT NULL DEFAULT '[]'::jsonb,
  -- What the generator ran against. Reproducibility is the trust claim.
  reference_data_version text NOT NULL,
  -- A what-if scenario is a NEW roadmap; the original is never overwritten.
  parent_id              uuid REFERENCES roadmaps (id) ON DELETE CASCADE,
  scenario_label_en      text,
  scenario_label_ar      text,
  is_saved               boolean NOT NULL DEFAULT false,
  created_at             timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT roadmaps_has_owner
    CHECK (user_id IS NOT NULL OR device_token IS NOT NULL)
);

CREATE INDEX roadmaps_user_idx ON roadmaps (user_id, created_at DESC);
CREATE INDEX roadmaps_device_idx ON roadmaps (device_token) WHERE user_id IS NULL;
CREATE INDEX roadmaps_parent_idx ON roadmaps (parent_id);

CREATE TABLE roadmap_stages (
  id                bigserial PRIMARY KEY,
  roadmap_id        uuid NOT NULL REFERENCES roadmaps (id) ON DELETE CASCADE,
  position          integer NOT NULL,
  title_en          text NOT NULL,
  title_ar          text NOT NULL,
  detail_en         text NOT NULL DEFAULT '',
  detail_ar         text NOT NULL DEFAULT '',
  projected_start   date NOT NULL,
  projected_end     date NOT NULL,
  is_optional       boolean NOT NULL DEFAULT false,
  cost_value        text,
  cost_status       source_status NOT NULL DEFAULT 'pending',
  -- Which guide row this stage was copied from. A stage whose text does not
  -- exist verbatim in the source data is a defect.
  source_country_iso text REFERENCES countries (iso) ON DELETE SET NULL,
  linked_course_id  integer,
  is_complete       boolean NOT NULL DEFAULT false,
  completed_at      timestamptz,
  UNIQUE (roadmap_id, position),
  CONSTRAINT roadmap_stages_dates_ordered CHECK (projected_end >= projected_start)
);
