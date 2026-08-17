#!/bin/bash
# Apply SpaceX identity (icons, D-DIN, Plex Mono) after a theme change.
[[ ${1:-} == spacex ]] || exit 0
SCRIPT="$HOME/.config/omarchy/themes/spacex/apply-identity.sh"
[[ -x $SCRIPT ]] && exec "$SCRIPT"
