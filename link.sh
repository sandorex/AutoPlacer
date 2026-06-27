#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# get version from info.json
version="$(awk -F'"' '/"version": ".+"/ { print $4; exit; }' info.json)"

# check if version was sucessfully read
if [[ -z "$version" ]]; then
    echo "Version could not be detected in 'info.json'"
    exit 1
fi

LINK_PATH="$HOME/.factorio/mods/autoplacer_$version"

if [[ -e "$LINK_PATH" ]]; then
    echo "Removing dev symlink (in ~/.factorio/mods/)"
    rm "$LINK_PATH"
else
    echo "Creating dev symlink (in ~/.factorio/mods/)"
    ln -s "$PWD/" "$LINK_PATH"
fi
