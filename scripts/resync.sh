#!/bin/bash

for file in *.srt; do
  echo $file

  ffmpeg -itsoffset -20 -i "$file" -c copy "${file%%.*}-fixed.srt"

  # cp "$file" "${file%%.*}-delayed.srt"

  # echo ${file%%.*}
done
