#!/usr/bin/env bash
# clean-up.sh: stops whatever start-the-mess.sh started that is still running, with KILL.
# Use it if you get stuck. It stops only the PIDs saved in .mess-pids, and only while each
# one is still one of the mess's programs. You don't need to change this file.
cd "$(dirname "$0")" || exit 1
if [[ ! -f .mess-pids ]]; then
  echo "Nothing to clean up."
  exit 0
fi
while read -r pid; do
  if ps -p "$pid" -o args= | grep -q 'mess/'; then
    kill -KILL "$pid" && echo "Stopped $pid."
  fi
done < .mess-pids
rm -f .mess-pids
echo "The mess is cleaned up."
