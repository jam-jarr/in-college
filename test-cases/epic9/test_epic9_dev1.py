#!/usr/bin/env python3
"""Compile and test Epic 9 Developer 1's message-viewing feature in isolation.

Run from the repository root with:
    python3 ../epic9dev1/test_epic9_dev1.py --repo .

Requires GNU COBOL (cobc). This script never overwrites real project data.
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def check(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def test_result(case: str, stdout: str) -> None:
    check("--- Your Messages ---" in stdout, f"{case}: inbox heading missing")
    check("View My Messages is under construction." not in stdout,
          f"{case}: old placeholder still displayed")
    check(stdout.count("--- Messages Menu ---") >= 2,
          f"{case}: did not return to Messages menu")
    check(stdout.count("8. Logout") >= 2,
          f"{case}: did not return to main menu")
    check("Unable to read messages" not in stdout and
          "Unable to read all messages" not in stdout,
          f"{case}: unexpected read failure")

    if case == "01-no-messages":
        check("You have no messages at this time." in stdout,
              f"{case}: no-message status missing")
        check("From:" not in stdout, f"{case}: incorrectly displayed another user's message")
        check("This should not show" not in stdout,
              f"{case}: other recipient's private message leaked")
    elif case == "02-one-message":
        check(stdout.count("From:") == 1, f"{case}: expected one message")
        for expected in ("From: user2", "Message: Please review my resume.",
                         "Sent: 2026-11-22 10:05:00"):
            check(expected in stdout, f"{case}: missing {expected!r}")
    elif case == "03-multiple-senders":
        check(stdout.count("From:") == 3, f"{case}: expected three messages")
        check(stdout.count("From: user2") == 2, f"{case}: expected two from user2")
        check(stdout.count("From: searchtarget") == 1,
              f"{case}: expected one from searchtarget")
        check("NOT for user inbox." not in stdout,
              f"{case}: private message leaked to wrong recipient")
        expected = ("Message: Hello from user2.",
                    "Message: Hello from searchtarget.",
                    "Message: Following up on my earlier message.")
        positions = [stdout.find(x) for x in expected]
        check(all(x >= 0 for x in positions) and positions == sorted(positions),
              f"{case}: messages missing or wrong order")
    else:
        raise AssertionError(f"Unrecognized test: {case}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", default=".", help="Path to the InCollege repo")
    args = parser.parse_args()
    repo = Path(args.repo).resolve()
    fixtures = repo / "test-cases" / "epic9"

    if shutil.which("cobc") is None:
        print("ERROR: GNU COBOL (cobc) is unavailable. Reopen the repo in its ",
              "VS Code Dev Container and run again.", file=sys.stderr)
        return 2
    if not (repo / "ViewMessages.cob").is_file() or not fixtures.is_dir():
        print("ERROR: First apply the Epic 9 Developer 1 changes.", file=sys.stderr)
        return 2

    with tempfile.TemporaryDirectory(prefix="epic9dev1-tests-") as scratch:
        root = Path(scratch)
        binary = root / "InCollege"
        command = ["cobc", "-x", "-I", str(repo), "-o", str(binary),
                   str(repo / "InCollege.cob")]
        print("Compiling the combined code...")
        build = subprocess.run(command, cwd=repo, text=True,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if build.returncode:
            print(build.stdout, file=sys.stderr)
            return build.returncode
        print("COBOL compilation: PASS")

        for case in ("01-no-messages", "02-one-message", "03-multiple-senders"):
            scenario = root / case
            scenario.mkdir()
            for fixture in (fixtures / case).glob("*.txt"):
                shutil.copyfile(fixture, scenario / fixture.name)

            original = (scenario / "messages.txt").read_bytes()
            repeat = 2 if case == "02-one-message" else 1
            for iteration in range(1, repeat + 1):
                run = subprocess.run([str(binary)], cwd=scenario, timeout=20,
                                     stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                check(run.returncode == 0, f"{case}: runtime error: {run.stderr!r}")
                output_path = scenario / "InCollege-Output.txt"
                check(output_path.exists(), f"{case}: program output file missing")
                output = output_path.read_bytes()
                check(run.stdout == output,
                      f"{case}: console output differs from InCollege-Output.txt")
                check((scenario / "messages.txt").read_bytes() == original,
                      f"{case}: message store was modified while viewing")
                test_result(case, run.stdout.decode("utf-8", errors="replace"))
            print(f"{case}: PASS" + (" (including restart)" if repeat == 2 else ""))

    print("All 3 Epic 9 Developer 1 scenarios passed: output identity, privacy, ",
          "menu navigation, and persistence.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, OSError, subprocess.TimeoutExpired) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
