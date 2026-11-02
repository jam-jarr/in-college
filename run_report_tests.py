#!/usr/bin/env python3
"""Small functional tests for the Week 7 job application report, using GnuCOBOL.

Tests zero, one, multiple, duplicate, cross-user, and persisted applications,
including console vs output-file equality. Does not modify project data files.
"""
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile


def job(job_id, poster, title, description, employer, location, salary):
    values = [(f"{job_id:06d}", 6), (poster, 20), (title, 50),
              (description, 200), (employer, 50), (location, 50), (salary, 40)]
    return "".join(value.ljust(width) for value, width in values)


def event(username, job_id, code):
    return f"{username:<20}{job_id:06d}{code}"


def run(binary, folder, events, label, count, titles):
    (folder / "saved-jobs.txt").write_text("\n".join(events) + "\n", encoding="utf-8")
    (folder / "InCollege-Input.txt").write_text(
        "1\nuser\nPassword1!\n3\n5\n3\n6\n", encoding="utf-8")
    result = subprocess.run([str(binary)], cwd=folder, text=True,
                            capture_output=True, timeout=15)
    assert result.returncode == 0, f"{label}: program failed: {result.stderr}"
    output = (folder / "InCollege-Output.txt").read_text(encoding="utf-8")
    assert result.stdout.splitlines() == output.splitlines(), \
        f"{label}: console and file outputs do not match"
    assert "--- Your Job Applications ---" in output, label
    assert f"Total Applications: {count}" in output, label
    for title, expected in titles.items():
        assert (f"Job Title: {title}" in output) == expected, (label, title)
    print("PASS", label)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".", help="Path to InCollege repository")
    repo = Path(parser.parse_args().repo).resolve()
    compiler = shutil.which("cobc")
    if compiler is None:
        raise SystemExit("GnuCOBOL (cobc) is not installed here; run inside your dev container.")
    with tempfile.TemporaryDirectory(prefix="week7-report-") as temp:
        tempdir = Path(temp)
        binary = tempdir / "InCollege"
        build = subprocess.run([compiler, "-x", "-I", str(repo), "-o", str(binary),
                               str(repo / "InCollege.cob")], cwd=repo,
                               text=True, capture_output=True)
        assert build.returncode == 0, f"compile failed:\n{build.stderr}"
        for name in ("accounts.txt", "profiles.txt", "connections.txt"):
            source = repo / name
            if source.is_file() and name != "accounts.txt":
                shutil.copyfile(source, tempdir / name)
            elif name == "accounts.txt":
                (tempdir / name).write_text(f"{'user':<20}Password1!\n", encoding="utf-8")
            else:
                (tempdir / name).write_text("", encoding="utf-8")
        (tempdir / "jobs.txt").write_text("\n".join([
            job(1, "user", "Software Intern", "Develop software", "TechCorp", "Remote", "$25/hr"),
            job(2, "user2", "Data Analyst", "Analyze data", "DataSolutions", "Tampa", ""),
            job(3, "user", "Marketing Intern", "Create campaigns", "BrandInc", "Orlando", ""),
        ]) + "\n", encoding="utf-8")
        titles = {"Software Intern": False, "Data Analyst": False, "Marketing Intern": False}
        run(binary, tempdir, [], "zero applications", 0, titles)
        titles["Software Intern"] = True
        run(binary, tempdir, [event("user", 1, "A"), event("user2", 2, "A"),
                              event("user", 3, "S")], "one and user isolation", 1, titles)
        titles["Marketing Intern"] = True
        multi = [event("user", 1, "A"), event("user", 1, "A"),
                 event("user2", 2, "A"), event("user", 3, "S"), event("user", 3, "A")]
        run(binary, tempdir, multi, "multiple, duplicate, saved-only ignored", 2, titles)
        run(binary, tempdir, multi, "persisted across restart", 2, titles)
    print("All Week 7 application report tests passed.")


if __name__ == "__main__":
    main()
