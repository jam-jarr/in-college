       IDENTIFICATION DIVISION.
       PROGRAM-ID. INCOLLEGE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           *> set up the input file
           SELECT INPUT-FILE
               ASSIGN TO "InCollege-Input.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

           *> set up the output file
           SELECT OUTPUT-FILE
               ASSIGN TO "InCollege-Output.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           
           *> set up persistent account storage
           SELECT ACCOUNT-FILE
               ASSIGN TO "accounts.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       *> stores each line read from the input file
       FD INPUT-FILE.
       01 INPUT-RECORD PIC X(100).

       *> stores each line written to the output file
       FD OUTPUT-FILE.
       01 OUTPUT-RECORD PIC X(100).
       
       *> stores account records between program runs
       FD ACCOUNT-FILE.
       01 ACCOUNT-RECORD.
           05 ACCOUNT-RECORD-USERNAME PIC X(20).
           05 ACCOUNT-RECORD-PASSWORD PIC X(12).



       WORKING-STORAGE SECTION.

       *> temporary values used while the program runs
       01 WS-MESSAGE PIC X(100).
       01 WS-USER-INPUT PIC X(100).
       01 WS-CHOICE PIC X.
       01 WS-INPUT-ENDED PIC X VALUE "N".
           88 INPUT-ENDED VALUE "Y".
           88 INPUT-AVAILABLE VALUE "N".
       
       
       *> stores account information while the program runs
       01 WS-ACCOUNTS.
           05 WS-ACCOUNT OCCURS 5 TIMES.
               10 WS-ACCOUNT-USERNAME PIC X(20).
               10 WS-ACCOUNT-PASSWORD PIC X(12).
       
       01 WS-USERNAME-EXISTS PIC X VALUE "N".
           88 USERNAME-EXISTS VALUE "Y".
           88 USERNAME-AVAILABLE VALUE "N".

       01 WS-ACCOUNT-COUNT PIC 9 VALUE 0.
       01 WS-ACCOUNT-INDEX PIC 9 VALUE 0.

       01 WS-ACCOUNT-FILE-ENDED PIC X VALUE "N".
           88 ACCOUNT-FILE-ENDED VALUE "Y".
           88 ACCOUNT-FILE-AVAILABLE VALUE "N".

       01 WS-PASSWORD-LENGTH PIC 99 VALUE 0.
       01 WS-CHAR-INDEX PIC 99 VALUE 0.

       01 WS-HAS-UPPERCASE PIC X VALUE "N".
           88 HAS-UPPERCASE VALUE "Y".

       01 WS-HAS-DIGIT PIC X VALUE "N".
           88 HAS-DIGIT VALUE "Y".

       01 WS-HAS-SPECIAL PIC X VALUE "N".
           88 HAS-SPECIAL VALUE "Y".

       01 WS-PASSWORD-VALID PIC X VALUE "N".
           88 PASSWORD-VALID VALUE "Y".
       
       *> values used during login
       01 WS-LOGIN-USERNAME PIC X(20).
       01 WS-LOGIN-PASSWORD PIC X(12).
       01 WS-LOGIN-FOUND PIC X VALUE "N".
           88 LOGIN-FOUND VALUE "Y".
           88 LOGIN-NOT-FOUND VALUE "N".
       
       *> controls the logged-in menu
       01 WS-LOGOUT-SELECTED PIC X VALUE "N".
           88 LOGOUT-SELECTED VALUE "Y".
           88 USER-LOGGED-IN VALUE "N".
       
       01 WS-SKILL-BACK-SELECTED PIC X VALUE "N".
           88 SKILL-BACK-SELECTED VALUE "Y".
           88 STAY-IN-SKILL-MENU VALUE "N".



       PROCEDURE DIVISION.

       MAIN-PROCEDURE.

           *> open the files for reading and writing
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE
           
           *> load saved accounts
           OPEN INPUT ACCOUNT-FILE
           PERFORM LOAD-ACCOUNTS
           CLOSE ACCOUNT-FILE *> close now to reopen later for writing

           *> temporarily test account storage
           *>MOVE "test" TO WS-ACCOUNT-USERNAME(1)
           *>MOVE "Password1!" TO WS-ACCOUNT-PASSWORD(1)
           *>MOVE 1 TO WS-ACCOUNT-COUNT
           
           *> temporary test for saving an account
           *>IF WS-ACCOUNT-COUNT < 5
           *>    ADD 1 TO WS-ACCOUNT-COUNT

           *>    MOVE "testuser"
           *>        TO WS-ACCOUNT-USERNAME(WS-ACCOUNT-COUNT)

           *>    MOVE "Testpass1!"
           *>        TO WS-ACCOUNT-PASSWORD(WS-ACCOUNT-COUNT)

           *>    PERFORM SAVE-ACCOUNT
           *>END-IF

           *> display the starting menu
           MOVE "Welcome to InCollege!" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           MOVE "1. Log In" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           MOVE "2. Create New Account" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           MOVE "Enter your choice:" TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           *> read the user's choice from the input file
           PERFORM READ-USER-INPUT

           IF INPUT-AVAILABLE
               MOVE WS-USER-INPUT(1:1) TO WS-CHOICE
           END-IF
           
           IF WS-CHOICE = "1"
               PERFORM LOGIN-USER
           ELSE
               IF WS-CHOICE = "2"
                   PERFORM CREATE-ACCOUNT
               END-IF
           END-IF

           *> close files before ending the program
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE

           STOP RUN.
       WRITE-MESSAGE.

           *> display the message to the console
           DISPLAY FUNCTION TRIM(WS-MESSAGE)

           *> write the same message to the output file
           MOVE WS-MESSAGE TO OUTPUT-RECORD
           WRITE OUTPUT-RECORD

           EXIT.

       READ-USER-INPUT.

           *> read one line from the input file
           READ INPUT-FILE
               AT END
                   SET INPUT-ENDED TO TRUE
                   MOVE "No input found." TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
               NOT AT END
                   SET INPUT-AVAILABLE TO TRUE
                   MOVE INPUT-RECORD TO WS-USER-INPUT

                   *> copy the input to the output
                   MOVE INPUT-RECORD TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
           END-READ

           EXIT.
          
       LOAD-ACCOUNTS.

           *> read each saved account into the account table
           PERFORM UNTIL ACCOUNT-FILE-ENDED

               READ ACCOUNT-FILE
                   AT END
                       SET ACCOUNT-FILE-ENDED TO TRUE

                   NOT AT END
                       IF WS-ACCOUNT-COUNT < 5
                           ADD 1 TO WS-ACCOUNT-COUNT
                           MOVE ACCOUNT-RECORD-USERNAME
                               TO WS-ACCOUNT-USERNAME
                                   (WS-ACCOUNT-COUNT)
                           MOVE ACCOUNT-RECORD-PASSWORD
                               TO WS-ACCOUNT-PASSWORD
                                   (WS-ACCOUNT-COUNT)
                       END-IF
               END-READ

           END-PERFORM

           EXIT.

       SAVE-ACCOUNT.

           *> copy the new account into the file record
           MOVE WS-ACCOUNT-USERNAME(WS-ACCOUNT-COUNT)
               TO ACCOUNT-RECORD-USERNAME

           MOVE WS-ACCOUNT-PASSWORD(WS-ACCOUNT-COUNT)
               TO ACCOUNT-RECORD-PASSWORD

           *> append the new account to persistent storage
           OPEN EXTEND ACCOUNT-FILE
           WRITE ACCOUNT-RECORD
           CLOSE ACCOUNT-FILE

           EXIT.
       
       CREATE-ACCOUNT.

           *> make sure another account can be created
           IF WS-ACCOUNT-COUNT >= 5
               STRING
                   "All permitted accounts have been created, "
                   "please come back later"
                   INTO WS-MESSAGE
               END-STRING

               PERFORM WRITE-MESSAGE
               EXIT PARAGRAPH
           END-IF

           *> determine which account slot to use
           MOVE WS-ACCOUNT-COUNT TO WS-ACCOUNT-INDEX
           ADD 1 TO WS-ACCOUNT-INDEX

           *> keep asking until a unique username is entered
           MOVE "Y" TO WS-USERNAME-EXISTS

           PERFORM UNTIL USERNAME-AVAILABLE OR INPUT-ENDED

               MOVE "Please enter your username:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               PERFORM READ-USER-INPUT

               IF INPUT-ENDED
                   EXIT PERFORM
               END-IF

               PERFORM CHECK-USERNAME

               IF USERNAME-EXISTS
                   MOVE "Username already exists, please try again."
                       TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
               END-IF

           END-PERFORM

           IF INPUT-ENDED
               EXIT PARAGRAPH
           END-IF

           MOVE WS-USER-INPUT(1:20)
               TO WS-ACCOUNT-USERNAME(WS-ACCOUNT-INDEX)

           *> keep asking until a valid password is entered
           MOVE "N" TO WS-PASSWORD-VALID

           PERFORM UNTIL PASSWORD-VALID OR INPUT-ENDED

               MOVE "Please enter your password:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               PERFORM READ-USER-INPUT

               IF INPUT-ENDED
                   EXIT PERFORM
               END-IF

               PERFORM VALIDATE-PASSWORD

               IF NOT PASSWORD-VALID
                   MOVE "Invalid password, please try again."
                       TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
               END-IF

           END-PERFORM

           IF INPUT-ENDED
               EXIT PARAGRAPH
           END-IF

           MOVE WS-USER-INPUT(1:12)
               TO WS-ACCOUNT-PASSWORD(WS-ACCOUNT-INDEX)

           *> update the number of saved accounts
           MOVE WS-ACCOUNT-INDEX TO WS-ACCOUNT-COUNT

           *> save the new account to the account file
           PERFORM SAVE-ACCOUNT

           MOVE "Account successfully created." TO WS-MESSAGE
           PERFORM WRITE-MESSAGE

           EXIT.


       VALIDATE-PASSWORD.

           *> reset validation values
           MOVE 0 TO WS-PASSWORD-LENGTH
           MOVE "N" TO WS-HAS-UPPERCASE
           MOVE "N" TO WS-HAS-DIGIT
           MOVE "N" TO WS-HAS-SPECIAL
           MOVE "N" TO WS-PASSWORD-VALID

           *> find the actual password length
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-USER-INPUT))
               TO WS-PASSWORD-LENGTH

           *> check each character in the password
           PERFORM VARYING WS-CHAR-INDEX FROM 1 BY 1
               UNTIL WS-CHAR-INDEX > WS-PASSWORD-LENGTH
               
               *> check for uppercase letters
               IF WS-USER-INPUT(WS-CHAR-INDEX:1) >= "A"
                   AND WS-USER-INPUT(WS-CHAR-INDEX:1) <= "Z"
                   MOVE "Y" TO WS-HAS-UPPERCASE
               END-IF

               IF WS-USER-INPUT(WS-CHAR-INDEX:1) >= "0"
                   AND WS-USER-INPUT(WS-CHAR-INDEX:1) <= "9"
                   MOVE "Y" TO WS-HAS-DIGIT
               END-IF

               *> check for special characters
               IF NOT (
                   WS-USER-INPUT(WS-CHAR-INDEX:1) >= "A"
                   AND WS-USER-INPUT(WS-CHAR-INDEX:1) <= "Z"
               )
                   AND NOT (
                       WS-USER-INPUT(WS-CHAR-INDEX:1) >= "a"
                       AND WS-USER-INPUT(WS-CHAR-INDEX:1) <= "z"
                   )
                   AND NOT (
                       WS-USER-INPUT(WS-CHAR-INDEX:1) >= "0"
                       AND WS-USER-INPUT(WS-CHAR-INDEX:1) <= "9"
                   )
                   MOVE "Y" TO WS-HAS-SPECIAL
               END-IF

           END-PERFORM

           *> password is valid only if every requirement passes
           IF WS-PASSWORD-LENGTH >= 8
               AND WS-PASSWORD-LENGTH <= 12
               AND WS-HAS-UPPERCASE = "Y"
               AND WS-HAS-DIGIT = "Y"
               AND WS-HAS-SPECIAL = "Y"
                   MOVE "Y" TO WS-PASSWORD-VALID
           END-IF

           EXIT.

       LOGIN-USER.
           *> continue trying until a valid account is found
           PERFORM UNTIL LOGIN-FOUND OR INPUT-ENDED

               MOVE "N" TO WS-LOGIN-FOUND

               *> read the username
               MOVE "Please enter your username:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               PERFORM READ-USER-INPUT

               IF INPUT-ENDED
                   EXIT PERFORM
               END-IF

               MOVE WS-USER-INPUT(1:20)
                   TO WS-LOGIN-USERNAME

               *> read the password
               MOVE "Please enter your password:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               PERFORM READ-USER-INPUT

               IF INPUT-ENDED
                   EXIT PERFORM
               END-IF

               MOVE WS-USER-INPUT(1:12)
                   TO WS-LOGIN-PASSWORD

               *> search through every stored account
               PERFORM VARYING WS-ACCOUNT-INDEX FROM 1 BY 1
                   UNTIL WS-ACCOUNT-INDEX > WS-ACCOUNT-COUNT
                   OR LOGIN-FOUND

                   IF WS-LOGIN-USERNAME =
                       WS-ACCOUNT-USERNAME(WS-ACCOUNT-INDEX)
                       AND WS-LOGIN-PASSWORD =
                       WS-ACCOUNT-PASSWORD(WS-ACCOUNT-INDEX)

                       MOVE "Y" TO WS-LOGIN-FOUND
                   END-IF

               END-PERFORM

               *> report whether the login succeeded
               IF LOGIN-FOUND
                   MOVE "You have successfully logged in"
                       TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE

                   PERFORM USER-MENU
               ELSE
                   MOVE
                       "Incorrect username/password, please try again"
                       TO WS-MESSAGE
                   PERFORM WRITE-MESSAGE
               END-IF

           END-PERFORM

           EXIT.

       USER-MENU.

           MOVE "N" TO WS-LOGOUT-SELECTED

           PERFORM UNTIL LOGOUT-SELECTED OR INPUT-ENDED

               MOVE "1. Search for a job" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "2. Find someone you know" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "3. Learn a new skill" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "4. Logout" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "Enter your choice:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               PERFORM READ-USER-INPUT

               IF INPUT-AVAILABLE
                   MOVE WS-USER-INPUT(1:1) TO WS-CHOICE
               END-IF

               EVALUATE WS-CHOICE

                   WHEN "1"
                       STRING
                           "Job search/internship is "
                           "under construction."
                           INTO WS-MESSAGE
                       END-STRING
                       PERFORM WRITE-MESSAGE

                   WHEN "2"
                       STRING
                           "Find someone you know is "
                           "under construction."
                           INTO WS-MESSAGE
                       END-STRING
                       PERFORM WRITE-MESSAGE

                   WHEN "3"
                       PERFORM SKILL-MENU

                   WHEN "4"
                       MOVE "Y" TO WS-LOGOUT-SELECTED

                   WHEN OTHER
                       MOVE "Invalid selection." TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE

               END-EVALUATE

           END-PERFORM

           EXIT.


              SKILL-MENU.

           MOVE "N" TO WS-SKILL-BACK-SELECTED

           PERFORM UNTIL SKILL-BACK-SELECTED OR INPUT-ENDED

               MOVE "Learn a New Skill:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "1. Flip Resets" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "2. Double Taps" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "3. Musty Flicks" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "4. Wizard Flicks" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "5. Zen Touch" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "6. Go Back" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               MOVE "Enter your choice:" TO WS-MESSAGE
               PERFORM WRITE-MESSAGE

               PERFORM READ-USER-INPUT

               IF INPUT-AVAILABLE
                   MOVE WS-USER-INPUT(1:1) TO WS-CHOICE
               END-IF

               EVALUATE WS-CHOICE

                   WHEN "1"
                   WHEN "2"
                   WHEN "3"
                   WHEN "4"
                   WHEN "5"
                       MOVE "This skill is under construction."
                           TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE

                   WHEN "6"
                       MOVE "Y" TO WS-SKILL-BACK-SELECTED

                   WHEN OTHER
                       MOVE "Invalid selection." TO WS-MESSAGE
                       PERFORM WRITE-MESSAGE

               END-EVALUATE

           END-PERFORM

           EXIT.

       CHECK-USERNAME.

           MOVE "N" TO WS-USERNAME-EXISTS

           PERFORM VARYING WS-ACCOUNT-INDEX FROM 1 BY 1
               UNTIL WS-ACCOUNT-INDEX > WS-ACCOUNT-COUNT
               OR USERNAME-EXISTS

               IF WS-USER-INPUT(1:20) =
                   WS-ACCOUNT-USERNAME(WS-ACCOUNT-INDEX)

                   MOVE "Y" TO WS-USERNAME-EXISTS
               END-IF

           END-PERFORM

           EXIT.