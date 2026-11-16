# Epic 8 tester inputs

Each `T01_*.txt` through `T12_*.txt` file contains one complete
`InCollege-Input.txt` sequence. The matching transcript is in `TestOutputs`
with the same name. The other tester's executable cases are `T13-Input.txt`
through `T22-Input.txt` (except T18), with matching `Txx-Output.txt` files in
`TestOutputs`. T18 is a separate message-record inspection in
`TestOutputs/Evidence`.

For each case, run the `testing-epic8` program in a clean working directory:

1. Copy the case file to `InCollege-Input.txt`.
2. Copy `Fixtures/accounts.txt` and `Fixtures/connections.txt` to the working
   directory with those names.
3. Run the program and compare `InCollege-Output.txt` with the matching file in
   `TestOutputs`. Console output should match the same transcript.
4. For T11 and T12, inspect the one new `messages.txt` record: sender and
   recipient are `user` and `connected`, the timestamp has format
   `YYYY-MM-DD HH:MM:SS`, and the content matches the input line exactly.

The fixtures contain `user` (sender), `connected` (accepted connection),
`pending` (pending connection), and `stranger` (no connection). All four accounts
use the password shown in the input files. T11 and T12 expect a successful send
to `connected` and a new record in `messages.txt` containing the sender,
recipient, timestamp, and full message content. Run each case with a fresh
`messages.txt` so existing records do not affect persistence checks.

T13-T22 use their matching `Fixtures/Txx-accounts.txt` and
`Fixtures/Txx-connections.txt` files. T15 additionally uses
`Fixtures/T15-messages.txt` to verify records survive a restart. T19 starts
without a `messages.txt` file to verify automatic creation.
