#!/usr/bin/env bash
# stop-politely.sh: stops one process the polite way first, and the hard way only if it must.
#
# Usage:   ./stop-politely.sh PID
# Example: ./stop-politely.sh 4242
#
# What it must do:
#   1. With no PID, print this line on standard error and stop with exit code 2:
#        Usage: stop-politely.sh PID
#   2. If no process with that PID is running, print this line and stop with exit code 1:
#        No process 4242 is running.
#   3. Send the process TERM, and print:
#        Sent TERM to 4242.
#   4. Check once a second, for up to 5 seconds, whether it's still running. As soon as
#      it's gone, print this line and stop with exit code 0:
#        4242 stopped.
#   5. If it's still running after 5 seconds, send it KILL, print this line, and stop
#      with exit code 0:
#        4242 ignored TERM. Sent KILL.
#
# ps -p PID succeeds (exit code 0) only while a process with that PID is running.
#
# Write your script under this line.
