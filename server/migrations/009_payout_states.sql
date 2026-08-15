-- Earnings gain a `requested` state, and a link to the request that claimed
-- them.
--
-- Without it the ledger has nowhere to put money a tutor has asked for but has
-- not received. The only alternatives were to leave the rows `available` — so a
-- second request could be opened against the same money — or to mark them
-- `paid` at request time, which would tell a tutor they had been paid on the
-- day they asked. Both are worse than a migration.
--
-- The lifecycle is now:
--   pending    booked and paid for, session not yet over
--   available  session over, can be asked for
--   requested  claimed by an open payout request
--   paid       the transfer happened
--   reversed   the booking was cancelled

ALTER TABLE earnings DROP CONSTRAINT earnings_status_check;

ALTER TABLE earnings ADD CONSTRAINT earnings_status_check
  CHECK (status IN ('pending', 'available', 'requested', 'paid', 'reversed'));

-- Which request claimed this row. Null until one does.
--
-- ON DELETE SET NULL rather than CASCADE: deleting a payout request must never
-- take a tutor's ledger rows with it.
ALTER TABLE earnings
  ADD COLUMN payout_request_id uuid
    REFERENCES payout_requests (id) ON DELETE SET NULL;

CREATE INDEX earnings_payout_request_idx
  ON earnings (payout_request_id)
  WHERE payout_request_id IS NOT NULL;

-- At most one open request per professional, enforced by the database rather
-- than by a check the application performs and a second connection races.
CREATE UNIQUE INDEX payout_requests_one_open_idx
  ON payout_requests (professional_id)
  WHERE status IN ('requested', 'approved');
