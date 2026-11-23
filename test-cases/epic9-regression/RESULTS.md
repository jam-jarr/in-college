# Epic 9 End-to-End and Regression Test Report

Results from executing the test script against the local checkout.
Scenarios use isolated temporary storage. Console and output file are byte-for-byte checked in each session.

| Test | Result | Details |
|---|---|---|
| E2E01-send-and-receive | PASS | All assertions satisfied |
| E2E02-multiple-senders | PASS | All assertions satisfied |
| E2E03-accept-connection-and-message | PASS | All assertions satisfied |
| NEG04-unknown-recipient | PASS | All assertions satisfied |
| NEG05-pending-connection | PASS | All assertions satisfied |
| NEG06-self-message | PASS | All assertions satisfied |
| NEG07-empty-message | PASS | All assertions satisfied |
| NEG08-over-200-characters | PASS | All assertions satisfied |
| BOUND09-send-200-characters | PASS | All assertions satisfied |
| REG10-invalid-login-retry | PASS | All assertions satisfied |
| REG11-empty-jobs-and-applications | PASS | All assertions satisfied |
| REG12-job-post-apply-report | PASS | All assertions satisfied |
| REG13-empty-network | PASS | All assertions satisfied |
| REG14-invalid-message-menu | PASS | All assertions satisfied |
| REG15-missing-message-file | PASS | All assertions satisfied |

**Result: 15/15 cases passed.**

Do not report failed scenarios as passed. Review the actual outputs before filing a bug.
