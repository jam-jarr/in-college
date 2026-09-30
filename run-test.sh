#!/usr/bin/env bash

# Test runner (epic -> test case, or run the whole epic):
#   1) pick an epic from test-cases/ (choose 1-N)
#   2) pick one test case in that epic, or run them all
#   3) for each test: copy every *.txt from test-cases/<epic>/<test>/ into the
#      project base, docker compose up, then save InCollege-Output.txt as
#      test-cases/<epic>/<test>/<test>.out

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

echo "Choose an epic (1-$N_EPICS):"
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

# --- level 2: pick a test case, or all -------------------------------------
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

ALL_LABEL="Run ALL test cases in $EPIC_NAME"
N_ALL=$(( N_TESTS + 1 ))
echo "Choose a test case (1-$N_TESTS), or $N_ALL = $ALL_LABEL:"
PS3="Test: "
select TEST in "${TESTS[@]}" "$ALL_LABEL"; do
    # selecting the trailing "all" option by its number must be checked
    # before TEST, because select sets TEST to the option's label word too.
    if [ -n "$REPLY" ] && [ "$REPLY" -eq "$N_ALL" ] 2>/dev/null; then
        MODE=all
        break
    fi
    if [ -n "$TEST" ] && [ "$TEST" != "$ALL_LABEL" ]; then
        MODE=one
        break
    fi
    echo "Invalid choice; pick a number 1-$N_ALL." >&2
done
if [ -z "$MODE" ]; then
    echo "No test case selected (input ended)." >&2
    exit 1
fi

# --- one test -----------------------------------------------------------------
run_test() {
    local dir="$1" name
    name="$(basename "$dir")"

    echo
    echo ">>> [$name] Loading environment from $dir ..."
    for f in "$dir"/*.txt; do
        [ -f "$f" ] || continue
        cp "$f" .
    done

    echo ">>> [$name] docker compose up (building + running)..."
    sudo docker compose up

    echo ">>> [$name] Copying output..."
    cp InCollege-Output.txt "$dir/$name.out"
    echo ">>> [$name] Done: $dir/$name.out"
}

# --- run -----------------------------------------------------------------------
if [ "$MODE" = all ]; then
    echo
    echo ">>> Running all $N_TESTS test cases in $EPIC_NAME ..."
    for t in "${TESTS[@]}"; do
        run_test "$t"
    done
    echo
    echo ">>> Finished all test cases in $EPIC_NAME."
else
    run_test "$TEST"
fi