#!/usr/bin/env bash

# Submission packager:
#   pick an epic from test-cases/ (choose 1-N), then for every test case in
#   that epic this script builds two zip archives:
#
#     EpicX-Storyx-Test-Input.zip   containing  <test>-Input.txt
#     EpicX-Storyx-Test-Output.zip  containing  <test>-Output.txt
#
# Inputs come from each test case's InCollege-Input.txt, outputs from its
# *.out file. Each file is renamed after its test case.

cd "$(dirname "$0")"

# --- level 1: pick an epic ------------------------------------------------
EPICS=()
for d in test-cases/*/; do
    [ -d "$d" ] || continue
    EPICS+=("${d%/}") # strip trailing slash
done
N_EPICS="${#EPICS[@]}"

if [ "$N_EPICS" -eq 0 ]; then
    echo "No epic directories found in test-cases/." >&2
    exit 1
fi

echo "Choose an epic to package (1-$N_EPICS):"
PS3="Epic: "
select EPIC in "${EPICS[@]}"; do
    if [ -n "$EPIC" ]; then
        break
    fi
    echo "Invalid choice; pick a number 1-$N_EPICS." >&2
done
if [ -z "$EPIC" ]; then
    echo "No epic selected (input ended)." >&2
    exit 1
fi
EPIC_NAME="$(basename "$EPIC")"

# Derive the "EpicX" part of the archive name from the digits in the epic
# dir name (epic4 -> Epic4). Defaults to the capitalized dir name if no
# digits are found.
if [[ "$EPIC_NAME" =~ ([0-9]+) ]]; then
    EPIC_NUM="${BASH_REMATCH[1]}"
    ARCHIVE_BASE="Epic${EPIC_NUM}-Storyx-Test"
else
    ARCHIVE_BASE="$(tr '[:lower:]' '[:upper:]' <<< "${EPIC_NAME:0:1}")${EPIC_NAME:1}-Storyx-Test"
fi
INPUT_ZIP="${ARCHIVE_BASE}-Input.zip"
OUTPUT_ZIP="${ARCHIVE_BASE}-Output.zip"

# --- gather the test cases -------------------------------------------------
TESTS=()
for d in "$EPIC"/*/; do
    [ -d "$d" ] || continue
    TESTS+=("${d%/}")
done
N_TESTS="${#TESTS[@]}"

if [ "$N_TESTS" -eq 0 ]; then
    echo "No test cases found in $EPIC." >&2
    exit 1
fi

# --- build the archive contents (flat, no subdirectories) -------------------
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo
echo ">>> Packaging $ARCHIVE_BASE from epic $EPIC_NAME ($N_TESTS test cases)..."

n_in=0; n_out=0
for t in "${TESTS[@]}"; do
    name="$(basename "$t")"

    # input: test case's InCollege-Input.txt -> <test>-Input.txt
    if [ -f "$t/InCollege-Input.txt" ]; then
        cp "$t/InCollege-Input.txt" "$WORK/${name}-Input.txt"
        echo "  [in ] $name -> ${name}-Input.txt"
        n_in=$(( n_in + 1 ))
    else
        echo "  [warn] no InCollege-Input.txt in $t"
    fi

    # output: every *.out in the test case -> <test>-Output.txt
    # (if a test case holds several .out files, keep each basename)
    outs=( "$t"/*.out )
    for f in "${outs[@]}"; do
        [ -f "$f" ] || continue
        stem="$(basename "$f" .out)"
        if [ "${#outs[@]}" -eq 1 ]; then
            dest="${name}-Output.txt"
        else
            dest="${name}-${stem}-Output.txt"
        fi
        cp "$f" "$WORK/$dest"
        echo "  [out] $name -> $dest"
        n_out=$(( n_out + 1 ))
    done
done

# --- zip them up (flat) ------------------------------------------------------
echo
echo ">>> Zipping..."
( cd "$WORK" && zip -q "$OLDPWD/$INPUT_ZIP" ./*-Input.txt )
( cd "$WORK" && zip -q "$OLDPWD/$OUTPUT_ZIP" ./*-Output.txt )

echo ">>> Wrote $PWD/$INPUT_ZIP ($n_in inputs)"
echo ">>> Wrote $PWD/$OUTPUT_ZIP ($n_out outputs)"
echo ">>> Done."