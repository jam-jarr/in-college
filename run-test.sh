#!/usr/bin/env bash

# Test runner:
#   1) pick a test-case environment from test-cases/ (choose 1-N subdir)
#   2) copy every *.txt file from that subdir into the project base
#      (InCollege-Input.txt, accounts.txt, connections.txt, ...) so the
#      environment is identical each run
#   3) docker compose up (builds + runs; blocks until the program exits)
#   4) copy InCollege-Output.txt into the subdir as <name>.out

cd "$(dirname "$0")"

# Only subdirectories count as test cases (their *.out files are skipped by
# the *.txt glob, so they never pollute the environment copy).
CASES=()
for dir in test-cases/*/; do
    [ -d "$dir" ] || continue
    CASES+=("${dir%/}") # strip trailing slash
done
N="${#CASES[@]}"

if [ "$N" -eq 0 ]; then
    echo "No test-case subdirectories found in test-cases/." >&2
    exit 1
fi

echo "Choose a test case (1-$N):"
PS3="Selection: "
select CASE in "${CASES[@]}"; do
    if [ -n "$CASE" ]; then
        break
    fi
    echo "Invalid choice; pick a number 1-$N." >&2
done

NAME="$(basename "$CASE")"

echo ">>> Loading environment from $CASE ..."
for f in "$CASE"/*.txt; do
    [ -f "$f" ] || continue
    cp "$f" .
    echo "    $(basename "$f")"
done

echo ">>> docker compose up (building + running)..."
sudo docker compose up

echo ">>> Copying output..."
cp InCollege-Output.txt "$CASE/$NAME.out"
echo ">>> Done: $CASE/$NAME.out"