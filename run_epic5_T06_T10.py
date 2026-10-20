#!/usr/bin/env python3
"""Run T06-T10 in isolated temporary directories; do not change project data."""
from pathlib import Path
import subprocess
import tempfile
import shutil
import sys

ROOT = Path.cwd()
INPUTS = ROOT / 'Epic5-Test-Inputs'
OUTPUTS = ROOT / 'Epic5-Test-Outputs'
BACKUP = ROOT / 'epic5-testing' / 'backup'
PROGRAM = ROOT / 'epic5-testing' / 'workspace' / 'InCollege'

for path in (INPUTS, OUTPUTS, BACKUP / 'accounts.txt', BACKUP / 'profiles.txt', PROGRAM):
    if not path.exists():
        sys.exit(f'MISSING: {path} — run this script from /workspaces/in-college')

INPUTS.mkdir(exist_ok=True)
OUTPUTS.mkdir(exist_ok=True)


def records(rows):
    return ''.join(f'{sender:<20}{recipient:<20}{status}\n' for sender, recipient, status in rows)


def get_records(path):
    result = []
    for line in path.read_text().splitlines():
        if not line.strip():
            continue
        result.append((line[0:20].strip(), line[20:40].strip(), line[40:41]))
    return result


def run_case(work, label, input_text):
    input_file = INPUTS / (label + '-Input.txt')
    console_file = OUTPUTS / (label + '-Output.txt')
    program_output = OUTPUTS / (label + '-Program-Output.txt')
    input_file.write_text(input_text)
    (work / 'InCollege-Input.txt').write_text(input_text)
    result = subprocess.run([str(PROGRAM)], cwd=work, capture_output=True, timeout=20)
    console_file.write_bytes(result.stdout)
    actual_output = work / 'InCollege-Output.txt'
    program_output.write_bytes(actual_output.read_bytes() if actual_output.exists() else b'')
    output = result.stdout.decode('utf-8', errors='replace')
    checks = [
        ('program exited successfully', result.returncode == 0),
        ('console equals output file', result.stdout == program_output.read_bytes()),
    ]
    if result.stderr:
        (OUTPUTS / (label + '-Stderr.txt')).write_bytes(result.stderr)
    return output, checks


def starting_dir(tmp, name, rows):
    work = Path(tmp) / name
    work.mkdir()
    shutil.copy2(BACKUP / 'accounts.txt', work / 'accounts.txt')
    shutil.copy2(BACKUP / 'profiles.txt', work / 'profiles.txt')
    (work / 'connections.txt').write_text(records(rows))
    (INPUTS / (name + '-Setup.txt')).write_text(records(rows))
    return work


def assert_status(work, expected):
    return get_records(work / 'connections.txt') == expected

LOGIN = '1\nsearchtarget\nPassword1!\n'
CHECK_PENDING = LOGIN + '7\n6\n'
REQUEST_AGAIN = '1\nuser2\nPassword1!\n4\nJordan Smith\n1\n6\n'
P2 = [('user', 'searchtarget', 'P'), ('user2', 'searchtarget', 'P')]
REPORT = []


def report(name, checks):
    good = all(ok for _, ok in checks)
    REPORT.append((name, good, checks))
    print(f"{'PASS' if good else 'FAIL'} {name}")
    for description, ok in checks:
        if not ok:
            print('   FAILED:', description)


with tempfile.TemporaryDirectory(prefix='epic5-batch-') as tmp:
    # T06: reject multiple incoming requests, verify removal after restart
    w = starting_dir(tmp, 'T06-Reject-Multiple', P2)
    out, checks = run_case(w, 'T06-Reject-Multiple', LOGIN + '7\n2\n2\n6\n')
    checks += [('both rejection confirmations', all(s in out for s in [
        'Connection request from user rejected!',
        'Connection request from user2 rejected!'])),
        ('both records rejected', assert_status(w, [('user','searchtarget','R'),('user2','searchtarget','R')]))]
    _, more = run_case(w, 'T06-Reject-Multiple-Restart', CHECK_PENDING)
    checks += more + [('no requests after restart', 'You have no pending connection requests' in (OUTPUTS/'T06-Reject-Multiple-Restart-Output.txt').read_text())]
    report('T06 multiple rejection', checks)

    # T07: block previously rejected sender after restarting
    rejected = [('user2','searchtarget','R')]
    w = starting_dir(tmp, 'T07-Reattempt-After-Restart', rejected)
    before = (w/'connections.txt').read_bytes()
    out, checks = run_case(w, 'T07-Reattempt-After-Restart', REQUEST_AGAIN)
    checks += [('blocked message displayed', 'You cannot send another request to this user.' in out),
               ('no records added or modified', (w/'connections.txt').read_bytes() == before)]
    report('T07 blocked reattempt after restart', checks)

    # T08: mixed accept first, reject second
    w = starting_dir(tmp, 'T08-Mixed-Accept-Reject', P2)
    out, checks = run_case(w, 'T08-Mixed-Accept-Reject', LOGIN + '7\n1\n2\n6\n')
    mixed = [('user','searchtarget','C'),('user2','searchtarget','R')]
    checks += [('accepted user confirmation', 'Connection request from user accepted!' in out),
               ('rejected user2 confirmation', 'Connection request from user2 rejected!' in out),
               ('correct mixed persistent statuses', assert_status(w, mixed))]
    report('T08 mixed accept/reject', checks)

    # T09: mixed scenario, restart, and inspect state and pending list
    w = starting_dir(tmp, 'T09-Mixed-Restart', P2)
    out, checks = run_case(w, 'T09-Mixed-Restart-Action', LOGIN + '7\n1\n2\n6\n')
    checks += [('initial mixed state saved', assert_status(w, mixed))]
    out, more = run_case(w, 'T09-Mixed-Restart-Verify', CHECK_PENDING)
    checks += more + [('still no pending requests', 'You have no pending connection requests' in out),
                     ('states persist after restart', assert_status(w, mixed))]
    report('T09 mixed decisions persist after restart', checks)

    # T10: invalid choice must retain pending request
    one = [('user2','searchtarget','P')]
    w = starting_dir(tmp, 'T10-Invalid-Decision', one)
    out, checks = run_case(w, 'T10-Invalid-Decision', LOGIN + '7\n9\n6\n')
    checks += [('invalid selection warning', 'Invalid selection; request remains pending.' in out),
               ('pending status unchanged', assert_status(w, one))]
    report('T10 invalid choice', checks)

lines = [f"{'PASS' if ok else 'FAIL'} — {name}" for name, ok, _ in REPORT]
lines.append('')
for name, _, checks in REPORT:
    lines.append(name)
    lines += [f"  {'PASS' if ok else 'FAIL'}: {description}" for description, ok in checks]
(OUTPUTS/'T06-T10-Test-Results.txt').write_text('\n'.join(lines) + '\n')
print('\nSummary:', sum(ok for _, ok, _ in REPORT), '/', len(REPORT), 'PASS')
print('Evidence saved in Epic5-Test-Inputs/ and Epic5-Test-Outputs/')
if not all(ok for _, ok, _ in REPORT):
    sys.exit(1)
