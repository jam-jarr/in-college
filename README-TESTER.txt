Independent Week 9 Tester — InCollege View My Messages

1. Switch to a branch containing Developer 1's integrated Epic 9 code, e.g.
   git fetch origin
   git switch -c epic9-ivan-tests origin/epic9dev1

2. Copy run_epic9_ivan_tests.py into the repository root.

3. In the VS Code Dev Container terminal, run:
   python3 run_epic9_ivan_tests.py

4. If it reports 7/7 PASS, you will have:
   Epic9-Storyx-Test-Input.zip
   Epic9-Storyx-Test-Output.zip
   test-cases/epic9-ivan/ (individual fixtures and actual .out files)

5. Commit the independent script, case inputs, .out files, and ZIPs:
   git add run_epic9_ivan_tests.py test-cases/epic9-ivan Epic9-Storyx-Test-Input.zip Epic9-Storyx-Test-Output.zip
   git commit -m "Add independent Epic 9 message viewing tests and evidence"
   git push -u origin epic9-ivan-tests

6. Record each test as a Jira test case with steps, expected/actual and PASS/FAIL.
   Do not claim PASS unless the program has actually run successfully.

Scenarios:
T01 empty inbox
T02 one received message
T03 multiple senders plus non-recipient privacy
T04 only messages to other users
T05 exact 200-character message content
T06 viewing the same inbox twice in one login
T07 received message persists across program restart

No project-level state is changed during test execution: each case runs in an
isolated temporary folder. Actual output files are created only after tests pass.

WARNING: Roles.txt currently lists both Ivan and Jamie as Tester #2. Correct
this to match the team's agreed Week 9 roles before submission.
