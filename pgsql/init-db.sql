-- Set timezone
SET timezone = 'Asia/Kolkata';

-- Add extension to template1
\c template1
CREATE EXTENSION IF NOT EXISTS pgx_ulid;

-- Enable the ULID extension for the specific database
\c dhoomgames
CREATE EXTENSION IF NOT EXISTS pgx_ulid;
