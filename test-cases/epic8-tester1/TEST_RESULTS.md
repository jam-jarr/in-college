# Epic 8 - Tester #1 Results Report

## Project Information

- Project: InCollege
- Sprint: Epic 8 - Basic Messaging System
- Tester: Ivan Gonzalez (Tester #1)
- Developer Tested: Jamie Giarratana (Developer #2)
- Development Branch: epic8-messaging-persistence
- Development Commit: 38fbc75
- Testing Branch: epic8-tester1
- Environment: Windows PowerShell, Docker Compose, GnuCOBOL

## Testing Summary

- Total Tests: 10
- Passed: 10
- Failed: 0
- Bugs Found: 0 in the tested scenarios

Nine tests involved program execution. T18 was a separate inspection
of the persistent message records.

## Test Results

| Test | Description | Result |
|------|-------------|--------|
| T13 | Successful Message Persistence | PASS |
| T14 | Multiple Message Persistence | PASS |
| T15 | Persistence After Restart | PASS |
| T16 | Maximum Message Length (200 Characters) | PASS |
| T17 | Invalid Message Handling | PASS |
| T18 | Message Record Validation | PASS |
| T19 | Automatic Message File Creation | PASS |
| T20 | Exact Console/Output Verification | PASS |
| T21 | Pending, Unknown, and Self Recipients | PASS |
| T22 | Existing Unconnected Recipient | PASS |

## Important Findings

1. Valid messages are saved successfully to messages.txt.
2. New messages are appended without overwriting previous messages.
3. Stored messages persist across application restarts.
4. Messages containing exactly 200 characters are preserved without truncation.
5. Empty messages and messages exceeding 200 characters are rejected.
6. Saved records contain sender, recipient, timestamp, and message content.
7. Missing message storage files are created automatically.
8. Console output and program output were verified as byte-identical in T20.
9. Pending, nonexistent, self, and unconnected recipients were rejected.
10. Rejected messages did not modify persistent storage.

## Testing Evidence

Each executable test has its own folder containing its input,
actual output, and supporting evidence.

The submission archives are:

- Epic8-Storyx-Test-Input.zip (9 test input files)
- Epic8-Storyx-Test-Output.zip (9 actual output files)

T18 includes a separate CSV containing message record validation results.

## Conclusion

All ten test cases passed.

No defects were observed in the messaging functionality covered by
these tests. Message persistence, storage integrity, input validation,
recipient restrictions, and output consistency behaved as expected.

Message retrieval remains intentionally under construction for Epic 8.

These results do not guarantee that the entire application is free
of defects; they document the scenarios executed by Tester #1.
