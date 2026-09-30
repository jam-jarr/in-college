#!/usr/bin/env sh

set -eux

FILE="./InCollege.cob"
PATTERN="WS-INPUT-MODE PIC X"

# Toggle 'F' <-> 'C' on that line
if grep -q "$PATTERN.*VALUE 'F'" "$FILE"; then
    FROM="'F'"; TO="'C'"
elif grep -q "$PATTERN.*VALUE 'C'" "$FILE"; then
    FROM="'C'"; TO="'F'"
else
    echo "Error: unexpected value on '$PATTERN' line." >&2
    exit 1
fi

sed -i "/$PATTERN/s/VALUE $FROM/VALUE $TO/" "$FILE"
