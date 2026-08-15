-- The suites run against their own database, so a test truncation can never
-- reach development data.
CREATE DATABASE ejadah_test OWNER ejadah;
