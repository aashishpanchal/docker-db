#!/usr/bin/env bash
set -euo pipefail

# Check if .env file exists
ENV_FILE="./.env"
if [[ ! -f $ENV_FILE ]]; then
  echo "❌ Error: .env file not found at $ENV_FILE"
  exit 1
fi

# Extract POSTGRES_DB value safely
DB_NAME=$(grep -E '^POSTGRES_DB=' "$ENV_FILE" | cut -d '=' -f2- | tr -d '"')

if [[ -z "$DB_NAME" ]]; then
  echo "❌ Error: POSTGRES_DB not found or empty in .env"
  exit 1
fi

# Ensure output directory exists
mkdir -p ./pgsql

# Write the init-db.sql file
cat > ./pgsql/init-db.sql <<EOF
-- Set timezone
SET timezone = 'Asia/Kolkata';

-- Add pgx_ulid to template1 so all future DBs inherit it
\\c template1
CREATE EXTENSION IF NOT EXISTS pgx_ulid;

-- Also enable the extension in the main database
\\c ${DB_NAME}
CREATE EXTENSION IF NOT EXISTS pgx_ulid;
EOF

echo "✅ Generated pgsql/init-db.sql with pgx_ulid for database: ${DB_NAME}"
