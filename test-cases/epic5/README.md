# Epic 5 test cases

Each subdirectory is one self-contained test case for `run-test.sh`:
it holds the seed data files (`accounts.txt`, `profiles.txt`,
`connections.txt`), the program input (`InCollege-Input.txt`), and the
expected output (`<test-name>.out`, regenerated on each run).

These cases were integrated from the manual multi-phase evidence in
`Epic5-Test-Inputs/` and `Epic5-Test-Outputs/` (T01-T10). Tests that were
originally multi-phase (action, then verify after a restart) are split into
one directory per phase; the "verify" directories are seeded with the
post-action state of `connections.txt` so every case is replayable
independently.

| Directory | Original test |
|---|---|
| t01-tenth-account | T01: 10th account can be created (9 seeded) |
| t02-eleventh-account-limit | T02: 11th account rejected (10 seeded) |
| t03-accept-one-request | T03: accept a single pending request |
| t03-verify-pending-removed | T03: pending list empty after accept + restart |
| t04-accept-multiple-requests | T04: accept multiple pending requests |
| t04-verify-persistence | T04: accepted states persist after restart |
| t05-reject-one-request | T05: reject a single pending request |
| t05-verify-rejection | T05: rejected sender no longer pending after restart |
| t05-blocked-reattempt | T05: re-sending to a rejected user is blocked |
| t06-reject-multiple | T06: reject multiple pending requests |
| t06-reject-multiple-restart | T06: no pending left after restart |
| t07-reattempt-after-restart | T07: blocked reattempt after restart |
| t08-mixed-accept-reject | T08: accept one, reject another in one session |
| t09-mixed-restart-action | T09: mixed decisions (accept + reject) |
| t09-mixed-restart-verify | T09: mixed statuses persist after restart |
| t10-invalid-decision | T10: invalid choice keeps request pending |

Shared seeds: `user`, `user2` and `searchtarget` (Jordan Smith) exist in
`accounts.txt`/`profiles.txt`; `connections.txt` rows use the fixed-width
`sender(20) recipient(20) status` format (`P` pending, `C` connected,
`R` rejected).
