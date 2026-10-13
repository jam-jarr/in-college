#!/usr/bin/env bash
#
# rotate-roles.sh - Rotate the roles in Roles.txt down by one position.
#
# Each person takes the role of the person above them; the first role
# wraps around to the last person. The "Week N:" header is incremented.
#
# Usage: ./rotate-roles.sh [file]   (defaults to Roles.txt)

set -euo pipefail

FILE="${1:-Roles.txt}"

if [[ ! -f "$FILE" ]]; then
  echo "Error: file not found: $FILE" >&2
  exit 1
fi

mapfile -t lines < "$FILE"

# --- Increment the week number in the header line, if present ---
header="${lines[0]}"
if [[ "$header" =~ ([0-9]+) ]]; then
  week="${BASH_REMATCH[1]}"
  header="${header//$week/$((week + 1))}"
fi

# --- Collect names and roles ---
names=()
roles=()
for line in "${lines[@]:1}"; do
  [[ -z "${line// }" ]] && continue          # skip blank lines
  names+=("${line%%:*}")                       # e.g. "Giarratana, Jamie"
  roles+=("${line#*: }")                       # e.g. "Tester #1"
done

count=${#roles[@]}
if (( count == 0 )); then
  echo "Error: no role entries found in $FILE" >&2
  exit 1
fi

# --- Write the rotated file ---
{
  echo "$header"
  for (( i = 0; i < count; i++ )); do
    j=$(( (i + 1) % count ))                   # rotate roles down, wrapping around
    echo "${names[i]}: ${roles[j]}"
  done
} > "$FILE"

echo "Rotated roles in $FILE ($header):"
cat "$FILE"
