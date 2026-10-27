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
## Epic 6 - Job Posting and Saved Jobs

Logged-in users can post job and internship listings through the Job Search/Internship menu.

### Posting a Job
Select "Post a Job/Internship" and enter:
- Job title (required)
- Description (required)
- Employer (required)
- Location (required)
- Salary (optional; enter NONE to skip)

Each posting receives a unique job ID and is stored in jobs.txt. Posted jobs remain available after the program restarts.

### Saved and Applied Jobs
Select "Saved/Applied Jobs" from the Job Search/Internship menu to:
1. Save a job by ID.
2. View saved jobs.
3. Unsave a job by ID.
4. Mark a job as applied.
5. View applied jobs.

Job selections are associated with the logged-in user. Saved and applied job states are persisted in saved-jobs.txt and restored across program runs.

### Input and Output
The program reads menu selections and job details from InCollege-Input.txt and displays output on the console while writing the same output to InCollege-Output.txt.

For example, after logging in, use menu option 3 to open Job Search/Internship, option 1 to post a job, and option 3 to return to the main menu.

The Browse Jobs/Internships option remains under construction for Epic 6.
