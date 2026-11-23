#!/usr/bin/env python3
"""Independent Epic 9 tester scenarios. Run from the InCollege repository root:
    python3 run_epic9_ivan_tests.py
Requires GNU COBOL (cobc) in VS Code's Dev Container.
Does not modify project data files; uses isolated temporary directories.
Creates Epic9-Storyx-Test-Input.zip and, after successful execution,
Epic9-Storyx-Test-Output.zip.
"""
from pathlib import Path
from tempfile import TemporaryDirectory
import shutil
import subprocess
from zipfile import ZipFile, ZIP_DEFLATED
import sys

ROOT=Path.cwd().resolve()
TESTBASE=ROOT / 'test-cases' / 'epic9-ivan'
ACCOUNTS='user                Password1!\nuser2               Password1!\nsearchtarget        Password1!\n'


def record(sender, recipient, timestamp, body):
    assert len(sender)<=20 and len(recipient)<=20 and len(timestamp)==19 and len(body)<=200
    return f'{sender:<20}{recipient:<20}{timestamp}{body:<200}\n'


def menu_input(repeat=False):
    return '1\nuser\nPassword1!\n9\n2\n' + ('2\n' if repeat else '') + '3\n8\n'

LONG=''.join(str(i%10) for i in range(200))
CASES={
    'T01-empty-inbox': {
        'messages':'', 'expected':[], 'forbidden':['From:', 'Message:'], 'count':0},
    'T02-single-message': {
        'messages':record('user2','user','2026-11-20 08:15:00','Reminder about the meeting.'),
        'expected':['From: user2', 'Message: Reminder about the meeting.', 'Sent: 2026-11-20 08:15:00'],
        'forbidden':['You have no messages at this time.'], 'count':1},
    'T03-multiple-senders-privacy': {
        'messages':''.join([
            record('user2','user','2026-11-20 09:00:00','First inbox message.'),
            record('searchtarget','user','2026-11-20 10:00:00','Second inbox message.'),
            record('user','user2','2026-11-20 11:00:00','PRIVATE TO ANOTHER USER'),
            record('user2','user','2026-11-20 12:00:00','Third inbox message.')]),
        'expected':['Message: First inbox message.', 'Message: Second inbox message.',
                    'Message: Third inbox message.'],
        'forbidden':['PRIVATE TO ANOTHER USER'], 'count':3, 'ordered':True},
    'T04-only-other-users': {
        'messages':''.join([
            record('user','user2','2026-11-20 10:00:00','NOT YOUR INBOX A'),
            record('user2','searchtarget','2026-11-20 11:00:00','NOT YOUR INBOX B')]),
        'expected':['You have no messages at this time.'],
        'forbidden':['From:', 'NOT YOUR INBOX A','NOT YOUR INBOX B'], 'count':0},
    'T05-200-char-content': {
        'messages':record('searchtarget','user','2026-11-21 09:31:00',LONG),
        'expected':['From: searchtarget', 'Message: '+LONG, 'Sent: 2026-11-21 09:31:00'],
        'forbidden':[], 'count':1},
    'T06-view-twice-same-login': {
        'messages':record('user2','user','2026-11-22 09:00:00','Repeat view check.'),
        'expected':['Message: Repeat view check.'], 'forbidden':[], 'count':2, 'repeat_view':True},
    'T07-persistence-after-restart': {
        'messages':record('user2','user','2026-11-22 10:00:00','Still here after restart.'),
        'expected':['Message: Still here after restart.'], 'forbidden':[], 'count':1, 'restart':True},
}


def require(condition,message):
    if not condition:
        raise AssertionError(message)


def main():
    if not (ROOT/'InCollege.cob').exists() or not (ROOT/'ViewMessages.cob').exists():
        print('ERROR: Run from a repository root with Epic 9 code (e.g., epic9dev1).',file=sys.stderr)
        return 2
    if not shutil.which('cobc'):
        print('ERROR: cobc not found. Open the repo in its VS Code Dev Container.',file=sys.stderr)
        return 2
    TESTBASE.mkdir(parents=True,exist_ok=True)
    with ZipFile(ROOT/'Epic9-Storyx-Test-Input.zip','w',ZIP_DEFLATED) as zin:
        for name, config in CASES.items():
            case_dir=TESTBASE/name
            case_dir.mkdir(parents=True,exist_ok=True)
            files={'accounts.txt':ACCOUNTS,
                   'messages.txt':config['messages'],
                   'InCollege-Input.txt':menu_input(config.get('repeat_view',False))}
            for fname,data in files.items():
                (case_dir/fname).write_text(data,encoding='utf-8',newline='')
                zin.writestr(f'TestInputs/{name}/{fname}', data)

    with TemporaryDirectory(prefix='incollege-epic9-ivan-') as temp:
        temp=Path(temp)
        exe=temp/'InCollege'
        build=subprocess.run(['cobc','-x','-I',str(ROOT),'-o',str(exe),str(ROOT/'InCollege.cob')],
                             cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
        if build.returncode:
            print('COMPILATION FAILED:\n'+build.stdout,file=sys.stderr)
            return 1
        print('COBOL compilation: PASS')
        results=[]
        for name,config in CASES.items():
            scenario=temp/name
            scenario.mkdir()
            for source in (TESTBASE/name).glob('*.txt'):
                shutil.copy2(source,scenario/source.name)
            original=(scenario/'messages.txt').read_bytes()
            n=2 if config.get('restart') else 1
            for runidx in range(n):
                p=subprocess.run([str(exe)],cwd=scenario,stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE,timeout=20)
                require(p.returncode==0,f'{name}: process failed: {p.stderr.decode(errors="replace")}')
                out_path=scenario/'InCollege-Output.txt'
                require(out_path.exists(),f'{name}: output file missing')
                require(p.stdout==out_path.read_bytes(),f'{name}: stdout and output file differ')
                require((scenario/'messages.txt').read_bytes()==original,
                        f'{name}: viewing modified persistent messages.txt')
                output=p.stdout.decode('utf-8',errors='replace')
                require('--- Your Messages ---' in output,f'{name}: inbox heading missing')
                require('View My Messages is under construction.' not in output,
                        f'{name}: still under construction')
                require(output.count('From: ')==config['count'],
                        f'{name}: expected {config["count"]} visible records; got {output.count("From: ")}')
                for term in config['expected']:
                    require(term in output,f'{name}: missing expected output: {term[:65]}')
                for term in config['forbidden']:
                    require(term not in output,f'{name}: forbidden output shown: {term[:65]}')
                if config['count']==0:
                    require('You have no messages at this time.' in output,
                            f'{name}: missing no-messages prompt')
                if config.get('ordered'):
                    pos=[output.index(term) for term in config['expected']]
                    require(pos==sorted(pos),f'{name}: messages were not shown in file order')
                if config.get('restart') and runidx==0:
                    first_stdout=p.stdout
                if config.get('restart') and runidx==1:
                    require(p.stdout==first_stdout,f'{name}: same inbox changed after restart')
            out=(scenario/'InCollege-Output.txt').read_bytes()
            (TESTBASE/name/f'{name}.out').write_bytes(out)
            results.append((name,out))
            print(f'{name}: PASS' + (' (2 runs)' if n==2 else ''))
        with ZipFile(ROOT/'Epic9-Storyx-Test-Output.zip','w',ZIP_DEFLATED) as zout:
            for name,out in results:
                zout.writestr(f'TestOutputs/{name}-Output.txt',out)
    print('\n7/7 independent cases PASSED. Generated both required input/output ZIPs.')
    print('NOTE: Record these actual results in Jira; this script does not edit Jira.')
    return 0

if __name__=='__main__':
    try:
        sys.exit(main())
    except (AssertionError,subprocess.TimeoutExpired,OSError) as e:
        print(f'TEST FAILED: {e}',file=sys.stderr)
        sys.exit(1)
