-- Set timezone
SET timezone = 'Asia/Kolkata';

-- Add pgx_ulid to template1 so all future DBs inherit it
\c template1
CREATE EXTENSION IF NOT EXISTS pgx_ulid;

-- Also enable the extension in the main database
\c dhoomgames
CREATE EXTENSION IF NOT EXISTS pgx_ulid;
