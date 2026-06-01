#!/bin/bash
# rect_focus_afdesign.sh
# Switches to the AeroSpace workspace where Affinity Designer 2 was found at startup,
# then focuses its specific window by ID.
# Reads KM variables via environment: KMVAR_rect_afDesignWorkspace, KMVAR_rect_afDesignWindowId

AEROSPACE="/opt/homebrew/bin/aerospace"

WORKSPACE="${KMVAR_rect_afDesignWorkspace}"
WINDOW_ID="${KMVAR_rect_afDesignWindowId}"

if [ -z "$WORKSPACE" ] || [ -z "$WINDOW_ID" ]; then
    exit 1
fi

"$AEROSPACE" workspace "$WORKSPACE"
sleep 0.15
"$AEROSPACE" focus --window-id "$WINDOW_ID"
