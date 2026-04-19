#!/bin/sh
set -e

read_secret() {
  var_name="$1"
  file_var_name="${var_name}_FILE"
  file_path=$(eval "printf '%s' \"\${$file_var_name:-}\"")

  if [ -n "$file_path" ] && [ -f "$file_path" ]; then
    value=$(tr -d '\r' < "$file_path")
    export "$var_name=$value"
  fi
}

read_secret POSTGRES_PASSWORD
read_secret JWT_SECRET
read_secret OPENAI_API_KEY

if [ -z "$DATABASE_URL" ]; then
  : "${POSTGRES_HOST:=db}"
  : "${POSTGRES_PORT:=5432}"
  : "${POSTGRES_DB:=lang_platformdb}"
  : "${POSTGRES_USER:=postgres}"
  : "${POSTGRES_PASSWORD:=}"

  encoded_user=$(node -p "encodeURIComponent(process.argv[1])" "$POSTGRES_USER")
  encoded_password=$(node -p "encodeURIComponent(process.argv[1])" "$POSTGRES_PASSWORD")
  encoded_db=$(node -p "encodeURIComponent(process.argv[1])" "$POSTGRES_DB")

  export DATABASE_URL="postgresql://${encoded_user}:${encoded_password}@${POSTGRES_HOST}:${POSTGRES_PORT}/${encoded_db}?schema=public"
fi

npx prisma migrate deploy

if [ "$#" -gt 0 ]; then
  exec "$@"
fi

exec npm start
