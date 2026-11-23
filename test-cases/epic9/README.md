# Epic 9 Developer 1 — inbox display tests

Each case contains fixture files for the existing `run-test.sh` approach.
It logs in as `user`, opens **9. Messages > 2. View My Messages**,
returns to the main menu, and logs out.

- `01-no-messages`: prints exactly the no-messages status; does not show messages addressed to other users.
- `02-one-message`: prints one sender, one message, and its timestamp.
- `03-multiple-senders`: prints three received messages from two different senders, oldest first; excludes the message addressed to `user2`.

Verify that all text shown on the console matches `InCollege-Output.txt`.
To check persistence, run `02-one-message` a second time without changing
`messages.txt`; the same message should still be visible.

### Run the automated checks (recommended)

From the repository root, after applying the Developer 1 changes and opening
your VS Code Dev Container:

```bash
python3 test-cases/epic9/test_epic9_dev1.py --repo .
```

The script compiles, runs three scenarios in isolated temporary directories,
verifies exact console/output file parity, rejects messages sent to a different
recipient, checks navigation back through both menus, and reruns the single
message case without deleting `messages.txt`. It does not overwrite project
storage files.

### Manual test without the interactive runner

Copy a case's `*.txt` files into the project root (back up your own persistent
files first). From the repository root, run:

```bash
cobc -x -o InCollege InCollege.cob
./InCollege > /tmp/epic9-console.txt
diff -u /tmp/epic9-console.txt InCollege-Output.txt
```

`diff` must produce no differences. `messages.txt` must remain unchanged.
