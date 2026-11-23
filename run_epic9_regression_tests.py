#!/usr/bin/env python3
"""Epic 9 end-to-end + legacy-regression tests, designed for the InCollege repo.

Run from the repository root after obtaining Epic 9 integration code:
    python3 run_epic9_regression_tests.py

Requires GNU COBOL (cobc). All program runs occur in temporary isolated
folders, never against accounts.txt, messages.txt, or other repo storage.
Test inputs and actual outputs are archived under DIFFERENT names from the
official Epic9-Storyx-Test-* ZIPs, so earlier Tester 1 evidence is preserved.
"""

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

REPO = Path.cwd().resolve()
OUT_DIR = REPO / 'test-cases' / 'epic9-regression'
USERS = [('user', 'Password1!'), ('user2', 'Password1!'),
         ('searchtarget', 'Password1!')]
ACCOUNTS = ''.join(f'{user:<20}{pw:<12}\n' for user, pw in USERS)
SAMPLE_MESSAGE = 'Hi, this is an Epic 9 end-to-end check.'
LONG_MESSAGE = ''.join(str(i % 10) for i in range(200))


def connection(sender, recipient, state='C'):
    assert len(sender) <= 20 and len(recipient) <= 20
    return f'{sender:<20}{recipient:<20}{state}\n'


def login(username='user', choices=()):
    return '1\n' + username + '\nPassword1!\n' + '\n'.join(choices) + '\n'


def send_input(sender, recipient, message):
    return login(sender, ['9', '1', recipient, message, '3', '8'])


def view_input(username):
    return login(username, ['9', '2', '3', '8'])


def msg_lines(folder):
    p = folder / 'messages.txt'
    if not p.exists():
        return []
    lines = p.read_text(encoding='utf-8').splitlines()
    return [{'sender': s[:20].strip(), 'recipient': s[20:40].strip(),
             'timestamp': s[40:59], 'body': s[59:].rstrip()}
            for s in lines if s]


def check(ok, detail):
    if not ok:
        raise AssertionError(detail)


class Scenario:
    def __init__(self, name, exe, working_base, initial=None):
        self.name = name
        self.root = working_base / name
        self.root.mkdir()
        self.evidence = OUT_DIR / name
        self.evidence.mkdir(parents=True, exist_ok=True)
        self.exe = exe
        self.sessions = 0
        fixture = {'accounts.txt': ACCOUNTS,
                   'connections.txt': '', 'messages.txt': '',
                   'jobs.txt': '', 'saved-jobs.txt': '', 'profiles.txt': ''}
        fixture.update(initial or {})
        init_folder = self.evidence / 'initial'
        init_folder.mkdir(exist_ok=True)
        for fname, body in fixture.items():
            (self.root / fname).write_bytes(body.encode('utf-8'))
            (init_folder / fname).write_bytes(body.encode('utf-8'))

    def run(self, input_text):
        self.sessions += 1
        label = f'session{self.sessions:02}'
        (self.root / 'InCollege-Input.txt').write_bytes(input_text.encode('utf-8'))
        (self.evidence / f'{label}-InCollege-Input.txt').write_bytes(input_text.encode('utf-8'))
        p = subprocess.run([str(self.exe)], cwd=self.root, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE, timeout=20)
        check(p.returncode == 0,
              f'{label} returned exit code {p.returncode}; stderr: {p.stderr.decode(errors="replace")[:800]}')
        output_path = self.root / 'InCollege-Output.txt'
        check(output_path.is_file(), f'{label}: output file not created')
        data = output_path.read_bytes()
        check(p.stdout == data, f'{label}: console output != InCollege-Output.txt')
        (self.evidence / f'{label}-Actual-Output.txt').write_bytes(data)
        decoded = data.decode('utf-8', errors='replace')
        check('Welcome to InCollege!' in decoded,
              f'{label}: main menu output missing')
        return decoded

    def persist_final(self):
        final = self.evidence / 'final-storage'
        final.mkdir(exist_ok=True)
        for fname in ['accounts.txt', 'connections.txt', 'messages.txt',
                      'jobs.txt', 'saved-jobs.txt']:
            if (self.root / fname).exists():
                shutil.copy2(self.root / fname, final / fname)


def one_send_and_receive(s):
    original = msg_lines(s.root)
    check(not original, 'expected initially empty message storage')
    s.run(send_input('user', 'user2', SAMPLE_MESSAGE))
    sent = msg_lines(s.root)
    check(len(sent) == 1, f'expected one stored message, found {len(sent)}')
    check(sent[0]['sender'] == 'user' and sent[0]['recipient'] == 'user2' and
          sent[0]['body'] == SAMPLE_MESSAGE, 'saved message fields incorrect')
    check(bool(re.fullmatch(r'\d{4}-\d\d-\d\d \d\d:\d\d:\d\d', sent[0]['timestamp'])),
          'stored timestamp is not YYYY-MM-DD HH:MM:SS')
    o = s.run(view_input('user2'))
    for part in ['From: user', 'Message: ' + SAMPLE_MESSAGE, 'Sent: ' + sent[0]['timestamp']]:
        check(part in o, f'receiver missing {part[:60]}')
    check(msg_lines(s.root) == sent, 'viewing unexpectedly modified storage')
    o = s.run(view_input('user'))
    check('You have no messages at this time.' in o and SAMPLE_MESSAGE not in o,
          'sender could see their own outgoing message in received inbox')


def multiple_real_senders(s):
    m1, m2 = 'First sender: user.', 'Second sender: searchtarget.'
    o = s.run(send_input('user', 'user2', m1))
    check('Message sent to user2 successfully!' in o, 'first send not confirmed')
    o = s.run(send_input('searchtarget', 'user2', m2))
    check('Message sent to user2 successfully!' in o, 'second send not confirmed')
    o = s.run(view_input('user2'))
    check(o.count('From: ') == 2, 'recipient did not see exactly two messages')
    check('Message: ' + m1 in o and 'Message: ' + m2 in o, 'recipient missing a message')
    check(o.index('Message: ' + m1) < o.index('Message: ' + m2),
          'messages not displayed in storage order')
    o = s.run(view_input('searchtarget'))
    check('You have no messages at this time.' in o and m1 not in o and m2 not in o,
          'non-recipient saw a private message')
    check(len(msg_lines(s.root)) == 2, 'stored message count changed after views')


def accept_request_then_send(s):
    o = s.run(login('user2', ['6', '1', '8']))
    check('Connection request from user accepted!' in o, 'pending connection not accepted')
    states = (s.root / 'connections.txt').read_text(encoding='utf-8').splitlines()
    check(len(states) == 1 and states[0][40:41] == 'C',
          'connection state did not change from pending to connected')
    o = s.run(send_input('user', 'user2', 'Message after connection approval.'))
    check('Message sent to user2 successfully!' in o, 'message not sent after approval')
    o = s.run(view_input('user2'))
    check('Message: Message after connection approval.' in o,
          'message missing after connection approval')


def rejected_send(s, recipient, message, expected):
    before = (s.root / 'messages.txt').read_bytes()
    o = s.run(send_input('user', recipient, message))
    check(expected in o, f'expected rejection not shown: {expected}')
    check('Message sent to ' not in o, 'rejected message incorrectly reported as sent')
    check((s.root / 'messages.txt').read_bytes() == before,
          'invalid message changed persistent storage')


def length_limit_send(s):
    o = s.run(send_input('user', 'user2', LONG_MESSAGE))
    check('Message sent to user2 successfully!' in o, '200-character send rejected')
    sent = msg_lines(s.root)
    check(len(sent) == 1 and sent[0]['body'] == LONG_MESSAGE,
          '200-character body was truncated or changed')
    o = s.run(view_input('user2'))
    check('Message: ' + LONG_MESSAGE in o, '200-character message not displayed exactly')


def invalid_login_retry(s):
    o = s.run('1\nuser\nWrong1!\nuser\nPassword1!\n9\n2\n3\n8\n')
    check('Incorrect username/password, please try again' in o, 'invalid login not rejected')
    check('You have successfully logged in' in o, 'valid login retry failed')
    check('--- Your Messages ---' in o, 'message menu inaccessible after retry')


def empty_jobs_and_applications(s):
    o = s.run(login('user', ['3', '2', '3', '4', '8']))
    check('No jobs available.' in o, 'empty job browse behavior regressed')
    check('No applications found.' in o, 'empty applications behavior regressed')
    check('Total Applications: 0' in o, 'empty applications count incorrect')


def job_post_apply_and_report(s):
    o = s.run(login('user', ['3', '1', 'Lab Test Technician',
                              'Support controlled testing for course project.',
                              'USF Research', 'Tampa', 'NONE', '4', '8']))
    check((s.root / 'jobs.txt').stat().st_size > 0, 'posting did not persist in jobs.txt')
    o = s.run(login('user2', ['3', '2', '1', '1', '0', '3', '4', '8']))
    check('Lab Test Technician' in o and '--- Job Details ---' in o,
          'job browsing or details regressed')
    check('Job Title: Lab Test Technician' in o and 'Total Applications: 1' in o,
          'applying and reporting a job failed')
    check((s.root / 'saved-jobs.txt').stat().st_size > 0,
          'job application did not persist')
    o = s.run(login('user2', ['3', '3', '4', '8']))
    check('Job Title: Lab Test Technician' in o and 'Total Applications: 1' in o,
          'application report not persistent after restart')
    check(not msg_lines(s.root), 'job workflow unexpectedly created messages')


def empty_network(s):
    o = s.run(login('user', ['7', '8']))
    check('--- Your Network ---' in o, 'network menu missing')
    check('You have no established connections.' in o,
          'empty network report behavior regressed')


def invalid_message_menu(s):
    o = s.run(login('user', ['9', '7', '2', '3', '8']))
    check('Invalid selection.' in o, 'invalid message menu option not reported')
    check('--- Your Messages ---' in o, 'menu did not recover after invalid choice')
    check('You have no messages at this time.' in o, 'empty inbox not shown after recovery')


def missing_message_file(s):
    (s.root / 'messages.txt').unlink()
    o = s.run(view_input('user'))
    check('You have no messages at this time.' in o, 'missing messages file not initialized')
    check((s.root / 'messages.txt').exists(), 'missing messages.txt not created at startup')


CASES = [
    ('E2E01-send-and-receive', {'connections.txt': connection('user','user2')}, one_send_and_receive),
    ('E2E02-multiple-senders', {'connections.txt': connection('user','user2') + connection('user2','searchtarget')}, multiple_real_senders),
    ('E2E03-accept-connection-and-message', {'connections.txt': connection('user','user2','P')}, accept_request_then_send),
    ('NEG04-unknown-recipient', {}, lambda s: rejected_send(s, 'notarealuser', 'Should not save.', 'User not found.')),
    ('NEG05-pending-connection', {'connections.txt': connection('user','user2','P')}, lambda s: rejected_send(s, 'user2', 'Should not save.', 'You can only message users you are connected with.')),
    ('NEG06-self-message', {'connections.txt': connection('user','user2')}, lambda s: rejected_send(s, 'user', 'Should not save.', 'You can only message users you are connected with.')),
    ('NEG07-empty-message', {'connections.txt': connection('user','user2')}, lambda s: rejected_send(s, 'user2', '', 'Message cannot be empty.')),
    ('NEG08-over-200-characters', {'connections.txt': connection('user','user2')}, lambda s: rejected_send(s, 'user2', 'X' * 201, 'Message exceeds 200 characters.')),
    ('BOUND09-send-200-characters', {'connections.txt': connection('user','user2')}, length_limit_send),
    ('REG10-invalid-login-retry', {}, invalid_login_retry),
    ('REG11-empty-jobs-and-applications', {}, empty_jobs_and_applications),
    ('REG12-job-post-apply-report', {}, job_post_apply_and_report),
    ('REG13-empty-network', {}, empty_network),
    ('REG14-invalid-message-menu', {}, invalid_message_menu),
    ('REG15-missing-message-file', {}, missing_message_file),
]


def bundle_inputs_and_outputs():
    with ZipFile(REPO/'Epic9-Regression-Test-Input.zip', 'w', ZIP_DEFLATED) as input_zip, \
         ZipFile(REPO/'Epic9-Regression-Test-Output.zip', 'w', ZIP_DEFLATED) as output_zip:
        for item in sorted(OUT_DIR.rglob('*')):
            if not item.is_file():
                continue
            rel = item.relative_to(OUT_DIR)
            if 'initial' in rel.parts or item.name.endswith('-InCollege-Input.txt'):
                input_zip.write(item, 'TestInputs/' + str(rel).replace('\\', '/'))
            else:
                output_zip.write(item, 'TestOutputs/' + str(rel).replace('\\', '/'))


def main():
    for name in ['InCollege.cob', 'ViewMessages.cob']:
        if not (REPO / name).is_file():
            print(f'ERROR: Missing {name}. Run from the Epic 9 repository root.', file=sys.stderr)
            return 2
    if shutil.which('cobc') is None:
        print('ERROR: GNU COBOL cobc missing. Use Docker as documented in the README.', file=sys.stderr)
        return 2
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    results = []
    with tempfile.TemporaryDirectory(prefix='epic9-extra-tests-') as tmp:
        work = Path(tmp)
        binary = work / 'InCollege'
        p = subprocess.run(['cobc', '-x', '-I', str(REPO), '-o', str(binary),
                            str(REPO/'InCollege.cob')], cwd=REPO, text=True,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if p.returncode != 0:
            print('COBOL compilation: FAIL\n' + p.stdout, file=sys.stderr)
            return 1
        print('COBOL compilation: PASS')
        for name, initial, test_fn in CASES:
            scenario = None
            try:
                scenario = Scenario(name, binary, work, initial)
                test_fn(scenario)
                results.append((name, 'PASS', 'All assertions satisfied'))
                print(name + ': PASS')
            except (AssertionError, OSError, subprocess.TimeoutExpired) as e:
                results.append((name, 'FAIL', str(e)))
                print(name + ': FAIL - ' + str(e), file=sys.stderr)
            finally:
                if scenario is not None:
                    scenario.persist_final()
    report = ['# Epic 9 End-to-End and Regression Test Report', '',
              'Results from executing the test script against the local checkout.',
              'Scenarios use isolated temporary storage. Console and output file are byte-for-byte checked in each session.', '',
              '| Test | Result | Details |', '|---|---|---|']
    for name, status, detail in results:
        report.append(f'| {name} | {status} | {detail.replace("|", "/")} |')
    passed = sum(s == 'PASS' for _, s, _ in results)
    report += ['', f'**Result: {passed}/{len(CASES)} cases passed.**',
               '', 'Do not report failed scenarios as passed. Review the actual outputs before filing a bug.', '']
    (OUT_DIR / 'RESULTS.md').write_text('\n'.join(report), encoding='utf-8')
    bundle_inputs_and_outputs()
    print(f'\n{passed}/{len(CASES)} additional scenarios PASSED.')
    print('Saved test-cases/epic9-regression/RESULTS.md and both Epic9-Regression-Test-*.zip files.')
    print('Earlier Epic9-Storyx-Test-*.zip files were NOT changed.')
    return 0 if passed == len(CASES) else 1


if __name__ == '__main__':
    sys.exit(main())
