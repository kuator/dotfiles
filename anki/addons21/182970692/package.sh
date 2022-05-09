#!/usr/bin/env sh

readonly root_dir=$(git rev-parse --show-toplevel)
readonly zip_name="browser_play_button_$(git branch --show-current).ankiaddon"

cd -- "$root_dir" || exit 1
rm -- "$zip_name" 2>/dev/null
git archive HEAD --format=zip -o "$zip_name"
(cd -- ajt_common && git archive HEAD --prefix="${PWD##*/}/" --format=zip -o "$root_dir/${PWD##*/}.zip")
zipmerge "$zip_name" ./*.zip
rm -- ./*.zip
