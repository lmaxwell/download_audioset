#!/bin/bash

SAMPLE_RATE=22050

# fetch_clip(videoID, startTime, endTime)
fetch_clip() {
  echo "Fetching $1 ($2 to $3)..."
  outname="id_$1_$2_$3"
  if [ -f "${outname}.wav" ]; then
    echo "Already have it."
    return
  fi

  youtube-dl https://youtube.com/watch?v=$1 \
    --quiet --extract-audio --audio-format wav \
    --output "$outname.%(ext)s"
  if [ $? -eq 0 ]; then
    # If we don't pipe `yes`, ffmpeg seems to steal a
    # character from stdin. I have no idea why.
	#  -ar $SAMPLE_RATE \

    yes | ffmpeg -loglevel quiet -i "./$outname.wav" -ss "$2" -to "$3" "./${outname}_out.wav"
    mv "./${outname}_out.wav" "./$outname.wav"
    #gzip "./$outname.wav"
    sleep 1
  else
    # Give the user a chance to Ctrl+C.
    sleep 1
  fi
}

grep -E '^[^#]' | while read line
do
  fetch_clip $(echo "$line" | sed -E 's/, / /g')
done
