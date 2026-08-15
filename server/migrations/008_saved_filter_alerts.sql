-- Saved-filter alerts need to know what has already been announced.
--
-- Without this, "3 new programmes match your search" has no anchor: every
-- sweep would either re-announce the same rows or announce nothing. The
-- dedupe key cannot carry it, because the thing being announced is a *count
-- since a moment*, not a specific row.
--
-- Null means the filter has never alerted. The first sweep sets it without
-- announcing anything, so saving a search does not immediately fire a
-- notification about programmes that were already there when it was saved.
ALTER TABLE saved_filters
  ADD COLUMN last_alerted_at timestamptz;

-- The sweep reads only filters with alerts on, and only for live users.
CREATE INDEX saved_filters_alerts_idx
  ON saved_filters (user_id)
  WHERE alerts_on = true;
