#!/bin/bash

for file in *.mkv; do
  echo $file

  # ffmpeg -itsoffset -9 -i "$file" -c copy "${file%%.*}-fixed.srt"

  ffmpeg -i "$file" -map '0:v' -map '0:2' -map '0:s' -c:v copy -c:a copy -c:s copy "japanese-$file"

  mv "$file" "english-$file"

  mv "japanese-$file" "$file"

  # echo ${file%%.*}
done
