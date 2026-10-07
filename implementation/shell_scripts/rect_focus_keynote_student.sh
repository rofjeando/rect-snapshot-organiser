#!/bin/bash
# rect_focus_keynote_student.sh
# Makes the Keynote deck of the student named in snag_imageName the front document
# in AeroSpace workspace K (called by KM macro "Keynote insert listImage3screens").
#
# Input:  KMVAR_snag_imageName, e.g. "20261007_AlexiKaruna's 1stb_1"  (YYYYMMDD_FirstLast...)
# Deck names: {Base}{N}_Student[.key], {Base}_Student{N}[.key], {Base}_Student[.key] (= 1),
#   Base = FirstLast with spaces removed (apostrophes/hyphens kept).
# A deck matches when the text after "YYYYMMDD_" starts with its Base (case-insensitive);
# the longest Base wins, then the highest ordinal. Names are never cut at a hyphen or
# apostrophe, so "Kevin-DMackay" cannot match another "Kevin".
# Steps: find the matching Keynote window on any workspace (open the newest deck from
#   StudentsKeynote if none is open), move it to K, focus it, then store the deck's
#   window title in KM variable rect_targetDeck so the AppleScript can verify the
#   front document before inserting images.
# Exit 1 with a message on stderr if no deck/window is found.

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

AS=/opt/homebrew/bin/aerospace
KEYNOTE_DIR="/Users/tsukadjed/Library/CloudStorage/Dropbox/SlideShows_keynote/StudentsKeynote"
NAME_RE="^(.*[^0-9])([0-9]*)_Student([0-9]*)(\.[Kk][Ee][Yy])?$"

set_target() {
    /usr/bin/osascript - "$1" <<'APPLESCRIPT' >/dev/null 2>&1
on run argv
	tell application "Keyboard Maestro Engine" to setvariable "rect_targetDeck" to (item 1 of argv)
end run
APPLESCRIPT
}

set_target ""

# Text after "YYYYMMDD_" (or the whole name if there is no date prefix)
REST=$(printf '%s' "$KMVAR_snag_imageName" | /usr/bin/sed -E 's/^[0-9]+_//')
if [ -z "$REST" ]; then
    echo "ERROR: snag_imageName is empty or has no student name: '$KMVAR_snag_imageName'" >&2
    exit 1
fi
REST_LC=$(printf '%s' "$REST" | tr '[:upper:]' '[:lower:]')

# Does deck title $1 belong to the student? Prints "baselength ordinal" if so.
match_title() {
    local title="$1" base ord lc
    [[ "$title" =~ $NAME_RE ]] || return 1
    base="${BASH_REMATCH[1]}"
    ord="${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
    ord=$((10#${ord:-1}))
    lc=$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')
    [[ "$REST_LC" == "$lc"* ]] || return 1
    echo "${#base} $ord"
}

# Best Keynote window across all workspaces
best_window() {
    local best_id="" best_title="" best_len=0 best_ord=0 wid ws title res len ord
    while IFS='|' read -r wid ws title; do
        res=$(match_title "$title") || continue
        len=${res% *}
        ord=${res#* }
        if [ "$len" -gt "$best_len" ] || { [ "$len" -eq "$best_len" ] && [ "$ord" -gt "$best_ord" ]; }; then
            best_len=$len
            best_ord=$ord
            best_id=$wid
            best_title=$title
        fi
    done < <("$AS" list-windows --monitor all --app-bundle-id com.apple.Keynote \
        --format '%{window-id}|%{workspace}|%{window-title}')
    [ -n "$best_id" ] && echo "$best_id|$best_title"
}

FOUND=$(best_window)

if [ -z "$FOUND" ]; then
    # No window: open the student's newest deck from StudentsKeynote
    DECK=""
    MAX=0
    BEST_LEN=0
    for f in "$KEYNOTE_DIR"/*.key; do
        [ -e "$f" ] || continue
        n=$(basename "$f")
        res=$(match_title "$n") || continue
        len=${res% *}
        ord=${res#* }
        if [ "$len" -gt "$BEST_LEN" ] || { [ "$len" -eq "$BEST_LEN" ] && [ "$ord" -gt "$MAX" ]; }; then
            BEST_LEN=$len
            MAX=$ord
            DECK="$f"
        fi
    done
    if [ -z "$DECK" ]; then
        echo "ERROR: no Keynote deck found for '$REST' in $KEYNOTE_DIR" >&2
        exit 1
    fi
    open -b com.apple.Keynote "$DECK"
    for _ in {1..30}; do
        sleep 0.5
        FOUND=$(best_window)
        [ -n "$FOUND" ] && break
    done
fi

if [ -z "$FOUND" ]; then
    echo "ERROR: no Keynote window appeared for '$REST'" >&2
    exit 1
fi

WID=${FOUND%%|*}
TITLE=${FOUND#*|}

"$AS" move-node-to-workspace --window-id "$WID" K
"$AS" workspace K
sleep 0.2
"$AS" focus --window-id "$WID"
sleep 0.2

set_target "$TITLE"
echo "$TITLE"
