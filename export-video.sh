#!/usr/bin/env bash
# export-video.sh: pretends to export a vacation video, one frame a second, for ten minutes.
# This is the job you want to keep running. You don't need to change this file.
for frame in {1..600}; do
  echo "Exported frame $frame of 600"
  sleep 1
done
echo "Done: vacation.mp4"
