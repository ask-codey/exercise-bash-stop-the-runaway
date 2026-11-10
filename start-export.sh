#!/usr/bin/env bash
# start-export.sh: starts the video export so that it keeps going after you close the
# terminal.
#
# Usage:   ./start-export.sh
#
# What it must do:
#   1. Start ./export-video.sh in the background, so this script finishes at once.
#   2. Make the export ignore the hang-up signal (HUP) that closing the terminal sends.
#   3. Send the export's output, and its errors, into export.log.
#   4. Save the export's PID in export.pid, and print:
#        Started the export: PID 4242
#
# The first line below makes the script work from its own folder, wherever you run it from.
cd "$(dirname "$0")" || exit 1

# Write your script under this line.
