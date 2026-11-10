#!/usr/bin/env bash
# start-the-mess.sh: starts the three programs in mess/ in the background, as if they had
# been left running. Each one writes into logs/. Their PIDs are saved in .mess-pids, so
# clean-up.sh can stop them if you get stuck. You don't need to change this file.
cd "$(dirname "$0")" || exit 1
if [[ -s .mess-pids ]]; then
  echo "The mess is already running. Stop it first, or run ./clean-up.sh."
  exit 1
fi
mkdir -p logs
for program in mess/*.sh; do
  name=$(basename "$program" .sh)
  nohup bash "$program" > "logs/$name.log" 2>&1 &
  echo $! >> .mess-pids
done
echo "Started 3 programs in the background. One of them is a runaway: find it with ps or top."
