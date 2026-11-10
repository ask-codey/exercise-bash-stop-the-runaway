#!/usr/bin/env bash
# alarm.sh: a runaway alarm. It beeps once a second until something stops it.
# In case you forget it, it stops by itself after 30 minutes.
end=$((SECONDS + 1800))
while (( SECONDS < end )); do
  echo "BEEP"
  sleep 1
done
