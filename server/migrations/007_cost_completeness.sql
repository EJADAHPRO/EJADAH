-- 007 · Record whether a country's cost floor is complete.
--
-- floor_cost_usd is a sum of the lower bounds of a guide's USD cost rows, and
-- unsourced rows contribute nothing. That makes a guide with missing fees look
-- cheaper than one that documented everything — which would let incomplete data
-- win the roadmap's cost tie-break. Recording completeness lets the engine
-- prefer a fully-sourced destination when scores are level, so honest data is
-- never penalised.

ALTER TABLE countries
  ADD COLUMN floor_cost_complete boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN countries.floor_cost_usd IS
  'Minimum total in USD implied by this guide''s own cost rows. A lower bound: '
  'each row contributes the bottom of its range and unsourced rows contribute '
  'nothing. NULL when no row is sourced at all.';

COMMENT ON COLUMN countries.floor_cost_complete IS
  'True when every USD cost row for this country carries a sourced value, so '
  'floor_cost_usd is a complete lower bound rather than a partial one.';
