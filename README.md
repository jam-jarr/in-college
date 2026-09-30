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
