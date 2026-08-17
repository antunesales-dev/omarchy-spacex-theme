#!/bin/bash
# Apply or undo SpaceX identity after a theme change.
SCRIPT="$HOME/.config/omarchy/themes/spacex/apply-identity.sh"
[[ -x $SCRIPT ]] && exec "$SCRIPT" "$@"
