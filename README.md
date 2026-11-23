# InCollege

The program reads all user input from `InCollege-Input.txt` and writes all
program output to both the console and `InCollege-Output.txt`.

```bash
cobc -x -o InCollege InCollege.cob

./InCollege
```

## Interactive Use

You can run the program interactively by changing this line

``` cobol
01 WS-INPUT-MODE PIC X VALUE 'F'.
```

to

``` cobol
01 WS-INPUT-MODE PIC X VALUE 'C'.
```

The `interactive-use.sh` shell script toggles this for you.

## Docker

If you do not have cobc installed, you can build and run it with Docker

``` bash
sudo docker compose up
```

If you want to run it interactively, first follow [this](#Interactive Use), then run

``` bash
sudo docker compose run cobol
```

## Testing Suite

Test cases live under `test-cases/<epic>/<test-case>/`. Each test case
contains an `InCollege-Input.txt` (the user input sent to the program), the
setup files it needs (`accounts.txt`, `profiles.txt`, ...), and a `<test-case>.out`
(expected/recorded output).

### Running Tests (`run-test.sh`)

``` bash
./run-test.sh
```

It prompts you to pick:

1. an **epic** — a folder under `test-cases/`
2. a **test case**, or "Run ALL test cases" in that epic

For each test it copies the test's `*.txt` files into the project root, runs
the program (via Docker), and saves the resulting `InCollege-Output.txt` back
into the test folder as `<test-case>.out`.

### Packaging a Submission (`package-submission.sh`)

When an epic is ready to hand in, package its test inputs and outputs into the
two submission archives:

``` bash
./package-submission.sh
```

It prompts you to pick an **epic** (numbered menu, same as the test runner)
and then produces, in the project root:

```
EpicX-Storyx-Test-Input.zip    <test-case>-Input.txt  (from InCollege-Input.txt)
EpicX-Storyx-Test-Output.zip   <test-case>-Output.txt (from <test-case>.out)
```
## Epic 7 - Job Board and Applications

After logging in, choose **3. Search for a job** from the main menu. The Job
Search/Internship menu offers:

1. **Post a Job/Internship** - enter a title, description, employer, location,
   and optional salary (`NONE` skips salary). Postings persist in `jobs.txt`.
2. **Browse Jobs/Internships** - see the title, employer, and location of each
   posting. Enter its displayed number to view the full details, including the
   description and salary when present. Choose **1. Apply for this job** to
   record an application, or **2. Back to job list**. Enter **0** from the job
   list to return to the Job Search/Internship menu.
3. **View My Applications** - see only the current user's applied jobs, with
   each job's title, employer, and location, plus a total count. An empty
   report says `No applications found.`
4. **Back to Main Menu**.

Applications persist as `A` events in `saved-jobs.txt`, keyed by username and
job ID. Reapplying to the same job does not create another application.

All choices are read in order from `InCollege-Input.txt`; the program does not
ask for live keyboard input in its default mode. Prompts, job details,
application confirmations, and reports appear on the console and in
`InCollege-Output.txt` with identical content. The root input and output files
show the Epic 8 messaging session described below.

## Epic 8 - Messaging

After logging in, choose **9. Messages** from the main menu. The Messages menu
offers:

1. **Send a New Message** - enter the username of a user you are connected
   with, then enter the message text (1-200 characters). The message is saved
   to `messages.txt` and the program reports
   `Message sent to <username> successfully!`
2. **View My Messages** - was a Week 8 placeholder. Epic 9 now displays received messages (see below).
3. **Back to Main Menu**.

A recipient must exist and must have an accepted connection with the sender
(status `C` in `connections.txt`, in either direction). Unknown, pending,
unconnected, and self recipients are rejected with an explanatory message.

Messages persist as fixed-width records in `messages.txt` (created
automatically at startup):

```
sender X(20) + recipient X(20) + timestamp X(19) + content X(200)
```

The timestamp is stored as `YYYY-MM-DD HH:MM:SS`. The record is append-only;
the file is not rewritten. Prompts, confirmations, and errors are written to
the console and `InCollege-Output.txt` exactly as with the other features.

The root `InCollege-Input.txt` contains a sample session using the root account
and connection files. It shows an unknown recipient, a pending connection,
a successful send to an accepted connection, and the under-construction view.
Run the program to regenerate `InCollege-Output.txt`; the successful message is
appended to `messages.txt`.

The `Epic8-Storyx-Test-Input.zip` and `Epic8-Storyx-Test-Output.zip` archives
contain all 21 executable tester cases. The input archive contains a
`TestInputs` folder with account and connection fixtures; the output archive
contains a `TestOutputs` folder with the T18 message-record inspection
evidence. The root sample input and output files are separate from these test
archives.


## Epic 9 - View My Messages

The **9. Messages** menu now supports **2. View My Messages**. The display
uses the Epic 9 inbox reader to show only messages addressed to the logged-in
user. Messages appear in `messages.txt` file order (oldest first), each with
`From:`, `Message:`, and `Sent:` fields. If there are none, the program prints
`You have no messages at this time.`. A read error produces an error notice.

The inbox reader remains responsible for reading and filtering `messages.txt`;
`ViewMessages.cob` is the display-only copybook. All output uses the existing
`WRITE-MESSAGE` paragraph, so the same output is sent to the console and
`InCollege-Output.txt`. The display does not change or delete any messages;
received messages remain viewable on subsequent program runs.

Example `InCollege-Input.txt` for an existing `user` account:

```text
1
user
Password1!
9
2
3
8
```

Compile as before from the repo root: `cobc -x -o InCollege InCollege.cob`.
The compiler resolves `COPY "ViewMessages.cob".` from that directory. See
`test-cases/epic9/` for no-message, single-message and multi-sender fixtures.
