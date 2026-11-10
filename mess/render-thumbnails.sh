#!/usr/bin/env bash
# render-thumbnails.sh: a photo-thumbnail maker stuck in a loop. It works as hard as it
# can and gets nowhere. In case you forget it, it gives up by itself after 30 minutes.
end=$((SECONDS + 1800))
while (( SECONDS < end )); do
  :
done
