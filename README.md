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
show a sample browse, apply, and report session.

The Epic 7 acceptance cases are packaged in
`Epic7-Storyx-Test-Input.zip` and `Epic7-Storyx-Test-Output.zip`. T01-T11
are single input and output text files. T12-T20 use matching case folders;
their input folders include the initial data files, and their output folders
include console output and the resulting data files. The output ZIP also
contains the corrected T18 and T19 captures under `Retests/`.
