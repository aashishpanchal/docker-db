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
DB_USER=$(grep -E '^POSTGRES_USER=' "$ENV_FILE" | cut -d '=' -f2- | tr -d '"')

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

-- Also enable the extension in the main database
\\c ${DB_NAME}
CREATE EXTENSION IF NOT EXISTS pgx_ulid;
EOF
