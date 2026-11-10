#!/usr/bin/env bats
# Checks your answers in answers.txt, and your two scripts, stop-politely.sh and start-export.sh.
# The scripts are tried for real, on small practice processes this check starts itself, in a
# throwaway folder. The check stops only the processes it started, and nothing in this folder is
# changed. Run it from this folder with:  bats check.bats
# You don't need to change this file.

bats_require_minimum_version 1.5.0

setup() {
  cd "$BATS_TEST_DIRNAME"
  T="$BATS_TEST_TMPDIR"
  : > "$T/started"
}

# Stops every process this test started that is still running: only PIDs it wrote down, and
# only while each one still runs a command from this test's throwaway folder or the export.
teardown() {
  local pid args
  while read -r pid; do
    [[ -n "$pid" ]] || continue
    args="$(ps -p "$pid" -o args= 2>/dev/null || true)"
    if [[ "$args" == *"$T"* || "$args" == *export-video.sh* ]]; then
      kill -KILL "$pid" 2>/dev/null || true
    fi
  done < "$T/started"
}

# The answer written after "N)" in answers.txt, without spaces or quotes at either end.
answer() {
  grep -E "^$1\)" answers.txt | head -n 1 | sed -E "s/^$1\)[[:space:]]*//; s/[[:space:]]+\$//; s/^[\"'\`]//; s/[\"'\`]\$//"
}

# Fails with a message when question N has no answer yet.
need() {
  if [[ -z "$(answer "$1")" ]]; then
    echo "Question $1 has no answer yet. Write it after \"$1)\" in answers.txt."
    return 1
  fi
}

# A signal's name in capitals, without SIG in front: "sigint" and "INT" both give INT.
signal_name() {
  local s
  s="$(tr '[:lower:]' '[:upper:]' <<< "$1")"
  s="${s#-}"
  echo "${s#SIG}"
}

# Starts a small practice process that writes "TERM" into $T/got-term when it gets TERM.
# polite: it stops then. stubborn: it carries on. Its PID goes in $pid and in $T/started.
start_practice() {
  if [[ "$1" == polite ]]; then
    printf '%s\n' "trap 'echo TERM >> \"$T/got-term\"; exit 0' TERM" 'while true; do sleep 0.2; done' > "$T/practice.sh"
  else
    printf '%s\n' "trap 'echo TERM >> \"$T/got-term\"' TERM" 'while true; do sleep 0.2; done' > "$T/practice.sh"
  fi
  ( bash "$T/practice.sh" > /dev/null 2>&1 3>&- & echo $! > "$T/practice.pid" )
  pid="$(cat "$T/practice.pid")"
  echo "$pid" >> "$T/started"
  sleep 0.5
}

# True while a process with this PID is running.
running() {
  ps -p "$1" > /dev/null 2>&1
}

# Copies start-export.sh into a throwaway folder with a quick practice export-video.sh (it writes
# its own PID into $T/started, so teardown can stop it, and it ends by itself within a minute),
# runs start-export.sh there for at most 10 seconds, and sets $status (124 when it was still
# running), $output and $pid.
start_export() {
  mkdir -p "$T/run"
  cp start-export.sh "$T/run/start-export.sh"
  printf '%s\n' '#!/usr/bin/env bash' "echo \$\$ >> '$T/started'" 'for frame in $(seq 1 300); do' '  echo "Exported frame $frame of 300"' '  sleep 0.2' 'done' > "$T/run/export-video.sh"
  chmod +x "$T/run/export-video.sh" "$T/run/start-export.sh"
  ( cd "$T/run" && bash start-export.sh > "$T/out.txt" 2>&1 < /dev/null 3>&- ) &
  local job=$! waited=0
  while kill -0 "$job" 2>/dev/null && (( waited < 50 )); do
    sleep 0.2
    waited=$((waited + 1))
  done
  if kill -0 "$job" 2>/dev/null; then
    kill -KILL "$job" 2>/dev/null || true
    status=124
  else
    wait "$job"
    status=$?
  fi
  output="$(cat "$T/out.txt")"
  pid="$(cat "$T/run/export.pid" 2>/dev/null | tr -d '[:space:]')"
  [[ -n "$pid" ]] && echo "$pid" >> "$T/started"
  return 0
}

@test "the scripts and the mess are here" {
  for f in answers.txt stop-politely.sh start-export.sh export-video.sh start-the-mess.sh clean-up.sh mess/render-thumbnails.sh mess/alarm.sh mess/stubborn-sync.sh; do
    if [[ ! -f "$f" ]]; then
      echo "$f is missing. Download the exercise again to get it back."
      return 1
    fi
  done
}

@test "1) the program using the most CPU" {
  need 1
  a="$(answer 1)"
  a="${a#bash }"; a="${a#./}"; a="${a#mess/}"; a="${a%.sh}"
  if [[ "$a" != "render-thumbnails" ]]; then
    echo "Question 1: \"$(answer 1)\" isn't the busiest program yet. Start the mess with ./start-the-mess.sh, then sort by CPU with ps aux --sort=-%cpu | head -n 5, or watch top."
    return 1
  fi
}

@test "2) the polite way to stop process 4242" {
  need 2
  a="$(answer 2)"
  if ! grep -Eq '^kill( +(-TERM|-SIGTERM|-15|-s +TERM|-s +SIGTERM|-s +15))? +4242$' <<< "$a"; then
    echo "Question 2: \"$a\" isn't it yet. The polite signal is TERM, and it's the one kill sends when you give it only a PID."
    return 1
  fi
}

@test "3) one command for every alarm.sh" {
  need 3
  a="$(answer 3)"
  if [[ "$a" =~ ^pkill\ +(-TERM\ +|-SIGTERM\ +|-15\ +)?(alarm|alarm\.sh|mess/alarm\.sh)$ ]]; then
    echo "Question 3: \"$a\" finds nothing yet. A script runs as bash, so pkill has to match against the whole command line: add -f."
    return 1
  fi
  if ! grep -Eq "^pkill( +(-TERM|-SIGTERM|-15))? +-f( +(-TERM|-SIGTERM|-15))? +['\"]?(\./)?(mess/)?alarm(\.sh)?['\"]?$" <<< "$a"; then
    echo "Question 3: \"$a\" isn't it yet. Which command stops processes by name? Check what it would stop with pgrep -af first."
    return 1
  fi
}

@test "4) the signal for a program that ignores TERM" {
  need 4
  a="$(signal_name "$(answer 4)")"
  if [[ "$a" != KILL && "$a" != 9 ]]; then
    echo "Question 4: \"$(answer 4)\" isn't it yet. Which signal can no program catch or ignore?"
    return 1
  fi
}

@test "5) the signal Ctrl+C sends" {
  need 5
  a="$(signal_name "$(answer 5)")"
  if [[ "$a" != INT && "$a" != 2 ]]; then
    echo "Question 5: \"$(answer 5)\" isn't it yet. kill -l 2 turns signal number 2 into its name."
    return 1
  fi
}

@test "6) stop-politely.sh with no PID shows how to use it" {
  run --separate-stderr bash stop-politely.sh
  if [[ "$status" -ne 2 ]]; then
    echo "With no PID, stop-politely.sh should stop with exit code 2. It finished with $status."
    return 1
  fi
  if [[ "$stderr" != *"Usage: stop-politely.sh PID"* ]]; then
    echo "With no PID, it should print on standard error: Usage: stop-politely.sh PID"
    echo "Standard error was: $stderr"
    echo "Print it with echo \"...\" >&2."
    return 1
  fi
}

@test "7) stop-politely.sh says when there's no such process" {
  ( sleep 0 & echo $! > "$T/gone.pid" )
  sleep 0.5
  gone="$(cat "$T/gone.pid")"
  run bash stop-politely.sh "$gone"
  if [[ "$status" -ne 1 || "$output" != *"No process $gone is running."* ]]; then
    echo "Given a PID that isn't running, it should print: No process $gone is running."
    echo "and stop with exit code 1. It printed: $output"
    echo "and finished with exit code $status. Check with ps -p first."
    return 1
  fi
}

@test "8) stop-politely.sh stops a process with TERM" {
  start_practice polite
  SECONDS=0
  run bash stop-politely.sh "$pid"
  took=$SECONDS
  if running "$pid"; then
    echo "The practice process is still running after stop-politely.sh finished. Send it TERM with kill -TERM \"\$1\", or plain kill."
    return 1
  fi
  if [[ ! -s "$T/got-term" ]]; then
    echo "The practice process stopped without handling TERM: it got KILL first, or too soon. Send TERM, then check once a second with ps -p."
    return 1
  fi
  if [[ "$output" != *"Sent TERM to $pid."* || "$output" != *"$pid stopped."* ]]; then
    echo "It should print: Sent TERM to $pid."
    echo "and then: $pid stopped."
    echo "It printed: $output"
    return 1
  fi
  if [[ "$status" -ne 0 ]]; then
    echo "After stopping it, the script should finish with exit code 0. It finished with $status."
    return 1
  fi
  if (( took > 3 )); then
    echo "The process stopped at once, but the script took $took seconds. Stop checking as soon as ps -p says it's gone."
    return 1
  fi
}

@test "9) stop-politely.sh sends KILL only after TERM and a wait" {
  start_practice stubborn
  SECONDS=0
  run bash stop-politely.sh "$pid"
  took=$SECONDS
  sleep 0.5
  if [[ ! -s "$T/got-term" ]] && running "$pid"; then
    echo "The practice process never got TERM, and it's still running. Send TERM first, so a program can save its work."
    return 1
  fi
  if [[ ! -s "$T/got-term" ]]; then
    echo "The practice process never handled TERM: it got KILL first, or too soon. Always send TERM first, so a program can save its work."
    return 1
  fi
  if running "$pid"; then
    echo "This practice process ignores TERM, and it's still running. After 5 seconds, send it KILL."
    return 1
  fi
  if (( took < 4 )); then
    echo "It sent KILL after only $took seconds. Check once a second, for up to 5 seconds, before you send KILL."
    return 1
  fi
  if [[ "$output" != *"$pid ignored TERM. Sent KILL."* || "$status" -ne 0 ]]; then
    echo "It should print: $pid ignored TERM. Sent KILL.  and finish with exit code 0."
    echo "It printed: $output"
    echo "and finished with exit code $status."
    return 1
  fi
}

@test "10) start-export.sh returns at once and saves the PID" {
  start_export
  if [[ "$status" -eq 124 ]]; then
    echo "start-export.sh was still running after 10 seconds. Put an & at the end of the line that starts the export."
    return 1
  fi
  if [[ -z "$pid" ]]; then
    echo "There's no PID in export.pid. Save it with: echo \$! > export.pid"
    return 1
  fi
  if [[ "$(ps -p "$pid" -o args= 2>/dev/null)" != *export-video.sh* ]]; then
    echo "export.pid holds $pid, but that isn't the running export. Save \$! right after the line that starts it."
    return 1
  fi
  if [[ "$output" != *"Started the export: PID $pid"* ]]; then
    echo "It should print: Started the export: PID $pid"
    echo "It printed: $output"
    return 1
  fi
}

@test "11) the export keeps running after a hang-up" {
  start_export
  if [[ -z "$pid" ]] || ! running "$pid"; then
    echo "The export isn't running, so this can't be checked yet. Get check 10) to pass first."
    return 1
  fi
  kill -HUP "$pid"
  sleep 1
  if ! running "$pid"; then
    echo "The export stopped when it got HUP, the signal closing a terminal sends. Start it with nohup in front."
    return 1
  fi
}

@test "12) the export's output goes to export.log" {
  start_export
  sleep 1
  if ! grep -q "Exported frame" "$T/run/export.log" 2>/dev/null; then
    echo "export.log doesn't have the export's lines in it. Send its output there with > export.log 2>&1."
    return 1
  fi
  if [[ "$output" == *"Exported frame"* ]]; then
    echo "The export's lines are showing in the terminal too. Send them all into export.log."
    return 1
  fi
}
