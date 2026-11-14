# Epic 8 tester inputs

Each `Txx_*.txt` file contains one complete `InCollege-Input.txt` sequence. The
matching transcript is `TestOutputs/Txx_*.txt`.

For each case, run the `testing-epic8` program in a clean working directory:

1. Copy the case file to `InCollege-Input.txt`.
2. Copy `Fixtures/accounts.txt` and `Fixtures/connections.txt` to the working
   directory with those names.
3. Run the program and compare `InCollege-Output.txt` with the matching file in
   `TestOutputs`. Console output should match the same transcript.

The fixtures contain `user` (sender), `connected` (accepted connection),
`pending` (pending connection), and `stranger` (no connection). All four accounts
use the password shown in the input files. T11 and T12 verify accepted message
content only: the implementation currently reports that storage is not yet
integrated, so these cases do not assert successful sending or persistence.
