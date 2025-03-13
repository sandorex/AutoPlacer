#!/usr/bin/env bash
# basic packaging script

set -euo pipefail

# ensure cwd is the root of repository
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# get version from info.json
version="$(awk -F'"' '/"version": ".+"/ { print $4; exit; }' info.json)"

# check if version was sucessfully read
if [[ -z "$version" ]]; then
    echo "Version could not be detected in 'info.json'"
    exit 1
fi

echo "Packaging mod version '${version}'"

# package using git (ignore files in .gitattributes)
git archive HEAD --prefix=AutoPlacer/ -o "autoplacer_${version}.zip"

echo "Done!"
