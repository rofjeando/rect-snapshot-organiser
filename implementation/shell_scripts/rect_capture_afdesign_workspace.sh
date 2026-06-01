#!/bin/bash
# rect_capture_afdesign_workspace.sh
# Finds which AeroSpace workspace Affinity Designer 2 is on and its window-id.
# Outputs two lines: workspace_name\nwindow_id
# Used by KM to store rect_afDesignWorkspace and rect_afDesignWindowId.

AEROSPACE="/opt/homebrew/bin/aerospace"

for ws in $("$AEROSPACE" list-workspaces --all); do
    result=$("$AEROSPACE" list-windows --workspace "$ws" --json 2>/dev/null \
        | /usr/bin/python3 -c "
import json, sys
try:
    windows = json.load(sys.stdin)
    for w in windows:
        if 'Affinity Designer' in w.get('app-name', ''):
            print('$ws')
            print(w['window-id'])
            break
except Exception:
    pass
" 2>/dev/null)
    if [ -n "$result" ]; then
        echo "$result"
        exit 0
    fi
done

# Fallback: not found
exit 1
