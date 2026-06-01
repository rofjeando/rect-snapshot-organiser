#!/bin/bash
# rect_focus_keynote_student.sh
# Finds the Keynote window containing the student surname (from snag_imageName)
# and focuses it via AeroSpace, making it the front document for AppleScript.
# Reads KMVAR_snag_imageName from environment.

AEROSPACE="/opt/homebrew/bin/aerospace"

# Extract surname: YYYYMMDD_SurnameFirstname-session_no → Surname
SURNAME=$(echo "$KMVAR_snag_imageName" | /usr/bin/sed 's/^[0-9]*_\([A-Za-z]*\).*/\1/')

if [ -z "$SURNAME" ]; then
    echo "ERROR: could not extract surname from snag_imageName=$KMVAR_snag_imageName" >&2
    exit 1
fi

# Search all workspaces for a Keynote window containing the surname
for ws in $("$AEROSPACE" list-workspaces --all); do
    result=$("$AEROSPACE" list-windows --workspace "$ws" --json 2>/dev/null \
        | /usr/bin/python3 -c "
import json, sys
try:
    windows = json.load(sys.stdin)
    for w in windows:
        if w.get('app-name') == 'Keynote' and '$SURNAME' in w.get('window-title', ''):
            print(w['window-id'])
            break
except Exception:
    pass
" 2>/dev/null)
    if [ -n "$result" ]; then
        "$AEROSPACE" workspace "$ws"
        sleep 0.2
        "$AEROSPACE" focus --window-id "$result"
        sleep 0.2
        exit 0
    fi
done

echo "ERROR: No Keynote window found containing surname: $SURNAME" >&2
exit 1
