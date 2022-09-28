#!/bin/bash

if [ "$1" == "" ]; then
  echo "Usage: $0 [file_to_convert.pcm]"
  exit
fi

ffmpeg -f s16le -ar 48k -ac 1 -i "$1" "${1%.*}.wav"
