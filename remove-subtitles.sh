#!/bin/bash

for file in **/*.mkv; do

  tmp="$file.mkv"
  ffmpeg -i "$file" -c copy -sn "$tmp"
  rm "$file"
  mv "$tmp" "$file"

done
