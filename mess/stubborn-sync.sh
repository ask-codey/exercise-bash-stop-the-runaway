#!/usr/bin/env bash
# stubborn-sync.sh: a file-sync program that ignores a polite request to stop.
# In case you forget it, it stops by itself after 30 minutes.
trap 'echo "Not now, I am syncing."' TERM
end=$((SECONDS + 1800))
while (( SECONDS < end )); do
  echo "Syncing..."
  sleep 1
done
