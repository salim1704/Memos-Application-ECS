#!/bin/bash


HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-https://tm.abdulqayoom.co.uk/healthz}"
max_attempts=10
attempt=1

echo "Running health check against $HEALTH_CHECK_URL..."

while [ $attempt -le $max_attempts ]; do
  response=$(curl -sS -m 10 -o /dev/null -w "%{http_code}" "$HEALTH_CHECK_URL" || echo "000")

  if [ "$response" = "200" ]; then
    echo "Health check passed!"
    exit 0
  fi

  echo "Attempt $attempt/$max_attempts failed (HTTP $response)"

  if [ $attempt -lt $max_attempts ]; then
    echo "Retrying in 30s..."
    sleep 30
  fi

  attempt=$((attempt + 1))
done

echo "Health check failed after $max_attempts attempts"
exit 1