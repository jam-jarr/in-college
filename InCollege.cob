       >>SOURCE FORMAT IS FREE
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

            *> set up persistent profile storage
            SELECT OPTIONAL PROFILE-FILE
                ASSIGN TO "profiles.txt"
                ORGANIZATION IS LINE SEQUENTIAL.

        DATA DIVISION.
       FILE SECTION.

       *> stores each line read from the input file
       FD INPUT-FILE.
        01 INPUT-RECORD PIC X(500).

       *> stores each line written to the output file
       FD OUTPUT-FILE.
       01 OUTPUT-RECORD PIC X(100).

        *> stores account records between program runs
        FD ACCOUNT-FILE.
        01 ACCOUNT-RECORD.
            05 ACCOUNT-RECORD-USERNAME PIC X(20).
            05 ACCOUNT-RECORD-PASSWORD PIC X(12).

        *> stores profile records between program runs
        FD PROFILE-FILE.
        01 PROFILE-RECORD.
            05 PROF-USERNAME        PIC X(20).
            05 PROF-FIRST-NAME       PIC X(20).
            05 PROF-LAST-NAME        PIC X(20).
            05 PROF-UNIVERSITY       PIC X(30).
            05 PROF-MAJOR            PIC X(30).
            05 PROF-GRAD-YEAR        PIC X(4).
            05 PROF-ABOUT-ME         PIC X(500).
            05 PROF-EXP-COUNT        PIC 9.
            05 PROF-EXPERIENCE OCCURS 3 TIMES.
                10 PROF-EXP-TITLE       PIC X(30).
                10 PROF-EXP-COMPANY     PIC X(30).
                10 PROF-EXP-DATES       PIC X(20).
                10 PROF-EXP-DESCRIPTION PIC X(200).
            05 PROF-EDU-COUNT        PIC 9.
            05 PROF-EDUCATION OCCURS 3 TIMES.
                10 PROF-EDU-DEGREE      PIC X(30).
                10 PROF-EDU-UNIVERSITY  PIC X(30).
                10 PROF-EDU-YEARS       PIC X(10).

        WORKING-STORAGE SECTION.

       *> temporary values used while the program runs
       01 WS-MESSAGE PIC X(100).
        01 WS-USER-INPUT PIC X(500).
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

        *> input mode: F = file (default), C = console
        01 WS-INPUT-MODE PIC X VALUE 'F'.
            88 FILE-INPUT-MODE VALUE 'F'.
            88 CONSOLE-INPUT-MODE VALUE 'C'.

        *> profile data (up to 5, matching max accounts)
        01 WS-PROFILES.
            05 WS-PROFILE OCCURS 5 TIMES.
                10 WS-PROF-USERNAME        PIC X(20).
                10 WS-PROF-FIRST-NAME     PIC X(20).
                10 WS-PROF-LAST-NAME      PIC X(20).
                10 WS-PROF-UNIVERSITY     PIC X(30).
                10 WS-PROF-MAJOR          PIC X(30).
                10 WS-PROF-GRAD-YEAR      PIC X(4).
                10 WS-PROF-ABOUT-ME       PIC X(500).
                10 WS-PROF-EXP-COUNT      PIC 9 VALUE 0.
                10 WS-PROF-EXPERIENCE OCCURS 3 TIMES.
                    15 WS-EXP-TITLE       PIC X(30).
                    15 WS-EXP-COMPANY     PIC X(30).
                    15 WS-EXP-DATES       PIC X(20).
                    15 WS-EXP-DESCRIPTION PIC X(200).
                10 WS-PROF-EDU-COUNT      PIC 9 VALUE 0.
                10 WS-PROF-EDUCATION OCCURS 3 TIMES.
                    15 WS-EDU-DEGREE      PIC X(30).
                    15 WS-EDU-UNIVERSITY  PIC X(30).
                    15 WS-EDU-YEARS       PIC X(10).

        01 WS-PROFILE-COUNT PIC 9 VALUE 0.
        01 WS-PROFILE-INDEX PIC 9 VALUE 0.
        01 WS-CURRENT-PROFILE-INDEX PIC 9 VALUE 0.

        01 WS-PROFILE-FOUND PIC X VALUE "N".
            88 PROFILE-FOUND VALUE "Y".
            88 PROFILE-NOT-FOUND VALUE "N".

        01 WS-PROFILE-FILE-ENDED PIC X VALUE "N".
            88 PROFILE-FILE-ENDED VALUE "Y".
            88 PROFILE-FILE-AVAILABLE VALUE "N".

        01 WS-TEMP-CHOICE PIC X.
        01 WS-EDIT-INDEX PIC 9.

        01 WS-GRAD-YEAR-VALID PIC X VALUE "N".
            88 GRAD-YEAR-VALID VALUE "Y".
            88 GRAD-YEAR-INVALID VALUE "N".

        01 WS-GRAD-YEAR-NUM PIC 9(4).

        01 WS-INPUT-LENGTH PIC 9(3) VALUE 0.

        01 WS-REQUIRED-FIELD-VALID PIC X VALUE "N".
            88 REQUIRED-FIELD-VALID VALUE "Y".
            88 REQUIRED-FIELD-INVALID VALUE "N".
       


        01 WS-SAVE-PROFILE PIC X VALUE "N".
            88 SAVE-PROFILE VALUE "Y".
            88 DISCARD-PROFILE VALUE "N".
        01 WS-SECTION-QUIT PIC X VALUE "N".
            88 SECTION-QUIT VALUE "Y".
            88 SECTION-CONTINUE VALUE "N".

        PROCEDURE DIVISION.

       MAIN-PROCEDURE.

           *> open the files for reading and writing
           OPEN INPUT INPUT-FILE
           OPEN OUTPUT OUTPUT-FILE

           *> load saved accounts
            OPEN INPUT ACCOUNT-FILE
            PERFORM LOAD-ACCOUNTS
            CLOSE ACCOUNT-FILE *> close now to reopen later for writing

            PERFORM LOAD-PROFILES

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

            IF INPUT-ENDED
                EXIT PARAGRAPH
            END-IF

            IF CONSOLE-INPUT-MODE
                ACCEPT WS-USER-INPUT
                SET INPUT-AVAILABLE TO TRUE
                MOVE WS-USER-INPUT TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
            ELSE
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
            END-IF

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

                MOVE "1. Edit or create profile" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE

                MOVE "2. View my profile" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE

                MOVE "3. Search for a job" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE

                MOVE "4. Find someone you know" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE

                MOVE "5. Learn a new skill" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE

                MOVE "6. Logout" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE

                MOVE "Enter your choice:" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE

                PERFORM READ-USER-INPUT

                IF INPUT-AVAILABLE
                    MOVE WS-USER-INPUT(1:1) TO WS-CHOICE
                END-IF

                EVALUATE WS-CHOICE

                    WHEN "1"
                        PERFORM EDIT-PROFILE

                    WHEN "2"
                        PERFORM VIEW-PROFILE

                    WHEN "3"
                        STRING
                            "Job search/internship is "
                            "under construction."
                            INTO WS-MESSAGE
                        END-STRING
                        PERFORM WRITE-MESSAGE

                    WHEN "4"
                        STRING
                            "Find someone you know is "
                            "under construction."
                            INTO WS-MESSAGE
                        END-STRING
                        PERFORM WRITE-MESSAGE

                    WHEN "5"
                        PERFORM SKILL-MENU

                    WHEN "6"
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

        LOAD-PROFILES.

            MOVE 0 TO WS-PROFILE-COUNT
            SET PROFILE-FILE-AVAILABLE TO TRUE
            OPEN INPUT PROFILE-FILE
            PERFORM UNTIL PROFILE-FILE-ENDED
                READ PROFILE-FILE
                    AT END
                        SET PROFILE-FILE-ENDED TO TRUE
                    NOT AT END
                        IF WS-PROFILE-COUNT < 5
                            ADD 1 TO WS-PROFILE-COUNT
                            MOVE PROF-USERNAME
                                TO WS-PROF-USERNAME(WS-PROFILE-COUNT)
                            MOVE PROF-FIRST-NAME
                                TO WS-PROF-FIRST-NAME(WS-PROFILE-COUNT)
                            MOVE PROF-LAST-NAME
                                TO WS-PROF-LAST-NAME(WS-PROFILE-COUNT)
                            MOVE PROF-UNIVERSITY
                                TO WS-PROF-UNIVERSITY(WS-PROFILE-COUNT)
                            MOVE PROF-MAJOR
                                TO WS-PROF-MAJOR(WS-PROFILE-COUNT)
                            MOVE PROF-GRAD-YEAR
                                TO WS-PROF-GRAD-YEAR(WS-PROFILE-COUNT)
                            MOVE PROF-ABOUT-ME
                                TO WS-PROF-ABOUT-ME(WS-PROFILE-COUNT)
                            MOVE PROF-EXP-COUNT
                                TO WS-PROF-EXP-COUNT(WS-PROFILE-COUNT)
                            PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                                UNTIL WS-EDIT-INDEX > 3
                                MOVE PROF-EXP-TITLE(WS-EDIT-INDEX)
                                    TO WS-EXP-TITLE(WS-PROFILE-COUNT,
                                        WS-EDIT-INDEX)
                                MOVE PROF-EXP-COMPANY(WS-EDIT-INDEX)
                                    TO WS-EXP-COMPANY(WS-PROFILE-COUNT,
                                        WS-EDIT-INDEX)
                                MOVE PROF-EXP-DATES(WS-EDIT-INDEX)
                                    TO WS-EXP-DATES(WS-PROFILE-COUNT,
                                        WS-EDIT-INDEX)
                                MOVE PROF-EXP-DESCRIPTION(WS-EDIT-INDEX)
                                    TO WS-EXP-DESCRIPTION(WS-PROFILE-COUNT,
                                        WS-EDIT-INDEX)
                            END-PERFORM
                            MOVE PROF-EDU-COUNT
                                TO WS-PROF-EDU-COUNT(WS-PROFILE-COUNT)
                            PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                                UNTIL WS-EDIT-INDEX > 3
                                MOVE PROF-EDU-DEGREE(WS-EDIT-INDEX)
                                    TO WS-EDU-DEGREE(WS-PROFILE-COUNT,
                                        WS-EDIT-INDEX)
                                MOVE PROF-EDU-UNIVERSITY(WS-EDIT-INDEX)
                                    TO WS-EDU-UNIVERSITY(WS-PROFILE-COUNT,
                                        WS-EDIT-INDEX)
                                MOVE PROF-EDU-YEARS(WS-EDIT-INDEX)
                                    TO WS-EDU-YEARS(WS-PROFILE-COUNT,
                                        WS-EDIT-INDEX)
                            END-PERFORM
                        END-IF
                END-READ
            END-PERFORM
            CLOSE PROFILE-FILE
            EXIT.

        SAVE-PROFILES.

            OPEN OUTPUT PROFILE-FILE
            PERFORM VARYING WS-PROFILE-INDEX FROM 1 BY 1
                UNTIL WS-PROFILE-INDEX > WS-PROFILE-COUNT
                MOVE WS-PROF-USERNAME(WS-PROFILE-INDEX)
                    TO PROF-USERNAME
                MOVE WS-PROF-FIRST-NAME(WS-PROFILE-INDEX)
                    TO PROF-FIRST-NAME
                MOVE WS-PROF-LAST-NAME(WS-PROFILE-INDEX)
                    TO PROF-LAST-NAME
                MOVE WS-PROF-UNIVERSITY(WS-PROFILE-INDEX)
                    TO PROF-UNIVERSITY
                MOVE WS-PROF-MAJOR(WS-PROFILE-INDEX)
                    TO PROF-MAJOR
                MOVE WS-PROF-GRAD-YEAR(WS-PROFILE-INDEX)
                    TO PROF-GRAD-YEAR
                MOVE WS-PROF-ABOUT-ME(WS-PROFILE-INDEX)
                    TO PROF-ABOUT-ME
                MOVE WS-PROF-EXP-COUNT(WS-PROFILE-INDEX)
                    TO PROF-EXP-COUNT
                PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                    UNTIL WS-EDIT-INDEX > 3
                    MOVE WS-EXP-TITLE(WS-PROFILE-INDEX, WS-EDIT-INDEX)
                        TO PROF-EXP-TITLE(WS-EDIT-INDEX)
                    MOVE WS-EXP-COMPANY(WS-PROFILE-INDEX, WS-EDIT-INDEX)
                        TO PROF-EXP-COMPANY(WS-EDIT-INDEX)
                    MOVE WS-EXP-DATES(WS-PROFILE-INDEX, WS-EDIT-INDEX)
                        TO PROF-EXP-DATES(WS-EDIT-INDEX)
                    MOVE WS-EXP-DESCRIPTION(WS-PROFILE-INDEX, WS-EDIT-INDEX)
                        TO PROF-EXP-DESCRIPTION(WS-EDIT-INDEX)
                END-PERFORM
                MOVE WS-PROF-EDU-COUNT(WS-PROFILE-INDEX)
                    TO PROF-EDU-COUNT
                PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                    UNTIL WS-EDIT-INDEX > 3
                    MOVE WS-EDU-DEGREE(WS-PROFILE-INDEX, WS-EDIT-INDEX)
                        TO PROF-EDU-DEGREE(WS-EDIT-INDEX)
                    MOVE WS-EDU-UNIVERSITY(WS-PROFILE-INDEX, WS-EDIT-INDEX)
                        TO PROF-EDU-UNIVERSITY(WS-EDIT-INDEX)
                    MOVE WS-EDU-YEARS(WS-PROFILE-INDEX, WS-EDIT-INDEX)
                        TO PROF-EDU-YEARS(WS-EDIT-INDEX)
                END-PERFORM
                WRITE PROFILE-RECORD
            END-PERFORM
            CLOSE PROFILE-FILE
            EXIT.

        VIEW-PROFILE.
            *> find existing profile for current logged-in user
            SET PROFILE-NOT-FOUND TO TRUE
            MOVE 0 TO WS-CURRENT-PROFILE-INDEX

            PERFORM VARYING WS-PROFILE-INDEX FROM 1 BY 1
                UNTIL WS-PROFILE-INDEX > WS-PROFILE-COUNT
                OR PROFILE-FOUND

                IF WS-PROF-USERNAME(WS-PROFILE-INDEX) =
                    WS-LOGIN-USERNAME

                    SET PROFILE-FOUND TO TRUE
                    MOVE WS-PROFILE-INDEX
                        TO WS-CURRENT-PROFILE-INDEX
                END-IF
            END-PERFORM

            IF PROFILE-FOUND
                PERFORM DISPLAY-PROFILE
            ELSE
                MOVE "No profile found. Please create a profile first."
                    TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
            END-IF

            EXIT.


        EDIT-PROFILE.

            *> find existing profile for current user
            SET PROFILE-NOT-FOUND TO TRUE
            MOVE 0 TO WS-CURRENT-PROFILE-INDEX
            PERFORM VARYING WS-PROFILE-INDEX FROM 1 BY 1
                UNTIL WS-PROFILE-INDEX > WS-PROFILE-COUNT
                OR PROFILE-FOUND
                IF WS-PROF-USERNAME(WS-PROFILE-INDEX) =
                    WS-LOGIN-USERNAME
                    SET PROFILE-FOUND TO TRUE
                    MOVE WS-PROFILE-INDEX TO WS-CURRENT-PROFILE-INDEX
                END-IF
            END-PERFORM

            *> if not found, create a new profile slot
            IF PROFILE-NOT-FOUND
                IF WS-PROFILE-COUNT < 5
                    ADD 1 TO WS-PROFILE-COUNT
                    MOVE WS-PROFILE-COUNT TO WS-CURRENT-PROFILE-INDEX
                    MOVE WS-LOGIN-USERNAME
                        TO WS-PROF-USERNAME(WS-CURRENT-PROFILE-INDEX)
                    MOVE SPACES
                        TO WS-PROF-FIRST-NAME(WS-CURRENT-PROFILE-INDEX)
                    MOVE SPACES
                        TO WS-PROF-LAST-NAME(WS-CURRENT-PROFILE-INDEX)
                    MOVE SPACES
                        TO WS-PROF-UNIVERSITY(WS-CURRENT-PROFILE-INDEX)
                    MOVE SPACES
                        TO WS-PROF-MAJOR(WS-CURRENT-PROFILE-INDEX)
                    MOVE SPACES
                        TO WS-PROF-GRAD-YEAR(WS-CURRENT-PROFILE-INDEX)
                    MOVE SPACES
                        TO WS-PROF-ABOUT-ME(WS-CURRENT-PROFILE-INDEX)
                    MOVE 0
                        TO WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX)
                    MOVE 0
                        TO WS-PROF-EDU-COUNT(WS-CURRENT-PROFILE-INDEX)
                    PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                        UNTIL WS-EDIT-INDEX > 3
                        MOVE SPACES TO WS-EXP-TITLE(
                            WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX)
                        MOVE SPACES TO WS-EXP-COMPANY(
                            WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX)
                        MOVE SPACES TO WS-EXP-DATES(
                            WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX)
                        MOVE SPACES TO WS-EXP-DESCRIPTION(
                            WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX)
                        MOVE SPACES TO WS-EDU-DEGREE(
                            WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX)
                        MOVE SPACES TO WS-EDU-UNIVERSITY(
                            WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX)
                        MOVE SPACES TO WS-EDU-YEARS(
                            WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX)
                    END-PERFORM
                ELSE
                    MOVE "Maximum profiles reached." TO WS-MESSAGE
                    PERFORM WRITE-MESSAGE
                    EXIT PARAGRAPH
                END-IF
            END-IF

            PERFORM EDIT-REQUIRED-FIELDS
            PERFORM EDIT-OPTIONAL-SECTIONS
            PERFORM DISPLAY-PROFILE

            MOVE "Save profile? (y/N):" TO WS-MESSAGE
            PERFORM WRITE-MESSAGE
            PERFORM READ-USER-INPUT
            IF INPUT-AVAILABLE
                MOVE WS-USER-INPUT(1:1) TO WS-TEMP-CHOICE
                IF WS-TEMP-CHOICE = 'Y' OR WS-TEMP-CHOICE = 'y'
                    PERFORM SAVE-PROFILES
                    MOVE "Profile saved." TO WS-MESSAGE
                    PERFORM WRITE-MESSAGE
                ELSE
                    MOVE "Changes discarded." TO WS-MESSAGE
                    PERFORM WRITE-MESSAGE
                    PERFORM LOAD-PROFILES
                END-IF
            ELSE
                MOVE "No input received. Changes discarded." TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM LOAD-PROFILES
            END-IF

            EXIT.

        EDIT-REQUIRED-FIELDS.

            *> First Name
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED

                IF WS-PROF-FIRST-NAME(
                    WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                    STRING
                        "First name ("
                        FUNCTION TRIM(WS-PROF-FIRST-NAME(
                            WS-CURRENT-PROFILE-INDEX))
                        "): "
                        INTO WS-MESSAGE
                    END-STRING
                ELSE
                    MOVE "First name: " TO WS-MESSAGE
                END-IF

                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-PROF-FIRST-NAME(
                        WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                        *> blank keeps existing value when editing
                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "First name is required."
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:20)
                        TO WS-PROF-FIRST-NAME(
                            WS-CURRENT-PROFILE-INDEX)

                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF

            END-PERFORM

            *> Last Name
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED

                IF WS-PROF-LAST-NAME(
                    WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                    STRING
                        "Last name ("
                        FUNCTION TRIM(WS-PROF-LAST-NAME(
                            WS-CURRENT-PROFILE-INDEX))
                        "): "
                        INTO WS-MESSAGE
                    END-STRING
                ELSE
                    MOVE "Last name: " TO WS-MESSAGE
                END-IF

                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-PROF-LAST-NAME(
                        WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                        *> blank keeps existing value when editing
                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "Last name is required."
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:20)
                        TO WS-PROF-LAST-NAME(
                            WS-CURRENT-PROFILE-INDEX)

                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF

            END-PERFORM

            *> University/College
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED

                IF WS-PROF-UNIVERSITY(
                    WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                    STRING
                        "University/College ("
                        FUNCTION TRIM(WS-PROF-UNIVERSITY(
                            WS-CURRENT-PROFILE-INDEX))
                        "): "
                        INTO WS-MESSAGE
                    END-STRING
                ELSE
                    MOVE "University/College: " TO WS-MESSAGE
                END-IF

                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-PROF-UNIVERSITY(
                        WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                        *> blank keeps existing value when editing
                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "University/College is required."
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:50)
                        TO WS-PROF-UNIVERSITY(
                            WS-CURRENT-PROFILE-INDEX)

                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF

            END-PERFORM

            *> Major
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED

                IF WS-PROF-MAJOR(
                    WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                    STRING
                        "Major ("
                        FUNCTION TRIM(WS-PROF-MAJOR(
                            WS-CURRENT-PROFILE-INDEX))
                        "): "
                        INTO WS-MESSAGE
                    END-STRING
                ELSE
                    MOVE "Major: " TO WS-MESSAGE
                END-IF

                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-PROF-MAJOR(
                        WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                        *> blank keeps existing value when editing
                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "Major is required."
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:50)
                        TO WS-PROF-MAJOR(
                            WS-CURRENT-PROFILE-INDEX)

                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF

            END-PERFORM

            *> Graduation Year
            SET GRAD-YEAR-INVALID TO TRUE

            PERFORM UNTIL GRAD-YEAR-VALID OR INPUT-ENDED

                IF WS-PROF-GRAD-YEAR(
                    WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                    STRING
                        "Graduation year ("
                        FUNCTION TRIM(WS-PROF-GRAD-YEAR(
                            WS-CURRENT-PROFILE-INDEX))
                        "): "
                        INTO WS-MESSAGE
                    END-STRING
                ELSE
                    MOVE "Graduation year: " TO WS-MESSAGE
                END-IF

                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-PROF-GRAD-YEAR(
                        WS-CURRENT-PROFILE-INDEX) NOT = SPACES

                        *> blank keeps the existing year when editing
                        SET GRAD-YEAR-VALID TO TRUE
                    ELSE
                        MOVE
                            "Graduation year is required."
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    IF WS-USER-INPUT(1:4) IS NUMERIC
                        AND WS-USER-INPUT(5:496) = SPACES

                        MOVE WS-USER-INPUT(1:4)
                            TO WS-GRAD-YEAR-NUM

                        IF WS-GRAD-YEAR-NUM > 2025
                            AND WS-GRAD-YEAR-NUM < 2034

                            MOVE WS-USER-INPUT(1:4)
                                TO WS-PROF-GRAD-YEAR(
                                    WS-CURRENT-PROFILE-INDEX)

                            SET GRAD-YEAR-VALID TO TRUE
                        ELSE
                            MOVE
                                "Graduation year must be 2026-2033."
                                TO WS-MESSAGE
                            PERFORM WRITE-MESSAGE
                        END-IF
                    ELSE
                        MOVE
                            "Graduation year must be a 4-digit number."
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                END-IF

            END-PERFORM
            EXIT.

        EDIT-OPTIONAL-SECTIONS.

            *> About Me
            MOVE "Edit About Me? (y/N):" TO WS-MESSAGE
            PERFORM WRITE-MESSAGE
            PERFORM READ-USER-INPUT

            IF INPUT-AVAILABLE
                MOVE WS-USER-INPUT(1:1) TO WS-TEMP-CHOICE

                IF WS-TEMP-CHOICE = 'Y' OR WS-TEMP-CHOICE = 'y'

                    SET REQUIRED-FIELD-INVALID TO TRUE

                    PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED

                        MOVE
                            "Enter About Me (optional, max 200 chars):"
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                        PERFORM READ-USER-INPUT

                        IF INPUT-ENDED
                            EXIT PERFORM
                        END-IF

                        MOVE FUNCTION LENGTH(
                            FUNCTION TRIM(WS-USER-INPUT))
                            TO WS-INPUT-LENGTH

                        IF WS-INPUT-LENGTH <= 200
                            MOVE WS-USER-INPUT(1:200)
                                TO WS-PROF-ABOUT-ME(
                                    WS-CURRENT-PROFILE-INDEX)
                            SET REQUIRED-FIELD-VALID TO TRUE
                        ELSE
                            MOVE
                                "About Me must be 200 characters or less."
                                TO WS-MESSAGE
                            PERFORM WRITE-MESSAGE
                        END-IF

                    END-PERFORM

                END-IF
            END-IF

            *> Experience
            SET SECTION-CONTINUE TO TRUE
            MOVE "Edit Experience? (y/N):" TO WS-MESSAGE
            PERFORM WRITE-MESSAGE
            PERFORM READ-USER-INPUT
            IF INPUT-AVAILABLE
                MOVE WS-USER-INPUT(1:1) TO WS-TEMP-CHOICE
                IF WS-TEMP-CHOICE = 'Y' OR WS-TEMP-CHOICE = 'y'
                    PERFORM EDIT-EXPERIENCE
                END-IF
            END-IF

            *> Education
            SET SECTION-CONTINUE TO TRUE
            MOVE "Edit Education? (y/N):" TO WS-MESSAGE
            PERFORM WRITE-MESSAGE
            PERFORM READ-USER-INPUT
            IF INPUT-AVAILABLE
                MOVE WS-USER-INPUT(1:1) TO WS-TEMP-CHOICE
                IF WS-TEMP-CHOICE = 'Y' OR WS-TEMP-CHOICE = 'y'
                    PERFORM EDIT-EDUCATION
                END-IF
            END-IF

            EXIT.

        EDIT-EXPERIENCE.

            SET SECTION-CONTINUE TO TRUE
            *> show existing entries and offer to modify
            PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                UNTIL WS-EDIT-INDEX >
                    WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX)
                OR SECTION-QUIT

                STRING
                    "Modify experience entry "
                    WS-EDIT-INDEX
                    " ("
                    FUNCTION TRIM(WS-EXP-TITLE(
                        WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX))
                    ")? (y/N/q):"
                    INTO WS-MESSAGE
                END-STRING
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-AVAILABLE
                    MOVE WS-USER-INPUT(1:1) TO WS-TEMP-CHOICE
                    EVALUATE WS-TEMP-CHOICE
                        WHEN 'Y'
                        WHEN 'y'
                            PERFORM EDIT-EXPERIENCE-ENTRY
                        WHEN 'q'
                        WHEN 'Q'
                            SET SECTION-QUIT TO TRUE
                        WHEN OTHER
                            CONTINUE
                    END-EVALUATE
                END-IF
            END-PERFORM

            *> offer to add new entries if not quit and room remains
            IF NOT SECTION-QUIT
                PERFORM UNTIL
                    WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX) >= 3
                    OR SECTION-QUIT

                    ADD 1 TO WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX)
                    MOVE WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX)
                        TO WS-EDIT-INDEX
                    STRING
                        "Add experience entry "
                        WS-EDIT-INDEX
                        "? (y/N):"
                        INTO WS-MESSAGE
                    END-STRING
                    PERFORM WRITE-MESSAGE
                    PERFORM READ-USER-INPUT

                    IF INPUT-AVAILABLE
                        MOVE WS-USER-INPUT(1:1) TO WS-TEMP-CHOICE
                        IF WS-TEMP-CHOICE = 'Y'
                            OR WS-TEMP-CHOICE = 'y'
                            PERFORM EDIT-EXPERIENCE-ENTRY
                        ELSE
                            SUBTRACT 1 FROM
                                WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX)
                            SET SECTION-QUIT TO TRUE
                        END-IF
                    ELSE
                        SUBTRACT 1 FROM
                            WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX)
                        SET SECTION-QUIT TO TRUE
                    END-IF
                END-PERFORM
            END-IF

            SET SECTION-CONTINUE TO TRUE
            EXIT.

        EDIT-EXPERIENCE-ENTRY.

            *> Title - required
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED
                MOVE "  Title: " TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-EXP-TITLE(
                        WS-CURRENT-PROFILE-INDEX,
                        WS-EDIT-INDEX) NOT = SPACES

                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "Title is required." TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:30)
                        TO WS-EXP-TITLE(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX)
                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF
            END-PERFORM

            *> Company - required
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED
                MOVE "  Company: " TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-EXP-COMPANY(
                        WS-CURRENT-PROFILE-INDEX,
                        WS-EDIT-INDEX) NOT = SPACES

                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "Company is required." TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:30)
                        TO WS-EXP-COMPANY(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX)
                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF
            END-PERFORM

            *> Dates - required
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED
                MOVE "  Dates: " TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-EXP-DATES(
                        WS-CURRENT-PROFILE-INDEX,
                        WS-EDIT-INDEX) NOT = SPACES

                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "Dates are required." TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:20)
                        TO WS-EXP-DATES(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX)
                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF
            END-PERFORM

            *> Description - optional, max 100 characters
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED
                MOVE
                    "  Description (optional, max 100 chars): "
                    TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                MOVE FUNCTION LENGTH(
                    FUNCTION TRIM(WS-USER-INPUT))
                    TO WS-INPUT-LENGTH

                IF WS-INPUT-LENGTH <= 100
                    MOVE WS-USER-INPUT(1:100)
                        TO WS-EXP-DESCRIPTION(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX)
                    SET REQUIRED-FIELD-VALID TO TRUE
                ELSE
                    MOVE
                        "Description must be 100 characters or less."
                        TO WS-MESSAGE
                    PERFORM WRITE-MESSAGE
                END-IF
            END-PERFORM

            EXIT.


        EDIT-EDUCATION.

            SET SECTION-CONTINUE TO TRUE
            *> show existing entries and offer to modify
            PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                UNTIL WS-EDIT-INDEX >
                    WS-PROF-EDU-COUNT(WS-CURRENT-PROFILE-INDEX)
                OR SECTION-QUIT

                STRING
                    "Modify education entry "
                    WS-EDIT-INDEX
                    " ("
                    FUNCTION TRIM(WS-EDU-DEGREE(
                        WS-CURRENT-PROFILE-INDEX, WS-EDIT-INDEX))
                    ")? (y/N/q):"
                    INTO WS-MESSAGE
                END-STRING
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-AVAILABLE
                    MOVE WS-USER-INPUT(1:1) TO WS-TEMP-CHOICE
                    EVALUATE WS-TEMP-CHOICE
                        WHEN 'Y'
                        WHEN 'y'
                            PERFORM EDIT-EDUCATION-ENTRY
                        WHEN 'q'
                        WHEN 'Q'
                            SET SECTION-QUIT TO TRUE
                        WHEN OTHER
                            CONTINUE
                    END-EVALUATE
                END-IF
            END-PERFORM

            *> offer to add new entries if not quit and room remains
            IF NOT SECTION-QUIT
                PERFORM UNTIL
                    WS-PROF-EDU-COUNT(WS-CURRENT-PROFILE-INDEX) >= 3
                    OR SECTION-QUIT

                    ADD 1 TO WS-PROF-EDU-COUNT(WS-CURRENT-PROFILE-INDEX)
                    MOVE WS-PROF-EDU-COUNT(WS-CURRENT-PROFILE-INDEX)
                        TO WS-EDIT-INDEX
                    STRING
                        "Add education entry "
                        WS-EDIT-INDEX
                        "? (y/N):"
                        INTO WS-MESSAGE
                    END-STRING
                    PERFORM WRITE-MESSAGE
                    PERFORM READ-USER-INPUT

                    IF INPUT-AVAILABLE
                        MOVE WS-USER-INPUT(1:1) TO WS-TEMP-CHOICE
                        IF WS-TEMP-CHOICE = 'Y'
                            OR WS-TEMP-CHOICE = 'y'
                            PERFORM EDIT-EDUCATION-ENTRY
                        ELSE
                            SUBTRACT 1 FROM
                                WS-PROF-EDU-COUNT(
                                    WS-CURRENT-PROFILE-INDEX)
                            SET SECTION-QUIT TO TRUE
                        END-IF
                    ELSE
                        SUBTRACT 1 FROM
                            WS-PROF-EDU-COUNT(
                                WS-CURRENT-PROFILE-INDEX)
                        SET SECTION-QUIT TO TRUE
                    END-IF
                END-PERFORM
            END-IF

            SET SECTION-CONTINUE TO TRUE
            EXIT.

        EDIT-EDUCATION-ENTRY.

            *> Degree - required
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED
                MOVE "  Degree: " TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-EDU-DEGREE(
                        WS-CURRENT-PROFILE-INDEX,
                        WS-EDIT-INDEX) NOT = SPACES

                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "Degree is required." TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:30)
                        TO WS-EDU-DEGREE(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX)
                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF
            END-PERFORM

            *> University - required
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED
                MOVE "  University: " TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-EDU-UNIVERSITY(
                        WS-CURRENT-PROFILE-INDEX,
                        WS-EDIT-INDEX) NOT = SPACES

                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "University is required." TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:30)
                        TO WS-EDU-UNIVERSITY(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX)
                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF
            END-PERFORM

            *> Years attended - required
            SET REQUIRED-FIELD-INVALID TO TRUE

            PERFORM UNTIL REQUIRED-FIELD-VALID OR INPUT-ENDED
                MOVE "  Years attended: " TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM READ-USER-INPUT

                IF INPUT-ENDED
                    EXIT PERFORM
                END-IF

                IF WS-USER-INPUT = SPACES
                    IF WS-EDU-YEARS(
                        WS-CURRENT-PROFILE-INDEX,
                        WS-EDIT-INDEX) NOT = SPACES

                        SET REQUIRED-FIELD-VALID TO TRUE
                    ELSE
                        MOVE "Years attended is required."
                            TO WS-MESSAGE
                        PERFORM WRITE-MESSAGE
                    END-IF
                ELSE
                    MOVE WS-USER-INPUT(1:10)
                        TO WS-EDU-YEARS(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX)
                    SET REQUIRED-FIELD-VALID TO TRUE
                END-IF
            END-PERFORM

            EXIT.

        DISPLAY-PROFILE.

            MOVE "=== Profile Preview ===" TO WS-MESSAGE
            PERFORM WRITE-MESSAGE

            MOVE SPACES TO WS-MESSAGE
            STRING
                "Name: "
                FUNCTION TRIM(WS-PROF-FIRST-NAME(
                    WS-CURRENT-PROFILE-INDEX))
                " "
                FUNCTION TRIM(WS-PROF-LAST-NAME(
                    WS-CURRENT-PROFILE-INDEX))
                INTO WS-MESSAGE
            END-STRING
            PERFORM WRITE-MESSAGE

            MOVE SPACES TO WS-MESSAGE
            STRING
                "University: "
                FUNCTION TRIM(WS-PROF-UNIVERSITY(
                    WS-CURRENT-PROFILE-INDEX))
                " | Major: "
                FUNCTION TRIM(WS-PROF-MAJOR(
                    WS-CURRENT-PROFILE-INDEX))
                " | Graduation: "
                FUNCTION TRIM(WS-PROF-GRAD-YEAR(
                    WS-CURRENT-PROFILE-INDEX))
                INTO WS-MESSAGE
            END-STRING
            PERFORM WRITE-MESSAGE

            IF WS-PROF-ABOUT-ME(WS-CURRENT-PROFILE-INDEX) NOT = SPACES
                MOVE SPACES TO WS-MESSAGE
                STRING
                    "About Me: "
                    FUNCTION TRIM(WS-PROF-ABOUT-ME(
                        WS-CURRENT-PROFILE-INDEX))
                    INTO WS-MESSAGE
                END-STRING
                PERFORM WRITE-MESSAGE
            END-IF

            IF WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX) > 0
                MOVE "Experience:" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                    UNTIL WS-EDIT-INDEX >
                        WS-PROF-EXP-COUNT(WS-CURRENT-PROFILE-INDEX)
                    MOVE SPACES TO WS-MESSAGE
                    STRING
                        "  "
                        WS-EDIT-INDEX
                        ". "
                        FUNCTION TRIM(WS-EXP-TITLE(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX))
                        " at "
                        FUNCTION TRIM(WS-EXP-COMPANY(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX))
                        " ("
                        FUNCTION TRIM(WS-EXP-DATES(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX))
                        ")"
                        INTO WS-MESSAGE
                    END-STRING
                    PERFORM WRITE-MESSAGE
                    MOVE SPACES TO WS-MESSAGE
                    STRING
                        "     "
                        FUNCTION TRIM(WS-EXP-DESCRIPTION(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX))
                        INTO WS-MESSAGE
                    END-STRING
                    PERFORM WRITE-MESSAGE
                END-PERFORM
            END-IF

            IF WS-PROF-EDU-COUNT(WS-CURRENT-PROFILE-INDEX) > 0
                MOVE "Education:" TO WS-MESSAGE
                PERFORM WRITE-MESSAGE
                PERFORM VARYING WS-EDIT-INDEX FROM 1 BY 1
                    UNTIL WS-EDIT-INDEX >
                        WS-PROF-EDU-COUNT(WS-CURRENT-PROFILE-INDEX)
                    MOVE SPACES TO WS-MESSAGE
                    STRING
                        "  "
                        WS-EDIT-INDEX
                        ". "
                        FUNCTION TRIM(WS-EDU-DEGREE(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX))
                        ", "
                        FUNCTION TRIM(WS-EDU-UNIVERSITY(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX))
                        " ("
                        FUNCTION TRIM(WS-EDU-YEARS(
                            WS-CURRENT-PROFILE-INDEX,
                            WS-EDIT-INDEX))
                        ")"
                        INTO WS-MESSAGE
                    END-STRING
                    PERFORM WRITE-MESSAGE
                END-PERFORM
            END-IF

            MOVE "=======================" TO WS-MESSAGE
            PERFORM WRITE-MESSAGE

            EXIT.
