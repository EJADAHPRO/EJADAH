-- 002 · Career: the 199 programmes, the 23 country guides, shortlist.
--
-- These two datasets are the product's trust claim. Rows are imported verbatim
-- from data/programmes.json and data/countries.js; nothing here is authored by
-- hand, and no value is ever estimated to fill a gap.

CREATE TYPE deadline_status AS ENUM ('open', 'closing_soon', 'expired');

CREATE TYPE pathway_class AS ENUM ('fast', 'exam', 'lang', 'complex');

-- How far a fact can be trusted. `pending` renders the exact words
-- "Pending source" / "بانتظار المصدر" and never a number.
CREATE TYPE source_status AS ENUM ('verified', 'pending', 'not_verified');

CREATE TABLE countries (
  iso                  text PRIMARY KEY,
  name_en              text NOT NULL,
  name_ar              text NOT NULL,
  region               text NOT NULL,
  exam_code            text NOT NULL,
  exam_full_en         text NOT NULL,
  exam_full_ar         text NOT NULL,
  pathway_class        pathway_class NOT NULL,
  pathway_class_en     text NOT NULL,
  pathway_class_ar     text NOT NULL,
  months_label         text NOT NULL,
  -- Parsed once at import from months_label ("12–24") so the roadmap can filter
  -- on time in SQL instead of re-parsing strings per request.
  min_months           integer NOT NULL,
  max_months           integer NOT NULL,
  difficulty_en        text NOT NULL,
  difficulty_ar        text NOT NULL,
  market_en            text NOT NULL,
  market_ar            text NOT NULL,
  salary_band          text,
  salary_note_en       text NOT NULL DEFAULT '',
  salary_note_ar       text NOT NULL DEFAULT '',
  authority_en         text NOT NULL,
  authority_ar         text NOT NULL,
  authority_site       text,
  visa_en              text NOT NULL DEFAULT '',
  visa_ar              text NOT NULL DEFAULT '',
  overview_en          text NOT NULL DEFAULT '',
  overview_ar          text NOT NULL DEFAULT '',
  recognition_note_en  text NOT NULL DEFAULT '',
  recognition_note_ar  text NOT NULL DEFAULT '',
  cost_note_en         text NOT NULL DEFAULT '',
  cost_note_ar         text NOT NULL DEFAULT '',
  updated_label        text NOT NULL,
  is_popular           boolean NOT NULL DEFAULT false,
  -- Languages a candidate must work in to follow this route, derived at import
  -- from the guide's own steps (Germany's step 1 is "German — B2 level").
  required_languages   text[] NOT NULL DEFAULT ARRAY['en'],
  -- Lowest total the guide's own cost table implies, in USD. Null where the
  -- table is entirely unsourced — which is a real state, not a zero.
  floor_cost_usd       integer,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX countries_region_idx ON countries (region);
CREATE INDEX countries_pathway_idx ON countries (pathway_class);

CREATE TABLE country_steps (
  id           bigserial PRIMARY KEY,
  country_iso  text NOT NULL REFERENCES countries (iso) ON DELETE CASCADE,
  position     integer NOT NULL,
  title_en     text NOT NULL,
  title_ar     text NOT NULL,
  detail_en    text NOT NULL DEFAULT '',
  detail_ar    text NOT NULL DEFAULT '',
  when_label   text,
  is_optional  boolean NOT NULL DEFAULT false,
  UNIQUE (country_iso, position)
);

CREATE TABLE country_exams (
  id              bigserial PRIMARY KEY,
  country_iso     text NOT NULL REFERENCES countries (iso) ON DELETE CASCADE,
  position        integer NOT NULL,
  name_en         text NOT NULL,
  name_ar         text NOT NULL,
  description_en  text NOT NULL DEFAULT '',
  description_ar  text NOT NULL DEFAULT '',
  dates_en        text NOT NULL DEFAULT '',
  dates_ar        text NOT NULL DEFAULT '',
  -- Eleven regulator fees are unverified. Those rows carry fee_value = NULL and
  -- fee_status = 'pending', and the app prints "Pending source".
  fee_value       text,
  fee_status      source_status NOT NULL DEFAULT 'pending',
  fee_source_name text,
  fee_source_url  text,
  fee_verified_on date,
  pass_mark_en    text NOT NULL DEFAULT '',
  pass_mark_ar    text NOT NULL DEFAULT '',
  UNIQUE (country_iso, position),
  -- A fee cannot claim to be verified without a value behind it.
  CONSTRAINT country_exams_verified_fee_has_value
    CHECK (fee_status <> 'verified' OR fee_value IS NOT NULL)
);

CREATE TABLE country_costs (
  id                bigserial PRIMARY KEY,
  country_iso       text NOT NULL REFERENCES countries (iso) ON DELETE CASCADE,
  position          integer NOT NULL,
  label_en          text NOT NULL,
  label_ar          text NOT NULL,
  local_value       text,
  local_status      source_status NOT NULL DEFAULT 'pending',
  usd_value         text,
  usd_status        source_status NOT NULL DEFAULT 'pending',
  UNIQUE (country_iso, position)
);

CREATE TABLE country_documents (
  id          bigserial PRIMARY KEY,
  country_iso text NOT NULL REFERENCES countries (iso) ON DELETE CASCADE,
  position    integer NOT NULL,
  label_en    text NOT NULL,
  label_ar    text NOT NULL,
  UNIQUE (country_iso, position)
);

CREATE TABLE country_tips (
  id          bigserial PRIMARY KEY,
  country_iso text NOT NULL REFERENCES countries (iso) ON DELETE CASCADE,
  position    integer NOT NULL,
  body_en     text NOT NULL,
  body_ar     text NOT NULL,
  UNIQUE (country_iso, position)
);

CREATE TABLE programmes (
  id                        integer PRIMARY KEY,
  region                    text NOT NULL,
  country                   text NOT NULL,
  -- Null where the source country has no guide; the card then renders without a
  -- flag rather than a broken image.
  country_iso               text REFERENCES countries (iso) ON DELETE SET NULL,
  city                      text NOT NULL DEFAULT '',
  university                text NOT NULL,
  programme_name            text NOT NULL,
  specialty                 text NOT NULL DEFAULT '',
  original_specialty        text NOT NULL DEFAULT '',
  degree_type               text NOT NULL DEFAULT '',
  study_type                text NOT NULL DEFAULT '',
  study_mode                text NOT NULL DEFAULT '',
  intake_month              text NOT NULL DEFAULT '',
  cohort_size               text NOT NULL DEFAULT '',
  duration_raw              text NOT NULL DEFAULT '',
  min_years                 integer,
  max_years                 integer,
  cost_raw                  text NOT NULL DEFAULT '',
  currency                  text,
  local_cost                integer,
  tuition_usd               integer,
  language                  text NOT NULL DEFAULT '',
  qs_rank                   integer,
  acceptance_rate           numeric(5, 4),
  ielts_requirement         text NOT NULL DEFAULT '',
  ielts_score               numeric(3, 1),
  gpa_requirement           text NOT NULL DEFAULT '',
  experience_requirement    text NOT NULL DEFAULT '',
  has_scholarship           boolean,
  has_egyptian_govt_funding boolean,
  thesis_required           boolean,
  interview_required        boolean,
  rating                    numeric(2, 1),
  deadline                  date,
  source_deadline_text      text NOT NULL DEFAULT '',
  days_remaining            integer,
  deadline_status           deadline_status NOT NULL DEFAULT 'expired',
  -- The source data's recognition labels lost their status in extraction, so
  -- the app shows nothing rather than guessing (conflict register #7).
  data_quality_note         text NOT NULL DEFAULT '',
  source_file               text NOT NULL DEFAULT '',
  created_at                timestamptz NOT NULL DEFAULT now(),
  updated_at                timestamptz NOT NULL DEFAULT now()
);

-- Every column the filter sheet can filter on is indexed: 199 rows today, but
-- the list is paginated and server-filtered by design and must stay that way.
CREATE INDEX programmes_region_idx ON programmes (region);
CREATE INDEX programmes_country_idx ON programmes (country);
CREATE INDEX programmes_specialty_idx ON programmes (specialty);
CREATE INDEX programmes_degree_idx ON programmes (degree_type);
CREATE INDEX programmes_intake_idx ON programmes (intake_month);
CREATE INDEX programmes_deadline_status_idx ON programmes (deadline_status);
CREATE INDEX programmes_deadline_idx ON programmes (deadline);
CREATE INDEX programmes_tuition_idx ON programmes (tuition_usd);

-- Text search over the three fields the search box actually claims to cover:
-- "University, programme or city".
CREATE INDEX programmes_search_idx ON programmes
  USING gin (
    to_tsvector(
      'simple',
      university || ' ' || programme_name || ' ' || city || ' ' || country
    )
  );

-- The shortlist. Saving is one of the five gates, so rows are always owned.
CREATE TABLE saved_programmes (
  user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  programme_id integer NOT NULL REFERENCES programmes (id) ON DELETE CASCADE,
  saved_at     timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, programme_id)
);

CREATE INDEX saved_programmes_user_idx ON saved_programmes (user_id, saved_at DESC);

-- A saved filter that raises alerts when new matches appear.
CREATE TABLE saved_filters (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  label      text NOT NULL,
  query      jsonb NOT NULL,
  alerts_on  boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX saved_filters_user_idx ON saved_filters (user_id);

-- Powers "Recently viewed" without exposing a browsing history to anyone else.
CREATE TABLE recently_viewed (
  user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  resource     text NOT NULL,
  resource_id  text NOT NULL,
  viewed_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, resource, resource_id)
);

CREATE INDEX recently_viewed_user_idx ON recently_viewed (user_id, viewed_at DESC);
