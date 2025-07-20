-- Set timezone
SET timezone = 'Asia/Kolkata';

-- Also enable the extension in the main database
\c dhoomgames
CREATE EXTENSION IF NOT EXISTS pgx_ulid;
asas