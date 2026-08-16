-- Two things the tutor dashboard (PE-13) needs and the schema has no home for.

-- Where a tutor's sessions actually happen.
--
-- One room per tutor rather than one per session: that is how the people doing
-- this work in Egypt actually operate — a personal Meet or Zoom room reused
-- every time — and a per-session field would be one more thing to fill in
-- before every booking.
--
-- Null is a real state, not a defect. Until it is set the dashboard shows the
-- session with an action to add a link, never a Join button that goes nowhere.
ALTER TABLE professionals ADD COLUMN meeting_url text;

-- "Hide me for now."
--
-- A tutor who is ill, on exams, or simply overloaded needs to stop appearing in
-- the marketplace without cancelling on anyone. Hidden removes them from every
-- listing and search; it does **not** touch a confirmed booking, which is a
-- promise already made and is honoured either way.
--
-- Distinct from `is_approved`: that is a decision about them, this is a
-- decision by them, and collapsing the two would let un-hiding restore someone
-- who was never approved.
ALTER TABLE professionals
  ADD COLUMN is_hidden boolean NOT NULL DEFAULT false;

-- Listings filter on both flags together, so the index carries both.
CREATE INDEX professionals_listable_idx
  ON professionals (kind)
  WHERE is_approved AND NOT is_hidden;
